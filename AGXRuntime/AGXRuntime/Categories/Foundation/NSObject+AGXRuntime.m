//
//  NSObject+AGXRuntime.m
//  AGXRuntime
//
//  Created by Char Aznable on 2016/2/19.
//  Copyright © 2016年 AI-CUC-EC. All rights reserved.
//

#import <AGXCore/AGXCore/AGXArc.h>
#import <AGXCore/AGXCore/NSObject+AGXCore.h>
#import "NSObject+AGXRuntime.h"
#import "AGXProtocol.h"
#import "AGXIvar.h"
#import "AGXProperty.h"
#import "AGXMethod.h"

@category_implementation(NSObject, AGXRuntime)

+ (NSArray *)agxProtocols {
    unsigned int count;
    Protocol * __unsafe_unretained *protocols = class_copyProtocolList(self, &count);

    NSMutableArray *array = [NSMutableArray array];
    for(unsigned i = 0; i < count; i++)
        [array addObject:[AGXProtocol protocolWithObjCProtocol:protocols[i]]];

    free(protocols);
    return AGX_AUTORELEASE([array copy]);
}

+ (void)enumerateAGXProtocolsWithBlock:(void (^)(AGXProtocol *))block {
    if AGX_EXPECT_F(!block) return;
    [self.agxProtocols enumerateObjectsUsingBlock:
     ^(id obj, NSUInteger idx, BOOL *stop) { block(obj); }];
}

- (NSArray *)agxProtocols {
    return self.class.agxProtocols;
}

- (void)enumerateAGXProtocolsWithBlock:(void (^)(id, AGXProtocol *))block {
    if AGX_EXPECT_F(!block) return;
    [self.class.agxProtocols enumerateObjectsUsingBlock:
     ^(id obj, NSUInteger idx, BOOL *stop) { block(self, obj); }];
}

+ (NSArray *)agxIvars {
    unsigned int count;
    Ivar *ivars = class_copyIvarList(self, &count);

    NSMutableArray *array = [NSMutableArray array];
    for(unsigned i = 0; i < count; i++)
        [array addObject:[AGXIvar ivarWithObjCIvar:ivars[i]]];

    free(ivars);
    return AGX_AUTORELEASE([array copy]);
}

+ (AGXIvar *)agxIvarForName:(NSString *)name {
    return [AGXIvar instanceIvarWithName:name inClass:self];
}

+ (void)enumerateAGXIvarsWithBlock:(void (^)(AGXIvar *))block {
    if AGX_EXPECT_F(!block) return;
    [self.agxIvars enumerateObjectsUsingBlock:
     ^(id obj, NSUInteger idx, BOOL *stop) { block(obj); }];
}

- (NSArray *)agxIvars {
    return self.class.agxIvars;
}

- (AGXIvar *)agxIvarForName:(NSString *)name {
    return [self.class agxIvarForName:name];
}

- (void)enumerateAGXIvarsWithBlock:(void (^)(id, AGXIvar *))block {
    if AGX_EXPECT_F(!block) return;
    [self.class.agxIvars enumerateObjectsUsingBlock:
     ^(id obj, NSUInteger idx, BOOL *stop) { block(self, obj); }];
}

+ (NSArray *)agxProperties {
    unsigned int count;
    objc_property_t *properties = class_copyPropertyList(self, &count);

    NSMutableArray *array = [NSMutableArray array];
    for(unsigned i = 0; i < count; i++)
        [array addObject:[AGXProperty propertyWithObjCProperty:properties[i]]];

    free(properties);
    return AGX_AUTORELEASE([array copy]);
}

+ (AGXProperty *)agxPropertyForName:(NSString *)name {
    return [AGXProperty propertyWithName:name inClass:self];
}

+ (void)enumerateAGXPropertiesWithBlock:(void (^)(AGXProperty *))block {
    if AGX_EXPECT_F(!block) return;
    [self.agxProperties enumerateObjectsUsingBlock:
     ^(id obj, NSUInteger idx, BOOL *stop) { block(obj); }];
}

- (NSArray *)agxProperties {
    return self.class.agxProperties;
}

- (AGXProperty *)agxPropertyForName:(NSString *)name {
    return [self.class agxPropertyForName:name];
}

- (void)enumerateAGXPropertiesWithBlock:(void (^)(id, AGXProperty *))block {
    if AGX_EXPECT_F(!block) return;
    [self.class.agxProperties enumerateObjectsUsingBlock:
     ^(id obj, NSUInteger idx, BOOL *stop) { block(self, obj); }];
}

