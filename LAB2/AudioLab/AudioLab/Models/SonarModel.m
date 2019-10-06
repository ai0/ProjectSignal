//
//  SonarModel.m
//  AudioLab
//
//  Created by Jing Su on 9/28/19.
//  Copyright © 2019 Jing Su. All rights reserved.
//

#import "SonarModel.h"
#import "CircularBuffer.h"
#import "FFTHelper.h"
#import "Novocaine.h"

@interface SonarModel ()
@property (strong, nonatomic) Novocaine *audioManager;
@property (strong, nonatomic) CircularBuffer *buffer;
@property (strong, nonatomic) FFTHelper *fftHelper;
@property (nonatomic) float *audioData;
@property (nonatomic) float *fftData;
@property (nonatomic) float *measuredResult;
@property (nonatomic) dispatch_queue_t probeQueue;
@property (nonatomic) double phaseIncrement;
@property (nonatomic) int cyclesToRecognize;
@property (nonatomic) int previousDirection;
@property (readonly, nonatomic) float frequencyResolution;
@end

@implementation SonarModel

- (Novocaine*)audioManager {
    if (!_audioManager) {
        _audioManager = [Novocaine audioManager];
        _frequencyResolution = BUFFER_SIZE / _audioManager.samplingRate;
    }
    return _audioManager;
}

- (CircularBuffer*)buffer {
    if (!_buffer) {
        _buffer = [[CircularBuffer alloc]initWithNumChannels:1 andBufferSize:BUFFER_SIZE];
    }
    return _buffer;
}

- (FFTHelper*)fftHelper {
    if (!_fftHelper) {
        _fftHelper = [[FFTHelper alloc]initWithFFTSize:BUFFER_SIZE];
    }
    return _fftHelper;
}

- (float *)audioData {
    if (!_audioData) {
        _audioData = malloc(sizeof(float)*AUDIO_DATA_SIZE);
    }
    return _audioData;
}

- (float *)fftData {
    if (!_fftData) {
        _fftData = malloc(sizeof(float)*FFT_DATA_SIZE);
    }
    return _fftData;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        self.measuredResult = calloc(2, sizeof(float));
        self.probeQueue = dispatch_queue_create("probeQueue", DISPATCH_QUEUE_SERIAL);
        self.cyclesToRecognize = 0;
        self.previousDirection = 0;
    }
    return self;
}

- (void)dealloc {
    if(_audioManager){
        [_audioManager setInputBlock:nil];
        [_audioManager setOutputBlock:nil];
        [_audioManager teardownAudio];
    }
    if (_audioData) free(self.audioData);
    if (_fftData) free(self.fftData);
    free(self.measuredResult);
}

- (void)start {
    __block SonarModel * __weak  weakSelf = self;
    [self.audioManager setInputBlock:^(float *data, UInt32 numFrames, UInt32 numChannels){
        [weakSelf.buffer addNewFloatData:data withNumSamples:numFrames];
        [weakSelf dopplerWorker:weakSelf.probeQueue];
    }];
    [self playInaudibleTone];
    [self.audioManager play];
}

- (void)pause {
    [self.audioManager pause];
    [self.audioManager setInputBlock:nil];
    [self.audioManager setOutputBlock:nil];
}

- (void)dopplerWorker:(dispatch_queue_t)queue {
    __block SonarModel * __weak  weakSelf = self;
    dispatch_async(queue, ^{
        [weakSelf.buffer fetchFreshData:weakSelf.audioData
                         withNumSamples:BUFFER_SIZE];
        [weakSelf.fftHelper performForwardFFTWithData:weakSelf.audioData
                           andCopydBMagnitudeToBuffer:weakSelf.fftData];
        [weakSelf measureDecibels];
        [weakSelf recognizeUserGesture];
    });
}

- (void)setFrequency:(int)frequencyInkHz {
    double frequency = frequencyInkHz * 1000;
    self.phaseIncrement = 2*M_PI*frequency/self.audioManager.samplingRate;
}

- (void)playInaudibleTone {
    __block double phase = 0.0;
    __block double sineWaveRepeatMax = 2*M_PI;
    __block SonarModel * __weak  weakSelf = self;
    
    [self.audioManager setOutputBlock:^(float *data, UInt32 numFrames, UInt32 numChannels)
     {
         for (int i=0; i < numFrames; ++i)
         {
             data[i] = sin(phase);
             phase += weakSelf.phaseIncrement;
             if (phase >= sineWaveRepeatMax) phase -= sineWaveRepeatMax;
         }
     }];
}

- (void)measureDecibels {
    int peakIndex = [self findPeakIndexFromFFTBasedOnOutputFreqRange:self.fftData];
    self.measuredResult[0] = peakIndex / self.frequencyResolution;
    self.measuredResult[1] = 20*log10f(fabsf(self.fftData[peakIndex]));
}

- (int)findPeakIndexFromFFTBasedOnOutputFreqRange:(float*) fftData {
    int leftBound = MIN_OUTPUT_FREQ * self.frequencyResolution,
        rightBound = MAX_OUTPUT_FREQ * self.frequencyResolution;
    float maxValue;
    unsigned long maxIndex;
    vDSP_maxvi(fftData + leftBound, 1, &maxValue, &maxIndex, rightBound - leftBound);
    return (int)maxIndex+leftBound;
}

- (enum Gesture)recognizeUserGesture {
    if (self.cyclesToRecognize > 0){
        self.cyclesToRecognize--;
        return VOID;
    }

    int peakIndex = [self findPeakIndexFromFFTBasedOnOutputFreqRange:self.fftData];
    float leftBandwidth, rightBandwidth;

    // find the vector mean magnitude for left and right bandwidth
    vDSP_meamgv(&self.fftData[peakIndex - RECOGNIZE_RANGE], 1, &leftBandwidth, RECOGNIZE_RANGE);
    vDSP_meamgv(&self.fftData[peakIndex + RECOGNIZE_RANGE], 1, &rightBandwidth, RECOGNIZE_RANGE);
    
    float difference = leftBandwidth - rightBandwidth;
    int direction = [self signOfFloat:difference];
    enum Gesture result = NONE;
    if (direction != 0) {
        if (direction > 0 && fabsf(difference) > [self calcRecognizeTowardSensitivity]) {
            result = TOWARD;
        } else if (fabsf(difference) > [self calcRecognizeAwaySensitivity]) {
            result = AWAY;
        }
    }
    
    self.previousDirection = direction;
    self.cyclesToRecognize = RECOGNIZE_CYCLES;
    return result;
}

- (int)signOfFloat:(float) num {
    return (num < 0) ? -1 : (num > 0) ? +1 : 0;
}

- (float)calcRecognizeTowardSensitivity {
    return 1 + (self.measuredResult[0] - MIN_OUTPUT_FREQ) / (MAX_OUTPUT_FREQ - MIN_OUTPUT_FREQ) / 10.0;
}

- (float)calcRecognizeAwaySensitivity {
    return 10 - (self.measuredResult[0] - MIN_OUTPUT_FREQ) / (MAX_OUTPUT_FREQ - MIN_OUTPUT_FREQ) / 10.0;
}

@end
