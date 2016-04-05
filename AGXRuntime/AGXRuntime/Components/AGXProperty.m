//
//  AGXProperty.m
//  AGXRuntime
//
//  Created by Char Aznable on 16/2/19.
//  Copyright © 2016年 AI-CUC-EC. All rights reserved.
//

#import "AGXProperty.h"
#import <AGXCore/AGXCore/AGXArc.h>
#import <AGXCore/AGXCore/NSString+AGXCore.h>

NSString *const AGXPropertyReadOnlyAttribute                        = @"R";
NSString *const AGXPropertyNonAtomicAttribute                       = @"N";
NSString *const AGXPropertyWeakReferenceAttribute                   = @"W";
NSString *const AGXPropertyEligibleForGarbageCollectionAttribute    = @"P";
NSString *const AGXPropertyDynamicAttribute                         = @"D";
NSString *const AGXPropertyRetainAttribute                          = @"&";
NSString *const AGXPropertyCopyAttribute                            = @"C";
NSString *const AGXPropertyGetterAttribute                          = @"G";
NSString *const AGXPropertySetterAttribute                          = @"S";
NSString *const AGXPropertyBackingIVarNameAttribute                 = @"V";
NSString *const AGXPropertyTypeEncodingAttribute                    = @"T";

@interface AGXPropertyInternal : AGXProperty {
    objc_property_t _property;
    NSMutableDictionary *_attrs;
    NSString *_name;
    SEL _getter;
    SEL _setter;
    Class _objectClass;
}
@end

#pragma mark - Implementation -

@implementation AGXProperty

+ (AGXProperty *)propertyWithObjCProperty:(objc_property_t)property {
    return AGX_AUTORELEASE([[self alloc] initWithObjCProperty:property]);
}

+ (AGXProperty *)propertyWithName:(NSString *)name inClass:(Class)cls {
    return AGX_AUTORELEASE([[self alloc] initWithName:name inClass:cls]);
}

+ (AGXProperty *)propertyWithName:(NSString *)name inClassNamed:(NSString *)className {
    return AGX_AUTORELEASE([[self alloc] initWithName:name inClassNamed:className]);
}

+ (AGXProperty *)propertyWithName:(NSString *)name attributes:(NSDictionary *)attributes {
    return AGX_AUTORELEASE([[self alloc] initWithName:name attributes:attributes]);
}

- (AGX_INSTANCETYPE)initWithObjCProperty:(objc_property_t)property {
    AGX_RELEASE(self);
    return [[AGXPropertyInternal alloc] initWithObjCProperty:property];
}

- (AGX_INSTANCETYPE)initWithName:(NSString *)name inClass:(Class)cls {
    AGX_RELEASE(self);
    return [[AGXPropertyInternal alloc] initWithName:name inClass:cls];
}

- (AGX_INSTANCETYPE)initWithName:(NSString *)name inClassNamed:(NSString *)className {
    AGX_RELEASE(self);
    return [[AGXPropertyInternal alloc] initWithName:name inClassNamed:className];
}

- (AGX_INSTANCETYPE)initWithName:(NSString *)name attributes:(NSDictionary *)attributes {
    AGX_RELEASE(self);
    return [[AGXPropertyInternal alloc] initWithName:name attributes:attributes];
}

- (NSString *)description {
    return [NSString stringWithFormat:@"<%@ %p: %@ %@ %@ %@>",
            [self class], self, [self name], [self attributeEncodings], [self typeEncoding], [self ivarName]];
}

- (BOOL)isEqual:(id)other {
    return [other isKindOfClass:[AGXProperty class]]
    && [[self name] isEqual:[other name]]
    && (![self attributeEncodings] ? ![other attributeEncodings]
        : [[self attributeEncodings] isEqual:[other attributeEncodings]])
    && [[self typeEncoding] isEqual:[other typeEncoding]]
    && (![self ivarName] ? ![other ivarName]
        : [[self ivarName] isEqual:[other ivarName]]);
}

- (NSUInteger)hash {
    return [[self name] hash] ^ [[self typeEncoding] hash];
}

- (objc_property_t)property {
    [self doesNotRecognizeSelector:_cmd];
    return NULL;
}

