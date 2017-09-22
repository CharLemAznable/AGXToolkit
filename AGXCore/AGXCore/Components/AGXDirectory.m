//
//  AGXDirectory.m
//  AGXCore
//
//  Created by Char Aznable on 16/2/4.
//  Copyright © 2016年 AI-CUC-EC. All rights reserved.
//

#import "AGXDirectory.h"
#import "AGXArc.h"

@interface AGXDirectory ()
@property (nonatomic, AGX_STRONG) NSString *subpath;
@end

@implementation AGXDirectory {
    NSString *_directoryRoot;
}

- (AGX_INSTANCETYPE)initWithRoot:(NSString *)directoryRoot {
    if (AGX_EXPECT_T(self = [super init])) {
        _directoryRoot = [directoryRoot copy];
    }
    return self;
}

- (void)dealloc {
    AGX_RELEASE(_directoryRoot);
    AGX_RELEASE(_subpath);
    AGX_SUPER_DEALLOC;
}

#define DirectoryInstanceDef(name, root)    \
+ (AGX_INSTANCETYPE)name {                  \
    return AGX_AUTORELEASE                  \
    ([[self alloc] initWithRoot:root]);     \
}

DirectoryInstanceDef(document, NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).firstObject)
DirectoryInstanceDef(caches, NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES).firstObject)
DirectoryInstanceDef(temporary, [NSHomeDirectory() stringByAppendingPathComponent:@"tmp"])

#undef DirectoryInstanceDef

#define DefaultDocument(type, name) \
+ (type)name { return AGXDirectory.document.name; }

DefaultDocument(AGXDirectory *(^)(NSString *), subpathAs)
DefaultDocument(NSString *(^)(NSString *), filePath)
DefaultDocument(BOOL (^)(NSString *), createPathOfFile)
DefaultDocument(BOOL (^)(NSString *), fileExists)
DefaultDocument(BOOL (^)(NSString *), plistFileExists)
DefaultDocument(BOOL (^)(NSString *), imageFileExists)
DefaultDocument(BOOL (^)(NSString *), deleteFile)
DefaultDocument(BOOL (^)(NSString *), deletePlistFile)
DefaultDocument(BOOL (^)(NSString *), deleteImageFile)
DefaultDocument(id<NSCoding> (^)(NSString *), contentWithFile)
DefaultDocument(NSData *(^)(NSString *), dataWithFile)
DefaultDocument(NSString *(^)(NSString *, NSStringEncoding), stringWithFile)
DefaultDocument(NSArray *(^)(NSString *), arrayWithFile)
DefaultDocument(NSDictionary *(^)(NSString *), dictionaryWithFile)
DefaultDocument(UIImage *(^)(NSString *), imageWithFile)
DefaultDocument(BOOL (^)(NSString *, id<NSCoding>), writeToFileWithContent)
DefaultDocument(BOOL (^)(NSString *, NSData *), writeToFileWithData)
DefaultDocument(BOOL (^)(NSString *, NSString *, NSStringEncoding), writeToFileWithString)
DefaultDocument(BOOL (^)(NSString *, NSArray *), writeToFileWithArray)
DefaultDocument(BOOL (^)(NSString *, NSDictionary *), writeToFileWithDictionary)
DefaultDocument(BOOL (^)(NSString *, UIImage *), writeToFileWithImage)
DefaultDocument(NSString *(^)(NSString *), directoryPath)
DefaultDocument(BOOL (^)(NSString *), directoryExists)
DefaultDocument(BOOL (^)(NSString *), deleteDirectory)
DefaultDocument(BOOL (^)(NSString *), createDirectory)

#undef DefaultDocument

- (AGXDirectory *(^)(NSString *))subpathAs {
    return AGX_BLOCK_AUTORELEASE(^AGXDirectory *(NSString *subpath) {
        self.subpath = subpath;
        return self;
    });
}

- (NSString *(^)(NSString *))filePath {
    return AGX_BLOCK_AUTORELEASE(^NSString *(NSString *fileName) {
        return [[_directoryRoot stringByAppendingPathComponent:_subpath]
                stringByAppendingPathComponent:fileName];
    });
}

