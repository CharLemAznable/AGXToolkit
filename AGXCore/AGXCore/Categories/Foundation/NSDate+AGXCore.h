//
//  NSDate+AGXCore.h
//  AGXCore
//
//  Created by Char Aznable on 16/2/4.
//  Copyright © 2016年 AI-CUC-EC. All rights reserved.
//

#ifndef AGXCore_NSDate_AGXCore_h
#define AGXCore_NSDate_AGXCore_h

#import "AGXCategory.h"

typedef long long AGXTimeIntervalMills;

const char *agxdate_rfc1123FromTimestamp(time_t timestamp);
const char *agxdate_rfc3339FromTimestamp(time_t timestamp);

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

@property (readonly) NSInteger monthCountInYear;
@property (readonly) NSInteger dayCountInMonth;
@property (readonly) NSInteger dayCountInYear;

- (NSString *)stringWithDateFormat:(NSString *)dateFormat;
- (NSString *)stringWithDateFormat:(NSString *)dateFormat timeZone:(NSTimeZone *)timeZone;

//  Created by Marcus Rohrmoser
//  http://blog.mro.name/2009/08/nsdateformatter-http-header/
//  http://www.w3.org/Protocols/rfc2616/rfc2616-sec3.html#sec3.3.1
+ (AGX_INSTANCETYPE)dateFromRFC1123:(NSString*)rfc1123String;
- (NSString *)rfc1123String;

+ (AGX_INSTANCETYPE)dateFromRFC3339:(NSString*)rfc3339String;
- (NSString *)rfc3339String;
@end

@category_interface(NSNumber, AGXCoreNSDate)
+ (AGX_INSTANCETYPE)numberWithTimeInterval:(NSTimeInterval)value;
- (AGX_INSTANCETYPE)initWithTimeInterval:(NSTimeInterval)value;
- (NSTimeInterval)timeIntervalValue;

+ (AGX_INSTANCETYPE)numberWithMills:(AGXTimeIntervalMills)value;
- (AGX_INSTANCETYPE)initWithMills:(AGXTimeIntervalMills)value;
- (AGXTimeIntervalMills)millsValue;
@end

@category_interface(NSString, AGXCoreNSDate)
- (NSDate *)dateWithDateFormat:(NSString *)dateFormat;
- (NSDate *)dateWithDateFormat:(NSString *)dateFormat timeZone:(NSTimeZone *)timeZone;

- (NSTimeInterval)timeIntervalValue;
- (AGXTimeIntervalMills)millsValue;
@end

#endif /* AGXCore_NSDate_AGXCore_h */
