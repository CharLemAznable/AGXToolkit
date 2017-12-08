//
//  UIApplication+AGXCore.m
//  AGXCore
//
//  Created by Char Aznable on 16/2/17.
//  Copyright © 2016年 AI-CUC-EC. All rights reserved.
//

#import <UserNotifications/UserNotifications.h>
#import "UIApplication+AGXCore.h"
#import "AGXAdapt.h"
#import "NSObject+AGXCore.h"

@interface AGXApplicationDelegateAGXCoreDummy : NSObject
- (void)application:(UIApplication *)application didRegisterUserNotificationSettings:(UIUserNotificationSettings *)notificationSettings;
- (void)AGXCore_UIApplicationDelegate_application:(UIApplication *)application didRegisterUserNotificationSettings:(UIUserNotificationSettings *)notificationSettings;
@end
@implementation AGXApplicationDelegateAGXCoreDummy
- (void)application:(UIApplication *)application didRegisterUserNotificationSettings:(UIUserNotificationSettings *)notificationSettings {}
- (void)AGXCore_UIApplicationDelegate_application:(UIApplication *)application didRegisterUserNotificationSettings:(UIUserNotificationSettings *)notificationSettings {
    [self AGXCore_UIApplicationDelegate_application:application didRegisterUserNotificationSettings:notificationSettings];
    agx_async_main([application registerForRemoteNotifications];)
}
@end

@category_implementation(UIApplication, AGXCore)

+ (UIWindow *)sharedKeyWindow {
    return [self sharedApplication].delegate.window;
}

+ (UIViewController *)sharedRootViewController {
    return [self sharedKeyWindow].rootViewController;
}

+ (void)openURLString:(NSString *)URLString options:(NSDictionary<NSString *, id> *)options completionHandler:(void (^)(BOOL success))completion {
    UIApplication *sharedApplication = [self sharedApplication];
    NSURL *url = [NSURL URLWithString:URLString];
    if ([sharedApplication canOpenURL:url]) {
        if (AGX_IOS10_0_OR_LATER) {
            [sharedApplication openURL:url options:options completionHandler:completion];
        } else {
            BOOL success = [sharedApplication openURL:url];
            agx_async_main(if (completion) completion(success);)
        }
    }
}

#define ADAPT_URL_STRING(URL)   \
(AGX_IOS10_0_OR_LATER?(@"App-Prefs:" @URL):(@"prefs:" @URL))
#define CAN_OPEN_URL_STRING(URL)\
[[self sharedApplication] canOpenURL:[NSURL URLWithString:(URL)]]
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

+ (void)registerUserNotificationTypes:(AGXUserNotificationType)types {
    [[self sharedApplication] registerUserNotificationTypes:types];
}

- (void)registerUserNotificationTypes:(AGXUserNotificationType)types {
    [self registerUserNotificationTypes:types categories:nil];
}

+ (void)registerUserNotificationTypes:(AGXUserNotificationType)types categories:(NSSet *)categories {
    [[self sharedApplication] registerUserNotificationTypes:types categories:categories];
}

- (void)registerUserNotificationTypes:(AGXUserNotificationType)types categories:(NSSet *)categories {
    [self p_delegateSwizzle];

#if __IPHONE_OS_VERSION_MIN_REQUIRED < __IPHONE_10_0
    AGX_BEFORE_IOS10_0 ? [self registerUserNotificationSettings:
                          [UIUserNotificationSettings settingsForTypes:(UIUserNotificationType)types
                                                            categories:categories]] :
#endif
    [UNUserNotificationCenter.currentNotificationCenter
     requestAuthorizationWithOptions:(UNAuthorizationOptions)types
     completionHandler:^(BOOL granted, NSError *error) {
         if (!granted) return;
         agx_async_main([self.delegate application:self didRegisterUserNotificationSettings:[UIUserNotificationSettings settingsForTypes:(UIUserNotificationType)types categories:categories]];)
     }];
}

+ (void)getRegistedNotificationTypeWithCompletionHandler:(void(^)(AGXUserNotificationType types))completionHandler {
    [[self sharedApplication] getRegistedNotificationTypeWithCompletionHandler:completionHandler];
}

- (void)getRegistedNotificationTypeWithCompletionHandler:(void(^)(AGXUserNotificationType types))completionHandler {
    if (!completionHandler) return;

#if __IPHONE_OS_VERSION_MIN_REQUIRED < __IPHONE_10_0
    if (AGX_BEFORE_IOS10_0) {
        completionHandler((AGXUserNotificationType)[self currentUserNotificationSettings].types);
    } else
#endif
        [UNUserNotificationCenter.currentNotificationCenter
         getNotificationSettingsWithCompletionHandler:^(UNNotificationSettings *settings) {
             AGXUserNotificationType current = AGXUserNotificationTypeNone;
             if (settings.authorizationStatus == UNAuthorizationStatusDenied) {
                 agx_async_main(completionHandler(current);)
                 return;
             }

             if (settings.badgeSetting == UNNotificationSettingEnabled) current |= AGXUserNotificationTypeBadge;
             if (settings.soundSetting == UNNotificationSettingEnabled) current |= AGXUserNotificationTypeSound;
             if (settings.alertSetting == UNNotificationSettingEnabled) current |= AGXUserNotificationTypeAlert;
             agx_async_main(completionHandler(current);)
         }];
}

#pragma mark - private methods

- (void)p_delegateSwizzle {
    static dispatch_once_t once_t;
    dispatch_once(&once_t, ^{
        [[self.delegate class]
         swizzleInstanceOriSelector:@selector(application:didRegisterUserNotificationSettings:)
         withNewSelector:@selector(AGXCore_UIApplicationDelegate_application:didRegisterUserNotificationSettings:)
         fromClass:[AGXApplicationDelegateAGXCoreDummy class]];
    });
}

@end
