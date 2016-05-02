//
//  AGXDirectory.h
//  AGXCore
//
//  Created by Char Aznable on 16/2/4.
//  Copyright © 2016年 AI-CUC-EC. All rights reserved.
//

#ifndef AGXCore_AGXDirectory_h
#define AGXCore_AGXDirectory_h

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, AGXDirectoryType) {
    AGXDocument     = 0,
    AGXCaches       = 1,
    AGXTemporary    = 2
};

@interface AGXDirectory : NSObject
+ (NSString *)fullFilePath:(NSString *)fileName;
+ (BOOL)fileExists:(NSString *)fileName;
+ (BOOL)deleteFile:(NSString *)fileName;
+ (BOOL)createPathOfFile:(NSString *)fileName;
+ (BOOL)createFile:(NSString *)fileName content:(id<NSCoding>)content;
+ (BOOL)replaceFile:(NSString *)fileName content:(id<NSCoding>)content;
+ (BOOL)createFile:(NSString *)fileName data:(NSData *)data;
+ (BOOL)replaceFile:(NSString *)fileName data:(NSData *)data;
+ (id<NSCoding>)contentOfFile:(NSString *)fileName;
+ (NSData *)dataOfFile:(NSString *)fileName;

+ (NSString *)directoryPath:(NSString *)directoryName;
+ (BOOL)directoryExists:(NSString *)directoryName;
+ (BOOL)deleteDirectory:(NSString *)directoryName;
+ (BOOL)createDirectory:(NSString *)directoryName;

+ (NSString *)fullFilePath:(NSString *)fileName inDirectory:(AGXDirectoryType)directory;
+ (BOOL)fileExists:(NSString *)fileName inDirectory:(AGXDirectoryType)directory;
+ (BOOL)deleteFile:(NSString *)fileName inDirectory:(AGXDirectoryType)directory;
+ (BOOL)createPathOfFile:(NSString *)fileName inDirectory:(AGXDirectoryType)directory;
+ (BOOL)createFile:(NSString *)fileName content:(id<NSCoding>)content inDirectory:(AGXDirectoryType)directory;
+ (BOOL)replaceFile:(NSString *)fileName content:(id<NSCoding>)content inDirectory:(AGXDirectoryType)directory;
+ (BOOL)createFile:(NSString *)fileName data:(NSData *)data inDirectory:(AGXDirectoryType)directory;
+ (BOOL)replaceFile:(NSString *)fileName data:(NSData *)data inDirectory:(AGXDirectoryType)directory;
+ (id<NSCoding>)contentOfFile:(NSString *)fileName inDirectory:(AGXDirectoryType)directory;
+ (NSData *)dataOfFile:(NSString *)fileName inDirectory:(AGXDirectoryType)directory;

+ (NSString *)directoryPath:(NSString *)directoryName inDirectory:(AGXDirectoryType)directory;
+ (BOOL)directoryExists:(NSString *)directoryName inDirectory:(AGXDirectoryType)directory;
+ (BOOL)deleteDirectory:(NSString *)directoryName inDirectory:(AGXDirectoryType)directory;
+ (BOOL)createDirectory:(NSString *)directoryName inDirectory:(AGXDirectoryType)directory;

+ (NSString *)fullFilePath:(NSString *)fileName inDirectory:(AGXDirectoryType)directory subpath:(NSString *)subpath;
+ (BOOL)fileExists:(NSString *)fileName inDirectory:(AGXDirectoryType)directory subpath:(NSString *)subpath;
+ (BOOL)deleteFile:(NSString *)fileName inDirectory:(AGXDirectoryType)directory subpath:(NSString *)subpath;
+ (BOOL)createPathOfFile:(NSString *)fileName inDirectory:(AGXDirectoryType)directory subpath:(NSString *)subpath;
+ (BOOL)createFile:(NSString *)fileName content:(id<NSCoding>)content inDirectory:(AGXDirectoryType)directory subpath:(NSString *)subpath;
+ (BOOL)replaceFile:(NSString *)fileName content:(id<NSCoding>)content inDirectory:(AGXDirectoryType)directory subpath:(NSString *)subpath;
+ (BOOL)createFile:(NSString *)fileName data:(NSData *)data inDirectory:(AGXDirectoryType)directory subpath:(NSString *)subpath;
+ (BOOL)replaceFile:(NSString *)fileName data:(NSData *)data inDirectory:(AGXDirectoryType)directory subpath:(NSString *)subpath;
+ (id<NSCoding>)contentOfFile:(NSString *)fileName inDirectory:(AGXDirectoryType)directory subpath:(NSString *)subpath;
+ (NSData *)dataOfFile:(NSString *)fileName inDirectory:(AGXDirectoryType)directory subpath:(NSString *)subpath;

+ (NSString *)directoryPath:(NSString *)directoryName inDirectory:(AGXDirectoryType)directory subpath:(NSString *)subpath;
+ (BOOL)directoryExists:(NSString *)directoryName inDirectory:(AGXDirectoryType)directory subpath:(NSString *)subpath;
+ (BOOL)deleteDirectory:(NSString *)directoryName inDirectory:(AGXDirectoryType)directory subpath:(NSString *)subpath;
+ (BOOL)createDirectory:(NSString *)directoryName inDirectory:(AGXDirectoryType)directory subpath:(NSString *)subpath;

+ (NSString *)documentDirectoryRoot;
+ (NSString *)cachesDirectoryRoot;
+ (NSString *)temporaryDirectoryRoot;
+ (NSString *)directoryRoot:(AGXDirectoryType)directory;
@end

#endif /* AGXCore_AGXDirectory_h */
