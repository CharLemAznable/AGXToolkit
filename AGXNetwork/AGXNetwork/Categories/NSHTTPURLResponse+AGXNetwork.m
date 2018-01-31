//
//  NSHTTPURLResponse+AGXNetwork.m
//  AGXNetwork
//
//  Created by Char Aznable on 2016/4/27.
//  Copyright © 2016年 AI-CUC-EC. All rights reserved.
//

//
//  Modify from:
//  MugunthKumar/MKNetworkKit
//

//  MKNetworkKit is licensed under MIT License Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

#import <AGXCore/AGXCore/AGXArc.h>
#import <AGXCore/AGXCore/NSString+AGXCore.h>
#import <AGXCore/AGXCore/NSDictionary+AGXCore.h>
#import <AGXCore/AGXCore/NSDate+AGXCore.h>
#import "NSHTTPURLResponse+AGXNetwork.h"

@category_implementation(NSHTTPURLResponse, AGXNetwork)

- (NSString *)lastModified {
    return [self.allHeaderFields objectForCaseInsensitiveKey:@"Last-Modified"];
}

- (NSString *)eTag {
    return [self.allHeaderFields objectForCaseInsensitiveKey:@"ETag"];
}

- (NSString *)cacheControl {
    return [self.allHeaderFields objectForCaseInsensitiveKey:@"Cache-Control"];
}

- (NSInteger)maxAge {
    __block NSInteger maxAge = 0;
    [[self.cacheControl componentsSeparatedByString:@","] enumerateObjectsUsingBlock:
     ^(NSString *control, NSUInteger idx, BOOL *stop) {
         if AGX_EXPECT_F(![control containsCaseInsensitiveString:@"max-age"]) return;
         maxAge = [control componentsSeparatedByString:@"="][1].integerValue;
         *stop = YES;
     }];
    return maxAge;
}

- (BOOL)noCache {
    return [self.cacheControl containsCaseInsensitiveString:@"no-cache"];
}

- (NSTimeInterval)expiresTimeSinceNow {
    NSString *expires = [self.allHeaderFields objectForCaseInsensitiveKey:@"Expires"];
    NSDate *expiresDate = [NSDate dateFromRFC1123:expires];
    if AGX_EXPECT_T(expiresDate) return expiresDate.timeIntervalSinceNow;
    return self.maxAge ?: 0;
}

@end
