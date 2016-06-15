//
//  AGXIvar.h
//  AGXRuntime
//
//  Created by Char Aznable on 16/2/19.
//  Copyright © 2016年 AI-CUC-EC. All rights reserved.
//

#ifndef AGXRuntime_AGXIvar_h
#define AGXRuntime_AGXIvar_h

#import <objc/runtime.h>
#import <AGXCore/AGXCore/AGXObjC.h>

@interface AGXIvar : NSObject
+ (AGX_INSTANCETYPE)ivarWithObjCIvar:(Ivar)ivar;
+ (AGX_INSTANCETYPE)instanceIvarWithName:(NSString *)name inClass:(Class)cls;
+ (AGX_INSTANCETYPE)classIvarWithName:(NSString *)name inClass:(Class)cls;
+ (AGX_INSTANCETYPE)instanceIvarWithName:(NSString *)name inClassNamed:(NSString *)className;
+ (AGX_INSTANCETYPE)classIvarWithName:(NSString *)name inClassNamed:(NSString *)className;
+ (AGX_INSTANCETYPE)ivarWithName:(NSString *)name typeEncoding:(NSString *)typeEncoding;
+ (AGX_INSTANCETYPE)ivarWithName:(NSString *)name encode:(const char *)encodeStr;

- (AGX_INSTANCETYPE)initWithObjCIvar:(Ivar)ivar;
- (AGX_INSTANCETYPE)initInstanceIvarWithName:(NSString *)name inClass:(Class)cls;
- (AGX_INSTANCETYPE)initClassIvarWithName:(NSString *)name inClass:(Class)cls;
- (AGX_INSTANCETYPE)initInstanceIvarWithName:(NSString *)name inClassNamed:(NSString *)className;
- (AGX_INSTANCETYPE)initClassIvarWithName:(NSString *)name inClassNamed:(NSString *)className;
- (AGX_INSTANCETYPE)initWithName:(NSString *)name typeEncoding:(NSString *)typeEncoding;

- (NSString *)name;
- (NSString *)typeName;
- (NSString *)typeEncoding;
- (ptrdiff_t)offset;
@end

#endif /* AGXRuntime_AGXIvar_h */
