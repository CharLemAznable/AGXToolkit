//
//  UITabBar+AGXCore.m
//  AGXCore
//
//  Created by Char Aznable on 2016/2/17.
//  Copyright © 2016年 AI-CUC-EC. All rights reserved.
//

#import "UITabBar+AGXCore.h"
#import "AGXAppearance.h"

@category_implementation(UITabBar, AGXCore)

- (NSArray *)barButtons {
    NSMutableArray *barButtons = [NSMutableArray array];
    [self.subviews enumerateObjectsUsingBlock:
     ^(UIView *obj, NSUInteger idx, BOOL *stop) {
         if ([NSStringFromClass(obj.class) isEqualToString:@"UITabBarButton"])
             [barButtons addObject:obj];
     }];
    return barButtons;
}

#pragma mark - barStyle -

+ (UIBarStyle)barStyle {
    return [APPEARANCE barStyle];
}

+ (void)setBarStyle:(UIBarStyle)barStyle {
    [APPEARANCE setBarStyle:barStyle];
}

#pragma mark - translucent -

+ (BOOL)isTranslucent {
    return [APPEARANCE isTranslucent];
}

+ (void)setTranslucent:(BOOL)translucent {
    [APPEARANCE setTranslucent:translucent];
}

#pragma mark - tintColor -

+ (UIColor *)tintColor {
    return [APPEARANCE tintColor];
}

+ (void)setTintColor:(UIColor *)tintColor {
    [APPEARANCE setTintColor:tintColor];
}

+ (UIColor *)barTintColor {
    return [APPEARANCE barTintColor];
}

+ (void)setBarTintColor:(UIColor *)barTintColor {
    [APPEARANCE setBarTintColor:barTintColor];
}

#pragma mark - backgroundImage -

+ (UIImage *)backgroundImage {
    return [APPEARANCE backgroundImage];
}

+ (void)setBackgroundImage:(UIImage *)backgroundImage {
    [APPEARANCE setBackgroundImage:backgroundImage];
}

#pragma mark - backgroundColor -

+ (UIColor *)backgroundColor {
    return [(UITabBar *)APPEARANCE backgroundColor];
}

+ (void)setBackgroundColor:(UIColor *)backgroundColor {
    [APPEARANCE setBackgroundColor:backgroundColor];
}

#pragma mark - indicatorImage -

+ (UIImage *)selectionIndicatorImage {
    return [APPEARANCE selectionIndicatorImage];
}

+ (void)setSelectionIndicatorImage:(UIImage *)selectionIndicatorImage {
    [APPEARANCE setSelectionIndicatorImage:selectionIndicatorImage];
}

#pragma mark - indicatorColor -

- (UIColor *)selectionIndicatorColor {
    return selectionIndicatorColor(self);
}

- (void)setSelectionIndicatorColor:(UIColor *)selectionIndicatorColor {
    setSelectionIndicatorColor(self, selectionIndicatorColor);
}

+ (UIColor *)selectionIndicatorColor {
    return selectionIndicatorColor(APPEARANCE);
}

+ (void)setSelectionIndicatorColor:(UIColor *)selectionIndicatorColor {
    setSelectionIndicatorColor(APPEARANCE, selectionIndicatorColor);
}

@end
