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

- (AGXResources *(^)(NSString *))subpathAs;
- (AGXResources *(^)(NSString *))subpathAppend;
- (AGXResources *(^)(NSString *))subpathAppendBundleNamed;
- (AGXResources *(^)(NSString *))subpathAppendLprojNamed;

- (NSString *)path;
- (NSURL *)URL;
- (BOOL)isExistsFile;
- (NSString *(^)(NSString *))pathWithFileNamed;
- (NSURL *(^)(NSString *))URLWithFileNamed;
- (BOOL (^)(NSString *))isExistsFileNamed;
- (NSString *(^)(NSString *))pathWithPlistNamed;
- (NSURL *(^)(NSString *))URLWithPlistNamed;
- (BOOL (^)(NSString *))isExistsPlistNamed;
- (NSString *(^)(NSString *))pathWithImageNamed;
- (NSURL *(^)(NSString *))URLWithImageNamed;
- (BOOL (^)(NSString *))isExistsImageNamed;

- (NSBundle *)bundle;
- (BOOL)isExistsDirectory;
- (NSString *(^)(NSString *))pathWithDirectoryNamed;
- (NSBundle *(^)(NSString *))bundleWithDirectoryNamed;
- (BOOL (^)(NSString *))isExistsDirectoryNamed;
- (NSString *(^)(NSString *))pathWithBundleNamed;
- (NSBundle *(^)(NSString *))bundleWithBundleNamed;
- (BOOL (^)(NSString *))isExistsBundleNamed;
- (NSString *(^)(NSString *))pathWithLprojNamed;
- (NSBundle *(^)(NSString *))bundleWithLprojNamed;
- (BOOL (^)(NSString *))isExistsLprojNamed;

- (BOOL)createDirectory;
- (BOOL)deleteDirectory;
- (BOOL (^)(NSString *))createDirectoryNamed;
- (BOOL (^)(NSString *))deleteDirectoryNamed;
- (BOOL (^)(NSString *))createBundleNamed;
- (BOOL (^)(NSString *))deleteBundleNamed;
- (BOOL (^)(NSString *))createLprojNamed;
- (BOOL (^)(NSString *))deleteLprojNamed;
- (BOOL (^)(NSString *))createPathOfFileNamed;

- (BOOL)deleteFile;
- (BOOL (^)(NSString *))deleteFileNamed;
- (BOOL (^)(NSString *))deletePlistNamed;
- (BOOL (^)(NSString *))deleteImageNamed;

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
