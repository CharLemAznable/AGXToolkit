//
//  UIApplication+AGXCore.h
//  AGXCore
//
//  Created by Char Aznable on 2016/2/17.
//  Copyright © 2016年 AI-CUC-EC. All rights reserved.
//

#ifndef AGXCore_UIApplication_AGXCore_h
#define AGXCore_UIApplication_AGXCore_h

#import <UIKit/UIKit.h>
#import "AGXCategory.h"

typedef NS_OPTIONS(NSUInteger, AGXUserNotificationType) {
    AGXUserNotificationTypeNone     = 0,
    AGXUserNotificationTypeBadge    = 1 << 0,
    AGXUserNotificationTypeSound    = 1 << 1,
    AGXUserNotificationTypeAlert    = 1 << 2,
};

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

+ (void)registerUserNotificationTypes:(AGXUserNotificationType)types;
- (void)registerUserNotificationTypes:(AGXUserNotificationType)types;
+ (void)registerUserNotificationTypes:(AGXUserNotificationType)types categories:(NSSet *)categories;
- (void)registerUserNotificationTypes:(AGXUserNotificationType)types categories:(NSSet *)categories;

+ (void)getRegistedNotificationTypeWithCompletionHandler:(void(^)(AGXUserNotificationType types))completionHandler;
- (void)getRegistedNotificationTypeWithCompletionHandler:(void(^)(AGXUserNotificationType types))completionHandler;
@end

#endif /* AGXCore_UIApplication_AGXCore_h */
