//
//  UINavigationBar+AGXCore.m
//  AGXCore
//
//  Created by Char Aznable on 2016/2/17.
//  Copyright © 2016 github.com/CharLemAznable. All rights reserved.
//

#import "UINavigationBar+AGXCore.h"
#import "AGXGeometry.h"
#import "UIView+AGXCore.h"
#import "AGXAppearance.h"

@category_implementation(UINavigationBar, AGXCore)

- (UINavigationController *)navigationController {
    UIResponder *responder = self.nextResponder;
    while (responder) {
        if ([responder isKindOfClass:UINavigationController.class])
            return (UINavigationController *)responder;
        responder = responder.nextResponder;
    }
    return nil;
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

- (UIImage *)defaultBackgroundImage {
    return backgroundImageForBarPositionAndBarMetrics(self, UIBarPositionAny, UIBarMetricsDefault);
}

- (void)setDefaultBackgroundImage:(UIImage *)backgroundImage {
    setBackgroundImageForBarPositionAndBarMetrics(self, backgroundImage, UIBarPositionAny, UIBarMetricsDefault);
}

+ (UIImage *)defaultBackgroundImage {
    return [self backgroundImageForBarMetrics:UIBarMetricsDefault];
}

+ (void)setDefaultBackgroundImage:(UIImage *)backgroundImage {
    [self setBackgroundImage:backgroundImage forBarMetrics:UIBarMetricsDefault];
}

+ (UIImage *)backgroundImageForBarMetrics:(UIBarMetrics)barMetrics {
    return [self backgroundImageForBarPosition:UIBarPositionAny barMetrics:barMetrics];
}

+ (void)setBackgroundImage:(UIImage *)backgroundImage forBarMetrics:(UIBarMetrics)barMetrics {
    [self setBackgroundImage:backgroundImage forBarPosition:UIBarPositionAny barMetrics:barMetrics];
}

+ (UIImage *)backgroundImageForBarPosition:(UIBarPosition)barPosition barMetrics:(UIBarMetrics)barMetrics {
    return backgroundImageForBarPositionAndBarMetrics(APPEARANCE, barPosition, barMetrics);
}

+ (void)setBackgroundImage:(UIImage *)backgroundImage forBarPosition:(UIBarPosition)barPosition barMetrics:(UIBarMetrics)barMetrics {
    setBackgroundImageForBarPositionAndBarMetrics(APPEARANCE, backgroundImage, barPosition, barMetrics);
}

- (UIImage *)currentBackgroundImage {
    return backgroundImageForBarPositionAndBarMetrics(self, self.barPosition, currentBarMetrics(self.topItem.prompt))
    ?: backgroundImageForBarPositionAndBarMetrics(self, UIBarPositionAny, UIBarMetricsDefault);
}

#pragma mark - backgroundColor -

- (UIColor *)defaultBackgroundColor {
    return [self backgroundColorForBarMetrics:UIBarMetricsDefault];
}

- (void)setDefaultBackgroundColor:(UIColor *)backgroundColor {
    [self setBackgroundColor:backgroundColor forBarMetrics:UIBarMetricsDefault];
}

+ (UIColor *)defaultBackgroundColor {
    return [self backgroundColorForBarMetrics:UIBarMetricsDefault];
}

+ (void)setDefaultBackgroundColor:(UIColor *)backgroundColor {
    [self setBackgroundColor:backgroundColor forBarMetrics:UIBarMetricsDefault];
}

- (UIColor *)backgroundColorForBarMetrics:(UIBarMetrics)barMetrics {
    return [self backgroundColorForBarPosition:UIBarPositionAny barMetrics:barMetrics];
}

- (void)setBackgroundColor:(UIColor *)backgroundColor forBarMetrics:(UIBarMetrics)barMetrics {
    [self setBackgroundColor:backgroundColor forBarPosition:UIBarPositionAny barMetrics:barMetrics];
}

+ (UIColor *)backgroundColorForBarMetrics:(UIBarMetrics)barMetrics {
    return [self backgroundColorForBarPosition:UIBarPositionAny barMetrics:barMetrics];
}

+ (void)setBackgroundColor:(UIColor *)backgroundColor forBarMetrics:(UIBarMetrics)barMetrics {
    [self setBackgroundColor:backgroundColor forBarPosition:UIBarPositionAny barMetrics:barMetrics];
}

- (UIColor *)backgroundColorForBarPosition:(UIBarPosition)barPosition barMetrics:(UIBarMetrics)barMetrics {
    return backgroundColorForBarPositionAndBarMetrics(self, barPosition, barMetrics);
}

- (void)setBackgroundColor:(UIColor *)backgroundColor forBarPosition:(UIBarPosition)barPosition barMetrics:(UIBarMetrics)barMetrics {
    setBackgroundColorForBarPositionAndBarMetrics(self, backgroundColor, barPosition, barMetrics);
}

+ (UIColor *)backgroundColorForBarPosition:(UIBarPosition)barPosition barMetrics:(UIBarMetrics)barMetrics {
    return backgroundColorForBarPositionAndBarMetrics(APPEARANCE, barPosition, barMetrics);
}

+ (void)setBackgroundColor:(UIColor *)backgroundColor forBarPosition:(UIBarPosition)barPosition barMetrics:(UIBarMetrics)barMetrics {
    setBackgroundColorForBarPositionAndBarMetrics(APPEARANCE, backgroundColor, barPosition, barMetrics);
}

- (UIColor *)currentBackgroundColor {
    return backgroundColorForBarPositionAndBarMetrics(self, self.barPosition, currentBarMetrics(self.topItem.prompt))
    ?: backgroundColorForBarPositionAndBarMetrics(self, UIBarPositionAny, UIBarMetricsDefault);
}

+ (UIImage *)shadowImage {
    return [APPEARANCE shadowImage];
}

+ (void)setShadowImage:(UIImage *)shadowImage {
    [APPEARANCE setShadowImage:shadowImage];
}

#pragma mark - textFont -

- (UIFont *)textFont {
    return titleTextAttributeForKey(self, NSFontAttributeName);
}

- (void)setTextFont:(UIFont *)textFont {
    setTitleTextAttributeForKey(self, NSFontAttributeName, textFont);
}

+ (UIFont *)textFont {
    return titleTextAttributeForKey(APPEARANCE, NSFontAttributeName);
}

+ (void)setTextFont:(UIFont *)textFont {
    setTitleTextAttributeForKey(APPEARANCE, NSFontAttributeName, textFont);
}

#pragma mark - textColor -

- (UIColor *)textColor {
    return titleTextAttributeForKey(self, NSForegroundColorAttributeName);
}

- (void)setTextColor:(UIColor *)textColor {
    setTitleTextAttributeForKey(self, NSForegroundColorAttributeName, textColor);
}

+ (UIColor *)textColor {
    return titleTextAttributeForKey(APPEARANCE, NSForegroundColorAttributeName);
}

+ (void)setTextColor:(UIColor *)textColor {
    setTitleTextAttributeForKey(APPEARANCE, NSForegroundColorAttributeName, textColor);
}

#pragma mark - textShadowColor -

- (UIColor *)textShadowColor {
    return titleShadowAttribute(self).shadowColor;
}

- (void)setTextShadowColor:(UIColor *)textShadowColor {
    NSShadow *shadow = defaultTitleShadowAttribute(self);
    shadow.shadowColor = textShadowColor;
    setTitleShadowAttribute(self, shadow);
}

+ (UIColor *)textShadowColor {
    return titleShadowAttribute(APPEARANCE).shadowColor;
}

+ (void)setTextShadowColor:(UIColor *)textShadowColor {
    NSShadow *shadow = defaultTitleShadowAttribute(APPEARANCE);
    shadow.shadowColor = textShadowColor;
    setTitleShadowAttribute(APPEARANCE, shadow);
}

#pragma mark - textShadowOffset -

- (CGSize)textShadowOffset {
    return titleShadowAttribute(self).shadowOffset;
}

- (void)setTextShadowOffset:(CGSize)textShadowOffset {
    NSShadow *shadow = defaultTitleShadowAttribute(self);
    shadow.shadowOffset = textShadowOffset;
    setTitleShadowAttribute(self, shadow);
}

+ (CGSize)textShadowOffset {
    return titleShadowAttribute(APPEARANCE).shadowOffset;
}

+ (void)setTextShadowOffset:(CGSize)textShadowOffset {
    NSShadow *shadow = defaultTitleShadowAttribute(APPEARANCE);
    shadow.shadowOffset = textShadowOffset;
    setTitleShadowAttribute(APPEARANCE, shadow);
}

#pragma mark - textShadowSize -

- (CGFloat)textShadowSize {
    return titleShadowAttribute(self).shadowBlurRadius;
}

- (void)setTextShadowSize:(CGFloat)textShadowSize {
    NSShadow *shadow = defaultTitleShadowAttribute(self);
    shadow.shadowBlurRadius = textShadowSize;
    setTitleShadowAttribute(self, shadow);
}

+ (CGFloat)textShadowSize {
    return titleShadowAttribute(APPEARANCE).shadowBlurRadius;
}

+ (void)setTextShadowSize:(CGFloat)textShadowSize {
    NSShadow *shadow = defaultTitleShadowAttribute(APPEARANCE);
    shadow.shadowBlurRadius = textShadowSize;
    setTitleShadowAttribute(APPEARANCE, shadow);
}

+ (UIImage *)backIndicatorImage {
    return [APPEARANCE backIndicatorImage];
}

+ (void)setBackIndicatorImage:(UIImage *)backIndicatorImage {
    [APPEARANCE setBackIndicatorImage:backIndicatorImage];
}

+ (UIImage *)backIndicatorTransitionMaskImage {
    return [APPEARANCE backIndicatorTransitionMaskImage];
}

+ (void)setBackIndicatorTransitionMaskImage:(UIImage *)backIndicatorTransitionMaskImage {
    [APPEARANCE setBackIndicatorTransitionMaskImage:backIndicatorTransitionMaskImage];
}

@end
