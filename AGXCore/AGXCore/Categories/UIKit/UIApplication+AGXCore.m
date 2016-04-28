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
@interface AGXApplicationDelegateDummy : NSObject
- (void)application:(UIApplication *)application didRegisterUserNotificationSettings:(UIUserNotificationSettings *)notificationSettings;
- (void)AGXCore_application:(UIApplication *)application didRegisterUserNotificationSettings:(UIUserNotificationSettings *)notificationSettings;
@end
#endif

@category_implementation(UIApplication, AGXCore)

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
    AGX_BEFORE_IOS8 ? [self registerForRemoteNotificationTypes:types] :
#endif
    [self registerUserNotificationSettings:
     [UIUserNotificationSettings settingsForTypes:userNotificationType(types)
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
     userNotificationType(type) == ([self currentUserNotificationSettings].types & userNotificationType(type)));
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

AGX_STATIC_INLINE UIUserNotificationType userNotificationType(AGXUserNotificationType type) {
#if __IPHONE_OS_VERSION_MIN_REQUIRED < 80000
    UIUserNotificationType result = UIUserNotificationTypeNone;
    if (type & AGXUserNotificationTypeBadge) result |= UIUserNotificationTypeBadge;
    if (type & AGXUserNotificationTypeSound) result |= UIUserNotificationTypeSound;
    if (type & AGXUserNotificationTypeAlert) result |= UIUserNotificationTypeAlert;
    return result;
#else
    return type;
#endif
}

- (void)p_delegateSwizzle {
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 80000
    // registerForRemoteNotifications in IOS8.0+
    if (AGX_BEFORE_IOS8) return;
    static dispatch_once_t once_t;
    dispatch_once(&once_t, ^{
        [[self.delegate class]
         swizzleInstanceOriSelector:@selector(application:didRegisterUserNotificationSettings:)
         withNewSelector:@selector(AGXCore_application:didRegisterUserNotificationSettings:)
         fromClass:[AGXApplicationDelegateDummy class]];
    });
#endif
}

@end

#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 80000
@implementation AGXApplicationDelegateDummy

- (void)application:(UIApplication *)application didRegisterUserNotificationSettings:(UIUserNotificationSettings *)notificationSettings {}

- (void)AGXCore_application:(UIApplication *)application didRegisterUserNotificationSettings:(UIUserNotificationSettings *)notificationSettings {
    [self AGXCore_application:application didRegisterUserNotificationSettings:notificationSettings];
    [application registerForRemoteNotifications];
}

@end
#endif
