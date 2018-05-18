//
//  AGXResources.m
//  AGXCore
//
//  Created by Char Aznable on 2018/3/14.
//  Copyright © 2018年 AI-CUC-EC. All rights reserved.
//

#import "AGXResources.h"
#import "AGXArc.h"
#import "NSArray+AGXCore.h"
#import "NSDictionary+AGXCore.h"

typedef NSDictionary<NSFileAttributeKey, id> * AGXAttributesType;
#define plistNameExt [plistName stringByAppendingPathExtension:@"plist"]
#define imageNameExt [imageName stringByAppendingPathExtension:@"png"]
#define bundleNameExt [bundleName stringByAppendingPathExtension:@"bundle"]
#define lprojNameExt [lprojName stringByAppendingPathExtension:@"lproj"]

@interface AGXBundleResources : AGXResources
+ (AGX_INSTANCETYPE)application;
@end

#pragma mark -

@interface AGXUserDomainResources : AGXResources
+ (AGX_INSTANCETYPE)document;
+ (AGX_INSTANCETYPE)caches;
+ (AGX_INSTANCETYPE)temporary;
@end

#pragma mark -

@interface AGXResources()
@property (nonatomic, copy) NSString *root;
@property (nonatomic, copy) NSString *subpath;
@end

#pragma mark -

@implementation AGXResources

#pragma mark - initial methods -

+ (AGX_INSTANCETYPE)application {
    return AGXBundleResources.application;
}

+ (AGX_INSTANCETYPE)document {
    return AGXUserDomainResources.document;
}

+ (AGX_INSTANCETYPE)caches {
    return AGXUserDomainResources.caches;
}

+ (AGX_INSTANCETYPE)temporary {
    return AGXUserDomainResources.temporary;
}

+ (AGX_INSTANCETYPE)pattern {
    return AGX_AUTORELEASE([[self alloc] initWithRoot:nil]);
}

- (AGX_INSTANCETYPE)initWithRoot:(NSString *)root {
    if AGX_EXPECT_T(self = [super init]) {
        _root = [root copy];
    }
    return self;
}

- (void)dealloc {
    AGX_RELEASE(_root);
    AGX_RELEASE(_subpath);
    AGX_SUPER_DEALLOC;
}

#pragma mark - subpath methods -

- (AGXResources *(^)(NSString *))subpathAs {
    return AGX_BLOCK_AUTORELEASE(^AGXResources *(NSString *subpath) {
        self.subpath = subpath;
        return self;
    });
}

- (AGXResources *(^)(NSString *))subpathAppend {
    return AGX_BLOCK_AUTORELEASE(^AGXResources *(NSString *append) {
        self.subpath = [_subpath?:@"" stringByAppendingPathComponent:append];
        return self;
    });
}

- (AGXResources *(^)(NSString *))subpathAppendBundleNamed {
    return AGX_BLOCK_AUTORELEASE(^AGXResources *(NSString *bundleName) {
        return self.subpathAppend([bundleName stringByAppendingPathExtension:@"bundle"]);
    });
}

- (AGXResources *(^)(NSString *))subpathAppendLprojNamed {
    return AGX_BLOCK_AUTORELEASE(^AGXResources *(NSString *lprojName) {
        return self.subpathAppend([lprojName stringByAppendingPathExtension:@"lproj"]);
    });
}

- (AGXResources *)applyWithApplication {
    return AGXBundleResources.application.subpathAs(_subpath);
}

- (AGXResources *)applyWithDocument {
    return AGXUserDomainResources.document.subpathAs(_subpath);
}

- (AGXResources *)applyWithCaches {
    return AGXUserDomainResources.caches.subpathAs(_subpath);
}

- (AGXResources *)applyWithTemporary {
    return AGXUserDomainResources.temporary.subpathAs(_subpath);
}

#pragma mark - indicate methods -

