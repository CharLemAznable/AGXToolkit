//
//  NSNumber+AGXCore.h
//  AGXCore
//
//  Created by Char Aznable on 16/2/4.
//  Copyright © 2016年 AI-CUC-EC. All rights reserved.
//

#ifndef AGXCore_NSNumber_AGXCore_h
#define AGXCore_NSNumber_AGXCore_h

#import <Foundation/Foundation.h>
#import <CoreGraphics/CoreGraphics.h>
#import "AGXCategory.h"

@category_interface(NSNumber, AGXCore)
+ (NSNumber *)numberWithFloatFromVaList:(va_list)vaList;
+ (NSNumber *)numberWithDoubleFromVaList:(va_list)vaList;

+ (NSNumber *)numberWithCGFloat:(CGFloat)value;
+ (NSNumber *)numberWithCGFloatFromVaList:(va_list)vaList;
- (AGX_INSTANCETYPE)initWithCGFloat:(CGFloat)value;
- (CGFloat)cgfloatValue;
@end

@category_interface(NSString, AGXCoreNSNumber)
- (CGFloat)cgfloatValue;
@end

#endif /* AGXCore_NSNumber_AGXCore_h */
