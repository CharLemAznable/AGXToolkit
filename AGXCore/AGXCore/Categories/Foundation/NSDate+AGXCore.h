//
//  NSDate+AGXCore.h
//  AGXCore
//
//  Created by Char Aznable on 16/2/4.
//  Copyright © 2016年 AI-CUC-EC. All rights reserved.
//

#ifndef AGXCore_NSDate_AGXCore_h
#define AGXCore_NSDate_AGXCore_h

#import <UIKit/UIKit.h>
#import "AGXCategory.h"

typedef long long AGXTimeIntervalMills;

@category_interface(NSDate, AGXCore)
- (AGXTimeIntervalMills)timeIntervalMillsSinceDate:(NSDate *)anotherDate;
@property (readonly) AGXTimeIntervalMills timeIntervalMillsSinceNow;
@property (readonly) AGXTimeIntervalMills timeIntervalMillsSince1970;

@property (readonly) NSInteger era;
@property (readonly) NSInteger year;
@property (readonly) NSInteger month;
@property (readonly) NSInteger day;
@property (readonly) NSInteger hour;
@property (readonly) NSInteger minute;
@property (readonly) NSInteger second;
@property (readonly) NSInteger weekday;

- (NSString *)stringWithDateFormat:(NSString *)dateFormat;
@end

@category_interface(NSNumber, AGXCoreNSDate)
+ (NSNumber *)numberWithMills:(AGXTimeIntervalMills)value;
- (AGX_INSTANCETYPE)initWithMills:(AGXTimeIntervalMills)value;
- (AGXTimeIntervalMills)millsValue;
@end

@category_interface(NSString, AGXCoreNSDate)
- (NSDate *)dateWithDateFormat:(NSString *)dateFormat;
- (AGXTimeIntervalMills)millsValue;
@end

#endif /* AGXCore_NSDate_AGXCore_h */
