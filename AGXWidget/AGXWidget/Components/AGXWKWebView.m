//
//  AGXWKWebView.m
//  AGXWidget
//
//  Created by Char Aznable on 2019/4/17.
//  Copyright © 2019 github.com/CharLemAznable. All rights reserved.
//

#import <AGXCore/AGXCore/AGXDelegateForwarder.h>
#import <AGXCore/AGXCore/AGXGeometry.h>
#import <AGXCore/AGXCore/NSDictionary+AGXCore.h>
#import <AGXCore/AGXCore/NSDate+AGXCore.h>
#import <AGXCore/AGXCore/UIApplication+AGXCore.h>
#import <AGXCore/AGXCore/UIColor+AGXCore.h>
#import <AGXJson/AGXJson.h>
#import "AGXWKWebView.h"
#import "AGXWidgetLocalization.h"
#import "AGXRefreshView.h"
#import "AGXProgressHUD.h"
#import "AGXProgressBar.h"
#import "AGXWKWebViewRefreshView.h"
#import "AGXWKWebViewJavascriptBridge.h"
#import "AGXWKWebViewErrorBridge.h"
#import "AGXWKWebViewConsoleBridge.h"
#import "AGXWKWebViewConsoleView.h"
#import "AGXWKWebViewDataBox.h"

@interface WKWebView (AGXWidget_AGXWKWebView) <UIScrollViewDelegate, UIScrollViewDelegate_AGXCore>
@end
@implementation WKWebView (AGXWidget_AGXWKWebView)
@end

@forwarder_interface(AGXWKWebViewNavigationDelegateForwarder, AGXWKWebView, WKNavigationDelegate)
@forwarder_implementation(AGXWKWebViewNavigationDelegateForwarder, AGXWKWebView, WKNavigationDelegate)

@interface AGXWKWebView () <WKNavigationDelegate, UIScrollViewDelegate, UIScrollViewDelegate_AGXCore, AGXRefreshViewDelegate, AGXWKWebViewConsoleViewDelegate>
@end

@implementation AGXWKWebView {
    AGXWKWebViewNavigationDelegateForwarder *_delegateForwarder;
    NSURLRequest *_currentRequest;

    AGXWKWebViewJavascriptBridge *_javascriptBridge;
    AGXWKWebViewErrorBridge *_errorBridge;
    AGXWKWebViewConsoleBridge *_consoleBridge;
    AGXWKWebViewConsoleView *_consoleView;

    BOOL _pullDownRefreshEnabled;
    AGXWKWebViewRefreshView *_pullDownRefreshView;

    AGXProgressBar *_progressBar;
    CGFloat _progressWidth;
    BOOL _progressBarExtendedTranslucentBars;

    BOOL _autoCoordinateBackgroundColor;
    BOOL _autoRevealCurrentLocationHost;
    NSString *_currentLocationHostRevealFormat;

    UIScrollView *_contentInsetHelperScrollView;
}

