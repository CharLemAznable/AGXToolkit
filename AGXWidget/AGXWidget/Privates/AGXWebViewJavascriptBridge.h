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
#import "AGXWebViewLogLevel.h"
#import "AGXEvaluateJavascriptDelegate.h"

@protocol AGXWebViewJavascriptBridgeHandler <JSExport>
- (id)callHandler:(NSString *)handlerName withData:(id)data inScope:(NSString *)scope;
- (void)onErrorWithMessage:(NSString *)message atStack:(NSString *)stack;
- (void)onLogLevel:(AGXWebViewLogLevel)level withData:(id)data atStack:(NSString *)stack;
@end

@interface AGXWebViewJavascriptBridge : NSObject <AGXWebViewJavascriptBridgeHandler>
@property (nonatomic, AGX_WEAK) id<AGXEvaluateJavascriptDelegate> delegate;

- (void)injectBridgeWrapperJavascript;

// called in sub Thread
- (void)registerHandlerName:(NSString *)handlerName block:(id (^)(id data))block;
- (void)registerHandlerName:(NSString *)handlerName target:(id)target action:(SEL)action;
- (void)registerHandlerName:(NSString *)handlerName block:(id (^)(id data))block scope:(NSString *)scope;
- (void)registerHandlerName:(NSString *)handlerName target:(id)target action:(SEL)action scope:(NSString *)scope;

// called in main Thread
- (void)registerErrorHandlerBlock:(void (^)(NSString *message, NSArray *stack))block;
- (void)registerErrorHandlerTarget:(id)target action:(SEL)action;

@property (nonatomic, assign) AGXWebViewLogLevel javascriptLogLevel;
// called in main Thread
- (void)registerLogHandlerBlock:(void (^)(AGXWebViewLogLevel level, id data, NSArray *stack))block;
- (void)registerLogHandlerTarget:(id)target action:(SEL)action;
@end

#endif /* AGXWidget_AGXWebViewJavascriptBridge_h */
