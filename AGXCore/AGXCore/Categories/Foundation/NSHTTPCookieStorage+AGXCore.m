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
    __AGX_BLOCK NSHTTPCookie *result;
    [self p_enumerateCookies:self.cookies withNames:@[cookieName]
                   withBlock:^(NSHTTPCookie *cookie, BOOL *stop) {
                       result = AGX_RETAIN(cookie); *stop = YES; }];
    return result ? AGX_AUTORELEASE(result) : nil;
}

- (NSString *)cookieFieldForRequestHeaderWithName:(NSString *)cookieName {
    return [NSHTTPCookie requestHeaderFieldsWithCookies:
            @[[self cookieWithName:cookieName]]][@"Cookie"];
}

- (NSString *)cookieValueWithName:(NSString *)cookieName {
    __AGX_BLOCK NSString *result;
    [self p_enumerateCookies:self.cookies withNames:@[cookieName]
                   withBlock:^(NSHTTPCookie *cookie, BOOL *stop) {
                       result = [cookie.value copy]; *stop = YES; }];
    return result ? AGX_AUTORELEASE(result) : nil;
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
    __AGX_BLOCK NSHTTPCookie *result;
    [self p_enumerateCookies:[self cookiesForURLString:URLString]
                   withNames:@[cookieName] withBlock:^(NSHTTPCookie *cookie, BOOL *stop) {
                       result = AGX_RETAIN(cookie); *stop = YES; }];
    return result ? AGX_AUTORELEASE(result) : nil;
}

- (NSString *)cookieFieldForRequestHeaderWithName:(NSString *)cookieName forURLString:(NSString *)URLString {
    return [NSHTTPCookie requestHeaderFieldsWithCookies:
            @[[self cookieWithName:cookieName forURLString:URLString]]][@"Cookie"];
}

- (NSString *)cookieValueWithName:(NSString *)cookieName forURLString:(NSString *)URLString {
    __AGX_BLOCK NSString *result;
    [self p_enumerateCookies:[self cookiesForURLString:URLString]
                   withNames:@[cookieName] withBlock:^(NSHTTPCookie *cookie, BOOL *stop) {
                       result = [cookie.value copy]; *stop = YES; }];
    return result ? AGX_AUTORELEASE(result) : nil;
}

#pragma mark - private methods

- (void)p_enumerateCookies:(NSArray<NSHTTPCookie *> *)cookies withNames:(NSArray<NSString *> *)cookieNames withBlock:(void (^)(NSHTTPCookie *cookie, BOOL *stop))block {
    [cookies enumerateObjectsUsingBlock:^(NSHTTPCookie *cookie, NSUInteger idx, BOOL *stop) {
        if (![cookieNames containsObject:cookie.name]) return;
        block(cookie, stop);
    }];
}

@end
