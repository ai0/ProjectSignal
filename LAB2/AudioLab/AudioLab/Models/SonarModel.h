//
//  SonarModel.h
//  AudioLab
//
//  Created by Jing Su on 9/28/19.
//  Copyright © 2019 Jing Su. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Constants.h"

enum Gesture {
    TOWARD,
    AWAY,
    NONE,
    VOID
};

@interface SonarModel : NSObject
@property (readonly) float *audioData;
@property (readonly) float *fftData;
@property (readonly) float *measuredResult;

- (void)start;
- (void)pause;
- (void)setFrequency:(int)frequency;
- (enum Gesture)recognizeUserGesture;
@end
