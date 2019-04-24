//
//  NSDate+AGXCore.m
//  AGXCore
//
//  Created by Char Aznable on 2016/2/4.
//  Copyright © 2016 github.com/CharLemAznable. All rights reserved.
//

#import <time.h>
#import <xlocale.h>
#import "NSDate+AGXCore.h"
#import "AGXArc.h"
#import "AGXAdapt.h"
#import "NSObject+AGXCore.h"

NSString *agxdate_rfc1123FromTimestamp(time_t timestamp) {
    struct tm timeinfo = {0};
    gmtime_r(&timestamp, &timeinfo);
    AGX_STATIC const size_t buffersize = 32;
    char *buffer = malloc(buffersize);
    strftime_l(buffer, buffersize, "%a, %d %b %Y %H:%M:%S GMT", &timeinfo, NULL);
    NSString *result = [NSString stringWithCString:buffer encoding:NSASCIIStringEncoding];
    free(buffer);
    return result;
}

NSString *agxdate_rfc3339FromTimestamp(time_t timestamp) {
    struct tm timeinfo = {0};
    gmtime_r(&timestamp, &timeinfo);
    AGX_STATIC const size_t buffersize = 25;
    char *buffer = malloc(buffersize);
    snprintf(buffer, buffersize, "%04d-%02d-%02dT%02d:%02d:%02d.000Z",
             timeinfo.tm_year + 1900, timeinfo.tm_mon+1, timeinfo.tm_mday,
             timeinfo.tm_hour, timeinfo.tm_min, timeinfo.tm_sec);
    NSString *result = [NSString stringWithCString:buffer encoding:NSASCIIStringEncoding];
    free(buffer);
    return result;
}

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
    return [NSCalendar.currentCalendar components:calendarUnit fromDate:self].componentName;    \
}

AGXNSDateComponent_implement(NSCalendarUnitEra, era);
AGXNSDateComponent_implement(NSCalendarUnitYear, year);
AGXNSDateComponent_implement(NSCalendarUnitMonth, month);
AGXNSDateComponent_implement(NSCalendarUnitDay, day);
AGXNSDateComponent_implement(NSCalendarUnitHour, hour);
AGXNSDateComponent_implement(NSCalendarUnitMinute, minute);
AGXNSDateComponent_implement(NSCalendarUnitSecond, second);
AGXNSDateComponent_implement(NSCalendarUnitWeekday, weekday);

#undef AGXNSDateComponent_implement

- (NSInteger)monthCountInYear {
    return [NSCalendar.currentCalendar rangeOfUnit:
            NSCalendarUnitMonth inUnit:NSCalendarUnitYear forDate:self].length;
}

- (NSInteger)dayCountInMonth {
    return [NSCalendar.currentCalendar rangeOfUnit:
            NSCalendarUnitDay inUnit:NSCalendarUnitMonth forDate:self].length;
}

- (NSInteger)dayCountInYear {
    NSInteger count = 0;
    NSDateComponents *components =[NSCalendar.currentCalendar components:
                                   NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay fromDate:self];
    for (int m = 0; m < self.monthCountInYear; m++) {
        components.month = m;
        count += [NSCalendar.currentCalendar dateFromComponents:components].dayCountInMonth;
    }
    return count;
}

- (NSString *)stringWithDateFormat:(NSString *)dateFormat {
    return [self stringWithDateFormat:dateFormat timeZone:NSTimeZone.localTimeZone];
}

- (NSString *)stringWithDateFormat:(NSString *)dateFormat timeZone:(NSTimeZone *)timeZone {
    NSDateFormatter *formatter = NSDateFormatter.instance;
    formatter.dateFormat = dateFormat;
    formatter.timeZone = timeZone;
    return [formatter stringFromDate:self];
}

