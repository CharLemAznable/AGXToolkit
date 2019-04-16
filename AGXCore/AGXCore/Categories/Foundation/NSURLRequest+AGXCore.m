//
//  NSURLRequest+AGXCore.m
//  AGXCore
//
//  Created by Char Aznable on 2016/6/1.
//  Copyright © 2016 github.com/CharLemAznable. All rights reserved.
//

#import "NSURLRequest+AGXCore.h"
#import "NSString+AGXCore.h"

@category_implementation(NSURLRequest, AGXCore)

- (BOOL)isNewRequestFromURL:(NSURL *)url {
    BOOL isFragmentJump = NO;
    if (self.URL.fragment) {
        NSString *nonFragmentURL = [self.URL.absoluteString stringByReplacingString:
                                    [@"#" stringByAppendingString:self.URL.fragment] withString:@""];
        isFragmentJump = [nonFragmentURL isEqualToString:url.absoluteString];
    }
    BOOL isTopLevelNavigation = [self.mainDocumentURL isEqual:self.URL];
    BOOL isHTTPOrLocalFile = [self.URL.scheme isEqualToString:@"http"]
    || [self.URL.scheme isEqualToString:@"https"]
    || [self.URL.scheme isEqualToString:@"file"];
    return !isFragmentJump && isHTTPOrLocalFile && isTopLevelNavigation;
}

@end
