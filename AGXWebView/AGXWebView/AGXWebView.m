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
    AGXWebViewJavascriptBridge *_bridge;
}

- (void)agxInitial {
    [super agxInitial];
    _bridge = [[AGXWebViewJavascriptBridge alloc] init];
    dispatch_async(dispatch_get_main_queue(), ^{ _bridge.webView = self; });
    
    AutoRegisterBridgeHandler(self, [AGXWebView class],
                              ^(id handler, SEL selector, NSString *handlerName) {
                                  [handler registerHandlerName:handlerName withSelector:selector];
                              });
}

- (void)dealloc {
    AGX_RELEASE(_bridge);
    AGX_SUPER_DEALLOC;
}

- (void)registerHandlerName:(NSString *)handlerName withSelector:(SEL)selector {
    __AGX_BLOCK AGXWebView* SELF = self;
    [_bridge registerHandler:handlerName handler:^(id data, AGXBridgeResponseCallback responseCallback) {
        NSString *signature = HandlerMethodSignature(SELF, selector);
        AGX_PerformSelector
        (
         if ([signature hasPrefix:@"v"]) {
             [SELF performSelector:selector withObject:data]; responseCallback(nil);
         } else if ([signature hasPrefix:@"@"]) {
             responseCallback([SELF performSelector:selector withObject:data]);
         } else responseCallback(@((NSInteger)[SELF performSelector:selector withObject:data]));
        )
    }];
}

- (void)registerTriggerName:(NSString *)triggerName withSelector:(SEL)selector {
#warning TODO
}

#pragma mark - UIWebView handler

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
