//
//  AGXAppearance.h
//  AGXCore
//
//  Created by Char Aznable on 2016/2/17.
//  Copyright © 2016 github.com/CharLemAznable. All rights reserved.
//

#ifndef AGXCore_AGXAppearance_h
#define AGXCore_AGXAppearance_h

#import "AGXArc.h"
#import "AGXAdapt.h"
#import "NSObject+AGXCore.h"
#import "UIImage+AGXCore.h"

#define APPEARANCE                  [self appearance]
#define APPEARANCE_IN_CLASS(clz)    [self appearanceWhenContainedInInstancesOfClasses:@[(clz)]]

#pragma mark - titleTextAttribute -

AGX_STATIC_INLINE id titleTextAttributeForKey(id instance, NSString *key) {
    return [instance titleTextAttributes][key];
}

AGX_STATIC_INLINE void setTitleTextAttributeForKey(id instance, NSString *key, id value) {
    NSMutableDictionary *attributes = [NSMutableDictionary dictionaryWithDictionary:
                                       [instance titleTextAttributes]];
    attributes[key] = value;
    [instance setTitleTextAttributes:attributes];
}

AGX_STATIC_INLINE NSShadow *titleShadowAttribute(id instance) {
    return titleTextAttributeForKey(instance, NSShadowAttributeName);
}

AGX_STATIC_INLINE NSShadow *defaultTitleShadowAttribute(id instance) {
    return titleShadowAttribute(instance) ?: NSShadow.instance;
}

AGX_STATIC_INLINE void setTitleShadowAttribute(id instance, NSShadow *shadow) {
    setTitleTextAttributeForKey(instance, NSShadowAttributeName, shadow);
}

#pragma mark - titleTextAttributeForState -

AGX_STATIC_INLINE id titleTextAttributeForStateAndKey(id instance, UIControlState state, NSString *key) {
    return [instance titleTextAttributesForState:state][key];
}

AGX_STATIC_INLINE void setTitleTextAttributeForStateAndKey(id instance, UIControlState state, NSString *key, id value) {
    NSMutableDictionary *attributes = [NSMutableDictionary dictionaryWithDictionary:
                                       [instance titleTextAttributesForState:state]];
    attributes[key] = value;
    [instance setTitleTextAttributes:attributes forState:state];
}

AGX_STATIC_INLINE NSShadow *titleShadowAttributeForState(id instance, UIControlState state) {
    return titleTextAttributeForStateAndKey(instance, state, NSShadowAttributeName);
}

AGX_STATIC_INLINE NSShadow *defaultTitleShadowAttributeForState(id instance, UIControlState state) {
    return titleShadowAttributeForState(instance, state) ?: NSShadow.instance;
}

AGX_STATIC_INLINE void setTitleShadowAttributeForState(id instance, UIControlState state, NSShadow *shadow) {
    setTitleTextAttributeForStateAndKey(instance, state, NSShadowAttributeName, shadow);
}

#pragma mark - selectionIndicatorColor -

AGX_STATIC_INLINE UIColor *selectionIndicatorColor
(AGX_KINDOF(UITabBar *) instance) {
    return [instance selectionIndicatorImage].dominantColor;
}

AGX_STATIC_INLINE void setSelectionIndicatorColor
(AGX_KINDOF(UITabBar *) instance, UIColor *selectionIndicatorColor) {
    [instance setSelectionIndicatorImage:[UIImage imagePointWithColor:selectionIndicatorColor]];
}

#pragma mark - backgroundImageForBarPositionAndBarMetrics

AGX_STATIC_INLINE UIImage *backgroundImageForBarPositionAndBarMetrics
(AGX_KINDOF(UINavigationBar *) instance, UIBarPosition barPosition, UIBarMetrics barMetrics) {
    return [instance backgroundImageForBarPosition:barPosition barMetrics:barMetrics];
}

AGX_STATIC_INLINE void setBackgroundImageForBarPositionAndBarMetrics
(AGX_KINDOF(UINavigationBar *) instance, UIImage *backgroundImage, UIBarPosition barPosition, UIBarMetrics barMetrics) {
    [instance setBackgroundImage:backgroundImage forBarPosition:barPosition barMetrics:barMetrics];
}

#pragma mark - backgroundColorForBarPositionAndBarMetrics

AGX_STATIC_INLINE UIColor *backgroundColorForBarPositionAndBarMetrics
(AGX_KINDOF(UINavigationBar *) instance, UIBarPosition barPosition, UIBarMetrics barMetrics) {
    return [backgroundImageForBarPositionAndBarMetrics(instance, barPosition, barMetrics) dominantColor];
}

AGX_STATIC_INLINE void setBackgroundColorForBarPositionAndBarMetrics
(AGX_KINDOF(UINavigationBar *) instance, UIColor *backgroundColor, UIBarPosition barPosition, UIBarMetrics barMetrics) {
    setBackgroundImageForBarPositionAndBarMetrics(instance, [UIImage imagePointWithColor:backgroundColor], barPosition, barMetrics);
}

