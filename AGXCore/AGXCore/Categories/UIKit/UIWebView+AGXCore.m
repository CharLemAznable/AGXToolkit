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
    [self loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:requestURLString]]];
}

- (NSString *)cookieWithName:(NSString *)name {
    __block NSString *value = nil;
    [[NSHTTPCookieStorage.sharedHTTPCookieStorage cookiesForURL:[NSURL URLWithString:self.request.URL.absoluteString]]
     enumerateObjectsUsingBlock:^(NSHTTPCookie *cookie, NSUInteger idx, BOOL *stop)
     { if ([cookie.name isEqualToString:name]) { value = AGX_AUTORELEASE([cookie.value copy]); *stop = YES; return; } }];

    return value;
}

@end
