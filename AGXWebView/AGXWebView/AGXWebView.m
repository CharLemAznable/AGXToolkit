//
//  AGXWebView.m
//  AGXWebView
//
//  Created by Char Aznable on 16/3/4.
//  Copyright © 2016年 AI-CUC-EC. All rights reserved.
//

#import "AGXWebView.h"
#import "AGXWebViewJavascriptBridge.h"
#import "AGXWebViewJavascriptBridgeAuto.h"
#import <AGXCore/AGXCore/NSObject+AGXCore.h>
#import <AGXCore/AGXCore/UIView+AGXCore.h>

@implementation AGXWebView {
    long _uniqueId;
    AGXWebViewJavascriptBridge *_bridge;
}

- (void)agxInitial {
    [super agxInitial];
    _uniqueId = 0;
    _bridge = [[AGXWebViewJavascriptBridge alloc] init];
    dispatch_async(dispatch_get_main_queue(), ^{ _bridge.webView = self; });
    
    AutoRegisterBridgeHandler(self, [AGXWebView class],
                              ^(id handler, SEL selector, NSString *handlerName) {
                                  [handler registerHandlerName:handlerName handler:handler selector:selector];
                              });
}

- (void)dealloc {
    AGX_RELEASE(_bridge);
    AGX_SUPER_DEALLOC;
}

- (void)registerHandlerName:(NSString *)handlerName handler:(id)handler selector:(SEL)selector; {
    [_bridge registerHandler:handlerName handler:handler selector:selector];
}

- (SEL)registerTriggerWithBlock:(AGXBridgeTrigger)triggerBlock {
    SEL trigger = NSSelectorFromString([NSString stringWithFormat:@"trigger_%ld:", ++_uniqueId]);
    [[self class] addInstanceMethodWithSelector:trigger andBlock:triggerBlock andTypeEncoding:"v@:@"];
    return trigger;
}

- (SEL)registerTriggerWithJavascript:(NSString *)javascript {
    return [self registerTriggerWithBlock:^(id SELF, id sender)
            { [SELF stringByEvaluatingJavaScriptFromString:javascript]; }];
}

#pragma mark - UIWebView bridge handler

- (void)bridge_reload {
    [self reload];
}

- (void)bridge_stopLoading {
    [self stopLoading];
}

- (void)bridge_goBack {
    [self goBack];
}

- (void)bridge_goForward {
    [self goForward];
}

- (BOOL)bridge_canGoBack {
    return [self canGoBack];
}

- (BOOL)bridge_canGoForward {
    return [self canGoForward];
}

- (BOOL)bridge_isLoading {
    return [self isLoading];
}

#pragma mark - swizzle

- (void)AGXWebView_setDelegate:(id<UIWebViewDelegate>)delegate {
    if (!delegate || delegate == _bridge)  {
        [self AGXWebView_setDelegate:delegate];
        return;
    }
    _bridge.delegate = delegate;
}

+ (void)load {
    static dispatch_once_t once_t;
    dispatch_once(&once_t, ^{
        [self swizzleInstanceOriSelector:@selector(setDelegate:)
                         withNewSelector:@selector(AGXWebView_setDelegate:)];
    });
}

@end
