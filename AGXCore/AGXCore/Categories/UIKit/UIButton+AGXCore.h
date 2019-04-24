//
//  UIButton+AGXCore.h
//  AGXCore
//
//  Created by Char Aznable on 2016/5/10.
//  Copyright © 2016 github.com/CharLemAznable. All rights reserved.
//

#ifndef AGXCore_UIButton_AGXCore_h
#define AGXCore_UIButton_AGXCore_h

#import <UIKit/UIKit.h>
#import "AGXCategory.h"

@category_interface(UIButton, AGXCore)
+ (UIImage *)backgroundImageForState:(UIControlState)state;
+ (void)setBackgroundImage:(UIImage *)image forState:(UIControlState)state;

- (UIColor *)backgroundColorForState:(UIControlState)state UI_APPEARANCE_SELECTOR;
- (void)setBackgroundColor:(UIColor *)color forState:(UIControlState)state UI_APPEARANCE_SELECTOR;
+ (UIColor *)backgroundColorForState:(UIControlState)state;
+ (void)setBackgroundColor:(UIColor *)color forState:(UIControlState)state;
@end

#endif /* AGXCore_UIButton_AGXCore_h */
