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

@end
