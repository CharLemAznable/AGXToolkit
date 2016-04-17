//
//  AGXWebViewInternalDelegate.h
//  AGXWidget
//
//  Created by Char Aznable on 16/4/15.
//  Copyright © 2016年 AI-CUC-EC. All rights reserved.
//

#ifndef AGXWidget_AGXWebViewInternalDelegate_h
#define AGXWidget_AGXWebViewInternalDelegate_h

#import <UIKit/UIKit.h>
#import "AGXWebViewJavascriptBridge.h"
#import "AGXWebViewProgressSensor.h"
#import "AGXWebViewExtension.h"
#import "AGXWebView.h"

@interface AGXWebViewInternalDelegate : NSObject <UIWebViewDelegate, AGXEvaluateJavascriptDelegate, AGXWebViewProgressSensorDelegate, AGXWebViewExtensionDelegate>
@property (nonatomic, AGX_WEAK) id<UIWebViewDelegate> delegate;
@property (nonatomic, AGX_WEAK) AGXWebView *webView;

@property (nonatomic, AGX_STRONG) AGXWebViewJavascriptBridge *bridge;
@property (nonatomic, AGX_STRONG) AGXWebViewProgressSensor *progress;
@property (nonatomic, AGX_STRONG) AGXWebViewExtension *extension;
@end

#endif /* AGXWidget_AGXWebViewInternalDelegate_h */
