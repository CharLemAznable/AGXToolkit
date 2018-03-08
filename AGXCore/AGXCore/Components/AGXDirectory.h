//
//  AGXDirectory.h
//  AGXCore
//
//  Created by Char Aznable on 2016/2/4.
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

+ (AGXDirectory *(^)(NSString *))subpathAs; // default in user's NSDocumentDirectory

+ (NSString *(^)(NSString *))filePath;
+ (NSURL *(^)(NSString *))fileURL;
+ (BOOL (^)(NSString *))createPathOfFile;
+ (BOOL (^)(NSString *))fileExists;
+ (BOOL (^)(NSString *))plistFileExists;
+ (BOOL (^)(NSString *))imageFileExists; // png
+ (BOOL (^)(NSString *))deleteFile;
+ (BOOL (^)(NSString *))deletePlistFile;
+ (BOOL (^)(NSString *))deleteImageFile; // png

+ (id<NSCoding> (^)(NSString *))contentWithFile;
+ (NSData *(^)(NSString *))dataWithFile;
+ (NSString *(^)(NSString *, NSStringEncoding))stringWithFile;
+ (NSArray *(^)(NSString *))arrayWithFile; // plist
+ (NSDictionary *(^)(NSString *))dictionaryWithFile; // plist
+ (NSSet *(^)(NSString *))setWithFile; // plist
+ (UIImage *(^)(NSString *))imageWithFile; // png

+ (BOOL (^)(NSString *, id<NSCoding>))writeToFileWithContent;
+ (BOOL (^)(NSString *, NSData *))writeToFileWithData;
+ (BOOL (^)(NSString *, NSString *, NSStringEncoding))writeToFileWithString;
+ (BOOL (^)(NSString *, NSArray *))writeToFileWithArray; // plist
+ (BOOL (^)(NSString *, NSDictionary *))writeToFileWithDictionary; // plist
+ (BOOL (^)(NSString *, NSSet *))writeToFileWithSet; // plist
+ (BOOL (^)(NSString *, UIImage *))writeToFileWithImage; // png

+ (NSString *(^)(NSString *))directoryPath;
+ (BOOL (^)(NSString *))directoryExists;
+ (BOOL (^)(NSString *))deleteDirectory;
+ (BOOL (^)(NSString *))createDirectory;

//////////////////////////////////////////////////

- (AGXDirectory *(^)(NSString *))subpathAs;

- (NSString *(^)(NSString *))filePath;
- (NSURL *(^)(NSString *))fileURL;
- (BOOL (^)(NSString *))createPathOfFile;
- (BOOL (^)(NSString *))fileExists;
- (BOOL (^)(NSString *))plistFileExists;
- (BOOL (^)(NSString *))imageFileExists; // png
- (BOOL (^)(NSString *))deleteFile;
- (BOOL (^)(NSString *))deletePlistFile;
- (BOOL (^)(NSString *))deleteImageFile; // png

- (id<NSCoding> (^)(NSString *))contentWithFile;
- (NSData *(^)(NSString *))dataWithFile;
- (NSString *(^)(NSString *, NSStringEncoding))stringWithFile;
- (NSArray *(^)(NSString *))arrayWithFile; // plist
- (NSDictionary *(^)(NSString *))dictionaryWithFile; // plist
- (NSSet *(^)(NSString *))setWithFile; // plist
- (UIImage *(^)(NSString *))imageWithFile; // png

- (BOOL (^)(NSString *, id<NSCoding>))writeToFileWithContent;
- (BOOL (^)(NSString *, NSData *))writeToFileWithData;
- (BOOL (^)(NSString *, NSString *, NSStringEncoding))writeToFileWithString;
- (BOOL (^)(NSString *, NSArray *))writeToFileWithArray; // plist
- (BOOL (^)(NSString *, NSDictionary *))writeToFileWithDictionary; // plist
- (BOOL (^)(NSString *, NSSet *))writeToFileWithSet; // plist
- (BOOL (^)(NSString *, UIImage *))writeToFileWithImage; // png

- (NSString *(^)(NSString *))directoryPath;
- (BOOL (^)(NSString *))directoryExists;
- (BOOL (^)(NSString *))deleteDirectory;
- (BOOL (^)(NSString *))createDirectory;
@end

#endif /* AGXCore_AGXDirectory_h */
