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
+ (double)DOUBLE; // default between 0..1
+ (double (^)(double max))DOUBLE_UNDER;
+ (float)FLOAT; // default between 0..1
+ (float (^)(float max))FLOAT_UNDER;
+ (CGFloat)CGFLOAT; // default between 0..1
+ (CGFloat (^)(CGFloat max))CGFLOAT_UNDER;
+ (unsigned long)LONG;
+ (unsigned long (^)(unsigned long max))LONG_UNDER;
+ (unsigned int)INT;
+ (unsigned int (^)(unsigned int max))INT_UNDER;
+ (NSUInteger)UINTEGER;
+ (NSUInteger (^)(NSUInteger max))UINTEGER_UNDER;

+ (NSString *(^)(int count))ASCII;
+ (NSString *(^)(int count))NUM;
+ (NSString *(^)(int count))LETTERS;
+ (NSString *(^)(int count))ALPHANUMERIC;

+ (CGPoint)CGPOINT; // default x&y between 0..1
+ (CGPoint (^)(CGRect rect))CGPOINT_IN;

+ (UIColor *)UICOLOR_RGB;
+ (UIColor *)UICOLOR_RGBA; // random alpha
+ (UIColor *(^)(CGFloat alpha))UICOLOR_ALPHA;

+ (NSString *)UIFONT_NAME;
+ (UIFont *)UIFONT; // default size between 10..20
+ (UIFont *(^)(CGFloat minSize, CGFloat maxSize))UIFONT_LIMITIN;
@end

#endif /* AGXCore_AGXRandom_h */
