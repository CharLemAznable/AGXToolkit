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
