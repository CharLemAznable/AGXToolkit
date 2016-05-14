//
//  AGXDirectory.m
//  AGXCore
//
//  Created by Char Aznable on 16/2/4.
//  Copyright © 2016年 AI-CUC-EC. All rights reserved.
//

#import "AGXDirectory.h"
#import "AGXArc.h"

@implementation AGXDirectory {
    AGXDirectoryType _directory;
    NSString *_subpath;
}

- (AGX_INSTANCETYPE)init {
    @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                   reason:@"Please use initializer: +document/+caches/+temporary"
                                 userInfo:nil];
    return nil;
}

- (AGX_INSTANCETYPE)initWithType:(AGXDirectoryType)directory {
    if (AGX_EXPECT_T(self = [super init])) _directory = directory;
    return self;
}

- (void)dealloc {
    AGX_RELEASE(_subpath);
    AGX_SUPER_DEALLOC;
}

+ (AGXDirectory *)document {
    return AGX_AUTORELEASE([[AGXDirectory alloc] initWithType:AGXDocument]);
}

+ (AGXDirectory *)caches {
    return AGX_AUTORELEASE([[AGXDirectory alloc] initWithType:AGXCaches]);
}

+ (AGXDirectory *)temporary {
    return AGX_AUTORELEASE([[AGXDirectory alloc] initWithType:AGXTemporary]);
}

- (AGXDirectory *(^)(NSString *))subpath {
    return AGX_BLOCK_AUTORELEASE(^AGXDirectory *(NSString *subpath) {
        NSString *temp = [subpath copy];
        AGX_RELEASE(_subpath);
        _subpath = temp;
        return self;
    });
}

- (NSString *(^)(NSString *))filePath {
    return AGX_BLOCK_AUTORELEASE(^NSString *(NSString *fileName) {
        return [[directoryRoot(_directory) stringByAppendingPathComponent:_subpath]
                stringByAppendingPathComponent:fileName];
    });
}

- (BOOL (^)(NSString *))fileExists {
    return AGX_BLOCK_AUTORELEASE(^BOOL (NSString *fileName) {
        BOOL isDirectory;
        BOOL exists = [[NSFileManager defaultManager] fileExistsAtPath:self.filePath(fileName) isDirectory:&isDirectory];
        return exists && !isDirectory;
    });
}

- (BOOL (^)(NSString *))deleteFile {
    return AGX_BLOCK_AUTORELEASE(^BOOL (NSString *fileName) {
        return [[NSFileManager defaultManager] removeItemAtPath:self.filePath(fileName) error:nil];
    });
}

- (BOOL (^)(NSString *))createPathOfFile {
    return AGX_BLOCK_AUTORELEASE(^BOOL (NSString *fileName) {
        return self.createDirectory(fileName.stringByDeletingLastPathComponent);
    });
}

- (BOOL (^)(NSString *, id<NSCoding>))createFileWithContent {
    return AGX_BLOCK_AUTORELEASE(^BOOL (NSString *fileName, id<NSCoding> content) {
        return self.createFileWithData(fileName, [NSKeyedArchiver archivedDataWithRootObject:content]);
    });
}

- (BOOL (^)(NSString *, id<NSCoding>))replaceFileWithContent {
    return AGX_BLOCK_AUTORELEASE(^BOOL (NSString *fileName, id<NSCoding> content) {
        return self.replaceFileWithContent(fileName, [NSKeyedArchiver archivedDataWithRootObject:content]);
    });
}

- (BOOL (^)(NSString *, NSData *))createFileWithData {
    return AGX_BLOCK_AUTORELEASE(^BOOL (NSString *fileName, NSData *data) {
        if (self.fileExists(fileName)) return NO;
        if (self.directoryExists(fileName)) self.deleteDirectory(fileName);
        return(self.createPathOfFile(fileName) && [data writeToFile:self.filePath(fileName) atomically:YES]);
    });
}

- (BOOL (^)(NSString *, NSData *))replaceFileWithData {
    return AGX_BLOCK_AUTORELEASE(^BOOL (NSString *fileName, NSData *data) {
        if (self.fileExists(fileName)) self.deleteFile(fileName);
        return self.createFileWithData(fileName, data);
    });
}

- (id<NSCoding> (^)(NSString *))contentOfFile {
    return AGX_BLOCK_AUTORELEASE(^id<NSCoding> (NSString *fileName) {
        NSData *data = self.dataOfFile(fileName);
        return data ? [NSKeyedUnarchiver unarchiveObjectWithData:data] : nil;
    });
}

- (NSData *(^)(NSString *))dataOfFile {
    return AGX_BLOCK_AUTORELEASE(^NSData *(NSString *fileName) {
        if (!self.fileExists(fileName)) return nil;
        return [NSData dataWithContentsOfFile:self.filePath(fileName)];
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
        BOOL exists = [[NSFileManager defaultManager] fileExistsAtPath:self.directoryPath(directoryName)
                                                           isDirectory:&isDirectory];
        return exists && isDirectory;
    });
}

- (BOOL (^)(NSString *))deleteDirectory {
    return AGX_BLOCK_AUTORELEASE(^BOOL (NSString *directoryName) {
        return [[NSFileManager defaultManager] removeItemAtPath:self.directoryPath(directoryName) error:nil];
    });
}

- (BOOL (^)(NSString *))createDirectory {
    return AGX_BLOCK_AUTORELEASE(^BOOL (NSString *directoryName) {
        if (self.directoryExists(directoryName)) return YES;
        if (self.fileExists(directoryName)) self.deleteFile(directoryName);
        return [[NSFileManager defaultManager] createDirectoryAtPath:self.directoryPath(directoryName)
                                         withIntermediateDirectories:YES attributes:nil error:nil];
    });
}

#pragma mark - private functions -

AGX_STATIC NSString *directoryRoot(AGXDirectoryType directory) {
    switch (directory) {
        case AGXDocument:   return searchPath(NSDocumentDirectory);
        case AGXCaches:     return searchPath(NSCachesDirectory);
        case AGXTemporary:  return [NSHomeDirectory() stringByAppendingPathComponent:@"tmp"];
        default:            return nil;
    }
}

AGX_STATIC NSString *searchPath(NSSearchPathDirectory directory) {
    return [NSSearchPathForDirectoriesInDomains(directory, NSUserDomainMask, YES) objectAtIndex:0];
}

@end
