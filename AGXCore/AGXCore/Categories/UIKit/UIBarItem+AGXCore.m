//
//  UIBarItem+AGXCore.m
//  AGXCore
//
//  Created by Char Aznable on 16/2/17.
//  Copyright © 2016年 AI-CUC-EC. All rights reserved.
//

#import "UIBarItem+AGXCore.h"
#import "AGXGeometry.h"
#import "AGXAppearance.h"

@category_implementation(UIBarItem, AGXCore)

#pragma mark - textFont -

- (UIFont *)textFontForState:(UIControlState)state {
    return titleTextAttributeForStateAndKey(self, state, AGXFontAttributeName);
}

- (void)setTextFont:(UIFont *)textFont forState:(UIControlState)state {
    setTitleTextAttributeForStateAndKey(self, state, AGXFontAttributeName, textFont);
}

+ (UIFont *)textFontForState:(UIControlState)state {
    return titleTextAttributeForStateAndKey(APPEARANCE, state, AGXFontAttributeName);
}

+ (void)setTextFont:(UIFont *)textFont forState:(UIControlState)state {
    setTitleTextAttributeForStateAndKey(APPEARANCE, state, AGXFontAttributeName, textFont);
}

#pragma mark - textColor -

- (UIColor *)textColorForState:(UIControlState)state {
    return titleTextAttributeForStateAndKey(self, state, AGXForegroundColorAttributeName);
}

- (void)setTextColor:(UIColor *)textColor forState:(UIControlState)state {
    setTitleTextAttributeForStateAndKey(self, state, AGXForegroundColorAttributeName, textColor);
}

+ (UIColor *)textColorForState:(UIControlState)state {
    return titleTextAttributeForStateAndKey(APPEARANCE, state, AGXForegroundColorAttributeName);
}

+ (void)setTextColor:(UIColor *)textColor forState:(UIControlState)state {
    setTitleTextAttributeForStateAndKey(APPEARANCE, state, AGXForegroundColorAttributeName, textColor);
}

#pragma mark - textShadowColor -

- (UIColor *)textShadowColorForState:(UIControlState)state {
    return
#if __IPHONE_OS_VERSION_MIN_REQUIRED < 60000
    BEFORE_IOS6 ? titleTextAttributeForStateAndKey(self, state, UITextAttributeTextShadowColor) :
#endif
    titleShadowAttributeForState(self, state).shadowColor;
}

- (void)setTextShadowColor:(UIColor *)textShadowColor forState:(UIControlState)state {
#if __IPHONE_OS_VERSION_MIN_REQUIRED < 60000
    if (BEFORE_IOS6) {
        setTitleTextAttributeForStateAndKey(self, state, UITextAttributeTextShadowColor, textShadowColor);
        return;
    }
#endif
    NSShadow *shadow = defaultTitleShadowAttributeForState(self, state);
    [shadow setShadowColor:textShadowColor];
    setTitleShadowAttributeForState(self, state, shadow);
}

+ (UIColor *)textShadowColorForState:(UIControlState)state {
    return
#if __IPHONE_OS_VERSION_MIN_REQUIRED < 60000
    BEFORE_IOS6 ? titleTextAttributeForStateAndKey(APPEARANCE, state, UITextAttributeTextShadowColor) :
#endif
    titleShadowAttributeForState(APPEARANCE, state).shadowColor;
}

+ (void)setTextShadowColor:(UIColor *)textShadowColor forState:(UIControlState)state {
#if __IPHONE_OS_VERSION_MIN_REQUIRED < 60000
    if (BEFORE_IOS6) {
        setTitleTextAttributeForStateAndKey(APPEARANCE, state, UITextAttributeTextShadowColor, textShadowColor);
        return;
    }
#endif
    NSShadow *shadow = defaultTitleShadowAttributeForState(APPEARANCE, state);
    [shadow setShadowColor:textShadowColor];
    setTitleShadowAttributeForState(APPEARANCE, state, shadow);
}

