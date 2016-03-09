//
//  NSValue+AGXCore.h
//  AGXCore
//
//  Created by Char Aznable on 16/2/4.
//  Copyright © 2016年 AI-CUC-EC. All rights reserved.
//

#ifndef AGXCore_NSValue_AGXCore_h
#define AGXCore_NSValue_AGXCore_h

#import <UIKit/UIKit.h>
#import "AGXCategory.h"

@category_interface(NSValue, AGXCore)
- (id)valueForKey:(NSString *)key;
- (id)valueForKeyPath:(NSString *)keyPath;

+ (NSValue *)valueWithCGPointFromVaList:(va_list)vaList;
+ (NSValue *)valueWithCGVectorFromVaList:(va_list)vaList;
+ (NSValue *)valueWithCGSizeFromVaList:(va_list)vaList;
+ (NSValue *)valueWithCGRectFromVaList:(va_list)vaList;
+ (NSValue *)valueWithCGAffineTransformFromVaList:(va_list)vaList;
+ (NSValue *)valueWithUIEdgeInsetsFromVaList:(va_list)vaList;
+ (NSValue *)valueWithUIOffsetFromVaList:(va_list)vaList;
@end

#define struct_boxed_interface(structType)                      \
category_interface(NSValue, structType##Boxed)                  \
+ (NSValue *)valueWith##structType:(structType)value;           \
+ (NSValue *)valueWith##structType##FromVaList:(va_list)vaList; \
- (structType)structType##Value;                                \
@end

#define struct_boxed_implementation(structType)                 \
category_implementation(NSValue, structType##Boxed)             \
+ (NSValue *)valueWith##structType:(structType)value {          \
    return [NSValue valueWithBytes:&value                       \
            objCType:@encode(structType)];                      \
}                                                               \
+ (NSValue *)valueWith##structType##FromVaList:(va_list)vaList {\
    return [self valueWith##structType:                         \
            va_arg(vaList, structType)];                        \
}                                                               \
- (structType)structType##Value {                               \
    structType result;                                          \
    [self getValue:&result];                                    \
    return result;                                              \
}                                                               \
@end

#endif /* AGXCore_NSValue_AGXCore_h */
