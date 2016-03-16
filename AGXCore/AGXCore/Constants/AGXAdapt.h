//
//  AGXAdapt.h
//  AGXCore
//
//  Created by Char Aznable on 16/2/4.
//  Copyright © 2016年 AI-CUC-EC. All rights reserved.
//

#ifndef AGXCore_AGXAdapt_h
#define AGXCore_AGXAdapt_h

#define IS_IPHONE4                      ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(640, 960), [[UIScreen mainScreen] currentMode].size) : NO)
#define IS_IPHONE5                      ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(640, 1136), [[UIScreen mainScreen] currentMode].size) : NO)
#define IS_IPHONE6                      ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(750, 1334), [[UIScreen mainScreen] currentMode].size) : NO)
#define IS_IPHONE6P                     ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(1242, 2208), [[UIScreen mainScreen] currentMode].size) : NO)

#define DeviceScale                     (IS_IPHONE6P ? 1.29375 : (IS_IPHONE6 ? 1.171875 : 1.0))
#define LogicScreenSize                 ([UIScreen mainScreen].bounds.size)

#define BEFORE_IOS6                     ([[[UIDevice currentDevice] systemVersion] compare:@"6.0"] == NSOrderedAscending)
#define BEFORE_IOS7                     ([[[UIDevice currentDevice] systemVersion] compare:@"7.0"] == NSOrderedAscending)
#define BEFORE_IOS8                     ([[[UIDevice currentDevice] systemVersion] compare:@"8.0"] == NSOrderedAscending)
#define BEFORE_IOS9                     ([[[UIDevice currentDevice] systemVersion] compare:@"9.0"] == NSOrderedAscending)

#define IOS6_OR_LATER                   (!BEFORE_IOS6)
#define IOS7_OR_LATER                   (!BEFORE_IOS7)
#define IOS8_OR_LATER                   (!BEFORE_IOS8)
#define IOS9_OR_LATER                   (!BEFORE_IOS9)

#define statusBarHeight                 (IOS7_OR_LATER ? 20 : 0)
#define statusBarFix                    (IOS7_OR_LATER ? 0 : 20)

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
# define AGXTextAlignmentLeft               (IOS6_OR_LATER? NSTextAlignmentLeft : UITextAlignmentLeft)
# define AGXTextAlignmentCenter             (IOS6_OR_LATER? NSTextAlignmentCenter : UITextAlignmentCenter)
# define AGXTextAlignmentRight              (IOS6_OR_LATER? NSTextAlignmentRight : UITextAlignmentRight)
# define AGXLineBreakByWordWrapping         (IOS6_OR_LATER? NSLineBreakByWordWrapping : UILineBreakModeWordWrap)
# define AGXLineBreakByCharWrapping         (IOS6_OR_LATER? NSLineBreakByCharWrapping : UILineBreakModeCharacterWrap)
# define AGXLineBreakByClipping             (IOS6_OR_LATER? NSLineBreakByClipping : UILineBreakModeClip)
# define AGXLineBreakByTruncatingHead       (IOS6_OR_LATER? NSLineBreakByTruncatingHead : UILineBreakModeHeadTruncation)
# define AGXLineBreakByTruncatingTail       (IOS6_OR_LATER? NSLineBreakByTruncatingTail : UILineBreakModeTailTruncation)
# define AGXLineBreakByTruncatingMiddle     (IOS6_OR_LATER? NSLineBreakByTruncatingMiddle : UILineBreakModeMiddleTruncation)
# define agxkCTTextAlignmentLeft            (IOS6_OR_LATER? kCTTextAlignmentLeft : kCTLeftTextAlignment)
# define agxkCTTextAlignmentRight           (IOS6_OR_LATER? kCTTextAlignmentRight : kCTRightTextAlignment)
# define agxkCTTextAlignmentCenter          (IOS6_OR_LATER? kCTTextAlignmentCenter : kCTCenterTextAlignment)
# define agxkCTTextAlignmentJustified       (IOS6_OR_LATER? kCTTextAlignmentJustified : kCTJustifiedTextAlignment)
# define agxkCTTextAlignmentNatural         (IOS6_OR_LATER? kCTTextAlignmentNatural : kCTNaturalTextAlignment)

# define AGXFontAttributeName               (IOS6_OR_LATER? NSFontAttributeName : UITextAttributeFont)
# define AGXForegroundColorAttributeName    (IOS6_OR_LATER? NSForegroundColorAttributeName : UITextAttributeTextColor)
#endif // __IPHONE_OS_VERSION_MIN_REQUIRED >= 60000

#if __IPHONE_OS_VERSION_MIN_REQUIRED >= 70000
# define AGXStatusBarStyleDefault           UIStatusBarStyleDefault
# define AGXStatusBarStyleLightContent      UIStatusBarStyleLightContent
# define AGXStatusBarStyleBlackTranslucent  UIStatusBarStyleLightContent
# define AGXStatusBarStyleBlackOpaque       UIStatusBarStyleLightContent
#else
# define AGXStatusBarStyleDefault           UIStatusBarStyleDefault
# define AGXStatusBarStyleLightContent      (IOS6_OR_LATER? UIStatusBarStyleLightContent : UIStatusBarStyleBlackTranslucent)
# define AGXStatusBarStyleBlackTranslucent  (IOS7_OR_LATER? UIStatusBarStyleLightContent : UIStatusBarStyleBlackTranslucent)
# define AGXStatusBarStyleBlackOpaque       (IOS7_OR_LATER? UIStatusBarStyleLightContent : UIStatusBarStyleBlackOpaque)UIStatusBarStyleLightContent
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
# define AGXCalendarUnitEra                 (IOS8_OR_LATER? NSCalendarUnitEra : NSEraCalendarUnit)
# define AGXCalendarUnitYear                (IOS8_OR_LATER? NSCalendarUnitYear : NSYearCalendarUnit)
# define AGXCalendarUnitMonth               (IOS8_OR_LATER? NSCalendarUnitMonth : NSMonthCalendarUnit)
# define AGXCalendarUnitDay                 (IOS8_OR_LATER? NSCalendarUnitDay : NSDayCalendarUnit)
# define AGXCalendarUnitHour                (IOS8_OR_LATER? NSCalendarUnitHour : NSHourCalendarUnit)
# define AGXCalendarUnitMinute              (IOS8_OR_LATER? NSCalendarUnitMinute : NSMinuteCalendarUnit)
# define AGXCalendarUnitSecond              (IOS8_OR_LATER? NSCalendarUnitSecond : NSSecondCalendarUnit)
# define AGXCalendarUnitWeekday             (IOS8_OR_LATER? NSCalendarUnitWeekday : NSWeekdayCalendarUnit)
# define AGXCalendarUnitWeekdayOrdinal      (IOS8_OR_LATER? NSCalendarUnitWeekdayOrdinal : NSWeekdayOrdinalCalendarUnit)

# define AGXUserNotificationType            UIRemoteNotificationType
# define AGXUserNotificationTypeNone        UIRemoteNotificationTypeNone
# define AGXUserNotificationTypeBadge       UIRemoteNotificationTypeBadge
# define AGXUserNotificationTypeSound       UIRemoteNotificationTypeSound
# define AGXUserNotificationTypeAlert       UIRemoteNotificationTypeAlert
#endif // __IPHONE_OS_VERSION_MIN_REQUIRED >= 80000

#endif /* AGXCore_AGXAdapt_h */
