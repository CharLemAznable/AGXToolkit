//
//  UITabBarItem+AGXCore.m
//  AGXCore
//
//  Created by Char Aznable on 2016/2/17.
//  Copyright © 2016年 AI-CUC-EC. All rights reserved.
//

#import "UITabBarItem+AGXCore.h"
#import "AGXAppearance.h"

@category_implementation(UITabBarItem, AGXCore)

+ (AGX_INSTANCETYPE)tabBarItemWithTitle:(NSString *)title image:(UIImage *)image selectedImage:(UIImage *)selectedImage {
    return AGX_AUTORELEASE([[self alloc] initWithTitle:title image:image selectedImage:selectedImage]);
}

+ (UIOffset)titlePositionAdjustment {
    return [APPEARANCE titlePositionAdjustment];
}

+ (void)setTitlePositionAdjustment:(UIOffset)titlePositionAdjustment {
    [APPEARANCE setTitlePositionAdjustment:titlePositionAdjustment];
}

@end