- (NSDictionary *)attributes {
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

- (BOOL)addToClass:(Class)classToAddTo {
    [self doesNotRecognizeSelector:_cmd];
    return NO;
}

- (NSString *)attributeEncodings {
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

- (BOOL)isReadOnly {
    [self doesNotRecognizeSelector:_cmd];
    return NO;
}

- (BOOL)isNonAtomic {
    [self doesNotRecognizeSelector:_cmd];
    return NO;
}

- (BOOL)isWeakReference {
    [self doesNotRecognizeSelector:_cmd];
    return NO;
}

- (BOOL)isEligibleForGarbageCollection {
    [self doesNotRecognizeSelector:_cmd];
    return NO;
}

- (BOOL)isDynamic {
    [self doesNotRecognizeSelector:_cmd];
    return NO;
}

- (AGXPropertyMemoryManagementPolicy)memoryManagementPolicy {
    [self doesNotRecognizeSelector:_cmd];
    return AGXPropertyMemoryManagementPolicyAssign;
}

- (SEL)getter {
    [self doesNotRecognizeSelector:_cmd];
    return (SEL)0;
}

- (SEL)setter {
    [self doesNotRecognizeSelector:_cmd];
    return (SEL)0;
}

- (NSString *)name {
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

- (NSString *)ivarName {
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

- (Class)objectClass {
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

@end

@interface AGXPropertyInternal () {
    dispatch_once_t once_getter;
    dispatch_once_t once_setter;
    dispatch_once_t once_objectClass;
}
@end

@implementation AGXPropertyInternal

- (AGX_INSTANCETYPE)initWithObjCProperty:(objc_property_t)property {
    if (AGX_EXPECT_T(self = [self init])) {
        _property = property;
        if (AGX_EXPECT_T(_property)) _name = [@(property_getName(_property)) copy];
        NSArray *attrs = [@(property_getAttributes(property)) arraySplitedByString:@","];
        _attrs = [[NSMutableDictionary alloc] initWithCapacity:[attrs count]];
        for(NSString *attrPair in attrs)
            [_attrs setObject:[attrPair substringFromIndex:1]
                       forKey:[attrPair substringToIndex:1]];
    }
    return self;
}

- (AGX_INSTANCETYPE)initWithName:(NSString *)name inClass:(Class)cls {
    return [self initWithObjCProperty:class_getProperty(cls, name.UTF8String)];
}

- (AGX_INSTANCETYPE)initWithName:(NSString *)name inClassNamed:(NSString *)className {
    return [self initWithObjCProperty:class_getProperty(objc_getClass(className.UTF8String), name.UTF8String)];
}

- (AGX_INSTANCETYPE)initWithName:(NSString *)name attributes:(NSDictionary *)attributes {
    if (AGX_EXPECT_T(self = [self init])) {
        _name = [name copy];
        _attrs = [attributes copy];
    }
    return self;
}

- (void)dealloc {
    AGX_RELEASE(_name);
    AGX_RELEASE(_attrs);
    AGX_SUPER_DEALLOC;
}

- (objc_property_t)property {
    return _property;
}

- (NSDictionary *)attributes {
    return AGX_AUTORELEASE([_attrs copy]);
}

- (BOOL)addToClass:(Class)classToAddTo {
    objc_property_attribute_t *cattrs = calloc([_attrs count], sizeof(objc_property_attribute_t));
    unsigned attrIdx = 0;
    for (NSString *attrKey in _attrs) {
        cattrs[attrIdx].name = [attrKey UTF8String];
        cattrs[attrIdx].value = [[_attrs objectForKey:attrKey] UTF8String];
        attrIdx++;
    }
    BOOL result = class_addProperty(classToAddTo, [[self name] UTF8String],
                                    cattrs, (unsigned int)[_attrs count]);
    free(cattrs);
    return result;
}

- (NSString *)attributeEncodings {
    NSMutableArray *filteredAttributes = [NSMutableArray arrayWithCapacity:[_attrs count] - 2];
    for (NSString *attrKey in _attrs) {
        if (![attrKey isEqualToString:AGXPropertyTypeEncodingAttribute] &&
            ![attrKey isEqualToString:AGXPropertyBackingIVarNameAttribute])
            [filteredAttributes addObject:[_attrs objectForKey:attrKey]];
    }
    return [filteredAttributes componentsJoinedByString:@","];
}

- (BOOL)isReadOnly {
    return [self hasAttribute:AGXPropertyReadOnlyAttribute];
}

- (BOOL)isNonAtomic {
    return [self hasAttribute:AGXPropertyNonAtomicAttribute];
}

- (BOOL)isWeakReference {
    if ([self memoryManagementPolicy] == AGXPropertyMemoryManagementPolicyAssign
        && [[self typeEncoding] hasPrefix:@"@"]) return YES;
    return [self hasAttribute:AGXPropertyWeakReferenceAttribute];
}

- (BOOL)isEligibleForGarbageCollection {
    return [self hasAttribute:AGXPropertyEligibleForGarbageCollectionAttribute];
}

- (BOOL)isDynamic {
    return [self hasAttribute:AGXPropertyDynamicAttribute];
}

- (AGXPropertyMemoryManagementPolicy)memoryManagementPolicy {
    if ([self hasAttribute:AGXPropertyRetainAttribute]) return AGXPropertyMemoryManagementPolicyRetain;
    if ([self hasAttribute:AGXPropertyCopyAttribute]) return AGXPropertyMemoryManagementPolicyCopy;
    return AGXPropertyMemoryManagementPolicyAssign;
}

- (SEL)getter {
    dispatch_once(&once_getter, ^{
        _getter = sel_registerName(([self valueOfAttribute:AGXPropertyGetterAttribute] ?:
                                    _name).UTF8String);
    });
    return _getter;
}

- (SEL)setter {
    dispatch_once(&once_setter, ^{
        if ([self isReadOnly]) return;
        _setter = sel_registerName(([self valueOfAttribute:AGXPropertySetterAttribute] ?:
                                    [NSString stringWithFormat:@"set%@:", [_name capitalized]]).UTF8String);
    });
    return _setter;
}

- (NSString *)name {
    return _name;
}

- (NSString *)ivarName {
    return [self valueOfAttribute:AGXPropertyBackingIVarNameAttribute];
}

- (NSString *)typeName {
    return [[[self typeEncoding] stringByTrimmingCharactersInSet:
            [NSCharacterSet characterSetWithCharactersInString:@"@\"{("]] substringToFirstString:@"="];
}

- (NSString *)typeEncoding {
    return [self valueOfAttribute:AGXPropertyTypeEncodingAttribute];
}

- (Class)objectClass {
    dispatch_once(&once_objectClass, ^{
        if ([self typeEncoding].length >= 2 && [[self typeEncoding] hasPrefix:@"@\""]) {
            _objectClass = objc_getClass([self typeName].UTF8String);
        } else if ([[self typeEncoding] hasPrefix:@"{"]) {
            _objectClass = [NSValue class];
        }
    });
    return _objectClass;
}

#pragma mark - Privates -

- (BOOL)hasAttribute:(NSString *)code {
    return [_attrs objectForKey:code] != nil;
}

- (NSString *)valueOfAttribute:(NSString *)code {
    return [_attrs objectForKey:code];
}

@end
