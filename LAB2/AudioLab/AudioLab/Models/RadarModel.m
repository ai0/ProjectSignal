//
//  RadarModel.m
//  AudioLab
//
//  Created by Jing Su on 9/28/19.
//  Copyright © 2019 Jing Su. All rights reserved.
//

#import "RadarModel.h"
#import "CircularBuffer.h"
#import "FFTHelper.h"
#import "Novocaine.h"

@interface RadarModel ()
@property (strong, nonatomic) Novocaine *audioManager;
@property (strong, nonatomic) CircularBuffer *buffer;
@property (strong, nonatomic) FFTHelper *fftHelper;
@property (strong, nonatomic) NSArray *fundamentalFrequencies;
@property (nonatomic) float *audioData;
@property (nonatomic) float *fftData;
@property (nonatomic) dispatch_queue_t antennaQueue;
@property (readonly, nonatomic) float frequencyResolution;
@end

@implementation RadarModel

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
        self.antennaQueue = dispatch_queue_create("antennaQueue", DISPATCH_QUEUE_SERIAL);
    }
    return self;
}

- (void)dealloc {
    if(_audioManager){
        [_audioManager setInputBlock:nil];
    }
    if (_audioData) free(self.audioData);
    if (_fftData) free(self.fftData);
}

- (void)start {
    __block RadarModel * __weak  weakSelf = self;
    [self.audioManager setInputBlock:^(float *data, UInt32 numFrames, UInt32 numChannels){
        [weakSelf.buffer addNewFloatData:data withNumSamples:numFrames];
        [weakSelf fftWorker:weakSelf.antennaQueue];
    }];
    [self.audioManager play];
}

- (void)pause {
    [self.audioManager pause];
    [self.audioManager setInputBlock:nil];
}

- (void)fftWorker:(dispatch_queue_t)queue {
    __block RadarModel * __weak  weakSelf = self;
    dispatch_async(queue, ^{
        [weakSelf.buffer fetchFreshData:weakSelf.audioData
                         withNumSamples:BUFFER_SIZE];
        [weakSelf detectPianoTones];
        [weakSelf.fftHelper performForwardFFTWithData:weakSelf.audioData
                           andCopydBMagnitudeToBuffer:weakSelf.fftData];
    });
}

- (float*)findTopTwoPeaks {
    int windowCount = FFT_DATA_SIZE - WINDOW_LENGTH;
    float *peakOfEachWindow = malloc(sizeof(float)*windowCount);
    
    vDSP_vswmax(self.fftData, 1, peakOfEachWindow, 1, windowCount, WINDOW_LENGTH);

    // find the top two indices of peak data
    int topTwoPeakIndices[] = {0, 0};
    for (int i=0; i<windowCount; i++) {
        if (peakOfEachWindow[i] == self.fftData[i]) {
            if (self.fftData[i] > self.fftData[topTwoPeakIndices[0]]) {
                topTwoPeakIndices[1] = topTwoPeakIndices[0];
                topTwoPeakIndices[0] = i;
            } else if (self.fftData[i] > self.fftData[topTwoPeakIndices[1]]) {
                topTwoPeakIndices[1] = i;
            }
        }
    }
    
    // validate and convert to frequency
    float *topTwoPeaks = malloc(sizeof(float)*2);
    topTwoPeaks[0] = peakOfEachWindow[topTwoPeakIndices[0]] == self.fftData[topTwoPeakIndices[0]] ?
                        [self getFrequencyFromIndex:topTwoPeakIndices[0] usingData:self.fftData]
                        : 0;
    topTwoPeaks[1] = peakOfEachWindow[topTwoPeakIndices[1]] == self.fftData[topTwoPeakIndices[1]] ?
                        [self getFrequencyFromIndex:topTwoPeakIndices[1] usingData:self.fftData]
                        : 0;

    free(peakOfEachWindow);
    return topTwoPeaks;
}

- (float)getFrequencyFromIndex:(NSUInteger)index
                     usingData:(float*)data
{
    if (index == 0) return 0;
    // Quadratic approximation formula from page 15 of MSLC_5_fft_motion.pdf:
    // f_{peak} \approx f_2 + \frac{m_3-m_1}{m_3-2m_2+m_1} \frac{\Delta f}{2}
    float f2 = index / self.frequencyResolution,
        m1 = data[index - 1],
        m2 = data[index],
        m3 = data[index + 1];
    return f2 + ((m3 - m1) / (m3 - 2.0 * m2 + m1)) * self.frequencyResolution / 2.0;
}

- (bool*)detectPianoTones {
    // A4: 440Hz, B6: 1975.533Hz
    // Frequency data from https://en.wikipedia.org/wiki/A_(musical_note)
    //                 and https://en.wikipedia.org/wiki/B_(musical_note)
    bool *pianoTonesResult = malloc(sizeof(bool)*2);
    // A4
    pianoTonesResult[0] = [self goertzelToneDetection:440 usingData:self.audioData withSamplesPerFrame:AUDIO_DATA_SIZE andSampleRate:self.audioManager.samplingRate];
    // B6
    pianoTonesResult[1] = [self goertzelToneDetection:1975.533 usingData:self.audioData withSamplesPerFrame:AUDIO_DATA_SIZE andSampleRate:self.audioManager.samplingRate];
    return pianoTonesResult;
}

// Using the Goertzel algorithm to perform tone detection
// Reference: https://courses.cs.washington.edu/courses/cse466/12au/calendar/Goertzel-EETimes.pdf
- (bool)goertzelToneDetection:(float)targetFrequency
                    usingData:(float*)data
          withSamplesPerFrame:(float)numSamples
                andSampleRate:(float)rate
{
    float k = floorf(0.5 + (numSamples * targetFrequency) / rate),
        w = (2.0 * M_PI / numSamples) * k,
        c = cosf(w),
        s = sinf(w),
        coeff = 2.0 * c;
    
    float q0 = 0,
        q1 = 0,
        q2 = 0;
    for(int i=0; i<numSamples; i++) {
        q0 = coeff * q1 - q2 + data[i];
        q2 = q1;
        q1 = q0;
    }
    
    // basic Goertzel
    float real = q1 - q2 * c,
        imaginary = q2 * s,
        magSquared = real * real + imaginary * imaginary;
    
    // optimized Goertzel
    // float magSquared = q1 * q1 + q2 * q2 - q1 * q2 * coeff;
    
    // threshold set to 1500
    return magSquared > 1500;
}

@end
