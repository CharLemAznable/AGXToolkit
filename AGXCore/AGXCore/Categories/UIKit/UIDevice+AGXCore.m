//
//  UIDevice+AGXCore.m
//  AGXCore
//
//  Created by Char Aznable on 16/2/17.
//  Copyright © 2016年 AI-CUC-EC. All rights reserved.
//

#include <sys/types.h>
#include <sys/sysctl.h>
#import "UIDevice+AGXCore.h"
#import "AGXArc.h"
#import "NSObject+AGXCore.h"
#import "NSString+AGXCore.h"
#import "UIWebView+AGXCore.h"

@category_implementation(UIDevice, AGXCore)

+ (NSString *)completeModelString {
    return [UIDevice currentDevice].completeModelString;
}

+ (NSString *)purifiedModelString {
    return [UIDevice currentDevice].purifiedModelString;
}

+ (NSString *)webkitVersionString {
    return [UIDevice currentDevice].webkitVersionString;
}

- (NSString *)completeModelString {
    static NSString *_completeModel = nil;
    static dispatch_once_t once_t;
    dispatch_once(&once_t, ^{
        if AGX_EXPECT_F(_completeModel) return;
        size_t size;
        sysctlbyname("hw.machine", NULL, &size, NULL, 0);
        char *machine = malloc(size);
        sysctlbyname("hw.machine", machine, &size, NULL, 0);
        _completeModel = [[NSString alloc] initWithCString:machine
                                                  encoding:NSASCIIStringEncoding];
        free(machine);
    });
    return _completeModel;
}

- (NSString *)purifiedModelString {
    static NSString *_purifiedModel = nil;
    static dispatch_once_t once_t;
    dispatch_once(&once_t, ^{
        if AGX_EXPECT_F(_purifiedModel) return;
        NSString *completeModel = [self completeModelString];

#define MATCH_MODEL(FULL_MODEL, PURIFIED) \
if ([completeModel isEqualToString:@FULL_MODEL])   _purifiedModel = @PURIFIED;

        MATCH_MODEL("iPhone1,1",    "iPhone")
        MATCH_MODEL("iPhone1,1",    "iPhone")
        MATCH_MODEL("iPhone1,2",    "iPhone 3G")
        MATCH_MODEL("iPhone2,1",    "iPhone 3GS")
        MATCH_MODEL("iPhone3,1",    "iPhone 4")
        MATCH_MODEL("iPhone3,2",    "iPhone 4")
        MATCH_MODEL("iPhone3,3",    "iPhone 4")
        MATCH_MODEL("iPhone4,1",    "iPhone 4S")
        MATCH_MODEL("iPhone5,1",    "iPhone 5")
        MATCH_MODEL("iPhone5,2",    "iPhone 5")
        MATCH_MODEL("iPhone5,3",    "iPhone 5C")
        MATCH_MODEL("iPhone5,4",    "iPhone 5C")
        MATCH_MODEL("iPhone6,1",    "iPhone 5S")
        MATCH_MODEL("iPhone6,2",    "iPhone 5S")
        MATCH_MODEL("iPhone7,1",    "iPhone 6 Plus")
        MATCH_MODEL("iPhone7,2",    "iPhone 6")
        MATCH_MODEL("iPhone8,1",    "iPhone 6S")
        MATCH_MODEL("iPhone8,2",    "iPhone 6S Plus")
        MATCH_MODEL("iPhone8,3",    "iPhone SE")
        MATCH_MODEL("iPhone8,4",    "iPhone SE")
        MATCH_MODEL("iPhone9,1",    "iPhone 7")
        MATCH_MODEL("iPhone9,2",    "iPhone 7 Plus")
        MATCH_MODEL("iPhone9,3",    "iPhone 7")
        MATCH_MODEL("iPhone9,4",    "iPhone 7 Plus")
        MATCH_MODEL("iPhone10,1",   "iPhone 8")
        MATCH_MODEL("iPhone10,2",   "iPhone 8 Plus")
        MATCH_MODEL("iPhone10,3",   "iPhone X")
        MATCH_MODEL("iPhone10,4",   "iPhone 8")
        MATCH_MODEL("iPhone10,5",   "iPhone 8 Plus")
        MATCH_MODEL("iPhone10,6",   "iPhone X")

        MATCH_MODEL("iPod1,1",      "iPod Touch 1G")
        MATCH_MODEL("iPod2,1",      "iPod Touch 2G")
        MATCH_MODEL("iPod3,1",      "iPod Touch 3G")
        MATCH_MODEL("iPod4,1",      "iPod Touch 4G")
        MATCH_MODEL("iPod5,1",      "iPod Touch 5G")
        MATCH_MODEL("iPod7,1",      "iPod Touch 6G")

        MATCH_MODEL("iPad1,1",      "iPad 1G")
        MATCH_MODEL("iPad2,1",      "iPad 2")
        MATCH_MODEL("iPad2,2",      "iPad 2")
        MATCH_MODEL("iPad2,3",      "iPad 2")
        MATCH_MODEL("iPad2,4",      "iPad 2")
        MATCH_MODEL("iPad2,5",      "iPad mini 1G")
        MATCH_MODEL("iPad2,6",      "iPad mini 1G")
        MATCH_MODEL("iPad2,7",      "iPad mini 1G")
        MATCH_MODEL("iPad3,1",      "iPad 3")
        MATCH_MODEL("iPad3,2",      "iPad 3")
        MATCH_MODEL("iPad3,3",      "iPad 3")
        MATCH_MODEL("iPad3,4",      "iPad 4")
        MATCH_MODEL("iPad3,5",      "iPad 4")
        MATCH_MODEL("iPad3,6",      "iPad 4")
        MATCH_MODEL("iPad4,1",      "iPad Air")
        MATCH_MODEL("iPad4,2",      "iPad Air")
        MATCH_MODEL("iPad4,3",      "iPad Air")
        MATCH_MODEL("iPad4,4",      "iPad mini 2")
        MATCH_MODEL("iPad4,5",      "iPad mini 2")
        MATCH_MODEL("iPad4,6",      "iPad mini 2")
        MATCH_MODEL("iPad4,7",      "iPad mini 3")
        MATCH_MODEL("iPad4,8",      "iPad mini 3")
        MATCH_MODEL("iPad4,9",      "iPad mini 3")
        MATCH_MODEL("iPad5,1",      "iPad mini 4")
        MATCH_MODEL("iPad5,2",      "iPad mini 4")
        MATCH_MODEL("iPad5,3",      "iPad Air 2")
        MATCH_MODEL("iPad5,4",      "iPad Air 2")
        MATCH_MODEL("iPad6,3",      "iPad Pro 9.7")
        MATCH_MODEL("iPad6,4",      "iPad Pro 9.7")
        MATCH_MODEL("iPad6,7",      "iPad Pro 12.9")
        MATCH_MODEL("iPad6,8",      "iPad Pro 12.9")

        MATCH_MODEL("i386",         "iPhone Simulator")
        MATCH_MODEL("x86_64",       "iPhone Simulator")

#undef MATCH_MODEL
    });
    return _purifiedModel;
}

- (NSString *)webkitVersionString {
    NSArray *userAgents = [UIWebView.userAgent arraySeparatedByString:@" " filterEmpty:YES];
    for (NSString *userAgent in userAgents) {
        if ([userAgent hasCaseInsensitivePrefix:@"AppleWebKit"]) return userAgent;
    }
    return @"UnKnown";
}

@end
