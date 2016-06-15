//
//  AGXMethod.m
//  AGXRuntime
//
//  Created by Char Aznable on 16/2/19.
//  Copyright © 2016年 AI-CUC-EC. All rights reserved.
//

#import <AGXCore/AGXCore/AGXArc.h>
#import "AGXMethod.h"

@interface AGXObjCMethodInternal : AGXMethod {
    Method _method;
}
@end

@interface AGXComponentsMethodInternal : AGXMethod {
    SEL _sel;
    IMP _imp;
    NSString *_sig;
}
@end

#pragma mark - Implementation -

@implementation AGXMethod

+ (AGX_INSTANCETYPE)methodWithObjCMethod:(Method)method {
    return AGX_AUTORELEASE([[self alloc] initWithObjCMethod:method]);
}

+ (AGX_INSTANCETYPE)instanceMethodWithName:(NSString *)name inClass:(Class)cls {
    return AGX_AUTORELEASE([[self alloc] initInstanceMethodWithName:name inClass:cls]);
}

+ (AGX_INSTANCETYPE)classMethodWithName:(NSString *)name inClass:(Class)cls {
    return AGX_AUTORELEASE([[self alloc] initClassMethodWithName:name inClass:cls]);
}

+ (AGX_INSTANCETYPE)instanceMethodWithName:(NSString *)name inClassNamed:(NSString *)className {
    return AGX_AUTORELEASE([[self alloc] initInstanceMethodWithName:name inClassNamed:className]);
}

+ (AGX_INSTANCETYPE)classMethodWithName:(NSString *)name inClassNamed:(NSString *)className {
    return AGX_AUTORELEASE([[self alloc] initClassMethodWithName:name inClassNamed:className]);
}

+ (AGX_INSTANCETYPE)methodWithSelector:(SEL)sel implementation:(IMP)imp signature:(NSString *)signature {
    return AGX_AUTORELEASE([[self alloc] initWithSelector:sel implementation:imp signature:signature]);
}

- (AGX_INSTANCETYPE)initWithObjCMethod:(Method)method {
    AGX_RELEASE(self);
    return [[AGXObjCMethodInternal alloc] initWithObjCMethod:method];
}

- (AGX_INSTANCETYPE)initInstanceMethodWithName:(NSString *)name inClass:(Class)cls {
    AGX_RELEASE(self);
    return [[AGXObjCMethodInternal alloc] initInstanceMethodWithName:name inClass:cls];
}

- (AGX_INSTANCETYPE)initClassMethodWithName:(NSString *)name inClass:(Class)cls {
    AGX_RELEASE(self);
    return [[AGXObjCMethodInternal alloc] initClassMethodWithName:name inClass:cls];
}

- (AGX_INSTANCETYPE)initInstanceMethodWithName:(NSString *)name inClassNamed:(NSString *)className {
    AGX_RELEASE(self);
    return [[AGXObjCMethodInternal alloc] initInstanceMethodWithName:name inClassNamed:className];
}

- (AGX_INSTANCETYPE)initClassMethodWithName:(NSString *)name inClassNamed:(NSString *)className {
    AGX_RELEASE(self);
    return [[AGXObjCMethodInternal alloc] initClassMethodWithName:name inClassNamed:className];
}

- (AGX_INSTANCETYPE)initWithSelector:(SEL)sel implementation:(IMP)imp signature:(NSString *)signature {
    AGX_RELEASE(self);
    return [[AGXComponentsMethodInternal alloc] initWithSelector:sel implementation:imp signature:signature];
}

- (NSString *)description {
    return [NSString stringWithFormat:@"<%@ %p: %@ %p %@>",
            [self class], self, NSStringFromSelector([self selector]), [self implementation], [self signature]];
}

- (BOOL)isEqual:(id)other {
    return [other isKindOfClass:[AGXMethod class]]
    && [self selector] == [other selector]
    && [self implementation] == [other implementation]
    && [[self signature] isEqual:[other signature]];
}

- (NSUInteger)hash {
    return (NSUInteger)(void *)[self selector] ^ (NSUInteger)[self implementation] ^ [[self signature] hash];
}

- (SEL)selector {
    [self doesNotRecognizeSelector:_cmd];
    return NULL;
}

- (NSString *)selectorName {
    return NSStringFromSelector([self selector]);
}

- (IMP)implementation {
    [self doesNotRecognizeSelector:_cmd];
    return NULL;
}

- (void)setImplementation:(IMP)imp {
    [self doesNotRecognizeSelector:_cmd];
}

- (NSString *)signature {
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

@end

@implementation AGXObjCMethodInternal

- (AGX_INSTANCETYPE)initWithObjCMethod:(Method)method {
    if (AGX_EXPECT_T(self = [self init])) _method = method;
    return self;
}

- (AGX_INSTANCETYPE)initInstanceMethodWithName:(NSString *)name inClass:(Class)cls {
    return [self initWithObjCMethod:class_getInstanceMethod(cls, NSSelectorFromString(name))];
}

- (AGX_INSTANCETYPE)initClassMethodWithName:(NSString *)name inClass:(Class)cls {
    return [self initWithObjCMethod:class_getClassMethod(cls, NSSelectorFromString(name))];
}

- (AGX_INSTANCETYPE)initInstanceMethodWithName:(NSString *)name inClassNamed:(NSString *)className {
    return [self initWithObjCMethod:
            class_getInstanceMethod(objc_getClass(className.UTF8String), NSSelectorFromString(name))];
}

- (AGX_INSTANCETYPE)initClassMethodWithName:(NSString *)name inClassNamed:(NSString *)className {
    return [self initWithObjCMethod:
            class_getClassMethod(objc_getClass(className.UTF8String), NSSelectorFromString(name))];
}

- (SEL)selector {
    return method_getName(_method);
}

- (IMP)implementation {
    return method_getImplementation(_method);
}

- (void)setImplementation:(IMP)imp {
    method_setImplementation(_method, imp);
}

- (NSString *)signature {
    return @(method_getTypeEncoding(_method));
}

@end

@implementation AGXComponentsMethodInternal

- (AGX_INSTANCETYPE)initWithSelector:(SEL)sel implementation:(IMP)imp signature:(NSString *)signature {
    if (AGX_EXPECT_T(self = [self init])) {
        _sel = sel;
        _imp = imp;
        _sig = [signature copy];
    }
    return self;
}

- (void)dealloc {
    AGX_RELEASE(_sig);
    AGX_SUPER_DEALLOC;
}

- (SEL)selector {
    return _sel;
}

- (IMP)implementation {
    return _imp;
}

- (void)setImplementation:(IMP)imp {
    _imp = imp;
}

- (NSString *)signature {
    return _sig;
}

@end
