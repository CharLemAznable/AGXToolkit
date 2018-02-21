//
//  AGXWebViewInternalDelegate.m
//  AGXWidget
//
//  Created by Char Aznable on 2016/4/15.
//  Copyright © 2016年 AI-CUC-EC. All rights reserved.
//

#import <AGXCore/AGXCore/NSObject+AGXCore.h>
#import <AGXCore/AGXCore/NSURLRequest+AGXCore.h>
#import <AGXCore/AGXCore/UIColor+AGXCore.h>
#import <AGXCore/AGXCore/UIScrollView+AGXCore.h>
#import "AGXWebViewInternalDelegate.h"

@implementation AGXWebViewInternalDelegate

- (AGX_INSTANCETYPE)init {
    if AGX_EXPECT_T(self = [super init]) {
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
    if AGX_EXPECT_F(webView != _webView) return YES;

    if ([_progress senseCompletedWithRequest:request]) return NO;
    [_bridge performSelectorOnMainThread:@selector(injectBridgeWrapperJavascript) withObject:nil waitUntilDone:NO];

    BOOL ret = YES;
    if ([self.delegate respondsToSelector:@selector(webView:shouldStartLoadWithRequest:navigationType:)])
        ret = [self.delegate webView:webView shouldStartLoadWithRequest:request navigationType:navigationType];

    if (ret && [request isNewRequestFromURL:webView.request.URL])
        [_progress resetProgressWithRequest:request];
    return ret;
}

- (void)webViewDidStartLoad:(UIWebView *)webView {
    if AGX_EXPECT_F(webView != _webView) return;

    if ([self.delegate respondsToSelector:@selector(webViewDidStartLoad:)])
        [self.delegate webViewDidStartLoad:webView];
    [_progress startProgress];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    if AGX_EXPECT_F(webView != _webView) return;

    [_bridge performSelectorOnMainThread:@selector(injectBridgeWrapperJavascript) withObject:nil waitUntilDone:NO];
    if ([self.delegate respondsToSelector:@selector(webViewDidFinishLoad:)])
        [self.delegate webViewDidFinishLoad:webView];
    [_progress senseProgressFromURL:webView.request.mainDocumentURL withError:nil];
    [_extension coordinateBackgroundColor];
    [_extension revealCurrentLocationHost];
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
    if AGX_EXPECT_F(webView != _webView) return;

    if ([self.delegate respondsToSelector:@selector(webView:didFailLoadWithError:)])
        [self.delegate webView:webView didFailLoadWithError:error];
    [_progress senseProgressFromURL:webView.request.mainDocumentURL withError:error];
}

#pragma mark - AGXEvaluateJavascriptDelegate

- (NSString *)evaluateJavascript:(NSString *)javascript {
    return [_webView stringByEvaluatingJavaScriptFromString:javascript];
}

#pragma mark - AGXWebViewProgressSensorDelegate

- (void)webViewProgressSensor:(AGXWebViewProgressSensor *)sensor updateProgress:(float)progress {
    [_webView performAGXSelector:@selector(setProgress:) withObject:@(progress)];
}

#pragma mark - AGXWebViewExtensionDelegate

- (void)webViewExtension:(AGXWebViewExtension *)webViewExtension coordinateWithBackgroundColor:(UIColor *)backgroundColor {
    _webView.backgroundColor = backgroundColor;
}

static NSInteger const AGX_HOST_INDICATOR_TAG = 9151920;

- (void)webViewExtension:(AGXWebViewExtension *)webViewExtension revealWithCurrentLocationHost:(NSString *)locationHost {
    UILabel *hostIndicatorLabel = [_webView viewWithTag:AGX_HOST_INDICATOR_TAG];
    if (!hostIndicatorLabel) {
        hostIndicatorLabel = UILabel.instance;
        hostIndicatorLabel.tag = AGX_HOST_INDICATOR_TAG;
        hostIndicatorLabel.backgroundColor = UIColor.clearColor;
        hostIndicatorLabel.font = [UIFont systemFontOfSize:12];
        hostIndicatorLabel.textAlignment = NSTextAlignmentCenter;
        [_webView addSubview:hostIndicatorLabel];
    }
    [_webView sendSubviewToBack:hostIndicatorLabel];
    hostIndicatorLabel.frame = CGRectMake(0, _webView.scrollView.contentInsetIncorporated.top+20,
                                          _webView.bounds.size.width, 24);

    AGXColorShade colorShade = _webView.backgroundColor.colorShade;
    hostIndicatorLabel.textColor = AGXColorShadeDark == colorShade ? UIColor.lightGrayColor :
    (AGXColorShadeLight == colorShade ? UIColor.darkGrayColor : UIColor.grayColor);
    hostIndicatorLabel.text = locationHost;
}

@end
