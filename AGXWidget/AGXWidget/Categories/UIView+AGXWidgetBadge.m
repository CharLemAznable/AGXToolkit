//
//  UIView+AGXWidget.m
//  AGXWidget
//
//  Created by Char Aznable on 2016/2/24.
//  Copyright © 2016年 AI-CUC-EC. All rights reserved.
//

#import <AGXCore/AGXCore/NSObject+AGXCore.h>
#import <AGXCore/AGXCore/NSNull+AGXCore.h>
#import <AGXCore/AGXCore/NSString+AGXCore.h>
#import <AGXCore/AGXCore/NSNumber+AGXCore.h>
#import <AGXCore/AGXCore/UIView+AGXCore.h>
#import <AGXCore/AGXCore/UILabel+AGXCore.h>
#import "UIView+AGXWidgetBadge.h"

#define APPEARANCE [self appearance]

static NSInteger const AGX_BADGE_TAG = 2147520;

NSString *const agxBadgeTextFontKVOKey  = @"agxbadgeTextFont";
NSString *const agxBadgeTextColorKVOKey = @"agxbadgeTextColor";
NSString *const agxBadgeColorKVOKey     = @"agxbadgeColor";
NSString *const agxBadgeOffsetKVOKey    = @"agxbadgeOffset";
NSString *const agxBadgeSizeKVOKey      = @"agxbadgeSize";

@category_implementation(UIView, AGXWidgetBadge)

- (void)showBadge {
    [self showBadgeWithString:nil];
}

- (void)showBadgeWithString:(NSString *)string {
    [self hideBadge];
    self.masksToBounds = NO;

    UILabel *badgeLabel = UILabel.instance;
    badgeLabel.tag = AGX_BADGE_TAG;
    badgeLabel.backgroundColor = self.badgeColor;
    badgeLabel.masksToBounds = YES;
    [self addSubview:badgeLabel];

    CGSize offset = self.badgeOffset;
    if ([NSNull isNotNull:string] && [string isNotEmpty]) {
        badgeLabel.text = string;
        badgeLabel.font = self.badgeTextFont;
        badgeLabel.textColor = self.badgeTextColor;
        badgeLabel.textAlignment = NSTextAlignmentCenter;

        CGSize size = [badgeLabel sizeThatFits:CGSizeMake(self.bounds.size.width, self.bounds.size.height)];
        badgeLabel.center = CGPointMake(self.bounds.size.width + offset.width, size.height / 4 + offset.height);
        badgeLabel.bounds = CGRectMake(0, 0, MAX(size.width + badgeLabel.font.pointSize / 2, size.height), size.height);
        badgeLabel.cornerRadius = size.height / 2;

    } else {
        CGFloat badgeSize = self.badgeSize;
        badgeLabel.center = CGPointMake(self.bounds.size.width + offset.width, badgeSize / 4 + offset.height);
        badgeLabel.bounds = CGRectMake(0, 0, badgeSize, badgeSize);
        badgeLabel.cornerRadius = badgeSize / 2;
    }
}

- (void)hideBadge {
    [[self viewWithTag:AGX_BADGE_TAG] removeFromSuperview];
}

- (UIFont *)badgeTextFont {
    return [self retainPropertyForAssociateKey:agxBadgeTextFontKVOKey] ?: [UIFont fontWithName:@".SFUIText-Regular" size:13];
}

- (void)setBadgeTextFont:(UIFont *)badgeTextFont {
    [self setKVORetainProperty:badgeTextFont forAssociateKey:agxBadgeTextFontKVOKey];

    ((UILabel *)[self viewWithTag:AGX_BADGE_TAG]).font = self.badgeTextFont;
}

+ (UIFont *)badgeTextFont {
    return [APPEARANCE badgeTextFont];
}

+ (void)setBadgeTextFont:(UIFont *)badgeTextFont {
    [APPEARANCE setBadgeTextFont:badgeTextFont];
}

- (UIColor *)badgeTextColor {
    return [self retainPropertyForAssociateKey:agxBadgeTextColorKVOKey] ?: [UIColor whiteColor];
}

