//
//  UITabBarItem+AGXCore.m
//  AGXCore
//
//  Created by Char Aznable on 16/2/17.
//  Copyright © 2016年 AI-CUC-EC. All rights reserved.
//

#import "UITabBarItem+AGXCore.h"
#import "AGXAppearance.h"

@category_implementation(UITabBarItem, AGXCore)

+ (UITabBarItem *)tabBarItemWithTitle:(NSString *)title image:(UIImage *)image selectedImage:(UIImage *)selectedImage {
#if __IPHONE_OS_VERSION_MIN_REQUIRED < 70000
    if (AGX_BEFORE_IOS7) {
        UITabBarItem *tabBarItem = [[UITabBarItem alloc] initWithTitle:title image:nil tag:0];
        [tabBarItem setFinishedSelectedImage:selectedImage withFinishedUnselectedImage:image];
        return AGX_AUTORELEASE(tabBarItem);
    }
#endif
    return AGX_AUTORELEASE([[UITabBarItem alloc] initWithTitle:title image:image
                                                 selectedImage:selectedImage]);
}

+ (UIOffset)titlePositionAdjustment {
    return [APPEARANCE titlePositionAdjustment];
}

+ (void)setTitlePositionAdjustment:(UIOffset)titlePositionAdjustment {
    [APPEARANCE setTitlePositionAdjustment:titlePositionAdjustment];
}

@end
