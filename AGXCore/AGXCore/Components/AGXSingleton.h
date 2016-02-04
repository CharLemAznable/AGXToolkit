//
//  AGXSingleton.h
//  AGXCore
//
//  Created by Char Aznable on 16/2/4.
//  Copyright © 2016年 AI-CUC-EC. All rights reserved.
//

#ifndef AGXCore_AGXSingleton_h
#define AGXCore_AGXSingleton_h

#import "AGXObjC.h"
#import "AGXArc.h"

// singleton_interface
#define singleton_interface(className, superClassName)          \
interface className : superClassName                            \
+ (AGX_INSTANCETYPE)share##className;                           \
@end                                                            \
@interface className ()

// singleton_implementation
#define singleton_implementation(className)                     \
implementation className                                        \
static id _share##className;                                    \
+ (AGX_INSTANCETYPE)share##className {                          \
    static dispatch_once_t once_t;                              \
    dispatch_once(&once_t, ^{                                   \
        if (AGX_EXPECT_F(_share##className)) return;            \
        _share##className = [[self alloc] init];                \
    });                                                         \
    return _share##className;                                   \
}                                                               \
+ (AGX_INSTANCETYPE)allocWithZone:(struct _NSZone *)zone {      \
    static dispatch_once_t once_t;                              \
    __block id alloc = nil;                                     \
    dispatch_once(&once_t, ^{                                   \
        if (AGX_EXPECT_T(!_share##className))                   \
            _share##className = [super allocWithZone:zone];     \
        alloc = _share##className;                              \
    });                                                         \
    return alloc;                                               \
}                                                               \
- (id)copyWithZone:(struct _NSZone *)zone {                     \
    return AGX_RETAIN(self);                                    \
}                                                               \
- (id)mutableCopyWithZone:(struct _NSZone *)zone {              \
    return [self copyWithZone:zone];                            \
}

#endif /* AGXCore_AGXSingleton_h */
