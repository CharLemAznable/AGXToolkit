//
//  UINavigationBar+AGXCore.h
//  AGXCore
//
//  Created by Char Aznable on 2016/2/17.
//  Copyright © 2016年 AI-CUC-EC. All rights reserved.
//

#ifndef AGXCore_UINavigationBar_AGXCore_h
#define AGXCore_UINavigationBar_AGXCore_h

#import <UIKit/UIKit.h>
#import "AGXArc.h"
#import "AGXCategory.h"

@category_interface(UINavigationBar, AGXCore)
@property (nonatomic, readonly) UINavigationController *navigationController;

+ (UIBarStyle)barStyle;
+ (void)setBarStyle:(UIBarStyle)barStyle;

+ (BOOL)isTranslucent;
+ (void)setTranslucent:(BOOL)translucent;

+ (UIColor *)tintColor;
+ (void)setTintColor:(UIColor *)tintColor;

+ (UIColor *)barTintColor;
+ (void)setBarTintColor:(UIColor *)barTintColor;

@property (nonatomic, AGX_STRONG) UIImage *defaultBackgroundImage;
+ (UIImage *)defaultBackgroundImage;
+ (void)setDefaultBackgroundImage:(UIImage *)backgroundImage;

+ (UIImage *)backgroundImageForBarMetrics:(UIBarMetrics)barMetrics;
+ (void)setBackgroundImage:(UIImage *)backgroundImage forBarMetrics:(UIBarMetrics)barMetrics;

+ (UIImage *)backgroundImageForBarPosition:(UIBarPosition)barPosition barMetrics:(UIBarMetrics)barMetrics;
+ (void)setBackgroundImage:(UIImage *)backgroundImage forBarPosition:(UIBarPosition)barPosition barMetrics:(UIBarMetrics)barMetrics;

@property (nonatomic, readonly) UIImage *currentBackgroundImage;

@property (nonatomic, AGX_STRONG) UIColor *defaultBackgroundColor;
+ (UIColor *)defaultBackgroundColor;
+ (void)setDefaultBackgroundColor:(UIColor *)backgroundColor;

- (UIColor *)backgroundColorForBarMetrics:(UIBarMetrics)barMetrics;
- (void)setBackgroundColor:(UIColor *)backgroundColor forBarMetrics:(UIBarMetrics)barMetrics;
+ (UIColor *)backgroundColorForBarMetrics:(UIBarMetrics)barMetrics;
+ (void)setBackgroundColor:(UIColor *)backgroundColor forBarMetrics:(UIBarMetrics)barMetrics;

- (UIColor *)backgroundColorForBarPosition:(UIBarPosition)barPosition barMetrics:(UIBarMetrics)barMetrics;
- (void)setBackgroundColor:(UIColor *)backgroundColor forBarPosition:(UIBarPosition)barPosition barMetrics:(UIBarMetrics)barMetrics;
+ (UIColor *)backgroundColorForBarPosition:(UIBarPosition)barPosition barMetrics:(UIBarMetrics)barMetrics;
+ (void)setBackgroundColor:(UIColor *)backgroundColor forBarPosition:(UIBarPosition)barPosition barMetrics:(UIBarMetrics)barMetrics;

@property (nonatomic, readonly) UIColor *currentBackgroundColor;

+ (UIImage *)shadowImage;
+ (void)setShadowImage:(UIImage *)shadowImage;

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

+ (UIImage *)backIndicatorImage;
+ (void)setBackIndicatorImage:(UIImage *)backIndicatorImage;
+ (UIImage *)backIndicatorTransitionMaskImage;
+ (void)setBackIndicatorTransitionMaskImage:(UIImage *)backIndicatorTransitionMaskImage;
@end

#endif /* AGXCore_UINavigationBar_AGXCore_h */
