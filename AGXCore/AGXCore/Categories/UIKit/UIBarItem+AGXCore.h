//
//  UIBarItem+AGXCore.h
//  AGXCore
//
//  Created by Char Aznable on 2016/2/17.
//  Copyright © 2016年 AI-CUC-EC. All rights reserved.
//

#ifndef AGXCore_UIBarItem_AGXCore_h
#define AGXCore_UIBarItem_AGXCore_h

#import <UIKit/UIKit.h>
#import "AGXCategory.h"

@category_interface(UIBarItem, AGXCore)
- (UIFont *)textFontForState:(UIControlState)state;
- (void)setTextFont:(UIFont *)textFont forState:(UIControlState)state;
+ (UIFont *)textFontForState:(UIControlState)state;
+ (void)setTextFont:(UIFont *)textFont forState:(UIControlState)state;

- (UIColor *)textColorForState:(UIControlState)state;
- (void)setTextColor:(UIColor *)textColor forState:(UIControlState)state;
+ (UIColor *)textColorForState:(UIControlState)state;
+ (void)setTextColor:(UIColor *)textColor forState:(UIControlState)state;

- (UIColor *)textShadowColorForState:(UIControlState)state;
- (void)setTextShadowColor:(UIColor *)textShadowColor forState:(UIControlState)state;
+ (UIColor *)textShadowColorForState:(UIControlState)state;
+ (void)setTextShadowColor:(UIColor *)textShadowColor forState:(UIControlState)state;

- (CGSize)textShadowOffsetForState:(UIControlState)state;
- (void)setTextShadowOffset:(CGSize)textShadowOffset forState:(UIControlState)state;
+ (CGSize)textShadowOffsetForState:(UIControlState)state;
+ (void)setTextShadowOffset:(CGSize)textShadowOffset forState:(UIControlState)state;

- (CGFloat)textShadowSizeForState:(UIControlState)state;
- (void)setTextShadowSize:(CGFloat)textShadowSize forState:(UIControlState)state;
+ (CGFloat)textShadowSizeForState:(UIControlState)state;
+ (void)setTextShadowSize:(CGFloat)textShadowSize forState:(UIControlState)state;
@end

#endif /* AGXCore_UIBarItem_AGXCore_h */
