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
+ (AGXBundle *(^)(NSString *))bundleNamed;

- (AGXBundle *(^)(NSString *))inSubpath;

- (NSString *(^)(NSString *))filePath;
- (NSURL *(^)(NSString *))fileURL;

- (id<NSCoding> (^)(NSString *))contentWithFile;
- (NSData *(^)(NSString *))dataWithFile;
- (NSArray *(^)(NSString *))arrayWithFile;
- (NSDictionary *(^)(NSString *))dictionaryWithFile;
- (UIImage *(^)(NSString *))imageWithFile;

+ (NSString *)appIdentifier;
+ (NSString *)appVersion;
+ (BOOL)viewControllerBasedStatusBarAppearance;
@end

#endif /* AGXCore_AGXBundle_h */