- (BOOL (^)(NSString *))createPathOfFile {
    return AGX_BLOCK_AUTORELEASE(^BOOL (NSString *fileName) {
        return self.createDirectory(fileName.stringByDeletingLastPathComponent);
    });
}

- (BOOL (^)(NSString *))fileExists {
    return AGX_BLOCK_AUTORELEASE(^BOOL (NSString *fileName) {
        BOOL isDirectory;
        BOOL exists = [[NSFileManager defaultManager] fileExistsAtPath
                       :self.filePath(fileName) isDirectory:&isDirectory];
        return exists && !isDirectory;
    });
}

- (BOOL (^)(NSString *))plistFileExists {
    return AGX_BLOCK_AUTORELEASE(^BOOL (NSString *fileName) {
        return self.fileExists([fileName stringByAppendingPathExtension:@"plist"]);
    });
}

- (BOOL (^)(NSString *))imageFileExists {
    return AGX_BLOCK_AUTORELEASE(^BOOL (NSString *fileName) {
        return self.fileExists([fileName stringByAppendingPathExtension:@"png"]);
    });
}

- (BOOL (^)(NSString *))deleteFile {
    return AGX_BLOCK_AUTORELEASE(^BOOL (NSString *fileName) {
        return [[NSFileManager defaultManager] removeItemAtPath
                :self.filePath(fileName) error:nil];
    });
}

- (BOOL (^)(NSString *))deletePlistFile {
    return AGX_BLOCK_AUTORELEASE(^BOOL (NSString *fileName) {
        return self.deleteFile([fileName stringByAppendingPathExtension:@"plist"]);
    });
}

- (BOOL (^)(NSString *))deleteImageFile {
    return AGX_BLOCK_AUTORELEASE(^BOOL (NSString *fileName) {
        return self.deleteFile([fileName stringByAppendingPathExtension:@"png"]);
    });
}

- (id<NSCoding> (^)(NSString *))contentWithFile {
    return AGX_BLOCK_AUTORELEASE(^id<NSCoding> (NSString *fileName) {
        NSData *data = self.dataWithFile(fileName);
        return data ? [NSKeyedUnarchiver unarchiveObjectWithData:data] : nil;
    });
}

- (NSData *(^)(NSString *))dataWithFile {
    return AGX_BLOCK_AUTORELEASE(^NSData *(NSString *fileName) {
        if (AGX_EXPECT_F(!self.fileExists(fileName))) return nil;
        return [NSData dataWithContentsOfFile:self.filePath(fileName)];
    });
}

- (NSString *(^)(NSString *, NSStringEncoding))stringWithFile {
    return AGX_BLOCK_AUTORELEASE(^NSString *(NSString *fileName, NSStringEncoding encoding) {
        if (AGX_EXPECT_F(!self.fileExists(fileName))) return nil;
        return [NSString stringWithContentsOfFile:self.filePath(fileName) encoding:encoding error:nil];
    });
}

- (NSArray *(^)(NSString *))arrayWithFile {
    return AGX_BLOCK_AUTORELEASE(^NSArray *(NSString *fileName) {
        NSString *fname = [fileName stringByAppendingPathExtension:@"plist"];
        if (AGX_EXPECT_F(!self.fileExists(fname))) return nil;
        return [NSArray arrayWithContentsOfFile:self.filePath(fname)];
    });
}

- (NSDictionary *(^)(NSString *))dictionaryWithFile {
    return AGX_BLOCK_AUTORELEASE(^NSDictionary *(NSString *fileName) {
        NSString *fname = [fileName stringByAppendingPathExtension:@"plist"];
        if (AGX_EXPECT_F(!self.fileExists(fname))) return nil;
        return [NSDictionary dictionaryWithContentsOfFile:self.filePath(fname)];
    });
}

- (UIImage *(^)(NSString *))imageWithFile {
    return AGX_BLOCK_AUTORELEASE(^UIImage *(NSString *fileName) {
        NSString *fname = [fileName stringByAppendingPathExtension:@"png"];
        if (AGX_EXPECT_F(!self.fileExists(fname))) return nil;
        return [UIImage imageWithContentsOfFile:self.filePath(fname)];
    });
}

