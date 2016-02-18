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

@interface AGXBundle : NSObject
+ (NSBundle *)appBundle;
+ (NSString *)appIdentifier;
+ (NSString *)appVersion;

+ (UIImage *)imageWithName:(NSString *)imageName;
+ (NSString *)plistPathWithName:(NSString *)fileName;
+ (NSURL *)audioURLWithName:(NSString *)fileName type:(NSString *)fileType;

+ (UIImage *)imageWithName:(NSString *)imageName bundle:(NSString *)bundleName;
+ (NSString *)plistPathWithName:(NSString *)fileName bundle:(NSString *)bundleName;
+ (NSURL *)audioURLWithName:(NSString *)fileName type:(NSString *)fileType bundle:(NSString *)bundleName;

+ (UIImage *)imageWithName:(NSString *)imageName bundle:(NSString *)bundleName subpath:(NSString *)subpath;
+ (NSString *)plistPathWithName:(NSString *)fileName bundle:(NSString *)bundleName subpath:(NSString *)subpath;
+ (NSURL *)audioURLWithName:(NSString *)fileName type:(NSString *)fileType bundle:(NSString *)bundleName subpath:(NSString *)subpath;
@end

#endif /* AGXCore_AGXBundle_h */
