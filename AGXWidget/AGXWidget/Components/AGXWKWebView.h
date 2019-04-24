//
//  AGXWKWebView.h
//  AGXWidget
//
//  Created by Char Aznable on 2019/4/17.
//  Copyright © 2019 github.com/CharLemAznable. All rights reserved.
//

#ifndef AGXWidget_AGXWKWebView_h
#define AGXWidget_AGXWKWebView_h

#import <UIKit/UIKit.h>
#import <WebKit/WebKit.h>
#import <AGXCore/AGXCore/AGXArc.h>
#import <AGXCore/AGXCore/AGXResources.h>
#import "AGXWKWebViewLogLevel.h"

@class AGXRefreshView;

AGX_EXTERN NSString *AGXWKBridgeInjectJSObjectName;   // AGXB

@interface AGXWKWebView : WKWebView
#pragma mark - convenience request
- (void)loadRequestWithURLString:(NSString *)requestURLString;
- (void)loadRequestWithURLString:(NSString *)requestURLString cachePolicy:(NSURLRequestCachePolicy)cachePolicy;
- (void)loadRequestWithURLString:(NSString *)requestURLString addHTTPHeaderFields:(NSDictionary *)HTTPHeaderFields;
- (void)loadRequestWithURLString:(NSString *)requestURLString cachePolicy:(NSURLRequestCachePolicy)cachePolicy addHTTPHeaderFields:(NSDictionary *)HTTPHeaderFields;

#pragma mark - convenience request with cookie
- (void)loadRequestWithURLString:(NSString *)requestURLString addCookieFieldWithNames:(NSArray *)cookieNames;
- (void)loadRequestWithURLString:(NSString *)requestURLString cachePolicy:(NSURLRequestCachePolicy)cachePolicy addCookieFieldWithNames:(NSArray *)cookieNames;
- (void)loadRequestWithURLString:(NSString *)requestURLString addCookieFieldWithNames:(NSArray *)cookieNames addHTTPHeaderFields:(NSDictionary *)HTTPHeaderFields;
- (void)loadRequestWithURLString:(NSString *)requestURLString cachePolicy:(NSURLRequestCachePolicy)cachePolicy addCookieFieldWithNames:(NSArray *)cookieNames addHTTPHeaderFields:(NSDictionary *)HTTPHeaderFields;

#pragma mark - convenience request for local resources file
- (void)loadRequestWithResourcesFilePathString:(NSString *)resourcesFilePathString resources:(AGXResources *)resources;
- (void)loadRequestWithResourcesFilePathString:(NSString *)resourcesFilePathString resourcesPattern:(AGXResources *)resourcesPattern;

@property (nonatomic, readonly) NSURLRequest *currentRequest;

- (SEL)registerTriggerAt:(Class)triggerClass withBlock:(void (^)(id SELF, id sender))triggerBlock;
- (SEL)registerTriggerAt:(Class)triggerClass withJavascript:(NSString *)javascript;
- (SEL)registerTriggerAt:(Class)triggerClass withJavascript:(NSString *)javascript paramKeyPath:(NSString *)paramKeyPath, ... NS_REQUIRES_NIL_TERMINATION;
- (SEL)registerTriggerAt:(Class)triggerClass withJavascript:(NSString *)javascript paramKeyPaths:(NSArray *)paramKeyPaths;

- (void)registerHandlerName:(NSString *)handlerName target:(id)target action:(SEL)action;
- (void)registerHandlerName:(NSString *)handlerName target:(id)target action:(SEL)action scope:(NSString *)scope;
- (void)reloadJavascriptBridgeUserScript;

// handler selector should have the form:
// - (void)xxx:(NSString *)message xxx:(NSArray *)stack
- (void)registerErrorHandlerTarget:(id)target action:(SEL)action;

@property (nonatomic, assign) AGXWKWebViewLogLevel javascriptLogLevel UI_APPEARANCE_SELECTOR; // default AGXWebViewLogInfo
+ (AGXWKWebViewLogLevel)javascriptLogLevel;
+ (void)setJavascriptLogLevel:(AGXWKWebViewLogLevel)javascriptLogLevel;

