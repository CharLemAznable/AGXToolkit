//
//  AGXWebViewInternalDelegate.m
//  AGXWidget
//
//  Created by Char Aznable on 16/4/15.
//  Copyright © 2016年 AI-CUC-EC. All rights reserved.
//

#import <AGXCore/AGXCore/NSURLRequest+AGXCore.h>
#import "AGXWebViewInternalDelegate.h"

@implementation AGXWebViewInternalDelegate

- (AGX_INSTANCETYPE)init {
    if (self = [super init]) {
        _bridge = [[AGXWebViewJavascriptBridge alloc] init];
        _bridge.delegate = self;

        _progress = [[AGXWebViewProgressSensor alloc] init];
        _progress.delegate = self;

        _extension = [[AGXWebViewExtension alloc] init];
        _extension.delegate = self;
    }
    return self;
}

- (void)dealloc {
    AGX_RELEASE(_bridge);
    AGX_RELEASE(_progress);
    AGX_RELEASE(_extension);
    _webView = nil;
    _delegate = nil;
    AGX_SUPER_DEALLOC;
}

- (BOOL)respondsToSelector:(SEL)aSelector {
    return [super respondsToSelector:aSelector]
    || [self.delegate respondsToSelector:aSelector];
}

- (id)forwardingTargetForSelector:(SEL)aSelector {
    return self.delegate;
}

#pragma mark - UIWebViewDelegate

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    if (webView != _webView) return YES;

    [_bridge injectBridgeWrapperJavascript];
    if ([_progress senseCompletedWithRequest:request]) return NO;
    
    BOOL ret = YES;
    if ([self.delegate respondsToSelector:@selector(webView:shouldStartLoadWithRequest:navigationType:)])
        ret = [self.delegate webView:webView shouldStartLoadWithRequest:request navigationType:navigationType];

    if (ret && [request isNewRequestFromURL:webView.request.URL])
        [_progress resetProgressWithRequest:request];
    return ret;
}

- (void)webViewDidStartLoad:(UIWebView *)webView {
    if (webView != _webView) return;

    [_progress startProgress];
    if ([self.delegate respondsToSelector:@selector(webViewDidStartLoad:)])
        [self.delegate webViewDidStartLoad:webView];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    if (webView != _webView) return;

    [_bridge injectBridgeWrapperJavascript];
    [_progress senseProgressFromURL:webView.request.mainDocumentURL withError:nil];
    [_extension coordinate];
    if ([self.delegate respondsToSelector:@selector(webViewDidFinishLoad:)])
        [self.delegate webViewDidFinishLoad:webView];
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
    if (webView != _webView) return;

    [_progress senseProgressFromURL:webView.request.mainDocumentURL withError:error];
    if ([self.delegate respondsToSelector:@selector(webView:didFailLoadWithError:)])
        [self.delegate webView:webView didFailLoadWithError:error];
}

#pragma mark - AGXEvaluateJavascriptDelegate

- (NSString *)evaluateJavascript:(NSString *)javascript {
    return [_webView stringByEvaluatingJavaScriptFromString:javascript];
}

#pragma mark - AGXWebViewProgressSensorDelegate

- (void)webViewProgressSensor:(AGXWebViewProgressSensor *)sensor updateProgress:(float)progress {
    [_webView performSelector:@selector(setProgress:) withObject:@(progress)];
}

#pragma mark - AGXWebViewExtensionDelegate

- (void)coordinateWithBackgroundColor:(UIColor *)backgroundColor {
    _webView.backgroundColor = backgroundColor;
}

@end
