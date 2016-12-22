//
//  UIWebView+AGXCore.m
//  AGXCore
//
//  Created by Char Aznable on 16/7/6.
//  Copyright © 2016年 AI-CUC-EC. All rights reserved.
//

#import "UIWebView+AGXCore.h"
#import "AGXArc.h"

@category_implementation(UIWebView, AGXCore)

- (void)loadRequestWithURLString:(NSString *)requestURLString {
    [self loadRequestWithURLString:requestURLString cachePolicy:NSURLRequestUseProtocolCachePolicy];
}

- (void)loadRequestWithURLString:(NSString *)requestURLString attachCookieNames:(NSArray *)cookieNames {
    [self loadRequestWithURLString:requestURLString cachePolicy:NSURLRequestUseProtocolCachePolicy attachCookieNames:cookieNames];
}

- (void)loadRequestWithURLString:(NSString *)requestURLString cachePolicy:(NSURLRequestCachePolicy)cachePolicy {
    [self loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:requestURLString]
                                       cachePolicy:cachePolicy timeoutInterval:60]];
}

- (void)loadRequestWithURLString:(NSString *)requestURLString cachePolicy:(NSURLRequestCachePolicy)cachePolicy attachCookieNames:(NSArray *)cookieNames {
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:requestURLString]
                                                           cachePolicy:cachePolicy timeoutInterval:60];
    NSArray *cookies = NSHTTPCookieStorage.sharedHTTPCookieStorage.cookies;
    NSMutableArray *attachCookies = [NSMutableArray array];
    for (NSHTTPCookie *cookie in cookies) {
        if (![cookieNames containsObject:cookie.name]) continue;
        [attachCookies addObject:cookie];
    }
    [request setValue:[NSHTTPCookie requestHeaderFieldsWithCookies:
                       attachCookies][@"Cookie"] forHTTPHeaderField:@"Cookie"];
    [self loadRequest:request];
}

- (NSString *)cookieWithName:(NSString *)name {
    NSArray *cookies = [NSHTTPCookieStorage.sharedHTTPCookieStorage cookiesForURL:
                        [NSURL URLWithString:self.request.URL.absoluteString]];
    for (NSHTTPCookie *cookie in cookies) {
        if ([cookie.name isEqualToString:name]) {
            return AGX_AUTORELEASE([cookie.value copy]);
        }
    }
    return nil;
}

@end