//  Created by Marcus Rohrmoser
//  http://blog.mro.name/2009/08/nsdateformatter-http-header/
//  http://www.w3.org/Protocols/rfc2616/rfc2616-sec3.html#sec3.3.1
+ (AGX_INSTANCETYPE)dateFromRFC1123:(NSString *)rfc1123String {
    if AGX_EXPECT_F(!rfc1123String) return nil;

    const char *str = rfc1123String.UTF8String;
    const char *fmt;
    char *ret;
    NSDate *retDate;

    fmt = "%a, %d %b %Y %H:%M:%S %Z";
    struct tm rfc1123timeinfo;
    memset(&rfc1123timeinfo, 0, sizeof(rfc1123timeinfo));
    ret = strptime_l(str, fmt, &rfc1123timeinfo, NULL);
    if (ret) {
        time_t rfc1123time = mktime(&rfc1123timeinfo);
        retDate = [self dateWithTimeIntervalSince1970:rfc1123time];
        if AGX_EXPECT_T(retDate) return retDate;
    }

    fmt = "%A, %d-%b-%y %H:%M:%S %Z";
    struct tm rfc850timeinfo;
    memset(&rfc850timeinfo, 0, sizeof(rfc850timeinfo));
    ret = strptime_l(str, fmt, &rfc850timeinfo, NULL);
    if (ret) {
        time_t rfc850time = mktime(&rfc850timeinfo);
        retDate = [self dateWithTimeIntervalSince1970:rfc850time];
        if AGX_EXPECT_T(retDate) return retDate;
    }

    fmt = "%a %b %e %H:%M:%S %Y";
    struct tm asctimeinfo;
    memset(&asctimeinfo, 0, sizeof(asctimeinfo));
    ret = strptime_l(str, fmt, &asctimeinfo, NULL);
    if (ret) {
        time_t asctime = mktime(&asctimeinfo);
        return [self dateWithTimeIntervalSince1970:asctime];
    }

    return nil;
}

- (NSString *)rfc1123String {
    return agxdate_rfc1123FromTimestamp((time_t)self.timeIntervalSince1970);
}

