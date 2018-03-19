//
//  UIWebView+AGXCore.m
//  AGXCore
//
//  Created by Char Aznable on 2016/7/6.
//  Copyright © 2016年 AI-CUC-EC. All rights reserved.
//

#import "UIWebView+AGXCore.h"
#import "AGXArc.h"
#import "NSObject+AGXCore.h"
#import "NSString+AGXCore.h"
#import "NSHTTPCookieStorage+AGXCore.h"

typedef void (^AGXBlockKitHandler)(UIWebView *webView);
typedef void (^AGXBlockKitHandlerWithVelocityTargetContentOffset)(UIWebView *webView, CGPoint velocity, CGPoint *targetContentOffset);
typedef void (^AGXBlockKitHandlerWithDecelerate)(UIWebView *webView, BOOL decelerate);
typedef UIView *(^AGXBlockKitHandlerWithViewForZooming)(UIWebView *webView);
typedef void (^AGXBlockKitHandlerWithView)(UIWebView *webView, UIView *view);
typedef void (^AGXBlockKitHandlerWithViewAtScale)(UIWebView *webView, UIView *view, CGFloat scale);
typedef BOOL (^AGXBlockKitHandlerWithShouldScrollToTop)(UIWebView *webView);

@interface AGXWebViewScrollDelegateInternalBlockKit : NSObject <UIScrollViewDelegate>
@property (nonatomic, AGX_WEAK) UIWebView *webView;
@property (nonatomic, copy) AGXBlockKitHandler webViewDidScroll;
@property (nonatomic, copy) AGXBlockKitHandler webViewDidZoom;
@property (nonatomic, copy) AGXBlockKitHandler webViewWillBeginDragging;
@property (nonatomic, copy) AGXBlockKitHandlerWithVelocityTargetContentOffset webViewWillEndDraggingWithVelocityTargetContentOffset;
@property (nonatomic, copy) AGXBlockKitHandlerWithDecelerate webViewDidEndDraggingWillDecelerate;
@property (nonatomic, copy) AGXBlockKitHandler webViewWillBeginDecelerating;
@property (nonatomic, copy) AGXBlockKitHandler webViewDidEndDecelerating;
@property (nonatomic, copy) AGXBlockKitHandler webViewDidEndScrollingAnimation;
@property (nonatomic, copy) AGXBlockKitHandlerWithViewForZooming viewForZoomingInWebView;
@property (nonatomic, copy) AGXBlockKitHandlerWithView webViewWillBeginZoomingWithView;
@property (nonatomic, copy) AGXBlockKitHandlerWithViewAtScale webViewDidEndZoomingWithViewAtScale;
@property (nonatomic, copy) AGXBlockKitHandlerWithShouldScrollToTop webViewShouldScrollToTop;
@property (nonatomic, copy) AGXBlockKitHandler webViewDidScrollToTop;
@property (nonatomic, copy) AGXBlockKitHandler webViewDidChangeAdjustedContentInset;
@end

@interface AGXWebViewScrollDelegateAGXCoreDummy : NSObject
@end

@category_implementation(UIWebView, AGXCore)

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
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:requestURLString]
                                                           cachePolicy:cachePolicy timeoutInterval:60];
    request.allHTTPHeaderFields = [NSDictionary dictionaryWithDictionary:HTTPHeaderFields];
    [self loadRequest:request];
}

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

- (NSArray<NSHTTPCookie *> *)cookiesWithNames:(NSArray<NSString *> *)cookieNames {
    return [NSHTTPCookieStorage.sharedHTTPCookieStorage
            cookiesWithNames:cookieNames forURLString:self.request.URL.absoluteString];
}

- (NSString *)cookieFieldForRequestHeaderWithNames:(NSArray<NSString *> *)cookieNames {
    return [NSHTTPCookieStorage.sharedHTTPCookieStorage
            cookieFieldForRequestHeaderWithNames:cookieNames forURLString:self.request.URL.absoluteString];
}

- (NSDictionary<NSString *, NSString *> *)cookieValuesWithNames:(NSArray<NSString *> *)cookieNames {
    return [NSHTTPCookieStorage.sharedHTTPCookieStorage
            cookieValuesWithNames:cookieNames forURLString:self.request.URL.absoluteString];
}

- (NSHTTPCookie *)cookieWithName:(NSString *)cookieName {
    return [NSHTTPCookieStorage.sharedHTTPCookieStorage
            cookieWithName:cookieName forURLString:self.request.URL.absoluteString];
}

