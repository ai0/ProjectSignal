//
//  OpenCVPPGBridge.h
//  ImageLab
//
//  Created by Jing Su on 11/1/19.
//  Copyright © 2019 Jing Su. All rights reserved.
//

#import "OpenCVBridge.hh"

@interface OpenCVPPGBridge : OpenCVBridge

- (bool)hasEnoughData;
- (NSArray*)getRedArray;
- (int)calcHeartRate;

@end
