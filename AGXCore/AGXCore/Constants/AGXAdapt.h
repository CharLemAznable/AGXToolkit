//
//  AGXAdapt.h
//  AGXCore
//
//  Created by Char Aznable on 16/2/4.
//  Copyright © 2016年 AI-CUC-EC. All rights reserved.
//

#ifndef AGXCore_AGXAdapt_h
#define AGXCore_AGXAdapt_h

#define AGX_IS_IPHONE4                  ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(640, 960), [[UIScreen mainScreen] currentMode].size) : NO)
#define AGX_IS_IPHONE5                  ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(640, 1136), [[UIScreen mainScreen] currentMode].size) : NO)
#define AGX_IS_IPHONE6                  ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(750, 1334), [[UIScreen mainScreen] currentMode].size) : NO)
#define AGX_IS_IPHONE6P                 ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(1242, 2208), [[UIScreen mainScreen] currentMode].size) : NO)

#define AGX_DeviceScale                 (AGX_IS_IPHONE6P ? 1.29375 : (AGX_IS_IPHONE6 ? 1.171875 : 1.0))
#define AGX_LogicScreenSize             ([UIScreen mainScreen].bounds.size)

#define AGX_BEFORE_IOS6                 ([[[UIDevice currentDevice] systemVersion] compare:@"6.0"] == NSOrderedAscending)
#define AGX_BEFORE_IOS7                 ([[[UIDevice currentDevice] systemVersion] compare:@"7.0"] == NSOrderedAscending)
#define AGX_BEFORE_IOS8                 ([[[UIDevice currentDevice] systemVersion] compare:@"8.0"] == NSOrderedAscending)
#define AGX_BEFORE_IOS9                 ([[[UIDevice currentDevice] systemVersion] compare:@"9.0"] == NSOrderedAscending)

#define AGX_IOS6_OR_LATER               (!AGX_BEFORE_IOS6)
#define AGX_IOS7_OR_LATER               (!AGX_BEFORE_IOS7)
#define AGX_IOS8_OR_LATER               (!AGX_BEFORE_IOS8)
#define AGX_IOS9_OR_LATER               (!AGX_BEFORE_IOS9)

#define agxStatusBarHeight              (AGX_IOS7_OR_LATER ? 20 : 0)
#define agxStatusBarFix                 (AGX_IOS7_OR_LATER ? 0 : 20)

#if __IPHONE_OS_VERSION_MIN_REQUIRED >= 60000
# define AGXTextAlignmentLeft               NSTextAlignmentLeft
# define AGXTextAlignmentCenter             NSTextAlignmentCenter
# define AGXTextAlignmentRight              NSTextAlignmentRight
# define AGXLineBreakByWordWrapping         NSLineBreakByWordWrapping
# define AGXLineBreakByCharWrapping         NSLineBreakByCharWrapping
# define AGXLineBreakByClipping             NSLineBreakByClipping
# define AGXLineBreakByTruncatingHead       NSLineBreakByTruncatingHead
# define AGXLineBreakByTruncatingTail       NSLineBreakByTruncatingTail
# define AGXLineBreakByTruncatingMiddle     NSLineBreakByTruncatingMiddle
# define agxkCTTextAlignmentLeft            kCTTextAlignmentLeft
# define agxkCTTextAlignmentRight           kCTTextAlignmentRight
# define agxkCTTextAlignmentCenter          kCTTextAlignmentCenter
# define agxkCTTextAlignmentJustified       kCTTextAlignmentJustified
# define agxkCTTextAlignmentNatural         kCTTextAlignmentNatural

# define AGXFontAttributeName               NSFontAttributeName
# define AGXForegroundColorAttributeName    NSForegroundColorAttributeName

#else // __IPHONE_OS_VERSION_MIN_REQUIRED >= 60000
# define AGXTextAlignmentLeft               (AGX_IOS6_OR_LATER? NSTextAlignmentLeft : UITextAlignmentLeft)
# define AGXTextAlignmentCenter             (AGX_IOS6_OR_LATER? NSTextAlignmentCenter : UITextAlignmentCenter)
# define AGXTextAlignmentRight              (AGX_IOS6_OR_LATER? NSTextAlignmentRight : UITextAlignmentRight)
# define AGXLineBreakByWordWrapping         (AGX_IOS6_OR_LATER? NSLineBreakByWordWrapping : UILineBreakModeWordWrap)
# define AGXLineBreakByCharWrapping         (AGX_IOS6_OR_LATER? NSLineBreakByCharWrapping : UILineBreakModeCharacterWrap)
# define AGXLineBreakByClipping             (AGX_IOS6_OR_LATER? NSLineBreakByClipping : UILineBreakModeClip)
# define AGXLineBreakByTruncatingHead       (AGX_IOS6_OR_LATER? NSLineBreakByTruncatingHead : UILineBreakModeHeadTruncation)
# define AGXLineBreakByTruncatingTail       (AGX_IOS6_OR_LATER? NSLineBreakByTruncatingTail : UILineBreakModeTailTruncation)
# define AGXLineBreakByTruncatingMiddle     (AGX_IOS6_OR_LATER? NSLineBreakByTruncatingMiddle : UILineBreakModeMiddleTruncation)
# define agxkCTTextAlignmentLeft            (AGX_IOS6_OR_LATER? kCTTextAlignmentLeft : kCTLeftTextAlignment)
# define agxkCTTextAlignmentRight           (AGX_IOS6_OR_LATER? kCTTextAlignmentRight : kCTRightTextAlignment)
# define agxkCTTextAlignmentCenter          (AGX_IOS6_OR_LATER? kCTTextAlignmentCenter : kCTCenterTextAlignment)
# define agxkCTTextAlignmentJustified       (AGX_IOS6_OR_LATER? kCTTextAlignmentJustified : kCTJustifiedTextAlignment)
# define agxkCTTextAlignmentNatural         (AGX_IOS6_OR_LATER? kCTTextAlignmentNatural : kCTNaturalTextAlignment)

