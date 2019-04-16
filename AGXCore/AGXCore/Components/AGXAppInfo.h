//
//  AGXAppInfo.h
//  AGXCore
//
//  Created by Char Aznable on 2018/3/14.
//  Copyright © 2018 github.com/CharLemAznable. All rights reserved.
//

#ifndef AGXCore_AGXAppInfo_h
#define AGXCore_AGXAppInfo_h

#import <UIKit/UIKit.h>

@interface AGXAppInfo : NSObject
+ (NSDictionary *)appInfoDictionary;
+ (NSString *)appIdentifier;
+ (NSString *)appVersion;
+ (NSString *)appBuildNumber;
+ (NSString *)appBundleName;
+ (BOOL)viewControllerBasedStatusBarAppearance;
+ (UIImage *)launchImage;
+ (NSString *)launchImageName;
@end

#endif /* AGXCore_AGXAppInfo_h */
