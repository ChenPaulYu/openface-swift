//
//  FaceARDetectIOS.m
//  FaceAR_SDK_IOS_OpenFace_RunFull
//
//  Created by Keegan Ren on 7/5/16.
//  Copyright © 2016 Keegan Ren. All rights reserved.
//

#import "FaceARDetectIOS.h"
#include <iostream>
#include <fstream>
#include <sstream>
#include <vector>
#include "LandmarkCoreIncludes.h"
#include "GazeEstimation.h"

double x_right_center_ref = 0;
double x_left_center_ref = 0;

double y_center_ref = 0;

double x_right_center = 0;
double x_left_center = 0;

double y_center = 0;

LandmarkDetector::FaceModelParameters det_parameters;
// The modules that are being used for tracking
LandmarkDetector::CLNF clnf_model;

@implementation FaceARDetectIOS

-(void)add:(int)number1 secondNumber:(int)number2{
    NSLog(@"answer from objective c file : %i",number1+number2);
}

//bool inits_FaceAR();
-(id) init
{
    self = [super init];
    NSString *location = [[NSBundle mainBundle] resourcePath];
    det_parameters.init();
    det_parameters.model_location = [location UTF8String] + std::string("/model/main_clnf_general.txt");
    det_parameters.face_detector_location = [location UTF8String] + std::string("/classifiers/haarcascade_frontalface_alt.xml");
    
    
    std::cout << "model_location = " << det_parameters.model_location << std::endl;
    std::cout << "face_detector_location = " << det_parameters.face_detector_location << std::endl;
    
    
    
    clnf_model.model_location_clnf = [location UTF8String] + std::string("/model/main_clnf_general.txt");
    clnf_model.face_detector_location_clnf = [location UTF8String] + std::string("/classifiers/haarcascade_frontalface_alt.xml");
    clnf_model.inits();

    return self;
}

// Visualising the results
std::vector<double> visualise_tracking(cv::Mat& captured_image, cv::Mat_<float>& depth_image, const LandmarkDetector::CLNF& face_model, const LandmarkDetector::FaceModelParameters& det_parameters, int frame_count, double fx, double fy, double cx, double cy)
//-(BOOL) visualise_tracking:(cv::Mat)captured_image depth_image_:(cv::Mat)depth_image face_model_:(const LandmarkDetector::CLNF)face_model det_parameters_:(const LandmarkDetector::FaceModelParameters)det_parameters frame_count_:(int)frame_count fx_:(double)fx fy_:(double)fy cx_:(double)cx cy_:(double)cy
{
    
    // Drawing the facial landmarks on the face and the bounding box around it if tracking is successful and initialised
    double detection_certainty = face_model.detection_certainty;
    bool detection_success = face_model.detection_success;
    std::vector<double> movement(5,0);

    
    double visualisation_boundary = 0.1;
    
    // Only draw if the reliability is reasonable, the value is slightly ad-hoc
    if (detection_certainty < visualisation_boundary)
    {
        
//        std::cout << "On "<< face_model.detected_landmarks.size() << std::endl;

        LandmarkDetector::Draw(captured_image, face_model);
    
//        std::cout << face_model.hierarchical_model_names[0] << ": " << face_model.hierarchical_models[0].detected_landmarks.size() << std::endl;
//        std::cout << face_model.hierarchical_model_names[1] << ": " << face_model.hierarchical_models[1].detected_landmarks.size() << std::endl;
//        std::cout << face_model.hierarchical_model_names[2] << ": " << face_model.hierarchical_models[2].detected_landmarks.size() << std::endl;
//        
//        std::cout << face_model.hierarchical_model_names[1] << "x[0]: " << *(r[1].detected_landmarks[0]) << std::endl;
        
        x_left_center = *(face_model.hierarchical_models[1].detected_landmarks[27]) + *(face_model.hierarchical_models[1].detected_landmarks[23]);
        x_right_center = *(face_model.hierarchical_models[2].detected_landmarks[27]) + *(face_model.hierarchical_models[2].detected_landmarks[23]);
        y_center = *(face_model.hierarchical_models[2].detected_landmarks[49]) + *(face_model.hierarchical_models[2].detected_landmarks[53]);
        
        x_left_center_ref = *(face_model.hierarchical_models[1].detected_landmarks[8]) + *(face_model.hierarchical_models[1].detected_landmarks[14]);
        x_right_center_ref = *(face_model.hierarchical_models[2].detected_landmarks[8]) + *(face_model.hierarchical_models[2].detected_landmarks[14]);
        y_center_ref = *(face_model.hierarchical_models[2].detected_landmarks[39]) + *(face_model.hierarchical_models[2].detected_landmarks[45]);
//
//        
        if( x_left_center_ref - x_left_center  > 5 ){
//            std::cout << "左" << std::endl;
            movement.at(0) = 1;
        }

        if( x_right_center - x_right_center_ref  > 5 ){
//            std::cout << "右" << std::endl;
            movement.at(1) = 1;
        }
        
        if( y_center - y_center_ref > 5){
            movement.at(2) = 1;
        }
        
//        if( y_center_ref - y_center > 5 ){
//            std::cout << "下" << std::endl;
//        }
        
//
        
        
//        double vis_certainty = detection_certainty;
//        if (vis_certainty > 1)
//            vis_certainty = 1;
//        if (vis_certainty < -1)
//            vis_certainty = -1;
//
//        vis_certainty = (vis_certainty + 1) / (visualisation_boundary + 1);
//
//
//        // A rough heuristic for box around the face width
//        int thickness = (int)std::ceil(2.0* ((double)captured_image.cols) / 640.0);
//
//        cv::Vec6d pose_estimate_to_draw = LandmarkDetector::GetCorrectedPoseWorld(face_model, fx, fy, cx, cy);
//
//
//        // Draw it in reddish if uncertain, blueish if certain
//        LandmarkDetector::DrawBox(captured_image, pose_estimate_to_draw, cv::Scalar((1 - vis_certainty)*255.0, 0, vis_certainty * 255), thickness, fx, fy, cx, cy);
    }
    
    return movement;
}