# define AGXFontAttributeName               (AGX_IOS6_OR_LATER? NSFontAttributeName : UITextAttributeFont)
# define AGXForegroundColorAttributeName    (AGX_IOS6_OR_LATER? NSForegroundColorAttributeName : UITextAttributeTextColor)
#endif // __IPHONE_OS_VERSION_MIN_REQUIRED >= 60000

#if __IPHONE_OS_VERSION_MIN_REQUIRED >= 70000
# define AGXStatusBarStyleDefault           UIStatusBarStyleDefault
# define AGXStatusBarStyleLightContent      UIStatusBarStyleLightContent
# define AGXStatusBarStyleBlackTranslucent  UIStatusBarStyleLightContent
# define AGXStatusBarStyleBlackOpaque       UIStatusBarStyleLightContent
#else
# define AGXStatusBarStyleDefault           UIStatusBarStyleDefault
# define AGXStatusBarStyleLightContent      (AGX_IOS6_OR_LATER? UIStatusBarStyleLightContent : UIStatusBarStyleBlackTranslucent)
# define AGXStatusBarStyleBlackTranslucent  (AGX_IOS7_OR_LATER? UIStatusBarStyleLightContent : UIStatusBarStyleBlackTranslucent)
# define AGXStatusBarStyleBlackOpaque       (AGX_IOS7_OR_LATER? UIStatusBarStyleLightContent : UIStatusBarStyleBlackOpaque)UIStatusBarStyleLightContent
#endif // __IPHONE_OS_VERSION_MIN_REQUIRED >= 70000

#if __IPHONE_OS_VERSION_MIN_REQUIRED >= 80000
# define AGXCalendarUnitEra                 NSCalendarUnitEra
# define AGXCalendarUnitYear                NSCalendarUnitYear
# define AGXCalendarUnitMonth               NSCalendarUnitMonth
# define AGXCalendarUnitDay                 NSCalendarUnitDay
# define AGXCalendarUnitHour                NSCalendarUnitHour
# define AGXCalendarUnitMinute              NSCalendarUnitMinute
# define AGXCalendarUnitSecond              NSCalendarUnitSecond
# define AGXCalendarUnitWeekday             NSCalendarUnitWeekday
# define AGXCalendarUnitWeekdayOrdinal      NSCalendarUnitWeekdayOrdinal

# define AGXUserNotificationType            UIUserNotificationType
# define AGXUserNotificationTypeNone        UIUserNotificationTypeNone
# define AGXUserNotificationTypeBadge       UIUserNotificationTypeBadge
# define AGXUserNotificationTypeSound       UIUserNotificationTypeSound
# define AGXUserNotificationTypeAlert       UIUserNotificationTypeAlert
#else // __IPHONE_OS_VERSION_MIN_REQUIRED >= 80000
# define AGXCalendarUnitEra                 (AGX_IOS8_OR_LATER? NSCalendarUnitEra : NSEraCalendarUnit)
# define AGXCalendarUnitYear                (AGX_IOS8_OR_LATER? NSCalendarUnitYear : NSYearCalendarUnit)
# define AGXCalendarUnitMonth               (AGX_IOS8_OR_LATER? NSCalendarUnitMonth : NSMonthCalendarUnit)
# define AGXCalendarUnitDay                 (AGX_IOS8_OR_LATER? NSCalendarUnitDay : NSDayCalendarUnit)
# define AGXCalendarUnitHour                (AGX_IOS8_OR_LATER? NSCalendarUnitHour : NSHourCalendarUnit)
# define AGXCalendarUnitMinute              (AGX_IOS8_OR_LATER? NSCalendarUnitMinute : NSMinuteCalendarUnit)
# define AGXCalendarUnitSecond              (AGX_IOS8_OR_LATER? NSCalendarUnitSecond : NSSecondCalendarUnit)
# define AGXCalendarUnitWeekday             (AGX_IOS8_OR_LATER? NSCalendarUnitWeekday : NSWeekdayCalendarUnit)
# define AGXCalendarUnitWeekdayOrdinal      (AGX_IOS8_OR_LATER? NSCalendarUnitWeekdayOrdinal : NSWeekdayOrdinalCalendarUnit)

# define AGXUserNotificationType            UIRemoteNotificationType
# define AGXUserNotificationTypeNone        UIRemoteNotificationTypeNone
# define AGXUserNotificationTypeBadge       UIRemoteNotificationTypeBadge
# define AGXUserNotificationTypeSound       UIRemoteNotificationTypeSound
# define AGXUserNotificationTypeAlert       UIRemoteNotificationTypeAlert
#endif // __IPHONE_OS_VERSION_MIN_REQUIRED >= 80000

#endif /* AGXCore_AGXAdapt_h */
