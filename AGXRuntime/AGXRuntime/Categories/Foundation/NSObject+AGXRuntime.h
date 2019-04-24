//
//  NSObject+AGXRuntime.h
//  AGXRuntime
//
//  Created by Char Aznable on 2016/2/19.
//  Copyright © 2016 github.com/CharLemAznable. All rights reserved.
//

#ifndef AGXRuntime_NSObject_AGXRuntime_h
#define AGXRuntime_NSObject_AGXRuntime_h

#import <AGXCore/AGXCore/AGXCategory.h>

@class AGXProtocol;
@class AGXIvar;
@class AGXProperty;
@class AGXMethod;

@category_interface(NSObject, AGXRuntime)
+ (NSArray *)agxProtocols;
+ (void)enumerateAGXProtocolsWithBlock:(void (^)(AGXProtocol *protocol))block;
- (NSArray *)agxProtocols;
- (void)enumerateAGXProtocolsWithBlock:(void (^)(id object, AGXProtocol *protocol))block;

+ (NSArray *)agxIvars;
+ (AGXIvar *)agxIvarForName:(NSString *)name;
+ (void)enumerateAGXIvarsWithBlock:(void (^)(AGXIvar *ivar))block;
- (NSArray *)agxIvars;
- (AGXIvar *)agxIvarForName:(NSString *)name;
- (void)enumerateAGXIvarsWithBlock:(void (^)(id object, AGXIvar *ivar))block;

+ (NSArray *)agxProperties;
+ (AGXProperty *)agxPropertyForName:(NSString *)name;
+ (void)enumerateAGXPropertiesWithBlock:(void (^)(AGXProperty *property))block;
- (NSArray *)agxProperties;
- (AGXProperty *)agxPropertyForName:(NSString *)name;
- (void)enumerateAGXPropertiesWithBlock:(void (^)(id object, AGXProperty *property))block;

+ (NSArray *)agxInstanceMethods;
+ (AGXMethod *)agxInstanceMethodForName:(NSString *)name;
+ (void)enumerateAGXInstanceMethodsWithBlock:(void (^)(AGXMethod *method))block;
- (NSArray *)agxInstanceMethods;
- (AGXMethod *)agxInstanceMethodForName:(NSString *)name;
- (void)enumerateAGXInstanceMethodsWithBlock:(void (^)(id object, AGXMethod *method))block;

+ (NSArray *)agxClassMethods;
+ (AGXMethod *)agxClassMethodForName:(NSString *)name;
+ (void)enumerateAGXClassMethodsWithBlock:(void (^)(AGXMethod *method))block;
- (NSArray *)agxClassMethods;
- (AGXMethod *)agxClassMethodForName:(NSString *)name;
- (void)enumerateAGXClassMethodsWithBlock:(void (^)(Class cls, AGXMethod *method))block;

+ (BOOL)respondsToAGXClassMethodForName:(NSString *)name;
- (BOOL)respondsToAGXInstanceMethodForName:(NSString *)name;

+ (id)performAGXClassMethodForName:(NSString *)name;
+ (id)performAGXClassMethodForName:(NSString *)name withObject:(id)object;
+ (id)performAGXClassMethodForName:(NSString *)name withObjects:(id)object, ... NS_REQUIRES_NIL_TERMINATION;
+ (id)performAGXClassMethodForName:(NSString *)name withObjectsArray:(NSArray *)objectArray;
- (id)performAGXInstanceMethodForName:(NSString *)name;
- (id)performAGXInstanceMethodForName:(NSString *)name withObject:(id)object;
- (id)performAGXInstanceMethodForName:(NSString *)name withObjects:(id)object, ... NS_REQUIRES_NIL_TERMINATION;
- (id)performAGXInstanceMethodForName:(NSString *)name withObjectsArray:(NSArray *)objectArray;
@end

#endif /* AGXRuntime_NSObject_AGXRuntime_h */
