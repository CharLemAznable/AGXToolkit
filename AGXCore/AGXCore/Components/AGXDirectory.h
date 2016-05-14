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
#import "AGXObjC.h"

typedef NS_ENUM(NSUInteger, AGXDirectoryType) {
    AGXDocument     = 0,
    AGXCaches       = 1,
    AGXTemporary    = 2
};

@interface AGXDirectory : NSObject
+ (AGXDirectory *)document;
+ (AGXDirectory *)caches;
+ (AGXDirectory *)temporary;

- (AGXDirectory *(^)(NSString *))subpath;

- (NSString *(^)(NSString *))filePath;
- (BOOL (^)(NSString *))fileExists;
- (BOOL (^)(NSString *))deleteFile;
- (BOOL (^)(NSString *))createPathOfFile;
- (BOOL (^)(NSString *, id<NSCoding>))createFileWithContent;
- (BOOL (^)(NSString *, id<NSCoding>))replaceFileWithContent;
- (BOOL (^)(NSString *, NSData *))createFileWithData;
- (BOOL (^)(NSString *, NSData *))replaceFileWithData;
- (id<NSCoding> (^)(NSString *))contentOfFile;
- (NSData *(^)(NSString *))dataOfFile;

- (NSString *(^)(NSString *))directoryPath;
- (BOOL (^)(NSString *))directoryExists;
- (BOOL (^)(NSString *))deleteDirectory;
- (BOOL (^)(NSString *))createDirectory;
@end

#endif /* AGXCore_AGXDirectory_h */
