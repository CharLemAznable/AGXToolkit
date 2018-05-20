//
//  NSNumber+AGXCore.h
//  AGXCore
//
//  Created by Char Aznable on 2016/2/4.
//  Copyright © 2016年 AI-CUC-EC. All rights reserved.
//

#ifndef AGXCore_NSNumber_AGXCore_h
#define AGXCore_NSNumber_AGXCore_h

#import <CoreGraphics/CoreGraphics.h>
#import "AGXCategory.h"

@category_interface(NSNumber, AGXCore)
+ (AGX_INSTANCETYPE)numberWithCGFloat:(CGFloat)value;
- (AGX_INSTANCETYPE)initWithCGFloat:(CGFloat)value;
- (CGFloat)cgfloatValue;
@end

@category_interface(NSString, AGXCoreNSNumber)
- (CGFloat)cgfloatValue;
@end

#endif /* AGXCore_NSNumber_AGXCore_h */
