//
//  UIBarButtonItem+AGXCore.h
//  AGXCore
//
//  Created by Char Aznable on 2016/2/17.
//  Copyright © 2016年 AI-CUC-EC. All rights reserved.
//

#ifndef AGXCore_UIBarButtonItem_AGXCore_h
#define AGXCore_UIBarButtonItem_AGXCore_h

#import <UIKit/UIKit.h>
#import "AGXArc.h"
#import "AGXCategory.h"

@category_interface(UIBarButtonItem, AGXCore)
#pragma mark - tintColor -

+ (UIColor *)tintColor;
+ (void)setTintColor:(UIColor *)tintColor;
+ (UIColor *)tintColorWhenContainedIn:(Class<UIAppearanceContainer>)containerClass;
+ (void)setTintColor:(UIColor *)tintColor whenContainedIn:(Class<UIAppearanceContainer>)containerClass;

#pragma mark - backgroundImage -

@property (nonatomic, AGX_STRONG) UIImage *defaultBackgroundImage;

+ (UIImage *)defaultBackgroundImage;
+ (void)setDefaultBackgroundImage:(UIImage *)backgroundImage;
+ (UIImage *)backgroundImageForState:(UIControlState)state barMetrics:(UIBarMetrics)barMetrics;
+ (void)setBackgroundImage:(UIImage *)backgroundImage forState:(UIControlState)state barMetrics:(UIBarMetrics)barMetrics;

+ (UIImage *)defaultBackgroundImageWhenContainedIn:(Class<UIAppearanceContainer>)containerClass;
+ (void)setDefaultBackgroundImage:(UIImage *)backgroundImage whenContainedIn:(Class<UIAppearanceContainer>)containerClass;
+ (UIImage *)backgroundImageForState:(UIControlState)state barMetrics:(UIBarMetrics)barMetrics whenContainedIn:(Class<UIAppearanceContainer>)containerClass;
+ (void)setBackgroundImage:(UIImage *)backgroundImage forState:(UIControlState)state barMetrics:(UIBarMetrics)barMetrics whenContainedIn:(Class<UIAppearanceContainer>)containerClass;

#pragma mark - backgroundColor -

@property (nonatomic, AGX_STRONG) UIColor *defaultBackgroundColor;
- (UIColor *)backgroundColorForState:(UIControlState)state barMetrics:(UIBarMetrics)barMetrics;
- (void)setBackgroundColor:(UIColor *)backgroundColor forState:(UIControlState)state barMetrics:(UIBarMetrics)barMetrics;

+ (UIColor *)defaultBackgroundColor;
+ (void)setDefaultBackgroundColor:(UIColor *)backgroundColor;
+ (UIColor *)backgroundColorForState:(UIControlState)state barMetrics:(UIBarMetrics)barMetrics;
+ (void)setBackgroundColor:(UIColor *)backgroundColor forState:(UIControlState)state barMetrics:(UIBarMetrics)barMetrics;

+ (UIColor *)defaultBackgroundColorWhenContainedIn:(Class<UIAppearanceContainer>)containerClass;
+ (void)setDefaultBackgroundColor:(UIColor *)backgroundColor whenContainedIn:(Class<UIAppearanceContainer>)containerClass;
+ (UIColor *)backgroundColorForState:(UIControlState)state barMetrics:(UIBarMetrics)barMetrics whenContainedIn:(Class<UIAppearanceContainer>)containerClass;
+ (void)setBackgroundColor:(UIColor *)backgroundColor forState:(UIControlState)state barMetrics:(UIBarMetrics)barMetrics whenContainedIn:(Class<UIAppearanceContainer>)containerClass;

#pragma mark - backgroundImage with style -

- (UIImage *)defaultBackgroundImageForStyle:(UIBarButtonItemStyle)style;
- (void)setDefaultBackgroundImage:(UIImage *)backgroundImage forStyle:(UIBarButtonItemStyle)style;

+ (UIImage *)defaultBackgroundImageForStyle:(UIBarButtonItemStyle)style;
+ (void)setDefaultBackgroundImage:(UIImage *)backgroundImage forStyle:(UIBarButtonItemStyle)style;
+ (UIImage *)backgroundImageForState:(UIControlState)state style:(UIBarButtonItemStyle)style barMetrics:(UIBarMetrics)barMetrics;
+ (void)setBackgroundImage:(UIImage *)backgroundImage forState:(UIControlState)state style:(UIBarButtonItemStyle)style barMetrics:(UIBarMetrics)barMetrics;

