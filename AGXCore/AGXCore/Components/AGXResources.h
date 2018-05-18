//
//  AGXResources.h
//  AGXCore
//
//  Created by Char Aznable on 2018/3/14.
//  Copyright © 2018年 AI-CUC-EC. All rights reserved.
//

#ifndef AGXCore_AGXResources_h
#define AGXCore_AGXResources_h

#import <UIKit/UIKit.h>
#import "AGXObjC.h"

@interface AGXResources : NSObject
+ (AGX_INSTANCETYPE)application;
+ (AGX_INSTANCETYPE)document;
+ (AGX_INSTANCETYPE)caches;
+ (AGX_INSTANCETYPE)temporary;
+ (AGX_INSTANCETYPE)pattern;

- (AGXResources *(^)(NSString *))subpathAs;
- (AGXResources *(^)(NSString *))subpathAppend;
- (AGXResources *(^)(NSString *))subpathAppendBundleNamed;
- (AGXResources *(^)(NSString *))subpathAppendLprojNamed;

- (AGXResources *)applyWithApplication;
- (AGXResources *)applyWithDocument;
- (AGXResources *)applyWithCaches;
- (AGXResources *)applyWithTemporary;

- (NSString *)path;
- (NSURL *)URL;
- (BOOL (^)(BOOL *))isExists;
- (BOOL)isExistsFile;
- (BOOL)isExistsDirectory;
- (NSDictionary<NSFileAttributeKey, id> *)attributes;
- (NSDictionary<NSFileAttributeKey, id> *(^)(NSError **))attributesExt;

- (NSString *(^)(NSString *))pathWithNamed;
- (NSURL *(^)(NSString *))URLWithNamed;
- (BOOL (^)(NSString *, BOOL *))isExistsNamed;
- (NSDictionary<NSFileAttributeKey, id> *(^)(NSString *))attributesWithNamed;
- (NSDictionary<NSFileAttributeKey, id> *(^)(NSString *, NSError **))attributesExtWithNamed;

- (NSString *(^)(NSString *))pathWithFileNamed;
- (NSURL *(^)(NSString *))URLWithFileNamed;
- (BOOL (^)(NSString *))isExistsFileNamed;
- (NSDictionary<NSFileAttributeKey, id> *(^)(NSString *))attributesWithFileNamed;
- (NSDictionary<NSFileAttributeKey, id> *(^)(NSString *, NSError **))attributesExtWithFileNamed;
- (NSString *(^)(NSString *))pathWithPlistNamed;
- (NSURL *(^)(NSString *))URLWithPlistNamed;
- (BOOL (^)(NSString *))isExistsPlistNamed;
- (NSDictionary<NSFileAttributeKey, id> *(^)(NSString *))attributesWithPlistNamed;
- (NSDictionary<NSFileAttributeKey, id> *(^)(NSString *, NSError **))attributesExtWithPlistNamed;
- (NSString *(^)(NSString *))pathWithImageNamed;
- (NSURL *(^)(NSString *))URLWithImageNamed;
- (BOOL (^)(NSString *))isExistsImageNamed;
- (NSDictionary<NSFileAttributeKey, id> *(^)(NSString *))attributesWithImageNamed;
- (NSDictionary<NSFileAttributeKey, id> *(^)(NSString *, NSError **))attributesExtWithImageNamed;

- (NSBundle *)bundle;
- (NSArray<NSString *> *)contents;
- (NSArray<NSString *> *(^)(NSError **))contentsExt;
- (NSArray<NSString *> *)subpaths;
- (NSArray<NSString *> *(^)(NSError **))subpathsExt;

