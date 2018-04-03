//
//  Use this file to import your target's public headers that you would like to expose to Swift.
//

// UseOpenCVInSwiftDemo-Bridging-Header.h
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
//#import "AppDelegate.h"
@interface ImageConverter : NSObject

+(UIImage *)getBinaryImage:(UIImage *)image;
+(UIImage *)processImage:(UIImage *)images frame__:(int)frame_count;

+(double)getdistance;
+(bool *)getdirection;
+(bool)resetCapture;


@end







