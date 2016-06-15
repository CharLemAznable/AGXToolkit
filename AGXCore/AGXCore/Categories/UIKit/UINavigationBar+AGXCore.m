//
//  UINavigationBar+AGXCore.m
//  AGXCore
//
//  Created by Char Aznable on 16/2/17.
//  Copyright © 2016年 AI-CUC-EC. All rights reserved.
//

#import "UINavigationBar+AGXCore.h"
#import "AGXGeometry.h"
#import "UIView+AGXCore.h"
#import "AGXAppearance.h"

@category_implementation(UINavigationBar, AGXCore)

- (UINavigationController *)navigationController {
    UIResponder *responder = self.nextResponder;
    while (responder) {
        if ([responder isKindOfClass:[UINavigationController class]])
            return (UINavigationController *)responder;
        responder = responder.nextResponder;
    }
    return nil;
}

#pragma mark - translucent -

static BOOL AGXUINavigationBarTranslucent = YES;

+ (BOOL)isTranslucent {
    return AGX_BEFORE_IOS8 ? AGXUINavigationBarTranslucent : [APPEARANCE isTranslucent];
}

+ (void)setTranslucent:(BOOL)translucent {
    if (AGX_BEFORE_IOS8) {
        AGXUINavigationBarTranslucent = translucent;
        AGXCore_UINavigationBarTranslucentChanged();
    } else [APPEARANCE setTranslucent:translucent];
}

// initial with global translucent
- (void)agxInitial {
    [super agxInitial];
    if (AGX_BEFORE_IOS8) self.translucent = AGXUINavigationBarTranslucent;
}

// record all navigation bar
static NSHashTable *agxUINavigationBars = nil;
+ (AGX_INSTANCETYPE)AGXCore_allocWithZone:(struct _NSZone *)zone {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        agxUINavigationBars = AGX_RETAIN([NSHashTable weakObjectsHashTable]);
    });
    NSAssert([NSThread isMainThread], @"should on the main thread");
    id alloc = [self AGXCore_allocWithZone:zone];
    [agxUINavigationBars addObject:alloc];
    return alloc;
}

// set exists navigation bar's translucent
void AGXCore_UINavigationBarTranslucentChanged() {
    for (UINavigationBar *navigationBar in agxUINavigationBars) {
        navigationBar.translucent = AGXUINavigationBarTranslucent;
    }
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
    return [self backgroundColorForBarPosition:self.barPosition barMetrics:currentBarMetrics(self.topItem.prompt)]
    ?: [self backgroundColorForBarPosition:UIBarPositionAny barMetrics:UIBarMetricsDefault];
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
    [shadow setShadowColor:textShadowColor];
    setTitleShadowAttribute(self, shadow);
}

+ (UIColor *)textShadowColor {
    return titleShadowAttribute(APPEARANCE).shadowColor;
}

+ (void)setTextShadowColor:(UIColor *)textShadowColor {
    NSShadow *shadow = defaultTitleShadowAttribute(APPEARANCE);
    [shadow setShadowColor:textShadowColor];
    setTitleShadowAttribute(APPEARANCE, shadow);
}

#pragma mark - textShadowOffset -

- (CGSize)textShadowOffset {
    return titleShadowAttribute(self).shadowOffset;
}

- (void)setTextShadowOffset:(CGSize)textShadowOffset {
    NSShadow *shadow = defaultTitleShadowAttribute(self);
    [shadow setShadowOffset:textShadowOffset];
    setTitleShadowAttribute(self, shadow);
}

+ (CGSize)textShadowOffset {
    return titleShadowAttribute(APPEARANCE).shadowOffset;
}

+ (void)setTextShadowOffset:(CGSize)textShadowOffset {
    NSShadow *shadow = defaultTitleShadowAttribute(APPEARANCE);
    [shadow setShadowOffset:textShadowOffset];
    setTitleShadowAttribute(APPEARANCE, shadow);
}

#pragma mark - textShadowSize -

- (CGFloat)textShadowSize {
    return titleShadowAttribute(self).shadowBlurRadius;
}

- (void)setTextShadowSize:(CGFloat)textShadowSize {
    NSShadow *shadow = defaultTitleShadowAttribute(self);
    [shadow setShadowBlurRadius:textShadowSize];
    setTitleShadowAttribute(self, shadow);
}

+ (CGFloat)textShadowSize {
    return titleShadowAttribute(APPEARANCE).shadowBlurRadius;
}

+ (void)setTextShadowSize:(CGFloat)textShadowSize {
    NSShadow *shadow = defaultTitleShadowAttribute(APPEARANCE);
    [shadow setShadowBlurRadius:textShadowSize];
    setTitleShadowAttribute(APPEARANCE, shadow);
}

@end
