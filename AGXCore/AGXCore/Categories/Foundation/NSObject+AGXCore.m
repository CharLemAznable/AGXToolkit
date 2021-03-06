//
//  NSObject+AGXCore.m
//  AGXCore
//
//  Created by Char Aznable on 2016/2/4.
//  Copyright © 2016 github.com/CharLemAznable. All rights reserved.
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
                          withNewSelector:@selector(AGXCore_NSObject_setValue:forUndefinedKey:)];);
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

+ (void)addInstanceMethodWithSelector:(SEL)selector fromClass:(Class)clazz {
    addInstanceMethodFromClassIfNotExists(self, selector, clazz);
}

+ (void)addOrReplaceInstanceMethodWithSelector:(SEL)selector fromClass:(Class)clazz {
    addInstanceMethodFromClassReplaceExists(self, selector, clazz);
}

+ (void)addClassMethodWithSelector:(SEL)selector fromClass:(Class)clazz {
    addInstanceMethodFromClassIfNotExists(object_getClass(self), selector, object_getClass(clazz));
}

+ (void)addOrReplaceClassMethodWithSelector:(SEL)selector fromClass:(Class)clazz {
    addInstanceMethodFromClassReplaceExists(object_getClass(self), selector, object_getClass(clazz));
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

AGX_STATIC void addInstanceMethodFromClassIfNotExists(Class targetClass, SEL selector, Class sourceClass) {
    Method method = class_getInstanceMethod(sourceClass, selector);
    addInstanceMethodIfNotExists(targetClass, selector, method_getImplementation(method),
                                 method_getTypeEncoding(method));
}

AGX_STATIC void addInstanceMethodFromClassReplaceExists(Class targetClass, SEL selector, Class sourceClass) {
    Method method = class_getInstanceMethod(sourceClass, selector);
    addInstanceMethodReplaceExists(targetClass, selector, method_getImplementation(method),
                                   method_getTypeEncoding(method));
}

AGX_STATIC void swizzleInstanceMethod(Class swiClass, SEL oriSelector, SEL newSelector, Class impClass) {
    addInstanceMethodFromClassIfNotExists(swiClass, oriSelector, impClass);
    addInstanceMethodFromClassReplaceExists(swiClass, newSelector, impClass);
    method_exchangeImplementations(class_getInstanceMethod(swiClass, oriSelector),
                                   class_getInstanceMethod(swiClass, newSelector));
}

#pragma mark - perform

- (id)performAGXSelector:(SEL)selector {
    return [self performAGXSelector:selector withObjectsArray:@[]];
}

- (id)performAGXSelector:(SEL)selector withObject:(id)object {
    return [self performAGXSelector:selector withObjectsArray:@[object]];
}

- (id)performAGXSelector:(SEL)selector withObjects:(id)object, ... NS_REQUIRES_NIL_TERMINATION {
    return [self performAGXSelector:selector withObjectsArray:agx_va_list(object)];
}

- (id)performAGXSelector:(SEL)selector withObjectsArray:(NSArray *)objectArray {
    NSMethodSignature *methodSignature = [self methodSignatureForSelector:selector];
    NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:methodSignature];
    [invocation setTarget:self];
    [invocation setSelector:selector];

#define setCTypeArgument(type, typeSel)             \
if (0 == strcmp(argumentType, @encode(type))) {     \
type value = [object typeSel];                  \
[invocation setArgument:&value atIndex:i+2];    \
}
    NSUInteger numberOfArguments = methodSignature.numberOfArguments;
    for (int i = 0; i < numberOfArguments-2; i++) {
        id object = objectArray[i];
        if (!object) break;
        const char *argumentType = [methodSignature getArgumentTypeAtIndex:i+2];

        if (0 == strcmp(argumentType, "@")) {
            [invocation setArgument:&object atIndex:i+2];
        }
        setCTypeArgument(char, charValue)
        setCTypeArgument(int, intValue)
        setCTypeArgument(short, shortValue)
        setCTypeArgument(long, longValue)
        setCTypeArgument(long long, longLongValue)
        setCTypeArgument(unsigned char, unsignedCharValue)
        setCTypeArgument(unsigned int, unsignedIntValue)
        setCTypeArgument(unsigned short, unsignedShortValue)
        setCTypeArgument(unsigned long, unsignedLongValue)
        setCTypeArgument(unsigned long long, unsignedLongLongValue)
        setCTypeArgument(BOOL, boolValue)
        setCTypeArgument(float, floatValue)
        setCTypeArgument(double, doubleValue)
    }
#undef setCTypeArgument
    [invocation invoke];

    if (!methodSignature.methodReturnLength) { return nil; }
    id result = nil;
    const char *returnType = methodSignature.methodReturnType;
    if (0 == strcmp(returnType, "@")) {
        [invocation getReturnValue:&result];
    }
#define getCTypeReturnValue(type)               \
if (0 == strcmp(returnType, @encode(type))) {   \
type value;                                 \
[invocation getReturnValue:&value];         \
result = @(value);                          \
}
    getCTypeReturnValue(char)
    getCTypeReturnValue(int)
    getCTypeReturnValue(short)
    getCTypeReturnValue(long)
    getCTypeReturnValue(long long)
    getCTypeReturnValue(unsigned char)
    getCTypeReturnValue(unsigned int)
    getCTypeReturnValue(unsigned short)
    getCTypeReturnValue(unsigned long)
    getCTypeReturnValue(unsigned long long)
    getCTypeReturnValue(BOOL)
    getCTypeReturnValue(float)
    getCTypeReturnValue(double)
#undef getCTypeReturnValue
    return result;
}

#pragma mark - observe

- (void)addObserver:(NSObject *)observer forKeyPaths:(NSArray *)keyPaths options:(NSKeyValueObservingOptions)options context:(void *)context {
    if AGX_EXPECT_F(!keyPaths) return;
    for (id keyPath in keyPaths) {
        NSString *k = [keyPath isKindOfClass:NSString.class] ? keyPath : [keyPath description];
        [self addObserver:observer forKeyPath:k options:options context:context];
    }
}

- (void)removeObserver:(NSObject *)observer forKeyPaths:(NSArray *)keyPaths context:(void *)context {
    if AGX_EXPECT_F(!keyPaths) return;
    for (id keyPath in keyPaths) {
        NSString *k = [keyPath isKindOfClass:NSString.class] ? keyPath : [keyPath description];
        [self removeObserver:observer forKeyPath:k context:context];
    }
}

- (void)removeObserver:(NSObject *)observer forKeyPaths:(NSArray *)keyPaths {
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
    NSData *plistData = self.plistData;
    if AGX_EXPECT_F(!plistData || 0 == plistData.length) return nil;
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
    return nil == object || NSNull.null == object;
}

BOOL AGXIsNotNil(id object) {
    return nil != object && NSNull.null != object;
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
