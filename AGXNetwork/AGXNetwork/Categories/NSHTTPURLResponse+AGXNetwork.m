//
//  NSHTTPURLResponse+AGXNetwork.m
//  AGXNetwork
//
//  Created by Char Aznable on 16/4/27.
//  Copyright © 2016年 AI-CUC-EC. All rights reserved.
//

#import "NSHTTPURLResponse+AGXNetwork.h"
#import <AGXCore/AGXCore/NSString+AGXCore.h>
#import <AGXCore/AGXCore/NSArray+AGXCore.h>
#import <AGXCore/AGXCore/NSDictionary+AGXCore.h>
#import <AGXCore/AGXCore/NSDate+AGXCore.h>

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
         if (![control containsCaseInsensitiveString:@"max-age"]) return;
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
    if (expiresDate) return [expiresDate timeIntervalSinceNow];
    return self.maxAge ?: 0;
}

@end
