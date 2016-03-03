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
+ (BOOL)deleteAllFiles;

+ (NSString *)directoryPath:(NSString *)directoryName;
+ (BOOL)directoryExists:(NSString *)directoryName;
+ (BOOL)createDirectory:(NSString *)directoryName;

+ (NSString *)fullFilePath:(NSString *)fileName inDirectory:(AGXDirectoryType)directory;
+ (BOOL)fileExists:(NSString *)fileName inDirectory:(AGXDirectoryType)directory;
+ (BOOL)deleteAllFilesInDirectory:(AGXDirectoryType)directory;

+ (NSString *)directoryPath:(NSString *)directoryName inDirectory:(AGXDirectoryType)directory;
+ (BOOL)directoryExists:(NSString *)directoryName inDirectory:(AGXDirectoryType)directory;
+ (BOOL)createDirectory:(NSString *)directoryName inDirectory:(AGXDirectoryType)directory;

+ (NSString *)fullFilePath:(NSString *)fileName inDirectory:(AGXDirectoryType)directory subpath:(NSString *)subpath;
+ (BOOL)fileExists:(NSString *)fileName inDirectory:(AGXDirectoryType)directory subpath:(NSString *)subpath;
+ (BOOL)deleteAllFilesInDirectory:(AGXDirectoryType)directory subpath:(NSString *)subpath;

+ (NSString *)directoryPath:(NSString *)directoryName inDirectory:(AGXDirectoryType)directory subpath:(NSString *)subpath;
+ (BOOL)directoryExists:(NSString *)directoryName inDirectory:(AGXDirectoryType)directory subpath:(NSString *)subpath;
+ (BOOL)createDirectory:(NSString *)directoryName inDirectory:(AGXDirectoryType)directory subpath:(NSString *)subpath;

+ (NSString *)documentDirectoryRoot;
+ (NSString *)cachesDirectoryRoot;
+ (NSString *)temporaryDirectoryRoot;
+ (NSString *)directoryRoot:(AGXDirectoryType)directory;
@end

#endif /* AGXCore_AGXDirectory_h */