- (BOOL (^)(NSString *, id<NSCoding>))writeToFileWithContent {
    return AGX_BLOCK_AUTORELEASE(^BOOL (NSString *fileName, id<NSCoding> content) {
        return self.writeToFileWithData(fileName, [NSKeyedArchiver archivedDataWithRootObject:content]);
    });
}

- (BOOL (^)(NSString *, NSData *))writeToFileWithData {
    return AGX_BLOCK_AUTORELEASE(^BOOL (NSString *fileName, NSData *data) {
        if (AGX_EXPECT_F(self.directoryExists(fileName))) self.deleteDirectory(fileName);
        return(self.createPathOfFile(fileName) &&
               [data writeToFile:self.filePath(fileName) atomically:YES]);
    });
}

- (BOOL (^)(NSString *, NSString *, NSStringEncoding))writeToFileWithString {
    return AGX_BLOCK_AUTORELEASE(^BOOL (NSString *fileName, NSString *string, NSStringEncoding encoding) {
        if (AGX_EXPECT_F(self.directoryExists(fileName))) self.deleteDirectory(fileName);
        return(self.createPathOfFile(fileName) &&
               [string writeToFile:self.filePath(fileName) atomically:YES encoding:encoding error:nil]);
    });
}

- (BOOL (^)(NSString *, NSArray *))writeToFileWithArray {
    return AGX_BLOCK_AUTORELEASE(^BOOL (NSString *fileName, NSArray *array) {
        NSString *fname = [fileName stringByAppendingPathExtension:@"plist"];
        if (AGX_EXPECT_F(self.directoryExists(fname))) self.deleteDirectory(fname);
        return(self.createPathOfFile(fname) &&
               [array writeToFile:self.filePath(fname) atomically:YES]);
    });
}

- (BOOL (^)(NSString *, NSDictionary *))writeToFileWithDictionary {
    return AGX_BLOCK_AUTORELEASE(^BOOL (NSString *fileName, NSDictionary *dictionary) {
        NSString *fname = [fileName stringByAppendingPathExtension:@"plist"];
        if (AGX_EXPECT_F(self.directoryExists(fname))) self.deleteDirectory(fname);
        return(self.createPathOfFile(fname) &&
               [dictionary writeToFile:self.filePath(fname) atomically:YES]);
    });
}

- (BOOL (^)(NSString *, UIImage *))writeToFileWithImage {
    return AGX_BLOCK_AUTORELEASE(^BOOL (NSString *fileName, UIImage *image) {
        return self.writeToFileWithData([fileName stringByAppendingPathExtension:@"png"],
                                        UIImagePNGRepresentation(image));
    });
}

- (NSString *(^)(NSString *))directoryPath {
    return AGX_BLOCK_AUTORELEASE(^NSString *(NSString *directoryName) {
        return self.filePath(directoryName);
    });
}

- (BOOL (^)(NSString *))directoryExists {
    return AGX_BLOCK_AUTORELEASE(^BOOL (NSString *directoryName) {
        BOOL isDirectory;
        BOOL exists = [[NSFileManager defaultManager] fileExistsAtPath
                       :self.directoryPath(directoryName) isDirectory:&isDirectory];
        return exists && isDirectory;
    });
}

- (BOOL (^)(NSString *))deleteDirectory {
    return AGX_BLOCK_AUTORELEASE(^BOOL (NSString *directoryName) {
        return [[NSFileManager defaultManager] removeItemAtPath
                :self.directoryPath(directoryName) error:nil];
    });
}

- (BOOL (^)(NSString *))createDirectory {
    return AGX_BLOCK_AUTORELEASE(^BOOL (NSString *directoryName) {
        if (self.directoryExists(directoryName)) return YES;
        if (AGX_EXPECT_F(self.fileExists(directoryName))) self.deleteFile(directoryName);
        return [[NSFileManager defaultManager] createDirectoryAtPath:
                self.directoryPath(directoryName) withIntermediateDirectories:YES attributes:nil error:nil];
    });
}

@end
