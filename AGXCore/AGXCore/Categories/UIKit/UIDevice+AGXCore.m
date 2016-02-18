//
//  UIDevice+AGXCore.m
//  AGXCore
//
//  Created by Char Aznable on 16/2/17.
//  Copyright © 2016年 AI-CUC-EC. All rights reserved.
//

#import "UIDevice+AGXCore.h"
#import "AGXObjC.h"
#include <sys/types.h>
#include <sys/sysctl.h>

@category_implementation(UIDevice, AGXCore)

- (NSString *)fullModelString {
    static NSString *_fullModel = nil;
    static dispatch_once_t once_t;
    dispatch_once(&once_t, ^{
        if (AGX_EXPECT_F(_fullModel)) return;
        size_t size;
        sysctlbyname("hw.machine", NULL, &size, NULL, 0);
        char *machine = malloc(size);
        sysctlbyname("hw.machine", machine, &size, NULL, 0);
        _fullModel = [[NSString alloc] initWithCString:machine
                                              encoding:NSASCIIStringEncoding];
        free(machine);
    });
    return _fullModel;
}

- (NSString *)purifyModelString {
    static NSString *_purifiedFullModel = nil;
    static dispatch_once_t once_t;
    dispatch_once(&once_t, ^{
        if (AGX_EXPECT_F(_purifiedFullModel)) return;
        NSString *fullModel = [self fullModelString];
        if ([fullModel isEqualToString:@"iPhone1,1"])   _purifiedFullModel = @"iPhone";
        if ([fullModel isEqualToString:@"iPhone1,2"])   _purifiedFullModel = @"iPhone 3G";
        if ([fullModel isEqualToString:@"iPhone2,1"])   _purifiedFullModel = @"iPhone 3GS";
        if ([fullModel isEqualToString:@"iPhone3,1"])   _purifiedFullModel = @"iPhone 4";
        if ([fullModel isEqualToString:@"iPhone3,2"])   _purifiedFullModel = @"iPhone 4";
        if ([fullModel isEqualToString:@"iPhone3,3"])   _purifiedFullModel = @"iPhone 4";
        if ([fullModel isEqualToString:@"iPhone4,1"])   _purifiedFullModel = @"iPhone 4S";
        if ([fullModel isEqualToString:@"iPhone5,1"])   _purifiedFullModel = @"iPhone 5";
        if ([fullModel isEqualToString:@"iPhone5,2"])   _purifiedFullModel = @"iPhone 5";
        if ([fullModel isEqualToString:@"iPhone5,3"])   _purifiedFullModel = @"iPhone 5C";
        if ([fullModel isEqualToString:@"iPhone5,4"])   _purifiedFullModel = @"iPhone 5C";
        if ([fullModel isEqualToString:@"iPhone6,1"])   _purifiedFullModel = @"iPhone 5S";
        if ([fullModel isEqualToString:@"iPhone6,2"])   _purifiedFullModel = @"iPhone 5S";
        if ([fullModel isEqualToString:@"iPhone7,1"])   _purifiedFullModel = @"iPhone 6Plus";
        if ([fullModel isEqualToString:@"iPhone7,2"])   _purifiedFullModel = @"iPhone 6";
        
        if ([fullModel isEqualToString:@"iPod1,1"])     _purifiedFullModel = @"iPod Touch 1G";
        if ([fullModel isEqualToString:@"iPod2,1"])     _purifiedFullModel = @"iPod Touch 2G";
        if ([fullModel isEqualToString:@"iPod3,1"])     _purifiedFullModel = @"iPod Touch 3G";
        if ([fullModel isEqualToString:@"iPod4,1"])     _purifiedFullModel = @"iPod Touch 4G";
        if ([fullModel isEqualToString:@"iPod5,1"])     _purifiedFullModel = @"iPod Touch 5G";
        
        if ([fullModel isEqualToString:@"iPad1,1"])     _purifiedFullModel = @"iPad 1G";
        if ([fullModel isEqualToString:@"iPad2,1"])     _purifiedFullModel = @"iPad 2";
        if ([fullModel isEqualToString:@"iPad2,2"])     _purifiedFullModel = @"iPad 2";
        if ([fullModel isEqualToString:@"iPad2,3"])     _purifiedFullModel = @"iPad 2";
        if ([fullModel isEqualToString:@"iPad2,4"])     _purifiedFullModel = @"iPad 2";
        if ([fullModel isEqualToString:@"iPad2,5"])     _purifiedFullModel = @"iPad Mini 1G";
        if ([fullModel isEqualToString:@"iPad2,6"])     _purifiedFullModel = @"iPad Mini 1G";
        if ([fullModel isEqualToString:@"iPad2,7"])     _purifiedFullModel = @"iPad Mini 1G";
        if ([fullModel isEqualToString:@"iPad3,1"])     _purifiedFullModel = @"iPad 3";
        if ([fullModel isEqualToString:@"iPad3,2"])     _purifiedFullModel = @"iPad 3";
        if ([fullModel isEqualToString:@"iPad3,3"])     _purifiedFullModel = @"iPad 3";
        if ([fullModel isEqualToString:@"iPad3,4"])     _purifiedFullModel = @"iPad 4";
        if ([fullModel isEqualToString:@"iPad3,5"])     _purifiedFullModel = @"iPad 4";
        if ([fullModel isEqualToString:@"iPad3,6"])     _purifiedFullModel = @"iPad 4";
        if ([fullModel isEqualToString:@"iPad4,1"])     _purifiedFullModel = @"iPad Air";
        if ([fullModel isEqualToString:@"iPad4,2"])     _purifiedFullModel = @"iPad Air";
        if ([fullModel isEqualToString:@"iPad4,3"])     _purifiedFullModel = @"iPad Air";
        if ([fullModel isEqualToString:@"iPad4,4"])     _purifiedFullModel = @"iPad Mini 2G";
        if ([fullModel isEqualToString:@"iPad4,5"])     _purifiedFullModel = @"iPad Mini 2G";
        if ([fullModel isEqualToString:@"iPad4,6"])     _purifiedFullModel = @"iPad Mini 2G";
        if ([fullModel isEqualToString:@"iPad4,7"])     _purifiedFullModel = @"iPad mini 3";
        if ([fullModel isEqualToString:@"iPad4,8"])     _purifiedFullModel = @"iPad mini 3";
        if ([fullModel isEqualToString:@"iPad4,9"])     _purifiedFullModel = @"iPad mini 3";
        if ([fullModel isEqualToString:@"iPad5,3"])     _purifiedFullModel = @"iPad air 2";
        if ([fullModel isEqualToString:@"iPad5,4"])     _purifiedFullModel = @"iPad air 2";
        
        if ([fullModel isEqualToString:@"i386"])        _purifiedFullModel = @"iPhone Simulator";
        if ([fullModel isEqualToString:@"x86_64"])      _purifiedFullModel = @"iPhone Simulator";
    });
    return _purifiedFullModel;
}

@end