+ (NSArray *)agxInstanceMethods {
    unsigned int count;
    Method *methods = class_copyMethodList(self, &count);

    NSMutableArray *array = [NSMutableArray array];
    for(unsigned i = 0; i < count; i++)
        [array addObject:[AGXMethod methodWithObjCMethod:methods[i]]];

    free(methods);
    return AGX_AUTORELEASE([array copy]);
}

+ (AGXMethod *)agxInstanceMethodForName:(NSString *)name {
    return [AGXMethod instanceMethodWithName:name inClass:self];
}

+ (void)enumerateAGXInstanceMethodsWithBlock:(void (^)(AGXMethod *))block {
    if AGX_EXPECT_F(!block) return;
    [self.agxInstanceMethods enumerateObjectsUsingBlock:
     ^(id obj, NSUInteger idx, BOOL *stop) { block(obj); }];
}

- (NSArray *)agxInstanceMethods {
    return self.class.agxInstanceMethods;
}

- (AGXMethod *)agxInstanceMethodForName:(NSString *)name {
    return [self.class agxInstanceMethodForName:name];
}

- (void)enumerateAGXInstanceMethodsWithBlock:(void (^)(id, AGXMethod *))block {
    if AGX_EXPECT_F(!block) return;
    [self.class.agxInstanceMethods enumerateObjectsUsingBlock:
     ^(id obj, NSUInteger idx, BOOL *stop) { block(self, obj); }];
}

+ (NSArray *)agxClassMethods {
    unsigned int count;
    Method *methods = class_copyMethodList(object_getClass(self), &count);

    NSMutableArray *array = [NSMutableArray array];
    for(unsigned i = 0; i < count; i++)
        [array addObject:[AGXMethod methodWithObjCMethod:methods[i]]];

    free(methods);
    return AGX_AUTORELEASE([array copy]);
}

+ (AGXMethod *)agxClassMethodForName:(NSString *)name {
    return [AGXMethod classMethodWithName:name inClass:self];
}

+ (void)enumerateAGXClassMethodsWithBlock:(void (^)(AGXMethod *))block {
    if AGX_EXPECT_F(!block) return;
    [self.agxClassMethods enumerateObjectsUsingBlock:
     ^(id obj, NSUInteger idx, BOOL *stop) { block(obj); }];
}

- (NSArray *)agxClassMethods {
    return self.class.agxClassMethods;
}

- (AGXMethod *)agxClassMethodForName:(NSString *)name {
    return [self.class agxClassMethodForName:name];
}

- (void)enumerateAGXClassMethodsWithBlock:(void (^)(Class, AGXMethod *))block {
    if AGX_EXPECT_F(!block) return;
    [self.class.agxClassMethods enumerateObjectsUsingBlock:
     ^(id obj, NSUInteger idx, BOOL *stop) { block(self.class, obj); }];
}

+ (BOOL)respondsToAGXClassMethodForName:(NSString *)name {
    return(nil != [self agxClassMethodForName:name]);
}

- (BOOL)respondsToAGXInstanceMethodForName:(NSString *)name {
    return(nil != [self agxInstanceMethodForName:name]);
}

+ (id)performAGXClassMethodForName:(NSString *)name {
    return [self performAGXClassMethodForName:name withObjectsArray:@[]];
}

+ (id)performAGXClassMethodForName:(NSString *)name withObject:(id)object {
    return [self performAGXClassMethodForName:name withObjectsArray:@[object]];
}

+ (id)performAGXClassMethodForName:(NSString *)name withObjects:(id)object, ... NS_REQUIRES_NIL_TERMINATION {
    return [self performAGXClassMethodForName:name withObjectsArray:agx_va_list(object)];
}

+ (id)performAGXClassMethodForName:(NSString *)name withObjectsArray:(NSArray *)objectArray {
    AGXMethod *method = [self agxClassMethodForName:name];
    if (!method) return nil;
    return [self performAGXSelector:method.selector withObjectsArray:objectArray];
}

- (id)performAGXInstanceMethodForName:(NSString *)name {
    return [self performAGXInstanceMethodForName:name withObjectsArray:@[]];
}

- (id)performAGXInstanceMethodForName:(NSString *)name withObject:(id)object {
    return [self performAGXInstanceMethodForName:name withObjectsArray:@[object]];
}

- (id)performAGXInstanceMethodForName:(NSString *)name withObjects:(id)object, ... NS_REQUIRES_NIL_TERMINATION {
    return [self performAGXInstanceMethodForName:name withObjectsArray:agx_va_list(object)];
}

- (id)performAGXInstanceMethodForName:(NSString *)name withObjectsArray:(NSArray *)objectArray {
    AGXMethod *method = [self agxInstanceMethodForName:name];
    if (!method) return nil;
    return [self performAGXSelector:method.selector withObjectsArray:objectArray];
}

@end