- (AGX_INSTANCETYPE)initWithFrame:(CGRect)frame configuration:(WKWebViewConfiguration *)configuration {
    if AGX_EXPECT_T(self = [super initWithFrame:frame configuration:configuration]) {
        super.backgroundColor = UIColor.whiteColor;
        super.scrollView.backgroundColor = UIColor.clearColor;
        super.scrollView.keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag;

        _delegateForwarder = [[AGXWKWebViewNavigationDelegateForwarder alloc] init];
        _delegateForwarder.internalDelegate = self;
        super.navigationDelegate = _delegateForwarder;
        _currentRequest = nil;

        _javascriptBridge = [[AGXWKWebViewJavascriptBridge alloc] init];
        [configuration.userContentController
         addScriptMessageHandler:[_javascriptBridge scriptMessageHandlerProxy]
         name:[_javascriptBridge scriptMessageHandlerName]];

        _errorBridge = [[AGXWKWebViewErrorBridge alloc] init];
        [configuration.userContentController
         addScriptMessageHandler:[_errorBridge scriptMessageHandlerProxy]
         name:[_errorBridge scriptMessageHandlerName]];

        _consoleBridge = [[AGXWKWebViewConsoleBridge alloc] init];
        [configuration.userContentController
         addScriptMessageHandler:[_consoleBridge scriptMessageHandlerProxy]
         name:[_consoleBridge scriptMessageHandlerName]];

        _pullDownRefreshEnabled = NO;
        _pullDownRefreshView = [[AGXWKWebViewRefreshView alloc] init];
        _pullDownRefreshView.internalDelegate = self;

        _progressBar = [[AGXProgressBar alloc] init];
        [self addSubview:_progressBar];
        _progressWidth = 2;
        _progressBarExtendedTranslucentBars = NO;

        _autoCoordinateBackgroundColor = YES;
        _autoRevealCurrentLocationHost = YES;
        _currentLocationHostRevealFormat = nil;

        _contentInsetHelperScrollView = [[UIScrollView alloc] init];
        _contentInsetHelperScrollView.backgroundColor = UIColor.clearColor;
        if (@available(iOS 11.0, *)) {
            _contentInsetHelperScrollView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentAlways;
        } else {
            _contentInsetHelperScrollView.automaticallyAdjustsContentInsetByBars = YES;
        }
        _contentInsetHelperScrollView.delegate = self;
        [self addSubview:_contentInsetHelperScrollView];

#define REGISTER(HANDLER, SELECTOR) \
[_javascriptBridge registerHandlerName:@HANDLER target:self action:SELECTOR]

        REGISTER("reload", @selector(reload));
        REGISTER("stopLoading", @selector(stopLoading));
        REGISTER("goBack", @selector(goBack));
        REGISTER("goForward", @selector(goForward));
        REGISTER("canGoBack", @selector(canGoBack:));
        REGISTER("canGoForward", @selector(canGoForward:));
        REGISTER("isLoading", @selector(isLoading:));

        REGISTER("setBounces", @selector(setBounces:));
        REGISTER("setBounceHorizontal", @selector(setBounceHorizontal:));
        REGISTER("setBounceVertical", @selector(setBounceVertical:));
        REGISTER("setShowHorizontalScrollBar", @selector(setShowHorizontalScrollBar:));
        REGISTER("setShowVerticalScrollBar", @selector(setShowVerticalScrollBar:));
        REGISTER("scrollToTop", @selector(scrollToTop:));
        REGISTER("scrollToBottom", @selector(scrollToBottom:));

        REGISTER("containerInset", @selector(containerInset:));
        REGISTER("startPullDownRefresh", @selector(startPullDownRefresh));
        REGISTER("finishPullDownRefresh", @selector(finishPullDownRefresh));

        REGISTER("HUDMessage", @selector(HUDMessage:));
        REGISTER("HUDLoading", @selector(HUDLoading:));
        REGISTER("HUDLoaded", @selector(HUDLoaded));

        REGISTER("setTemporaryItem", @selector(setTemporaryItem:));
        REGISTER("temporaryItem", @selector(temporaryItem:));
        REGISTER("setPermanentItem", @selector(setPermanentItem:));
        REGISTER("permanentItem", @selector(permanentItem:));
        REGISTER("setImmortalItem", @selector(setImmortalItem:));
        REGISTER("immortalItem", @selector(immortalItem:));

#undef REGISTER

        [_errorBridge registerErrorHandlerTarget:
         self action:@selector(_consoleViewHandleErrorMessage:stack:)];
        [_consoleBridge registerLogHandlerTarget:
         self action:@selector(_consoleViewHandleLogLevel:content:stack:)];

        [configuration.userContentController addUserScript:[_javascriptBridge wrapperUserScript]];
        [configuration.userContentController addUserScript:[_errorBridge wrapperUserScript]];
        [configuration.userContentController addUserScript:[_consoleBridge wrapperUserScript]];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];

    _pullDownRefreshView.frame = AGX_CGRectMake
    (CGPointMake(0, -self.scrollView.bounds.size.height), self.scrollView.bounds.size);

    [self bringSubviewToFront:_progressBar];
    CGFloat contentInsetTop = self.containerContentInset.top;
    CGFloat y = _progressBarExtendedTranslucentBars ? 0 : contentInsetTop;
    CGFloat height = _progressBarExtendedTranslucentBars ? (contentInsetTop+_progressWidth) : _progressWidth;
    _progressBar.frame = CGRectMake(0, y, self.bounds.size.width, height);

    [self sendSubviewToBack:_contentInsetHelperScrollView];
    _contentInsetHelperScrollView.frame = self.scrollView.frame;

    [self bringSubviewToFront:_consoleView];
    _consoleView.frame = _contentInsetHelperScrollView.frame;
    _consoleView.layoutContentInset = self.containerContentInset;
}

- (void)setNavigationDelegate:(id<WKNavigationDelegate>)navigationDelegate {
    _delegateForwarder.externalDelegate = navigationDelegate;
}

- (id<WKNavigationDelegate>)navigationDelegate {
    return _delegateForwarder.externalDelegate;
}

