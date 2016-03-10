//
//  AGXWebView.m
//  AGXWidget
//
//  Created by Char Aznable on 16/3/4.
//  Copyright © 2016年 AI-CUC-EC. All rights reserved.
//

#import "AGXWebView.h"
#import "AGXWebViewJavascriptBridge.h"
#import "AGXWebViewJavascriptBridgeAuto.h"
#import <AGXCore/AGXCore/NSObject+AGXCore.h>
#import <AGXCore/AGXCore/UIView+AGXCore.h>

@interface AGXWebViewInternalDelegate : NSObject <UIWebViewDelegate, AGXWebViewJavascriptBridgeDelegate>
@property (nonatomic, AGX_WEAK) id<UIWebViewDelegate> delegate;
@property (nonatomic, AGX_WEAK) UIWebView *webView;

@property (nonatomic, AGX_STRONG) AGXWebViewJavascriptBridge *bridge;
@end

@implementation AGXWebView {
    long _uniqueId;
    AGXWebViewInternalDelegate *_internal;
}

- (void)agxInitial {
    [super agxInitial];
    _uniqueId = 0;
    _internal = [[AGXWebViewInternalDelegate alloc] init];
    dispatch_async(dispatch_get_main_queue(), ^{ _internal.webView = self; });
    
    AutoRegisterBridgeHandler(self, [AGXWebView class],
                              ^(id handler, SEL selector, NSString *handlerName) {
                                  [handler registerHandlerName:handlerName handler:handler selector:selector];
                              });
}

- (BOOL)autoEmbedJavascript {
    return _internal.bridge.autoEmbedJavascript;
}

- (void)setAutoEmbedJavascript:(BOOL)autoEmbedJavascript {
    _internal.bridge.autoEmbedJavascript = autoEmbedJavascript;
}

- (void)dealloc {
    AGX_RELEASE(_internal);
    AGX_SUPER_DEALLOC;
}

- (void)registerHandlerName:(NSString *)handlerName handler:(id)handler selector:(SEL)selector; {
    [_internal.bridge registerHandler:handlerName handler:handler selector:selector];
}

- (SEL)registerTriggerAt:(Class)triggerClass withBlock:(AGXBridgeTrigger)triggerBlock {
    SEL selector = NSSelectorFromString([NSString stringWithFormat:@"trigger_%ld:", ++_uniqueId]);
    [triggerClass addInstanceMethodWithSelector:selector andBlock:triggerBlock andTypeEncoding:"v@:@"];
    return selector;
}

- (SEL)registerTriggerAt:(Class)triggerClass withJavascript:(NSString *)javascript {
    __AGX_BLOCK AGXWebView *__webView = self;
    return [self registerTriggerAt:triggerClass withBlock:^(id SELF, id sender)
            { [__webView stringByEvaluatingJavaScriptFromString:javascript]; }];
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

- (void)bridge_scaleFit {
    self.scalesPageToFit = YES;
}

- (void)bridge_setBounces:(BOOL)bounces {
    self.scrollView.bounces = bounces;
}

- (void)bridge_setBounceHorizontal:(BOOL)bounceHorizontal {
    if (bounceHorizontal) self.scrollView.bounces = YES;
    self.scrollView.alwaysBounceHorizontal = bounceHorizontal;
}

- (void)bridge_setBounceVertical:(BOOL)bounceVertical {
    if (bounceVertical) self.scrollView.bounces = YES;
    self.scrollView.alwaysBounceHorizontal = bounceVertical;
}

- (void)bridge_setShowHorizontalScrollBar:(BOOL)showHorizontalScrollBar {
    self.scrollView.showsHorizontalScrollIndicator = showHorizontalScrollBar;
}

- (void)bridge_setShowVerticalScrollBar:(BOOL)showVerticalScrollBar {
    self.scrollView.showsVerticalScrollIndicator = showVerticalScrollBar;
}

#pragma mark - swizzle

- (void)AGXWebView_setDelegate:(id<UIWebViewDelegate>)delegate {
    if (!delegate || delegate == _internal)  {
        [self AGXWebView_setDelegate:delegate];
        return;
    }
    _internal.delegate = delegate;
}

+ (void)load {
    static dispatch_once_t once_t;
    dispatch_once(&once_t, ^{
        [self swizzleInstanceOriSelector:@selector(setDelegate:)
                         withNewSelector:@selector(AGXWebView_setDelegate:)];
    });
}

@end

@implementation AGXWebViewInternalDelegate

- (AGX_INSTANCETYPE)init {
    if (self = [super init]) {
        _bridge = [[AGXWebViewJavascriptBridge alloc] init];
        _bridge.delegate = self;
    }
    return self;
}

- (void)setWebView:(UIWebView *)webView {
    _webView = webView;
    _webView.delegate = self;
}

- (void)dealloc {
    AGX_RELEASE(_bridge);
    _webView.delegate = nil;
    _webView = nil;
    _delegate = nil;
    AGX_SUPER_DEALLOC;
}

#pragma mark - AGXWebViewJavascriptBridgeDelegate

- (NSString *)evaluateJavascript:(NSString *)javascript {
    return [_webView stringByEvaluatingJavaScriptFromString:javascript];
}

#pragma mark - UIWebViewDelegate

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    if (webView != _webView) return YES;
    
    if ([_bridge doBridgeWithRequest:request]) return NO;
    else if ([_delegate respondsToSelector:@selector(webView:shouldStartLoadWithRequest:navigationType:)])
        return [_delegate webView:webView shouldStartLoadWithRequest:request navigationType:navigationType];
    else return YES;
}

- (void)webViewDidStartLoad:(UIWebView *)webView {
    if (webView != _webView) return;
    
    if ([_delegate respondsToSelector:@selector(webViewDidStartLoad:)])
        [_delegate webViewDidStartLoad:webView];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    if (webView != _webView) return;
    
    [_bridge setupBridge];
    if ([_delegate respondsToSelector:@selector(webViewDidFinishLoad:)])
        [_delegate webViewDidFinishLoad:webView];
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
    if (webView != _webView) return;
    
    if ([_delegate respondsToSelector:@selector(webView:didFailLoadWithError:)])
        [_delegate webView:webView didFailLoadWithError:error];
}

@end
