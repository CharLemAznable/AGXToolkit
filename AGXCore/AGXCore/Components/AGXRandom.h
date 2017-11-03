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
+ (bool (^)(void))BOOLEAN;
+ (double (^)(void))DOUBLE; // default between 0..1
+ (double (^)(double max))DOUBLE_UNDER;
+ (float (^)(void))FLOAT; // default between 0..1
+ (float (^)(float max))FLOAT_UNDER;
+ (CGFloat (^)(void))CGFLOAT; // default between 0..1
+ (CGFloat (^)(CGFloat max))CGFLOAT_UNDER;
+ (unsigned long (^)(void))LONG;
+ (unsigned long (^)(unsigned long max))LONG_UNDER;
+ (unsigned int (^)(void))INT;
+ (unsigned int (^)(unsigned int max))INT_UNDER;
+ (NSUInteger (^)(void))UINTEGER;
+ (NSUInteger (^)(NSUInteger max))UINTEGER_UNDER;

+ (NSString *(^)(int count))ASCII;
+ (NSString *(^)(int count))NUM;
+ (NSString *(^)(int count))LETTERS;
+ (NSString *(^)(int count))ALPHANUMERIC;

+ (CGPoint (^)(void))CGPOINT; // default x&y between 0..1
+ (CGPoint (^)(CGRect rect))CGPOINT_IN;

+ (UIColor *(^)(void))UICOLOR_RGB;
+ (UIColor *(^)(void))UICOLOR_RGBA; // random alpha
+ (UIColor *(^)(CGFloat alpha))UICOLOR_ALPHA;

+ (NSString *(^)(void))UIFONT_NAME;
+ (UIFont *(^)(void))UIFONT; // default size between 10..20
+ (UIFont *(^)(CGFloat minSize, CGFloat maxSize))UIFONT_LIMITIN;
@end

#endif /* AGXCore_AGXRandom_h */