- (void)dealloc {
    _contentInsetHelperScrollView.delegate = nil;
    AGX_RELEASE(_contentInsetHelperScrollView);

    AGX_RELEASE(_currentLocationHostRevealFormat);

    AGX_RELEASE(_progressBar);

    _pullDownRefreshView.delegate = nil;
    _pullDownRefreshView.internalDelegate = nil;
    AGX_RELEASE(_pullDownRefreshView);

    AGX_RELEASE(_consoleView);

    [self.configuration.userContentController
     removeScriptMessageHandlerForName:[_consoleBridge scriptMessageHandlerName]];
    AGX_RELEASE(_consoleBridge);

    [self.configuration.userContentController
     removeScriptMessageHandlerForName:[_errorBridge scriptMessageHandlerName]];
    AGX_RELEASE(_errorBridge);

    [self.configuration.userContentController
     removeScriptMessageHandlerForName:[_javascriptBridge scriptMessageHandlerName]];
    AGX_RELEASE(_javascriptBridge);

    AGX_RELEASE(_currentRequest);

    super.navigationDelegate = nil;
    _delegateForwarder.externalDelegate = nil;
    _delegateForwarder.internalDelegate = nil;
    AGX_RELEASE(_delegateForwarder);

    AGX_SUPER_DEALLOC;
}

#pragma mark - convenience request

- (void)loadRequestWithURLString:(NSString *)requestURLString {
    [self loadRequestWithURLString:requestURLString addHTTPHeaderFields:@{}];
}

- (void)loadRequestWithURLString:(NSString *)requestURLString cachePolicy:(NSURLRequestCachePolicy)cachePolicy {
    [self loadRequestWithURLString:requestURLString cachePolicy:cachePolicy addHTTPHeaderFields:@{}];
}

- (void)loadRequestWithURLString:(NSString *)requestURLString addHTTPHeaderFields:(NSDictionary *)HTTPHeaderFields {
    [self loadRequestWithURLString:requestURLString cachePolicy:NSURLRequestUseProtocolCachePolicy
               addHTTPHeaderFields:HTTPHeaderFields];
}

- (void)loadRequestWithURLString:(NSString *)requestURLString cachePolicy:(NSURLRequestCachePolicy)cachePolicy addHTTPHeaderFields:(NSDictionary *)HTTPHeaderFields {
    if AGX_EXPECT_F(AGXIsNilOrEmpty(requestURLString)) return;
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:requestURLString.stringEncodedForURL]
                                                           cachePolicy:cachePolicy timeoutInterval:60];
    NSMutableDictionary *allHTTPHeaderFields = [NSMutableDictionary dictionaryWithDictionary:HTTPHeaderFields];
    [allHTTPHeaderFields addEntriesFromDictionary:request.allHTTPHeaderFields];
    request.allHTTPHeaderFields = [NSDictionary dictionaryWithDictionary:allHTTPHeaderFields];
    [self loadRequest:request];
}

#pragma mark - convenience request with cookie

- (void)loadRequestWithURLString:(NSString *)requestURLString addCookieFieldWithNames:(NSArray *)cookieNames {
    [self loadRequestWithURLString:requestURLString addCookieFieldWithNames:cookieNames addHTTPHeaderFields:@{}];
}

- (void)loadRequestWithURLString:(NSString *)requestURLString cachePolicy:(NSURLRequestCachePolicy)cachePolicy addCookieFieldWithNames:(NSArray *)cookieNames {
    [self loadRequestWithURLString:requestURLString cachePolicy:cachePolicy
           addCookieFieldWithNames:cookieNames addHTTPHeaderFields:@{}];
}
- (void)loadRequestWithURLString:(NSString *)requestURLString addCookieFieldWithNames:(NSArray *)cookieNames addHTTPHeaderFields:(NSDictionary *)HTTPHeaderFields {
    [self loadRequestWithURLString:requestURLString cachePolicy:NSURLRequestUseProtocolCachePolicy
           addCookieFieldWithNames:cookieNames addHTTPHeaderFields:HTTPHeaderFields];
}

- (void)loadRequestWithURLString:(NSString *)requestURLString cachePolicy:(NSURLRequestCachePolicy)cachePolicy addCookieFieldWithNames:(NSArray *)cookieNames addHTTPHeaderFields:(NSDictionary *)HTTPHeaderFields {
    NSMutableDictionary *allHTTPHeaderFields = [NSMutableDictionary dictionaryWithDictionary:HTTPHeaderFields];
    allHTTPHeaderFields[@"Cookie"] = [NSHTTPCookieStorage.sharedHTTPCookieStorage
                                      cookieFieldForRequestHeaderWithNames:cookieNames];
    [self loadRequestWithURLString:requestURLString cachePolicy:cachePolicy addHTTPHeaderFields:allHTTPHeaderFields];
}

#pragma mark - convenience request for local resources file

