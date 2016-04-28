//
//  AGXWebViewJavascriptBridge.h
//  AGXWidget
//
//  Created by Char Aznable on 16/3/4.
//  Copyright © 2016年 AI-CUC-EC. All rights reserved.
//

#ifndef AGXWidget_AGXWebViewJavascriptBridge_h
#define AGXWidget_AGXWebViewJavascriptBridge_h

#import <UIKit/UIKit.h>
#import <JavaScriptCore/JavaScriptCore.h>
#import <AGXCore/AGXCore/AGXArc.h>
#import "AGXEvaluateJavascriptDelegate.h"

typedef id (^AGXBridgeHandler)(id data);

@protocol AGXWebViewJavascriptBridgeHandler <JSExport>
- (id)callHandler:(NSString *)handlerName withData:(id)data;
@end

@interface AGXWebViewJavascriptBridge : NSObject <AGXWebViewJavascriptBridgeHandler>
@property (nonatomic, AGX_WEAK) id<AGXEvaluateJavascriptDelegate> delegate;

- (void)injectBridgeWrapperJavascript;
- (void)registerHandler:(NSString *)handlerName handler:(AGXBridgeHandler)handler;
- (void)registerHandler:(NSString *)handlerName handler:(id)handler selector:(SEL)selector;
@end

#endif /* AGXWidget_AGXWebViewJavascriptBridge_h */
