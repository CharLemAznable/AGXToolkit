//
//  UIColor+AGXCore.h
//  AGXCore
//
//  Created by Char Aznable on 2016/2/17.
//  Copyright © 2016 github.com/CharLemAznable. All rights reserved.
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

@property (nonatomic, readonly) CGColorRef rgbaCGColorRef;
@property (nonatomic, readonly) CGFloat colorAlpha;
@property (nonatomic, readonly) AGXColorShade colorShade;
- (BOOL)isEqualToColor:(UIColor *)color;
@end

AGX_EXTERN AGX_OVERLOAD UIColor *AGXColor(NSUInteger red, NSUInteger green, NSUInteger blue);
AGX_EXTERN AGX_OVERLOAD UIColor *AGXColor(NSUInteger red, NSUInteger green, NSUInteger blue, NSUInteger alpha);
AGX_EXTERN AGX_OVERLOAD UIColor *AGXColor(NSString *hexString);

AGX_EXTERN AGX_OVERLOAD UIColor *AGX_UIColor(CGFloat red, CGFloat green, CGFloat blue);
AGX_EXTERN AGX_OVERLOAD UIColor *AGX_UIColor(CGFloat red, CGFloat green, CGFloat blue, CGFloat alpha);

#endif /* AGXCore_UIColor_AGXCore_h */
