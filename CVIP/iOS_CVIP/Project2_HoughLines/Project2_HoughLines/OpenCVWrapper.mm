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

+ (UIImage *)houghTransformLinesToImage:(UIImage *)image {
    Mat src, binary;
    UIImageToMat(image, src);
    
    Canny(src, binary, 100, 400);
    
    std::vector<Vec4i> lines;
    HoughLinesP(binary, lines, 1, CV_PI / 180, 50, 150, 10);
    
//    std::vector<Vec4i> filteredLines = recognition(lines);
    
    for (size_t i = 0; i < lines.size(); ++i) {
        Vec4i line = lines[i];
        cv::line(src, cv::Point(line[0], line[1]), cv::Point(line[2], line[3]), cv::Scalar(0, 255, 0, 255), 1, CV_AA);
    }
    
    return MatToUIImage(src);
}

# pragma mark - private

std::vector<Vec4i> recognition(std::vector<Vec4i> lines) {
    std::vector<Vec4i> filteredLines;
    
    for (size_t i = 0; i < lines.size(); ++i) {
        for (size_t j = 0; j < lines.size(); ++j) {
            if (i > j) {
                Vec4i line1 = lines[i];
                Vec4i line2 = lines[j];
                
                cv::Point pStart1 = cv::Point(line1[0], line1[1]);
                cv::Point pStart2 = cv::Point(line2[0], line2[1]);
                cv::Point pEnd1 = cv::Point(line1[2], line1[3]);
                cv::Point pEnd2 = cv::Point(line2[2], line2[3]);
                
                double distance1 = sqrt(pow(pStart1.x - pStart2.x, 2) + pow(pStart1.y - pStart2.y, 2));
                double distance2 = sqrt(pow(pEnd1.x - pEnd2.x, 2) + pow(pEnd1.y - pEnd2.y, 2));
                if (distance1 < 10 && distance2 < 10) {
                    filteredLines.push_back(line1);
                    filteredLines.push_back(line2);
                }
            }
        }
    }
    
    return filteredLines;
}

+ (void)myNormalize:(Mat &)mat {
    normalize(mat, mat, 0, 255, NORM_MINMAX);
    convertScaleAbs(mat, mat);
}

@end





