//
//  NSHTTPCookieStorage+AGXCore.h
//  AGXCore
//
//  Created by Char Aznable on 2017/11/1.
//  Copyright © 2017年 AI-CUC-EC. All rights reserved.
//

#ifndef AGXCore_NSHTTPCookieStorage_AGXCore_h
#define AGXCore_NSHTTPCookieStorage_AGXCore_h

#import "AGXCategory.h"

@category_interface(NSHTTPCookieStorage, AGXCore)
- (NSArray<NSHTTPCookie *> *)cookiesWithNames:(NSArray<NSString *> *)cookieNames;
- (NSString *)cookieFieldForRequestHeaderWithNames:(NSArray<NSString *> *)cookieNames;
- (NSDictionary<NSString *, NSString *> *)cookieValuesWithNames:(NSArray<NSString *> *)cookieNames;

- (NSHTTPCookie *)cookieWithName:(NSString *)cookieName;
- (NSString *)cookieFieldForRequestHeaderWithName:(NSString *)cookieName;
- (NSString *)cookieValueWithName:(NSString *)cookieName;

- (NSArray<NSHTTPCookie *> *)cookiesForURLString:(NSString *)URLString;

- (NSArray<NSHTTPCookie *> *)cookiesWithNames:(NSArray<NSString *> *)cookieNames forURLString:(NSString *)URLString;
- (NSString *)cookieFieldForRequestHeaderWithNames:(NSArray<NSString *> *)cookieNames forURLString:(NSString *)URLString;
- (NSDictionary<NSString *, NSString *> *)cookieValuesWithNames:(NSArray<NSString *> *)cookieNames forURLString:(NSString *)URLString;

- (NSHTTPCookie *)cookieWithName:(NSString *)cookieName forURLString:(NSString *)URLString;
- (NSString *)cookieFieldForRequestHeaderWithName:(NSString *)cookieName forURLString:(NSString *)URLString;
- (NSString *)cookieValueWithName:(NSString *)cookieName forURLString:(NSString *)URLString;
@end

#endif /* AGXCore_NSHTTPCookieStorage_AGXCore_h */
