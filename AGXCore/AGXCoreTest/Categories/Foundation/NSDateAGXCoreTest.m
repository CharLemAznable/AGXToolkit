//
//  NSDateAGXCoreTest.m
//  AGXCore
//
//  Created by Char Aznable on 2016/2/5.
//  Copyright © 2016 github.com/CharLemAznable. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "AGXCore.h"

@interface NSDateAGXCoreTest : XCTestCase

@end

@implementation NSDateAGXCoreTest

- (void)testNSDateAGXCore {
    NSString *string = @"2016-11-25 11:48";
    NSDate *stringDate = [string dateWithDateFormat:@"yyyy-MM-dd HH:mm"];
    NSString *dateString = [stringDate stringWithDateFormat:@"yyyy-MM-dd HH:mm"];
    XCTAssertEqualObjects(string, dateString);

    XCTAssertEqual(25, stringDate.day);
    XCTAssertEqual(30, stringDate.dayCountInMonth);
    XCTAssertEqual(366, stringDate.dayCountInYear);

    NSString *mills = nil;
    XCTAssertEqual(mills.millsValue, 0);
    mills = @"123";
    XCTAssertEqual(mills.millsValue, 123);

    NSString *rfc1123String = @"Tue, 21 Dec 2010 05:54:26 GMT";
    NSDate *rfc1123Date = [NSDate dateFromRFC1123:rfc1123String];
    XCTAssertNotNil(rfc1123Date);
    XCTAssertEqualObjects(rfc1123Date.rfc1123String, rfc1123String);

    NSString *rfc3339String = @"2010-12-21T05:54:26.000Z";
    NSDate *rfc3339Date = [NSDate dateFromRFC3339:rfc3339String];
    XCTAssertNotNil(rfc3339Date);
    XCTAssertEqualObjects(rfc3339Date.rfc3339String, rfc3339String);
}

@end
