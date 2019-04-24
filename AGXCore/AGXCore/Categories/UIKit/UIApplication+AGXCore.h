//
//  UIApplication+AGXCore.h
//  AGXCore
//
//  Created by Char Aznable on 2016/2/17.
//  Copyright © 2016 github.com/CharLemAznable. All rights reserved.
//

#ifndef AGXCore_UIApplication_AGXCore_h
#define AGXCore_UIApplication_AGXCore_h

#import <UIKit/UIKit.h>
#import <UserNotifications/UserNotifications.h>
#import "AGXCategory.h"

@category_interface(UIApplication, AGXCore)
+ (UIWindow *)sharedKeyWindow;
+ (UIViewController *)sharedRootViewController;

+ (void)openURLString:(NSString *)URLString options:(NSDictionary<NSString *, id> *)options completionHandler:(void (^)(BOOL success))completion;

+ (BOOL)canOpenSettingBluetooth;
+ (BOOL)canOpenSettingNotifications;
+ (BOOL)canOpenPrivacyLocation;
+ (BOOL)canOpenPrivacyPhotos;
+ (BOOL)canOpenPrivacyCamera;
+ (BOOL)canOpenApplicationSetting;

+ (void)openSettingBluetooth;
+ (void)openSettingNotifications;
+ (void)openPrivacyLocation;
+ (void)openPrivacyPhotos;
+ (void)openPrivacyCamera;
+ (void)openApplicationSetting;

+ (void)registerUserNotificationTypes:(UNAuthorizationOptions)options;
- (void)registerUserNotificationTypes:(UNAuthorizationOptions)options;
+ (void)registerUserNotificationTypes:(UNAuthorizationOptions)options completionHandler:(void (^)(BOOL granted, NSError *error))completionHandler;
- (void)registerUserNotificationTypes:(UNAuthorizationOptions)options completionHandler:(void (^)(BOOL granted, NSError *error))completionHandler;

+ (void)getRegistedNotificationTypeWithCompletionHandler:(void(^)(UNAuthorizationOptions options))completionHandler;
- (void)getRegistedNotificationTypeWithCompletionHandler:(void(^)(UNAuthorizationOptions options))completionHandler;
@end

#endif /* AGXCore_UIApplication_AGXCore_h */