- (NSString *(^)(NSString *))pathWithDirectoryNamed;
- (NSURL *(^)(NSString *))URLWithDirectoryNamed;
- (BOOL (^)(NSString *))isExistsDirectoryNamed;
- (NSDictionary<NSFileAttributeKey, id> *(^)(NSString *))attributesWithDirectoryNamed;
- (NSDictionary<NSFileAttributeKey, id> *(^)(NSString *, NSError **))attributesExtWithDirectoryNamed;
- (NSBundle *(^)(NSString *))bundleWithDirectoryNamed;
- (NSArray<NSString *> *(^)(NSString *))contentsInDirectoryNamed;
- (NSArray<NSString *> *(^)(NSString *, NSError **))contentsExtInDirectoryNamed;
- (NSArray<NSString *> *(^)(NSString *))subpathsInDirectoryNamed;
- (NSArray<NSString *> *(^)(NSString *, NSError **))subpathsExtInDirectoryNamed;
- (NSString *(^)(NSString *))pathWithBundleNamed;
- (NSURL *(^)(NSString *))URLWithBundleNamed;
- (BOOL (^)(NSString *))isExistsBundleNamed;
- (NSDictionary<NSFileAttributeKey, id> *(^)(NSString *))attributesWithBundleNamed;
- (NSDictionary<NSFileAttributeKey, id> *(^)(NSString *, NSError **))attributesExtWithBundleNamed;
- (NSBundle *(^)(NSString *))bundleWithBundleNamed;
- (NSArray<NSString *> *(^)(NSString *))contentsInBundleNamed;
- (NSArray<NSString *> *(^)(NSString *, NSError **))contentsExtInBundleNamed;
- (NSArray<NSString *> *(^)(NSString *))subpathsInBundleNamed;
- (NSArray<NSString *> *(^)(NSString *, NSError **))subpathsExtInBundleNamed;
- (NSString *(^)(NSString *))pathWithLprojNamed;
- (NSURL *(^)(NSString *))URLWithLprojNamed;
- (BOOL (^)(NSString *))isExistsLprojNamed;
- (NSDictionary<NSFileAttributeKey, id> *(^)(NSString *))attributesWithLprojNamed;
- (NSDictionary<NSFileAttributeKey, id> *(^)(NSString *, NSError **))attributesExtWithLprojNamed;
- (NSBundle *(^)(NSString *))bundleWithLprojNamed;
- (NSArray<NSString *> *(^)(NSString *))contentsInLprojNamed;
- (NSArray<NSString *> *(^)(NSString *, NSError **))contentsExtInLprojNamed;
- (NSArray<NSString *> *(^)(NSString *))subpathsInLprojNamed;
- (NSArray<NSString *> *(^)(NSString *, NSError **))subpathsExtInLprojNamed;

- (BOOL (^)(NSDictionary<NSFileAttributeKey, id> *))setAttributes;
- (BOOL (^)(NSDictionary<NSFileAttributeKey, id> *, NSError **))setAttributesExt;
- (BOOL)remove;
- (BOOL (^)(NSError **))removeExt;

- (BOOL (^)(NSString *, NSDictionary<NSFileAttributeKey, id> *))setAttributesWithNamed;
- (BOOL (^)(NSString *, NSDictionary<NSFileAttributeKey, id> *, NSError **))setAttributesExtWithNamed;
- (BOOL (^)(NSString *))removeNamed;
- (BOOL (^)(NSString *, NSError **))removeExtNamed;

- (BOOL (^)(NSString *, NSDictionary<NSFileAttributeKey, id> *))setAttributesWithFileNamed;
- (BOOL (^)(NSString *, NSDictionary<NSFileAttributeKey, id> *, NSError **))setAttributesExtWithFileNamed;
- (BOOL (^)(NSString *))removeFileNamed;
- (BOOL (^)(NSString *, NSError **))removeExtFileNamed;
- (BOOL (^)(NSString *, NSDictionary<NSFileAttributeKey, id> *))setAttributesWithPlistNamed;
- (BOOL (^)(NSString *, NSDictionary<NSFileAttributeKey, id> *, NSError **))setAttributesExtWithPlistNamed;
- (BOOL (^)(NSString *))removePlistNamed;
- (BOOL (^)(NSString *, NSError **))removeExtPlistNamed;
- (BOOL (^)(NSString *, NSDictionary<NSFileAttributeKey, id> *))setAttributesWithImageNamed;
- (BOOL (^)(NSString *, NSDictionary<NSFileAttributeKey, id> *, NSError **))setAttributesExtWithImageNamed;
- (BOOL (^)(NSString *))removeImageNamed;
- (BOOL (^)(NSString *, NSError **))removeExtImageNamed;

