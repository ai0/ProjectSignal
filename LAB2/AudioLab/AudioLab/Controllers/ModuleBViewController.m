//
//  ModuleBViewController.m
//  AudioLab
//
//  Created by Jing Su on 9/27/19.
//  Copyright © 2019 Jing Su. All rights reserved.
//

#import "ModuleBViewController.h"
#import "SMUGraphHelper.h"
#import "SonarModel.h"

@interface ModuleBViewController ()
@property (strong, nonatomic) SonarModel *sonarModel;
@property (strong, nonatomic) SMUGraphHelper *graphHelper;
@property (weak, nonatomic) IBOutlet UILabel *inputFrequencyLabel;
@property (weak, nonatomic) IBOutlet UILabel *inputDecibelsLabel;
@property (weak, nonatomic) IBOutlet UILabel *outputFrquencyLabel;
@property (weak, nonatomic) IBOutlet UILabel *gestureLabel;
@property (weak, nonatomic) IBOutlet UISlider *outputFrequencySlider;
@end

@implementation ModuleBViewController

- (SonarModel *)sonarModel {
    if(!_sonarModel) {
        _sonarModel = [[SonarModel alloc] init];
    }
    return _sonarModel;
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
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self.sonarModel setFrequency:self.outputFrequencySlider.value];
    [self.sonarModel start];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [self.sonarModel pause];
}

- (IBAction)frequencySliderIsChanged:(UISlider *)sender {
    [self.sonarModel setFrequency:sender.value];
    self.outputFrquencyLabel.text = [NSString stringWithFormat:@"Output: %.2fkHz", sender.value];
}

- (void)update {
    // plot the audio data and fft data
    [self.graphHelper setGraphData:self.sonarModel.audioData
                    withDataLength:BUFFER_SIZE
                     forGraphIndex:0];
    [self.graphHelper setGraphData:self.sonarModel.fftData
                    withDataLength:BUFFER_SIZE/2
                     forGraphIndex:1
                 withNormalization:64.0
                     withZeroValue:-60];
    [self.graphHelper update];
    
    self.inputFrequencyLabel.text = [NSString stringWithFormat:@"%.f Hz", self.sonarModel.measuredResult[0]];
    self.inputDecibelsLabel.text = [NSString stringWithFormat:@"%.2f dB", self.sonarModel.measuredResult[1]];
    
    enum Gesture gesture = [self.sonarModel recognizeUserGesture];
    // I want to use the gestures as a form of control in the app here,
    // but the screen space limited me to add additional controllers.
    // So only changed the label color here.
    switch (gesture) {
        case TOWARD:
            self.gestureLabel.text = @"TOWARD";
            self.gestureLabel.textColor = [UIColor greenColor];
            break;
        case AWAY:
            self.gestureLabel.text = @"AWAY";
            self.gestureLabel.textColor = [UIColor redColor];
            break;
        case NONE:
            self.gestureLabel.text = @"NONE";
            self.gestureLabel.textColor = [UIColor whiteColor];
            break;
        case VOID:
          default:
            break;
    }
}

- (void)glkView:(GLKView *)view drawInRect:(CGRect)rect {
    [self.graphHelper draw];
}

@end
