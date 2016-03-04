//
//  AGXWebViewJavascriptBridge.m
//  AGXWebView
//
//  Created by Char Aznable on 16/3/4.
//  Copyright © 2016年 AI-CUC-EC. All rights reserved.
//

#import "AGXWebViewJavascriptBridge.h"
#import <AGXCore/AGXCore/AGXObjC.h>
#import <AGXCore/AGXCore/AGXArc.h>

@implementation AGXWebViewJavascriptBridge {
    AGXWebViewJavascriptBridgeBase *_base;
}

+ (void)enableLogging { [AGXWebViewJavascriptBridgeBase enableLogging]; }
+ (void)setLogMaxLength:(int)length { [AGXWebViewJavascriptBridgeBase setLogMaxLength:length]; }

- (AGX_INSTANCETYPE)init {
    if (AGX_EXPECT_T(self = [super init])) {
        _base = [[AGXWebViewJavascriptBridgeBase alloc] init];
        _base.delegate = self;
    }
    return self;
}

- (void)setWebView:(UIWebView *)webView {
    _webView = webView;
    _webView.delegate = self;
}

- (void)dealloc {
    AGX_RELEASE(_base);
    _base = nil;
    _webView.delegate = nil;
    _webView = nil;
    _delegate = nil;
    AGX_SUPER_DEALLOC;
}

- (void)registerHandler:(NSString *)handlerName handler:(AGXBridgeHandler)handler {
    _base.messageHandlers[handlerName] = AGX_AUTORELEASE([handler copy]);
}

- (void)callHandler:(NSString *)handlerName {
    [self callHandler:handlerName data:nil];
}

- (void)callHandler:(NSString *)handlerName data:(id)data {
    [self callHandler:handlerName data:data responseCallback:nil];
}

- (void)callHandler:(NSString *)handlerName data:(id)data responseCallback:(AGXBridgeResponseCallback)responseCallback {
    [_base sendData:data responseCallback:responseCallback handlerName:handlerName];
}

#pragma mark - AGXWebViewJavascriptBridgeBaseDelegate

- (NSString *)_evaluateJavascript:(NSString *)javascriptCommand {
    return [_webView stringByEvaluatingJavaScriptFromString:javascriptCommand];
}

#pragma mark - UIWebViewDelegate

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    if (webView != _webView) return YES;
    
    NSURL *url = [request URL];
    if ([_base isCorrectProcotocolScheme:url]) {
        if ([_base isBridgeLoadedURL:url]) {
            [_base injectJavascriptFile];
        } else if ([_base isQueueMessageURL:url]) {
            NSString *messageQueueString = [self _evaluateJavascript:[_base agxWebViewJavascriptFetchQueueCommand]];
            [_base flushMessageQueue:messageQueueString];
        } else {
            [_base logUnkownMessage:url];
        }
        return NO;
    } else if ([_delegate respondsToSelector:@selector(webView:shouldStartLoadWithRequest:navigationType:)]) {
        return [_delegate webView:webView shouldStartLoadWithRequest:request navigationType:navigationType];
    }
    return YES;
}

- (void)webViewDidStartLoad:(UIWebView *)webView {
    if (webView != _webView) return;
    if ([_delegate respondsToSelector:@selector(webViewDidStartLoad:)])
        [_delegate webViewDidStartLoad:webView];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    if (webView != _webView) return;
    if ([_delegate respondsToSelector:@selector(webViewDidFinishLoad:)])
        [_delegate webViewDidFinishLoad:webView];
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
    if (webView != _webView) return;
    if ([_delegate respondsToSelector:@selector(webView:didFailLoadWithError:)])
        [_delegate webView:webView didFailLoadWithError:error];
}

@end
