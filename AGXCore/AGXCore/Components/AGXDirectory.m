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

+ (BOOL)deleteAllFiles {
    return [self deleteAllFilesInDirectory:AGXDocument];
}

+ (NSString *)directoryPath:(NSString *)directoryName {
    return [self directoryPath:directoryName inDirectory:AGXDocument];
}

+ (BOOL)directoryExists:(NSString *)directoryName {
    return [self directoryExists:directoryName inDirectory:AGXDocument];
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

+ (BOOL)deleteAllFilesInDirectory:(AGXDirectoryType)directory {
    return [self deleteAllFilesInDirectory:directory subpath:nil];
}

+ (NSString *)directoryPath:(NSString *)directoryName inDirectory:(AGXDirectoryType)directory {
    return [self directoryPath:directoryName inDirectory:directory subpath:nil];
}

+ (BOOL)directoryExists:(NSString *)directoryName inDirectory:(AGXDirectoryType)directory {
    return [self directoryExists:directoryName inDirectory:directory subpath:nil];
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
    return [[NSFileManager defaultManager] fileExistsAtPath:
            [self fullFilePath:fileName inDirectory:directory subpath:subpath]];
}

+ (BOOL)deleteAllFilesInDirectory:(AGXDirectoryType)directory subpath:(NSString *)subpath {
    return [[NSFileManager defaultManager] removeItemAtPath:
            [[self directoryRoot:directory] stringByAppendingPathComponent:subpath] error:nil];
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

+ (BOOL)createDirectory:(NSString *)directoryName inDirectory:(AGXDirectoryType)directory subpath:(NSString *)subpath {
    return [self directoryExists:directoryName inDirectory:directory subpath:subpath]
    || [[NSFileManager defaultManager] createDirectoryAtPath:[self directoryPath:directoryName
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
