//
//  AGXRandom.h
//  AGXCore
//
//  Created by Char Aznable on 2017/10/30.
//  Copyright © 2017年 AI-CUC-EC. All rights reserved.
//

#ifndef AGXCore_AGXRandom_h
#define AGXCore_AGXRandom_h

#import <UIKit/UIKit.h>

@interface AGXRandom : NSObject
+ (bool)BOOLEAN;
+ (unsigned int)INT;
+ (unsigned int (^)(unsigned int max))INT_UNDER;
+ (unsigned int (^)(unsigned int min, unsigned int max))INT_BETWEEN;
+ (unsigned long)LONG;
+ (unsigned long (^)(unsigned long max))LONG_UNDER;
+ (unsigned long (^)(unsigned long min, unsigned long max))LONG_BETWEEN;
+ (NSUInteger)UINTEGER;
+ (NSUInteger (^)(NSUInteger max))UINTEGER_UNDER;
+ (NSUInteger (^)(NSUInteger min, NSUInteger max))UINTEGER_BETWEEN;
+ (float)FLOAT; // default between 0..1
+ (float (^)(float max))FLOAT_UNDER;
+ (float (^)(float min, float max))FLOAT_BETWEEN;
+ (double)DOUBLE; // default between 0..1
+ (double (^)(double max))DOUBLE_UNDER;
+ (double (^)(double min, double max))DOUBLE_BETWEEN;
+ (CGFloat)CGFLOAT; // default between 0..1
+ (CGFloat (^)(CGFloat max))CGFLOAT_UNDER;
+ (CGFloat (^)(CGFloat min, CGFloat max))CGFLOAT_BETWEEN;

+ (NSString *(^)(int count))ASCII;
+ (NSString *(^)(int count))NUM;
+ (NSString *(^)(int count))LETTERS;
+ (NSString *(^)(int count))ALPHANUMERIC;
+ (NSString *(^)(int count, NSString *chars))CHARACTERS;

+ (CGPoint)CGPOINT; // default x&y between 0..1
+ (CGPoint (^)(CGRect rect))CGPOINT_IN;

+ (UIColor *)UICOLOR_RGB; // default alpha 1
+ (UIColor *(^)(CGFloat min, CGFloat max))UICOLOR_RGB_ALL_LIMITIN;
+ (UIColor *(^)(CGFloat minRed, CGFloat maxRed, CGFloat minGreen, CGFloat maxGreen, CGFloat minBlue, CGFloat maxBlue))UICOLOR_RGB_LIMITIN;
+ (UIColor *)UICOLOR_RGBA;
+ (UIColor *(^)(CGFloat min, CGFloat max))UICOLOR_RGBA_ALL_LIMITIN;
+ (UIColor *(^)(CGFloat minRed, CGFloat maxRed, CGFloat minGreen, CGFloat maxGreen, CGFloat minBlue, CGFloat maxBlue, CGFloat minAlpha, CGFloat maxAlpha))UICOLOR_RGBA_LIMITIN;

+ (NSString *)UIFONT_NAME;
+ (UIFont *)UIFONT; // default size between 10..20
+ (UIFont *(^)(CGFloat minSize, CGFloat maxSize))UIFONT_LIMITIN;
@end

#endif /* AGXCore_AGXRandom_h */
