//
//  AGXRandom.h
//  AGXCore
//
//  Created by Char Aznable on 2017/10/30.
//  Copyright © 2017年 AI-CUC-EC. All rights reserved.
//

#ifndef AGXCore_AGXRandom_h
#define AGXCore_AGXRandom_h

#import <Foundation/Foundation.h>
#import <CoreGraphics/CoreGraphics.h>

@interface AGXRandom : NSObject
+ (bool (^)(void))BOOLEAN;
+ (double (^)(void))DOUBLE;
+ (float (^)(void))FLOAT;
+ (CGFloat (^)(void))CGFLOAT;
+ (unsigned long (^)(void))LONG;
+ (unsigned long (^)(long max))LONG_UNDER;
+ (unsigned int (^)(void))INT;
+ (unsigned int (^)(int max))INT_UNDER;
+ (NSUInteger (^)(void))UINTEGER;
+ (NSUInteger (^)(NSInteger max))UINTEGER_UNDER;

+ (NSString *(^)(int count))ASCII;
+ (NSString *(^)(int count))NUM;
+ (NSString *(^)(int count))LETTERS;
+ (NSString *(^)(int count))ALPHANUMERIC;
@end

#endif /* AGXCore_AGXRandom_h */
