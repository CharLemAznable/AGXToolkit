//
//  UITabBar+AGXCore.m
//  AGXCore
//
//  Created by Char Aznable on 16/2/17.
//  Copyright © 2016年 AI-CUC-EC. All rights reserved.
//

#import "UITabBar+AGXCore.h"
#import "AGXAppearance.h"

@category_implementation(UITabBar, AGXCore)

- (NSArray *)barButtons {
    NSMutableArray *barButtons = [NSMutableArray array];
    [self.subviews enumerateObjectsUsingBlock:
     ^(UIView *obj, NSUInteger idx, BOOL *stop) {
         if ([NSStringFromClass([obj class]) isEqualToString:@"UITabBarButton"])
             [barButtons addObject:obj];
     }];
    return barButtons;
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

#pragma mark - selectedTintColor -

#if __IPHONE_OS_VERSION_MIN_REQUIRED >= __IPHONE_8_0
- (UIColor *)selectedImageTintColor {
    return [self tintColor];
}

- (void)setSelectedImageTintColor:(UIColor *)selectedImageTintColor {
    [self setTintColor:selectedImageTintColor];
}
#endif

+ (UIColor *)selectedImageTintColor {
    return [APPEARANCE selectedImageTintColor];
}

+ (void)setSelectedImageTintColor:(UIColor *)selectedImageTintColor {
    [APPEARANCE setSelectedImageTintColor:selectedImageTintColor];
}

@end