- (void)loadRequestWithResourcesFilePathString:(NSString *)resourcesFilePathString resources:(AGXResources *)resources {
    if AGX_EXPECT_F(AGXIsNilOrEmpty(resourcesFilePathString)) return;
    NSArray *filePathComponents = [resourcesFilePathString arraySeparatedByString:@"?" filterEmpty:YES];
    if AGX_EXPECT_F(!resources.isExistsFileNamed(filePathComponents[0])) return;

    NSURL *fileURL = [NSURL URLWithString:[@"?" stringByAppendingObjects:filePathComponents[1]?:@"", nil]
                            relativeToURL:[NSURL fileURLWithPath:filePathComponents[0]]];
    [self loadRequest:[NSURLRequest requestWithURL:fileURL]];
}

- (void)loadRequestWithResourcesFilePathString:(NSString *)resourcesFilePathString resourcesPattern:(AGXResources *)resourcesPattern {
    if AGX_EXPECT_F(AGXIsNilOrEmpty(resourcesFilePathString)) return;
    NSArray *filePathComponents = [resourcesFilePathString arraySeparatedByString:@"?" filterEmpty:YES];
    NSString *filePath = (resourcesPattern.applyWithTemporary.isExistsFileNamed(filePathComponents[0]) ?
                          resourcesPattern.applyWithTemporary.pathWithFileNamed(filePathComponents[0]) :
                          (resourcesPattern.applyWithCaches.isExistsFileNamed(filePathComponents[0]) ?
                           resourcesPattern.applyWithCaches.pathWithFileNamed(filePathComponents[0]) :
                           (resourcesPattern.applyWithDocument.isExistsFileNamed(filePathComponents[0]) ?
                            resourcesPattern.applyWithDocument.pathWithFileNamed(filePathComponents[0]) :
                            (resourcesPattern.applyWithApplication.isExistsFileNamed(filePathComponents[0]) ?
                             resourcesPattern.applyWithApplication.pathWithFileNamed(filePathComponents[0]) : nil))));
    if AGX_EXPECT_F(!filePath) return;

    NSURL *fileURL = [NSURL URLWithString:[@"?" stringByAppendingObjects:filePathComponents[1]?:@"", nil]
                            relativeToURL:[NSURL fileURLWithPath:filePath]];
    [self loadRequest:[NSURLRequest requestWithURL:fileURL]];
}

#pragma mark - UIScrollViewDelegate: WKScrollView Delgate Forwarder

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (scrollView == self.scrollView) {
        if ([WKWebView instancesRespondToSelector:
             @selector(scrollViewDidScroll:)])
            [super scrollViewDidScroll:scrollView];
        [self pullDownRefreshViewDidScrollView:scrollView];
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    if (scrollView == self.scrollView) {
        if ([WKWebView instancesRespondToSelector:
             @selector(scrollViewDidEndDragging:willDecelerate:)])
            [super scrollViewDidEndDragging:scrollView willDecelerate:decelerate];
        [self pullDownRefreshViewDidEndDragging:scrollView];
    }
}

- (void)scrollViewDidChangeAdjustedContentInset:(UIScrollView *)scrollView {
    if (@available(iOS 11.0, *)) {
        if (scrollView == self.scrollView) {
            if ([WKWebView instancesRespondToSelector:
                 @selector(scrollViewDidChangeAdjustedContentInset:)]) {
                [super scrollViewDidChangeAdjustedContentInset:scrollView];
            }
        } else if (scrollView == _contentInsetHelperScrollView) {
            [self changedAdjustedContentInset];
        }
    }
}

- (void)scrollViewDidChangeAutomaticallyAdjustedContentInset:(UIScrollView *)scrollView {
    if (@available(iOS 11.0, *)) return;
    if (scrollView == self.scrollView) {
        if ([WKWebView instancesRespondToSelector:
             @selector(scrollViewDidChangeAutomaticallyAdjustedContentInset:)]) {
            [super scrollViewDidChangeAutomaticallyAdjustedContentInset:scrollView];
        }
    } else if (scrollView == _contentInsetHelperScrollView) {
        [self changedAdjustedContentInset];
    }
}

#pragma mark - WKNavigationDelegate

- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler {
    if (webView == self) {
        NSURLRequest *request = navigationAction.request;
        if ([request isNewRequestFromURL:self.URL]) {
            AGX_RELEASE(_currentRequest);
            _currentRequest = [navigationAction.request copy];
        }
    }

    if (![_delegateForwarder.externalDelegate respondsToSelector:
          @selector(webView:decidePolicyForNavigationAction:decisionHandler:)]) {
        !decisionHandler?:decisionHandler(WKNavigationActionPolicyAllow);
    }
}

- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation {
    if (webView == self) {
        [self coordinateBackgroundColor];
        [self revealCurrentLocationHost];
        [self finishPullDownRefresh];
    }
}