- (NSString *)cookieFieldForRequestHeaderWithName:(NSString *)cookieName {
    return [NSHTTPCookieStorage.sharedHTTPCookieStorage
            cookieFieldForRequestHeaderWithName:cookieName forURLString:self.request.URL.absoluteString];
}

- (NSString *)cookieValueWithName:(NSString *)cookieName {
    return [NSHTTPCookieStorage.sharedHTTPCookieStorage
            cookieValueWithName:cookieName forURLString:self.request.URL.absoluteString];
}

- (void)loadRequestWithResourcesFilePathString:(NSString *)resourcesFilePathString resources:(AGXResources *)resources {
    if AGX_EXPECT_F(AGXIsNilOrEmpty(resourcesFilePathString)) return;
    NSArray *filePathComponents = [resourcesFilePathString arraySeparatedByString:@"?" filterEmpty:YES];
    [self loadRequestWithURLString:[(resources.isExistsFileNamed(filePathComponents[0]) ?
                                     resources.pathWithFileNamed(filePathComponents[0]) : nil)
                                    stringByAppendingObjects:@"?", filePathComponents[1]?:@"", nil]];
}

- (void)loadRequestWithResourcesFilePathString:(NSString *)resourcesFilePathString resourcesPattern:(AGXResources *)resourcesPattern {
    if AGX_EXPECT_F(AGXIsNilOrEmpty(resourcesFilePathString)) return;
    NSArray *filePathComponents = [resourcesFilePathString arraySeparatedByString:@"?" filterEmpty:YES];
    [self loadRequestWithURLString:[(resourcesPattern.applyWithTemporary.isExistsFileNamed(filePathComponents[0]) ?
                                     resourcesPattern.applyWithTemporary.pathWithFileNamed(filePathComponents[0]) :
                                     (resourcesPattern.applyWithCaches.isExistsFileNamed(filePathComponents[0]) ?
                                      resourcesPattern.applyWithCaches.pathWithFileNamed(filePathComponents[0]) :
                                      (resourcesPattern.applyWithDocument.isExistsFileNamed(filePathComponents[0]) ?
                                       resourcesPattern.applyWithDocument.pathWithFileNamed(filePathComponents[0]) :
                                       (resourcesPattern.applyWithApplication.isExistsFileNamed(filePathComponents[0]) ?
                                        resourcesPattern.applyWithApplication.pathWithFileNamed(filePathComponents[0]) : nil))))
                                    stringByAppendingObjects:@"?", filePathComponents[1]?:@"", nil]];
}

- (NSString *)userAgent {
    return [self stringByEvaluatingJavaScriptFromString:@"navigator.userAgent"];
}

+ (NSString *)userAgent {
    return UIWebView.instance.userAgent;
}

+ (void)setUserAgent:(NSString *)userAgent {
    [NSUserDefaults.standardUserDefaults registerDefaults:@{@"UserAgent": userAgent}];
}

+ (void)addUserAgent:(NSString *)userAgent {
    [UIWebView setUserAgent:[NSString stringWithFormat:@"%@ %@", UIWebView.userAgent, userAgent]];
}

#define BlockKitGetterSetter(type, name, capitalizedName)               \
- (type)name { return self.blockKit.name; }                             \
- (void)set##capitalizedName:(type)name { self.blockKit.name = name; }

