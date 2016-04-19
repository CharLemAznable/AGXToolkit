//
//  AGXWebView.m
//  AGXWidget
//
//  Created by Char Aznable on 16/3/4.
//  Copyright © 2016年 AI-CUC-EC. All rights reserved.
//

#import "AGXWebView.h"
#import "AGXProgressBar.h"
#import "AGXWebViewInternalDelegate.h"
#import <AGXCore/AGXCore/NSObject+AGXCore.h>
#import <AGXCore/AGXCore/UIView+AGXCore.h>

static long uniqueId = 0;

@implementation AGXWebView {
    AGXWebViewInternalDelegate *_internal;
    
    AGXProgressBar *_progressBar;
}

- (void)agxInitial {
    [super agxInitial];
    self.opaque = NO;
    
    _internal = [[AGXWebViewInternalDelegate alloc] init];
    agx_async_main(_internal.webView = self;)
    
    [_internal.bridge registerHandler:@"reload" handler:self selector:@selector(reload)];
    [_internal.bridge registerHandler:@"stopLoading" handler:self selector:@selector(stopLoading)];
    [_internal.bridge registerHandler:@"goBack" handler:self selector:@selector(goBack)];
    [_internal.bridge registerHandler:@"goForward" handler:self selector:@selector(goForward)];
    [_internal.bridge registerHandler:@"canGoBack" handler:self selector:@selector(canGoBack)];
    [_internal.bridge registerHandler:@"canGoForward" handler:self selector:@selector(canGoForward)];
    [_internal.bridge registerHandler:@"isLoading" handler:self selector:@selector(isLoading)];
    
    [_internal.bridge registerHandler:@"scaleFit" handler:self selector:@selector(scaleFit)];
    [_internal.bridge registerHandler:@"setBounces" handler:self selector:@selector(setBounces:)];
    [_internal.bridge registerHandler:@"setBounceHorizontal" handler:self selector:@selector(setBounceHorizontal:)];
    [_internal.bridge registerHandler:@"setBounceVertical" handler:self selector:@selector(setBounceVertical:)];
    [_internal.bridge registerHandler:@"setShowHorizontalScrollBar" handler:self
                             selector:@selector(setShowHorizontalScrollBar:)];
    [_internal.bridge registerHandler:@"setShowVerticalScrollBar" handler:self
                             selector:@selector(setShowVerticalScrollBar:)];
    
    _progressBar = [[AGXProgressBar alloc] init];
    [self addSubview:_progressBar];
    
    _progressWidth = 2;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    [self bringSubviewToFront:_progressBar];
    _progressBar.frame = CGRectMake(0, 0, self.bounds.size.width, _progressWidth);
}

- (void)dealloc {
    AGX_RELEASE(_progressBar);
    AGX_RELEASE(_internal);
    AGX_SUPER_DEALLOC;
}

- (BOOL)autoEmbedJavascript {
    return _internal.bridge.autoEmbedJavascript;
}

- (void)setAutoEmbedJavascript:(BOOL)autoEmbedJavascript {
    _internal.bridge.autoEmbedJavascript = autoEmbedJavascript;
}

- (BOOL)coordinateBackgroundColor {
    return _internal.extension.coordinateBackgroundColor;
}

- (void)setCoordinateBackgroundColor:(BOOL)coordinateBackgroundColor {
    _internal.extension.coordinateBackgroundColor = coordinateBackgroundColor;
}

- (UIColor *)progressColor {
    return _progressBar.progressColor;
}

- (void)setProgressColor:(UIColor *)progressColor {
    _progressBar.progressColor = progressColor;
}

+ (UIColor *)progressColor {
    return [[self appearance] progressColor];
}

+ (void)setProgressColor:(UIColor *)progressColor {
    [[self appearance] setProgressColor:progressColor];
}

+ (CGFloat)progressWidth {
    return [[self appearance] progressWidth];
}

+ (void)setProgressWidth:(CGFloat)progressWidth {
    [[self appearance] setProgressWidth:progressWidth];
}

- (void)registerHandlerName:(NSString *)handlerName handler:(id)handler selector:(SEL)selector; {
    [_internal.bridge registerHandler:handlerName handler:handler selector:selector];
}

- (SEL)registerTriggerAt:(Class)triggerClass withBlock:(AGXBridgeTrigger)triggerBlock {
    SEL selector = NSSelectorFromString([NSString stringWithFormat:@"trigger_%ld:", ++uniqueId]);
    [triggerClass addInstanceMethodWithSelector:selector andBlock:triggerBlock andTypeEncoding:"v@:@"];
    return selector;
}

- (SEL)registerTriggerAt:(Class)triggerClass withJavascript:(NSString *)javascript {
    __AGX_BLOCK AGXWebView *__webView = self;
    return [self registerTriggerAt:triggerClass withBlock:^(id SELF, id sender)
            { [__webView stringByEvaluatingJavaScriptFromString:javascript]; }];
}

#pragma mark - UIWebView bridge handler

- (void)scaleFit {
    self.scalesPageToFit = YES;
}

- (void)setBounces:(BOOL)bounces {
    self.scrollView.bounces = bounces;
}

- (void)setBounceHorizontal:(BOOL)bounceHorizontal {
    if (bounceHorizontal) self.scrollView.bounces = YES;
    self.scrollView.alwaysBounceHorizontal = bounceHorizontal;
}

- (void)setBounceVertical:(BOOL)bounceVertical {
    if (bounceVertical) self.scrollView.bounces = YES;
    self.scrollView.alwaysBounceHorizontal = bounceVertical;
}

- (void)setShowHorizontalScrollBar:(BOOL)showHorizontalScrollBar {
    self.scrollView.showsHorizontalScrollIndicator = showHorizontalScrollBar;
}

- (void)setShowVerticalScrollBar:(BOOL)showVerticalScrollBar {
    self.scrollView.showsVerticalScrollIndicator = showVerticalScrollBar;
}

#pragma mark - swizzle

- (void)AGXWidget_setDelegate:(id<UIWebViewDelegate>)delegate {
    if (!delegate || delegate == _internal)  {
        [self AGXWidget_setDelegate:delegate];
        return;
    }
    _internal.delegate = delegate;
}

+ (void)load {
    static dispatch_once_t once_t;
    dispatch_once(&once_t, ^{
        [self swizzleInstanceOriSelector:@selector(setDelegate:)
                         withNewSelector:@selector(AGXWidget_setDelegate:)];
    });
}

#pragma mark - private methods

- (void)setProgress:(float)progress {
    [_progressBar setProgress:progress animated:YES];
}

@end