//bool run_FaceAR(cv::Mat &captured_image, int frame_count, float fx, float fy, float cx, float cy);
-(std::vector<double>) run_FaceAR:(cv::Mat)captured_image frame__:(int)frame_count fx__:(double)fx fy__:(double)fy cx__:(double)cx cy__:(double)cy
{
    // Reading the images
    cv::Mat_<float> depth_image;
    cv::Mat_<uchar> grayscale_image;
    
    if(captured_image.channels() == 3)
    {
        cv::cvtColor(captured_image, grayscale_image, CV_BGR2GRAY);
    }
    else
    {
        grayscale_image = captured_image.clone();
    }
    
    // The actual facial landmark detection / tracking
    bool detection_success = LandmarkDetector::DetectLandmarksInVideo(grayscale_image, depth_image, clnf_model, det_parameters);
    
//    if(detection_success == true) {
//        std::cout << "facial landmark detection success " << std::endl;
//    }
//
    
    // Visualising the results
    // Drawing the facial landmarks on the face and the bounding box around it if tracking is successful and initialised
    
    double detection_certainty = clnf_model.detection_certainty;
    std::vector<double> move = visualise_tracking(captured_image, depth_image, clnf_model, det_parameters, frame_count, fx, fy, cx, cy);
//    std::cout << "move[0] : "<< move[4] << std::endl;
    //////////////////////////////////////////////////////////////////////
    /// gaze EstimateGaze
    ///
    cv::Point3f gazeDirection0(0, 0, -1);
    cv::Point3f gazeDirection1(0, 0, -1);
    if (det_parameters.track_gaze && detection_success && clnf_model.eye_model)
    {
        GazeEstimate::EstimateGaze(clnf_model, gazeDirection0, fx, fy, cx, cy, true);
        GazeEstimate::EstimateGaze(clnf_model, gazeDirection1, fx, fy, cx, cy, false);
        GazeEstimate::DrawGaze(captured_image, clnf_model, gazeDirection0, gazeDirection1, fx, fy, cx, cy);
    }
    
    cv::Mat eyeLdmks3d_right = clnf_model.hierarchical_models[1].GetShape(fx, fy, cx, cy);
    eyeLdmks3d_right = eyeLdmks3d_right.t();
    cv::Mat_<double> irisLdmks3d = eyeLdmks3d_right.rowRange(0,8);
    cv::Point3f p (mean(irisLdmks3d.col(0))[0], mean(irisLdmks3d.col(1))[0], mean(irisLdmks3d.col(2))[0]);
    cv::Vec3f pvector = p;
    double positionz = pvector[2];
    
    move.push_back(positionz);
    
//    std::cout << pvector[2] << std::endl;
    
    if(detection_success){
        return move;
    }else {
        return std::vector<double>();
    }
    
//    GazeEstimate::
    
}




//bool reset_FaceAR();
-(BOOL) reset_FaceAR
{
    clnf_model.Reset();
    
    return true;
}

//bool clear_FaceAR();
-(BOOL) clear_FaceAR
{
    clnf_model.Reset();
    
    return true;
}




@end
