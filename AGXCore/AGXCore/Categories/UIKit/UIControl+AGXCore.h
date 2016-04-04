//
//  UIControl+AGXCore.h
//  AGXCore
//
//  Created by Char Aznable on 16/2/17.
//  Copyright © 2016年 AI-CUC-EC. All rights reserved.
//

#ifndef AGXCore_UIControl_AGXCore_h
#define AGXCore_UIControl_AGXCore_h

#import <UIKit/UIKit.h>
#import "AGXCategory.h"

AGX_EXTERN float AGXMinOperationInterval;

@category_interface(UIControl, AGXCore)
- (CGFloat)borderWidthForState:(UIControlState)state UI_APPEARANCE_SELECTOR;
- (void)setBorderWidth:(CGFloat)width forState:(UIControlState)state UI_APPEARANCE_SELECTOR;
+ (CGFloat)borderWidthForState:(UIControlState)state;
+ (void)setBorderWidth:(CGFloat)width forState:(UIControlState)state;

- (UIColor *)borderColorForState:(UIControlState)state UI_APPEARANCE_SELECTOR;
- (void)setBorderColor:(UIColor *)color forState:(UIControlState)state UI_APPEARANCE_SELECTOR;
+ (UIColor *)borderColorForState:(UIControlState)state;
+ (void)setBorderColor:(UIColor *)color forState:(UIControlState)state;

- (UIColor *)shadowColorForState:(UIControlState)state UI_APPEARANCE_SELECTOR;
- (void)setShadowColor:(UIColor *)color forState:(UIControlState)state UI_APPEARANCE_SELECTOR;
+ (UIColor *)shadowColorForState:(UIControlState)state;
+ (void)setShadowColor:(UIColor *)color forState:(UIControlState)state;

- (float)shadowOpacityForState:(UIControlState)state UI_APPEARANCE_SELECTOR;
- (void)setShadowOpacity:(float)opacity forState:(UIControlState)state UI_APPEARANCE_SELECTOR;
+ (float)shadowOpacityForState:(UIControlState)state;
+ (void)setShadowOpacity:(float)opacity forState:(UIControlState)state;

- (CGSize)shadowOffsetForState:(UIControlState)state UI_APPEARANCE_SELECTOR;
- (void)setShadowOffset:(CGSize)offset forState:(UIControlState)state UI_APPEARANCE_SELECTOR;
+ (CGSize)shadowOffsetForState:(UIControlState)state;
+ (void)setShadowOffset:(CGSize)offset forState:(UIControlState)state;

- (CGFloat)shadowSizeForState:(UIControlState)state UI_APPEARANCE_SELECTOR;
- (void)setShadowSize:(CGFloat)size forState:(UIControlState)state UI_APPEARANCE_SELECTOR;
+ (CGFloat)shadowSizeForState:(UIControlState)state;
+ (void)setShadowSize:(CGFloat)size forState:(UIControlState)state;

@property (nonatomic) NSTimeInterval acceptEventInterval;
@end

#endif /* AGXCore_UIControl_AGXCore_h */
