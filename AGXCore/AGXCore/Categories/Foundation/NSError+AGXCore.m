//
//  NSError+AGXCore.m
//  AGXCore
//
//  Created by Char Aznable on 17/9/29.
//  Copyright © 2017年 AI-CUC-EC. All rights reserved.
//

#import "NSError+AGXCore.h"
#import "NSString+AGXCore.h"

@category_implementation(NSError, AGXCore)

+ (AGX_INSTANCETYPE)errorWithDomain:(NSString *)domain code:(NSInteger)code description:(NSString *)fmt, ... NS_FORMAT_FUNCTION(3,4) {
    va_list args;
    va_start(args, fmt);
    NSString *desc = [NSString stringWithFormat:fmt arguments:args];
    va_end(args);

    return [NSError errorWithDomain:domain code:code userInfo:
            [NSDictionary dictionaryWithObject:desc forKey:NSLocalizedDescriptionKey]];
}

+ (BOOL)fillError:(NSError **)error withDomain:(NSString *)domain code:(NSInteger)code description:(NSString *)fmt, ... NS_FORMAT_FUNCTION(4,5) {
    if (!error) return NO;

    va_list args;
    va_start(args, fmt);
    NSString *desc = [NSString stringWithFormat:fmt arguments:args];
    va_end(args);

    *error = [NSError errorWithDomain:domain code:code userInfo:
              [NSDictionary dictionaryWithObject:desc forKey:NSLocalizedDescriptionKey]];
    return YES;
}

+ (BOOL)clearError:(NSError **)error {
    if (!error) return NO;

    *error = nil;
    return YES;
}

@end
