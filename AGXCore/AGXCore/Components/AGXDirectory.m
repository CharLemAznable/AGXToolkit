//
//  AGXDirectory.m
//  AGXCore
//
//  Created by Char Aznable on 16/2/4.
//  Copyright © 2016年 AI-CUC-EC. All rights reserved.
//

#import "AGXDirectory.h"
#import "AGXObjC.h"

@implementation AGXDirectory

#pragma mark - default use Document Directory

+ (NSString *)fullFilePath:(NSString *)fileName {
    return [self fullFilePath:fileName inDirectory:AGXDocument];
}

+ (BOOL)fileExists:(NSString *)fileName {
    return [self fileExists:fileName inDirectory:AGXDocument];
}

+ (BOOL)deleteFile:(NSString *)fileName {
    return [self deleteFile:fileName inDirectory:AGXDocument];
}

+ (BOOL)createPathOfFile:(NSString *)fileName {
    return [self createPathOfFile:fileName inDirectory:AGXDocument];
}

+ (BOOL)createFile:(NSString *)fileName content:(id<NSCoding>)content {
    return [self createFile:fileName content:content inDirectory:AGXDocument];
}

+ (BOOL)replaceFile:(NSString *)fileName content:(id<NSCoding>)content {
    return [self replaceFile:fileName content:content inDirectory:AGXDocument];
}

+ (BOOL)createFile:(NSString *)fileName data:(NSData *)data {
    return [self createFile:fileName data:data inDirectory:AGXDocument];
}

+ (BOOL)replaceFile:(NSString *)fileName data:(NSData *)data {
    return [self replaceFile:fileName data:data inDirectory:AGXDocument];
}

+ (id<NSCoding>)contentOfFile:(NSString *)fileName {
    return [self contentOfFile:fileName inDirectory:AGXDocument];
}

+ (NSData *)dataOfFile:(NSString *)fileName {
    return [self dataOfFile:fileName inDirectory:AGXDocument];
}

+ (NSString *)directoryPath:(NSString *)directoryName {
    return [self directoryPath:directoryName inDirectory:AGXDocument];
}

+ (BOOL)directoryExists:(NSString *)directoryName {
    return [self directoryExists:directoryName inDirectory:AGXDocument];
}

+ (BOOL)deleteDirectory:(NSString *)directoryName {
    return [self deleteDirectory:directoryName inDirectory:AGXDocument];
}

+ (BOOL)createDirectory:(NSString *)directoryName {
    return [self createDirectory:directoryName inDirectory:AGXDocument];
}

#pragma mark - specify Directory

+ (NSString *)fullFilePath:(NSString *)fileName inDirectory:(AGXDirectoryType)directory {
    return [self fullFilePath:fileName inDirectory:directory subpath:nil];
}

+ (BOOL)fileExists:(NSString *)fileName inDirectory:(AGXDirectoryType)directory {
    return [self fileExists:fileName inDirectory:directory subpath:nil];
}

+ (BOOL)deleteFile:(NSString *)fileName inDirectory:(AGXDirectoryType)directory {
    return [self deleteFile:fileName inDirectory:directory subpath:nil];
}

+ (BOOL)createPathOfFile:(NSString *)fileName inDirectory:(AGXDirectoryType)directory {
    return [self createPathOfFile:fileName inDirectory:directory subpath:nil];
}

+ (BOOL)createFile:(NSString *)fileName content:(id<NSCoding>)content inDirectory:(AGXDirectoryType)directory {
    return [self createFile:fileName content:content inDirectory:directory subpath:nil];
}

+ (BOOL)replaceFile:(NSString *)fileName content:(id<NSCoding>)content inDirectory:(AGXDirectoryType)directory {
    return [self replaceFile:fileName content:content inDirectory:directory subpath:nil];
}

+ (BOOL)createFile:(NSString *)fileName data:(NSData *)data inDirectory:(AGXDirectoryType)directory {
    return [self createFile:fileName data:data inDirectory:directory subpath:nil];
}

+ (BOOL)replaceFile:(NSString *)fileName data:(NSData *)data inDirectory:(AGXDirectoryType)directory {
    return [self replaceFile:fileName data:data inDirectory:directory subpath:nil];
}

+ (id<NSCoding>)contentOfFile:(NSString *)fileName inDirectory:(AGXDirectoryType)directory {
    return [self contentOfFile:fileName inDirectory:directory subpath:nil];
}

+ (NSData *)dataOfFile:(NSString *)fileName inDirectory:(AGXDirectoryType)directory {
    return [self dataOfFile:fileName inDirectory:directory subpath:nil];
}

+ (NSString *)directoryPath:(NSString *)directoryName inDirectory:(AGXDirectoryType)directory {
    return [self directoryPath:directoryName inDirectory:directory subpath:nil];
}

+ (BOOL)directoryExists:(NSString *)directoryName inDirectory:(AGXDirectoryType)directory {
    return [self directoryExists:directoryName inDirectory:directory subpath:nil];
}

+ (BOOL)deleteDirectory:(NSString *)directoryName inDirectory:(AGXDirectoryType)directory {
    return [self deleteDirectory:directoryName inDirectory:directory subpath:nil];
}

+ (BOOL)createDirectory:(NSString *)directoryName inDirectory:(AGXDirectoryType)directory {
    return [self createDirectory:directoryName inDirectory:directory subpath:nil];
}

#pragma mark - specify subpath

+ (NSString *)fullFilePath:(NSString *)fileName inDirectory:(AGXDirectoryType)directory subpath:(NSString *)subpath {
    return [[[self directoryRoot:directory] stringByAppendingPathComponent:
             subpath] stringByAppendingPathComponent:fileName];
}

