//
//  AGXMethod.m
//  AGXRuntime
//
//  Created by Char Aznable on 16/2/19.
//  Copyright © 2016年 AI-CUC-EC. All rights reserved.
//

//
//  Modify from:
//  NextThought/MAObjCRuntime
//

//  MAObjCRuntime and all code associated with it is distributed under a BSD license, as listed below.
//
//
//  Copyright (c) 2010, Michael Ash
//  All rights reserved.
//
//  Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:
//
//  Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
//
//  Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
//
//  Neither the name of Michael Ash nor the names of its contributors may be used to endorse or promote products derived from this software without specific prior written permission.
//
//  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

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
