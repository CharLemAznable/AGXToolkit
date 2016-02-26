//
//  UIView+AGXWidget.m
//  AGXWidget
//
//  Created by Char Aznable on 16/2/24.
//  Copyright © 2016年 AI-CUC-EC. All rights reserved.
//

#import "UIView+AGXWidget.h"
#import <AGXCore/AGXCore/AGXAdapt.h>
#import <AGXCore/AGXCore/NSObject+AGXCore.h>
#import <AGXCore/AGXCore/NSNull+AGXCore.h>
#import <AGXCore/AGXCore/NSString+AGXCore.h>
#import <AGXCore/AGXCore/NSNumber+AGXCore.h>
#import <AGXCore/AGXCore/UIView+AGXCore.h>
#import <AGXCore/AGXCore/UILabel+AGXCore.h>

#define APPEARANCE [self appearance]

static NSInteger const AGX_BADGE_TAG = 2147520;

NSString *const agxBadgeTextFontKVOKey  = @"agxbadgeTextFont";
NSString *const agxBadgeTextColorKVOKey = @"agxbadgeTextColor";
NSString *const agxBadgeColorKVOKey     = @"agxbadgeColor";
NSString *const agxBadgeOffsetKVOKey    = @"agxbadgeOffset";
NSString *const agxBadgeSizeKVOKey      = @"agxbadgeSize";

@category_implementation(UIView, AGXWidget)

- (void)showBadge {
    [self showBadgeWithString:nil];
}

- (void)showBadgeWithString:(NSString *)string {
    [self hideBadge];
    self.masksToBounds = NO;
    
    UILabel *badgeLabel = AGX_AUTORELEASE([[UILabel alloc] init]);
    badgeLabel.tag = AGX_BADGE_TAG;
    badgeLabel.backgroundColor = self.badgeColor;
    badgeLabel.masksToBounds = YES;
    [self addSubview:badgeLabel];
    
    CGSize offset = self.badgeOffset;
    if ([NSNull isNotNull:string] && [string isNotEmpty]) {
        badgeLabel.text = string;
        badgeLabel.font = self.badgeTextFont;
        badgeLabel.textColor = self.badgeTextColor;
        badgeLabel.textAlignment = AGXTextAlignmentCenter;
        
        CGSize size = [badgeLabel sizeThatConstraintToSize:
                       CGSizeMake(self.bounds.size.width, self.bounds.size.height)];
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
    return [self propertyForAssociateKey:agxBadgeTextFontKVOKey] ?: [UIFont fontWithName:@".SFUIText-Regular" size:13];
}

- (void)setBadgeTextFont:(UIFont *)badgeTextFont {
    [self setProperty:badgeTextFont forAssociateKey:agxBadgeTextFontKVOKey];
    
    ((UILabel *)[self viewWithTag:AGX_BADGE_TAG]).font = self.badgeTextFont;
}

+ (UIFont *)badgeTextFont {
    return [APPEARANCE badgeTextFont];
}

+ (void)setBadgeTextFont:(UIFont *)badgeTextFont {
    [APPEARANCE setBadgeTextFont:badgeTextFont];
}

- (UIColor *)badgeTextColor {
    return [self propertyForAssociateKey:agxBadgeTextColorKVOKey] ?: [UIColor whiteColor];
}

- (void)setBadgeTextColor:(UIColor *)badgeTextColor {
    [self setProperty:badgeTextColor forAssociateKey:agxBadgeTextColorKVOKey];
    
    ((UILabel *)[self viewWithTag:AGX_BADGE_TAG]).textColor = self.badgeTextColor;
}

+ (UIColor *)badgeTextColor {
    return [APPEARANCE badgeTextColor];
}

+ (void)setBadgeTextColor:(UIColor *)badgeTextColor {
    [APPEARANCE setBadgeTextColor:badgeTextColor];
}

- (UIColor *)badgeColor {
    return [self propertyForAssociateKey:agxBadgeColorKVOKey] ?: [UIColor redColor];
}

- (void)setBadgeColor:(UIColor *)badgeColor {
    [self setProperty:badgeColor forAssociateKey:agxBadgeColorKVOKey];
    
    [self viewWithTag:AGX_BADGE_TAG].backgroundColor = self.badgeColor;
}

+ (UIColor *)badgeColor {
    return [APPEARANCE badgeColor];
}

+ (void)setBadgeColor:(UIColor *)badgeColor {
    [APPEARANCE setBadgeColor:badgeColor];
}

- (CGSize)badgeOffset {
    NSValue *badgeOffset = [self propertyForAssociateKey:agxBadgeOffsetKVOKey];
    return badgeOffset ? [badgeOffset CGSizeValue] : CGSizeZero;
}

- (void)setBadgeOffset:(CGSize)badgeOffset {
    CGSize oriOffset = self.badgeOffset;
    CGPoint center = [self viewWithTag:AGX_BADGE_TAG].center;
    
    [self setProperty:[NSValue valueWithCGSize:badgeOffset] forAssociateKey:agxBadgeOffsetKVOKey];
    
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
    NSNumber *badgeSize = [self propertyForAssociateKey:agxBadgeSizeKVOKey];
    return badgeSize ? [badgeSize cgfloatValue] : 8;
}

- (void)setBadgeSize:(CGFloat)badgeSize {
    [self setProperty:[NSNumber numberWithCGFloat:badgeSize] forAssociateKey:agxBadgeSizeKVOKey];
    
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

- (void)agx_dealloc_uiview_agxwidget {
    [self assignProperty:nil forAssociateKey:agxBadgeTextFontKVOKey];
    [self assignProperty:nil forAssociateKey:agxBadgeTextColorKVOKey];
    [self assignProperty:nil forAssociateKey:agxBadgeColorKVOKey];
    [self assignProperty:nil forAssociateKey:agxBadgeOffsetKVOKey];
    [self assignProperty:nil forAssociateKey:agxBadgeSizeKVOKey];
    
    [self agx_dealloc_uiview_agxwidget];
}

+ (void)load {
    static dispatch_once_t once_t;
    dispatch_once(&once_t, ^{
        // dealloc badge's associate objects
        [self swizzleInstanceOriSelector:NSSelectorFromString(@"dealloc")
                         withNewSelector:@selector(agx_dealloc_uiview_agxwidget)];
    });
}

@end