- (void)webView:(WKWebView *)webView didFailNavigation:(WKNavigation *)navigation withError:(NSError *)error {
    if (webView == self) {
        [self finishPullDownRefresh];
    }
}

#pragma mark - Javascript trigger register

AGX_STATIC long uniqueId = 0;

- (SEL)registerTriggerAt:(Class)triggerClass withBlock:(void (^)(id SELF, id sender))triggerBlock {
    SEL selector = NSSelectorFromString([NSString stringWithFormat:@"trigger_%ld:", ++uniqueId]);
    [triggerClass addInstanceMethodWithSelector:selector andBlock:triggerBlock andTypeEncoding:"v@:@"];
    return selector;
}

- (SEL)registerTriggerAt:(Class)triggerClass withJavascript:(NSString *)javascript {
    AGX_WEAKIFY(weakSelf, self);
    return [self registerTriggerAt:triggerClass withBlock:^(id SELF, id sender) {
        AGX_STRONGIFY(strongSelf, weakSelf);
        [strongSelf evaluateJavaScript:[NSString stringWithFormat:@";(%@)();", javascript]
                     completionHandler:NULL];
        AGX_UNSTRONGIFY(strongSelf);
    }];
}

- (SEL)registerTriggerAt:(Class)triggerClass withJavascript:(NSString *)javascript paramKeyPath:(NSString *)paramKeyPath, ... NS_REQUIRES_NIL_TERMINATION {
    return [self registerTriggerAt:triggerClass withJavascript:javascript paramKeyPaths:agx_va_list(paramKeyPath)];
}

- (SEL)registerTriggerAt:(Class)triggerClass withJavascript:(NSString *)javascript paramKeyPaths:(NSArray *)paramKeyPaths {
    AGX_WEAKIFY(weakSelf, self);
    return [self registerTriggerAt:triggerClass withBlock:^(id SELF, id sender) {
        AGX_STRONGIFY(strongSelf, weakSelf);
        NSMutableArray *paramValues = [NSMutableArray array];
        for (int i = 0; i < paramKeyPaths.count; i++) {
            NSString *keyPath = paramKeyPaths[i];
            if AGX_EXPECT_F(0 == keyPath.length) { [paramValues addObject:@"undefined"]; continue; }
            [paramValues addObject:[[SELF valueForKeyPath:keyPath] agxJsonString] ?: @"undefined"];
        }
        [strongSelf evaluateJavaScript:[NSString stringWithFormat:@";(%@)(%@);", javascript,
                                        [paramValues stringJoinedByString:@"," usingComparator:NULL filterEmpty:NO]]
                     completionHandler:NULL];
        AGX_UNSTRONGIFY(strongSelf);
    }];
}

#pragma mark - Javascript handler bridge register

- (void)registerHandlerName:(NSString *)handlerName target:(id)target action:(SEL)action {
    [_javascriptBridge registerHandlerName:handlerName target:target action:action];
}

- (void)registerHandlerName:(NSString *)handlerName target:(id)target action:(SEL)action scope:(NSString *)scope {
    [_javascriptBridge registerHandlerName:handlerName target:target action:action scope:scope];
}

- (void)reloadJavascriptBridgeUserScript {
    [self.configuration.userContentController addUserScript:[_javascriptBridge wrapperUserScript]];
}

#pragma mark - Error handler bridge register

- (void)registerErrorHandlerTarget:(id)target action:(SEL)action {
    [_errorBridge registerErrorHandlerTarget:target action:action];
}

#pragma mark - Console handler bridge register

- (AGXWKWebViewLogLevel)javascriptLogLevel {
    return _consoleBridge.javascriptLogLevel;
}

- (void)setJavascriptLogLevel:(AGXWKWebViewLogLevel)javascriptLogLevel {
    _consoleBridge.javascriptLogLevel = javascriptLogLevel;
    _consoleView.javascriptLogLevel = javascriptLogLevel;
}

+ (AGXWKWebViewLogLevel)javascriptLogLevel {
    return [[self appearance] javascriptLogLevel];
}

+ (void)setJavascriptLogLevel:(AGXWKWebViewLogLevel)javascriptLogLevel {
    [[self appearance] setJavascriptLogLevel:javascriptLogLevel];
}

- (void)registerLogHandlerTarget:(id)target action:(SEL)action {
    [_consoleBridge registerLogHandlerTarget:target action:action];
}

#pragma mark - Log Console

