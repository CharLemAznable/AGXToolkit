//
//  AGXIvar.m
//  AGXRuntime
//
//  Created by Char Aznable on 2016/2/19.
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
#import "AGXIvar.h"

@interface AGXObjCIvarInternal : AGXIvar {
    Ivar _ivar;
}
@end

@interface AGXComponentsIvarInternal : AGXIvar {
    NSString *_name;
    NSString *_typeEncoding;
}
@end

#pragma mark - Implementation -

@implementation AGXIvar

+ (AGX_INSTANCETYPE)ivarWithObjCIvar:(Ivar)ivar {
    return AGX_AUTORELEASE([[self alloc] initWithObjCIvar:ivar]);
}

+ (AGX_INSTANCETYPE)instanceIvarWithName:(NSString *)name inClass:(Class)cls {
    return AGX_AUTORELEASE([[self alloc] initInstanceIvarWithName:name inClass:cls]);
}

+ (AGX_INSTANCETYPE)classIvarWithName:(NSString *)name inClass:(Class)cls {
    return AGX_AUTORELEASE([[self alloc] initClassIvarWithName:name inClass:cls]);
}

+ (AGX_INSTANCETYPE)instanceIvarWithName:(NSString *)name inClassNamed:(NSString *)className {
    return AGX_AUTORELEASE([[self alloc] initInstanceIvarWithName:name inClassNamed:className]);
}

+ (AGX_INSTANCETYPE)classIvarWithName:(NSString *)name inClassNamed:(NSString *)className {
    return AGX_AUTORELEASE([[self alloc] initClassIvarWithName:name inClassNamed:className]);
}

+ (AGX_INSTANCETYPE)ivarWithName:(NSString *)name typeEncoding:(NSString *)typeEncoding {
    return AGX_AUTORELEASE([[self alloc] initWithName:name typeEncoding:typeEncoding]);
}

+ (AGX_INSTANCETYPE)ivarWithName:(NSString *)name encode:(const char *)encodeStr {
    return [self ivarWithName:name typeEncoding:@(encodeStr)];
}

- (AGX_INSTANCETYPE)initWithObjCIvar:(Ivar)ivar {
    AGX_RELEASE(self);
    return [[AGXObjCIvarInternal alloc] initWithObjCIvar:ivar];
}

- (AGX_INSTANCETYPE)initInstanceIvarWithName:(NSString *)name inClass:(Class)cls {
    AGX_RELEASE(self);
    return [[AGXObjCIvarInternal alloc] initInstanceIvarWithName:name inClass:cls];
}

- (AGX_INSTANCETYPE)initClassIvarWithName:(NSString *)name inClass:(Class)cls {
    AGX_RELEASE(self);
    return [[AGXObjCIvarInternal alloc] initClassIvarWithName:name inClass:cls];
}

- (AGX_INSTANCETYPE)initInstanceIvarWithName:(NSString *)name inClassNamed:(NSString *)className {
    AGX_RELEASE(self);
    return [[AGXObjCIvarInternal alloc] initInstanceIvarWithName:name inClassNamed:className];
}

- (AGX_INSTANCETYPE)initClassIvarWithName:(NSString *)name inClassNamed:(NSString *)className {
    AGX_RELEASE(self);
    return [[AGXObjCIvarInternal alloc] initClassIvarWithName:name inClassNamed:className];
}

- (AGX_INSTANCETYPE)initWithName:(NSString *)name typeEncoding:(NSString *)typeEncoding {
    AGX_RELEASE(self);
    return [[AGXComponentsIvarInternal alloc] initWithName:name typeEncoding:typeEncoding];
}

- (NSString *)description {
    return [NSString stringWithFormat:@"<%@ %p: %@ %@ %ld>",
            self.class, self, self.name, self.typeEncoding, (long)self.offset];
}

- (BOOL)isEqual:(id)other {
    return [other isKindOfClass:AGXIvar.class]
    && [self.name isEqual:[other name]]
    && [self.typeEncoding isEqual:[other typeEncoding]];
}

- (NSUInteger)hash {
    return self.name.hash ^ self.typeEncoding.hash;
}

- (NSString *)name {
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

- (NSString *)typeName {
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

- (NSString *)typeEncoding {
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

- (ptrdiff_t)offset {
    [self doesNotRecognizeSelector:_cmd];
    return 0;
}

@end

@implementation AGXObjCIvarInternal

- (AGX_INSTANCETYPE)initWithObjCIvar:(Ivar)ivar {
    if AGX_EXPECT_T(self = [self init]) _ivar = ivar;
    return self;
}

- (AGX_INSTANCETYPE)initInstanceIvarWithName:(NSString *)name inClass:(Class)cls {
    return [self initWithObjCIvar:class_getInstanceVariable(cls, name.UTF8String)];
}

- (AGX_INSTANCETYPE)initClassIvarWithName:(NSString *)name inClass:(Class)cls {
    return [self initWithObjCIvar:class_getClassVariable(cls, name.UTF8String)];
}

- (AGX_INSTANCETYPE)initInstanceIvarWithName:(NSString *)name inClassNamed:(NSString *)className {
    return [self initWithObjCIvar:class_getInstanceVariable(objc_getClass(className.UTF8String), name.UTF8String)];
}

- (AGX_INSTANCETYPE)initClassIvarWithName:(NSString *)name inClassNamed:(NSString *)className {
    return [self initWithObjCIvar:class_getClassVariable(objc_getClass(className.UTF8String), name.UTF8String)];
}

- (NSString *)name {
    return @(ivar_getName(_ivar));
}

- (NSString *)typeName {
    return [self.typeEncoding stringByTrimmingCharactersInSet:
            [NSCharacterSet characterSetWithCharactersInString:@"@\""]];
}

- (NSString *)typeEncoding {
    return @(ivar_getTypeEncoding(_ivar));
}

- (ptrdiff_t)offset {
    return ivar_getOffset(_ivar);
}

@end

@implementation AGXComponentsIvarInternal

- (AGX_INSTANCETYPE)initWithName:(NSString *)name typeEncoding:(NSString *)typeEncoding {
    if AGX_EXPECT_T(self = [self init]) {
        _name = [name copy];
        _typeEncoding = [typeEncoding copy];
    }
    return self;
}

- (void)dealloc {
    AGX_RELEASE(_name);
    AGX_RELEASE(_typeEncoding);
    AGX_SUPER_DEALLOC;
}

- (NSString *)name {
    return _name;
}

- (NSString *)typeEncoding {
    return _typeEncoding;
}

- (ptrdiff_t)offset {
    return -1;
}

@end
