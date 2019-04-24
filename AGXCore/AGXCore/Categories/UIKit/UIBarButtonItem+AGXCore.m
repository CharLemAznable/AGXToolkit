//
//  UIBarButtonItem+AGXCore.m
//  AGXCore
//
//  Created by Char Aznable on 2016/2/17.
//  Copyright © 2016 github.com/CharLemAznable. All rights reserved.
//

#import "UIBarButtonItem+AGXCore.h"
#import "AGXGeometry.h"
#import "AGXAppearance.h"

@category_implementation(UIBarButtonItem, AGXCore)

#pragma mark - tintColor -

+ (UIColor *)tintColor {
    return [APPEARANCE tintColor];
}

+ (void)setTintColor:(UIColor *)tintColor {
    [APPEARANCE setTintColor:tintColor];
}

+ (UIColor *)tintColorWhenContainedIn:(Class<UIAppearanceContainer>)containerClass {
    return [APPEARANCE_IN_CLASS(containerClass) tintColor];
}

+ (void)setTintColor:(UIColor *)tintColor whenContainedIn:(Class<UIAppearanceContainer>)containerClass {
    [APPEARANCE_IN_CLASS(containerClass) setTintColor:tintColor];
}

#pragma mark - backgroundImage -

- (UIImage *)defaultBackgroundImage {
    return backgroundImageForStateAndBarMetrics(self, UIControlStateNormal, UIBarMetricsDefault);
}

- (void)setDefaultBackgroundImage:(UIImage *)backgroundImage {
    setBackgroundImageForStateAndBarMetrics(self, backgroundImage, UIControlStateNormal, UIBarMetricsDefault);
}

