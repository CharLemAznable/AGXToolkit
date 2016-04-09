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

- (NSString *)stringWithDateFormat:(NSString *)dateFormat {
    NSDateFormatter *formatter = AGX_AUTORELEASE([[NSDateFormatter alloc] init]);
    formatter.dateFormat = dateFormat;
    return [formatter stringFromDate:self];
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
