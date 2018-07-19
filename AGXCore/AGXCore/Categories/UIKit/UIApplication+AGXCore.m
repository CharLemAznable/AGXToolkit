//
//  UIApplication+AGXCore.m
//  AGXCore
//
//  Created by Char Aznable on 2016/2/17.
//  Copyright © 2016年 AI-CUC-EC. All rights reserved.
//

#import <UserNotifications/UserNotifications.h>
#import "UIApplication+AGXCore.h"
#import "AGXAdapt.h"
#import "NSObject+AGXCore.h"
#import "NSString+AGXCore.h"

@category_implementation(UIApplication, AGXCore)

+ (UIWindow *)sharedKeyWindow {
    return self.sharedApplication.delegate.window;
}

+ (UIViewController *)sharedRootViewController {
    return self.sharedKeyWindow.rootViewController;
}

+ (void)openURLString:(NSString *)URLString options:(NSDictionary<NSString *, id> *)options completionHandler:(void (^)(BOOL success))completion {
    UIApplication *sharedApplication = self.sharedApplication;
    NSURL *url = [NSURL URLWithString:URLString.stringEncodedForURL];
    if (![sharedApplication canOpenURL:url]) return;
    [sharedApplication openURL:url options:options completionHandler:completion];
}

#define ADAPT_URL_STRING(URL)   \
(AGX_IOS10_0_OR_LATER?(@"App-Prefs:" @URL):(@"prefs:" @URL))
#define CAN_OPEN_URL_STRING(URL)\
[self.sharedApplication canOpenURL:[NSURL URLWithString:(URL).stringEncodedForURL]]
#define OPEN_URL_STRING(URL)    \
[self openURLString:(URL) options:@{} completionHandler:NULL]

+ (BOOL)canOpenSettingBluetooth     { return CAN_OPEN_URL_STRING(ADAPT_URL_STRING("root=Bluetooth")); }
+ (BOOL)canOpenSettingNotifications { return CAN_OPEN_URL_STRING(ADAPT_URL_STRING("root=NOTIFICATIONS_ID")); }
+ (BOOL)canOpenPrivacyLocation      { return CAN_OPEN_URL_STRING(ADAPT_URL_STRING("root=Privacy&path=LOCATION")); }
+ (BOOL)canOpenPrivacyPhotos        { return CAN_OPEN_URL_STRING(ADAPT_URL_STRING("root=Privacy&path=PHOTOS")); }
+ (BOOL)canOpenPrivacyCamera        { return CAN_OPEN_URL_STRING(ADAPT_URL_STRING("root=Privacy&path=CAMERA")); }
+ (BOOL)canOpenApplicationSetting   { return CAN_OPEN_URL_STRING(UIApplicationOpenSettingsURLString); }

+ (void)openSettingBluetooth        { OPEN_URL_STRING(ADAPT_URL_STRING("root=Bluetooth")); }
+ (void)openSettingNotifications    { OPEN_URL_STRING(ADAPT_URL_STRING("root=NOTIFICATIONS_ID")); }
+ (void)openPrivacyLocation         { OPEN_URL_STRING(ADAPT_URL_STRING("root=Privacy&path=LOCATION")); }
+ (void)openPrivacyPhotos           { OPEN_URL_STRING(ADAPT_URL_STRING("root=Privacy&path=PHOTOS")); }
+ (void)openPrivacyCamera           { OPEN_URL_STRING(ADAPT_URL_STRING("root=Privacy&path=CAMERA")); }
+ (void)openApplicationSetting      { OPEN_URL_STRING(UIApplicationOpenSettingsURLString); }

#undef OPEN_URL_STRING
#undef CAN_OPEN_URL_STRING
#undef ADAPT_URL_STRING

+ (void)registerUserNotificationTypes:(UNAuthorizationOptions)options {
    [self.sharedApplication registerUserNotificationTypes:options];
}

- (void)registerUserNotificationTypes:(UNAuthorizationOptions)options {
    [self registerUserNotificationTypes:options completionHandler:NULL];
}

+ (void)registerUserNotificationTypes:(UNAuthorizationOptions)options completionHandler:(void (^)(BOOL granted, NSError *error))completionHandler {
    [self.sharedApplication registerUserNotificationTypes:options completionHandler:completionHandler];
}

- (void)registerUserNotificationTypes:(UNAuthorizationOptions)options completionHandler:(void (^)(BOOL granted, NSError *error))completionHandler {
    [UNUserNotificationCenter.currentNotificationCenter requestAuthorizationWithOptions:options
     completionHandler:^(BOOL granted, NSError *error) { completionHandler(granted, error); }];
}

+ (void)getRegistedNotificationTypeWithCompletionHandler:(void(^)(UNAuthorizationOptions options))completionHandler {
    [self.sharedApplication getRegistedNotificationTypeWithCompletionHandler:completionHandler];
}

- (void)getRegistedNotificationTypeWithCompletionHandler:(void(^)(UNAuthorizationOptions options))completionHandler {
    if (!completionHandler) return;

    [UNUserNotificationCenter.currentNotificationCenter
     getNotificationSettingsWithCompletionHandler:^(UNNotificationSettings *settings) {
         UNAuthorizationOptions current = 0;
         if (UNAuthorizationStatusDenied == settings.authorizationStatus) {
             agx_async_main(completionHandler(current););
             return;
         }

         if (UNNotificationSettingEnabled == settings.badgeSetting) current |= UNAuthorizationOptionBadge;
         if (UNNotificationSettingEnabled == settings.soundSetting) current |= UNAuthorizationOptionSound;
         if (UNNotificationSettingEnabled == settings.alertSetting) current |= UNAuthorizationOptionAlert;
         agx_async_main(completionHandler(current););
     }];
}

@end
