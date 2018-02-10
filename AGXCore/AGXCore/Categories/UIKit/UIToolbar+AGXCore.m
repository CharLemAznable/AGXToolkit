//
//  UIToolbar+AGXCore.m
//  AGXCore
//
//  Created by Char Aznable on 2018/2/10.
//  Copyright © 2018年 AI-CUC-EC. All rights reserved.
//

#import "UIToolbar+AGXCore.h"
#import "AGXAppearance.h"

@category_implementation(UIToolbar, AGXCore)

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
    return [self backgroundImageForBarMetrics:UIBarMetricsDefault];
}

- (void)setDefaultBackgroundImage:(UIImage *)backgroundImage {
    [self setBackgroundImage:backgroundImage forBarMetrics:UIBarMetricsDefault];
}

+ (UIImage *)defaultBackgroundImage {
    return [self backgroundImageForBarMetrics:UIBarMetricsDefault];
}

+ (void)setDefaultBackgroundImage:(UIImage *)backgroundImage {
    [self setBackgroundImage:backgroundImage forBarMetrics:UIBarMetricsDefault];
}

- (UIImage *)backgroundImageForBarMetrics:(UIBarMetrics)barMetrics {
    return backgroundImageForToolbarPositionAndBarMetrics(self, UIBarPositionAny, barMetrics);
}

- (void)setBackgroundImage:(UIImage *)backgroundImage forBarMetrics:(UIBarMetrics)barMetrics {
    setBackgroundImageForToolbarPositionAndBarMetrics(self, backgroundImage, UIBarPositionAny, barMetrics);
}

+ (UIImage *)backgroundImageForBarMetrics:(UIBarMetrics)barMetrics {
    return [self backgroundImageForToolbarPosition:UIBarPositionAny barMetrics:barMetrics];
}

+ (void)setBackgroundImage:(UIImage *)backgroundImage forBarMetrics:(UIBarMetrics)barMetrics {
    [self setBackgroundImage:backgroundImage forToolbarPosition:UIBarPositionAny barMetrics:barMetrics];
}

+ (UIImage *)backgroundImageForToolbarPosition:(UIBarPosition)barPosition barMetrics:(UIBarMetrics)barMetrics {
    return backgroundImageForToolbarPositionAndBarMetrics(APPEARANCE, barPosition, barMetrics);
}

+ (void)setBackgroundImage:(UIImage *)backgroundImage forToolbarPosition:(UIBarPosition)barPosition barMetrics:(UIBarMetrics)barMetrics {
    setBackgroundImageForToolbarPositionAndBarMetrics(APPEARANCE, backgroundImage, barPosition, barMetrics);
}

- (UIImage *)currentBackgroundImage {
    return backgroundImageForToolbarPositionAndBarMetrics(self, self.barPosition, currentBarMetrics(nil))
    ?: backgroundImageForToolbarPositionAndBarMetrics(self, UIBarPositionAny, UIBarMetricsDefault);
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
    return [self backgroundColorForToolbarPosition:UIBarPositionAny barMetrics:barMetrics];
}

- (void)setBackgroundColor:(UIColor *)backgroundColor forBarMetrics:(UIBarMetrics)barMetrics {
    [self setBackgroundColor:backgroundColor forToolbarPosition:UIBarPositionAny barMetrics:barMetrics];
}

+ (UIColor *)backgroundColorForBarMetrics:(UIBarMetrics)barMetrics {
    return [self backgroundColorForToolbarPosition:UIBarPositionAny barMetrics:barMetrics];
}

+ (void)setBackgroundColor:(UIColor *)backgroundColor forBarMetrics:(UIBarMetrics)barMetrics {
    [self setBackgroundColor:backgroundColor forToolbarPosition:UIBarPositionAny barMetrics:barMetrics];
}

- (UIColor *)backgroundColorForToolbarPosition:(UIBarPosition)barPosition barMetrics:(UIBarMetrics)barMetrics {
    return backgroundColorForToolbarPositionAndBarMetrics(self, barPosition, barMetrics);
}

- (void)setBackgroundColor:(UIColor *)backgroundColor forToolbarPosition:(UIBarPosition)barPosition barMetrics:(UIBarMetrics)barMetrics {
    setBackgroundColorForToolbarPositionAndBarMetrics(self, backgroundColor, barPosition, barMetrics);
}

+ (UIColor *)backgroundColorForToolbarPosition:(UIBarPosition)barPosition barMetrics:(UIBarMetrics)barMetrics {
    return backgroundColorForToolbarPositionAndBarMetrics(APPEARANCE, barPosition, barMetrics);
}

+ (void)setBackgroundColor:(UIColor *)backgroundColor forToolbarPosition:(UIBarPosition)barPosition barMetrics:(UIBarMetrics)barMetrics {
    setBackgroundColorForToolbarPositionAndBarMetrics(APPEARANCE, backgroundColor, barPosition, barMetrics);
}

- (UIColor *)currentBackgroundColor {
    return backgroundColorForToolbarPositionAndBarMetrics(self, self.barPosition, currentBarMetrics(nil))
    ?: backgroundColorForToolbarPositionAndBarMetrics(self, UIBarPositionAny, UIBarMetricsDefault);
}

@end
