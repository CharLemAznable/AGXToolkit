//
//  UIApplication+AGXCore.h
//  AGXCore
//
//  Created by Char Aznable on 16/2/17.
//  Copyright © 2016年 AI-CUC-EC. All rights reserved.
//

#ifndef AGXCore_UIApplication_AGXCore_h
#define AGXCore_UIApplication_AGXCore_h

#import <UIKit/UIKit.h>
#import "AGXCategory.h"
#import "AGXAdapt.h"

typedef NS_OPTIONS(NSUInteger, AGXUserNotificationType) {
    AGXUserNotificationTypeNone     = 0,
    AGXUserNotificationTypeBadge    = 1 << 0,
    AGXUserNotificationTypeSound    = 1 << 1,
    AGXUserNotificationTypeAlert    = 1 << 2,
};

@category_interface(UIApplication, AGXCore)
+ (void)registerUserNotificationTypes:(AGXUserNotificationType)types;
- (void)registerUserNotificationTypes:(AGXUserNotificationType)types;
+ (void)registerUserNotificationTypes:(AGXUserNotificationType)types categories:(NSSet AGX_GENERIC(UIUserNotificationCategory *) *)categories;
- (void)registerUserNotificationTypes:(AGXUserNotificationType)types categories:(NSSet AGX_GENERIC(UIUserNotificationCategory *) *)categories;

+ (BOOL)notificationTypeRegisted:(AGXUserNotificationType)type;
- (BOOL)notificationTypeRegisted:(AGXUserNotificationType)type;

+ (BOOL)noneNotificationTypeRegisted;
- (BOOL)noneNotificationTypeRegisted;
@end

#endif /* AGXCore_UIApplication_AGXCore_h */
