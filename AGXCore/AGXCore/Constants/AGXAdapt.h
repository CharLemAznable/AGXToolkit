//
//  AGXAdapt.h
//  AGXCore
//
//  Created by Char Aznable on 16/2/4.
//  Copyright © 2016年 AI-CUC-EC. All rights reserved.
//

#ifndef AGXCore_AGXAdapt_h
#define AGXCore_AGXAdapt_h

#import <UIKit/UIKit.h>

#if __IPHONE_OS_VERSION_MIN_REQUIRED < __IPHONE_7_0
#error AGXToolkit is supported only on iOS 7 and above
#endif

#define AGX_IS_IPHONE4                  ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(640, 960), [[UIScreen mainScreen] currentMode].size) : NO)
#define AGX_IS_IPHONE5                  ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(640, 1136), [[UIScreen mainScreen] currentMode].size) : NO)
#define AGX_IS_IPHONE6                  ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(750, 1334), [[UIScreen mainScreen] currentMode].size) : NO)
#define AGX_IS_IPHONE6P                 ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(1242, 2208), [[UIScreen mainScreen] currentMode].size) : NO)

#define AGX_DeviceScale                 (AGX_IS_IPHONE6P ? 1.29375 : (AGX_IS_IPHONE6 ? 1.171875 : 1.0))
#define AGX_LogicScreenSize             ([UIScreen mainScreen].bounds.size)
#define AGX_SinglePixel                 (1/[UIScreen mainScreen].scale)

#define AGX_BEFORE_IOS8                 ([[[UIDevice currentDevice] systemVersion] compare:@"8.0"] == NSOrderedAscending)
#define AGX_BEFORE_IOS9                 ([[[UIDevice currentDevice] systemVersion] compare:@"9.0"] == NSOrderedAscending)

#define AGX_IOS8_OR_LATER               (!AGX_BEFORE_IOS8)
#define AGX_IOS9_OR_LATER               (!AGX_BEFORE_IOS9)

#if __IPHONE_OS_VERSION_MIN_REQUIRED >= __IPHONE_8_0
# define AGXCalendarUnitEra                 NSCalendarUnitEra
# define AGXCalendarUnitYear                NSCalendarUnitYear
# define AGXCalendarUnitMonth               NSCalendarUnitMonth
# define AGXCalendarUnitDay                 NSCalendarUnitDay
# define AGXCalendarUnitHour                NSCalendarUnitHour
# define AGXCalendarUnitMinute              NSCalendarUnitMinute
# define AGXCalendarUnitSecond              NSCalendarUnitSecond
# define AGXCalendarUnitWeekday             NSCalendarUnitWeekday
# define AGXCalendarUnitWeekdayOrdinal      NSCalendarUnitWeekdayOrdinal
#else // __IPHONE_OS_VERSION_MIN_REQUIRED >= __IPHONE_8_0
# define AGXCalendarUnitEra                 (AGX_IOS8_OR_LATER? NSCalendarUnitEra : NSEraCalendarUnit)
# define AGXCalendarUnitYear                (AGX_IOS8_OR_LATER? NSCalendarUnitYear : NSYearCalendarUnit)
# define AGXCalendarUnitMonth               (AGX_IOS8_OR_LATER? NSCalendarUnitMonth : NSMonthCalendarUnit)
# define AGXCalendarUnitDay                 (AGX_IOS8_OR_LATER? NSCalendarUnitDay : NSDayCalendarUnit)
# define AGXCalendarUnitHour                (AGX_IOS8_OR_LATER? NSCalendarUnitHour : NSHourCalendarUnit)
# define AGXCalendarUnitMinute              (AGX_IOS8_OR_LATER? NSCalendarUnitMinute : NSMinuteCalendarUnit)
# define AGXCalendarUnitSecond              (AGX_IOS8_OR_LATER? NSCalendarUnitSecond : NSSecondCalendarUnit)
# define AGXCalendarUnitWeekday             (AGX_IOS8_OR_LATER? NSCalendarUnitWeekday : NSWeekdayCalendarUnit)
# define AGXCalendarUnitWeekdayOrdinal      (AGX_IOS8_OR_LATER? NSCalendarUnitWeekdayOrdinal : NSWeekdayOrdinalCalendarUnit)
#endif // __IPHONE_OS_VERSION_MIN_REQUIRED >= __IPHONE_8_0

#endif /* AGXCore_AGXAdapt_h */
