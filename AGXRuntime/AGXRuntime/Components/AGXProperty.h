//
//  AGXProperty.h
//  AGXRuntime
//
//  Created by Char Aznable on 16/2/19.
//  Copyright © 2016年 AI-CUC-EC. All rights reserved.
//

#ifndef AGXRuntime_AGXProperty_h
#define AGXRuntime_AGXProperty_h

#import <Foundation/Foundation.h>
#import <objc/runtime.h>
#import <AGXCore/AGXObjC.h>

typedef NS_ENUM(NSUInteger, AGXPropertyMemoryManagementPolicy) {
    AGXPropertyMemoryManagementPolicyAssign = 0,
    AGXPropertyMemoryManagementPolicyRetain,
    AGXPropertyMemoryManagementPolicyCopy,
};

extern NSString *const AGXPropertyReadOnlyAttribute;
extern NSString *const AGXPropertyNonAtomicAttribute;
extern NSString *const AGXPropertyWeakReferenceAttribute;
extern NSString *const AGXPropertyEligibleForGarbageCollectionAttribute;
extern NSString *const AGXPropertyDynamicAttribute;
extern NSString *const AGXPropertyRetainAttribute;
extern NSString *const AGXPropertyCopyAttribute;
extern NSString *const AGXPropertyGetterAttribute;
extern NSString *const AGXPropertySetterAttribute;
extern NSString *const AGXPropertyBackingIVarNameAttribute;
extern NSString *const AGXPropertyTypeEncodingAttribute;

@interface AGXProperty : NSObject
+ (AGXProperty *)propertyWithObjCProperty:(objc_property_t)property;
+ (AGXProperty *)propertyWithName:(NSString *)name inClass:(Class)cls;
+ (AGXProperty *)propertyWithName:(NSString *)name inClassNamed:(NSString *)className;
+ (AGXProperty *)propertyWithName:(NSString *)name attributes:(NSDictionary *)attributes;

- (AGX_INSTANCETYPE)initWithObjCProperty:(objc_property_t)property;
- (AGX_INSTANCETYPE)initWithName:(NSString *)name inClass:(Class)cls;
- (AGX_INSTANCETYPE)initWithName:(NSString *)name inClassNamed:(NSString *)className;
- (AGX_INSTANCETYPE)initWithName:(NSString *)name attributes:(NSDictionary *)attributes;

- (objc_property_t)property;
- (NSDictionary *)attributes;
- (BOOL)addToClass:(Class)classToAddTo;

- (NSString *)attributeEncodings;
- (BOOL)isReadOnly;
- (BOOL)isNonAtomic;
- (BOOL)isWeakReference;
- (BOOL)isEligibleForGarbageCollection;
- (BOOL)isDynamic;
- (AGXPropertyMemoryManagementPolicy)memoryManagementPolicy;
- (SEL)getter;
- (SEL)setter;
- (NSString *)name;
- (NSString *)ivarName;
- (NSString *)typeName;
- (NSString *)typeEncoding;
- (Class)objectClass;
@end

#endif /* AGXRuntime_AGXProperty_h */
