//
//  OpenCVPPGBridge.m
//  ImageLab
//
//  Created by Jing Su on 11/1/19.
//  Copyright © 2019 Jing Su. All rights reserved.
//

#import "OpenCVPPGBridge.h"
#import "AVFoundation/AVFoundation.h"


using namespace cv;

@interface OpenCVPPGBridge()
@property (nonatomic) cv::Mat image;
@property (nonatomic) NSMutableArray *redArray;
@end

@implementation OpenCVPPGBridge
@dynamic image;

- (int)bufferSize {
    return 120;
}

- (NSMutableArray*)redArray {
    if(!_redArray)
        _redArray = [[NSMutableArray alloc] init];
    return _redArray;
}

- (NSArray*)getRedArray {
    return self.redArray;
}

- (bool)hasEnoughData {
    return self.redArray.count >= self.bufferSize;
}

- (void)processImage{
    cv::Mat frame_gray, image_copy;
    Scalar avgPixelIntensity;
    
    cvtColor(self.image, image_copy, CV_BGRA2BGR);
    avgPixelIntensity = cv::mean( image_copy );

    // threshold set to 128
    if (avgPixelIntensity.val[0] > 128) {
        if (self.redArray.count >= self.bufferSize) {
            [self.redArray removeObjectAtIndex:0];
        }
        [self.redArray addObject:[NSNumber numberWithDouble:avgPixelIntensity.val[0]]];
    }
}

- (int)calcHeartRate {
    // lock in current red array size
    int curRedArraySize = (int)self.redArray.count,
        windowLength = 12,
        windowCount = curRedArraySize - windowLength,
        peaksCount = 0,
        bottomCount = 0;

    // find peaks and bottoms in each window
    for (int i = 0; i < windowCount; i++) {
        NSNumber *minVal = self.redArray[i],
            *maxVal = self.redArray[i];
        for (int j=i+1; j<i+windowLength; j++) {
            if (self.redArray[j] < minVal) minVal = self.redArray[j];
            if (self.redArray[j] > maxVal) maxVal = self.redArray[j];
        }
        if (minVal == self.redArray[i]) bottomCount++;
        if (maxVal == self.redArray[i]) peaksCount++;
    }

    double avgCount = (peaksCount + peaksCount) / 2.0;
    // 30 fps
    return avgCount / (curRedArraySize / 30) * 30;
}

@end
