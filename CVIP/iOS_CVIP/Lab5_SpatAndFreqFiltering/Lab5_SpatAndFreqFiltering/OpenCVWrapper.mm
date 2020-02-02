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

+ (UIImage *)spectrumImageFromImage:(UIImage *)image {
    Mat src = [self spectrumFromImage:image];
    [self myNormalize:src];
    return MatToUIImage(src);
}

+ (UIImage *)spectrumImageFromGaussianFilterWithSize:(CGSize)size cutoffInPixels:(double)cutoffInPixels type:(FilterType)type {
    Mat gaussianFilter = [self gaussianFilterWithSize:size cutoffInPixels:cutoffInPixels type:type];
    [self myNormalize:gaussianFilter];
    return MatToUIImage(gaussianFilter);
}

+ (UIImage *)applyFilterImage:(UIImage *)filterImage toImage:(UIImage *)image {
    Mat src, filter;
    UIImageToMat(image, src);
    UIImageToMat(filterImage, filter);
    
    src.convertTo(src, CV_32F);
    filter.convertTo(filter, CV_32F);
    // Ширина и высота - четные
//    NSLog(@"%d | %d", src.rows, src.cols);
//    NSLog(@"%d | %d", filter.rows, filter.cols);
    normalize(src, src, 0, 1, NORM_MINMAX);
    normalize(filter, filter, 0, 1, NORM_MINMAX);
    
    src = [self computeDFT:src];
    [self shift:src];
    
    Mat kernel = [self getComplexFrom:filter];
    mulSpectrums(src, kernel, src, DFT_COMPLEX_OUTPUT);
    
    idft(src, src, DFT_COMPLEX_OUTPUT);
    
    src = [self getMagnitudeFrom:src withLogScale:NO];
    
    [self myNormalize:src];
    return MatToUIImage(src);
}

#pragma mark - private

+ (Mat)spectrumFromImage:(UIImage *)image {
    Mat src;
    UIImageToMat(image, src);
    Mat mag = [self getMagnitudeFrom:[self computeDFT:src] withLogScale:YES];
    [self shift:mag];
    [self myNormalize:mag];
    return mag;
}

+ (Mat)getMagnitudeFrom:(Mat)complex withLogScale:(BOOL)logScale {
    Mat mag;
    Mat planes[] = { Mat::zeros(complex.size(), CV_32F), Mat::zeros(complex.size(), CV_32F) };
    split(complex, planes);
    magnitude(planes[0], planes[1], mag);
    if (logScale) {
        mag += Scalar::all(1);
        log(mag, mag);
    }
    return mag;
}

+ (Mat)computeDFT:(Mat)src {
    Mat padded;
    int m = getOptimalDFTSize(src.rows);
    int n = getOptimalDFTSize(src.cols);
    copyMakeBorder(src, padded, 0, m - src.rows, 0, n - src.cols, BORDER_CONSTANT, Scalar::all(0));
    Mat planes[] = { Mat_<float>(src), Mat::zeros(src.size(), CV_32F) };
    Mat complex;
    merge(planes, 2, complex);
    dft(complex, complex, DFT_COMPLEX_OUTPUT);
    return complex;
}

+ (void)shift:(Mat &)mat {
    mat = mat(cv::Rect(0, 0, mat.cols & -2, mat.rows & -2));
    
    int cx = mat.cols / 2, cy = mat.rows / 2;
    
    Mat q0(mat, cv::Rect(0, 0, cx, cy));
    Mat q1(mat, cv::Rect(cx, 0, cx, cy));
    Mat q2(mat, cv::Rect(0, cy, cx, cy));
    Mat q3(mat, cv::Rect(cx, cy, cx, cy));
    
    Mat tmp;
    q0.copyTo(tmp);
    q3.copyTo(q0);
    tmp.copyTo(q3);
    
    q1.copyTo(tmp);
    q2.copyTo(q1);
    tmp.copyTo(q2);
}

+ (void)myNormalize:(Mat &)mat {
    normalize(mat, mat, 0, 255, NORM_MINMAX);
    convertScaleAbs(mat, mat);
}

double gaussianCoeff(double i, double j, double d0) {
    double d = cv::sqrt(i * i + j * j);
    return cv::exp((-d * d) / (2 * d0 * d0));
}

+ (Mat)gaussianFilterWithSize:(CGSize)size cutoffInPixels:(double)cutoffInPixels type:(FilterType)type {
    Mat gaussianFilter(cv::Size(size.width, size.height), CV_32F);
    
    cv::Point center(size.width / 2, size.height / 2);
    for(int i = 0; i < (int)gaussianFilter.rows; i++) {
        for(int j = 0; j < (int)gaussianFilter.cols; j++) {
            gaussianFilter.at<float>(i, j) = type == LowFreq ? gaussianCoeff(i - center.y, j - center.x, cutoffInPixels) : 1 - gaussianCoeff(i - center.y, j - center.x, cutoffInPixels);
        }
    }
    return gaussianFilter;
}

+ (Mat)getComplexFrom:(Mat)mat {
    Mat planes[] = { Mat::zeros(mat.size(), CV_32F), Mat::zeros(mat.size(), CV_32F) };
    Mat complex;
    planes[0] = mat;
    planes[1] = mat;
    merge(planes, 2, complex);
    return complex;
}

@end





