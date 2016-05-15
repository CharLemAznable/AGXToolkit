//
//  AGXDirectory.h
//  AGXCore
//
//  Created by Char Aznable on 16/2/4.
//  Copyright © 2016年 AI-CUC-EC. All rights reserved.
//

#ifndef AGXCore_AGXDirectory_h
#define AGXCore_AGXDirectory_h

#import <UIKit/UIKit.h>
#import "AGXObjC.h"

@interface AGXDirectory : NSObject
+ (AGX_INSTANCETYPE)document;
+ (AGX_INSTANCETYPE)caches;
+ (AGX_INSTANCETYPE)temporary;

- (AGXDirectory *(^)(NSString *))inSubpath;

- (NSString *(^)(NSString *))filePath;
- (BOOL (^)(NSString *))createPathOfFile;

- (BOOL (^)(NSString *))fileExists;
- (BOOL (^)(NSString *))plistFileExists;
- (BOOL (^)(NSString *))imageFileExists; // png

- (BOOL (^)(NSString *))deleteFile;
- (BOOL (^)(NSString *))deletePlistFile;
- (BOOL (^)(NSString *))deleteImageFile; // png

- (id<NSCoding> (^)(NSString *))contentWithFile;
- (NSData *(^)(NSString *))dataWithFile;
- (NSArray *(^)(NSString *))arrayWithFile; // plist
- (NSDictionary *(^)(NSString *))dictionaryWithFile; // plist
- (UIImage *(^)(NSString *))imageWithFile; // png

- (BOOL (^)(NSString *, id<NSCoding>))writeToFileWithContent;
- (BOOL (^)(NSString *, NSData *))writeToFileWithData;
- (BOOL (^)(NSString *, NSArray *))writeToFileWithArray; // plist
- (BOOL (^)(NSString *, NSDictionary *))writeToFileWithDictionary; // plist
- (BOOL (^)(NSString *, UIImage *))writeToFileWithImage; // png

- (NSString *(^)(NSString *))directoryPath;
- (BOOL (^)(NSString *))directoryExists;
- (BOOL (^)(NSString *))deleteDirectory;
- (BOOL (^)(NSString *))createDirectory;
@end

#endif /* AGXCore_AGXDirectory_h */