+ (UIImage *)defaultBackgroundImageForStyle:(UIBarButtonItemStyle)style whenContainedIn:(Class<UIAppearanceContainer>)containerClass;
+ (void)setDefaultBackgroundImage:(UIImage *)backgroundImage forStyle:(UIBarButtonItemStyle)style whenContainedIn:(Class<UIAppearanceContainer>)containerClass;
+ (UIImage *)backgroundImageForState:(UIControlState)state style:(UIBarButtonItemStyle)style barMetrics:(UIBarMetrics)barMetrics whenContainedIn:(Class<UIAppearanceContainer>)containerClass;
+ (void)setBackgroundImage:(UIImage *)backgroundImage forState:(UIControlState)state style:(UIBarButtonItemStyle)style barMetrics:(UIBarMetrics)barMetrics whenContainedIn:(Class<UIAppearanceContainer>)containerClass;

#pragma mark - backgroundColor with style -

- (UIColor *)defaultBackgroundColorForStyle:(UIBarButtonItemStyle)style;
- (void)setDefaultBackgroundColor:(UIColor *)backgroundColor forStyle:(UIBarButtonItemStyle)style;
- (UIColor *)backgroundColorForState:(UIControlState)state style:(UIBarButtonItemStyle)style barMetrics:(UIBarMetrics)barMetrics;
- (void)setBackgroundColor:(UIColor *)backgroundColor forState:(UIControlState)state style:(UIBarButtonItemStyle)style barMetrics:(UIBarMetrics)barMetrics;

+ (UIColor *)defaultBackgroundColorForStyle:(UIBarButtonItemStyle)style;
+ (void)setDefaultBackgroundColor:(UIColor *)backgroundColor forStyle:(UIBarButtonItemStyle)style;
+ (UIColor *)backgroundColorForState:(UIControlState)state style:(UIBarButtonItemStyle)style barMetrics:(UIBarMetrics)barMetrics;
+ (void)setBackgroundColor:(UIColor *)backgroundColor forState:(UIControlState)state style:(UIBarButtonItemStyle)style barMetrics:(UIBarMetrics)barMetrics;

+ (UIColor *)defaultBackgroundColorForStyle:(UIBarButtonItemStyle)style whenContainedIn:(Class<UIAppearanceContainer>)containerClass;
+ (void)setDefaultBackgroundColor:(UIColor *)backgroundColor forStyle:(UIBarButtonItemStyle)style whenContainedIn:(Class<UIAppearanceContainer>)containerClass;
+ (UIColor *)backgroundColorForState:(UIControlState)state style:(UIBarButtonItemStyle)style barMetrics:(UIBarMetrics)barMetrics whenContainedIn:(Class<UIAppearanceContainer>)containerClass;
+ (void)setBackgroundColor:(UIColor *)backgroundColor forState:(UIControlState)state style:(UIBarButtonItemStyle)style barMetrics:(UIBarMetrics)barMetrics whenContainedIn:(Class<UIAppearanceContainer>)containerClass;

#pragma mark - backgroundVerticalPositionAdjustment -

@property (nonatomic) CGFloat defaultBackgroundVerticalPositionAdjustment;

+ (CGFloat)defaultBackgroundVerticalPositionAdjustment;
+ (void)setDefaultBackgroundVerticalPositionAdjustment:(CGFloat)adjustment;
+ (CGFloat)backgroundVerticalPositionAdjustmentForBarMetrics:(UIBarMetrics)barMetrics;
+ (void)setBackgroundVerticalPositionAdjustment:(CGFloat)adjustment forBarMetrics:(UIBarMetrics)barMetrics;

+ (CGFloat)defaultBackgroundVerticalPositionAdjustmentWhenContainedIn:(Class<UIAppearanceContainer>)containerClass;
+ (void)setDefaultBackgroundVerticalPositionAdjustment:(CGFloat)adjustment whenContainedIn:(Class<UIAppearanceContainer>)containerClass;
+ (CGFloat)backgroundVerticalPositionAdjustmentForBarMetrics:(UIBarMetrics)barMetrics whenContainedIn:(Class<UIAppearanceContainer>)containerClass;
+ (void)setBackgroundVerticalPositionAdjustment:(CGFloat)adjustment forBarMetrics:(UIBarMetrics)barMetrics whenContainedIn:(Class<UIAppearanceContainer>)containerClass;