+ (AGX_INSTANCETYPE)dateFromRFC3339:(NSString *)rfc3339String {
    // Date and Time representation in RFC3399:
    // Pattern #1: "YYYY-MM-DDTHH:MM:SSZ"
    //                      1
    //  0 1 2 3 4 5 6 7 8 9 0 1 2 3 4 5 6 7 8 9
    // [Y|Y|Y|Y|-|M|M|-|D|D|T|H|H|:|M|M|:|S|S|Z]
    //
    // Pattern #2: "YYYY-MM-DDTHH:MM:SS.sssZ"
    //                      1                   2
    //  0 1 2 3 4 5 6 7 8 9 0 1 2 3 4 5 6 7 8 9 0 1 2 3
    // [Y|Y|Y|Y|-|M|M|-|D|D|T|H|H|:|M|M|:|S|S|.|s|s|s|Z]
    //   NOTE: The number of digits in the "sss" part is not defined.
    //
    // Pattern #3: "YYYY-MM-DDTHH:MM:SS+HH:MM"
    //                      1                   2
    //  0 1 2 3 4 5 6 7 8 9 0 1 2 3 4 5 6 7 8 9 0 1 2 3 4
    // [Y|Y|Y|Y|-|M|M|-|D|D|T|H|H|:|M|M|:|S|S|+|H|H|:|M|M]
    //
    // Pattern #4: "YYYY-MM-DDTHH:MM:SS.sss+HH:MM"
    //                      1                   2
    //  0 1 2 3 4 5 6 7 8 9 0 1 2 3 4 5 6 7 8 9 0 1 2 3 4 5 6 7 8
    // [Y|Y|Y|Y|-|M|M|-|D|D|T|H|H|:|M|M|:|S|S|.|s|s|s|+|H|H|:|M|M]
    //   NOTE: The number of digits in the "sss" part is not defined.

    // NSDate format: "YYYY-MM-DD HH:MM:SS +HHMM".

    NSCharacterSet *setOfT = [NSCharacterSet characterSetWithCharactersInString:@"tT"];
    NSRange tMarkPos = [rfc3339String rangeOfCharacterFromSet:setOfT];
    if (NSNotFound == tMarkPos.location) return nil;

    // extract date and time part:
    NSString *datePart = [rfc3339String substringToIndex:tMarkPos.location];
    NSString *timePart = [rfc3339String substringWithRange:NSMakeRange(tMarkPos.location + tMarkPos.length, 8)];
    NSString *restPart = [rfc3339String substringFromIndex:tMarkPos.location + tMarkPos.length + 8];

    // extract time offset part:
    NSString *tzSignPart, *tzHourPart, *tzMinPart;
    NSCharacterSet *setOfZ = [NSCharacterSet characterSetWithCharactersInString:@"zZ"];
    NSRange tzPos = [restPart rangeOfCharacterFromSet:setOfZ];
    if (NSNotFound == tzPos.location) { // Pattern #3 or #4
        NSCharacterSet *setOfSign = [NSCharacterSet characterSetWithCharactersInString:@"+-"];
        NSRange tzSignPos = [restPart rangeOfCharacterFromSet:setOfSign];
        if (NSNotFound == tzSignPos.location) return nil;

        tzSignPart = [restPart substringWithRange:tzSignPos];
        tzHourPart = [restPart substringWithRange:NSMakeRange(tzSignPos.location + tzSignPos.length, 2)];
        tzMinPart = [restPart substringFromIndex:tzSignPos.location + tzSignPos.length + 2 + 1];
    } else { // Pattern #1 or #2
        // "Z" means UTC.
        tzSignPart = @"+";
        tzHourPart = @"00";
        tzMinPart = @"00";
    }

    // construct a date string in the NSDate format
    return [[NSString stringWithFormat:@"%@ %@ %@%@%@",
             datePart, timePart, tzSignPart, tzHourPart, tzMinPart]
            dateWithDateFormat:@"yyyy-MM-dd HH:mm:ss +0000"
            timeZone:[NSTimeZone timeZoneWithName:@"GMT"]];
}

- (NSString *)rfc3339String {
    return agxdate_rfc3339FromTimestamp((time_t)self.timeIntervalSince1970);
}

@end

@category_implementation(NSNumber, AGXCoreNSDate)

+ (AGX_INSTANCETYPE)numberWithTimeInterval:(NSTimeInterval)value {
    return AGX_AUTORELEASE([[self alloc] initWithDouble:value]);
}

- (AGX_INSTANCETYPE)initWithTimeInterval:(NSTimeInterval)value {
    return [self initWithDouble:value];
}

- (NSTimeInterval)timeIntervalValue {
    return self.doubleValue;
}

+ (AGX_INSTANCETYPE)numberWithMills:(AGXTimeIntervalMills)value {
    return AGX_AUTORELEASE([[self alloc] initWithLongLong:value]);
}

- (AGX_INSTANCETYPE)initWithMills:(AGXTimeIntervalMills)value {
    return [self initWithLongLong:value];
}

- (AGXTimeIntervalMills)millsValue {
    return self.longLongValue;
}

@end

@category_implementation(NSString, AGXCoreNSDate)

- (NSDate *)dateWithDateFormat:(NSString *)dateFormat {
    return [self dateWithDateFormat:dateFormat timeZone:[NSTimeZone localTimeZone]];
}

- (NSDate *)dateWithDateFormat:(NSString *)dateFormat timeZone:(NSTimeZone *)timeZone {
    NSDateFormatter *formatter = NSDateFormatter.instance;
    formatter.dateFormat = dateFormat;
    formatter.timeZone = timeZone;
    return [formatter dateFromString:self];
}

- (NSTimeInterval)timeIntervalValue {
    return [self doubleValue];
}

- (AGXTimeIntervalMills)millsValue {
    return [self longLongValue];
}

@end