- (BOOL)createDirectory;
- (BOOL (^)(NSDictionary<NSFileAttributeKey, id> *, NSError **))createExtDirectory;

- (BOOL (^)(NSString *, NSDictionary<NSFileAttributeKey, id> *))setAttributesWithDirectoryNamed;
- (BOOL (^)(NSString *, NSDictionary<NSFileAttributeKey, id> *, NSError **))setAttributesExtWithDirectoryNamed;
- (BOOL (^)(NSString *))removeDirectoryNamed;
- (BOOL (^)(NSString *, NSError **))removeExtDirectoryNamed;
- (BOOL (^)(NSString *))createDirectoryNamed;
- (BOOL (^)(NSString *, NSDictionary<NSFileAttributeKey, id> *, NSError **))createExtDirectoryNamed;
- (BOOL (^)(NSString *, NSDictionary<NSFileAttributeKey, id> *))setAttributesWithBundleNamed;
- (BOOL (^)(NSString *, NSDictionary<NSFileAttributeKey, id> *, NSError **))setAttributesExtWithBundleNamed;
- (BOOL (^)(NSString *))removeBundleNamed;
- (BOOL (^)(NSString *, NSError **))removeExtBundleNamed;
- (BOOL (^)(NSString *))createBundleNamed;
- (BOOL (^)(NSString *, NSDictionary<NSFileAttributeKey, id> *, NSError **))createExtBundleNamed;
- (BOOL (^)(NSString *, NSDictionary<NSFileAttributeKey, id> *))setAttributesWithLprojNamed;
- (BOOL (^)(NSString *, NSDictionary<NSFileAttributeKey, id> *, NSError **))setAttributesExtWithLprojNamed;
- (BOOL (^)(NSString *))removeLprojNamed;
- (BOOL (^)(NSString *, NSError **))removeExtLprojNamed;
- (BOOL (^)(NSString *))createLprojNamed;
- (BOOL (^)(NSString *, NSDictionary<NSFileAttributeKey, id> *, NSError **))createExtLprojNamed;

- (BOOL (^)(NSString *))createPathOfFileNamed;
- (BOOL (^)(NSString *, NSDictionary<NSFileAttributeKey, id> *, NSError **))createExtPathOfFileNamed;

- (NSData *(^)(NSString *))dataWithFileNamed;
- (id<NSCoding> (^)(NSString *))contentWithFileNamed;
- (NSString *(^)(NSString *, NSStringEncoding))stringWithFileNamed;
- (NSArray *(^)(NSString *))arrayWithFileNamed;
- (NSArray *(^)(NSString *))arrayWithPlistNamed;
- (NSDictionary *(^)(NSString *))dictionaryWithFileNamed;
- (NSDictionary *(^)(NSString *))dictionaryWithPlistNamed;
- (NSSet *(^)(NSString *))setWithFileNamed;
- (NSSet *(^)(NSString *))setWithPlistNamed;
- (UIImage *(^)(NSString *))imageWithFileNamed;
- (UIImage *(^)(NSString *))imageWithImageNamed;

- (BOOL (^)(NSString *, NSData *))writeDataWithFileNamed;
- (BOOL (^)(NSString *, id<NSCoding>))writeContentWithFileNamed;
- (BOOL (^)(NSString *, NSString *, NSStringEncoding))writeStringWithFileNamed;
- (BOOL (^)(NSString *, NSArray *))writeArrayWithFileNamed;
- (BOOL (^)(NSString *, NSArray *))writeArrayWithPlistNamed;
- (BOOL (^)(NSString *, NSDictionary *))writeDictionaryWithFileNamed;
- (BOOL (^)(NSString *, NSDictionary *))writeDictionaryWithPlistNamed;
- (BOOL (^)(NSString *, NSSet *))writeSetWithFileNamed;
- (BOOL (^)(NSString *, NSSet *))writeSetWithPlistNamed;
- (BOOL (^)(NSString *, UIImage *))writeImageWithFileNamed;
- (BOOL (^)(NSString *, UIImage *))writeImageWithImageNamed;
@end

#endif /* AGXCore_AGXResources_h */