- (NSString *)path {
    // Override
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

- (NSURL *)URL {
    return [NSURL fileURLWithPath:self.path];
}

- (BOOL (^)(BOOL *))isExists {
    return AGX_BLOCK_AUTORELEASE(^BOOL (BOOL *isDirectory) {
        return [NSFileManager.defaultManager fileExistsAtPath:self.path isDirectory:isDirectory];
    });
}

- (BOOL)isExistsFile {
    BOOL isDirectory;
    BOOL exists = self.isExists(&isDirectory);
    return exists && !isDirectory;
}

- (BOOL)isExistsDirectory {
    BOOL isDirectory;
    BOOL exists = self.isExists(&isDirectory);
    return exists && isDirectory;
}

- (AGXAttributesType)attributes {
    return self.attributesExt(nil);
}

- (AGXAttributesType (^)(NSError **))attributesExt {
    return AGX_BLOCK_AUTORELEASE(^AGXAttributesType (NSError **error) {
        return [NSFileManager.defaultManager attributesOfItemAtPath:self.path error:error];
    });
}

#pragma mark -

- (NSString *(^)(NSString *))pathWithNamed {
    return AGX_BLOCK_AUTORELEASE(^NSString *(NSString *name) {
        return [self.path stringByAppendingPathComponent:name];
    });
}

- (NSURL *(^)(NSString *))URLWithNamed {
    return AGX_BLOCK_AUTORELEASE(^NSURL *(NSString *name) {
        return [NSURL fileURLWithPath:self.pathWithNamed(name)];
    });
}

- (BOOL (^)(NSString *, BOOL *))isExistsNamed {
    return AGX_BLOCK_AUTORELEASE(^BOOL (NSString *name, BOOL *isDirectory) {
        return [NSFileManager.defaultManager fileExistsAtPath:self.pathWithNamed(name) isDirectory:isDirectory];
    });
}

- (AGXAttributesType (^)(NSString *))attributesWithNamed {
    return AGX_BLOCK_AUTORELEASE(^AGXAttributesType (NSString *name) {
        return self.attributesExtWithNamed(name, nil);
    });
}

- (AGXAttributesType (^)(NSString *, NSError **))attributesExtWithNamed {
    return AGX_BLOCK_AUTORELEASE(^AGXAttributesType (NSString *name, NSError **error) {
        return [NSFileManager.defaultManager attributesOfItemAtPath:self.pathWithNamed(name) error:error];
    });
}

#pragma mark -

- (NSString *(^)(NSString *))pathWithFileNamed {
    return AGX_BLOCK_AUTORELEASE(^NSString *(NSString *fileName) {
        return self.pathWithNamed(fileName);
    });
}

- (NSURL *(^)(NSString *))URLWithFileNamed {
    return AGX_BLOCK_AUTORELEASE(^NSURL *(NSString *fileName) {
        return self.URLWithNamed(fileName);
    });
}

- (BOOL (^)(NSString *))isExistsFileNamed {
    return AGX_BLOCK_AUTORELEASE(^BOOL (NSString *fileName) {
        BOOL isDirectory;
        BOOL exists = self.isExistsNamed(fileName, &isDirectory);
        return exists && !isDirectory;
    });
}

- (AGXAttributesType (^)(NSString *))attributesWithFileNamed {
    return AGX_BLOCK_AUTORELEASE(^AGXAttributesType (NSString *fileName) {
        return self.attributesWithNamed(fileName);
    });
}

- (AGXAttributesType (^)(NSString *, NSError **))attributesExtWithFileNamed {
    return AGX_BLOCK_AUTORELEASE(^AGXAttributesType (NSString *fileName, NSError **error) {
        return self.attributesExtWithNamed(fileName, error);
    });
}

- (NSString *(^)(NSString *))pathWithPlistNamed {
    return AGX_BLOCK_AUTORELEASE(^NSString *(NSString *plistName) {
        return self.pathWithFileNamed(plistNameExt);
    });
}

- (NSURL *(^)(NSString *))URLWithPlistNamed {
    return AGX_BLOCK_AUTORELEASE(^NSURL *(NSString *plistName) {
        return self.URLWithFileNamed(plistNameExt);
    });
}

- (BOOL (^)(NSString *))isExistsPlistNamed {
    return AGX_BLOCK_AUTORELEASE(^BOOL (NSString *plistName) {
        return self.isExistsFileNamed(plistNameExt);
    });
}

- (AGXAttributesType (^)(NSString *))attributesWithPlistNamed {
    return AGX_BLOCK_AUTORELEASE(^AGXAttributesType (NSString *plistName) {
        return self.attributesWithFileNamed(plistNameExt);
    });
}

- (AGXAttributesType (^)(NSString *, NSError **))attributesExtWithPlistNamed {
    return AGX_BLOCK_AUTORELEASE(^AGXAttributesType (NSString *plistName, NSError **error) {
        return self.attributesExtWithFileNamed(plistNameExt, error);
    });
}

- (NSString *(^)(NSString *))pathWithImageNamed {
    return AGX_BLOCK_AUTORELEASE(^NSString *(NSString *imageName) {
        return self.pathWithFileNamed(imageNameExt);
    });
}

- (NSURL *(^)(NSString *))URLWithImageNamed {
    return AGX_BLOCK_AUTORELEASE(^NSURL *(NSString *imageName) {
        return self.URLWithFileNamed(imageNameExt);
    });
}

- (BOOL (^)(NSString *))isExistsImageNamed {
    return AGX_BLOCK_AUTORELEASE(^BOOL (NSString *imageName) {
        return self.isExistsFileNamed(imageNameExt);
    });
}

- (AGXAttributesType (^)(NSString *))attributesWithImageNamed {
    return AGX_BLOCK_AUTORELEASE(^AGXAttributesType (NSString *imageName) {
        return self.attributesWithFileNamed(imageNameExt);
    });
}

- (AGXAttributesType (^)(NSString *, NSError **))attributesExtWithImageNamed {
    return AGX_BLOCK_AUTORELEASE(^AGXAttributesType (NSString *imageName, NSError **error) {
        return self.attributesExtWithFileNamed(imageNameExt, error);
    });
}

#pragma mark -

- (NSBundle *)bundle {
    if (!self.isExistsDirectory) return nil;
    return [NSBundle bundleWithPath:self.path];
}

- (NSArray<NSString *> *)contents {
    return self.contentsExt(nil);
}

- (NSArray<NSString *> *(^)(NSError **))contentsExt {
    return AGX_BLOCK_AUTORELEASE(^NSArray<NSString *> *(NSError **error) {
        if (!self.isExistsDirectory) return nil;
        return [NSFileManager.defaultManager contentsOfDirectoryAtPath:self.path error:error];
    });
}

- (NSArray<NSString *> *)subpaths {
    return self.subpathsExt(nil);
}

- (NSArray<NSString *> *(^)(NSError **))subpathsExt {
    return AGX_BLOCK_AUTORELEASE(^NSArray<NSString *> *(NSError **error) {
        if (!self.isExistsDirectory) return nil;
        return [NSFileManager.defaultManager subpathsOfDirectoryAtPath:self.path error:error];
    });
}

#pragma mark -

- (NSString *(^)(NSString *))pathWithDirectoryNamed {
    return AGX_BLOCK_AUTORELEASE(^NSString *(NSString *directoryName) {
        return self.pathWithNamed(directoryName);
    });
}

- (NSURL *(^)(NSString *))URLWithDirectoryNamed {
    return AGX_BLOCK_AUTORELEASE(^NSURL *(NSString *directoryName) {
        return self.URLWithNamed(directoryName);
    });
}

- (BOOL (^)(NSString *))isExistsDirectoryNamed {
    return AGX_BLOCK_AUTORELEASE(^BOOL (NSString *directoryName) {
        BOOL isDirectory;
        BOOL exists = self.isExistsNamed(directoryName, &isDirectory);
        return exists && isDirectory;
    });
}

- (AGXAttributesType (^)(NSString *))attributesWithDirectoryNamed {
    return AGX_BLOCK_AUTORELEASE(^AGXAttributesType (NSString *directoryName) {
        return self.attributesWithNamed(directoryName);
    });
}

- (AGXAttributesType (^)(NSString *, NSError **))attributesExtWithDirectoryNamed {
    return AGX_BLOCK_AUTORELEASE(^AGXAttributesType (NSString *directoryName, NSError **error) {
        return self.attributesExtWithNamed(directoryName, error);
    });
}

- (NSBundle *(^)(NSString *))bundleWithDirectoryNamed {
    return AGX_BLOCK_AUTORELEASE(^NSBundle *(NSString *directoryName) {
        if (!self.isExistsDirectoryNamed(directoryName)) return nil;
        return [NSBundle bundleWithPath:self.pathWithNamed(directoryName)];
    });
}

- (NSArray<NSString *> *(^)(NSString *))contentsInDirectoryNamed {
    return AGX_BLOCK_AUTORELEASE(^NSArray<NSString *> *(NSString *directoryName) {
        return self.contentsExtInDirectoryNamed(directoryName, nil);
    });
}

- (NSArray<NSString *> *(^)(NSString *, NSError **))contentsExtInDirectoryNamed {
    return AGX_BLOCK_AUTORELEASE(^NSArray<NSString *> *(NSString *directoryName, NSError **error) {
        if (!self.isExistsDirectoryNamed(directoryName)) return nil;
        return [NSFileManager.defaultManager contentsOfDirectoryAtPath:self.pathWithNamed(directoryName) error:error];
    });
}

- (NSArray<NSString *> *(^)(NSString *))subpathsInDirectoryNamed {
    return AGX_BLOCK_AUTORELEASE(^NSArray<NSString *> *(NSString *directoryName) {
        return self.subpathsExtInDirectoryNamed(directoryName, nil);
    });
}

- (NSArray<NSString *> *(^)(NSString *, NSError **))subpathsExtInDirectoryNamed {
    return AGX_BLOCK_AUTORELEASE(^NSArray<NSString *> *(NSString *directoryName, NSError **error) {
        if (!self.isExistsDirectoryNamed(directoryName)) return nil;
        return [NSFileManager.defaultManager subpathsOfDirectoryAtPath:self.pathWithNamed(directoryName) error:error];
    });
}

- (NSString *(^)(NSString *))pathWithBundleNamed {
    return AGX_BLOCK_AUTORELEASE(^NSString *(NSString *bundleName) {
        return self.pathWithDirectoryNamed(bundleNameExt);
    });
}

- (NSURL *(^)(NSString *))URLWithBundleNamed {
    return AGX_BLOCK_AUTORELEASE(^NSURL *(NSString *bundleName) {
        return self.URLWithDirectoryNamed(bundleNameExt);
    });
}

- (BOOL (^)(NSString *))isExistsBundleNamed {
    return AGX_BLOCK_AUTORELEASE(^BOOL (NSString *bundleName) {
        return self.isExistsDirectoryNamed(bundleNameExt);
    });
}

- (AGXAttributesType (^)(NSString *))attributesWithBundleNamed {
    return AGX_BLOCK_AUTORELEASE(^AGXAttributesType (NSString *bundleName) {
        return self.attributesWithDirectoryNamed(bundleNameExt);
    });
}

- (AGXAttributesType (^)(NSString *, NSError **))attributesExtWithBundleNamed {
    return AGX_BLOCK_AUTORELEASE(^AGXAttributesType (NSString *bundleName, NSError **error) {
        return self.attributesExtWithDirectoryNamed(bundleNameExt, error);
    });
}

- (NSBundle *(^)(NSString *))bundleWithBundleNamed {
    return AGX_BLOCK_AUTORELEASE(^NSBundle *(NSString *bundleName) {
        return self.bundleWithDirectoryNamed(bundleNameExt);
    });
}

- (NSArray<NSString *> *(^)(NSString *))contentsInBundleNamed {
    return AGX_BLOCK_AUTORELEASE(^NSArray<NSString *> *(NSString *bundleName) {
        return self.contentsInDirectoryNamed(bundleNameExt);
    });
}

- (NSArray<NSString *> *(^)(NSString *, NSError **))contentsExtInBundleNamed {
    return AGX_BLOCK_AUTORELEASE(^NSArray<NSString *> *(NSString *bundleName, NSError **error) {
        return self.contentsExtInDirectoryNamed(bundleNameExt, error);
    });
}

- (NSArray<NSString *> *(^)(NSString *))subpathsInBundleNamed {
    return AGX_BLOCK_AUTORELEASE(^NSArray<NSString *> *(NSString *bundleName) {
        return self.subpathsInDirectoryNamed(bundleNameExt);
    });
}

- (NSArray<NSString *> *(^)(NSString *, NSError **))subpathsExtInBundleNamed {
    return AGX_BLOCK_AUTORELEASE(^NSArray<NSString *> *(NSString *bundleName, NSError **error) {
        return self.subpathsExtInDirectoryNamed(bundleNameExt, error);
    });
}

- (NSString *(^)(NSString *))pathWithLprojNamed {
    return AGX_BLOCK_AUTORELEASE(^NSString *(NSString *lprojName) {
        return self.pathWithDirectoryNamed(lprojNameExt);
    });
}

- (NSURL *(^)(NSString *))URLWithLprojNamed {
    return AGX_BLOCK_AUTORELEASE(^NSURL *(NSString *lprojName) {
        return self.URLWithDirectoryNamed(lprojNameExt);
    });
}

- (BOOL (^)(NSString *))isExistsLprojNamed {
    return AGX_BLOCK_AUTORELEASE(^BOOL (NSString *lprojName) {
        return self.isExistsDirectoryNamed(lprojNameExt);
    });
}

- (AGXAttributesType (^)(NSString *))attributesWithLprojNamed {
    return AGX_BLOCK_AUTORELEASE(^AGXAttributesType (NSString *lprojName) {
        return self.attributesWithDirectoryNamed(lprojNameExt);
    });
}

- (AGXAttributesType (^)(NSString *, NSError **))attributesExtWithLprojNamed {
    return AGX_BLOCK_AUTORELEASE(^AGXAttributesType (NSString *lprojName, NSError **error) {
        return self.attributesExtWithDirectoryNamed(lprojNameExt, error);
    });
}

- (NSBundle *(^)(NSString *))bundleWithLprojNamed {
    return AGX_BLOCK_AUTORELEASE(^NSBundle *(NSString *lprojName) {
        return self.bundleWithDirectoryNamed(lprojNameExt);
    });
}

- (NSArray<NSString *> *(^)(NSString *))contentsInLprojNamed {
    return AGX_BLOCK_AUTORELEASE(^NSArray<NSString *> *(NSString *lprojName) {
        return self.contentsInDirectoryNamed(lprojNameExt);
    });
}

- (NSArray<NSString *> *(^)(NSString *, NSError **))contentsExtInLprojNamed {
    return AGX_BLOCK_AUTORELEASE(^NSArray<NSString *> *(NSString *lprojName, NSError **error) {
        return self.contentsExtInDirectoryNamed(lprojNameExt, error);
    });
}

- (NSArray<NSString *> *(^)(NSString *))subpathsInLprojNamed {
    return AGX_BLOCK_AUTORELEASE(^NSArray<NSString *> *(NSString *lprojName) {
        return self.subpathsInDirectoryNamed(lprojNameExt);
    });
}

- (NSArray<NSString *> *(^)(NSString *, NSError **))subpathsExtInLprojNamed {
    return AGX_BLOCK_AUTORELEASE(^NSArray<NSString *> *(NSString *lprojName, NSError **error) {
        return self.subpathsExtInDirectoryNamed(lprojNameExt, error);
    });
}

#pragma mark - manage methods (override) -

- (BOOL (^)(AGXAttributesType))setAttributes {
    return AGX_BLOCK_AUTORELEASE(^BOOL (AGXAttributesType attributes) {
        return self.setAttributesExt(attributes, nil);
    });
}

- (BOOL (^)(AGXAttributesType, NSError **))setAttributesExt {
    // Override
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

- (BOOL)remove {
    return self.removeExt(nil);
}

- (BOOL (^)(NSError **))removeExt {
    // Override
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

- (BOOL (^)(NSString *, AGXAttributesType))setAttributesWithNamed {
    return AGX_BLOCK_AUTORELEASE(^BOOL (NSString *name, AGXAttributesType attributes) {
        return self.setAttributesExtWithNamed(name, attributes, nil);
    });
}

- (BOOL (^)(NSString *, AGXAttributesType, NSError **))setAttributesExtWithNamed {
    // Override
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

- (BOOL (^)(NSString *))removeNamed {
    return AGX_BLOCK_AUTORELEASE(^BOOL (NSString *name) {
        return self.removeExtNamed(name, nil);
    });
}

- (BOOL (^)(NSString *, NSError **))removeExtNamed {
    // Override
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

- (BOOL (^)(NSString *, AGXAttributesType))setAttributesWithFileNamed {
    return AGX_BLOCK_AUTORELEASE(^BOOL (NSString *fileName, AGXAttributesType attributes) {
        return self.setAttributesWithNamed(fileName, attributes);
    });
}

- (BOOL (^)(NSString *, AGXAttributesType, NSError **))setAttributesExtWithFileNamed {
    return AGX_BLOCK_AUTORELEASE(^BOOL (NSString *fileName, AGXAttributesType attributes, NSError **error) {
        return self.setAttributesExtWithNamed(fileName, attributes, error);
    });
}

- (BOOL (^)(NSString *))removeFileNamed {
    return AGX_BLOCK_AUTORELEASE(^BOOL (NSString *fileName) {
        return self.removeNamed(fileName);
    });
}

- (BOOL (^)(NSString *, NSError **))removeExtFileNamed {
    return AGX_BLOCK_AUTORELEASE(^BOOL (NSString *fileName, NSError **error) {
        return self.removeExtNamed(fileName, error);
    });
}

- (BOOL (^)(NSString *, AGXAttributesType))setAttributesWithPlistNamed {
    return AGX_BLOCK_AUTORELEASE(^BOOL (NSString *plistName, AGXAttributesType attributes) {
        return self.setAttributesWithFileNamed(plistNameExt, attributes);
    });
}

- (BOOL (^)(NSString *, AGXAttributesType, NSError **))setAttributesExtWithPlistNamed {
    return AGX_BLOCK_AUTORELEASE(^BOOL (NSString *plistName, AGXAttributesType attributes, NSError **error) {
        return self.setAttributesExtWithFileNamed(plistNameExt, attributes, error);
    });
}

- (BOOL (^)(NSString *))removePlistNamed {
    return AGX_BLOCK_AUTORELEASE(^BOOL (NSString *plistName) {
        return self.removeFileNamed(plistNameExt);
    });
}

- (BOOL (^)(NSString *, NSError **))removeExtPlistNamed {
    return AGX_BLOCK_AUTORELEASE(^BOOL (NSString *plistName, NSError **error) {
        return self.removeExtFileNamed(plistNameExt, error);
    });
}

- (BOOL (^)(NSString *, AGXAttributesType))setAttributesWithImageNamed {
    return AGX_BLOCK_AUTORELEASE(^BOOL (NSString *imageName, AGXAttributesType attributes) {
        return self.setAttributesWithFileNamed(imageNameExt, attributes);
    });
}

- (BOOL (^)(NSString *, AGXAttributesType, NSError **))setAttributesExtWithImageNamed {
    return AGX_BLOCK_AUTORELEASE(^BOOL (NSString *imageName, AGXAttributesType attributes, NSError **error) {
        return self.setAttributesExtWithFileNamed(imageNameExt, attributes, error);
    });
}

- (BOOL (^)(NSString *))removeImageNamed {
    return AGX_BLOCK_AUTORELEASE(^BOOL (NSString *imageName) {
        return self.removeFileNamed(imageNameExt);
    });
}

- (BOOL (^)(NSString *, NSError **))removeExtImageNamed {
    return AGX_BLOCK_AUTORELEASE(^BOOL (NSString *imageName, NSError **error) {
        return self.removeExtFileNamed(imageNameExt, error);
    });
}

#pragma mark -

- (BOOL)createDirectory {
    return self.createExtDirectory(nil, nil);
}

- (BOOL (^)(AGXAttributesType, NSError **))createExtDirectory {
    // Override
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

#pragma mark -

- (BOOL (^)(NSString *, AGXAttributesType))setAttributesWithDirectoryNamed {
    return AGX_BLOCK_AUTORELEASE(^BOOL (NSString *directoryName, AGXAttributesType attributes) {
        return self.setAttributesWithNamed(directoryName, attributes);
    });
}

- (BOOL (^)(NSString *, AGXAttributesType, NSError **))setAttributesExtWithDirectoryNamed {
    return AGX_BLOCK_AUTORELEASE(^BOOL (NSString *directoryName, AGXAttributesType attributes, NSError **error) {
        return self.setAttributesExtWithNamed(directoryName, attributes, error);
    });
}

- (BOOL (^)(NSString *))removeDirectoryNamed {
    return AGX_BLOCK_AUTORELEASE(^BOOL (NSString *directoryName) {
        return self.removeNamed(directoryName);
    });
}

- (BOOL (^)(NSString *, NSError **))removeExtDirectoryNamed {
    return AGX_BLOCK_AUTORELEASE(^BOOL (NSString *directoryName, NSError **error) {
        return self.removeExtNamed(directoryName, error);
    });
}

- (BOOL (^)(NSString *))createDirectoryNamed {
    return AGX_BLOCK_AUTORELEASE(^BOOL (NSString *directoryName) {
        return self.createExtDirectoryNamed(directoryName, nil, nil);
    });
}

- (BOOL (^)(NSString *, AGXAttributesType, NSError **))createExtDirectoryNamed {
    // Override
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

- (BOOL (^)(NSString *, AGXAttributesType))setAttributesWithBundleNamed {
    return AGX_BLOCK_AUTORELEASE(^BOOL (NSString *bundleName, AGXAttributesType attributes) {
        return self.setAttributesWithDirectoryNamed(bundleNameExt, attributes);
    });
}

- (BOOL (^)(NSString *, AGXAttributesType, NSError **))setAttributesExtWithBundleNamed {
    return AGX_BLOCK_AUTORELEASE(^BOOL (NSString *bundleName, AGXAttributesType attributes, NSError **error) {
        return self.setAttributesExtWithDirectoryNamed(bundleNameExt, attributes, error);
    });
}

- (BOOL (^)(NSString *))removeBundleNamed {
    return AGX_BLOCK_AUTORELEASE(^BOOL (NSString *bundleName) {
        return self.removeDirectoryNamed(bundleNameExt);
    });
}

- (BOOL (^)(NSString *, NSError **))removeExtBundleNamed {
    return AGX_BLOCK_AUTORELEASE(^BOOL (NSString *bundleName, NSError **error) {
        return self.removeExtDirectoryNamed(bundleNameExt, error);
    });
}

- (BOOL (^)(NSString *))createBundleNamed {
    return AGX_BLOCK_AUTORELEASE(^BOOL (NSString *bundleName) {
        return self.createDirectoryNamed(bundleNameExt);
    });
}

- (BOOL (^)(NSString *, AGXAttributesType, NSError **))createExtBundleNamed {
    return AGX_BLOCK_AUTORELEASE(^BOOL (NSString *bundleName, AGXAttributesType attributes, NSError **error) {
        return self.createExtDirectoryNamed(bundleNameExt, attributes, error);
    });
}

- (BOOL (^)(NSString *, AGXAttributesType))setAttributesWithLprojNamed {
    return AGX_BLOCK_AUTORELEASE(^BOOL (NSString *lprojName, AGXAttributesType attributes) {
        return self.setAttributesWithDirectoryNamed(lprojNameExt, attributes);
    });
}

- (BOOL (^)(NSString *, AGXAttributesType, NSError **))setAttributesExtWithLprojNamed {
    return AGX_BLOCK_AUTORELEASE(^BOOL (NSString *lprojName, AGXAttributesType attributes, NSError **error) {
        return self.setAttributesExtWithDirectoryNamed(lprojNameExt, attributes, error);
    });
}

- (BOOL (^)(NSString *))removeLprojNamed {
    return AGX_BLOCK_AUTORELEASE(^BOOL (NSString *lprojName) {
        return self.removeDirectoryNamed(lprojNameExt);
    });
}

- (BOOL (^)(NSString *, NSError **))removeExtLprojNamed {
    return AGX_BLOCK_AUTORELEASE(^BOOL (NSString *lprojName, NSError **error) {
        return self.removeExtDirectoryNamed(lprojNameExt, error);
    });
}

- (BOOL (^)(NSString *))createLprojNamed {
    return AGX_BLOCK_AUTORELEASE(^BOOL (NSString *lprojName) {
        return self.createDirectoryNamed(lprojNameExt);
    });
}

- (BOOL (^)(NSString *, AGXAttributesType, NSError **))createExtLprojNamed {
    return AGX_BLOCK_AUTORELEASE(^BOOL (NSString *lprojName, AGXAttributesType attributes, NSError **error) {
        return self.createExtDirectoryNamed(lprojNameExt, attributes, error);
    });
}

- (BOOL (^)(NSString *))createPathOfFileNamed {
    return AGX_BLOCK_AUTORELEASE(^BOOL (NSString *fileName) {
        return self.createDirectoryNamed(fileName.stringByDeletingLastPathComponent);
    });
}

- (BOOL (^)(NSString *, AGXAttributesType, NSError **))createExtPathOfFileNamed {
    return AGX_BLOCK_AUTORELEASE(^BOOL (NSString *fileName, AGXAttributesType attributes, NSError **error) {
        return self.createExtDirectoryNamed(fileName.stringByDeletingLastPathComponent, attributes, error);
    });
}

#pragma mark - content read methods -

- (NSData *(^)(NSString *))dataWithFileNamed {
    return AGX_BLOCK_AUTORELEASE(^NSData *(NSString *fileName) {
        return [NSData dataWithContentsOfFile:self.pathWithFileNamed(fileName)];
    });
}

- (id<NSCoding> (^)(NSString *))contentWithFileNamed {
    return AGX_BLOCK_AUTORELEASE(^id<NSCoding> (NSString *fileName) {
        NSData *data = self.dataWithFileNamed(fileName);
        return data ? [NSKeyedUnarchiver unarchiveObjectWithData:data] : nil;
    });
}

- (NSString *(^)(NSString *, NSStringEncoding))stringWithFileNamed {
    return AGX_BLOCK_AUTORELEASE(^NSString *(NSString *fileName, NSStringEncoding encoding) {
        return [NSString stringWithContentsOfFile:self.pathWithFileNamed(fileName) encoding:encoding error:nil];
    });
}

- (NSArray *(^)(NSString *))arrayWithFileNamed {
    return AGX_BLOCK_AUTORELEASE(^NSArray *(NSString *fileName) {
        return [NSArray arrayWithContentsOfFilePath:self.pathWithFileNamed(fileName)];
    });
}

- (NSArray *(^)(NSString *))arrayWithPlistNamed {
    return AGX_BLOCK_AUTORELEASE(^NSArray *(NSString *plistName) {
        return [NSArray arrayWithContentsOfFilePath:self.pathWithPlistNamed(plistName)];
    });
}

- (NSDictionary *(^)(NSString *))dictionaryWithFileNamed {
    return AGX_BLOCK_AUTORELEASE(^NSDictionary *(NSString *fileName) {
        return [NSDictionary dictionaryWithContentsOfFilePath:self.pathWithFileNamed(fileName)];
    });
}

- (NSDictionary *(^)(NSString *))dictionaryWithPlistNamed {
    return AGX_BLOCK_AUTORELEASE(^NSDictionary *(NSString *plistName) {
        return [NSDictionary dictionaryWithContentsOfFilePath:self.pathWithPlistNamed(plistName)];
    });
}

- (NSSet *(^)(NSString *))setWithFileNamed {
    return AGX_BLOCK_AUTORELEASE(^NSSet *(NSString *fileName) {
        return [NSSet setWithArray:self.arrayWithFileNamed(fileName)];
    });
}

- (NSSet *(^)(NSString *))setWithPlistNamed {
    return AGX_BLOCK_AUTORELEASE(^NSSet *(NSString *plistName) {
        return [NSSet setWithArray:self.arrayWithPlistNamed(plistName)];
    });
}

- (UIImage *(^)(NSString *))imageWithFileNamed {
    return AGX_BLOCK_AUTORELEASE(^UIImage *(NSString *fileName) {
        return [UIImage imageWithContentsOfFile:self.pathWithFileNamed(fileName)];
    });
}

- (UIImage *(^)(NSString *))imageWithImageNamed {
    return AGX_BLOCK_AUTORELEASE(^UIImage *(NSString *imageName) {
        return [UIImage imageWithContentsOfFile:self.pathWithImageNamed(imageName)];
    });
}

#pragma mark - content write methods (override) -

- (BOOL (^)(NSString *, NSData *))writeDataWithFileNamed {
    // Override
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

- (BOOL (^)(NSString *, id<NSCoding>))writeContentWithFileNamed {
    return AGX_BLOCK_AUTORELEASE(^BOOL (NSString *fileName, id<NSCoding> content) {
        return self.writeDataWithFileNamed(fileName, [NSKeyedArchiver archivedDataWithRootObject:content]);
    });
}

- (BOOL (^)(NSString *, NSString *, NSStringEncoding))writeStringWithFileNamed {
    // Override
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

- (BOOL (^)(NSString *, NSArray *))writeArrayWithFileNamed {
    // Override
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

- (BOOL (^)(NSString *, NSArray *))writeArrayWithPlistNamed {
    return AGX_BLOCK_AUTORELEASE(^BOOL (NSString *plistName, NSArray *array) {
        return self.writeArrayWithFileNamed([plistName stringByAppendingPathExtension:@"plist"], array);
    });
}

- (BOOL (^)(NSString *, NSDictionary *))writeDictionaryWithFileNamed {
    // Override
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

- (BOOL (^)(NSString *, NSDictionary *))writeDictionaryWithPlistNamed {
    return AGX_BLOCK_AUTORELEASE(^BOOL (NSString *plistName, NSDictionary *dictionary) {
        return self.writeDictionaryWithFileNamed([plistName stringByAppendingPathExtension:@"plist"], dictionary);
    });
}

- (BOOL (^)(NSString *, NSSet *))writeSetWithFileNamed {
    return AGX_BLOCK_AUTORELEASE(^BOOL (NSString *fileName, NSSet *set) {
        return self.writeArrayWithFileNamed(fileName, set.allObjects);
    });
}

- (BOOL (^)(NSString *, NSSet *))writeSetWithPlistNamed {
    return AGX_BLOCK_AUTORELEASE(^BOOL (NSString *plistName, NSSet *set) {
        return self.writeSetWithFileNamed([plistName stringByAppendingPathExtension:@"plist"], set);
    });
}

- (BOOL (^)(NSString *, UIImage *))writeImageWithFileNamed {
    return AGX_BLOCK_AUTORELEASE(^BOOL (NSString *fileName, UIImage *image) {
        return self.writeDataWithFileNamed(fileName, UIImagePNGRepresentation(image));
    });
}

- (BOOL (^)(NSString *, UIImage *))writeImageWithImageNamed {
    return AGX_BLOCK_AUTORELEASE(^BOOL (NSString *imageName, UIImage *image) {
        return self.writeImageWithFileNamed([imageName stringByAppendingPathExtension:@"png"], image);
    });
}

@end

#pragma mark -

@implementation AGXBundleResources

#pragma mark - initial methods -

+ (AGX_INSTANCETYPE)application {
    return AGX_AUTORELEASE([[self alloc] initWithRoot:
                            [NSBundle bundleForClass:AGXResources.class].resourcePath]);
}

#pragma mark - indicate methods -

- (NSString *)path {
    return [self.root stringByAppendingPathComponent:self.subpath];
}

@end

#pragma mark -

@implementation AGXUserDomainResources

#pragma mark - initial methods -

+ (AGX_INSTANCETYPE)document {
    return AGX_AUTORELEASE([[self alloc] initWithRoot:
                            NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).firstObject]);
}

+ (AGX_INSTANCETYPE)caches {
    return AGX_AUTORELEASE([[self alloc] initWithRoot:
                            NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES).firstObject]);
}

+ (AGX_INSTANCETYPE)temporary {
    return AGX_AUTORELEASE([[self alloc] initWithRoot:
                            [NSHomeDirectory() stringByAppendingPathComponent:@"tmp"]]);
}

#pragma mark - indicate methods -

- (NSString *)path {
    return [self.root stringByAppendingPathComponent:self.subpath];
}

#pragma mark - manage methods -

- (BOOL (^)(AGXAttributesType, NSError **))setAttributesExt {
    return AGX_BLOCK_AUTORELEASE(^BOOL (AGXAttributesType attributes, NSError **error) {
        return [NSFileManager.defaultManager setAttributes:attributes ofItemAtPath:self.path error:error];
    });
}

- (BOOL (^)(NSError **))removeExt {
    return AGX_BLOCK_AUTORELEASE(^BOOL (NSError **error) {
        return [NSFileManager.defaultManager removeItemAtPath:self.path error:error];
    });
}

- (BOOL (^)(NSString *, AGXAttributesType, NSError **))setAttributesExtWithNamed {
    return AGX_BLOCK_AUTORELEASE(^BOOL (NSString *name, AGXAttributesType attributes, NSError **error) {
        return [NSFileManager.defaultManager setAttributes:attributes ofItemAtPath:self.pathWithNamed(name) error:error];
    });
}

- (BOOL (^)(NSString *, NSError **))removeExtNamed {
    return AGX_BLOCK_AUTORELEASE(^BOOL (NSString *name, NSError **error) {
        return [NSFileManager.defaultManager removeItemAtPath:self.pathWithNamed(name) error:error];
    });
}

- (BOOL (^)(AGXAttributesType, NSError **))createExtDirectory {
    return AGX_BLOCK_AUTORELEASE(^BOOL (AGXAttributesType attributes, NSError **error) {
        if (self.isExistsDirectory) return YES;
        if AGX_EXPECT_F(self.isExistsFile) [self remove];
        return [NSFileManager.defaultManager createDirectoryAtPath:
                self.path withIntermediateDirectories:YES attributes:attributes error:error];
    });
}

- (BOOL (^)(NSString *, AGXAttributesType, NSError **))createExtDirectoryNamed {
    return AGX_BLOCK_AUTORELEASE(^BOOL (NSString *directoryName, AGXAttributesType attributes, NSError **error) {
        if (self.isExistsDirectoryNamed(directoryName)) return YES;
        if AGX_EXPECT_F(self.isExistsFileNamed(directoryName)) self.removeFileNamed(directoryName);
        return [NSFileManager.defaultManager createDirectoryAtPath:
                self.pathWithDirectoryNamed(directoryName) withIntermediateDirectories:YES attributes:attributes error:error];
    });
}

#pragma mark - content write methods -

- (BOOL (^)(NSString *, NSData *))writeDataWithFileNamed {
    return AGX_BLOCK_AUTORELEASE(^BOOL (NSString *fileName, NSData *data) {
        if AGX_EXPECT_F(self.isExistsDirectoryNamed(fileName)) self.removeDirectoryNamed(fileName);
        return(self.createPathOfFileNamed(fileName) &&
               [data writeToFile:self.pathWithFileNamed(fileName) atomically:YES]);
    });
}

- (BOOL (^)(NSString *, NSString *, NSStringEncoding))writeStringWithFileNamed {
    return AGX_BLOCK_AUTORELEASE(^BOOL (NSString *fileName, NSString *string, NSStringEncoding encoding) {
        if AGX_EXPECT_F(self.isExistsDirectoryNamed(fileName)) self.removeDirectoryNamed(fileName);
        return(self.createPathOfFileNamed(fileName) &&
               [string writeToFile:self.pathWithFileNamed(fileName) atomically:YES encoding:encoding error:nil]);
    });
}

- (BOOL (^)(NSString *, NSArray *))writeArrayWithFileNamed {
    return AGX_BLOCK_AUTORELEASE(^BOOL (NSString *fileName, NSArray *array) {
        if AGX_EXPECT_F(self.isExistsDirectoryNamed(fileName)) self.removeDirectoryNamed(fileName);
        return(self.createPathOfFileNamed(fileName) &&
               [array writeToFile:self.pathWithFileNamed(fileName) atomically:YES]);
    });
}

- (BOOL (^)(NSString *, NSDictionary *))writeDictionaryWithFileNamed {
    return AGX_BLOCK_AUTORELEASE(^BOOL (NSString *fileName, NSDictionary *dictionary) {
        if AGX_EXPECT_F(self.isExistsDirectoryNamed(fileName)) self.removeDirectoryNamed(fileName);
        return(self.createPathOfFileNamed(fileName) &&
               [dictionary writeToFile:self.pathWithFileNamed(fileName) atomically:YES]);
    });
}

@end

#undef plistNameExt
#undef imageNameExt
#undef bundleNameExt
#undef lprojNameExt
