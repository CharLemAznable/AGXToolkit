//
//  AGXWebView.m
//  AGXWidget
//
//  Created by Char Aznable on 2016/3/4.
//  Copyright © 2016 github.com/CharLemAznable. All rights reserved.
//

#import <AssetsLibrary/AssetsLibrary.h>
#import <AVFoundation/AVCaptureDevice.h>
#import <AVFoundation/AVMediaFormat.h>
#import <AGXCore/AGXCore/AGXRandom.h>
#import <AGXCore/AGXCore/NSData+AGXCore.h>
#import <AGXCore/AGXCore/NSNumber+AGXCore.h>
#import <AGXCore/AGXCore/NSString+AGXCore.h>
#import <AGXCore/AGXCore/NSArray+AGXCore.h>
#import <AGXCore/AGXCore/NSDictionary+AGXCore.h>
#import <AGXCore/AGXCore/NSDate+AGXCore.h>
#import <AGXCore/AGXCore/UIApplication+AGXCore.h>
#import <AGXCore/AGXCore/UIImage+AGXCore.h>
#import <AGXCore/AGXCore/UIColor+AGXCore.h>
#import <AGXJson/AGXJson.h>
#import "AGXRefreshView.h"
#import "AGXProgressBar.h"
#import "AGXProgressHUD.h"
#import "AGXWebViewInternalDelegate.h"
#import "AGXWebViewConsole.h"
#import "AGXWebViewDataBox.h"

AGX_STATIC long uniqueId = 0;

@interface AGXWebView () <AGXRefreshViewDelegate, AGXWebViewConsoleDelegate>
@end

@implementation AGXWebView {
    AGXWebViewInternalDelegate *_webViewInternalDelegate;

    AGXProgressBar *_progressBar;
    CGFloat _progressWidth;
    BOOL _progressBarExtendedTranslucentBars;

    UIScrollView *_contentInsetHelperScrollView;
    AGXWebViewConsole *_console;

    NSString *_captchaCode;
}

AGX_STATIC NSHashTable *agxWebViews = nil;
+ (AGX_INSTANCETYPE)allocWithZone:(struct _NSZone *)zone {
    agx_once(agxWebViews = AGX_RETAIN([NSHashTable weakObjectsHashTable]););
    NSAssert(NSThread.isMainThread, @"should on the main thread");
    id alloc = [super allocWithZone:zone];
    [agxWebViews addObject:alloc];
    return alloc;
}

