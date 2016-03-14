//
//  UIColor+AGXCore.h
//  AGXCore
//
//  Created by Char Aznable on 16/2/17.
//  Copyright © 2016年 AI-CUC-EC. All rights reserved.
//

#ifndef AGXCore_UIColor_AGXCore_h
#define AGXCore_UIColor_AGXCore_h

#import <UIKit/UIKit.h>
#import "AGXCategory.h"

typedef NS_ENUM(NSInteger, AGXColorShade) {
    AGXColorShadeUnmeasured = 0,
    AGXColorShadeLight      = 1,
    AGXColorShadeDark       = -1
};

@category_interface(UIColor, AGXCore)
// Convenience methods for creating autoreleased colors with integer between 0 and 255
+ (UIColor *)colorWithIntegerRed:(NSUInteger)red green:(NSUInteger)green blue:(NSUInteger)blue;
// Convenience methods for creating autoreleased colors with integer between 0 and 255
+ (UIColor *)colorWithIntegerRed:(NSUInteger)red green:(NSUInteger)green blue:(NSUInteger)blue alpha:(NSUInteger)alpha;
// Convenience methods for creating autoreleased colors with HEX String like "ff3344"
+ (UIColor *)colorWithRGBHexString:(NSString *)hexString;
// Convenience methods for creating autoreleased colors with HEX String like "ff3344ff"
+ (UIColor *)colorWithRGBAHexString:(NSString *)hexString;

- (CGColorRef)rgbaCGColorRef;
- (AGXColorShade)colorShade;
- (BOOL)isEqualToColor:(UIColor *)color;
@end

#endif /* AGXCore_UIColor_AGXCore_h */
