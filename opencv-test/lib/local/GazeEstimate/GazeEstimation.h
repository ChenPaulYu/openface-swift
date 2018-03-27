#ifndef __GAZEESTIMATION_h_
#define __GAZEESTIMATION_h_

#include "opencv2/core/core.hpp"
#include "LandmarkCoreIncludes.h"
#include "opencv2/core/core.hpp"
#include "opencv2/imgproc/imgproc.hpp"
#include "opencv2/calib3d/calib3d.hpp"
#include <iostream>

namespace GazeEstimate
{

void EstimateGaze(const LandmarkDetector::CLNF& clnf_model, cv::Point3f& gaze_absolute, float fx, float fy, float cx, float cy, bool left_eye);
void DrawGaze(cv::Mat img, const LandmarkDetector::CLNF& clnf_model, cv::Point3f gazeVecAxisLeft, cv::Point3f gazeVecAxisRight, float fx, float fy, float cx, float cy);
    
}
#endif
