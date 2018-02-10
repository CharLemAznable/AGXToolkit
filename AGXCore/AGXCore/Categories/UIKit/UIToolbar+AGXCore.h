//
//  UIToolbar+AGXCore.h
//  AGXCore
//
//  Created by Char Aznable on 2018/2/10.
//  Copyright © 2018年 AI-CUC-EC. All rights reserved.
//

#ifndef AGXCore_UIToolbar_AGXCore_h
#define AGXCore_UIToolbar_AGXCore_h

#import <UIKit/UIKit.h>
#import "AGXArc.h"
#import "AGXCategory.h"

@category_interface(UIToolbar, AGXCore)
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

- (UIImage *)backgroundImageForBarMetrics:(UIBarMetrics)barMetrics;
- (void)setBackgroundImage:(UIImage *)backgroundImage forBarMetrics:(UIBarMetrics)barMetrics;
+ (UIImage *)backgroundImageForBarMetrics:(UIBarMetrics)barMetrics;
+ (void)setBackgroundImage:(UIImage *)backgroundImage forBarMetrics:(UIBarMetrics)barMetrics;

+ (UIImage *)backgroundImageForToolbarPosition:(UIBarPosition)topOrBottom barMetrics:(UIBarMetrics)barMetrics;
+ (void)setBackgroundImage:(UIImage *)backgroundImage forToolbarPosition:(UIBarPosition)topOrBottom barMetrics:(UIBarMetrics)barMetrics;

@property (nonatomic, readonly) UIImage *currentBackgroundImage;

@property (nonatomic, AGX_STRONG) UIColor *defaultBackgroundColor;
+ (UIColor *)defaultBackgroundColor;
+ (void)setDefaultBackgroundColor:(UIColor *)backgroundColor;

- (UIColor *)backgroundColorForBarMetrics:(UIBarMetrics)barMetrics;
- (void)setBackgroundColor:(UIColor *)backgroundColor forBarMetrics:(UIBarMetrics)barMetrics;
+ (UIColor *)backgroundColorForBarMetrics:(UIBarMetrics)barMetrics;
+ (void)setBackgroundColor:(UIColor *)backgroundColor forBarMetrics:(UIBarMetrics)barMetrics;

- (UIColor *)backgroundColorForToolbarPosition:(UIBarPosition)barPosition barMetrics:(UIBarMetrics)barMetrics;
- (void)setBackgroundColor:(UIColor *)backgroundColor forToolbarPosition:(UIBarPosition)barPosition barMetrics:(UIBarMetrics)barMetrics;
+ (UIColor *)backgroundColorForToolbarPosition:(UIBarPosition)barPosition barMetrics:(UIBarMetrics)barMetrics;
+ (void)setBackgroundColor:(UIColor *)backgroundColor forToolbarPosition:(UIBarPosition)barPosition barMetrics:(UIBarMetrics)barMetrics;

@property (nonatomic, readonly) UIColor *currentBackgroundColor;
@end

#endif /* AGXCore_UIToolbar_AGXCore_h */
