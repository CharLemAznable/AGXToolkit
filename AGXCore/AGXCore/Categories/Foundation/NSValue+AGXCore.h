//
//  NSValue+AGXCore.h
//  AGXCore
//
//  Created by Char Aznable on 2016/2/4.
//  Copyright © 2016 github.com/CharLemAznable. All rights reserved.
//

#ifndef AGXCore_NSValue_AGXCore_h
#define AGXCore_NSValue_AGXCore_h

#import "AGXCategory.h"

@category_interface(NSValue, AGXCore)
- (id)valueForKey:(NSString *)key;
- (id)valueForKeyPath:(NSString *)keyPath;
@end

#define struct_boxed_interface(structType)                      \
category_interface(NSValue, structType##Boxed)                  \
+ (AGX_INSTANCETYPE)valueWith##structType:(structType)value;    \
- (structType)structType##Value;                                \
@end

#define struct_boxed_implementation(structType)                 \
category_implementation(NSValue, structType##Boxed)             \
+ (AGX_INSTANCETYPE)valueWith##structType:(structType)value {   \
    return [NSValue valueWithBytes:&value                       \
            objCType:@encode(structType)];                      \
}                                                               \
- (structType)structType##Value {                               \
    structType result;                                          \
    [self getValue:&result];                                    \
    return result;                                              \
}                                                               \
@end

#endif /* AGXCore_NSValue_AGXCore_h */