- (void)setShowLogConsole:(BOOL)showLogConsole {
    _showLogConsole = showLogConsole;

    if (_showLogConsole) {
        if (!_consoleView) {
            _consoleView = [[AGXWKWebViewConsoleView alloc] initWithLogLevel:
                            _consoleBridge.javascriptLogLevel];
            _consoleView.delegate = self;
        }
        [self addSubview:_consoleView];
    } else {
        [_consoleView removeFromSuperview];
        if (_consoleView) {
            AGX_RELEASE(_consoleView);
            _consoleView = nil;
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

#pragma mark - AGXWKWebViewConsoleViewDelegate

- (void)webViewConsoleView:(AGXWKWebViewConsoleView *)consoleView didSelectSegmentIndex:(NSInteger)index {
    if AGX_EXPECT_F(consoleView != _consoleView) return;
    _consoleBridge.javascriptLogLevel = index;
}

#pragma mark - Log Console handler

- (void)_consoleViewHandleErrorMessage:(NSString *)message stack:(NSArray *)stack {
    [_consoleView addLogLevel:AGXWKWebViewLogError message:message stack:stack];
}

- (void)_consoleViewHandleLogLevel:(AGXWKWebViewLogLevel)level content:(NSArray *)content stack:(NSArray *)stack {
    NSMutableArray *contentByJsonString = NSMutableArray.instance;
    [content enumerateObjectsUsingBlock:
     ^(id obj, NSUInteger idx, BOOL *stop) {
         [contentByJsonString addObject:[obj agxJsonString]];
     }];
    NSString *message = [contentByJsonString stringJoinedByString:
                         @", " usingComparator:NULL filterEmpty:NO];
    [_consoleView addLogLevel:level message:message stack:stack];
}

#pragma mark - PullDownRefresh

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
    if (_pullDownRefreshEnabled) {
        [self.scrollView scrollToTop:NO];
        [_pullDownRefreshView scrollViewFinishLoad:self.scrollView];
    }
}

#pragma mark - private PullDownRefresh called in UIScrollViewDelegate

- (void)pullDownRefreshViewDidScrollView:(UIScrollView *)scrollView {
    if (_pullDownRefreshEnabled) [_pullDownRefreshView didScrollView:scrollView];
}

- (void)pullDownRefreshViewDidEndDragging:(UIScrollView *)scrollView {
    if (_pullDownRefreshEnabled) [_pullDownRefreshView didEndDragging:scrollView];
}

#pragma mark - AGXRefreshViewDelegate

- (void)refreshViewStartLoad:(AGXRefreshView *)refreshView {
    if (!_pullDownRefreshEnabled) return;

    AGX_STATIC NSString *const doPullDownRefreshExistsJS =
    @"'function'==typeof doPullDownRefresh";
    AGX_STATIC NSString *const doPullDownRefreshJS =
    @";window.doPullDownRefresh&&window.doPullDownRefresh();";

    [self evaluateJavaScript:doPullDownRefreshExistsJS completionHandler:^(id result, NSError *error) {
        [result boolValue] ? [self evaluateJavaScript:doPullDownRefreshJS completionHandler:NULL] : [self reload];
    }];
}

#pragma mark - ProgressBar

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

- (void)updateProgressWhenEstimatedProgressChanged {
    float oldProgress = _progressBar.progress;
    float newProgress = self.estimatedProgress;
    [_progressBar setProgress:newProgress
                     animated:newProgress > oldProgress];
}

#pragma mark - Trigger webView:didFailNavigation:withError: when URL changed to nil

- (void)triggerFailNavigationWhenURLChangedNil {
    if (AGXIsNil(self.URL) && AGXIsNotNil(self.currentRequest)) {
        if ([_delegateForwarder respondsToSelector:@selector(webView:didFailNavigation:withError:)]) {
            [_delegateForwarder webView:self didFailNavigation:nil withError:
             [NSError errorWithDomain:@"AGXWKWebViewErrorDomain" code:-9999 description:
              @"AGXWKWebView Failed Navigation: %@", self.currentRequest.URL]];
        }
    }
}

#pragma mark - WKWebView key-value observing

- (void)didChangeValueForKey:(NSString *)key {
    if ([@"estimatedProgress" isEqualToString:key]) {
        [self updateProgressWhenEstimatedProgressChanged];
    } else if ([@"URL" isEqualToString:key]) {
        [self triggerFailNavigationWhenURLChangedNil];
    }
    [super didChangeValueForKey:key];
}

#pragma mark - private Extension features

- (void)coordinateBackgroundColor {
    if (_autoCoordinateBackgroundColor) {
        if (![super.scrollView.backgroundColor isEqualToColor:UIColor.clearColor]) {
            super.backgroundColor = super.scrollView.backgroundColor;
        }
    }
    super.scrollView.backgroundColor = UIColor.clearColor;
}

AGX_STATIC const NSInteger AGX_HOST_INDICATOR_TAG = 9151920;

- (void)revealCurrentLocationHost {
    if (_autoRevealCurrentLocationHost) {
        NSString *format = [_currentLocationHostRevealFormat containsString:@"%@"]
        ? _currentLocationHostRevealFormat : AGXWidgetLocalizedStringDefault
        (@"AGXWKWebView.currentLocationHostRevealFormat", @"Provided by: %@");
        NSString *locationHost = AGXIsNotEmpty(self.URL.host) ?
        [NSString stringWithFormat:format, self.URL.host] : @"";

        UILabel *hostIndicatorLabel = [self viewWithTag:AGX_HOST_INDICATOR_TAG];
        if (!hostIndicatorLabel) {
            hostIndicatorLabel = UILabel.instance;
            hostIndicatorLabel.tag = AGX_HOST_INDICATOR_TAG;
            hostIndicatorLabel.backgroundColor = UIColor.clearColor;
            hostIndicatorLabel.font = [UIFont systemFontOfSize:12];
            hostIndicatorLabel.textAlignment = NSTextAlignmentCenter;
            [self addSubview:hostIndicatorLabel];
        }
        [self sendSubviewToBack:hostIndicatorLabel];
        hostIndicatorLabel.frame = CGRectMake(0, self.containerContentInset.top+20,
                                              self.bounds.size.width, 24);

        AGXColorShade colorShade = super.backgroundColor.colorShade;
        hostIndicatorLabel.textColor = AGXColorShadeDark == colorShade ? UIColor.lightGrayColor :
        (AGXColorShadeLight == colorShade ? UIColor.darkGrayColor : UIColor.grayColor);
        hostIndicatorLabel.text = locationHost;
    }
}

- (void)changedAdjustedContentInset {
    [self setNeedsLayout];
    [self containerContentInsetDidChange];
    [self revealCurrentLocationHost];
}

#pragma mark - ContentInsetHelper

- (UIEdgeInsets)containerContentInset {
    return _contentInsetHelperScrollView.contentInsetIncorporated;
}

- (void)containerContentInsetDidChange {
    AGX_STATIC NSString *const containerInsetDidChangeJSFormat =
    @";window.containerInsetDidChange&&window.containerInsetDidChange(%@);";
    [self evaluateJavaScript:[NSString stringWithFormat:containerInsetDidChangeJSFormat,
                              [self.containerInset agxJsonString]] completionHandler:NULL];
}

- (id)containerInset {
    return [[NSValue valueWithUIEdgeInsets:self.containerContentInset] validJsonObjectForUIEdgeInsets];
}

#pragma mark - WKWebView bridge handler

- (WKNavigation *)reload {
    NSString *viewURL = self.URL.absoluteString;
    if (AGXIsNotEmpty(viewURL)) return [super reload];
    else return [self loadRequest:self.currentRequest];
}

- (void)canGoBack:(NSDictionary *)params {
    NSString *callback = [params itemForKey:@"callback"];
    if AGX_EXPECT_F(AGXIsNilOrEmpty(callback)) return;
    NSString *javascript = [NSString stringWithFormat:@";(%@)(%d);",
                            callback, self.canGoBack];
    [self evaluateJavaScript:javascript completionHandler:NULL];
}

- (void)canGoForward:(NSDictionary *)params {
    NSString *callback = [params itemForKey:@"callback"];
    if AGX_EXPECT_F(AGXIsNilOrEmpty(callback)) return;
    NSString *javascript = [NSString stringWithFormat:@";(%@)(%d);",
                            callback, self.canGoForward];
    [self evaluateJavaScript:javascript completionHandler:NULL];
}

- (void)isLoading:(NSDictionary *)params {
    NSString *callback = [params itemForKey:@"callback"];
    if AGX_EXPECT_F(AGXIsNilOrEmpty(callback)) return;
    NSString *javascript = [NSString stringWithFormat:@";(%@)(%d);",
                            callback, self.isLoading];
    [self evaluateJavaScript:javascript completionHandler:NULL];
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

- (void)scrollToTop:(BOOL)animated {
    [self.scrollView scrollToTop:animated];
}

- (void)scrollToBottom:(BOOL)animated {
    [self.scrollView scrollToBottom:animated];
}

#pragma mark - AGXWKWebView bridge handler

- (void)containerInset:(NSDictionary *)params {
    NSString *callback = [params itemForKey:@"callback"];
    if AGX_EXPECT_F(AGXIsNilOrEmpty(callback)) return;
    NSString *javascript = [NSString stringWithFormat:@";(%@)(%@);",
                            callback, [self.containerInset agxJsonString]];
    [self evaluateJavaScript:javascript completionHandler:NULL];
}

#pragma mark - ProgressHUD bridge handler

- (void)HUDMessage:(NSDictionary *)setting {
    NSString *title = [setting itemForKey:@"title"], *message = [setting itemForKey:@"message"];
    if AGX_EXPECT_F(AGXIsNilOrEmpty(title) && AGXIsNilOrEmpty(message)) return;
    NSTimeInterval delay = [([setting itemForKey:@"delay"]?:@2) timeIntervalValue];
    BOOL fullScreen = [([setting itemForKey:@"fullScreen"]?:@NO) boolValue];
    BOOL opaque = [([setting itemForKey:@"opaque"]?:@YES) boolValue];
    UIView *view = fullScreen ? UIApplication.sharedKeyWindow : self;
    [view showMessageHUD:opaque title:title detail:message duration:delay];
}

- (void)HUDLoading:(NSDictionary *)setting {
    NSString *title = [setting itemForKey:@"title"], *message = [setting itemForKey:@"message"];
    BOOL fullScreen = [([setting itemForKey:@"fullScreen"]?:@NO) boolValue];
    BOOL opaque = [([setting itemForKey:@"opaque"]?:@YES) boolValue];
    UIView *view = fullScreen ? UIApplication.sharedKeyWindow : self;
    [view showLoadingHUD:opaque title:title detail:message];
}

- (void)HUDLoaded {
    [UIApplication.sharedKeyWindow hideRecursiveHUD];
}

#pragma mark - AGXData bridge hander

- (void)setTemporaryItem:(NSDictionary *)params {
    NSString *key = [params itemForKey:@"key"];
    if AGX_EXPECT_F(AGXIsNilOrEmpty(key)) return;
    id value = [params itemForKey:@"value"];
    if AGX_EXPECT_F(AGXIsNil(value)) return;

    [AGXWKWebViewDataBox.shareInstance.temporary setValue:value forKey:key];
    [AGXWKWebViewDataBox.shareInstance synchronize];
}

- (void)temporaryItem:(NSDictionary *)params {
    NSString *key = [params itemForKey:@"key"];
    if AGX_EXPECT_F(AGXIsNilOrEmpty(key)) return;
    NSString *callback = [params itemForKey:@"callback"];
    if AGX_EXPECT_F(AGXIsNilOrEmpty(callback)) return;

    id value = [AGXWKWebViewDataBox.shareInstance.temporary itemForKey:key];
    NSString *javascript = [NSString stringWithFormat:@";(%@)(%@);",
                            callback, [value agxJsonString]];
    [self evaluateJavaScript:javascript completionHandler:NULL];
}

- (void)setPermanentItem:(NSDictionary *)params {
    NSString *key = [params itemForKey:@"key"];
    if AGX_EXPECT_F(AGXIsNilOrEmpty(key)) return;
    id value = [params itemForKey:@"value"];
    if AGX_EXPECT_F(AGXIsNil(value)) return;

    [AGXWKWebViewDataBox.shareInstance.permanent setValue:value forKey:key];
    [AGXWKWebViewDataBox.shareInstance synchronize];
}

- (void)permanentItem:(NSDictionary *)params {
    NSString *key = [params itemForKey:@"key"];
    if AGX_EXPECT_F(AGXIsNilOrEmpty(key)) return;
    NSString *callback = [params itemForKey:@"callback"];
    if AGX_EXPECT_F(AGXIsNilOrEmpty(callback)) return;

    id value = [AGXWKWebViewDataBox.shareInstance.permanent itemForKey:key];
    NSString *javascript = [NSString stringWithFormat:@";(%@)(%@);",
                            callback, [value agxJsonString]];
    [self evaluateJavaScript:javascript completionHandler:NULL];
}

- (void)setImmortalItem:(NSDictionary *)params {
    NSString *key = [params itemForKey:@"key"];
    if AGX_EXPECT_F(AGXIsNilOrEmpty(key)) return;
    id value = [params itemForKey:@"value"];
    if AGX_EXPECT_F(AGXIsNil(value)) return;

    [AGXWKWebViewDataBox.shareInstance.immortal setValue:value forKey:key];
    [AGXWKWebViewDataBox.shareInstance synchronize];
}

- (void)immortalItem:(NSDictionary *)params {
    NSString *key = [params itemForKey:@"key"];
    if AGX_EXPECT_F(AGXIsNilOrEmpty(key)) return;
    NSString *callback = [params itemForKey:@"callback"];
    if AGX_EXPECT_F(AGXIsNilOrEmpty(callback)) return;

    id value = [AGXWKWebViewDataBox.shareInstance.immortal itemForKey:key];
    NSString *javascript = [NSString stringWithFormat:@";(%@)(%@);",
                            callback, [value agxJsonString]];
    [self evaluateJavaScript:javascript completionHandler:NULL];
}

@end