- (AGX_INSTANCETYPE)initWithFrame:(CGRect)frame {
    if AGX_EXPECT_T(self = [super initWithFrame:frame]) {
        self.backgroundColor = UIColor.whiteColor;

        _webViewInternalDelegate = [[AGXWebViewInternalDelegate alloc] init];
        _webViewInternalDelegate.webView = self;
        super.delegate = _webViewInternalDelegate;

        super.scrollView.keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag;

        _pullDownRefreshView = [[AGXRefreshView alloc] init];
        _pullDownRefreshView.delegate = self;

        _progressBar = [[AGXProgressBar alloc] init];
        [self addSubview:_progressBar];

        _progressWidth = 2;
        _progressBarExtendedTranslucentBars = YES;

        _contentInsetHelperScrollView = [[UIScrollView alloc] init];
        _contentInsetHelperScrollView.backgroundColor = UIColor.clearColor;
        if (@available(iOS 11.0, *)) {
            _contentInsetHelperScrollView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentAlways;
        } else {
            _contentInsetHelperScrollView.automaticallyAdjustsContentInsetByBars = YES;
        }
        _contentInsetHelperScrollView.delegate = _webViewInternalDelegate.extension;
        [self addSubview:_contentInsetHelperScrollView];

        _captchaCode = nil;

#define REGISTER(HANDLER, SELECTOR)                     \
[_webViewInternalDelegate.bridge registerHandlerName:   \
@HANDLER target:self action:@selector(SELECTOR)]

        REGISTER("reload", reload);
        REGISTER("stopLoading", stopLoading);
        REGISTER("goBack", goBack);
        REGISTER("goForward", goForward);
        REGISTER("canGoBack", canGoBack);
        REGISTER("canGoForward", canGoForward);
        REGISTER("isLoading", isLoading);

        REGISTER("scaleFit", scaleFit);
        REGISTER("setBounces", setBounces:);
        REGISTER("setBounceHorizontal", setBounceHorizontal:);
        REGISTER("setBounceVertical", setBounceVertical:);
        REGISTER("setShowHorizontalScrollBar", setShowHorizontalScrollBar:);
        REGISTER("setShowVerticalScrollBar", setShowVerticalScrollBar:);
        REGISTER("scrollToTop", scrollToTop:);
        REGISTER("scrollToBottom", scrollToBottom:);
        REGISTER("containerInset", containerInset);
        REGISTER("startPullDownRefresh", startPullDownRefreshAsync);
        REGISTER("finishPullDownRefresh", finishPullDownRefreshAsync);

        REGISTER("HUDMessage", HUDMessage:);
        REGISTER("HUDLoading", HUDLoading:);
        REGISTER("HUDLoaded", HUDLoaded);

        REGISTER("captchaImageURLString", captchaImageURLString:);
        REGISTER("verifyCaptchaCode", verifyCaptchaCode:);

        REGISTER("watermarkedImageURLString", watermarkedImageURLString:);

        REGISTER("setTemporaryItem", setTemporaryItem:);
        REGISTER("temporaryItem", temporaryItem:);
        REGISTER("setPermanentItem", setPermanentItem:);
        REGISTER("permanentItem", permanentItem:);
        REGISTER("setImmortalItem", setImmortalItem:);
        REGISTER("immortalItem", immortalItem:);

#undef REGISTER

        [_webViewInternalDelegate.bridge registerErrorHandlerTarget:
         self action:@selector(internalHandleErrorMessage:stack:)];
        [_webViewInternalDelegate.bridge registerLogHandlerTarget:
         self action:@selector(internalHandleLogLevel:content:stack:)];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    _pullDownRefreshView.frame = AGX_CGRectMake
    (CGPointMake(0, -self.scrollView.bounds.size.height), self.scrollView.bounds.size);

    [self sendSubviewToBack:_contentInsetHelperScrollView];
    _contentInsetHelperScrollView.frame = self.scrollView.frame;

    [self bringSubviewToFront:_progressBar];
    CGFloat contentInsetTop = self.containerContentInset.top;
    CGFloat y = _progressBarExtendedTranslucentBars ? 0 : contentInsetTop;
    CGFloat height = _progressBarExtendedTranslucentBars ? (contentInsetTop+_progressWidth) : _progressWidth;
    _progressBar.frame = CGRectMake(0, y, self.bounds.size.width, height);
    [self bringSubviewToFront:_console];
    _console.frame = _contentInsetHelperScrollView.frame;
    _console.layoutContentInset = self.containerContentInset;
}

- (void)dealloc {
    AGX_RELEASE(_console);
    AGX_RELEASE(_captchaCode);
    AGX_RELEASE(_contentInsetHelperScrollView);
    AGX_RELEASE(_progressBar);
    AGX_RELEASE(_pullDownRefreshView);
    AGX_RELEASE(_webViewInternalDelegate);
    AGX_SUPER_DEALLOC;
}

- (BOOL)autoCoordinateBackgroundColor {
    return _webViewInternalDelegate.extension.autoCoordinateBackgroundColor;
}

- (void)setAutoCoordinateBackgroundColor:(BOOL)autoCoordinateBackgroundColor {
    _webViewInternalDelegate.extension.autoCoordinateBackgroundColor = autoCoordinateBackgroundColor;
}

- (BOOL)autoRevealCurrentLocationHost {
    return _webViewInternalDelegate.extension.autoRevealCurrentLocationHost;
}

- (void)setAutoRevealCurrentLocationHost:(BOOL)autoRevealCurrentLocationHost {
    _webViewInternalDelegate.extension.autoRevealCurrentLocationHost = autoRevealCurrentLocationHost;
}

- (NSString *)currentLocationHostRevealFormat {
    return _webViewInternalDelegate.extension.currentLocationHostRevealFormat;
}

- (void)setCurrentLocationHostRevealFormat:(NSString *)currentLocationHostRevealFormat {
    _webViewInternalDelegate.extension.currentLocationHostRevealFormat = currentLocationHostRevealFormat;
}

- (void)setPullDownRefreshEnabled:(BOOL)pullDownRefreshEnabled {
    if (_pullDownRefreshEnabled == pullDownRefreshEnabled) return;
    _pullDownRefreshEnabled = pullDownRefreshEnabled;

    if (_pullDownRefreshEnabled) {
        [self.scrollView addSubview:_pullDownRefreshView];
    } else {
        [_pullDownRefreshView removeFromSuperview];
    }
    [self setNeedsLayout];
}

- (void)startPullDownRefresh {
    if (_pullDownRefreshEnabled) {
        [_pullDownRefreshView scrollViewStartLoad:self.scrollView];
        [self.scrollView scrollToTop:YES];
    }
}

- (void)finishPullDownRefresh {
    if (_pullDownRefreshEnabled) [_pullDownRefreshView scrollViewFinishLoad:self.scrollView];
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

- (CGFloat)progressWidth {
    return _progressWidth;
}

- (void)setProgressWidth:(CGFloat)progressWidth {
    _progressWidth = progressWidth;
    [self setNeedsLayout];
}

+ (CGFloat)progressWidth {
    return [[self appearance] progressWidth];
}

+ (void)setProgressWidth:(CGFloat)progressWidth {
    [[self appearance] setProgressWidth:progressWidth];
}

- (BOOL)progressBarExtendedTranslucentBars {
    return _progressBarExtendedTranslucentBars;
}

- (void)setProgressBarExtendedTranslucentBars:(BOOL)progressBarExtendedTranslucentBars {
    _progressBarExtendedTranslucentBars = progressBarExtendedTranslucentBars;
    [self setNeedsLayout];
}

+ (BOOL)progressBarExtendedTranslucentBars {
    return [[self appearance] progressBarExtendedTranslucentBars];
}

+ (void)setProgressBarExtendedTranslucentBars:(BOOL)progressBarExtendedTranslucentBars {
    [[self appearance] setProgressBarExtendedTranslucentBars:progressBarExtendedTranslucentBars];
}

- (UIEdgeInsets)containerContentInset {
    return _contentInsetHelperScrollView.contentInsetIncorporated;
}

- (void)containerContentInsetDidChange {
    AGX_STATIC NSString *const containerInsetDidChangeJSFormat =
    @";window.containerInsetDidChange&&window.containerInsetDidChange(%@);";
    [self stringByEvaluatingJavaScriptFromString:
     [NSString stringWithFormat:containerInsetDidChangeJSFormat,
      [self.containerInset agxJsonString]]];
}

- (NSURLRequest *)currentRequest {
    return _webViewInternalDelegate.progress.currentRequest;
}

- (void)registerHandlerName:(NSString *)handlerName target:(id)target action:(SEL)action {
    [_webViewInternalDelegate.bridge registerHandlerName:handlerName target:target action:action];
}

- (void)registerHandlerName:(NSString *)handlerName target:(id)target action:(SEL)action scope:(NSString *)scope {
    [_webViewInternalDelegate.bridge registerHandlerName:handlerName target:target action:action scope:scope];
}

- (void)registerErrorHandlerTarget:(id)target action:(SEL)action {
    [_webViewInternalDelegate.bridge registerErrorHandlerTarget:target action:action];
}

- (void)setShowLogConsole:(BOOL)showLogConsole {
    _showLogConsole = showLogConsole;

    if (_showLogConsole) {
        if (!_console) {
            _console = [[AGXWebViewConsole alloc] initWithLogLevel:
                        _webViewInternalDelegate.bridge.javascriptLogLevel];
            _console.delegate = self;
        }
        [self addSubview:_console];
    } else {
        [_console removeFromSuperview];
        if (_console) {
            AGX_RELEASE(_console);
            _console = nil;
        }
    }
    [self setNeedsLayout];
}

+ (BOOL)showLogConsole {
    return [[self appearance] showLogConsole];
}

+ (void)setShowLogConsole:(BOOL)showLogConsole {
    [[self appearance] setShowLogConsole:showLogConsole];
}

// AGXWebViewConsoleDelegate
- (void)webViewConsole:(AGXWebViewConsole *)console didSelectSegmentIndex:(NSInteger)index {
    if AGX_EXPECT_F(console != _console) return;
    _webViewInternalDelegate.bridge.javascriptLogLevel = index;
}

- (AGXWebViewLogLevel)javascriptLogLevel {
    return _webViewInternalDelegate.bridge.javascriptLogLevel;
}

- (void)setJavascriptLogLevel:(AGXWebViewLogLevel)javascriptLogLevel {
    _webViewInternalDelegate.bridge.javascriptLogLevel = javascriptLogLevel;
    _console.javascriptLogLevel = javascriptLogLevel;
}

+ (AGXWebViewLogLevel)javascriptLogLevel {
    return [[self appearance] javascriptLogLevel];
}

+ (void)setJavascriptLogLevel:(AGXWebViewLogLevel)javascriptLogLevel {
    [[self appearance] setJavascriptLogLevel:javascriptLogLevel];
}

- (void)registerLogHandlerTarget:(id)target action:(SEL)action {
    [_webViewInternalDelegate.bridge registerLogHandlerTarget:target action:action];
}

- (SEL)registerTriggerAt:(Class)triggerClass withBlock:(void (^)(id SELF, id sender))triggerBlock {
    SEL selector = NSSelectorFromString([NSString stringWithFormat:@"trigger_%ld:", ++uniqueId]);
    [triggerClass addInstanceMethodWithSelector:selector andBlock:triggerBlock andTypeEncoding:"v@:@"];
    return selector;
}

- (SEL)registerTriggerAt:(Class)triggerClass withJavascript:(NSString *)javascript {
    __AGX_WEAK_RETAIN AGXWebView *__webView = self;
    return [self registerTriggerAt:triggerClass withBlock:^(id SELF, id sender) {
        [__webView stringByEvaluatingJavaScriptFromString:
         [NSString stringWithFormat:@";(%@)();", javascript]];
    }];
}

- (SEL)registerTriggerAt:(Class)triggerClass withJavascript:(NSString *)javascript paramKeyPath:(NSString *)paramKeyPath, ... NS_REQUIRES_NIL_TERMINATION {
    return [self registerTriggerAt:triggerClass withJavascript:javascript paramKeyPaths:agx_va_list(paramKeyPath)];
}

- (SEL)registerTriggerAt:(Class)triggerClass withJavascript:(NSString *)javascript paramKeyPaths:(NSArray *)paramKeyPaths {
    __AGX_WEAK_RETAIN AGXWebView *__webView = self;
    return [self registerTriggerAt:triggerClass withBlock:^(id SELF, id sender) {
        NSMutableArray *paramValues = [NSMutableArray array];
        for (int i = 0; i < paramKeyPaths.count; i++) {
            NSString *keyPath = paramKeyPaths[i];
            if AGX_EXPECT_F(0 == keyPath.length) { [paramValues addObject:@"undefined"]; continue; }
            [paramValues addObject:[[SELF valueForKeyPath:keyPath] agxJsonString] ?: @"undefined"];
        }
        [__webView stringByEvaluatingJavaScriptFromString:
         [NSString stringWithFormat:@";(%@)(%@);", javascript,
          [paramValues stringJoinedByString:@"," usingComparator:NULL filterEmpty:NO]]];
    }];
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [super scrollViewDidScroll:scrollView];
    if (_pullDownRefreshEnabled) [_pullDownRefreshView didScrollView:scrollView];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    [super scrollViewDidEndDragging:scrollView willDecelerate:decelerate];
    if (_pullDownRefreshEnabled) [_pullDownRefreshView didEndDragging:scrollView];
}

#pragma mark - AGXRefreshViewDelegate

- (void)refreshViewStartLoad:(AGXRefreshView *)refreshView {
    if (!_pullDownRefreshEnabled) return;

    AGX_STATIC NSString *const doPullDownRefreshExistsJS =
    @"'function'==typeof doPullDownRefresh";
    AGX_STATIC NSString *const doPullDownRefreshJS =
    @";window.doPullDownRefresh&&window.doPullDownRefresh();";

    [[self stringByEvaluatingJavaScriptFromString:doPullDownRefreshExistsJS] boolValue] ?
    [self stringByEvaluatingJavaScriptFromString:doPullDownRefreshJS] : [self reload];
}

#pragma mark - UIWebView bridge handler

- (void)reload {
    NSString *viewURL = self.request.URL.absoluteString;
    if (AGXIsNotEmpty(viewURL)) [super reload];
    else [self loadRequest:self.currentRequest];
}

- (void)scaleFit {
    self.scalesPageToFit = YES;
}

- (void)setBounces:(BOOL)bounces {
    agx_async_main(self.scrollView.bounces = bounces;);
}

- (void)setBounceHorizontal:(BOOL)bounceHorizontal {
    agx_async_main
    (if (bounceHorizontal) self.scrollView.bounces = YES;
     self.scrollView.alwaysBounceHorizontal = bounceHorizontal;);
}

- (void)setBounceVertical:(BOOL)bounceVertical {
    agx_async_main
    (if (bounceVertical) self.scrollView.bounces = YES;
     self.scrollView.alwaysBounceHorizontal = bounceVertical;);
}

- (void)setShowHorizontalScrollBar:(BOOL)showHorizontalScrollBar {
    agx_async_main
    (self.scrollView.showsHorizontalScrollIndicator = showHorizontalScrollBar;);
}

- (void)setShowVerticalScrollBar:(BOOL)showVerticalScrollBar {
    agx_async_main
    (self.scrollView.showsVerticalScrollIndicator = showVerticalScrollBar;);
}

- (void)scrollToTop:(BOOL)animated {
    agx_async_main([self.scrollView scrollToTop:animated];);
}

- (void)scrollToBottom:(BOOL)animated {
    agx_async_main([self.scrollView scrollToBottom:animated];);
}

- (id)containerInset {
    return [[NSValue valueWithUIEdgeInsets:self.containerContentInset] validJsonObjectForUIEdgeInsets];
}

- (void)startPullDownRefreshAsync {
    agx_async_main([self startPullDownRefresh];);
}

- (void)finishPullDownRefreshAsync {
    agx_async_main([self finishPullDownRefresh];);
}

#pragma mark - ProgressHUD bridge handler

- (void)HUDMessage:(NSDictionary *)setting {
    NSString *title = [setting itemForKey:@"title"], *message = [setting itemForKey:@"message"];
    if AGX_EXPECT_F(AGXIsNilOrEmpty(title) && AGXIsNilOrEmpty(message)) return;
    NSTimeInterval delay = [([setting itemForKey:@"delay"]?:@2) timeIntervalValue];
    BOOL fullScreen = [([setting itemForKey:@"fullScreen"]?:@NO) boolValue];
    BOOL opaque = [([setting itemForKey:@"opaque"]?:@YES) boolValue];
    UIView *view = fullScreen ? UIApplication.sharedKeyWindow : self;
    agx_async_main([view showMessageHUD:opaque title:title detail:message duration:delay];);
}

- (void)HUDLoading:(NSDictionary *)setting {
    NSString *title = [setting itemForKey:@"title"], *message = [setting itemForKey:@"message"];
    BOOL fullScreen = [([setting itemForKey:@"fullScreen"]?:@NO) boolValue];
    BOOL opaque = [([setting itemForKey:@"opaque"]?:@YES) boolValue];
    UIView *view = fullScreen ? UIApplication.sharedKeyWindow : self;
    agx_async_main([view showLoadingHUD:opaque title:title detail:message];);
}

- (void)HUDLoaded {
    agx_async_main([UIApplication.sharedKeyWindow hideRecursiveHUD];);
}

#pragma mark - Captcha image handler

- (NSString *)captchaImageURLString:(NSDictionary *)params {
    if (![params itemForKey:@"width"] || ![params itemForKey:@"height"]) return nil;

    NSString *type = [params itemForKey:@"type"]?:@"default";
    NSString *(^randomBlock)(int count) = [type isCaseInsensitiveEqualToString:@"digit"] ? AGXRandom.NUM :
    ([type isCaseInsensitiveEqualToString:@"letter"] ? AGXRandom.LETTERS : AGXRandom.ALPHANUMERIC);
    NSString *temp = AGX_RETAIN(randomBlock([[params itemForKey:@"length"] intValue]?:4));
    AGX_RELEASE(_captchaCode);
    _captchaCode = temp;

    UIImage *image = [UIImage captchaImageWithCaptchaCode:_captchaCode size:
                      CGSizeMake([[params itemForKey:@"width"] cgfloatValue],
                                 [[params itemForKey:@"height"] cgfloatValue])];
    return [NSString stringWithFormat:@"data:image/png;base64,%@",
            UIImagePNGRepresentation(image).base64EncodedString];
}

- (BOOL)verifyCaptchaCode:(NSString *)inputCode {
    return AGXIsNotEmpty(inputCode) && [_captchaCode isCaseInsensitiveEqualToString:inputCode];
}

#pragma mark - Watermarked image handler

- (NSString *)watermarkedImageURLString:(NSDictionary *)params {
    NSString *url = [params itemForKey:@"url"];
    if AGX_EXPECT_F(AGXIsNilOrEmpty(url)) return nil;

    UIImage *image = [UIImage imageWithURLString:url scale:UIScreen.mainScreen.scale];
    if AGX_EXPECT_F(!image) return nil;

    UIImage *watermarkImage = nil;
    NSString *imageURLString = [params itemForKey:@"image"];
    if (AGXIsNotEmpty(imageURLString)) {
        watermarkImage = [UIImage imageWithURLString:imageURLString scale:UIScreen.mainScreen.scale];
    }
    NSString *watermarkText = [params itemForKey:@"text"];
    if AGX_EXPECT_F(!watermarkImage && AGXIsNilOrEmpty(watermarkText)) return nil;

    AGXDirection direction = [([params itemForKey:@"direction"]?:@(AGXDirectionSouthEast)) unsignedIntegerValue];
    CGVector offset = CGVectorMake([[params itemForKey:@"offsetX"] cgfloatValue],
                                   [[params itemForKey:@"offsetY"] cgfloatValue]);

    UIImage *resultImage = nil;
    if (watermarkImage) {
        resultImage = [UIImage imageBaseOnImage:image watermarkedWithImage:watermarkImage
                                    inDirection:direction withOffset:offset];
    } else {
        NSMutableDictionary *attrs = NSMutableDictionary.instance;
        attrs[NSForegroundColorAttributeName] = AGXColor([params itemForKey:@"color"]);
        NSString *fontName = (AGXIsNotEmpty([params itemForKey:@"fontName"]) ?
                              [params itemForKey:@"fontName"] : @"HelveticaNeue");
        CGFloat fontSize = [([params itemForKey:@"fontSize"]?:@12) cgfloatValue];
        attrs[NSFontAttributeName] = [UIFont fontWithName:fontName size:fontSize];

        resultImage = [UIImage imageBaseOnImage:image watermarkedWithText:watermarkText
                                 withAttributes:attrs inDirection:direction withOffset:offset];
    }

    return [NSString stringWithFormat:@"data:image/png;base64,%@",
            UIImagePNGRepresentation(resultImage).base64EncodedString];
}

#pragma mark - AGXData bridge hander

- (void)setTemporaryItem:(NSDictionary *)params {
    NSString *key = [params itemForKey:@"key"];
    if AGX_EXPECT_F(AGXIsNilOrEmpty(key)) return;
    id value = [params itemForKey:@"value"];
    if AGX_EXPECT_F(AGXIsNil(value)) return;

    [AGXWebViewDataBox.shareInstance.temporary setValue:value forKey:key];
    [AGXWebViewDataBox.shareInstance synchronize];
}

- (void)temporaryItem:(NSDictionary *)params {
    NSString *key = [params itemForKey:@"key"];
    if AGX_EXPECT_F(AGXIsNilOrEmpty(key)) return;
    NSString *callback = [params itemForKey:@"callback"];
    if AGX_EXPECT_F(AGXIsNilOrEmpty(callback)) return;

    id value = [AGXWebViewDataBox.shareInstance.temporary itemForKey:key];
    NSString *javascript = [NSString stringWithFormat:@";(%@)(%@);",
                            callback, [value agxJsonString]];
    [self stringByEvaluatingJavaScriptFromString:javascript];
}

- (void)setPermanentItem:(NSDictionary *)params {
    NSString *key = [params itemForKey:@"key"];
    if AGX_EXPECT_F(AGXIsNilOrEmpty(key)) return;
    id value = [params itemForKey:@"value"];
    if AGX_EXPECT_F(AGXIsNil(value)) return;

    [AGXWebViewDataBox.shareInstance.permanent setValue:value forKey:key];
    [AGXWebViewDataBox.shareInstance synchronize];
}

- (void)permanentItem:(NSDictionary *)params {
    NSString *key = [params itemForKey:@"key"];
    if AGX_EXPECT_F(AGXIsNilOrEmpty(key)) return;
    NSString *callback = [params itemForKey:@"callback"];
    if AGX_EXPECT_F(AGXIsNilOrEmpty(callback)) return;

    id value = [AGXWebViewDataBox.shareInstance.permanent itemForKey:key];
    NSString *javascript = [NSString stringWithFormat:@";(%@)(%@);",
                            callback, [value agxJsonString]];
    [self stringByEvaluatingJavaScriptFromString:javascript];
}

- (void)setImmortalItem:(NSDictionary *)params {
    NSString *key = [params itemForKey:@"key"];
    if AGX_EXPECT_F(AGXIsNilOrEmpty(key)) return;
    id value = [params itemForKey:@"value"];
    if AGX_EXPECT_F(AGXIsNil(value)) return;

    [AGXWebViewDataBox.shareInstance.immortal setValue:value forKey:key];
    [AGXWebViewDataBox.shareInstance synchronize];
}

- (void)immortalItem:(NSDictionary *)params {
    NSString *key = [params itemForKey:@"key"];
    if AGX_EXPECT_F(AGXIsNilOrEmpty(key)) return;
    NSString *callback = [params itemForKey:@"callback"];
    if AGX_EXPECT_F(AGXIsNilOrEmpty(callback)) return;

    id value = [AGXWebViewDataBox.shareInstance.immortal itemForKey:key];
    NSString *javascript = [NSString stringWithFormat:@";(%@)(%@);",
                            callback, [value agxJsonString]];
    [self stringByEvaluatingJavaScriptFromString:javascript];
}

#pragma mark - bridge error handler

- (void)internalHandleErrorMessage:(NSString *)message stack:(NSArray *)stack {
    [_console addLogLevel:AGXWebViewLogError message:message stack:stack];
}

#pragma mark - bridge log handler

- (void)internalHandleLogLevel:(AGXWebViewLogLevel)level content:(NSArray *)content stack:(NSArray *)stack {
    NSMutableArray *contentByJsonString = NSMutableArray.instance;
    [content enumerateObjectsUsingBlock:
     ^(id obj, NSUInteger idx, BOOL *stop) {
         [contentByJsonString addObject:[obj agxJsonString]];
    }];
    NSString *message = [contentByJsonString stringJoinedByString:
                         @", " usingComparator:NULL filterEmpty:NO];
    [_console addLogLevel:level message:message stack:stack];
}

#pragma mark - override

- (id<UIWebViewDelegate>)delegate {
    return _webViewInternalDelegate.delegate;
}

- (void)setDelegate:(id<UIWebViewDelegate>)delegate {
    _webViewInternalDelegate.delegate = delegate;
    super.delegate = _webViewInternalDelegate;
}

#pragma mark - private methods

- (AGXWebViewInternalDelegate *)internal {
    return _webViewInternalDelegate;
}

- (void)setProgress:(float)progress {
    [_progressBar setProgress:progress animated:YES];
}

@end

@category_interface(NSObject, AGXWidgetAGXWebView)
@end
@category_implementation(NSObject, AGXWidgetAGXWebView)
- (void)webView:(id)webView didCreateJavaScriptContext:(JSContext *)ctx forFrame:(id)frame {
    void (^JavaScriptContextBridgeInjection)(void) = ^{
        for (AGXWebView *agxWebView in agxWebViews) {
            NSString *hash = [NSString stringWithFormat:@"agx_jscWebView_%lud", (unsigned long)agxWebView.hash];
            [agxWebView stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"var %@='%@'", hash, hash]];
            if ([ctx[hash].toString isEqualToString:hash]) {
                ctx[@"AGXBridge"] = [agxWebView valueForKeyPath:@"internal.bridge"];
                return;
            }
        }
    };

    if (NSThread.isMainThread) JavaScriptContextBridgeInjection();
    else dispatch_async(dispatch_get_main_queue(), JavaScriptContextBridgeInjection);
}
@end