#pragma mark - textShadowOffset -

- (CGSize)textShadowOffsetForState:(UIControlState)state {
    return
#if __IPHONE_OS_VERSION_MIN_REQUIRED < 60000
    BEFORE_IOS6 ? AGX_CGSizeFromUIOffset
    ([titleTextAttributeForStateAndKey(self, state, UITextAttributeTextShadowOffset) UIOffsetValue]) :
#endif
    titleShadowAttributeForState(self, state).shadowOffset;
}

- (void)setTextShadowOffset:(CGSize)textShadowOffset forState:(UIControlState)state {
#if __IPHONE_OS_VERSION_MIN_REQUIRED < 60000
    if (BEFORE_IOS6) {
        setTitleTextAttributeForStateAndKey(self, state, UITextAttributeTextShadowOffset,
                                            [NSValue valueWithUIOffset:AGX_UIOffsetFromCGSize(textShadowOffset)]);
        return;
    }
#endif
    NSShadow *shadow = defaultTitleShadowAttributeForState(self, state);
    [shadow setShadowOffset:textShadowOffset];
    setTitleShadowAttributeForState(self, state, shadow);
}

+ (CGSize)textShadowOffsetForState:(UIControlState)state {
    return
#if __IPHONE_OS_VERSION_MIN_REQUIRED < 60000
    BEFORE_IOS6 ? AGX_CGSizeFromUIOffset
    ([titleTextAttributeForStateAndKey(APPEARANCE, state, UITextAttributeTextShadowOffset) UIOffsetValue]) :
#endif
    titleShadowAttributeForState(APPEARANCE, state).shadowOffset;
}

+ (void)setTextShadowOffset:(CGSize)textShadowOffset forState:(UIControlState)state {
#if __IPHONE_OS_VERSION_MIN_REQUIRED < 60000
    if (BEFORE_IOS6) {
        setTitleTextAttributeForStateAndKey(APPEARANCE, state, UITextAttributeTextShadowOffset,
                                            [NSValue valueWithUIOffset:AGX_UIOffsetFromCGSize(textShadowOffset)]);
        return;
    }
#endif
    NSShadow *shadow = defaultTitleShadowAttributeForState(APPEARANCE, state);
    [shadow setShadowOffset:textShadowOffset];
    setTitleShadowAttributeForState(APPEARANCE, state, shadow);
}

#pragma mark - textShadowSize -

- (CGFloat)textShadowSizeForState:(UIControlState)state {
    return
#if __IPHONE_OS_VERSION_MIN_REQUIRED < 60000
    BEFORE_IOS6 ? 0 :
#endif
    titleShadowAttributeForState(self, state).shadowBlurRadius;
}

- (void)setTextShadowSize:(CGFloat)textShadowSize forState:(UIControlState)state {
#if __IPHONE_OS_VERSION_MIN_REQUIRED < 60000
    if (BEFORE_IOS6) return;
#endif
    NSShadow *shadow = defaultTitleShadowAttributeForState(self, state);
    [shadow setShadowBlurRadius:textShadowSize];
    setTitleShadowAttributeForState(self, state, shadow);
}

+ (CGFloat)textShadowSizeForState:(UIControlState)state {
    return
#if __IPHONE_OS_VERSION_MIN_REQUIRED < 60000
    BEFORE_IOS6 ? 0 :
#endif
    titleShadowAttributeForState(APPEARANCE, state).shadowBlurRadius;
}

+ (void)setTextShadowSize:(CGFloat)textShadowSize forState:(UIControlState)state {
#if __IPHONE_OS_VERSION_MIN_REQUIRED < 60000
    if (BEFORE_IOS6) return;
#endif
    NSShadow *shadow = defaultTitleShadowAttributeForState(APPEARANCE, state);
    [shadow setShadowBlurRadius:textShadowSize];
    setTitleShadowAttributeForState(APPEARANCE, state, shadow);
}

@end
