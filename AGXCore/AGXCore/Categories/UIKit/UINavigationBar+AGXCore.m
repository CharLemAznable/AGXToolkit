//
//  UINavigationBar+AGXCore.m
//  AGXCore
//
//  Created by Char Aznable on 16/2/17.
//  Copyright © 2016年 AI-CUC-EC. All rights reserved.
//

#import "UINavigationBar+AGXCore.h"
#import "AGXGeometry.h"
#import "AGXAppearance.h"

@category_implementation(UINavigationBar, AGXCore)

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
    BEFORE_IOS7 ? nil :
#endif
    [APPEARANCE barTintColor];
}

+ (void)setBarTintColor:(UIColor *)barTintColor {
#if __IPHONE_OS_VERSION_MIN_REQUIRED < 70000
    if (BEFORE_IOS7) return;
#endif
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
    return [self backgroundColorForBarPosition:self.barPosition barMetrics:currentBarMetrics(self.topItem.prompt)]
    ?: [self backgroundColorForBarPosition:UIBarPositionAny barMetrics:UIBarMetricsDefault];
}

#pragma mark - textFont -

- (UIFont *)textFont {
    return titleTextAttributeForKey(self, AGXFontAttributeName);
}

- (void)setTextFont:(UIFont *)textFont {
    setTitleTextAttributeForKey(self, AGXFontAttributeName, textFont);
}

+ (UIFont *)textFont {
    return titleTextAttributeForKey(APPEARANCE, AGXFontAttributeName);
}

+ (void)setTextFont:(UIFont *)textFont {
    setTitleTextAttributeForKey(APPEARANCE, AGXFontAttributeName, textFont);
}

#pragma mark - textColor -

- (UIColor *)textColor {
    return titleTextAttributeForKey(self, AGXForegroundColorAttributeName);
}

- (void)setTextColor:(UIColor *)textColor {
    setTitleTextAttributeForKey(self, AGXForegroundColorAttributeName, textColor);
}

+ (UIColor *)textColor {
    return titleTextAttributeForKey(APPEARANCE, AGXForegroundColorAttributeName);
}

+ (void)setTextColor:(UIColor *)textColor {
    setTitleTextAttributeForKey(APPEARANCE, AGXForegroundColorAttributeName, textColor);
}

#pragma mark - textShadowColor -

- (UIColor *)textShadowColor {
    return
#if __IPHONE_OS_VERSION_MIN_REQUIRED < 60000
    BEFORE_IOS6 ? titleTextAttributeForKey(self, UITextAttributeTextShadowColor) :
#endif
    titleShadowAttribute(self).shadowColor;
}

- (void)setTextShadowColor:(UIColor *)textShadowColor {
#if __IPHONE_OS_VERSION_MIN_REQUIRED < 60000
    if (BEFORE_IOS6) {
        setTitleTextAttributeForKey
        (self, UITextAttributeTextShadowColor, textShadowColor);
        return;
    }
#endif
    NSShadow *shadow = defaultTitleShadowAttribute(self);
    [shadow setShadowColor:textShadowColor];
    setTitleShadowAttribute(self, shadow);
}

+ (UIColor *)textShadowColor {
    return
#if __IPHONE_OS_VERSION_MIN_REQUIRED < 60000
    BEFORE_IOS6 ? titleTextAttributeForKey(APPEARANCE, UITextAttributeTextShadowColor) :
#endif
    titleShadowAttribute(APPEARANCE).shadowColor;
}

+ (void)setTextShadowColor:(UIColor *)textShadowColor {
#if __IPHONE_OS_VERSION_MIN_REQUIRED < 60000
    if (BEFORE_IOS6) {
        setTitleTextAttributeForKey
        (APPEARANCE, UITextAttributeTextShadowColor, textShadowColor);
        return;
    }
#endif
    NSShadow *shadow = defaultTitleShadowAttribute(APPEARANCE);
    [shadow setShadowColor:textShadowColor];
    setTitleShadowAttribute(APPEARANCE, shadow);
}

#pragma mark - textShadowOffset -

- (CGSize)textShadowOffset {
    return
#if __IPHONE_OS_VERSION_MIN_REQUIRED < 60000
    BEFORE_IOS6 ? AGX_CGSizeFromUIOffset
    ([titleTextAttributeForKey(self, UITextAttributeTextShadowOffset) UIOffsetValue]) :
#endif
    titleShadowAttribute(self).shadowOffset;
}

- (void)setTextShadowOffset:(CGSize)textShadowOffset {
#if __IPHONE_OS_VERSION_MIN_REQUIRED < 60000
    if (BEFORE_IOS6) {
        setTitleTextAttributeForKey
        (self, UITextAttributeTextShadowOffset,
         [NSValue valueWithUIOffset:AGX_UIOffsetFromCGSize(textShadowOffset)]);
        return;
    }
#endif
    NSShadow *shadow = defaultTitleShadowAttribute(self);
    [shadow setShadowOffset:textShadowOffset];
    setTitleShadowAttribute(self, shadow);
}

+ (CGSize)textShadowOffset {
    return
#if __IPHONE_OS_VERSION_MIN_REQUIRED < 60000
    BEFORE_IOS6 ? AGX_CGSizeFromUIOffset
    ([titleTextAttributeForKey(APPEARANCE, UITextAttributeTextShadowOffset) UIOffsetValue]) :
#endif
    titleShadowAttribute(APPEARANCE).shadowOffset;
}

+ (void)setTextShadowOffset:(CGSize)textShadowOffset {
#if __IPHONE_OS_VERSION_MIN_REQUIRED < 60000
    if (BEFORE_IOS6) {
        setTitleTextAttributeForKey
        (APPEARANCE, UITextAttributeTextShadowOffset,
         [NSValue valueWithUIOffset:AGX_UIOffsetFromCGSize(textShadowOffset)]);
        return;
    }
#endif
    NSShadow *shadow = defaultTitleShadowAttribute(APPEARANCE);
    [shadow setShadowOffset:textShadowOffset];
    setTitleShadowAttribute(APPEARANCE, shadow);
}

#pragma mark - textShadowSize -

- (CGFloat)textShadowSize {
    return
#if __IPHONE_OS_VERSION_MIN_REQUIRED < 60000
    BEFORE_IOS6 ? 0 :
#endif
    titleShadowAttribute(self).shadowBlurRadius;
}

- (void)setTextShadowSize:(CGFloat)textShadowSize {
#if __IPHONE_OS_VERSION_MIN_REQUIRED < 60000
    if (BEFORE_IOS6) return;
#endif
    NSShadow *shadow = defaultTitleShadowAttribute(self);
    [shadow setShadowBlurRadius:textShadowSize];
    setTitleShadowAttribute(self, shadow);
}

+ (CGFloat)textShadowSize {
    return
#if __IPHONE_OS_VERSION_MIN_REQUIRED < 60000
    BEFORE_IOS6 ? 0 :
#endif
    titleShadowAttribute(APPEARANCE).shadowBlurRadius;
}

+ (void)setTextShadowSize:(CGFloat)textShadowSize {
#if __IPHONE_OS_VERSION_MIN_REQUIRED < 60000
    if (BEFORE_IOS6) return;
#endif
    NSShadow *shadow = defaultTitleShadowAttribute(APPEARANCE);
    [shadow setShadowBlurRadius:textShadowSize];
    setTitleShadowAttribute(APPEARANCE, shadow);
}

@end
