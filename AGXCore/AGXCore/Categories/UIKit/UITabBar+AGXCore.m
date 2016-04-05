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

- (NSArray AGX_GENERIC(UIView *) *)barButtons {
    NSMutableArray *barButtons = [NSMutableArray array];
    [self.subviews enumerateObjectsUsingBlock:
     ^(__kindof UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
         if ([NSStringFromClass([obj class]) isEqualToString:@"UITabBarButton"])
             [barButtons addObject:obj];
     }];
    return barButtons;
}

#pragma mark - translucent -

#if __IPHONE_OS_VERSION_MAX_ALLOWED < 70000
- (BOOL)isTranslucent {
    return NO;
}

- (void)setTranslucent:(BOOL)translucent {
}
#endif

+ (BOOL)isTranslucent {
    return
#if __IPHONE_OS_VERSION_MIN_REQUIRED < 70000
    AGX_BEFORE_IOS7 ? NO :
#endif
    [APPEARANCE isTranslucent];
}

+ (void)setTranslucent:(BOOL)translucent {
#if __IPHONE_OS_VERSION_MIN_REQUIRED < 70000
    if (AGX_BEFORE_IOS7) return;
#endif
    [APPEARANCE setTranslucent:translucent];
}

#pragma mark - tintColor -

+ (UIColor *)tintColor {
    return [APPEARANCE tintColor];
}

+ (void)setTintColor:(UIColor *)tintColor {
    [APPEARANCE setTintColor:tintColor];
}

#if __IPHONE_OS_VERSION_MAX_ALLOWED < 70000
- (UIColor *)barTintColor {
    return nil;
}

- (void)setBarTintColor:(UIColor *)barTintColor {
}
#endif

+ (UIColor *)barTintColor {
    return
#if __IPHONE_OS_VERSION_MIN_REQUIRED < 70000
    AGX_BEFORE_IOS7 ? nil :
#endif
    [APPEARANCE barTintColor];
}

+ (void)setBarTintColor:(UIColor *)barTintColor {
#if __IPHONE_OS_VERSION_MIN_REQUIRED < 70000
    if (AGX_BEFORE_IOS7) return;
#endif
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
    return [APPEARANCE backgroundColor];
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

#if __IPHONE_OS_VERSION_MIN_REQUIRED >= 80000
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
