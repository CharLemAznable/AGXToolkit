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

#pragma mark -

@interface AGXUserDomainResources : AGXResources
#pragma mark -
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
    return AGX_AUTORELEASE([[self alloc] initWithRoot:
                            [NSBundle bundleForClass:AGXResources.class].resourcePath]);
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

#pragma mark - indicate methods -

- (NSString *)path {
    return [_root stringByAppendingPathComponent:_subpath];
}

- (NSURL *)URL {
    return [NSURL fileURLWithPath:self.path];
}

- (BOOL)isExistsFile {
    BOOL isDirectory;
    BOOL exists = [NSFileManager.defaultManager fileExistsAtPath
                   :self.path isDirectory:&isDirectory];
    return exists && !isDirectory;
}

- (NSString *(^)(NSString *))pathWithFileNamed {
    return AGX_BLOCK_AUTORELEASE(^NSString *(NSString *fileName) {
        return [self.path stringByAppendingPathComponent:fileName];
    });
}

- (NSURL *(^)(NSString *))URLWithFileNamed {
    return AGX_BLOCK_AUTORELEASE(^NSURL *(NSString *fileName) {
        return [NSURL fileURLWithPath:self.pathWithFileNamed(fileName)];
    });
}

- (BOOL (^)(NSString *))isExistsFileNamed {
    return AGX_BLOCK_AUTORELEASE(^BOOL (NSString *fileName) {
        BOOL isDirectory;
        BOOL exists = [NSFileManager.defaultManager fileExistsAtPath
                       :self.pathWithFileNamed(fileName) isDirectory:&isDirectory];
        return exists && !isDirectory;
    });
}

- (NSString *(^)(NSString *))pathWithPlistNamed {
    return AGX_BLOCK_AUTORELEASE(^NSString *(NSString *plistName) {
        return self.pathWithFileNamed([plistName stringByAppendingPathExtension:@"plist"]);
    });
}

- (NSURL *(^)(NSString *))URLWithPlistNamed {
    return AGX_BLOCK_AUTORELEASE(^NSURL *(NSString *plistName) {
        return self.URLWithFileNamed([plistName stringByAppendingPathExtension:@"plist"]);
    });
}

- (BOOL (^)(NSString *))isExistsPlistNamed {
    return AGX_BLOCK_AUTORELEASE(^BOOL (NSString *plistName) {
        return self.isExistsFileNamed([plistName stringByAppendingPathExtension:@"plist"]);
    });
}

- (NSString *(^)(NSString *))pathWithImageNamed {
    return AGX_BLOCK_AUTORELEASE(^NSString *(NSString *imageName) {
        return self.pathWithFileNamed([imageName stringByAppendingPathExtension:@"png"]);
    });
}

- (NSURL *(^)(NSString *))URLWithImageNamed {
    return AGX_BLOCK_AUTORELEASE(^NSURL *(NSString *imageName) {
        return self.URLWithFileNamed([imageName stringByAppendingPathExtension:@"png"]);
    });
}

- (BOOL (^)(NSString *))isExistsImageNamed {
    return AGX_BLOCK_AUTORELEASE(^BOOL (NSString *imageName) {
        return self.isExistsFileNamed([imageName stringByAppendingPathExtension:@"png"]);
    });
}

- (NSBundle *)bundle {
    if (!self.isExistsDirectory) return nil;
    return [NSBundle bundleWithPath:self.path];
}

- (BOOL)isExistsDirectory {
    BOOL isDirectory;
    BOOL exists = [NSFileManager.defaultManager fileExistsAtPath
                   :self.path isDirectory:&isDirectory];
    return exists && isDirectory;
}

- (NSString *(^)(NSString *))pathWithDirectoryNamed {
    return AGX_BLOCK_AUTORELEASE(^NSString *(NSString *directoryName) {
        return self.pathWithFileNamed(directoryName);
    });
}

- (NSBundle *(^)(NSString *))bundleWithDirectoryNamed {
    return AGX_BLOCK_AUTORELEASE(^NSBundle *(NSString *directoryName) {
        if (!self.isExistsDirectoryNamed(directoryName)) return nil;
        return [NSBundle bundleWithPath:self.pathWithDirectoryNamed(directoryName)];
    });
}

- (BOOL (^)(NSString *))isExistsDirectoryNamed {
    return AGX_BLOCK_AUTORELEASE(^BOOL (NSString *directoryName) {
        BOOL isDirectory;
        BOOL exists = [NSFileManager.defaultManager fileExistsAtPath
                       :self.pathWithDirectoryNamed(directoryName) isDirectory:&isDirectory];
        return exists && isDirectory;
    });
}

- (NSString *(^)(NSString *))pathWithBundleNamed {
    return AGX_BLOCK_AUTORELEASE(^NSString *(NSString *bundleName) {
        return self.pathWithDirectoryNamed([bundleName stringByAppendingPathExtension:@"bundle"]);
    });
}

- (NSBundle *(^)(NSString *))bundleWithBundleNamed {
    return AGX_BLOCK_AUTORELEASE(^NSBundle *(NSString *bundleName) {
        return self.bundleWithDirectoryNamed([bundleName stringByAppendingPathExtension:@"bundle"]);
    });
}

