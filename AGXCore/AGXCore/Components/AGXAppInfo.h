//
//  AGXAppInfo.h
//  AGXCore
//
//  Created by Char Aznable on 2018/3/14.
//  Copyright © 2018年 AI-CUC-EC. All rights reserved.
//

#ifndef AGXCore_AGXAppInfo_h
#define AGXCore_AGXAppInfo_h

#import <Foundation/Foundation.h>

@interface AGXAppInfo : NSObject
+ (NSDictionary *)appInfoDictionary;
+ (NSString *)appIdentifier;
+ (NSString *)appVersion;
+ (NSString *)appBuildNumber;
+ (NSString *)appBundleName;
+ (BOOL)viewControllerBasedStatusBarAppearance;
@end

#endif /* AGXCore_AGXAppInfo_h */