+ (BOOL)fileExists:(NSString *)fileName inDirectory:(AGXDirectoryType)directory subpath:(NSString *)subpath {
    BOOL isDirectory;
    BOOL exists = [[NSFileManager defaultManager] fileExistsAtPath:
                   [self fullFilePath:fileName inDirectory:directory subpath:subpath] isDirectory:&isDirectory];
    return exists && !isDirectory;
}

+ (BOOL)deleteFile:(NSString *)fileName inDirectory:(AGXDirectoryType)directory subpath:(NSString *)subpath {
    return [[NSFileManager defaultManager] removeItemAtPath:
            [self fullFilePath:fileName inDirectory:directory subpath:subpath] error:nil];
}

+ (BOOL)createPathOfFile:(NSString *)fileName inDirectory:(AGXDirectoryType)directory subpath:(NSString *)subpath {
    return [self createDirectory:[fileName stringByDeletingLastPathComponent] inDirectory:directory subpath:subpath];
}

+ (BOOL)createFile:(NSString *)fileName content:(id<NSCoding>)content inDirectory:(AGXDirectoryType)directory subpath:(NSString *)subpath {
    return [self createFile:fileName data:[NSKeyedArchiver archivedDataWithRootObject:content]
                inDirectory:directory subpath:subpath];
}

+ (BOOL)replaceFile:(NSString *)fileName content:(id<NSCoding>)content inDirectory:(AGXDirectoryType)directory subpath:(NSString *)subpath {
    return [self replaceFile:fileName data:[NSKeyedArchiver archivedDataWithRootObject:content]
                 inDirectory:directory subpath:subpath];
}

+ (BOOL)createFile:(NSString *)fileName data:(NSData *)data inDirectory:(AGXDirectoryType)directory subpath:(NSString *)subpath {
    if ([self fileExists:fileName inDirectory:directory subpath:subpath]) return NO;
    if ([self directoryExists:fileName inDirectory:directory subpath:subpath])
        [self deleteDirectory:fileName inDirectory:directory subpath:subpath];

    return([self createPathOfFile:fileName inDirectory:directory subpath:subpath] &&
           [data writeToFile:[self fullFilePath:fileName inDirectory:directory subpath:subpath] atomically:YES]);
}

+ (BOOL)replaceFile:(NSString *)fileName data:(NSData *)data inDirectory:(AGXDirectoryType)directory subpath:(NSString *)subpath {
    if ([self fileExists:fileName inDirectory:directory subpath:subpath])
        [self deleteFile:fileName inDirectory:directory subpath:subpath];

    return [self createFile:fileName data:data inDirectory:directory subpath:subpath];
}

+ (id<NSCoding>)contentOfFile:(NSString *)fileName inDirectory:(AGXDirectoryType)directory subpath:(NSString *)subpath {
    NSData *data = [self dataOfFile:fileName inDirectory:directory subpath:subpath];
    return data ? [NSKeyedUnarchiver unarchiveObjectWithData:data] : nil;
}

+ (NSData *)dataOfFile:(NSString *)fileName inDirectory:(AGXDirectoryType)directory subpath:(NSString *)subpath {
    if (![self fileExists:fileName inDirectory:directory subpath:subpath]) return nil;
    return [NSData dataWithContentsOfFile:[self fullFilePath:fileName inDirectory:directory subpath:subpath]];
}

+ (NSString *)directoryPath:(NSString *)directoryName inDirectory:(AGXDirectoryType)directory subpath:(NSString *)subpath {
    return [self fullFilePath:directoryName inDirectory:directory subpath:subpath];
}

+ (BOOL)directoryExists:(NSString *)directoryName inDirectory:(AGXDirectoryType)directory subpath:(NSString *)subpath {
    BOOL isDirectory;
    BOOL exists = [[NSFileManager defaultManager] fileExistsAtPath:
                   [self directoryPath:directoryName inDirectory:directory subpath:subpath] isDirectory:&isDirectory];
    return exists && isDirectory;
}

+ (BOOL)deleteDirectory:(NSString *)directoryName inDirectory:(AGXDirectoryType)directory subpath:(NSString *)subpath {
    return [[NSFileManager defaultManager] removeItemAtPath:
            [self directoryPath:directoryName inDirectory:directory subpath:subpath] error:nil];
}

+ (BOOL)createDirectory:(NSString *)directoryName inDirectory:(AGXDirectoryType)directory subpath:(NSString *)subpath {
    if ([self directoryExists:directoryName inDirectory:directory subpath:subpath]) return YES;

    if ([self fileExists:directoryName inDirectory:directory subpath:subpath])
        [self deleteFile:directoryName inDirectory:directory subpath:subpath];

    return [[NSFileManager defaultManager] createDirectoryAtPath:[self directoryPath:directoryName
                                                                         inDirectory:directory subpath:subpath]
                                     withIntermediateDirectories:YES attributes:nil error:nil];
}

+ (NSString *)documentDirectoryRoot {
    return searchPath(NSDocumentDirectory);
}

+ (NSString *)cachesDirectoryRoot {
    return searchPath(NSCachesDirectory);
}

+ (NSString *)temporaryDirectoryRoot {
    return [NSHomeDirectory() stringByAppendingPathComponent:@"tmp"];
}

+ (NSString *)directoryRoot:(AGXDirectoryType)directory {
    switch (directory) {
        case AGXDocument:
            return [self documentDirectoryRoot];
        case AGXCaches:
            return [self cachesDirectoryRoot];
        case AGXTemporary:
            return [self temporaryDirectoryRoot];
        default:
            return nil;
    }
}

#pragma mark - private functions -

AGX_STATIC NSString *searchPath(NSSearchPathDirectory directory) {
    return [NSSearchPathForDirectoriesInDomains(directory, NSUserDomainMask, YES) objectAtIndex:0];
}

@end
