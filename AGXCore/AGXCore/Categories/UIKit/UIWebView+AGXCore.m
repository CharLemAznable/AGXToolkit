//
//  UIWebView+AGXCore.m
//  AGXCore
//
//  Created by Char Aznable on 16/7/6.
//  Copyright © 2016年 AI-CUC-EC. All rights reserved.
//

#import "UIWebView+AGXCore.h"
#import "AGXArc.h"
#import "NSHTTPCookieStorage+AGXCore.h"

@category_implementation(UIWebView, AGXCore)

- (void)loadRequestWithURLString:(NSString *)requestURLString {
    [self loadRequestWithURLString:requestURLString cachePolicy:NSURLRequestUseProtocolCachePolicy];
}

- (void)loadRequestWithURLString:(NSString *)requestURLString cachePolicy:(NSURLRequestCachePolicy)cachePolicy {
    [self loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:requestURLString]
                                       cachePolicy:cachePolicy timeoutInterval:60]];
}

- (void)loadRequestWithURLString:(NSString *)requestURLString allHTTPHeaderFields:(NSDictionary *)allHTTPHeaderFields {
    [self loadRequestWithURLString:requestURLString cachePolicy:NSURLRequestUseProtocolCachePolicy
               allHTTPHeaderFields:allHTTPHeaderFields];
}

- (void)loadRequestWithURLString:(NSString *)requestURLString cachePolicy:(NSURLRequestCachePolicy)cachePolicy allHTTPHeaderFields:(NSDictionary *)allHTTPHeaderFields {
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:requestURLString]
                                                           cachePolicy:cachePolicy timeoutInterval:60];
    request.allHTTPHeaderFields = allHTTPHeaderFields;
    [self loadRequest:request];
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

@end
