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

+ (UIImage *)lbpImageFromImage:(UIImage *)image {
    Mat src, dst;
    UIImageToMat(image, src);
    
    cvtColor(src, src, COLOR_RGB2GRAY);
    lbp(src, dst);
    
    return MatToUIImage(dst);
}

#pragma mark - private

void lbp(const Mat & src, Mat & dst) {
    dst = Mat::zeros(src.rows - 2, src.cols - 2, CV_8UC1);
    
    for (int i = 1; i < src.rows - 1; ++i) {
        for (int j = 1; j < src.cols - 1; ++j) {
            
            int center = src.at<int>(i, j);
            
            unsigned char code = 0;
            code |= (src.at<int>(i - 1, j - 1) > center) << 7;
            code |= (src.at<int>(i - 1, j) > center) << 6;
            code |= (src.at<int>(i - 1, j + 1) > center) << 5;
            code |= (src.at<int>(i, j + 1) > center) << 4;
            code |= (src.at<int>(i + 1, j + 1) > center) << 3;
            code |= (src.at<int>(i + 1, j) > center) << 2;
            code |= (src.at<int>(i + 1, j - 1) > center) << 1;
            code |= (src.at<int>(i, j - 1) > center) << 0;
            
            dst.at<unsigned char>(i - 1, j - 1) = code;
        }
    }
}

@end





