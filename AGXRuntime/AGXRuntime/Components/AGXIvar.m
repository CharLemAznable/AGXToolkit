//
//  AGXIvar.m
//  AGXRuntime
//
//  Created by Char Aznable on 16/2/19.
//  Copyright © 2016年 AI-CUC-EC. All rights reserved.
//

#import "AGXIvar.h"
#import <AGXCore/AGXCore/AGXArc.h>

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
            [self class], self, [self name], [self typeEncoding], (long)[self offset]];
}

- (BOOL)isEqual:(id)other {
    return [other isKindOfClass:[AGXIvar class]]
    && [[self name] isEqual:[other name]]
    && [[self typeEncoding] isEqual:[other typeEncoding]];
}

- (NSUInteger)hash {
    return [[self name] hash] ^ [[self typeEncoding] hash];
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
    if (AGX_EXPECT_T(self = [self init])) _ivar = ivar;
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
    return [[self typeEncoding] stringByTrimmingCharactersInSet:
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
    if (AGX_EXPECT_T(self = [self init])) {
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
