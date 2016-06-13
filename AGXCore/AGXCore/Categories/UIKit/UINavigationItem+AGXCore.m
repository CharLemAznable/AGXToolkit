//
//  UINavigationItem+AGXCore.m
//  AGXCore
//
//  Created by Char Aznable on 16/6/3.
//  Copyright © 2016年 AI-CUC-EC. All rights reserved.
//

#import "UINavigationItem+AGXCore.h"
#import "NSObject+AGXCore.h"

@category_implementation(UINavigationItem, AGXCore)

#pragma mark - fix NSCoding bug

NSString *const agxLeftItemsSupplementBackButtonKey = @"agxLeftItemsSupplementBackButton";

- (AGX_INSTANCETYPE)AGXCore_UINavigationItem_initWithCoder:(NSCoder *)aDecoder {
    if (AGX_EXPECT_T([self AGXCore_UINavigationItem_initWithCoder:aDecoder])) {
        self.leftItemsSupplementBackButton = [aDecoder decodeBoolForKey:agxLeftItemsSupplementBackButtonKey];
    }
    return self;
}

- (void)AGXCore_UINavigationItem_encodeWithCoder:(NSCoder *)aCoder {
    [self AGXCore_UINavigationItem_encodeWithCoder:aCoder];
    [aCoder encodeBool:self.leftItemsSupplementBackButton forKey:agxLeftItemsSupplementBackButtonKey];
}

+ (void)load {
    static dispatch_once_t once_t;
    dispatch_once(&once_t, ^{
        [self swizzleInstanceOriSelector:@selector(initWithCoder:)
                         withNewSelector:@selector(AGXCore_UINavigationItem_initWithCoder:)];
        [self swizzleInstanceOriSelector:@selector(encodeWithCoder:)
                         withNewSelector:@selector(AGXCore_UINavigationItem_encodeWithCoder:)];
    });
}

@end