- (BOOL (^)(NSString *))isExistsBundleNamed {
    return AGX_BLOCK_AUTORELEASE(^BOOL (NSString *bundleName) {
        return self.isExistsDirectoryNamed([bundleName stringByAppendingPathExtension:@"bundle"]);
    });
}

- (NSString *(^)(NSString *))pathWithLprojNamed {
    return AGX_BLOCK_AUTORELEASE(^NSString *(NSString *lprojName) {
        return self.pathWithDirectoryNamed([lprojName stringByAppendingPathExtension:@"lproj"]);
    });
}

- (NSBundle *(^)(NSString *))bundleWithLprojNamed {
    return AGX_BLOCK_AUTORELEASE(^NSBundle *(NSString *lprojName) {
        return self.bundleWithDirectoryNamed([lprojName stringByAppendingPathExtension:@"lproj"]);
    });
}

- (BOOL (^)(NSString *))isExistsLprojNamed {
    return AGX_BLOCK_AUTORELEASE(^BOOL (NSString *lprojName) {
        return self.isExistsDirectoryNamed([lprojName stringByAppendingPathExtension:@"lproj"]);
    });
}

#pragma mark - manage methods (override) -

- (BOOL)createDirectory {
    [self doesNotRecognizeSelector:_cmd];
    return NO;
}

- (BOOL)deleteDirectory {
    return self.deleteFile;
}