BlockKitGetterSetter(AGXBlockKitHandler, webViewDidScroll, WebViewDidScroll)
BlockKitGetterSetter(AGXBlockKitHandler, webViewDidZoom, WebViewDidZoom)
BlockKitGetterSetter(AGXBlockKitHandler, webViewWillBeginDragging, WebViewWillBeginDragging)
BlockKitGetterSetter(AGXBlockKitHandlerWithVelocityTargetContentOffset, webViewWillEndDraggingWithVelocityTargetContentOffset, WebViewWillEndDraggingWithVelocityTargetContentOffset)
BlockKitGetterSetter(AGXBlockKitHandlerWithDecelerate, webViewDidEndDraggingWillDecelerate, WebViewDidEndDraggingWillDecelerate)
BlockKitGetterSetter(AGXBlockKitHandler, webViewWillBeginDecelerating, WebViewWillBeginDecelerating)
BlockKitGetterSetter(AGXBlockKitHandler, webViewDidEndDecelerating, WebViewDidEndDecelerating)
BlockKitGetterSetter(AGXBlockKitHandler, webViewDidEndScrollingAnimation, WebViewDidEndScrollingAnimation)
BlockKitGetterSetter(AGXBlockKitHandlerWithViewForZooming, viewForZoomingInWebView, ViewForZoomingInWebView)
BlockKitGetterSetter(AGXBlockKitHandlerWithView, webViewWillBeginZoomingWithView, WebViewWillBeginZoomingWithView)
BlockKitGetterSetter(AGXBlockKitHandlerWithViewAtScale, webViewDidEndZoomingWithViewAtScale, WebViewDidEndZoomingWithViewAtScale)
BlockKitGetterSetter(AGXBlockKitHandlerWithShouldScrollToTop, webViewShouldScrollToTop, WebViewShouldScrollToTop)
BlockKitGetterSetter(AGXBlockKitHandler, webViewDidScrollToTop, WebViewDidScrollToTop)
BlockKitGetterSetter(AGXBlockKitHandler, webViewDidChangeAdjustedContentInset, WebViewDidChangeAdjustedContentInset)

#undef BlockKitGetterSetter

NSString *const agxWebViewScrollDelegateInternalBlockKitKey = @"agxWebViewScrollDelegateInternalBlockKit";

- (AGXWebViewScrollDelegateInternalBlockKit *)blockKit {
    if (![self retainPropertyForAssociateKey:agxWebViewScrollDelegateInternalBlockKitKey]) {
        AGXWebViewScrollDelegateInternalBlockKit *blockKit = AGXWebViewScrollDelegateInternalBlockKit.instance;
        blockKit.webView = self;
        [self setRetainProperty:blockKit forAssociateKey:agxWebViewScrollDelegateInternalBlockKitKey];
    }
    return [self retainPropertyForAssociateKey:agxWebViewScrollDelegateInternalBlockKitKey];
}

- (void)AGXCore_UIWebView_dealloc {
    [self setRetainProperty:NULL forAssociateKey:agxWebViewScrollDelegateInternalBlockKitKey];
    [self AGXCore_UIWebView_dealloc];
}

+ (void)load {
    agx_once
    ([UIWebView swizzleInstanceOriSelector:NSSelectorFromString(@"dealloc")
                           withNewSelector:@selector(AGXCore_UIWebView_dealloc)];)
}

@end

@implementation AGXWebViewScrollDelegateInternalBlockKit

