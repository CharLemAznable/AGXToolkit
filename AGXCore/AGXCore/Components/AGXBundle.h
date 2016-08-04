//
//  AGXBundle.h
//  AGXCore
//
//  Created by Char Aznable on 16/2/4.
//  Copyright © 2016年 AI-CUC-EC. All rights reserved.
//

#ifndef AGXCore_AGXBundle_h
#define AGXCore_AGXBundle_h

#import <UIKit/UIKit.h>
#import "AGXObjC.h"

@interface AGXBundle : NSObject
+ (AGX_INSTANCETYPE)appBundle;

+ (AGXBundle *(^)(NSString *))bundleNameAs;
+ (AGXBundle *(^)(NSString *))subpathAs;

+ (NSString *(^)(NSString *))filePath;
+ (NSURL *(^)(NSString *))fileURL;

+ (id<NSCoding> (^)(NSString *))contentWithFile;
+ (NSData *(^)(NSString *))dataWithFile;
+ (NSString *(^)(NSString *, NSStringEncoding))stringWithFile;
+ (NSArray *(^)(NSString *))arrayWithFile;
+ (NSDictionary *(^)(NSString *))dictionaryWithFile;
+ (UIImage *(^)(NSString *))imageWithFile;

//////////////////////////////////////////////////

- (AGXBundle *(^)(NSString *))bundleNameAs;
- (AGXBundle *(^)(NSString *))subpathAs;

- (NSString *(^)(NSString *))filePath;
- (NSURL *(^)(NSString *))fileURL;

- (id<NSCoding> (^)(NSString *))contentWithFile;
- (NSData *(^)(NSString *))dataWithFile;
- (NSString *(^)(NSString *, NSStringEncoding))stringWithFile;
- (NSArray *(^)(NSString *))arrayWithFile;
- (NSDictionary *(^)(NSString *))dictionaryWithFile;
- (UIImage *(^)(NSString *))imageWithFile;

+ (NSDictionary *)appInfoDictionary;
+ (NSString *)appIdentifier;
+ (NSString *)appVersion;
+ (NSString *)appBuildNumber;
+ (BOOL)viewControllerBasedStatusBarAppearance;
@end

#endif /* AGXCore_AGXBundle_h */
