//
//  NSObject+AGXCore.m
//  AGXCore
//
//  Created by Char Aznable on 2016/2/4.
//  Copyright © 2016年 AI-CUC-EC. All rights reserved.
//

#import <objc/runtime.h>
#import "NSObject+AGXCore.h"
#import "AGXArc.h"
#import "NSData+AGXCore.h"

@category_implementation(NSObject, AGXCore)

+ (BOOL)isProperSubclassOfClass:(Class)aClass {
    return [self isSubclassOfClass:aClass] && self != aClass;
}

+ (AGX_INSTANCETYPE)instance {
    return AGX_AUTORELEASE([[self alloc] init]);
}

- (AGX_INSTANCETYPE)duplicate {
    if AGX_EXPECT_F(![self conformsToProtocol:@protocol(NSCoding)]) return nil;
    return [NSKeyedUnarchiver unarchiveObjectWithData:[NSKeyedArchiver archivedDataWithRootObject:self]];
}

#pragma mark - KVC Undefined

NSString *const agxSilentUndefinedKeyValueCodingKey = @"agxSilentUndefinedKeyValueCoding";

+ (BOOL)silentUndefinedKeyValueCoding {
    return [[self retainPropertyForAssociateKey:agxSilentUndefinedKeyValueCodingKey] boolValue];
}

+ (void)setSilentUndefinedKeyValueCoding:(BOOL)silentUndefinedKeyValueCoding {
    [self setKVORetainProperty:@(silentUndefinedKeyValueCoding) forAssociateKey:agxSilentUndefinedKeyValueCodingKey];
}

- (id)AGXCore_NSObject_valueForUndefinedKey:(NSString *)key {
    if (!self.class.silentUndefinedKeyValueCoding) return [self AGXCore_NSObject_valueForUndefinedKey:key];
    AGXLog(@"%@ valueForUndefinedKey:]: this class is not key value coding-compliant for the key %@.", self, key);
    return nil;
}

- (void)AGXCore_NSObject_setValue:(id)value forUndefinedKey:(NSString *)key {
    if (!self.class.silentUndefinedKeyValueCoding) return [self AGXCore_NSObject_setValue:value forUndefinedKey:key];
    AGXLog(@"%@ setValue:forUndefinedKey:]: this class is not key value coding-compliant for the key %@.", self, key);
}

+ (void)load {
    agx_once
    ([NSObject swizzleInstanceOriSelector:@selector(valueForUndefinedKey:)
                             withNewSelector:@selector(AGXCore_NSObject_valueForUndefinedKey:)];
     [NSObject swizzleInstanceOriSelector:@selector(setValue:forUndefinedKey:)
                          withNewSelector:@selector(AGXCore_NSObject_setValue:forUndefinedKey:)];)
}

#pragma mark - add (replace)

+ (void)addInstanceMethodWithSelector:(SEL)selector andBlock:(id)block andTypeEncoding:(const char *)typeEncoding {
    addInstanceMethodIfNotExists(self, selector, imp_implementationWithBlock(block), typeEncoding);
}

+ (void)addOrReplaceInstanceMethodWithSelector:(SEL)selector andBlock:(id)block andTypeEncoding:(const char *)typeEncoding {
    addInstanceMethodReplaceExists(self, selector, imp_implementationWithBlock(block), typeEncoding);
}

+ (void)addClassMethodWithSelector:(SEL)selector andBlock:(id)block andTypeEncoding:(const char *)typeEncoding {
    addInstanceMethodIfNotExists(object_getClass(self), selector, imp_implementationWithBlock(block), typeEncoding);
}

+ (void)addOrReplaceClassMethodWithSelector:(SEL)selector andBlock:(id)block andTypeEncoding:(const char *)typeEncoding {
    addInstanceMethodReplaceExists(object_getClass(self), selector, imp_implementationWithBlock(block), typeEncoding);
}

#pragma mark - swizzle

+ (void)swizzleInstanceOriSelector:(SEL)oriSelector withNewSelector:(SEL)newSelector {
    [self swizzleInstanceOriSelector:oriSelector withNewSelector:newSelector fromClass:self];
}

+ (void)swizzleInstanceOriSelector:(SEL)oriSelector withNewSelector:(SEL)newSelector fromClass:(Class)clazz {
    swizzleInstanceMethod(self, oriSelector, newSelector, clazz);
}

+ (void)swizzleClassOriSelector:(SEL)oriSelector withNewSelector:(SEL)newSelector {
    [self swizzleClassOriSelector:oriSelector withNewSelector:newSelector fromClass:self];
}

+ (void)swizzleClassOriSelector:(SEL)oriSelector withNewSelector:(SEL)newSelector fromClass:(Class)clazz {
    swizzleInstanceMethod(object_getClass(self), oriSelector, newSelector, object_getClass(clazz));
}

AGX_STATIC void addInstanceMethodIfNotExists(Class targetClass, SEL selector, IMP imp, const char *typeEncoding) {
    class_addMethod(targetClass, selector, imp, typeEncoding);
}

AGX_STATIC void addInstanceMethodReplaceExists(Class targetClass, SEL selector, IMP imp, const char *typeEncoding) {
    if AGX_EXPECT_T(!class_addMethod(targetClass, selector, imp, typeEncoding))
        method_setImplementation(class_getInstanceMethod(targetClass, selector), imp);
}

