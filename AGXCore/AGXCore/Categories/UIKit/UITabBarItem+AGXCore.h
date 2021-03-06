//
//  UITabBarItem+AGXCore.h
//  AGXCore
//
//  Created by Char Aznable on 2016/2/17.
//  Copyright © 2016 github.com/CharLemAznable. All rights reserved.
//

#ifndef AGXCore_UITabBarItem_AGXCore_h
#define AGXCore_UITabBarItem_AGXCore_h

#import <UIKit/UIKit.h>
#import "AGXCategory.h"

@category_interface(UITabBarItem, AGXCore)
+ (AGX_INSTANCETYPE)tabBarItemWithTitle:(NSString *)title image:(UIImage *)image selectedImage:(UIImage *)selectedImage;

+ (UIOffset)titlePositionAdjustment;
+ (void)setTitlePositionAdjustment:(UIOffset)titlePositionAdjustment;
@end

#endif /* AGXCore_UITabBarItem_AGXCore_h */
