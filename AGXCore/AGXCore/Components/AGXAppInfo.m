//
//  AGXAppInfo.m
//  AGXCore
//
//  Created by Char Aznable on 2018/3/14.
//  Copyright © 2018年 AI-CUC-EC. All rights reserved.
//

#import "AGXAppInfo.h"

@implementation AGXAppInfo

+ (NSDictionary *)appInfoDictionary {
    return [NSBundle bundleForClass:AGXAppInfo.class].infoDictionary;
}

+ (NSString *)appIdentifier {
    return self.appInfoDictionary[@"CFBundleIdentifier"];
}

+ (NSString *)appVersion {
    return self.appInfoDictionary[@"CFBundleShortVersionString"];
}

+ (NSString *)appBuildNumber {
    return self.appInfoDictionary[@"CFBundleVersion"];
}

+ (NSString *)appBundleName {
    return self.appInfoDictionary[@"CFBundleName"]?:@"Unknown";
}

+ (BOOL)viewControllerBasedStatusBarAppearance {
    id setting = self.appInfoDictionary[@"UIViewControllerBasedStatusBarAppearance"];
    return setting ? [setting boolValue] : YES;
}

@end
