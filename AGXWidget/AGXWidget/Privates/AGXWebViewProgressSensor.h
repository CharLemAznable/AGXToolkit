//
//  AGXWebViewProgressSensor.h
//  AGXWidget
//
//  Created by Char Aznable on 16/3/10.
//  Copyright © 2016年 AI-CUC-EC. All rights reserved.
//

#ifndef AGXWidget_AGXWebViewProgressSensor_h
#define AGXWidget_AGXWebViewProgressSensor_h

#import <Foundation/Foundation.h>
#import "AGXEvaluateJavascriptDelegate.h"
#import <AGXCore/AGXCore/AGXArc.h>

@protocol AGXWebViewProgressSensorDelegate;

@interface AGXWebViewProgressSensor : NSObject
@property (nonatomic, AGX_WEAK) id<AGXWebViewProgressSensorDelegate> delegate;
@property (nonatomic, readonly) float progress; // 0.0..1.0

- (BOOL)senseCompletedWithRequest:(NSURLRequest *)request;
- (BOOL)shouldResetProgressWithRequest:(NSURLRequest *)request fromURL:(NSURL *)originURL;
- (void)resetProgressWithRequest:(NSURLRequest *)request;
- (void)startProgress;
- (void)senseProgressFromURL:(NSURL *)documentURL withError:(NSError *)error;
@end

@protocol AGXWebViewProgressSensorDelegate <AGXEvaluateJavascriptDelegate>
- (void)webViewProgressSensor:(AGXWebViewProgressSensor *)sensor updateProgress:(float)progress;
@end

#endif /* AGXWidget_AGXWebViewProgressSensor_h */