// handler selector should have the form:
// - (void)xxx:(AGXWKWebViewLogLevel)level xxx:(NSArray *)content xxx:(NSArray *)stack
- (void)registerLogHandlerTarget:(id)target action:(SEL)action;

@property (nonatomic, assign)       BOOL                showLogConsole UI_APPEARANCE_SELECTOR; // default NO
+ (BOOL)showLogConsole;
+ (void)setShowLogConsole:(BOOL)showLogConsole;

@property (nonatomic, assign)       BOOL                pullDownRefreshEnabled; // default NO
@property (nonatomic, readonly)     AGXRefreshView      *pullDownRefreshView; // default [self reload]
- (void)startPullDownRefresh;
- (void)finishPullDownRefresh;

@property (nonatomic, AGX_STRONG)   UIColor             *progressColor UI_APPEARANCE_SELECTOR; // default 167efb
+ (UIColor *)progressColor;
+ (void)setProgressColor:(UIColor *)progressColor;
@property (nonatomic, assign)       CGFloat             progressWidth UI_APPEARANCE_SELECTOR; // default 2
+ (CGFloat)progressWidth;
+ (void)setProgressWidth:(CGFloat)progressWidth;
@property (nonatomic, assign)       BOOL                progressBarExtendedTranslucentBars UI_APPEARANCE_SELECTOR; // default NO
+ (BOOL)progressBarExtendedTranslucentBars;
+ (void)setProgressBarExtendedTranslucentBars:(BOOL)progressBarExtendedTranslucentBars;

@property (nonatomic, assign)       BOOL                autoCoordinateBackgroundColor; // default YES
@property (nonatomic, assign)       BOOL                autoRevealCurrentLocationHost; // default YES
@property (nonatomic, AGX_STRONG)   NSString            *currentLocationHostRevealFormat; // default "Provided by: %@"

@property (nonatomic, readonly)     UIEdgeInsets        containerContentInset;
- (void)containerContentInsetDidChange;
- (id)containerInset;

#pragma mark - WKWebView bridge handler
/* declaration&implementation in super class
- (void)reload;
- (void)stopLoading;
- (void)goBack;
- (void)goForward; */
- (void)canGoBack:(NSDictionary *)params;
- (void)canGoForward:(NSDictionary *)params;
- (void)isLoading:(NSDictionary *)params;
- (void)setBounces:(BOOL)bounces;
- (void)setBounceHorizontal:(BOOL)bounceHorizontal;
- (void)setBounceVertical:(BOOL)bounceVertical;
- (void)setShowHorizontalScrollBar:(BOOL)showHorizontalScrollBar;
- (void)setShowVerticalScrollBar:(BOOL)showVerticalScrollBar;
- (void)scrollToTop:(BOOL)animated;
- (void)scrollToBottom:(BOOL)animated;

#pragma mark - AGXWKWebView bridge handler
- (void)containerInset:(NSDictionary *)params;
/*
- (void)startPullDownRefresh;
- (void)finishPullDownRefresh; */

#pragma mark - ProgressHUD bridge handler
- (void)HUDMessage:(NSDictionary *)setting; // { "title":string, "message":string, "delay":float, "fullScreen":bool, "opaque":bool }
- (void)HUDLoading:(NSDictionary *)setting; // { "title":string, "message":string, "fullScreen":bool, "opaque":bool }
- (void)HUDLoaded;

#pragma mark - AGXData bridge hander
- (void)setTemporaryItem:(NSDictionary *)params;
- (void)temporaryItem:(NSDictionary *)params;
- (void)setPermanentItem:(NSDictionary *)params;
- (void)permanentItem:(NSDictionary *)params;
- (void)setImmortalItem:(NSDictionary *)params;
- (void)immortalItem:(NSDictionary *)params;
@end

#endif /* AGXWidget_AGXWKWebView_h */
