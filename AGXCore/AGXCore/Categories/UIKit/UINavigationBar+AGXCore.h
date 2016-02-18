//
//  UINavigationBar+AGXCore.h
//  AGXCore
//
//  Created by Char Aznable on 16/2/17.
//  Copyright © 2016年 AI-CUC-EC. All rights reserved.
//

#ifndef AGXCore_UINavigationBar_AGXCore_h
#define AGXCore_UINavigationBar_AGXCore_h

#import <UIKit/UIKit.h>
#import "AGXCategory.h"
#import "AGXArc.h"

@category_interface(UINavigationBar, AGXCore)
+ (BOOL)isTranslucent;
+ (void)setTranslucent:(BOOL)translucent;

+ (UIColor *)tintColor;
+ (void)setTintColor:(UIColor *)tintColor;

#if __IPHONE_OS_VERSION_MAX_ALLOWED < 70000
@property (nonatomic, AGX_STRONG) UIColor *barTintColor UI_APPEARANCE_SELECTOR;
#endif
+ (UIColor *)barTintColor;
+ (void)setBarTintColor:(UIColor *)barTintColor;

@property (nonatomic, AGX_STRONG) UIImage *defaultBackgroundImage;
+ (UIImage *)defaultBackgroundImage;
+ (void)setDefaultBackgroundImage:(UIImage *)backgroundImage;

+ (UIImage *)backgroundImageForBarMetrics:(UIBarMetrics)barMetrics;
+ (void)setBackgroundImage:(UIImage *)backgroundImage forBarMetrics:(UIBarMetrics)barMetrics;

@property (nonatomic, AGX_STRONG) UIColor *defaultBackgroundColor;
+ (UIColor *)defaultBackgroundColor;
+ (void)setDefaultBackgroundColor:(UIColor *)backgroundColor;

- (UIColor *)backgroundColorForBarMetrics:(UIBarMetrics)barMetrics;
- (void)setBackgroundColor:(UIColor *)backgroundColor forBarMetrics:(UIBarMetrics)barMetrics;
+ (UIColor *)backgroundColorForBarMetrics:(UIBarMetrics)barMetrics;
+ (void)setBackgroundColor:(UIColor *)backgroundColor forBarMetrics:(UIBarMetrics)barMetrics;

@property (nonatomic, AGX_STRONG) UIFont *textFont;
+ (UIFont *)textFont;
+ (void)setTextFont:(UIFont *)textFont;

@property (nonatomic, AGX_STRONG) UIColor *textColor;
+ (UIColor *)textColor;
+ (void)setTextColor:(UIColor *)textColor;

@property (nonatomic, AGX_STRONG) UIColor *textShadowColor;
+ (UIColor *)textShadowColor;
+ (void)setTextShadowColor:(UIColor *)textShadowColor;

@property (nonatomic)             CGSize textShadowOffset;
+ (CGSize)textShadowOffset;
+ (void)setTextShadowOffset:(CGSize)textShadowOffset;

@property (nonatomic)             CGFloat textShadowSize;
+ (CGFloat)textShadowSize;
+ (void)setTextShadowSize:(CGFloat)textShadowSize;
@end

#endif /* AGXCore_UINavigationBar_AGXCore_h */
