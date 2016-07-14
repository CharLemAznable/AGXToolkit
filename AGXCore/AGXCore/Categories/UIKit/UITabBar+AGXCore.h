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
#import "AGXArc.h"
#import "AGXCategory.h"

@category_interface(UITabBar, AGXCore)
@property (nonatomic, readonly) NSArray *barButtons;

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

#if __IPHONE_OS_VERSION_MIN_REQUIRED >= __IPHONE_8_0
@property (nonatomic, AGX_STRONG) UIColor *selectedImageTintColor;
#endif
+ (UIColor *)selectedImageTintColor;
+ (void)setSelectedImageTintColor:(UIColor *)selectedImageTintColor;
@end

#endif /* AGXCore_UITabBar_AGXCore_h */
