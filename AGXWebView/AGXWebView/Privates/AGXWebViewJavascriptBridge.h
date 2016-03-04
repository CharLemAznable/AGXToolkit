//
//  AGXWebViewJavascriptBridge.h
//  AGXWebView
//
//  Created by Char Aznable on 16/3/4.
//  Copyright © 2016年 AI-CUC-EC. All rights reserved.
//

#ifndef AGXWebView_AGXWebViewJavascriptBridge_h
#define AGXWebView_AGXWebViewJavascriptBridge_h

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "AGXWebViewJavascriptBridgeBase.h"

@interface AGXWebViewJavascriptBridge : NSObject<UIWebViewDelegate, AGXWebViewJavascriptBridgeBaseDelegate>
@property (nonatomic, assign) id<UIWebViewDelegate> delegate;
@property (nonatomic, assign) UIWebView *webView;

+ (void)enableLogging;
+ (void)setLogMaxLength:(int)length;

- (void)registerHandler:(NSString *)handlerName handler:(AGXBridgeHandler)handler;
- (void)callHandler:(NSString *)handlerName;
- (void)callHandler:(NSString *)handlerName data:(id)data;
- (void)callHandler:(NSString *)handlerName data:(id)data responseCallback:(AGXBridgeResponseCallback)responseCallback;
@end

#endif /* AGXWebView_AGXWebViewJavascriptBridge_h */
