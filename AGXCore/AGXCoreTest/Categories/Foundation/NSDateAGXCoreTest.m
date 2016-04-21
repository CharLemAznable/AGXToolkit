//
//  NSDateAGXCoreTest.m
//  AGXCore
//
//  Created by Char Aznable on 16/2/5.
//  Copyright © 2016年 AI-CUC-EC. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "AGXCore.h"

@interface NSDateAGXCoreTest : XCTestCase

@end

@implementation NSDateAGXCoreTest

- (void)testNSDateAGXCore {
    NSString *string = @"2015-11-25 11:48";
    NSDate *stringDate = [string dateWithDateFormat:@"yyyy-MM-dd HH:mm"];
    NSString *dateString = [stringDate stringWithDateFormat:@"yyyy-MM-dd HH:mm"];
    XCTAssertEqualObjects(string, dateString);

    NSString *mills = nil;
    XCTAssertEqual([mills millsValue], 0);
    mills = @"123";
    XCTAssertEqual([mills millsValue], 123);
}

@end
