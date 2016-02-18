//
//  NSDictionary+AGXCore.h
//  AGXCore
//
//  Created by Char Aznable on 16/2/4.
//  Copyright © 2016年 AI-CUC-EC. All rights reserved.
//

#ifndef AGXCore_NSDictionary_AGXCore_h
#define AGXCore_NSDictionary_AGXCore_h

#import <Foundation/Foundation.h>
#import "AGXCategory.h"
#import "AGXDirectory.h"

@category_interface_generic(NSDictionary, AGX_COVARIANT_GENERIC2(AGX_KEY_TYPE, AGX_OBJECT_TYPE), AGXCore)
- (NSDictionary AGX_GENERIC2(AGX_KEY_TYPE, AGX_OBJECT_TYPE) *)deepCopy NS_RETURNS_RETAINED;
- (NSMutableDictionary AGX_GENERIC2(AGX_KEY_TYPE, AGX_OBJECT_TYPE) *)deepMutableCopy NS_RETURNS_RETAINED;
- (AGX_OBJECT_TYPE)objectForKey:(AGX_KEY_TYPE)key defaultValue:(AGX_OBJECT_TYPE)defaultValue;
- (NSDictionary AGX_GENERIC2(AGX_KEY_TYPE, AGX_OBJECT_TYPE) *)subDictionaryForKeys:(NSArray AGX_GENERIC(AGX_KEY_TYPE) *)keys;

+ (NSDictionary AGX_GENERIC2(AGX_KEY_TYPE, AGX_OBJECT_TYPE) *)dictionaryWithContentsOfUserFile:(NSString *)fileName;
+ (NSDictionary AGX_GENERIC2(AGX_KEY_TYPE, AGX_OBJECT_TYPE) *)dictionaryWithContentsOfUserFile:(NSString *)fileName subpath:(NSString *)subpath;
+ (NSDictionary AGX_GENERIC2(AGX_KEY_TYPE, AGX_OBJECT_TYPE) *)dictionaryWithContentsOfUserFile:(NSString *)fileName inDirectory:(AGXDirectoryType)directory;
+ (NSDictionary AGX_GENERIC2(AGX_KEY_TYPE, AGX_OBJECT_TYPE) *)dictionaryWithContentsOfUserFile:(NSString *)fileName inDirectory:(AGXDirectoryType)directory subpath:(NSString *)subpath;
+ (NSDictionary AGX_GENERIC2(AGX_KEY_TYPE, AGX_OBJECT_TYPE) *)dictionaryWithContentsOfUserFile:(NSString *)fileName bundle:(NSString *)bundleName;
+ (NSDictionary AGX_GENERIC2(AGX_KEY_TYPE, AGX_OBJECT_TYPE) *)dictionaryWithContentsOfUserFile:(NSString *)fileName bundle:(NSString *)bundleName subpath:(NSString *)subpath;

- (AGX_INSTANCETYPE)initWithContentsOfUserFile:(NSString *)fileName;
- (AGX_INSTANCETYPE)initWithContentsOfUserFile:(NSString *)fileName subpath:(NSString *)subpath;
- (AGX_INSTANCETYPE)initWithContentsOfUserFile:(NSString *)fileName inDirectory:(AGXDirectoryType)directory;
- (AGX_INSTANCETYPE)initWithContentsOfUserFile:(NSString *)fileName inDirectory:(AGXDirectoryType)directory subpath:(NSString *)subpath;
- (AGX_INSTANCETYPE)initWithContentsOfUserFile:(NSString *)fileName bundle:(NSString *)bundleName;
- (AGX_INSTANCETYPE)initWithContentsOfUserFile:(NSString *)fileName bundle:(NSString *)bundleName subpath:(NSString *)subpath;

- (BOOL)writeToUserFile:(NSString *)fileName;
- (BOOL)writeToUserFile:(NSString *)fileName inDirectory:(AGXDirectoryType)directory;
- (BOOL)writeToUserFile:(NSString *)fileName inDirectory:(AGXDirectoryType)directory subpath:(NSString *)subpath;

#if __IPHONE_OS_VERSION_MAX_ALLOWED < 60000
- (AGX_OBJECT_TYPE)objectForKeyedSubscript:(AGX_KEY_TYPE)key;
#endif
@end

#if __IPHONE_OS_VERSION_MAX_ALLOWED < 60000
@category_interface_generic(NSMutableDictionary, AGX_GENERIC2(AGX_KEY_TYPE, AGX_OBJECT_TYPE), AGXCore)
- (void)setObject:(AGX_OBJECT_TYPE)obj forKeyedSubscript:(AGX_KEY_TYPE <NSCopying>)key;
@end
#endif

#endif /* AGXCore_NSDictionary_AGXCore_h */
