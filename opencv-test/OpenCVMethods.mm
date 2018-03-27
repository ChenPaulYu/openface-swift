//
//  OpenCVMethods.m
//  opencv-test
//
//  Created by Bernie on 2018/3/22.
//  Copyright © 2018年 PaulChen. All rights reserved.
//

// OpenCVMethods.mm
#import <opencv2/opencv.hpp>
#import <opencv2/imgcodecs/ios.h>
#include "FaceARDetectIOS.h"
#import "opencv-test-Bridging-Header.h"
#include <iostream>





double facedistanceZ = 0;

bool moveArray[5];





@implementation ImageConverter : NSObject

+(UIImage *)getBinaryImage:(UIImage *)image {
    cv::Mat mat;
    UIImageToMat(image, mat);
    
    cv::Mat gray;
    cv::cvtColor(mat, gray, CV_RGB2GRAY);
    
    cv::Mat bin;
    cv::threshold(gray, bin, 0, 255, cv::THRESH_BINARY | cv::THRESH_OTSU);
    
    UIImage *binImg = MatToUIImage(mat);
    return binImg;
}

+(UIImage *)processImage:(UIImage *) images frame__:(int)frame_count
{
    cv::Mat image;
    UIImageToMat(images, image);
    cv::Mat targetImage(image.cols,image.rows,CV_8UC3);
    cv::cvtColor(image, targetImage, cv::COLOR_BGRA2BGR);
    if(targetImage.empty()){
        std::cout << "targetImage empty" << std::endl;
    }
    else
    {
        float fx, fy, cx, cy;
        cx = 1.0*targetImage.cols / 2.0;
        cy = 1.0*targetImage.rows / 2.0;
        
        fx = 500 * (targetImage.cols / 640.0);
        fy = 500 * (targetImage.rows / 480.0);
        
        fx = (fx + fy) / 2.0;
        fy = fx;
        
        std::vector<double> movement;
        
        movement = [[FaceARDetectIOS alloc] run_FaceAR:targetImage frame__:frame_count fx__:fx fy__:fy cx__:cx cy__:cy];
        if(!movement.empty()){
//            std::cout << movement[5] << std::endl;
            facedistanceZ = movement[5];
            for(int i =0 ;i<=4; i++){
                moveArray[i] = movement[i];
            }
            
        }
    }
    cv::cvtColor(targetImage, image, cv::COLOR_BGRA2RGB);
    
    UIImage *binImg = MatToUIImage(targetImage);
    
    return binImg;
}

+(double)getdistance{
    return facedistanceZ;
}

+(bool *)getdirection{
    return moveArray;
}

@end


