//
//  AGXRandomTest.m
//  AGXCoreTest
//
//  Created by Char Aznable on 2017/10/30.
//  Copyright © 2017年 AI-CUC-EC. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "AGXCore.h"

@interface AGXRandomTest : XCTestCase

@end

@implementation AGXRandomTest

- (void)testRandomBoolean {
    int count = 0;
    for (int i = 0; i < 100; i++) {
        if (AGXRandom.BOOLEAN()) count++;
    }
    XCTAssert(count > 0);
    XCTAssert(count < 100);
}

- (void)testRandomDouble {
    XCTAssertEqual(sizeof(AGXRandom.DOUBLE()), 8);
    int count = 0;
    for (int i = 0; i < 100; i++) {
        if (AGXRandom.DOUBLE() > 0.5) count++;
    }
    XCTAssert(count > 0);
    XCTAssert(count < 100);
}

- (void)testRandomFloat {
    XCTAssertEqual(sizeof(AGXRandom.FLOAT()), 4);
    int count = 0;
    for (int i = 0; i < 100; i++) {
        if (AGXRandom.FLOAT() > 0.5) count++;
    }
    XCTAssert(count > 0);
    XCTAssert(count < 100);
}

- (void)testRandomLong {
    XCTAssertEqual(sizeof(AGXRandom.LONG()), 8);
    int count = 0;
    for (int i = 0; i < 100; i++) {
        if (AGXRandom.LONG() > (UINT64_MAX / 2)) count++;
    }
    XCTAssert(count > 0);
    XCTAssert(count < 100);
}

- (void)testRandomLongWithBound {
    XCTAssertEqual(sizeof(AGXRandom.LONG_UNDER(100)), 8);
    int count = 0;
    for (int i = 0; i < 100; i++) {
        if (AGXRandom.LONG_UNDER(100) >= 50) count++;
    }
    XCTAssert(count > 0);
    XCTAssert(count < 100);

    XCTAssertEqual(AGXRandom.LONG_UNDER(-100), 0);
}

- (void)testRandomInt {
    XCTAssertEqual(sizeof(AGXRandom.INT()), 4);
    int count = 0;
    for (int i = 0; i < 100; i++) {
        if (AGXRandom.INT() > (UINT32_MAX / 2)) count++;
    }
    XCTAssert(count > 0);
    XCTAssert(count < 100);
}

- (void)testRandomIntWithBound {
    XCTAssertEqual(sizeof(AGXRandom.INT_UNDER(100)), 4);
    int count = 0;
    for (int i = 0; i < 100; i++) {
        if (AGXRandom.INT_UNDER(100) >= 50) count++;
    }
    XCTAssert(count > 0);
    XCTAssert(count < 100);

    XCTAssertEqual(AGXRandom.INT_UNDER(-100), 0);
}

- (void)testRandomInteger {
    XCTAssertEqual(sizeof(AGXRandom.UINTEGER()), sizeof(NSUInteger));
    int count = 0;
    for (int i = 0; i < 100; i++) {
        if (AGXRandom.UINTEGER() > (NSUIntegerMax / 2)) count++;
    }
    XCTAssert(count > 0);
    XCTAssert(count < 100);
}

- (void)testRandomIntegerWithBound {
    XCTAssertEqual(sizeof(AGXRandom.UINTEGER_UNDER(100)), sizeof(NSUInteger));
    int count = 0;
    for (int i = 0; i < 100; i++) {
        if (AGXRandom.UINTEGER_UNDER(100) >= 50) count++;
    }
    XCTAssert(count > 0);
    XCTAssert(count < 100);

    XCTAssertEqual(AGXRandom.UINTEGER_UNDER(-100), 0);
}

- (void)testRandomNum {
    XCTAssertEqualObjects(AGXRandom.NUM(-1), @"");

    NSString *randomString = AGXRandom.NUM(10);
    NSRange range = [randomString rangeOfString:@"\\d{10}" options:NSRegularExpressionSearch];
    XCTAssertEqual(range.location, 0);
    XCTAssertEqual(range.length, 10);
}

- (void)testRandomAscii {
    XCTAssertEqualObjects(AGXRandom.ASCII(-1), @"");

    NSString *randomString = AGXRandom.ASCII(50);
    NSRange range = [randomString rangeOfString:@"[%&'\\(\\)\\*+,\\-\\./:;<=>\\?@\\[\\\\\\]\\^_`\\{\\|\\}~0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz]{50}" options:NSRegularExpressionSearch];
    XCTAssertEqual(range.location, 0);
    XCTAssertEqual(range.length, 50);
}

- (void)testRandomLetters {
    XCTAssertEqualObjects(AGXRandom.LETTERS(-1), @"");

    NSString *randomString = AGXRandom.LETTERS(20);
    NSRange range = [randomString rangeOfString:@"[ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz]{20}" options:NSRegularExpressionSearch];
    XCTAssertEqual(range.location, 0);
    XCTAssertEqual(range.length, 20);
}

- (void)testRandomAlphanumeric {
    XCTAssertEqualObjects(AGXRandom.ALPHANUMERIC(-1), @"");

    NSString *randomString = AGXRandom.ALPHANUMERIC(30);
    NSRange range = [randomString rangeOfString:@"[0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz]{30}" options:NSRegularExpressionSearch];
    XCTAssertEqual(range.location, 0);
    XCTAssertEqual(range.length, 30);
}

@end