#pragma mark - backgroundImageForToolbarPositionAndBarMetrics

AGX_STATIC_INLINE UIImage *backgroundImageForToolbarPositionAndBarMetrics
(AGX_KINDOF(UIToolbar *) instance, UIBarPosition barPosition, UIBarMetrics barMetrics) {
    return [instance backgroundImageForToolbarPosition:barPosition barMetrics:barMetrics];
}

AGX_STATIC_INLINE void setBackgroundImageForToolbarPositionAndBarMetrics
(AGX_KINDOF(UIToolbar *) instance, UIImage *backgroundImage, UIBarPosition barPosition, UIBarMetrics barMetrics) {
    [instance setBackgroundImage:backgroundImage forToolbarPosition:barPosition barMetrics:barMetrics];
}

#pragma mark - backgroundColorForBarPositionAndBarMetrics

AGX_STATIC_INLINE UIColor *backgroundColorForToolbarPositionAndBarMetrics
(AGX_KINDOF(UIToolbar *) instance, UIBarPosition barPosition, UIBarMetrics barMetrics) {
    return [backgroundImageForToolbarPositionAndBarMetrics(instance, barPosition, barMetrics) dominantColor];
}

AGX_STATIC_INLINE void setBackgroundColorForToolbarPositionAndBarMetrics
(AGX_KINDOF(UIToolbar *) instance, UIColor *backgroundColor, UIBarPosition barPosition, UIBarMetrics barMetrics) {
    setBackgroundImageForToolbarPositionAndBarMetrics(instance, [UIImage imagePointWithColor:backgroundColor], barPosition, barMetrics);
}

#pragma mark - backgroundImageForStateAndBarMetrics -

AGX_STATIC_INLINE UIImage *backgroundImageForStateAndBarMetrics
(AGX_KINDOF(UIBarButtonItem *) instance, UIControlState state, UIBarMetrics barMetrics) {
    return [instance backgroundImageForState:state barMetrics:barMetrics];
}

AGX_STATIC_INLINE void setBackgroundImageForStateAndBarMetrics
(AGX_KINDOF(UIBarButtonItem *) instance, UIImage *backgroundImage, UIControlState state, UIBarMetrics barMetrics) {
    [instance setBackgroundImage:backgroundImage forState:state barMetrics:barMetrics];
}

#pragma mark - backgroundColorForStateAndBarMetrics -

AGX_STATIC_INLINE UIColor *backgroundColorForStateAndBarMetrics
(AGX_KINDOF(UIBarButtonItem *) instance, UIControlState state, UIBarMetrics barMetrics) {
    return [backgroundImageForStateAndBarMetrics(instance, state, barMetrics) dominantColor];
}

AGX_STATIC_INLINE void setBackgroundColorForStateAndBarMetrics
(AGX_KINDOF(UIBarButtonItem *) instance, UIColor *backgroundColor, UIControlState state, UIBarMetrics barMetrics) {
    setBackgroundImageForStateAndBarMetrics(instance, [UIImage imagePointWithColor:backgroundColor], state, barMetrics);
}

#pragma mark - backgroundImageForStateAndStyleAndBarMetrics -

AGX_STATIC_INLINE UIImage *backgroundImageForStateAndStyleAndBarMetrics
(AGX_KINDOF(UIBarButtonItem *) instance, UIControlState state, UIBarButtonItemStyle style, UIBarMetrics barMetrics) {
    return [instance backgroundImageForState:state style:style barMetrics:barMetrics];
}

AGX_STATIC_INLINE void setBackgroundImageForStateAndStyleAndBarMetrics
(AGX_KINDOF(UIBarButtonItem *) instance, UIImage *backgroundImage, UIControlState state, UIBarButtonItemStyle style, UIBarMetrics barMetrics) {
    [instance setBackgroundImage:backgroundImage forState:state style:style barMetrics:barMetrics];
}

#pragma mark - backgroundColorForStateAndStyleAndBarMetrics -

AGX_STATIC_INLINE UIColor *backgroundColorForStateAndStyleAndBarMetrics
(AGX_KINDOF(UIBarButtonItem *) instance, UIControlState state, UIBarButtonItemStyle style, UIBarMetrics barMetrics) {
    return [backgroundImageForStateAndStyleAndBarMetrics(instance, state, style, barMetrics) dominantColor];
}

AGX_STATIC_INLINE void setBackgroundColorForStateAndStyleAndBarMetrics
(AGX_KINDOF(UIBarButtonItem *) instance, UIColor *backgroundColor, UIControlState state, UIBarButtonItemStyle style, UIBarMetrics barMetrics) {
    setBackgroundImageForStateAndStyleAndBarMetrics
    (instance, [UIImage imagePointWithColor:backgroundColor], state, style, barMetrics);
}

#pragma mark - backgroundVerticalPositionAdjustment -

