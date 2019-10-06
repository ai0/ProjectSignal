//
//  ModuleAViewController.m
//  AudioLab
//
//  Created by Jing Su on 9/27/19.
//  Copyright © 2019 Jing Su. All rights reserved.
//

#import "ModuleAViewController.h"
#import "SMUGraphHelper.h"
#import "RadarModel.h"

@interface ModuleAViewController ()
@property (strong, nonatomic) RadarModel *radarModel;
@property (strong, nonatomic) SMUGraphHelper *graphHelper;
@property (nonatomic) bool isLocked;
@property (nonatomic) float* lastTopTwoPeaks;

@property (weak, nonatomic) IBOutlet UILabel *firstFreqLabel;
@property (weak, nonatomic) IBOutlet UILabel *secondFreqLabel;

@property (weak, nonatomic) IBOutlet UILabel *pianoA4Label;
@property (weak, nonatomic) IBOutlet UILabel *pianoB6Label;

@end

@implementation ModuleAViewController

- (RadarModel *)radarModel {
    if(!_radarModel) {
        _radarModel = [[RadarModel alloc] init];
    }
    return _radarModel;
}

- (SMUGraphHelper*)graphHelper {
    if(!_graphHelper){
        _graphHelper = [[SMUGraphHelper alloc]initWithController:self
                                        preferredFramesPerSecond:60
                                                       numGraphs:2
                                                       plotStyle:PlotStyleSeparated
                                               maxPointsPerGraph:BUFFER_SIZE];
    }
    return _graphHelper;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.graphHelper setFullScreenBounds];
    self.isLocked = false;
    self.lastTopTwoPeaks = calloc(2, sizeof(float));
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self.radarModel start];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [self.radarModel pause];
}

- (void)dealloc {
    free(self.lastTopTwoPeaks);
}

- (void)update {
    if (!self.isLocked) {
        // plot the audio data and fft data
        [self.graphHelper setGraphData:self.radarModel.audioData
                        withDataLength:BUFFER_SIZE
                         forGraphIndex:0];
        [self.graphHelper setGraphData:self.radarModel.fftData
                        withDataLength:BUFFER_SIZE/2
                         forGraphIndex:1
                     withNormalization:64.0
                         withZeroValue:-60];
        [self.graphHelper update];
        
        // displays the frequency of the two loudest tones within (±3Hz) accuracy
        float *topTwoPeaks = [self.radarModel findTopTwoPeaks];
        if (fabsf(topTwoPeaks[0] - self.lastTopTwoPeaks[0]) > DISPLAY_ACCURACY) {
            self.firstFreqLabel.text = [NSString stringWithFormat:@"%05.2f", topTwoPeaks[0]];
            self.lastTopTwoPeaks[0] = topTwoPeaks[0];
        }
        if (fabsf(topTwoPeaks[1] - self.lastTopTwoPeaks[1]) > DISPLAY_ACCURACY) {
            self.secondFreqLabel.text = [NSString stringWithFormat:@"%05.2f", topTwoPeaks[1]];
            self.lastTopTwoPeaks[1] = topTwoPeaks[1];
        }
        free(topTwoPeaks);
        
        // recognize two tones (A4, B6) played on a piano
        bool *pianoTonesResult = [self.radarModel detectPianoTones];
        self.pianoA4Label.textColor = pianoTonesResult[0] ? [UIColor colorWithRed:0 green:249 blue:0 alpha:1] : [UIColor grayColor];
        self.pianoB6Label.textColor = pianoTonesResult[1] ? [UIColor colorWithRed:0 green:249 blue:0 alpha:1] : [UIColor grayColor];
        free(pianoTonesResult);
    }
}

- (void)glkView:(GLKView *)view drawInRect:(CGRect)rect {
    [self.graphHelper draw];
}

- (IBAction)lockBtn:(UIButton *)sender {
    if (self.isLocked) {
        [sender setImage:[UIImage imageNamed:@"unlock"] forState:UIControlStateNormal];
    } else {
        [sender setImage:[UIImage imageNamed:@"lock"] forState:UIControlStateNormal];
    }
    self.isLocked = !self.isLocked;
}

@end
