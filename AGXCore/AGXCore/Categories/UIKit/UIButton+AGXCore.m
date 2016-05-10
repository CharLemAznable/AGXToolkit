//
//  UIButton+AGXCore.m
//  AGXCore
//
//  Created by Char Aznable on 16/5/10.
//  Copyright © 2016年 AI-CUC-EC. All rights reserved.
//

#import "UIButton+AGXCore.h"
#import "AGXAppearance.h"

@category_implementation(UIButton, AGXCore)

#pragma mark - backgroundImage

+ (UIImage *)backgroundImageForState:(UIControlState)state {
    return [APPEARANCE backgroundImageForState:state];
}

+ (void)setBackgroundImage:(UIImage *)image forState:(UIControlState)state {
    [APPEARANCE setBackgroundImage:image forState:state];
}

#pragma mark - backgroundColor

- (UIColor *)backgroundColorForState:(UIControlState)state {
    return [[self backgroundImageForState:state] dominantColor];
}

- (void)setBackgroundColor:(UIColor *)color forState:(UIControlState)state {
    [self setBackgroundImage:[UIImage imagePointWithColor:color] forState:state];
}

+ (UIColor *)backgroundColorForState:(UIControlState)state {
    return [APPEARANCE backgroundColorForState:state];
}

+ (void)setBackgroundColor:(UIColor *)color forState:(UIControlState)state {
    [APPEARANCE setBackgroundColor:color forState:state];
}

@end
