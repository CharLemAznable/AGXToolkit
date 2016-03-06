//
//  AGXWebView.m
//  AGXWebView
//
//  Created by Char Aznable on 16/3/4.
//  Copyright © 2016年 AI-CUC-EC. All rights reserved.
//

#import "AGXWebView.h"
#import "AGXWebViewJavascriptBridge.h"
#import <AGXCore/AGXCore/AGXObjC.h>
#import <AGXCore/AGXCore/NSObject+AGXCore.h>
#import <AGXCore/AGXCore/UIView+AGXCore.h>
#import <AGXRuntime/AGXRuntime.h>

@implementation AGXWebView {
    AGXWebViewJavascriptBridge *_bridge;
}

- (void)agxInitial {
    [super agxInitial];
    _bridge = [[AGXWebViewJavascriptBridge alloc] init];
    dispatch_async(dispatch_get_main_queue(), ^{ _bridge.webView = self; });
}

- (void)registerHandler:(id)handler selector:(SEL)selector name:(NSString *)handlerName {
    [_bridge registerHandler:handlerName handler:^(id data, AGXBridgeResponseCallback responseCallback) {
        AGXMethod *method = [AGXMethod instanceMethodWithName:NSStringFromSelector(selector) inClass:[handler class]];
        if ([method.signature hasPrefix:@"v"]) {
            [handler performSelector:selector withObject:data]; responseCallback(nil);
        } else responseCallback([handler performSelector:selector withObject:data]);
    }];
}

- (void)dealloc {
    AGX_RELEASE(_bridge);
    AGX_SUPER_DEALLOC;
}

#pragma mark - swizzle

- (void)agx_setDelegate:(id<UIWebViewDelegate>)delegate {
    if (!delegate || delegate == _bridge)  {
        [self agx_setDelegate:delegate];
        return;
    }
    _bridge.delegate = delegate;
}

+ (void)load {
    static dispatch_once_t once_t;
    dispatch_once(&once_t, ^{
        [self swizzleInstanceOriSelector:@selector(setDelegate:)
                         withNewSelector:@selector(agx_setDelegate:)];
    });
}

@end