AGX_STATIC void swizzleInstanceMethod(Class swiClass, SEL oriSelector, SEL newSelector, Class impClass) {
    Method oriMethod = class_getInstanceMethod(impClass, oriSelector);
    Method newMethod = class_getInstanceMethod(impClass, newSelector);
    addInstanceMethodIfNotExists(swiClass, oriSelector, method_getImplementation(oriMethod),
                                 method_getTypeEncoding(oriMethod));
    addInstanceMethodReplaceExists(swiClass, newSelector, method_getImplementation(newMethod),
                                   method_getTypeEncoding(newMethod));
    method_exchangeImplementations(class_getInstanceMethod(swiClass, oriSelector),
                                   class_getInstanceMethod(swiClass, newSelector));
}

#pragma mark - observe

- (void)addObserver:(NSObject *)observer
        forKeyPaths:(NSArray *)keyPaths
            options:(NSKeyValueObservingOptions)options
            context:(void *)context {
    if AGX_EXPECT_F(!keyPaths) return;
    for (id keyPath in keyPaths) {
        NSString *k = [keyPath isKindOfClass:[NSString class]] ? keyPath : [keyPath description];
        [self addObserver:observer forKeyPath:k options:options context:context];
    }
}

- (void)removeObserver:(NSObject *)observer
           forKeyPaths:(NSArray *)keyPaths
               context:(void *)context {
    if AGX_EXPECT_F(!keyPaths) return;
    for (id keyPath in keyPaths) {
        NSString *k = [keyPath isKindOfClass:[NSString class]] ? keyPath : [keyPath description];
        [self removeObserver:observer forKeyPath:k context:context];
    }
}

- (void)removeObserver:(NSObject *)observer
           forKeyPaths:(NSArray *)keyPaths {
    [self removeObserver:observer forKeyPaths:keyPaths context:NULL];
}

#pragma mark - associate

- (id)assignPropertyForAssociateKey:(NSString *)key {
    return [self p_getAssociatedPropertyForAssociateKey:key];
}

- (void)setAssignProperty:(id)property forAssociateKey:(NSString *)key {
    [self p_setAssociatedProperty:property forAssociateKey:key policy:OBJC_ASSOCIATION_ASSIGN];
}

- (void)setKVOAssignProperty:(id)property forAssociateKey:(NSString *)key {
    [self p_setKVOAssociatedProperty:property forAssociateKey:key policy:OBJC_ASSOCIATION_ASSIGN];
}

- (id)retainPropertyForAssociateKey:(NSString *)key {
    return [self p_getAssociatedPropertyForAssociateKey:key];
}

- (void)setRetainProperty:(id)property forAssociateKey:(NSString *)key {
    [self p_setAssociatedProperty:property forAssociateKey:key policy:OBJC_ASSOCIATION_RETAIN_NONATOMIC];
}

- (void)setKVORetainProperty:(id)property forAssociateKey:(NSString *)key {
    [self p_setKVOAssociatedProperty:property forAssociateKey:key policy:OBJC_ASSOCIATION_RETAIN_NONATOMIC];
}

- (id)copyPropertyForAssociateKey:(NSString *)key {
    return [self p_getAssociatedPropertyForAssociateKey:key];
}

- (void)setCopyProperty:(id)property forAssociateKey:(NSString *)key {
    [self p_setAssociatedProperty:property forAssociateKey:key policy:OBJC_ASSOCIATION_COPY_NONATOMIC];
}

- (void)setKVOCopyProperty:(id)property forAssociateKey:(NSString *)key {
    [self p_setKVOAssociatedProperty:property forAssociateKey:key policy:OBJC_ASSOCIATION_COPY_NONATOMIC];
}

#pragma mark - associate private

- (id)p_getAssociatedPropertyForAssociateKey:(NSString *)key {
    return objc_getAssociatedObject(self, (AGX_BRIDGE const void *)(key));
}

- (void)p_setAssociatedProperty:(id)property forAssociateKey:(NSString *)key policy:(objc_AssociationPolicy)policy {
    objc_setAssociatedObject(self, (AGX_BRIDGE const void *)(key), property, policy);
}

- (void)p_setKVOAssociatedProperty:(id)property forAssociateKey:(NSString *)key policy:(objc_AssociationPolicy)policy {
    id originalProperty = [self p_getAssociatedPropertyForAssociateKey:key];
    if AGX_EXPECT_F([property isEqual:originalProperty]) return;

    [self willChangeValueForKey:key];
    [self p_setAssociatedProperty:property forAssociateKey:key policy:policy];
    [self didChangeValueForKey:key];
}

#pragma mark - Plist

- (NSData *)plistData {
    return [NSPropertyListSerialization dataWithPropertyList:self format:NSPropertyListXMLFormat_v1_0 options:0 error:NULL];
}

- (NSString *)plistString {
    NSData *plistData = [self plistData];
    if AGX_EXPECT_F(!plistData || 0 == [plistData length]) return nil;
    return plistData.base64EncodedString;
}

#pragma mark - empty check

- (BOOL)isEmpty {
    return NO;
}

- (BOOL)isNotEmpty {
    return YES;
}

@end

BOOL AGXIsNil(id object) {
    return nil == object || [NSNull null] == object;
}

BOOL AGXIsNotNil(id object) {
    return nil != object && [NSNull null] != object;
}

BOOL AGXIsEmpty(id object) {
    return AGXIsNotNil(object) && [object isEmpty];
}

BOOL AGXIsNotEmpty(id object) {
    return AGXIsNotNil(object) && [object isNotEmpty];
}

BOOL AGXIsNilOrEmpty(id object) {
    return AGXIsNil(object) || [object isEmpty];
}
