//
//  NSDate+AGXCore.m
//  AGXCore
//
//  Created by Char Aznable on 16/2/4.
//  Copyright © 2016年 AI-CUC-EC. All rights reserved.
//

#import "NSDate+AGXCore.h"
#import "AGXArc.h"
#import "AGXAdapt.h"
#import <time.h>
#import <xlocale.h>

@category_implementation(NSDate, AGXCore)

- (AGXTimeIntervalMills)timeIntervalMillsSinceDate:(NSDate *)anotherDate {
    return [self timeIntervalSinceDate:anotherDate] * 1000;
}

- (AGXTimeIntervalMills)timeIntervalMillsSinceNow {
    return [self timeIntervalSinceNow] * 1000;
}

- (AGXTimeIntervalMills)timeIntervalMillsSince1970 {
    return [self timeIntervalSince1970] * 1000;
}

#define AGXNSDateComponent_implement(calendarUnit, componentName)                               \
- (NSInteger)componentName {                                                                    \
    return [[NSCalendar currentCalendar] components:calendarUnit fromDate:self].componentName;  \
}

AGXNSDateComponent_implement(AGXCalendarUnitEra, era);
AGXNSDateComponent_implement(AGXCalendarUnitYear, year);
AGXNSDateComponent_implement(AGXCalendarUnitMonth, month);
AGXNSDateComponent_implement(AGXCalendarUnitDay, day);
AGXNSDateComponent_implement(AGXCalendarUnitHour, hour);
AGXNSDateComponent_implement(AGXCalendarUnitMinute, minute);
AGXNSDateComponent_implement(AGXCalendarUnitSecond, second);
AGXNSDateComponent_implement(AGXCalendarUnitWeekday, weekday);

- (NSInteger)monthCountInYear {
    return [[NSCalendar currentCalendar] rangeOfUnit:AGXCalendarUnitMonth inUnit:AGXCalendarUnitYear forDate:self].length;
}

- (NSInteger)dayCountInMonth {
    return [[NSCalendar currentCalendar] rangeOfUnit:AGXCalendarUnitDay inUnit:AGXCalendarUnitMonth forDate:self].length;
}

- (NSInteger)dayCountInYear {
    NSInteger count = 0;
    NSDateComponents *components =[[NSCalendar currentCalendar] components:
                                   NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay fromDate:self];
    for (int m = 0; m < self.monthCountInYear; m++) {
        components.month = m;
        count += [[NSCalendar currentCalendar] dateFromComponents:components].dayCountInMonth;
    }
    return count;
}

- (NSString *)stringWithDateFormat:(NSString *)dateFormat {
    NSDateFormatter *formatter = AGX_AUTORELEASE([[NSDateFormatter alloc] init]);
    formatter.dateFormat = dateFormat;
    return [formatter stringFromDate:self];
}

+ (NSDate *)dateFromRFC1123:(NSString *)rfc1123String {
    if (!rfc1123String) return nil;

    const char *str = [rfc1123String UTF8String];
    const char *fmt;
    char *ret;
    NSDate *retDate;

    fmt = "%a, %d %b %Y %H:%M:%S %Z";
    struct tm rfc1123timeinfo;
    memset(&rfc1123timeinfo, 0, sizeof(rfc1123timeinfo));
    ret = strptime_l(str, fmt, &rfc1123timeinfo, NULL);
    if (ret) {
        time_t rfc1123time = mktime(&rfc1123timeinfo);
        retDate = [NSDate dateWithTimeIntervalSince1970:rfc1123time];
        if (retDate) return retDate;
    }

    fmt = "%A, %d-%b-%y %H:%M:%S %Z";
    struct tm rfc850timeinfo;
    memset(&rfc850timeinfo, 0, sizeof(rfc850timeinfo));
    ret = strptime_l(str, fmt, &rfc850timeinfo, NULL);
    if (ret) {
        time_t rfc850time = mktime(&rfc850timeinfo);
        retDate = [NSDate dateWithTimeIntervalSince1970:rfc850time];
        if (retDate) return retDate;
    }

    fmt = "%a %b %e %H:%M:%S %Y";
    struct tm asctimeinfo;
    memset(&asctimeinfo, 0, sizeof(asctimeinfo));
    ret = strptime_l(str, fmt, &asctimeinfo, NULL);
    if (ret) {
        time_t asctime = mktime(&asctimeinfo);
        return [NSDate dateWithTimeIntervalSince1970:asctime];
    }

    return nil;
}

- (NSString *)rfc1123String {
    time_t date = (time_t)[self timeIntervalSince1970];
    struct tm timeinfo;
    gmtime_r(&date, &timeinfo);
    char buffer[32];
    size_t ret = strftime_l(buffer, sizeof(buffer), "%a, %d %b %Y %H:%M:%S GMT", &timeinfo, NULL);
    return ret ? @(buffer) : nil;
}

@end

@category_implementation(NSNumber, AGXCoreNSDate)

+ (NSNumber *)numberWithTimeInterval:(NSTimeInterval)value {
    return AGX_AUTORELEASE([[self alloc] initWithDouble:value]);
}

- (AGX_INSTANCETYPE)initWithTimeInterval:(NSTimeInterval)value {
    return [self initWithDouble:value];
}

- (NSTimeInterval)timeIntervalValue {
    return [self doubleValue];
}

+ (NSNumber *)numberWithMills:(AGXTimeIntervalMills)value {
    return AGX_AUTORELEASE([[self alloc] initWithLongLong:value]);
}

- (AGX_INSTANCETYPE)initWithMills:(AGXTimeIntervalMills)value {
    return [self initWithLongLong:value];
}

- (AGXTimeIntervalMills)millsValue {
    return [self longLongValue];
}

@end

@category_implementation(NSString, AGXCoreNSDate)

- (NSDate *)dateWithDateFormat:(NSString *)dateFormat {
    NSDateFormatter *formatter = AGX_AUTORELEASE([[NSDateFormatter alloc] init]);
    formatter.dateFormat = dateFormat;
    return [formatter dateFromString:self];
}

- (NSTimeInterval)timeIntervalValue {
    return [self doubleValue];
}

- (AGXTimeIntervalMills)millsValue {
    return [self longLongValue];
}

@end
