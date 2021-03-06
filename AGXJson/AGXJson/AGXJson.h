//
//  AGXJson.h
//  AGXJson
//
//  Created by Char Aznable on 2016/2/19.
//  Copyright © 2016 github.com/CharLemAznable. All rights reserved.
//

#ifndef AGXJson_AGXJson_h
#define AGXJson_AGXJson_h

#import <CoreFoundation/CoreFoundation.h>
#import <AGXCore/AGXCore/AGXCategory.h>
#import <AGXRuntime/AGXRuntime.h>

FOUNDATION_EXPORT const long AGXJsonVersionNumber;
FOUNDATION_EXPORT const unsigned char AGXJsonVersionString[];

typedef NS_OPTIONS(NSUInteger, AGXJsonOptions) {
    AGXJsonNone             = 0,
    AGXJsonWriteClassName   = 1 << 0
};

AGX_EXTERN NSString *const AGXJSONABLE_CLASS_NAME;
AGX_EXTERN NSString *const AGXJSONABLE_STRUCT_NAME;

// You can set AGX_USE_JSONKIT value TRUE/YES to use JSONKit, AGX_USE_JSONKIT default FALSE/NO.
AGX_EXTERN BOOL AGX_USE_JSONKIT;

@category_interface(NSData, AGXJson)
- (id)agxJsonObject;
- (id)agxJsonObjectAsClass:(Class)clazz;
@end

@category_interface(NSString, AGXJson)
- (id)agxJsonObject;
- (id)agxJsonObjectAsClass:(Class)clazz;
@end

@category_interface(NSObject, AGXJson)
- (NSData *)agxJsonData;
- (NSData *)agxJsonDataWithOptions:(AGXJsonOptions)options;

- (NSString *)agxJsonString;
- (NSString *)agxJsonStringWithOptions:(AGXJsonOptions)options;
@end

//////////////////////////////////////////////////

@category_interface(NSObject, AGXJsonable)
+ (AGX_INSTANCETYPE)instanceWithValidJsonObject:(id)jsonObject;
- (AGX_INSTANCETYPE)initWithValidJsonObject:(id)jsonObject;
- (void)setPropertiesWithValidJsonObject:(id)jsonObject;
- (id)validJsonObject;
- (id)validJsonObjectWithOptions:(AGXJsonOptions)options;
@end

@category_interface(NSValue, AGXJsonable)
+ (void)addJsonableObjCType:(const char *)objCType withName:(NSString *)typeName;
+ (AGX_INSTANCETYPE)valueWithValidJsonObject:(id)jsonObject;

- (id)validJsonObjectForCGPoint;
+ (AGX_INSTANCETYPE)valueWithValidJsonObjectForCGPoint:(id)jsonObject;
- (id)validJsonObjectForCGVector;
+ (AGX_INSTANCETYPE)valueWithValidJsonObjectForCGVector:(id)jsonObject;
- (id)validJsonObjectForCGSize;
+ (AGX_INSTANCETYPE)valueWithValidJsonObjectForCGSize:(id)jsonObject;
- (id)validJsonObjectForCGRect;
+ (AGX_INSTANCETYPE)valueWithValidJsonObjectForCGRect:(id)jsonObject;
- (id)validJsonObjectForCGAffineTransform;
+ (AGX_INSTANCETYPE)valueWithValidJsonObjectForCGAffineTransform:(id)jsonObject;
- (id)validJsonObjectForUIEdgeInsets;
+ (AGX_INSTANCETYPE)valueWithValidJsonObjectForUIEdgeInsets:(id)jsonObject;
- (id)validJsonObjectForUIOffset;
+ (AGX_INSTANCETYPE)valueWithValidJsonObjectForUIOffset:(id)jsonObject;
- (id)validJsonObjectForNSRange;
+ (AGX_INSTANCETYPE)valueWithValidJsonObjectForNSRange:(id)jsonObject;
@end

// struct_jsonable

#define struct_jsonable_interface(structType)                           \
category_interface(NSValue, structType##JsonableDummy)                  \
@end                                                                    \
AGX_CONSTRUCTOR void add_##structType##_jsonable_support()              \
{ [NSValue addJsonableObjCType:@encode(structType)                      \
                      withName:@#structType]; }                         \
@interface NSValue (structType##Jsonable)                               \
- (id)validJsonObjectFor##structType;                                   \
+ (NSValue *)valueWithValidJsonObjectFor##structType:(id)jsonObject;    \
@end

#define struct_jsonable_implementation(structType)                      \
category_implementation(NSValue, structType##JsonableDummy)             \
@end                                                                    \
@implementation NSValue (structType##Jsonable)

// collection json

@category_interface(NSString, AGXJsonable)
+ (AGX_INSTANCETYPE)stringWithValidJsonObject:(id)jsonObject;
@end

@category_interface(NSArray, AGXJsonable)
+ (AGX_INSTANCETYPE)arrayWithValidJsonObject:(id)jsonObject;
@end

@category_interface(NSDictionary, AGXJsonable)
+ (AGX_INSTANCETYPE)dictionaryWithValidJsonObject:(id)jsonObject;
@end

#endif /* AGXJson_AGXJson_h */