#pragma mark - titlePositionAdjustment -

@property (nonatomic) UIOffset defaultTitlePositionAdjustment;

+ (UIOffset)defaultTitlePositionAdjustment;
+ (void)setDefaultTitlePositionAdjustment:(UIOffset)adjustment;
+ (UIOffset)titlePositionAdjustmentForBarMetrics:(UIBarMetrics)barMetrics;
+ (void)setTitlePositionAdjustment:(UIOffset)adjustment forBarMetrics:(UIBarMetrics)barMetrics;

+ (UIOffset)defaultTitlePositionAdjustmentWhenContainedIn:(Class<UIAppearanceContainer>)containerClass;
+ (void)setDefaultTitlePositionAdjustment:(UIOffset)adjustment whenContainedIn:(Class<UIAppearanceContainer>)containerClass;
+ (UIOffset)titlePositionAdjustmentForBarMetrics:(UIBarMetrics)barMetrics whenContainedIn:(Class<UIAppearanceContainer>)containerClass;
+ (void)setTitlePositionAdjustment:(UIOffset)adjustment forBarMetrics:(UIBarMetrics)barMetrics whenContainedIn:(Class<UIAppearanceContainer>)containerClass;

#pragma mark - backButtonBackgroundImage -

@property (nonatomic, AGX_STRONG) UIImage *defaultBackButtonBackgroundImage;

+ (UIImage *)defaultBackButtonBackgroundImage;
+ (void)setDefaultBackButtonBackgroundImage:(UIImage *)backgroundImage;
+ (UIImage *)backButtonBackgroundImageForState:(UIControlState)state barMetrics:(UIBarMetrics)barMetrics;
+ (void)setBackButtonBackgroundImage:(UIImage *)backgroundImage forState:(UIControlState)state barMetrics:(UIBarMetrics)barMetrics;

+ (UIImage *)defaultBackButtonBackgroundImageWhenContainedIn:(Class<UIAppearanceContainer>)containerClass;
+ (void)setDefaultBackButtonBackgroundImage:(UIImage *)backgroundImage whenContainedIn:(Class<UIAppearanceContainer>)containerClass;
+ (UIImage *)backButtonBackgroundImageForState:(UIControlState)state barMetrics:(UIBarMetrics)barMetrics whenContainedIn:(Class<UIAppearanceContainer>)containerClass;
+ (void)setBackButtonBackgroundImage:(UIImage *)backgroundImage forState:(UIControlState)state barMetrics:(UIBarMetrics)barMetrics whenContainedIn:(Class<UIAppearanceContainer>)containerClass;

#pragma mark - backButtonBackgroundColor -

@property (nonatomic, AGX_STRONG) UIColor *defaultBackButtonBackgroundColor;
- (UIColor *)backButtonBackgroundColorForState:(UIControlState)state barMetrics:(UIBarMetrics)barMetrics;
- (void)setBackButtonBackgroundColor:(UIColor *)backgroundColor forState:(UIControlState)state barMetrics:(UIBarMetrics)barMetrics;

+ (UIColor *)defaultBackButtonBackgroundColor;
+ (void)setDefaultBackButtonBackgroundColor:(UIColor *)backgroundColor;
+ (UIColor *)backButtonBackgroundColorForState:(UIControlState)state barMetrics:(UIBarMetrics)barMetrics;
+ (void)setBackButtonBackgroundColor:(UIColor *)backgroundColor forState:(UIControlState)state barMetrics:(UIBarMetrics)barMetrics;

+ (UIColor *)defaultBackButtonBackgroundColorWhenContainedIn:(Class<UIAppearanceContainer>)containerClass;
+ (void)setDefaultBackButtonBackgroundColor:(UIColor *)backgroundColor whenContainedIn:(Class<UIAppearanceContainer>)containerClass;
+ (UIColor *)backButtonBackgroundColorForState:(UIControlState)state barMetrics:(UIBarMetrics)barMetrics whenContainedIn:(Class<UIAppearanceContainer>)containerClass;
+ (void)setBackButtonBackgroundColor:(UIColor *)backgroundColor forState:(UIControlState)state barMetrics:(UIBarMetrics)barMetrics whenContainedIn:(Class<UIAppearanceContainer>)containerClass;

#pragma mark - backButtonBackgroundVerticalPositionAdjustment -

