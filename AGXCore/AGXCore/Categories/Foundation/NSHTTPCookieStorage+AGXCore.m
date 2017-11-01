//
//  NSHTTPCookieStorage+AGXCore.m
//  AGXCore
//
//  Created by Char Aznable on 2017/11/1.
//  Copyright © 2017年 AI-CUC-EC. All rights reserved.
//

#import "NSHTTPCookieStorage+AGXCore.h"
#import "AGXArc.h"
#import "NSObject+AGXCore.h"

@category_implementation(NSHTTPCookieStorage, AGXCore)

- (NSArray<NSHTTPCookie *> *)cookiesWithNames:(NSArray<NSString *> *)cookieNames {
    NSMutableArray *result = NSMutableArray.instance;
    [self p_enumerateCookies:self.cookies withNames:cookieNames
                   withBlock:^(NSHTTPCookie *cookie, BOOL *stop) {
                       [result addObject:cookie]; }];
    return AGX_AUTORELEASE([result copy]);
}

- (NSString *)cookieFieldForRequestHeaderWithNames:(NSArray<NSString *> *)cookieNames {
    return [NSHTTPCookie requestHeaderFieldsWithCookies:
            [self cookiesWithNames:cookieNames]][@"Cookie"];
}

- (NSDictionary<NSString *, NSString *> *)cookieValuesWithNames:(NSArray<NSString *> *)cookieNames {
    NSMutableDictionary *result = NSMutableDictionary.instance;
    [self p_enumerateCookies:self.cookies withNames:cookieNames
                   withBlock:^(NSHTTPCookie *cookie, BOOL *stop) {
                       result[cookie.name] = AGX_AUTORELEASE([cookie.value copy]); }];
    return AGX_AUTORELEASE([result copy]);
}

- (NSHTTPCookie *)cookieWithName:(NSString *)cookieName {
    return [self cookiesWithNames:@[cookieName]][0];
}

- (NSString *)cookieFieldForRequestHeaderWithName:(NSString *)cookieName {
    return [self cookieFieldForRequestHeaderWithNames:@[cookieName]];
}

- (NSString *)cookieValueWithName:(NSString *)cookieName {
    return [self cookieValuesWithNames:@[cookieName]][cookieName];
}

- (NSArray<NSHTTPCookie *> *)cookiesForURLString:(NSString *)URLString {
    return [self cookiesForURL:[NSURL URLWithString:URLString]];
}

- (NSArray<NSHTTPCookie *> *)cookiesWithNames:(NSArray<NSString *> *)cookieNames forURLString:(NSString *)URLString {
    NSMutableArray *result = NSMutableArray.instance;
    [self p_enumerateCookies:[self cookiesForURLString:URLString]
                   withNames:cookieNames withBlock:^(NSHTTPCookie *cookie, BOOL *stop) {
                       [result addObject:cookie]; }];
    return AGX_AUTORELEASE([result copy]);
}

- (NSString *)cookieFieldForRequestHeaderWithNames:(NSArray<NSString *> *)cookieNames forURLString:(NSString *)URLString {
    return [NSHTTPCookie requestHeaderFieldsWithCookies:
            [self cookiesWithNames:cookieNames forURLString:URLString]][@"Cookie"];
}

- (NSDictionary<NSString *, NSString *> *)cookieValuesWithNames:(NSArray<NSString *> *)cookieNames forURLString:(NSString *)URLString {
    NSMutableDictionary *result = NSMutableDictionary.instance;
    [self p_enumerateCookies:[self cookiesForURLString:URLString]
                   withNames:cookieNames withBlock:^(NSHTTPCookie *cookie, BOOL *stop) {
                       result[cookie.name] = AGX_AUTORELEASE([cookie.value copy]); }];
    return AGX_AUTORELEASE([result copy]);
}

- (NSHTTPCookie *)cookieWithName:(NSString *)cookieName forURLString:(NSString *)URLString {
    return [self cookiesWithNames:@[cookieName] forURLString:URLString][0];
}

- (NSString *)cookieFieldForRequestHeaderWithName:(NSString *)cookieName forURLString:(NSString *)URLString {
    return [self cookieFieldForRequestHeaderWithNames:@[cookieName] forURLString:URLString];
}

- (NSString *)cookieValueWithName:(NSString *)cookieName forURLString:(NSString *)URLString {
    return [self cookieValuesWithNames:@[cookieName] forURLString:URLString][cookieName];
}

#pragma mark - private methods

- (void)p_enumerateCookies:(NSArray<NSHTTPCookie *> *)cookies withNames:(NSArray<NSString *> *)cookieNames withBlock:(void (^)(NSHTTPCookie *cookie, BOOL *stop))block {
    [cookies enumerateObjectsUsingBlock:^(NSHTTPCookie *cookie, NSUInteger idx, BOOL *stop) {
        if (![cookieNames containsObject:cookie.name]) return;
        block(cookie, stop);
    }];
}

@end
