//
//  RadarModel.h
//  AudioLab
//
//  Created by Jing Su on 9/28/19.
//  Copyright © 2019 Jing Su. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Constants.h"

@interface RadarModel : NSObject
@property (readonly) float *audioData;
@property (readonly) float *fftData;

- (float *)findTopTwoPeaks;
- (void)start;
- (void)pause;
- (bool*)detectPianoTones;
@end
