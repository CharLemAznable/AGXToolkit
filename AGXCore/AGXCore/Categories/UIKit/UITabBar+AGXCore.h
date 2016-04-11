//
//  UITabBar+AGXCore.h
//  AGXCore
//
//  Created by Char Aznable on 16/2/17.
//  Copyright © 2016年 AI-CUC-EC. All rights reserved.
//

#ifndef AGXCore_UITabBar_AGXCore_h
#define AGXCore_UITabBar_AGXCore_h

#import <UIKit/UIKit.h>
#import "AGXCategory.h"
#import "AGXArc.h"

@category_interface(UITabBar, AGXCore)
@property (nonatomic, readonly) NSArray AGX_GENERIC(UIView *) *barButtons;

+ (BOOL)isTranslucent;
+ (void)setTranslucent:(BOOL)translucent;

+ (UIColor *)tintColor;
+ (void)setTintColor:(UIColor *)tintColor;

+ (UIColor *)barTintColor;
+ (void)setBarTintColor:(UIColor *)barTintColor;

+ (UIImage *)backgroundImage;
+ (void)setBackgroundImage:(UIImage *)backgroundImage;

+ (UIColor *)backgroundColor;
+ (void)setBackgroundColor:(UIColor *)backgroundColor;

+ (UIImage *)selectionIndicatorImage;
+ (void)setSelectionIndicatorImage:(UIImage *)selectionIndicatorImage;

@property (nonatomic, AGX_STRONG) UIColor *selectionIndicatorColor;
+ (UIColor *)selectionIndicatorColor;
+ (void)setSelectionIndicatorColor:(UIColor *)selectionIndicatorColor;

#if __IPHONE_OS_VERSION_MIN_REQUIRED >= 80000
@property (nonatomic, AGX_STRONG) UIColor *selectedImageTintColor;
#endif
+ (UIColor *)selectedImageTintColor;
+ (void)setSelectedImageTintColor:(UIColor *)selectedImageTintColor;
@end

#endif /* AGXCore_UITabBar_AGXCore_h */