- (void)setBadgeTextColor:(UIColor *)badgeTextColor {
    [self setKVORetainProperty:badgeTextColor forAssociateKey:agxBadgeTextColorKVOKey];

    ((UILabel *)[self viewWithTag:AGX_BADGE_TAG]).textColor = self.badgeTextColor;
}

+ (UIColor *)badgeTextColor {
    return [APPEARANCE badgeTextColor];
}

+ (void)setBadgeTextColor:(UIColor *)badgeTextColor {
    [APPEARANCE setBadgeTextColor:badgeTextColor];
}

- (UIColor *)badgeColor {
    return [self retainPropertyForAssociateKey:agxBadgeColorKVOKey] ?: [UIColor redColor];
}

- (void)setBadgeColor:(UIColor *)badgeColor {
    [self setKVORetainProperty:badgeColor forAssociateKey:agxBadgeColorKVOKey];

    [self viewWithTag:AGX_BADGE_TAG].backgroundColor = self.badgeColor;
}

+ (UIColor *)badgeColor {
    return [APPEARANCE badgeColor];
}

+ (void)setBadgeColor:(UIColor *)badgeColor {
    [APPEARANCE setBadgeColor:badgeColor];
}

- (CGSize)badgeOffset {
    NSValue *badgeOffset = [self retainPropertyForAssociateKey:agxBadgeOffsetKVOKey];
    return badgeOffset ? [badgeOffset CGSizeValue] : CGSizeZero;
}

- (void)setBadgeOffset:(CGSize)badgeOffset {
    CGSize oriOffset = self.badgeOffset;
    CGPoint center = [self viewWithTag:AGX_BADGE_TAG].center;

    [self setKVORetainProperty:[NSValue valueWithCGSize:badgeOffset] forAssociateKey:agxBadgeOffsetKVOKey];

    [self viewWithTag:AGX_BADGE_TAG].center = CGPointMake(center.x - oriOffset.width + badgeOffset.width,
                                                          center.y - oriOffset.height + badgeOffset.height);
}

+ (CGSize)badgeOffset {
    return [APPEARANCE badgeOffset];
}

+ (void)setBadgeOffset:(CGSize)badgeOffset {
    [APPEARANCE setBadgeOffset:badgeOffset];
}

- (CGFloat)badgeSize {
    NSNumber *badgeSize = [self retainPropertyForAssociateKey:agxBadgeSizeKVOKey];
    return badgeSize ? [badgeSize cgfloatValue] : 8;
}

- (void)setBadgeSize:(CGFloat)badgeSize {
    [self setKVORetainProperty:[NSNumber numberWithCGFloat:badgeSize] forAssociateKey:agxBadgeSizeKVOKey];

    if (!((UILabel *)[self viewWithTag:AGX_BADGE_TAG]).text) {
        [self viewWithTag:AGX_BADGE_TAG].bounds = CGRectMake(0, 0, badgeSize, badgeSize);
        [self viewWithTag:AGX_BADGE_TAG].cornerRadius = badgeSize / 2;
    }
}

+ (CGFloat)badgeSize {
    return [APPEARANCE badgeSize];
}

+ (void)setBadgeSize:(CGFloat)badgeSize {
    [APPEARANCE setBadgeSize:badgeSize];
}

#pragma mark - swizzle

- (void)AGXWidgetBadge_UIView_dealloc {
    [self setRetainProperty:NULL forAssociateKey:agxBadgeTextFontKVOKey];
    [self setRetainProperty:NULL forAssociateKey:agxBadgeTextColorKVOKey];
    [self setRetainProperty:NULL forAssociateKey:agxBadgeColorKVOKey];
    [self setRetainProperty:NULL forAssociateKey:agxBadgeOffsetKVOKey];
    [self setRetainProperty:NULL forAssociateKey:agxBadgeSizeKVOKey];
    [self AGXWidgetBadge_UIView_dealloc];
}

+ (void)load {
    agx_once
    (// dealloc badge's associate objects
     [UIView swizzleInstanceOriSelector:NSSelectorFromString(@"dealloc")
                        withNewSelector:@selector(AGXWidgetBadge_UIView_dealloc)];)
}

@end

#undef APPEARANCE
