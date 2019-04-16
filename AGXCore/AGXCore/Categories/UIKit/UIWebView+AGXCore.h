//
//  UIWebView+AGXCore.h
//  AGXCore
//
//  Created by Char Aznable on 2016/7/6.
//  Copyright © 2016 github.com/CharLemAznable. All rights reserved.
//

#ifndef AGXCore_UIWebView_AGXCore_h
#define AGXCore_UIWebView_AGXCore_h

#import <UIKit/UIKit.h>
#import "AGXCategory.h"
#import "AGXResources.h"

@category_interface(UIWebView, AGXCore)
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

#pragma mark - fetch cookies for current request URL
- (NSArray<NSHTTPCookie *> *)cookiesWithNames:(NSArray<NSString *> *)cookieNames;
- (NSString *)cookieFieldForRequestHeaderWithNames:(NSArray<NSString *> *)cookieNames;
- (NSDictionary<NSString *, NSString *> *)cookieValuesWithNames:(NSArray<NSString *> *)cookieNames;

- (NSHTTPCookie *)cookieWithName:(NSString *)cookieName;
- (NSString *)cookieFieldForRequestHeaderWithName:(NSString *)cookieName;
- (NSString *)cookieValueWithName:(NSString *)cookieName;

#pragma mark - convenience request for local resources file
- (void)loadRequestWithResourcesFilePathString:(NSString *)resourcesFilePathString resources:(AGXResources *)resources;
- (void)loadRequestWithResourcesFilePathString:(NSString *)resourcesFilePathString resourcesPattern:(AGXResources *)resourcesPattern;

#pragma mark - user agent setting
- (NSString *)userAgent;
+ (NSString *)userAgent;

+ (void)setUserAgent:(NSString *)userAgent;
+ (void)addUserAgent:(NSString *)userAgent;

- (UIView *)browserView; // access UIWebBrowserView

@property (nonatomic, copy) void (^webViewDidScroll)(UIWebView *webView);
@property (nonatomic, copy) void (^webViewDidZoom)(UIWebView *webView);
@property (nonatomic, copy) void (^webViewWillBeginDragging)(UIWebView *webView);
@property (nonatomic, copy) void (^webViewWillEndDraggingWithVelocityTargetContentOffset)(UIWebView *webView, CGPoint velocity, CGPoint *targetContentOffset);
@property (nonatomic, copy) void (^webViewDidEndDraggingWillDecelerate)(UIWebView *webView, BOOL decelerate);
@property (nonatomic, copy) void (^webViewWillBeginDecelerating)(UIWebView *webView);
@property (nonatomic, copy) void (^webViewDidEndDecelerating)(UIWebView *webView);
@property (nonatomic, copy) void (^webViewDidEndScrollingAnimation)(UIWebView *webView);
@property (nonatomic, copy) UIView *(^viewForZoomingInWebView)(UIWebView *webView);
@property (nonatomic, copy) void (^webViewWillBeginZoomingWithView)(UIWebView *webView, UIView *view);
@property (nonatomic, copy) void (^webViewDidEndZoomingWithViewAtScale)(UIWebView *webView, UIView *view, CGFloat scale);
@property (nonatomic, copy) BOOL (^webViewShouldScrollToTop)(UIWebView *webView);
@property (nonatomic, copy) void (^webViewDidScrollToTop)(UIWebView *webView);
@property (nonatomic, copy) void (^webViewDidChangeAdjustedContentInset)(UIWebView *webView);
@property (nonatomic, copy) void (^webViewDidChangeAutomaticallyAdjustedContentInset)(UIWebView *webView);
@end

#endif /* AGXCore_UIWebView_AGXCore_h */
