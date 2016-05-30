//
//  UIApplication+AGXCore.m
//  AGXCore
//
//  Created by Char Aznable on 16/2/17.
//  Copyright © 2016年 AI-CUC-EC. All rights reserved.
//

#import "UIApplication+AGXCore.h"
#import "NSObject+AGXCore.h"

#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 80000
@interface AGXApplicationDelegateAGXCoreDummy : NSObject
- (void)application:(UIApplication *)application didRegisterUserNotificationSettings:(UIUserNotificationSettings *)notificationSettings;
- (void)AGXCore_UIApplicationDelegate_application:(UIApplication *)application didRegisterUserNotificationSettings:(UIUserNotificationSettings *)notificationSettings;
@end
@implementation AGXApplicationDelegateAGXCoreDummy
- (void)application:(UIApplication *)application didRegisterUserNotificationSettings:(UIUserNotificationSettings *)notificationSettings {}
- (void)AGXCore_UIApplicationDelegate_application:(UIApplication *)application didRegisterUserNotificationSettings:(UIUserNotificationSettings *)notificationSettings {
    [self AGXCore_UIApplicationDelegate_application:application didRegisterUserNotificationSettings:notificationSettings];
    [application registerForRemoteNotifications];
}
@end
#endif

@category_implementation(UIApplication, AGXCore)

+ (UIWindow *)sharedKeyWindow {
    return [self sharedApplication].delegate.window;
}

+ (UIViewController *)sharedRootViewController {
    return [self sharedKeyWindow].rootViewController;
}

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

#if __IPHONE_OS_VERSION_MIN_REQUIRED < 80000
    AGX_BEFORE_IOS8 ? [self registerForRemoteNotificationTypes:(UIRemoteNotificationType)types] :
#endif
    [self registerUserNotificationSettings:
     [UIUserNotificationSettings settingsForTypes:(UIUserNotificationType)types
                                       categories:categories]];

}

+ (BOOL)notificationTypeRegisted:(AGXUserNotificationType)type {
    return [[self sharedApplication] notificationTypeRegisted:type];
}

- (BOOL)notificationTypeRegisted:(AGXUserNotificationType)type {
    return type != AGXUserNotificationTypeNone &&
    (
#if __IPHONE_OS_VERSION_MIN_REQUIRED < 80000
     AGX_BEFORE_IOS8 ? type == ([self enabledRemoteNotificationTypes] & type) :
#endif
     type == ([self currentUserNotificationSettings].types & type));
}

+ (BOOL)noneNotificationTypeRegisted {
    return [[self sharedApplication] noneNotificationTypeRegisted];
}

- (BOOL)noneNotificationTypeRegisted {
    return
#if __IPHONE_OS_VERSION_MIN_REQUIRED < 80000
    AGX_BEFORE_IOS8 ? UIRemoteNotificationTypeNone == [self enabledRemoteNotificationTypes] :
#endif
    UIUserNotificationTypeNone == [self currentUserNotificationSettings].types;
}

#pragma mark - private methods

- (void)p_delegateSwizzle {
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 80000
    // registerForRemoteNotifications in IOS8.0+
    if (AGX_BEFORE_IOS8) return;
    static dispatch_once_t once_t;
    dispatch_once(&once_t, ^{
        [[self.delegate class]
         swizzleInstanceOriSelector:@selector(application:didRegisterUserNotificationSettings:)
         withNewSelector:@selector(AGXCore_UIApplicationDelegate_application:didRegisterUserNotificationSettings:)
         fromClass:[AGXApplicationDelegateAGXCoreDummy class]];
    });
#endif
}

@end
