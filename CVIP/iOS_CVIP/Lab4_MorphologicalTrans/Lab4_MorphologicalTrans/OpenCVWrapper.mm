//
//  OpenCVWrapper.mm
//  Lab2_BrightnessTransformations
//
//  Created by Maxim Aliev on 05/03/17.
//  Copyright © 2017 Maxial. All rights reserved.
//

#include "OpenCVWrapper.h"

using namespace cv;

@implementation OpenCVWrapper

+ (Mat)genRingWithOuterRadius:(double)outerR andInnerRadius:(double)innerR {
    double outerD = outerR * 2, innerD = innerR * 2, thickness = outerR - innerR;
    
    Mat ellipse = getStructuringElement(MORPH_ELLIPSE, cv::Size(outerD, outerD));
    Mat smallEllipse = getStructuringElement(MORPH_ELLIPSE, cv::Size(innerD, innerD));
    
    Mat ring = Mat::zeros(outerD, outerD, CV_THRESH_BINARY);
    
    smallEllipse.copyTo(ring(cv::Rect(thickness, thickness, smallEllipse.cols, smallEllipse.rows)));
    subtract(ellipse, ring, ring);
    
    return ring;
}

+ (UIImage *)grayscaleFrom:(UIImage *)image {
    Mat src, dst;
    UIImageToMat(image, src);
    print(src);
    cvtColor(src, dst, COLOR_RGB2GRAY);
    return MatToUIImage(dst);
}

+ (UIImage *)erodeImage:(UIImage *)image withRingOuterRadius:(double)outerR andInnerRadius:(double)innerR {
    Mat src;
    UIImageToMat(image, src);
    Mat holeRing = [self genRingWithOuterRadius:outerR andInnerRadius:innerR];
    erode(src, src, holeRing);
    return MatToUIImage(src);
}

+ (UIImage *)dilateImage:(UIImage *)image withRadius:(double)radius {
    Mat src;
    UIImageToMat(image, src);
    Mat holeMask = getStructuringElement(MORPH_ELLIPSE, cv::Size(radius * 2, radius * 2));
    dilate(src, src, holeMask);
    return MatToUIImage(src);
}

+ (UIImage *)addImage:(UIImage *)image1 toImage:(UIImage *)image2 {
    Mat src1, src2, dst;
    UIImageToMat(image1, src1);
    UIImageToMat(image2, src2);
    src1 += src2;
    return MatToUIImage(src1);
}

+ (UIImage *)ringFromImage:(UIImage *)image withGearBodyRadius:(double)gearBodyR samplingRingSpacerRadius:(double)samplingRingSpacerR andSamplingRingWidthRadius:(double)samplingRingWidthR {
    Mat src, inter;
    UIImageToMat(image, src);
    
    Mat gearBody = getStructuringElement(MORPH_ELLIPSE, cv::Size(gearBodyR * 2, gearBodyR * 2));
    Mat samplingRingSpacer = getStructuringElement(MORPH_ELLIPSE, cv::Size(samplingRingSpacerR * 2, samplingRingSpacerR * 2));
    Mat samplingRingWidth = getStructuringElement(MORPH_ELLIPSE, cv::Size(samplingRingWidthR * 2, samplingRingWidthR * 2));
    
    morphologyEx(src, src, MORPH_OPEN, gearBody);
    dilate(src, inter, samplingRingSpacer);
    dilate(inter, src, samplingRingWidth);
    src -= inter;
    return MatToUIImage(src);
}

+ (UIImage *)intersectionImage:(UIImage *)image1 withImage:(UIImage *)image2 {
    Mat src1, src2;
    UIImageToMat(image1, src1);
    UIImageToMat(image2, src2);
    bitwise_and(src1, src2, src1);
    return MatToUIImage(src1);
}

+ (UIImage *)detectDefects:(UIImage *)image withDefectCueRadius:(double)defectCueR andMaskImage:(UIImage *)maskImage {
    Mat src, maskSrc, inter;
    UIImageToMat(image, src);
    UIImageToMat(maskImage, maskSrc);
    
    inter = maskSrc - src;
    Mat kernel = getStructuringElement(MORPH_ELLIPSE, cv::Size(defectCueR * 2, defectCueR * 2));
    dilate(inter, inter, kernel);
    bitwise_or(inter, src, src);
    
    return MatToUIImage(src);
}

@end





