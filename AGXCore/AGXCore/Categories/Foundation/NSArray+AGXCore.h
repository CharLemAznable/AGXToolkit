//
//  NSArray+AGXCore.h
//  AGXCore
//
//  Created by Char Aznable on 16/2/4.
//  Copyright © 2016年 AI-CUC-EC. All rights reserved.
//

#ifndef AGXCore_NSArray_AGXCore_h
#define AGXCore_NSArray_AGXCore_h

#import <Foundation/Foundation.h>
#import "AGXCategory.h"
#import "AGXDirectory.h"

@category_interface_generic(NSArray, AGX_COVARIANT_GENERIC(AGX_OBJECT_TYPE), AGXCore)
- (NSArray AGX_GENERIC(AGX_OBJECT_TYPE) *)deepCopy NS_RETURNS_RETAINED;
- (NSMutableArray AGX_GENERIC(AGX_OBJECT_TYPE) *)deepMutableCopy NS_RETURNS_RETAINED;
- (AGX_OBJECT_TYPE)objectAtIndex:(NSUInteger)index defaultValue:(AGX_OBJECT_TYPE)defaultValue;
- (NSArray AGX_GENERIC(AGX_OBJECT_TYPE) *)reverseArray;

+ (NSArray AGX_GENERIC(AGX_OBJECT_TYPE) *)arrayWithContentsOfUserFile:(NSString *)fileName;
+ (NSArray AGX_GENERIC(AGX_OBJECT_TYPE) *)arrayWithContentsOfUserFile:(NSString *)fileName subpath:(NSString *)subpath;
+ (NSArray AGX_GENERIC(AGX_OBJECT_TYPE) *)arrayWithContentsOfUserFile:(NSString *)fileName inDirectory:(AGXDirectoryType)directory;
+ (NSArray AGX_GENERIC(AGX_OBJECT_TYPE) *)arrayWithContentsOfUserFile:(NSString *)fileName inDirectory:(AGXDirectoryType)directory subpath:(NSString *)subpath;
+ (NSArray AGX_GENERIC(AGX_OBJECT_TYPE) *)arrayWithContentsOfUserFile:(NSString *)fileName bundle:(NSString *)bundleName;
+ (NSArray AGX_GENERIC(AGX_OBJECT_TYPE) *)arrayWithContentsOfUserFile:(NSString *)fileName bundle:(NSString *)bundleName subpath:(NSString *)subpath;

- (AGX_INSTANCETYPE)initWithContentsOfUserFile:(NSString *)fileName;
- (AGX_INSTANCETYPE)initWithContentsOfUserFile:(NSString *)fileName subpath:(NSString *)subpath;
- (AGX_INSTANCETYPE)initWithContentsOfUserFile:(NSString *)fileName inDirectory:(AGXDirectoryType)directory;
- (AGX_INSTANCETYPE)initWithContentsOfUserFile:(NSString *)fileName inDirectory:(AGXDirectoryType)directory subpath:(NSString *)subpath;
- (AGX_INSTANCETYPE)initWithContentsOfUserFile:(NSString *)fileName bundle:(NSString *)bundleName;
- (AGX_INSTANCETYPE)initWithContentsOfUserFile:(NSString *)fileName bundle:(NSString *)bundleName subpath:(NSString *)subpath;

- (BOOL)writeToUserFile:(NSString *)fileName;
- (BOOL)writeToUserFile:(NSString *)fileName inDirectory:(AGXDirectoryType)directory;
- (BOOL)writeToUserFile:(NSString *)fileName inDirectory:(AGXDirectoryType)directory subpath:(NSString *)subpath;
@end

#endif /* AGXCore_NSArray_AGXCore_h */
