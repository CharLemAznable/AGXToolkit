//
//  UIView+AGXWidget.h
//  AGXWidget
//
//  Created by Char Aznable on 2016/2/24.
//  Copyright © 2016年 AI-CUC-EC. All rights reserved.
//

#ifndef AGXWidget_UIView_AGXWidgetBadge_h
#define AGXWidget_UIView_AGXWidgetBadge_h

#import <UIKit/UIKit.h>
#import <AGXCore/AGXCore/AGXArc.h>
#import <AGXCore/AGXCore/AGXCategory.h>

@category_interface(UIView, AGXWidgetBadge)
- (void)showBadge;
- (void)showBadgeWithString:(NSString *)string;
- (void)hideBadge;

// default text font <font-family: ".SFUIText-Regular"; font-weight: normal; font-style: normal; font-size: 13.00pt>
@property (nonatomic, AGX_STRONG) UIFont   *badgeTextFont   UI_APPEARANCE_SELECTOR;
+ (UIFont *)badgeTextFont;
+ (void)setBadgeTextFont:(UIFont *)badgeTextFont;

// default text color [UIColor whiteColor]
@property (nonatomic, AGX_STRONG) UIColor  *badgeTextColor  UI_APPEARANCE_SELECTOR;
+ (UIColor *)badgeTextColor;
+ (void)setBadgeTextColor:(UIColor *)badgeTextColor;

// default color [UIColor redColor]
@property (nonatomic, AGX_STRONG) UIColor  *badgeColor      UI_APPEARANCE_SELECTOR;
+ (UIColor *)badgeColor;
+ (void)setBadgeColor:(UIColor *)badgeColor;

// default offset (0, 0), center position (bounds.size.width, badgeSize/4).
@property (nonatomic)             CGSize    badgeOffset     UI_APPEARANCE_SELECTOR;
+ (CGSize)badgeOffset;
+ (void)setBadgeOffset:(CGSize)badgeOffset;

// default size 8, badge is a circle of radius 4. Effect badge size when badgeValue is nil or empty.
@property (nonatomic)             CGFloat   badgeSize       UI_APPEARANCE_SELECTOR;
+ (CGFloat)badgeSize;
+ (void)setBadgeSize:(CGFloat)badgeSize;
@end

#endif /* AGXWidget_UIView_AGXWidgetBadge_h */