- (BOOL (^)(NSString *))createDirectoryNamed {
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

- (BOOL (^)(NSString *))deleteDirectoryNamed {
    return AGX_BLOCK_AUTORELEASE(^BOOL (NSString *directoryName) {
        return self.deleteFileNamed(directoryName);
    });
}

- (BOOL (^)(NSString *))createBundleNamed {
    return AGX_BLOCK_AUTORELEASE(^BOOL (NSString *bundleName) {
        return self.createDirectoryNamed([bundleName stringByAppendingPathExtension:@"bundle"]);
    });
}

- (BOOL (^)(NSString *))deleteBundleNamed {
    return AGX_BLOCK_AUTORELEASE(^BOOL (NSString *bundleName) {
        return self.deleteDirectoryNamed([bundleName stringByAppendingPathExtension:@"bundle"]);
    });
}

- (BOOL (^)(NSString *))createLprojNamed {
    return AGX_BLOCK_AUTORELEASE(^BOOL (NSString *lprojName) {
        return self.createDirectoryNamed([lprojName stringByAppendingPathExtension:@"lproj"]);
    });
}

- (BOOL (^)(NSString *))deleteLprojNamed {
    return AGX_BLOCK_AUTORELEASE(^BOOL (NSString *lprojName) {
        return self.deleteDirectoryNamed([lprojName stringByAppendingPathExtension:@"lproj"]);
    });
}

- (BOOL (^)(NSString *))createPathOfFileNamed {
    return AGX_BLOCK_AUTORELEASE(^BOOL (NSString *fileName) {
        return self.createDirectoryNamed(fileName.stringByDeletingLastPathComponent);
    });
}

- (BOOL)deleteFile {
    [self doesNotRecognizeSelector:_cmd];
    return NO;
}

- (BOOL (^)(NSString *))deleteFileNamed {
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

- (BOOL (^)(NSString *))deletePlistNamed {
    return AGX_BLOCK_AUTORELEASE(^BOOL (NSString *plistName) {
        return self.deleteFileNamed([plistName stringByAppendingPathExtension:@"plist"]);
    });
}

- (BOOL (^)(NSString *))deleteImageNamed {
    return AGX_BLOCK_AUTORELEASE(^BOOL (NSString *imageName) {
        return self.deleteFileNamed([imageName stringByAppendingPathExtension:@"png"]);
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
    return AGX_BLOCK_AUTORELEASE(^NSArray *(NSString *fileName) {
        return [NSArray arrayWithContentsOfFilePath:self.pathWithPlistNamed(fileName)];
    });
}

- (NSDictionary *(^)(NSString *))dictionaryWithFileNamed {
    return AGX_BLOCK_AUTORELEASE(^NSDictionary *(NSString *fileName) {
        return [NSDictionary dictionaryWithContentsOfFilePath:self.pathWithFileNamed(fileName)];
    });
}

- (NSDictionary *(^)(NSString *))dictionaryWithPlistNamed {
    return AGX_BLOCK_AUTORELEASE(^NSDictionary *(NSString *fileName) {
        return [NSDictionary dictionaryWithContentsOfFilePath:self.pathWithPlistNamed(fileName)];
    });
}

- (NSSet *(^)(NSString *))setWithFileNamed {
    return AGX_BLOCK_AUTORELEASE(^NSSet *(NSString *fileName) {
        return [NSSet setWithArray:self.arrayWithFileNamed(fileName)];
    });
}

- (NSSet *(^)(NSString *))setWithPlistNamed {
    return AGX_BLOCK_AUTORELEASE(^NSSet *(NSString *fileName) {
        return [NSSet setWithArray:self.arrayWithPlistNamed(fileName)];
    });
}

- (UIImage *(^)(NSString *))imageWithFileNamed {
    return AGX_BLOCK_AUTORELEASE(^UIImage *(NSString *fileName) {
        return [UIImage imageWithContentsOfFile:self.pathWithFileNamed(fileName)];
    });
}

- (UIImage *(^)(NSString *))imageWithImageNamed {
    return AGX_BLOCK_AUTORELEASE(^UIImage *(NSString *fileName) {
        return [UIImage imageWithContentsOfFile:self.pathWithImageNamed(fileName)];
    });
}

#pragma mark - content write methods (override) -

- (BOOL (^)(NSString *, NSData *))writeDataWithFileNamed {
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

- (BOOL (^)(NSString *, id<NSCoding>))writeContentWithFileNamed {
    return AGX_BLOCK_AUTORELEASE(^BOOL (NSString *fileName, id<NSCoding> content) {
        return self.writeDataWithFileNamed(fileName, [NSKeyedArchiver archivedDataWithRootObject:content]);
    });
}

- (BOOL (^)(NSString *, NSString *, NSStringEncoding))writeStringWithFileNamed {
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

- (BOOL (^)(NSString *, NSArray *))writeArrayWithFileNamed {
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

- (BOOL (^)(NSString *, NSArray *))writeArrayWithPlistNamed {
    return AGX_BLOCK_AUTORELEASE(^BOOL (NSString *plistName, NSArray *array) {
        return self.writeArrayWithFileNamed([plistName stringByAppendingPathExtension:@"plist"], array);
    });
}

- (BOOL (^)(NSString *, NSDictionary *))writeDictionaryWithFileNamed {
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

#pragma mark - manage methods -

- (BOOL)createDirectory {
    if (self.isExistsDirectory) return YES;
    if AGX_EXPECT_F(self.isExistsFile) [self deleteFile];
    return [NSFileManager.defaultManager createDirectoryAtPath:
            self.path withIntermediateDirectories:YES attributes:nil error:nil];
}

- (BOOL (^)(NSString *))createDirectoryNamed {
    return AGX_BLOCK_AUTORELEASE(^BOOL (NSString *directoryName) {
        if (self.isExistsDirectoryNamed(directoryName)) return YES;
        if AGX_EXPECT_F(self.isExistsFileNamed(directoryName)) self.deleteFileNamed(directoryName);
        return [NSFileManager.defaultManager createDirectoryAtPath:
                self.pathWithDirectoryNamed(directoryName) withIntermediateDirectories:YES attributes:nil error:nil];
    });
}

- (BOOL)deleteFile {
    return [NSFileManager.defaultManager removeItemAtPath:self.path error:nil];
}

- (BOOL (^)(NSString *))deleteFileNamed {
    return AGX_BLOCK_AUTORELEASE(^BOOL (NSString *fileName) {
        return [NSFileManager.defaultManager removeItemAtPath:self.pathWithFileNamed(fileName) error:nil];
    });
}

- (BOOL (^)(NSString *, NSData *))writeDataWithFileNamed {
    return AGX_BLOCK_AUTORELEASE(^BOOL (NSString *fileName, NSData *data) {
        if AGX_EXPECT_F(self.isExistsDirectoryNamed(fileName)) self.deleteDirectoryNamed(fileName);
        return(self.createPathOfFileNamed(fileName) &&
               [data writeToFile:self.pathWithFileNamed(fileName) atomically:YES]);
    });
}

- (BOOL (^)(NSString *, NSString *, NSStringEncoding))writeStringWithFileNamed {
    return AGX_BLOCK_AUTORELEASE(^BOOL (NSString *fileName, NSString *string, NSStringEncoding encoding) {
        if AGX_EXPECT_F(self.isExistsDirectoryNamed(fileName)) self.deleteDirectoryNamed(fileName);
        return(self.createPathOfFileNamed(fileName) &&
               [string writeToFile:self.pathWithFileNamed(fileName) atomically:YES encoding:encoding error:nil]);
    });
}

- (BOOL (^)(NSString *, NSArray *))writeArrayWithFileNamed {
    return AGX_BLOCK_AUTORELEASE(^BOOL (NSString *fileName, NSArray *array) {
        if AGX_EXPECT_F(self.isExistsDirectoryNamed(fileName)) self.deleteDirectoryNamed(fileName);
        return(self.createPathOfFileNamed(fileName) &&
               [array writeToFile:self.pathWithFileNamed(fileName) atomically:YES]);
    });
}

- (BOOL (^)(NSString *, NSDictionary *))writeDictionaryWithFileNamed {
    return AGX_BLOCK_AUTORELEASE(^BOOL (NSString *fileName, NSDictionary *dictionary) {
        if AGX_EXPECT_F(self.isExistsDirectoryNamed(fileName)) self.deleteDirectoryNamed(fileName);
        return(self.createPathOfFileNamed(fileName) &&
               [dictionary writeToFile:self.pathWithFileNamed(fileName) atomically:YES]);
    });
}

@end