@property (nonatomic) CGFloat defaultBackButtonBackgroundVerticalPositionAdjustment;

+ (CGFloat)defaultBackButtonBackgroundVerticalPositionAdjustment;
+ (void)setDefaultBackButtonBackgroundVerticalPositionAdjustment:(CGFloat)adjustment;
+ (CGFloat)backButtonBackgroundVerticalPositionAdjustmentForBarMetrics:(UIBarMetrics)barMetrics;
+ (void)setBackButtonBackgroundVerticalPositionAdjustment:(CGFloat)adjustment forBarMetrics:(UIBarMetrics)barMetrics;

+ (CGFloat)defaultBackButtonBackgroundVerticalPositionAdjustmentWhenContainedIn:(Class<UIAppearanceContainer>)containerClass;
+ (void)setDefaultBackButtonBackgroundVerticalPositionAdjustment:(CGFloat)adjustment whenContainedIn:(Class<UIAppearanceContainer>)containerClass;
+ (CGFloat)backButtonBackgroundVerticalPositionAdjustmentForBarMetrics:(UIBarMetrics)barMetrics whenContainedIn:(Class<UIAppearanceContainer>)containerClass;
+ (void)setBackButtonBackgroundVerticalPositionAdjustment:(CGFloat)adjustment forBarMetrics:(UIBarMetrics)barMetrics whenContainedIn:(Class<UIAppearanceContainer>)containerClass;

#pragma mark - backButtonTitlePositionAdjustment -

@property (nonatomic) UIOffset defaultBackButtonTitlePositionAdjustment;

+ (UIOffset)defaultBackButtonTitlePositionAdjustment;
+ (void)setDefaultBackButtonTitlePositionAdjustment:(UIOffset)adjustment;
+ (UIOffset)backButtonTitlePositionAdjustmentForBarMetrics:(UIBarMetrics)barMetrics;
+ (void)setBackButtonTitlePositionAdjustment:(UIOffset)adjustment forBarMetrics:(UIBarMetrics)barMetrics;

+ (UIOffset)defaultBackButtonTitlePositionAdjustmentWhenContainedIn:(Class<UIAppearanceContainer>)containerClass;
+ (void)setDefaultBackButtonTitlePositionAdjustment:(UIOffset)adjustment whenContainedIn:(Class<UIAppearanceContainer>)containerClass;
+ (UIOffset)backButtonTitlePositionAdjustmentForBarMetrics:(UIBarMetrics)barMetrics whenContainedIn:(Class<UIAppearanceContainer>)containerClass;
+ (void)setBackButtonTitlePositionAdjustment:(UIOffset)adjustment forBarMetrics:(UIBarMetrics)barMetrics whenContainedIn:(Class<UIAppearanceContainer>)containerClass;

#pragma mark - text attributes with container -

+ (UIFont *)textFontForState:(UIControlState)state whenContainedIn:(Class<UIAppearanceContainer>)containerClass;
+ (void)setTextFont:(UIFont *)textFont forState:(UIControlState)state whenContainedIn:(Class<UIAppearanceContainer>)containerClass;

+ (UIColor *)textColorForState:(UIControlState)state whenContainedIn:(Class<UIAppearanceContainer>)containerClass;
+ (void)setTextColor:(UIColor *)textColor forState:(UIControlState)state whenContainedIn:(Class<UIAppearanceContainer>)containerClass;

+ (UIColor *)textShadowColorForState:(UIControlState)state whenContainedIn:(Class<UIAppearanceContainer>)containerClass;
+ (void)setTextShadowColor:(UIColor *)textShadowColor forState:(UIControlState)state whenContainedIn:(Class<UIAppearanceContainer>)containerClass;

+ (CGSize)textShadowOffsetForState:(UIControlState)state whenContainedIn:(Class<UIAppearanceContainer>)containerClass;
+ (void)setTextShadowOffset:(CGSize)textShadowOffset forState:(UIControlState)state whenContainedIn:(Class<UIAppearanceContainer>)containerClass;

+ (CGFloat)textShadowSizeForState:(UIControlState)state whenContainedIn:(Class<UIAppearanceContainer>)containerClass;
+ (void)setTextShadowSize:(CGFloat)textShadowSize forState:(UIControlState)state whenContainedIn:(Class<UIAppearanceContainer>)containerClass;
@end

#endif /* AGXCore_UIBarButtonItem_AGXCore_h */
