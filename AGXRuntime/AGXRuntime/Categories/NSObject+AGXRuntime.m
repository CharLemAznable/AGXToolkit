//
//  NSObject+AGXRuntime.m
//  AGXRuntime
//
//  Created by Char Aznable on 16/2/19.
//  Copyright © 2016年 AI-CUC-EC. All rights reserved.
//

#import "NSObject+AGXRuntime.h"
#import "AGXProtocol.h"
#import "AGXIvar.h"
#import "AGXProperty.h"
#import "AGXMethod.h"
#import <AGXCore/AGXArc.h>

@category_implementation(NSObject, AGXRuntime)

+ (NSArray *)zuxProtocols {
    unsigned int count;
    Protocol * __unsafe_unretained *protocols = class_copyProtocolList(self, &count);
    
    NSMutableArray *array = [NSMutableArray array];
    for(unsigned i = 0; i < count; i++)
        [array addObject:[AGXProtocol protocolWithObjCProtocol:protocols[i]]];
    
    free(protocols);
    return AGX_AUTORELEASE([array copy]);
}

+ (void)enumerateAGXProtocolsWithBlock:(void (^)(AGXProtocol *))block {
    if (AGX_EXPECT_F(!block)) return;
    [[self zuxProtocols] enumerateObjectsUsingBlock:
     ^(id _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) { block(obj); }];
}

- (void)enumerateAGXProtocolsWithBlock:(void (^)(id, AGXProtocol *))block {
    if (AGX_EXPECT_F(!block)) return;
    [[[self class] zuxProtocols] enumerateObjectsUsingBlock:
     ^(id _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) { block(self, obj); }];
}

+ (NSArray *)zuxIvars {
    unsigned int count;
    Ivar *ivars = class_copyIvarList(self, &count);
    
    NSMutableArray *array = [NSMutableArray array];
    for(unsigned i = 0; i < count; i++)
        [array addObject:[AGXIvar ivarWithObjCIvar:ivars[i]]];
    
    free(ivars);
    return AGX_AUTORELEASE([array copy]);
}

+ (AGXIvar *)zuxIvarForName:(NSString *)name {
    return [AGXIvar instanceIvarWithName:name inClass:self];
}

+ (void)enumerateAGXIvarsWithBlock:(void (^)(AGXIvar *))block {
    if (AGX_EXPECT_F(!block)) return;
    [[self zuxIvars] enumerateObjectsUsingBlock:
     ^(id _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) { block(obj); }];
}

- (void)enumerateAGXIvarsWithBlock:(void (^)(id, AGXIvar *))block {
    if (AGX_EXPECT_F(!block)) return;
    [[[self class] zuxIvars] enumerateObjectsUsingBlock:
     ^(id _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) { block(self, obj); }];
}

+ (NSArray *)zuxProperties {
    unsigned int count;
    objc_property_t *properties = class_copyPropertyList(self, &count);
    
    NSMutableArray *array = [NSMutableArray array];
    for(unsigned i = 0; i < count; i++)
        [array addObject:[AGXProperty propertyWithObjCProperty:properties[i]]];
    
    free(properties);
    return AGX_AUTORELEASE([array copy]);
}

+ (AGXProperty *)zuxPropertyForName:(NSString *)name {
    return [AGXProperty propertyWithName:name inClass:self];
}

+ (void)enumerateAGXPropertiesWithBlock:(void (^)(AGXProperty *))block {
    if (AGX_EXPECT_F(!block)) return;
    [[self zuxProperties] enumerateObjectsUsingBlock:
     ^(id _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) { block(obj); }];
}

- (void)enumerateAGXPropertiesWithBlock:(void (^)(id, AGXProperty *))block {
    if (AGX_EXPECT_F(!block)) return;
    [[[self class] zuxProperties] enumerateObjectsUsingBlock:
     ^(id _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) { block(self, obj); }];
}

+ (NSArray *)zuxMethods {
    unsigned int count;
    Method *methods = class_copyMethodList(self, &count);
    
    NSMutableArray *array = [NSMutableArray array];
    for(unsigned i = 0; i < count; i++)
        [array addObject:[AGXMethod methodWithObjCMethod:methods[i]]];
    
    free(methods);
    return AGX_AUTORELEASE([array copy]);
}

+ (AGXMethod *)zuxInstanceMethodForName:(NSString *)name {
    return [AGXMethod instanceMethodWithName:name inClass:self];
}

+ (AGXMethod *)zuxClassMethodForName:(NSString *)name {
    return [AGXMethod classMethodWithName:name inClass:self];
}

+ (void)enumerateAGXMethodsWithBlock:(void (^)(AGXMethod *))block {
    if (AGX_EXPECT_F(!block)) return;
    [[self zuxMethods] enumerateObjectsUsingBlock:
     ^(id _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) { block(obj); }];
}

- (void)enumerateAGXMethodsWithBlock:(void (^)(id, AGXMethod *))block {
    if (AGX_EXPECT_F(!block)) return;
    [[[self class] zuxMethods] enumerateObjectsUsingBlock:
     ^(id _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) { block(self, obj); }];
}

@end
