//
//  UIWebView+AGXCore.m
//  AGXCore
//
//  Created by Char Aznable on 16/7/6.
//  Copyright © 2016年 AI-CUC-EC. All rights reserved.
//

#import "UIWebView+AGXCore.h"

@category_implementation(UIWebView, AGXCore)

- (void)loadRequestWithURLString:(NSString *)requestURLString {
    [self loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:requestURLString]]];
}

@end
