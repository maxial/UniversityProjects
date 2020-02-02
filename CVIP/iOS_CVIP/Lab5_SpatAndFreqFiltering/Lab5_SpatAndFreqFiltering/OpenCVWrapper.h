//
//  OpenCVWrapper.h
//  Lab2_BrightnessTransformations
//
//  Created by Maxim Aliev on 05/03/17.
//  Copyright © 2017 Maxial. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

typedef enum : NSInteger {
    HighFreq,
    LowFreq
} FilterType;

@interface OpenCVWrapper : NSObject

+ (UIImage *)spectrumImageFromImage:(UIImage *)image;
+ (UIImage *)spectrumImageFromGaussianFilterWithSize:(CGSize)size cutoffInPixels:(double)cutoffInPixels type:(FilterType)type;
+ (UIImage *)applyFilterImage:(UIImage *)filterImage toImage:(UIImage *)image;

@end
