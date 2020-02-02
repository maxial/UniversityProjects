//
//  OpenCVWrapper.h
//  Lab2_BrightnessTransformations
//
//  Created by Maxim Aliev on 05/03/17.
//  Copyright © 2017 Maxial. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

@interface OpenCVWrapper : NSObject

+ (UIImage *)grayscaleFrom:(UIImage *)image;

+ (UIImage *)erodeImage:(UIImage *)image withRingOuterRadius:(double)outerR andInnerRadius:(double)innerR;
+ (UIImage *)dilateImage:(UIImage *)image withRadius:(double)radius;
+ (UIImage *)addImage:(UIImage *)image1 toImage:(UIImage *)image2;
+ (UIImage *)ringFromImage:(UIImage *)image withGearBodyRadius:(double)gearBodyR samplingRingSpacerRadius:(double)samplingRingSpacerR andSamplingRingWidthRadius:(double)samplingRingWidthR;
+ (UIImage *)intersectionImage:(UIImage *)image1 withImage:(UIImage *)image2;
+ (UIImage *)detectDefects:(UIImage *)image withDefectCueRadius:(double)defectCueR andMaskImage:(UIImage *)maskImage;

@end