- (void)dealloc {
    _webView = nil;
    AGX_BLOCK_RELEASE(_webViewDidScroll);
    AGX_BLOCK_RELEASE(_webViewDidZoom);
    AGX_BLOCK_RELEASE(_webViewWillBeginDragging);
    AGX_BLOCK_RELEASE(_webViewWillEndDraggingWithVelocityTargetContentOffset);
    AGX_BLOCK_RELEASE(_webViewDidEndDraggingWillDecelerate);
    AGX_BLOCK_RELEASE(_webViewWillBeginDecelerating);
    AGX_BLOCK_RELEASE(_webViewDidEndDecelerating);
    AGX_BLOCK_RELEASE(_webViewDidEndScrollingAnimation);
    AGX_BLOCK_RELEASE(_viewForZoomingInWebView);
    AGX_BLOCK_RELEASE(_webViewWillBeginZoomingWithView);
    AGX_BLOCK_RELEASE(_webViewDidEndZoomingWithViewAtScale);
    AGX_BLOCK_RELEASE(_webViewShouldScrollToTop);
    AGX_BLOCK_RELEASE(_webViewDidScrollToTop);
    AGX_BLOCK_RELEASE(_webViewDidChangeAdjustedContentInset);
    AGX_SUPER_DEALLOC;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    !_webViewDidScroll ?: _webViewDidScroll(_webView);
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView {
    !_webViewDidZoom ?: _webViewDidZoom(_webView);
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    !_webViewWillBeginDragging ?: _webViewWillBeginDragging(_webView);
}

- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset {
    !_webViewWillEndDraggingWithVelocityTargetContentOffset ?: _webViewWillEndDraggingWithVelocityTargetContentOffset(_webView, velocity, targetContentOffset);
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    !_webViewDidEndDraggingWillDecelerate ?: _webViewDidEndDraggingWillDecelerate(_webView, decelerate);
}

- (void)scrollViewWillBeginDecelerating:(UIScrollView *)scrollView {
    !_webViewWillBeginDecelerating ?: _webViewWillBeginDecelerating(_webView);
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    !_webViewDidEndDecelerating ?: _webViewDidEndDecelerating(_webView);
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView {
    !_webViewDidEndScrollingAnimation ?: _webViewDidEndScrollingAnimation(_webView);
}

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return !_viewForZoomingInWebView ? nil : _viewForZoomingInWebView(_webView);
}

- (void)scrollViewWillBeginZooming:(UIScrollView *)scrollView withView:(UIView *)view {
    !_webViewWillBeginZoomingWithView ?: _webViewWillBeginZoomingWithView(_webView, view);
}

- (void)scrollViewDidEndZooming:(UIScrollView *)scrollView withView:(UIView *)view atScale:(CGFloat)scale {
    !_webViewDidEndZoomingWithViewAtScale ?: _webViewDidEndZoomingWithViewAtScale(_webView, view, scale);
}

- (BOOL)scrollViewShouldScrollToTop:(UIScrollView *)scrollView {
    return !_webViewShouldScrollToTop ? YES : _webViewShouldScrollToTop(_webView);
}

- (void)scrollViewDidScrollToTop:(UIScrollView *)scrollView {
    !_webViewDidScrollToTop ?: _webViewDidScrollToTop(_webView);
}

- (void)scrollViewDidChangeAdjustedContentInset:(UIScrollView *)scrollView {
    !_webViewDidChangeAdjustedContentInset ?: _webViewDidChangeAdjustedContentInset(_webView);
}

- (BOOL)respondsToSelector:(SEL)aSelector {
    if (@selector(scrollViewDidScroll:) == aSelector) {
        return(_webViewDidScroll != NULL);
    } else if (@selector(scrollViewDidZoom:) == aSelector) {
        return(_webViewDidZoom != NULL);
    } else if (@selector(scrollViewWillBeginDragging:) == aSelector) {
        return(_webViewWillBeginDragging != NULL);
    } else if (@selector(scrollViewWillEndDragging:withVelocity:targetContentOffset:) == aSelector) {
        return(_webViewWillEndDraggingWithVelocityTargetContentOffset != NULL);
    } else if (@selector(scrollViewDidEndDragging:willDecelerate:) == aSelector) {
        return(_webViewDidEndDraggingWillDecelerate != NULL);
    } else if (@selector(scrollViewWillBeginDecelerating:) == aSelector) {
        return(_webViewWillBeginDecelerating != NULL);
    } else if (@selector(scrollViewDidEndDecelerating:) == aSelector) {
        return(_webViewDidEndDecelerating != NULL);
    } else if (@selector(scrollViewDidEndScrollingAnimation:) == aSelector) {
        return(_webViewDidEndScrollingAnimation != NULL);
    } else if (@selector(viewForZoomingInScrollView:) == aSelector) {
        return(_viewForZoomingInWebView != NULL);
    } else if (@selector(scrollViewWillBeginZooming:withView:) == aSelector) {
        return(_webViewWillBeginZoomingWithView != NULL);
    } else if (@selector(scrollViewDidEndZooming:withView:atScale:) == aSelector) {
        return(_webViewDidEndZoomingWithViewAtScale != NULL);
    } else if (@selector(scrollViewShouldScrollToTop:) == aSelector) {
        return(_webViewShouldScrollToTop != NULL);
    } else if (@selector(scrollViewDidScrollToTop:) == aSelector) {
        return(_webViewDidScrollToTop != NULL);
    } else if (@selector(scrollViewDidChangeAdjustedContentInset:) == aSelector) {
        return(_webViewDidChangeAdjustedContentInset != NULL);
    } else { return [super respondsToSelector:aSelector]; }
}

@end

// _UIWebViewScrollViewDelegateForwarder implementation:
//
// @interface _UIWebViewScrollViewDelegateForwarder : NSObject <UIScrollViewDelegate> {
//     id <UIScrollViewDelegate> _delegate;
//     UIWebView *_webView;
// }
// @property(nonatomic) UIWebView *webView; // @synthesize webView=_webView;
// @property(nonatomic) id<UIScrollViewDelegate> delegate; // @synthesize delegate=_delegate;
// - (void)forwardInvocation:(id)arg1;
// - (BOOL)respondsToSelector:(SEL)arg1;
// - (id)methodSignatureForSelector:(SEL)arg1;
// @end
//
// @implementation _UIWebViewScrollViewDelegateForwarder
// @synthesize webView=_webView;
// @synthesize delegate=_delegate;
// - (void)forwardInvocation:(NSInvocation *)arg1 {
//     SEL sel = [arg1 selector];
//     bool hasWebViewResponded = false;
//     if ([_webView respondsToSelector:sel]) {
//         [arg1 invokeWithTarget:_webView];
//         hasWebViewResponded = true;
//     }
//     if([_delegate respondsToSelector:sel]) {
//         [arg1 invokeWithTarget:_delegate];
//     } else {
//         if (!hasWebViewResponded) {
//             [super forwardInvocation:arg1];
//         }
//     }
// }
// - (BOOL)respondsToSelector:(SEL)arg1 {
//     bool result = [super respondsToSelector:arg1];
//     if (!result) {
//         result = [_webView respondsToSelector:arg1];
//         if (!result) {
//             result = [_delegate respondsToSelector:arg1];
//         }
//     }
//     return result;
// }
// - (id)methodSignatureForSelector:(SEL)arg1 {
//     id result = [super methodSignatureForSelector:arg1];
//     if (!result) {
//         result = [_webView methodSignatureForSelector:arg1];
//         if (!result) {
//             result = [(NSObject *)_delegate methodSignatureForSelector:arg1];
//         }
//     }
//     return result;
// }
// @end

@implementation AGXWebViewScrollDelegateAGXCoreDummy

- (AGXWebViewScrollDelegateInternalBlockKit *)AGXCore__UIWebViewScrollViewDelegateForwarder_webView_blockKit {
    return [[self valueForKey:@"webView"] blockKit];
}

- (void)AGXCore__UIWebViewScrollViewDelegateForwarder_forwardInvocation:(NSInvocation *)anInvocation {
    [self AGXCore__UIWebViewScrollViewDelegateForwarder_forwardInvocation:anInvocation];

    AGXWebViewScrollDelegateInternalBlockKit *blockKit
    = [self AGXCore__UIWebViewScrollViewDelegateForwarder_webView_blockKit];
    if ([blockKit respondsToSelector:anInvocation.selector]) {
        [anInvocation invokeWithTarget:blockKit];
    }
}

- (BOOL)AGXCore__UIWebViewScrollViewDelegateForwarder_respondsToSelector:(SEL)aSelector {
    return([self AGXCore__UIWebViewScrollViewDelegateForwarder_respondsToSelector:aSelector] ||
           [[self AGXCore__UIWebViewScrollViewDelegateForwarder_webView_blockKit] respondsToSelector:aSelector]);
}

- (NSMethodSignature *)AGXCore__UIWebViewScrollViewDelegateForwarder_methodSignatureForSelector:(SEL)aSelector {
    return([self AGXCore__UIWebViewScrollViewDelegateForwarder_methodSignatureForSelector:aSelector] ?:
           [[self AGXCore__UIWebViewScrollViewDelegateForwarder_webView_blockKit] methodSignatureForSelector:aSelector]);
}

+ (void)load {
    agx_once
    (Class _UIWebViewScrollViewDelegateForwarder
     = NSClassFromString(@"_UIWebViewScrollViewDelegateForwarder");
     [_UIWebViewScrollViewDelegateForwarder
      addInstanceMethodWithSelector:@selector(AGXCore__UIWebViewScrollViewDelegateForwarder_webView_blockKit)
      fromClass:AGXWebViewScrollDelegateAGXCoreDummy.class];
     [_UIWebViewScrollViewDelegateForwarder
      swizzleInstanceOriSelector:@selector(forwardInvocation:)
      withNewSelector:@selector(AGXCore__UIWebViewScrollViewDelegateForwarder_forwardInvocation:)
      fromClass:AGXWebViewScrollDelegateAGXCoreDummy.class];
     [_UIWebViewScrollViewDelegateForwarder
      swizzleInstanceOriSelector:@selector(respondsToSelector:)
      withNewSelector:@selector(AGXCore__UIWebViewScrollViewDelegateForwarder_respondsToSelector:)
      fromClass:AGXWebViewScrollDelegateAGXCoreDummy.class];
     [_UIWebViewScrollViewDelegateForwarder
      swizzleInstanceOriSelector:@selector(methodSignatureForSelector:)
      withNewSelector:@selector(AGXCore__UIWebViewScrollViewDelegateForwarder_methodSignatureForSelector:)
      fromClass:AGXWebViewScrollDelegateAGXCoreDummy.class];)
}

@end
