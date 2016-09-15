//
//  AGXAdapt.h
//  AGXCore
//
//  Created by Char Aznable on 16/2/4.
//  Copyright © 2016年 AI-CUC-EC. All rights reserved.
//

#ifndef AGXCore_AGXAdapt_h
#define AGXCore_AGXAdapt_h

#import "NSString+AGXCore.h"

#if __IPHONE_OS_VERSION_MIN_REQUIRED < __IPHONE_7_0
#error AGXToolkit is supported only on iOS 7 and above
#endif

#define AGX_IS_IPHONE4                  ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(640, 960), [[UIScreen mainScreen] currentMode].size) : NO)
#define AGX_IS_IPHONE5                  ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(640, 1136), [[UIScreen mainScreen] currentMode].size) : NO)
#define AGX_IS_IPHONE6                  ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(750, 1334), [[UIScreen mainScreen] currentMode].size) : NO)
#define AGX_IS_IPHONE6_BIGMODE          ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(640, 1136), [[UIScreen mainScreen] currentMode].size) : NO)
#define AGX_IS_IPHONE6P                 ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(1242, 2208), [[UIScreen mainScreen] currentMode].size) : NO)
#define AGX_IS_IPHONE6P_BIGMODE         ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(1125, 2001), [[UIScreen mainScreen] currentMode].size) : NO)

#define AGX_DeviceScale                 (AGX_IS_IPHONE6P?1.29375:(AGX_IS_IPHONE6||AGX_IS_IPHONE6P_BIGMODE?1.171875:1.0))
#define AGX_LogicScreenSize             ([UIScreen mainScreen].bounds.size)
#define AGX_SinglePixel                 (1/[UIScreen mainScreen].scale)

#define AGX_SYSTEM_VERSION_COMPARE(ver) [[[UIDevice currentDevice] systemVersion] compareToVersionString:@ver]

#define AGX_BEFORE_IOS7_1               (AGX_SYSTEM_VERSION_COMPARE("7.1")  == NSOrderedAscending)
#define AGX_BEFORE_IOS8_0               (AGX_SYSTEM_VERSION_COMPARE("8.0")  == NSOrderedAscending)
#define AGX_BEFORE_IOS8_1               (AGX_SYSTEM_VERSION_COMPARE("8.1")  == NSOrderedAscending)
#define AGX_BEFORE_IOS8_2               (AGX_SYSTEM_VERSION_COMPARE("8.2")  == NSOrderedAscending)
#define AGX_BEFORE_IOS8_3               (AGX_SYSTEM_VERSION_COMPARE("8.3")  == NSOrderedAscending)
#define AGX_BEFORE_IOS8_4               (AGX_SYSTEM_VERSION_COMPARE("8.4")  == NSOrderedAscending)
#define AGX_BEFORE_IOS9_0               (AGX_SYSTEM_VERSION_COMPARE("9.0")  == NSOrderedAscending)
#define AGX_BEFORE_IOS9_1               (AGX_SYSTEM_VERSION_COMPARE("9.1")  == NSOrderedAscending)
#define AGX_BEFORE_IOS9_2               (AGX_SYSTEM_VERSION_COMPARE("9.2")  == NSOrderedAscending)
#define AGX_BEFORE_IOS9_3               (AGX_SYSTEM_VERSION_COMPARE("9.3")  == NSOrderedAscending)
#define AGX_BEFORE_IOS10_0              (AGX_SYSTEM_VERSION_COMPARE("10.0") == NSOrderedAscending)

#define AGX_IOS7_1_OR_LATER             (!AGX_BEFORE_IOS7_1)
#define AGX_IOS8_0_OR_LATER             (!AGX_BEFORE_IOS8_0)
#define AGX_IOS8_1_OR_LATER             (!AGX_BEFORE_IOS8_1)
#define AGX_IOS8_2_OR_LATER             (!AGX_BEFORE_IOS8_2)
#define AGX_IOS8_3_OR_LATER             (!AGX_BEFORE_IOS8_3)
#define AGX_IOS8_4_OR_LATER             (!AGX_BEFORE_IOS8_4)
#define AGX_IOS9_0_OR_LATER             (!AGX_BEFORE_IOS9_0)
#define AGX_IOS9_1_OR_LATER             (!AGX_BEFORE_IOS9_1)
#define AGX_IOS9_2_OR_LATER             (!AGX_BEFORE_IOS9_2)
#define AGX_IOS9_3_OR_LATER             (!AGX_BEFORE_IOS9_3)
#define AGX_IOS10_0_OR_LATER            (!AGX_BEFORE_IOS10_0)

#if __IPHONE_OS_VERSION_MIN_REQUIRED >= __IPHONE_8_0
# define AGXCalendarUnitEra             NSCalendarUnitEra
# define AGXCalendarUnitYear            NSCalendarUnitYear
# define AGXCalendarUnitMonth           NSCalendarUnitMonth
# define AGXCalendarUnitDay             NSCalendarUnitDay
# define AGXCalendarUnitHour            NSCalendarUnitHour
# define AGXCalendarUnitMinute          NSCalendarUnitMinute
# define AGXCalendarUnitSecond          NSCalendarUnitSecond
# define AGXCalendarUnitWeekday         NSCalendarUnitWeekday
# define AGXCalendarUnitWeekdayOrdinal  NSCalendarUnitWeekdayOrdinal
#else // __IPHONE_OS_VERSION_MIN_REQUIRED >= __IPHONE_8_0
# define AGXCalendarUnitEra             (AGX_IOS8_0_OR_LATER? NSCalendarUnitEra : NSEraCalendarUnit)
# define AGXCalendarUnitYear            (AGX_IOS8_0_OR_LATER? NSCalendarUnitYear : NSYearCalendarUnit)
# define AGXCalendarUnitMonth           (AGX_IOS8_0_OR_LATER? NSCalendarUnitMonth : NSMonthCalendarUnit)
# define AGXCalendarUnitDay             (AGX_IOS8_0_OR_LATER? NSCalendarUnitDay : NSDayCalendarUnit)
# define AGXCalendarUnitHour            (AGX_IOS8_0_OR_LATER? NSCalendarUnitHour : NSHourCalendarUnit)
# define AGXCalendarUnitMinute          (AGX_IOS8_0_OR_LATER? NSCalendarUnitMinute : NSMinuteCalendarUnit)
# define AGXCalendarUnitSecond          (AGX_IOS8_0_OR_LATER? NSCalendarUnitSecond : NSSecondCalendarUnit)
# define AGXCalendarUnitWeekday         (AGX_IOS8_0_OR_LATER? NSCalendarUnitWeekday : NSWeekdayCalendarUnit)
# define AGXCalendarUnitWeekdayOrdinal  (AGX_IOS8_0_OR_LATER? NSCalendarUnitWeekdayOrdinal : NSWeekdayOrdinalCalendarUnit)
#endif // __IPHONE_OS_VERSION_MIN_REQUIRED >= __IPHONE_8_0

#endif /* AGXCore_AGXAdapt_h */