+ (UIImage *)defaultBackgroundImage {
    return [self backgroundImageForState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
}

+ (void)setDefaultBackgroundImage:(UIImage *)backgroundImage {
    [self setBackgroundImage:backgroundImage forState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
}

+ (UIImage *)backgroundImageForState:(UIControlState)state barMetrics:(UIBarMetrics)barMetrics {
    return backgroundImageForStateAndBarMetrics(APPEARANCE, state, barMetrics);
}

+ (void)setBackgroundImage:(UIImage *)backgroundImage forState:(UIControlState)state barMetrics:(UIBarMetrics)barMetrics {
    setBackgroundImageForStateAndBarMetrics(APPEARANCE, backgroundImage, state, barMetrics);
}

+ (UIImage *)defaultBackgroundImageWhenContainedIn:(Class<UIAppearanceContainer>)containerClass {
    return [self backgroundImageForState:UIControlStateNormal barMetrics:UIBarMetricsDefault whenContainedIn:containerClass];
}

+ (void)setDefaultBackgroundImage:(UIImage *)backgroundImage whenContainedIn:(Class<UIAppearanceContainer>)containerClass {
    [self setBackgroundImage:backgroundImage forState:UIControlStateNormal barMetrics:UIBarMetricsDefault whenContainedIn:containerClass];
}

+ (UIImage *)backgroundImageForState:(UIControlState)state barMetrics:(UIBarMetrics)barMetrics whenContainedIn:(Class<UIAppearanceContainer>)containerClass {
    return backgroundImageForStateAndBarMetrics(APPEARANCE_IN_CLASS(containerClass), state, barMetrics);
}

+ (void)setBackgroundImage:(UIImage *)backgroundImage forState:(UIControlState)state barMetrics:(UIBarMetrics)barMetrics whenContainedIn:(Class<UIAppearanceContainer>)containerClass {
    setBackgroundImageForStateAndBarMetrics(APPEARANCE_IN_CLASS(containerClass), backgroundImage, state, barMetrics);
}

#pragma mark - backgroundColor -

- (UIColor *)defaultBackgroundColor {
    return [self backgroundColorForState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
}

- (void)setDefaultBackgroundColor:(UIColor *)backgroundColor {
    [self setBackgroundColor:backgroundColor forState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
}

- (UIColor *)backgroundColorForState:(UIControlState)state barMetrics:(UIBarMetrics)barMetrics {
    return backgroundColorForStateAndBarMetrics(self, state, barMetrics);
}

- (void)setBackgroundColor:(UIColor *)backgroundColor forState:(UIControlState)state barMetrics:(UIBarMetrics)barMetrics {
    setBackgroundColorForStateAndBarMetrics(self, backgroundColor, state, barMetrics);
}

+ (UIColor *)defaultBackgroundColor {
    return [self backgroundColorForState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
}

+ (void)setDefaultBackgroundColor:(UIColor *)backgroundColor {
    [self setBackgroundColor:backgroundColor forState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
}

+ (UIColor *)backgroundColorForState:(UIControlState)state barMetrics:(UIBarMetrics)barMetrics {
    return backgroundColorForStateAndBarMetrics(APPEARANCE, state, barMetrics);
}

+ (void)setBackgroundColor:(UIColor *)backgroundColor forState:(UIControlState)state barMetrics:(UIBarMetrics)barMetrics {
    setBackgroundColorForStateAndBarMetrics(APPEARANCE, backgroundColor, state, barMetrics);
}

+ (UIColor *)defaultBackgroundColorWhenContainedIn:(Class<UIAppearanceContainer>)containerClass {
    return [self backgroundColorForState:UIControlStateNormal barMetrics:UIBarMetricsDefault
                         whenContainedIn:containerClass];
}

+ (void)setDefaultBackgroundColor:(UIColor *)backgroundColor whenContainedIn:(Class<UIAppearanceContainer>)containerClass {
    [self setBackgroundColor:backgroundColor forState:UIControlStateNormal barMetrics:UIBarMetricsDefault
             whenContainedIn:containerClass];
}

+ (UIColor *)backgroundColorForState:(UIControlState)state barMetrics:(UIBarMetrics)barMetrics whenContainedIn:(Class<UIAppearanceContainer>)containerClass {
    return backgroundColorForStateAndBarMetrics(APPEARANCE_IN_CLASS(containerClass), state, barMetrics);
}

+ (void)setBackgroundColor:(UIColor *)backgroundColor forState:(UIControlState)state barMetrics:(UIBarMetrics)barMetrics whenContainedIn:(Class<UIAppearanceContainer>)containerClass {
    setBackgroundColorForStateAndBarMetrics(APPEARANCE_IN_CLASS(containerClass), backgroundColor, state, barMetrics);
}

#pragma mark - backgroundImage with style -

- (UIImage *)defaultBackgroundImageForStyle:(UIBarButtonItemStyle)style {
    return backgroundImageForStateAndStyleAndBarMetrics(self, UIControlStateNormal, style, UIBarMetricsDefault);
}

- (void)setDefaultBackgroundImage:(UIImage *)backgroundImage forStyle:(UIBarButtonItemStyle)style {
    setBackgroundImageForStateAndStyleAndBarMetrics
    (self, backgroundImage, UIControlStateNormal, style, UIBarMetricsDefault);
}

+ (UIImage *)defaultBackgroundImageForStyle:(UIBarButtonItemStyle)style {
    return [self backgroundImageForState:UIControlStateNormal style:style barMetrics:UIBarMetricsDefault];
}

+ (void)setDefaultBackgroundImage:(UIImage *)backgroundImage forStyle:(UIBarButtonItemStyle)style {
    [self setBackgroundImage:backgroundImage forState:UIControlStateNormal style:style barMetrics:UIBarMetricsDefault];
}

+ (UIImage *)backgroundImageForState:(UIControlState)state style:(UIBarButtonItemStyle)style barMetrics:(UIBarMetrics)barMetrics {
    return backgroundImageForStateAndStyleAndBarMetrics(APPEARANCE, state, style, barMetrics);
}

+ (void)setBackgroundImage:(UIImage *)backgroundImage forState:(UIControlState)state style:(UIBarButtonItemStyle)style barMetrics:(UIBarMetrics)barMetrics {
    setBackgroundImageForStateAndStyleAndBarMetrics
    (APPEARANCE, backgroundImage, state, style, barMetrics);
}

+ (UIImage *)defaultBackgroundImageForStyle:(UIBarButtonItemStyle)style whenContainedIn:(Class<UIAppearanceContainer>)containerClass {
    return [self backgroundImageForState:UIControlStateNormal style:style barMetrics:UIBarMetricsDefault
                         whenContainedIn:containerClass];
}

+ (void)setDefaultBackgroundImage:(UIImage *)backgroundImage forStyle:(UIBarButtonItemStyle)style whenContainedIn:(Class<UIAppearanceContainer>)containerClass {
    [self setBackgroundImage:backgroundImage forState:UIControlStateNormal style:style barMetrics:UIBarMetricsDefault
             whenContainedIn:containerClass];
}

+ (UIImage *)backgroundImageForState:(UIControlState)state style:(UIBarButtonItemStyle)style barMetrics:(UIBarMetrics)barMetrics whenContainedIn:(Class<UIAppearanceContainer>)containerClass {
    return backgroundImageForStateAndStyleAndBarMetrics(APPEARANCE_IN_CLASS(containerClass), state, style, barMetrics);
}

+ (void)setBackgroundImage:(UIImage *)backgroundImage forState:(UIControlState)state style:(UIBarButtonItemStyle)style barMetrics:(UIBarMetrics)barMetrics whenContainedIn:(Class<UIAppearanceContainer>)containerClass {
    setBackgroundImageForStateAndStyleAndBarMetrics
    (APPEARANCE_IN_CLASS(containerClass), backgroundImage, state, style, barMetrics);
}

#pragma mark - backgroundColor with style -

- (UIColor *)defaultBackgroundColorForStyle:(UIBarButtonItemStyle)style {
    return [self backgroundColorForState:UIControlStateNormal style:style barMetrics:UIBarMetricsDefault];
}

- (void)setDefaultBackgroundColor:(UIColor *)backgroundColor forStyle:(UIBarButtonItemStyle)style {
    [self setBackgroundColor:backgroundColor forState:UIControlStateNormal style:style barMetrics:UIBarMetricsDefault];
}

- (UIColor *)backgroundColorForState:(UIControlState)state style:(UIBarButtonItemStyle)style barMetrics:(UIBarMetrics)barMetrics {
    return backgroundColorForStateAndStyleAndBarMetrics(self, state, style, barMetrics);
}

- (void)setBackgroundColor:(UIColor *)backgroundColor forState:(UIControlState)state style:(UIBarButtonItemStyle)style barMetrics:(UIBarMetrics)barMetrics {
    setBackgroundColorForStateAndStyleAndBarMetrics(self, backgroundColor, state, style, barMetrics);
}

+ (UIColor *)defaultBackgroundColorForStyle:(UIBarButtonItemStyle)style {
    return [self backgroundColorForState:UIControlStateNormal style:style barMetrics:UIBarMetricsDefault];
}

+ (void)setDefaultBackgroundColor:(UIColor *)backgroundColor forStyle:(UIBarButtonItemStyle)style {
    [self setBackgroundColor:backgroundColor forState:UIControlStateNormal style:style barMetrics:UIBarMetricsDefault];
}

+ (UIColor *)backgroundColorForState:(UIControlState)state style:(UIBarButtonItemStyle)style barMetrics:(UIBarMetrics)barMetrics {
    return backgroundColorForStateAndStyleAndBarMetrics(APPEARANCE, state, style, barMetrics);
}

+ (void)setBackgroundColor:(UIColor *)backgroundColor forState:(UIControlState)state style:(UIBarButtonItemStyle)style barMetrics:(UIBarMetrics)barMetrics {
    setBackgroundColorForStateAndStyleAndBarMetrics(APPEARANCE, backgroundColor, state, style, barMetrics);
}

+ (UIColor *)defaultBackgroundColorForStyle:(UIBarButtonItemStyle)style whenContainedIn:(Class<UIAppearanceContainer>)containerClass {
    return [self backgroundColorForState:UIControlStateNormal style:style barMetrics:UIBarMetricsDefault
                         whenContainedIn:containerClass];
}

+ (void)setDefaultBackgroundColor:(UIColor *)backgroundColor forStyle:(UIBarButtonItemStyle)style whenContainedIn:(Class<UIAppearanceContainer>)containerClass {
    [self setBackgroundColor:backgroundColor forState:UIControlStateNormal style:style barMetrics:UIBarMetricsDefault
             whenContainedIn:containerClass];
}

+ (UIColor *)backgroundColorForState:(UIControlState)state style:(UIBarButtonItemStyle)style barMetrics:(UIBarMetrics)barMetrics whenContainedIn:(Class<UIAppearanceContainer>)containerClass {
    return backgroundColorForStateAndStyleAndBarMetrics(APPEARANCE_IN_CLASS(containerClass), state, style, barMetrics);
}

+ (void)setBackgroundColor:(UIColor *)backgroundColor forState:(UIControlState)state style:(UIBarButtonItemStyle)style barMetrics:(UIBarMetrics)barMetrics whenContainedIn:(Class<UIAppearanceContainer>)containerClass {
    setBackgroundColorForStateAndStyleAndBarMetrics
    (APPEARANCE_IN_CLASS(containerClass), backgroundColor, state, style, barMetrics);
}

#pragma mark - backgroundVerticalPositionAdjustment -

- (CGFloat)defaultBackgroundVerticalPositionAdjustment {
    return backgroundVerticalPositionAdjustmentForBarMetrics(self, UIBarMetricsDefault);
}

- (void)setDefaultBackgroundVerticalPositionAdjustment:(CGFloat)adjustment {
    setBackgroundVerticalPositionAdjustmentForBarMetrics(self, adjustment, UIBarMetricsDefault);
}

+ (CGFloat)defaultBackgroundVerticalPositionAdjustment {
    return [self backgroundVerticalPositionAdjustmentForBarMetrics:UIBarMetricsDefault];
}

+ (void)setDefaultBackgroundVerticalPositionAdjustment:(CGFloat)adjustment {
    [self setBackgroundVerticalPositionAdjustment:adjustment forBarMetrics:UIBarMetricsDefault];
}

+ (CGFloat)backgroundVerticalPositionAdjustmentForBarMetrics:(UIBarMetrics)barMetrics {
    return backgroundVerticalPositionAdjustmentForBarMetrics(APPEARANCE, barMetrics);
}

+ (void)setBackgroundVerticalPositionAdjustment:(CGFloat)adjustment forBarMetrics:(UIBarMetrics)barMetrics {
    setBackgroundVerticalPositionAdjustmentForBarMetrics(APPEARANCE, adjustment, barMetrics);
}

+ (CGFloat)defaultBackgroundVerticalPositionAdjustmentWhenContainedIn:(Class<UIAppearanceContainer>)containerClass {
    return [self backgroundVerticalPositionAdjustmentForBarMetrics:UIBarMetricsDefault whenContainedIn:containerClass];
}

+ (void)setDefaultBackgroundVerticalPositionAdjustment:(CGFloat)adjustment whenContainedIn:(Class<UIAppearanceContainer>)containerClass {
    [self setBackgroundVerticalPositionAdjustment:adjustment forBarMetrics:UIBarMetricsDefault whenContainedIn:containerClass];
}

+ (CGFloat)backgroundVerticalPositionAdjustmentForBarMetrics:(UIBarMetrics)barMetrics whenContainedIn:(Class<UIAppearanceContainer>)containerClass {
    return backgroundVerticalPositionAdjustmentForBarMetrics(APPEARANCE_IN_CLASS(containerClass), barMetrics);
}

+ (void)setBackgroundVerticalPositionAdjustment:(CGFloat)adjustment forBarMetrics:(UIBarMetrics)barMetrics whenContainedIn:(Class<UIAppearanceContainer>)containerClass {
    setBackgroundVerticalPositionAdjustmentForBarMetrics(APPEARANCE_IN_CLASS(containerClass), adjustment, barMetrics);
}

#pragma mark - titlePositionAdjustment -

- (UIOffset)defaultTitlePositionAdjustment {
    return titlePositionAdjustmentForBarMetrics(self, UIBarMetricsDefault);
}

- (void)setDefaultTitlePositionAdjustment:(UIOffset)adjustment {
    setTitlePositionAdjustmentForBarMetrics(self, adjustment, UIBarMetricsDefault);
}

+ (UIOffset)defaultTitlePositionAdjustment {
    return [self titlePositionAdjustmentForBarMetrics:UIBarMetricsDefault];
}

+ (void)setDefaultTitlePositionAdjustment:(UIOffset)adjustment {
    [self setTitlePositionAdjustment:adjustment forBarMetrics:UIBarMetricsDefault];
}

+ (UIOffset)titlePositionAdjustmentForBarMetrics:(UIBarMetrics)barMetrics {
    return titlePositionAdjustmentForBarMetrics(APPEARANCE, barMetrics);
}

+ (void)setTitlePositionAdjustment:(UIOffset)adjustment forBarMetrics:(UIBarMetrics)barMetrics {
    setTitlePositionAdjustmentForBarMetrics(APPEARANCE, adjustment, barMetrics);
}

+ (UIOffset)defaultTitlePositionAdjustmentWhenContainedIn:(Class<UIAppearanceContainer>)containerClass {
    return [self titlePositionAdjustmentForBarMetrics:UIBarMetricsDefault whenContainedIn:containerClass];
}

+ (void)setDefaultTitlePositionAdjustment:(UIOffset)adjustment whenContainedIn:(Class<UIAppearanceContainer>)containerClass {
    [self setTitlePositionAdjustment:adjustment forBarMetrics:UIBarMetricsDefault whenContainedIn:containerClass];
}

+ (UIOffset)titlePositionAdjustmentForBarMetrics:(UIBarMetrics)barMetrics whenContainedIn:(Class<UIAppearanceContainer>)containerClass {
    return titlePositionAdjustmentForBarMetrics(APPEARANCE_IN_CLASS(containerClass), barMetrics);
}

+ (void)setTitlePositionAdjustment:(UIOffset)adjustment forBarMetrics:(UIBarMetrics)barMetrics whenContainedIn:(Class<UIAppearanceContainer>)containerClass {
    setTitlePositionAdjustmentForBarMetrics(APPEARANCE_IN_CLASS(containerClass), adjustment, barMetrics);
}

#pragma mark - backButtonBackgroundImage -

- (UIImage *)defaultBackButtonBackgroundImage {
    return backButtonBackgroundImageForStateAndBarMetrics(self, UIControlStateNormal, UIBarMetricsDefault);
}

- (void)setDefaultBackButtonBackgroundImage:(UIImage *)backgroundImage {
    setBackButtonBackgroundImageForStateAndBarMetrics(self, backgroundImage, UIControlStateNormal, UIBarMetricsDefault);
}

+ (UIImage *)defaultBackButtonBackgroundImage {
    return [self backButtonBackgroundImageForState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
}

+ (void)setDefaultBackButtonBackgroundImage:(UIImage *)backgroundImage {
    [self setBackButtonBackgroundImage:backgroundImage forState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
}

+ (UIImage *)backButtonBackgroundImageForState:(UIControlState)state barMetrics:(UIBarMetrics)barMetrics {
    return backButtonBackgroundImageForStateAndBarMetrics(APPEARANCE, state, barMetrics);
}

+ (void)setBackButtonBackgroundImage:(UIImage *)backgroundImage forState:(UIControlState)state barMetrics:(UIBarMetrics)barMetrics {
    setBackButtonBackgroundImageForStateAndBarMetrics(APPEARANCE, backgroundImage, state, barMetrics);
}

+ (UIImage *)defaultBackButtonBackgroundImageWhenContainedIn:(Class<UIAppearanceContainer>)containerClass {
    return [self backButtonBackgroundImageForState:UIControlStateNormal barMetrics:UIBarMetricsDefault whenContainedIn:containerClass];
}

+ (void)setDefaultBackButtonBackgroundImage:(UIImage *)backgroundImage whenContainedIn:(Class<UIAppearanceContainer>)containerClass {
    [self setBackButtonBackgroundImage:backgroundImage forState:UIControlStateNormal barMetrics:UIBarMetricsDefault whenContainedIn:containerClass];
}

+ (UIImage *)backButtonBackgroundImageForState:(UIControlState)state barMetrics:(UIBarMetrics)barMetrics whenContainedIn:(Class<UIAppearanceContainer>)containerClass {
    return backButtonBackgroundImageForStateAndBarMetrics(APPEARANCE_IN_CLASS(containerClass), state, barMetrics);
}

+ (void)setBackButtonBackgroundImage:(UIImage *)backgroundImage forState:(UIControlState)state barMetrics:(UIBarMetrics)barMetrics whenContainedIn:(Class<UIAppearanceContainer>)containerClass {
    setBackButtonBackgroundImageForStateAndBarMetrics
    (APPEARANCE_IN_CLASS(containerClass), backgroundImage, state, barMetrics);
}

#pragma mark - backButtonBackgroundColor -

- (UIColor *)defaultBackButtonBackgroundColor {
    return [self backButtonBackgroundColorForState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
}

- (void)setDefaultBackButtonBackgroundColor:(UIColor *)backgroundColor {
    [self setBackButtonBackgroundColor:backgroundColor forState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
}

- (UIColor *)backButtonBackgroundColorForState:(UIControlState)state barMetrics:(UIBarMetrics)barMetrics {
    return backButtonBackgroundColorForStateAndBarMetrics(self, state, barMetrics);
}

- (void)setBackButtonBackgroundColor:(UIColor *)backgroundColor forState:(UIControlState)state barMetrics:(UIBarMetrics)barMetrics {
    setBackButtonBackgroundColorForStateAndBarMetrics(self, backgroundColor, state, barMetrics);
}

+ (UIColor *)defaultBackButtonBackgroundColor {
    return [self backButtonBackgroundColorForState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
}

+ (void)setDefaultBackButtonBackgroundColor:(UIColor *)backgroundColor {
    [self setBackButtonBackgroundColor:backgroundColor forState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
}

+ (UIColor *)backButtonBackgroundColorForState:(UIControlState)state barMetrics:(UIBarMetrics)barMetrics {
    return backButtonBackgroundColorForStateAndBarMetrics(APPEARANCE, state, barMetrics);
}

+ (void)setBackButtonBackgroundColor:(UIColor *)backgroundColor forState:(UIControlState)state barMetrics:(UIBarMetrics)barMetrics {
    setBackButtonBackgroundColorForStateAndBarMetrics(APPEARANCE, backgroundColor, state, barMetrics);
}

+ (UIColor *)defaultBackButtonBackgroundColorWhenContainedIn:(Class<UIAppearanceContainer>)containerClass {
    return [self backButtonBackgroundColorForState:UIControlStateNormal barMetrics:UIBarMetricsDefault whenContainedIn:containerClass];
}

+ (void)setDefaultBackButtonBackgroundColor:(UIColor *)backgroundColor whenContainedIn:(Class<UIAppearanceContainer>)containerClass {
    [self setBackButtonBackgroundColor:backgroundColor forState:UIControlStateNormal barMetrics:UIBarMetricsDefault whenContainedIn:containerClass];
}

+ (UIColor *)backButtonBackgroundColorForState:(UIControlState)state barMetrics:(UIBarMetrics)barMetrics whenContainedIn:(Class<UIAppearanceContainer>)containerClass {
    return backButtonBackgroundColorForStateAndBarMetrics(APPEARANCE_IN_CLASS(containerClass), state, barMetrics);
}

+ (void)setBackButtonBackgroundColor:(UIColor *)backgroundColor forState:(UIControlState)state barMetrics:(UIBarMetrics)barMetrics whenContainedIn:(Class<UIAppearanceContainer>)containerClass {
    setBackButtonBackgroundColorForStateAndBarMetrics
    (APPEARANCE_IN_CLASS(containerClass), backgroundColor, state, barMetrics);
}

#pragma mark - backButtonBackgroundVerticalPositionAdjustment -

- (CGFloat)defaultBackButtonBackgroundVerticalPositionAdjustment {
    return backButtonBackgroundVerticalPositionAdjustmentForBarMetrics(self, UIBarMetricsDefault);
}

- (void)setDefaultBackButtonBackgroundVerticalPositionAdjustment:(CGFloat)adjustment {
    setBackButtonBackgroundVerticalPositionAdjustmentForBarMetrics(self, adjustment, UIBarMetricsDefault);
}

+ (CGFloat)defaultBackButtonBackgroundVerticalPositionAdjustment {
    return [self backButtonBackgroundVerticalPositionAdjustmentForBarMetrics:UIBarMetricsDefault];
}

+ (void)setDefaultBackButtonBackgroundVerticalPositionAdjustment:(CGFloat)adjustment {
    [self setBackButtonBackgroundVerticalPositionAdjustment:adjustment forBarMetrics:UIBarMetricsDefault];
}

+ (CGFloat)backButtonBackgroundVerticalPositionAdjustmentForBarMetrics:(UIBarMetrics)barMetrics {
    return backButtonBackgroundVerticalPositionAdjustmentForBarMetrics(APPEARANCE, barMetrics);
}

+ (void)setBackButtonBackgroundVerticalPositionAdjustment:(CGFloat)adjustment forBarMetrics:(UIBarMetrics)barMetrics {
    setBackButtonBackgroundVerticalPositionAdjustmentForBarMetrics(APPEARANCE, adjustment, barMetrics);
}

+ (CGFloat)defaultBackButtonBackgroundVerticalPositionAdjustmentWhenContainedIn:(Class<UIAppearanceContainer>)containerClass {
    return [self backButtonBackgroundVerticalPositionAdjustmentForBarMetrics:UIBarMetricsDefault
                                                             whenContainedIn:containerClass];
}

+ (void)setDefaultBackButtonBackgroundVerticalPositionAdjustment:(CGFloat)adjustment whenContainedIn:(Class<UIAppearanceContainer>)containerClass {
    [self setBackButtonBackgroundVerticalPositionAdjustment:adjustment forBarMetrics:UIBarMetricsDefault
                                            whenContainedIn:containerClass];
}

+ (CGFloat)backButtonBackgroundVerticalPositionAdjustmentForBarMetrics:(UIBarMetrics)barMetrics whenContainedIn:(Class<UIAppearanceContainer>)containerClass {
    return backButtonBackgroundVerticalPositionAdjustmentForBarMetrics(APPEARANCE_IN_CLASS(containerClass), barMetrics);
}

+ (void)setBackButtonBackgroundVerticalPositionAdjustment:(CGFloat)adjustment forBarMetrics:(UIBarMetrics)barMetrics whenContainedIn:(Class<UIAppearanceContainer>)containerClass {
    setBackButtonBackgroundVerticalPositionAdjustmentForBarMetrics
    (APPEARANCE_IN_CLASS(containerClass), adjustment, barMetrics);
}

#pragma mark - backButtonTitlePositionAdjustment -

- (UIOffset)defaultBackButtonTitlePositionAdjustment {
    return backButtonTitlePositionAdjustmentForBarMetrics(self, UIBarMetricsDefault);
}

- (void)setDefaultBackButtonTitlePositionAdjustment:(UIOffset)adjustment {
    setBackButtonTitlePositionAdjustmentForBarMetrics(self, adjustment, UIBarMetricsDefault);
}

+ (UIOffset)defaultBackButtonTitlePositionAdjustment {
    return [self backButtonTitlePositionAdjustmentForBarMetrics:UIBarMetricsDefault];
}

+ (void)setDefaultBackButtonTitlePositionAdjustment:(UIOffset)adjustment {
    [self setBackButtonTitlePositionAdjustment:adjustment forBarMetrics:UIBarMetricsDefault];
}

+ (UIOffset)backButtonTitlePositionAdjustmentForBarMetrics:(UIBarMetrics)barMetrics {
    return backButtonTitlePositionAdjustmentForBarMetrics(APPEARANCE, barMetrics);
}

+ (void)setBackButtonTitlePositionAdjustment:(UIOffset)adjustment forBarMetrics:(UIBarMetrics)barMetrics {
    setBackButtonTitlePositionAdjustmentForBarMetrics(APPEARANCE, adjustment, barMetrics);
}

+ (UIOffset)defaultBackButtonTitlePositionAdjustmentWhenContainedIn:(Class<UIAppearanceContainer>)containerClass {
    return [self backButtonTitlePositionAdjustmentForBarMetrics:UIBarMetricsDefault whenContainedIn:containerClass];
}

+ (void)setDefaultBackButtonTitlePositionAdjustment:(UIOffset)adjustment whenContainedIn:(Class<UIAppearanceContainer>)containerClass {
    [self setBackButtonTitlePositionAdjustment:adjustment forBarMetrics:UIBarMetricsDefault whenContainedIn:containerClass];
}

+ (UIOffset)backButtonTitlePositionAdjustmentForBarMetrics:(UIBarMetrics)barMetrics whenContainedIn:(Class<UIAppearanceContainer>)containerClass {
    return backButtonTitlePositionAdjustmentForBarMetrics(APPEARANCE_IN_CLASS(containerClass), barMetrics);
}

+ (void)setBackButtonTitlePositionAdjustment:(UIOffset)adjustment forBarMetrics:(UIBarMetrics)barMetrics whenContainedIn:(Class<UIAppearanceContainer>)containerClass {
    setBackButtonTitlePositionAdjustmentForBarMetrics(APPEARANCE_IN_CLASS(containerClass), adjustment, barMetrics);
}

#pragma mark - text attributes with container -

+ (UIFont *)textFontForState:(UIControlState)state whenContainedIn:(Class<UIAppearanceContainer>)containerClass {
    return titleTextAttributeForStateAndKey(APPEARANCE_IN_CLASS(containerClass), state, NSFontAttributeName);
}

+ (void)setTextFont:(UIFont *)textFont forState:(UIControlState)state whenContainedIn:(Class<UIAppearanceContainer>)containerClass {
    setTitleTextAttributeForStateAndKey(APPEARANCE_IN_CLASS(containerClass), state, NSFontAttributeName, textFont);
}

+ (UIColor *)textColorForState:(UIControlState)state whenContainedIn:(Class<UIAppearanceContainer>)containerClass {
    return titleTextAttributeForStateAndKey(APPEARANCE_IN_CLASS(containerClass), state, NSForegroundColorAttributeName);
}

+ (void)setTextColor:(UIColor *)textColor forState:(UIControlState)state whenContainedIn:(Class<UIAppearanceContainer>)containerClass {
    setTitleTextAttributeForStateAndKey(APPEARANCE_IN_CLASS(containerClass), state, NSForegroundColorAttributeName, textColor);
}

+ (UIColor *)textShadowColorForState:(UIControlState)state whenContainedIn:(Class<UIAppearanceContainer>)containerClass {
    return titleShadowAttributeForState(APPEARANCE_IN_CLASS(containerClass), state).shadowColor;
}

+ (void)setTextShadowColor:(UIColor *)textShadowColor forState:(UIControlState)state whenContainedIn:(Class<UIAppearanceContainer>)containerClass {
    NSShadow *shadow = defaultTitleShadowAttributeForState(APPEARANCE_IN_CLASS(containerClass), state);
    shadow.shadowColor = textShadowColor;
    setTitleShadowAttributeForState(APPEARANCE_IN_CLASS(containerClass), state, shadow);
}

+ (CGSize)textShadowOffsetForState:(UIControlState)state whenContainedIn:(Class<UIAppearanceContainer>)containerClass {
    return titleShadowAttributeForState(APPEARANCE_IN_CLASS(containerClass), state).shadowOffset;
}

+ (void)setTextShadowOffset:(CGSize)textShadowOffset forState:(UIControlState)state whenContainedIn:(Class<UIAppearanceContainer>)containerClass {
    NSShadow *shadow = defaultTitleShadowAttributeForState(APPEARANCE_IN_CLASS(containerClass), state);
    shadow.shadowOffset = textShadowOffset;
    setTitleShadowAttributeForState(APPEARANCE_IN_CLASS(containerClass), state, shadow);
}

+ (CGFloat)textShadowSizeForState:(UIControlState)state whenContainedIn:(Class<UIAppearanceContainer>)containerClass {
    return titleShadowAttributeForState(APPEARANCE_IN_CLASS(containerClass), state).shadowBlurRadius;
}

+ (void)setTextShadowSize:(CGFloat)textShadowSize forState:(UIControlState)state whenContainedIn:(Class<UIAppearanceContainer>)containerClass {
    NSShadow *shadow = defaultTitleShadowAttributeForState(APPEARANCE_IN_CLASS(containerClass), state);
    shadow.shadowBlurRadius = textShadowSize;
    setTitleShadowAttributeForState(APPEARANCE_IN_CLASS(containerClass), state, shadow);
}

@end
