//
//  UIWebView+AGXCore.h
//  AGXCore
//
//  Created by Char Aznable on 16/7/6.
//  Copyright © 2016年 AI-CUC-EC. All rights reserved.
//

#ifndef AGXCore_UIWebView_AGXCore_h
#define AGXCore_UIWebView_AGXCore_h

#import <UIKit/UIKit.h>
#import "AGXCategory.h"

@category_interface(UIWebView, AGXCore)
- (void)loadRequestWithURLString:(NSString *)requestURLString;
- (void)loadRequestWithURLString:(NSString *)requestURLString cachePolicy:(NSURLRequestCachePolicy)cachePolicy;
- (void)loadRequestWithURLString:(NSString *)requestURLString allHTTPHeaderFields:(NSDictionary *)allHTTPHeaderFields;
- (void)loadRequestWithURLString:(NSString *)requestURLString cachePolicy:(NSURLRequestCachePolicy)cachePolicy allHTTPHeaderFields:(NSDictionary *)allHTTPHeaderFields;

- (NSArray<NSHTTPCookie *> *)cookiesWithNames:(NSArray<NSString *> *)cookieNames;
- (NSString *)cookieFieldForRequestHeaderWithNames:(NSArray<NSString *> *)cookieNames;
- (NSDictionary<NSString *, NSString *> *)cookieValuesWithNames:(NSArray<NSString *> *)cookieNames;

- (NSHTTPCookie *)cookieWithName:(NSString *)cookieName;
- (NSString *)cookieFieldForRequestHeaderWithName:(NSString *)cookieName;
- (NSString *)cookieValueWithName:(NSString *)cookieName;
@end

#endif /* AGXCore_UIWebView_AGXCore_h */