AGX_STATIC_INLINE CGFloat backgroundVerticalPositionAdjustmentForBarMetrics
(AGX_KINDOF(UIBarButtonItem *) instance, UIBarMetrics barMetrics) {
    return [instance backgroundVerticalPositionAdjustmentForBarMetrics:barMetrics];
}

AGX_STATIC_INLINE void setBackgroundVerticalPositionAdjustmentForBarMetrics
(AGX_KINDOF(UIBarButtonItem *) instance, CGFloat adjustment, UIBarMetrics barMetrics) {
    [instance setBackgroundVerticalPositionAdjustment:adjustment forBarMetrics:barMetrics];
}

#pragma mark - titlePositionAdjustment -

AGX_STATIC_INLINE UIOffset titlePositionAdjustmentForBarMetrics
(AGX_KINDOF(UIBarButtonItem *) instance, UIBarMetrics barMetrics) {
    return [instance titlePositionAdjustmentForBarMetrics:barMetrics];
}

AGX_STATIC_INLINE void setTitlePositionAdjustmentForBarMetrics
(AGX_KINDOF(UIBarButtonItem *) instance, UIOffset adjustment, UIBarMetrics barMetrics) {
    [instance setTitlePositionAdjustment:adjustment forBarMetrics:barMetrics];
}

#pragma mark - backButtonBackgroundImage -

AGX_STATIC_INLINE UIImage *backButtonBackgroundImageForStateAndBarMetrics
(AGX_KINDOF(UIBarButtonItem *) instance, UIControlState state, UIBarMetrics barMetrics) {
    return [instance backButtonBackgroundImageForState:state barMetrics:barMetrics];
}

AGX_STATIC_INLINE void setBackButtonBackgroundImageForStateAndBarMetrics
(AGX_KINDOF(UIBarButtonItem *) instance, UIImage *backgroundImage, UIControlState state, UIBarMetrics barMetrics) {
    [instance setBackButtonBackgroundImage:backgroundImage forState:state barMetrics:barMetrics];
}

#pragma mark - backButtonBackgroundColor -

AGX_STATIC_INLINE UIColor *backButtonBackgroundColorForStateAndBarMetrics
(AGX_KINDOF(UIBarButtonItem *) instance, UIControlState state, UIBarMetrics barMetrics) {
    return [backButtonBackgroundImageForStateAndBarMetrics(instance, state, barMetrics) dominantColor];
}

AGX_STATIC_INLINE void setBackButtonBackgroundColorForStateAndBarMetrics
(AGX_KINDOF(UIBarButtonItem *) instance, UIColor *backgroundColor, UIControlState state, UIBarMetrics barMetrics) {
    setBackButtonBackgroundImageForStateAndBarMetrics
    (instance, [UIImage imagePointWithColor:backgroundColor], state, barMetrics);
}

#pragma mark - backButtonBackgroundVerticalPositionAdjustment -

AGX_STATIC_INLINE CGFloat backButtonBackgroundVerticalPositionAdjustmentForBarMetrics
(AGX_KINDOF(UIBarButtonItem *) instance, UIBarMetrics barMetrics) {
    return [instance backButtonBackgroundVerticalPositionAdjustmentForBarMetrics:barMetrics];
}

AGX_STATIC_INLINE void setBackButtonBackgroundVerticalPositionAdjustmentForBarMetrics
(AGX_KINDOF(UIBarButtonItem *) instance, CGFloat adjustment, UIBarMetrics barMetrics) {
    [instance setBackButtonBackgroundVerticalPositionAdjustment:adjustment forBarMetrics:barMetrics];
}

#pragma mark - backButtonTitlePositionAdjustment -

AGX_STATIC_INLINE UIOffset backButtonTitlePositionAdjustmentForBarMetrics
(AGX_KINDOF(UIBarButtonItem *) instance, UIBarMetrics barMetrics) {
    return [instance backButtonTitlePositionAdjustmentForBarMetrics:barMetrics];
}

AGX_STATIC_INLINE void setBackButtonTitlePositionAdjustmentForBarMetrics
(AGX_KINDOF(UIBarButtonItem *) instance, UIOffset adjustment, UIBarMetrics barMetrics) {
    [instance setBackButtonTitlePositionAdjustment:adjustment forBarMetrics:barMetrics];
}

#pragma mark - current UIBarMetrics

AGX_STATIC_INLINE UIBarMetrics currentBarMetrics(id prompt) {
    switch (UIApplication.sharedApplication.statusBarOrientation) {
        case UIInterfaceOrientationPortrait:
        case UIInterfaceOrientationPortraitUpsideDown:
            return prompt ? UIBarMetricsDefaultPrompt : UIBarMetricsDefault;
        case UIInterfaceOrientationLandscapeLeft:
        case UIInterfaceOrientationLandscapeRight:
            return prompt ? UIBarMetricsCompactPrompt : UIBarMetricsCompact;
        case UIInterfaceOrientationUnknown:
            return UIBarMetricsDefault;
    }
}

#endif /* AGXCore_AGXAppearance_h */
