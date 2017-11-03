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

- (void)testRandomDoubleWithBound {
    XCTAssertEqual(sizeof(AGXRandom.DOUBLE_UNDER(100)), 8);
    int count = 0;
    for (int i = 0; i < 100; i++) {
        if (AGXRandom.DOUBLE_UNDER(100) > 50) count++;
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

- (void)testRandomFloatWithBound {
    XCTAssertEqual(sizeof(AGXRandom.FLOAT_UNDER(100)), 4);
    int count = 0;
    for (int i = 0; i < 100; i++) {
        if (AGXRandom.FLOAT_UNDER(100) > 50) count++;
    }
    XCTAssert(count > 0);
    XCTAssert(count < 100);
}

- (void)testRandomCGFloat {
    XCTAssertEqual(sizeof(AGXRandom.CGFLOAT()), sizeof(CGFloat));
    int count = 0;
    for (int i = 0; i < 100; i++) {
        if (AGXRandom.CGFLOAT() > 0.5) count++;
    }
    XCTAssert(count > 0);
    XCTAssert(count < 100);
}

- (void)testRandomCGFloatWithBound {
    XCTAssertEqual(sizeof(AGXRandom.CGFLOAT_UNDER(100)), sizeof(CGFloat));
    int count = 0;
    for (int i = 0; i < 100; i++) {
        if (AGXRandom.CGFLOAT_UNDER(100) > 50) count++;
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

    XCTAssertEqual(AGXRandom.LONG_UNDER(0), 0);
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

    XCTAssertEqual(AGXRandom.INT_UNDER(0), 0);
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

    XCTAssertEqual(AGXRandom.UINTEGER_UNDER(0), 0);
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

- (void)testRandomCGPoint {
    CGRect rect = CGRectMake(0, 0, 1, 1);
    CGPoint point = AGXRandom.CGPOINT();
    XCTAssertTrue(CGRectContainsPoint(rect, point));

    CGRect rect2 = CGRectMake(10, 20, 30, 40);
    CGPoint point2 = AGXRandom.CGPOINT_IN(rect2);
    XCTAssertTrue(CGRectContainsPoint(rect2, point2));
}

- (void)testRandomUIColor {
    UIColor *color = AGXRandom.UICOLOR_RGB();
    CGFloat components[4] = {-1, -1, -1, -1};
    [color getRed:&components[0] green:&components[1]
             blue:&components[2] alpha:&components[3]];
    XCTAssertTrue(components[0] >= 0);
    XCTAssertTrue(components[0] <= 1);
    XCTAssertTrue(components[1] >= 0);
    XCTAssertTrue(components[1] <= 1);
    XCTAssertTrue(components[2] >= 0);
    XCTAssertTrue(components[2] <= 1);
    XCTAssertTrue(components[3] == 1);

    UIColor *color2 = AGXRandom.UICOLOR_RGBA();
    CGFloat components2[4] = {-1, -1, -1, -1};
    [color2 getRed:&components2[0] green:&components2[1]
              blue:&components2[2] alpha:&components2[3]];
    XCTAssertTrue(components2[0] >= 0);
    XCTAssertTrue(components2[0] <= 1);
    XCTAssertTrue(components2[1] >= 0);
    XCTAssertTrue(components2[1] <= 1);
    XCTAssertTrue(components2[2] >= 0);
    XCTAssertTrue(components2[2] <= 1);
    XCTAssertTrue(components2[3] >= 0);
    XCTAssertTrue(components2[3] <= 1);

    UIColor *color3 = AGXRandom.UICOLOR_ALPHA(0.5);
    CGFloat components3[4] = {-1, -1, -1, -1};
    [color3 getRed:&components3[0] green:&components3[1]
              blue:&components3[2] alpha:&components3[3]];
    XCTAssertTrue(components3[0] >= 0);
    XCTAssertTrue(components3[0] <= 1);
    XCTAssertTrue(components3[1] >= 0);
    XCTAssertTrue(components3[1] <= 1);
    XCTAssertTrue(components3[2] >= 0);
    XCTAssertTrue(components3[2] <= 1);
    XCTAssertTrue(components3[3] == 0.5);
}

- (void)testRandomUIFont {
    NSString *fontName = AGXRandom.UIFONT_NAME();
    XCTAssertNotNil(fontName);

    UIFont *font = AGXRandom.UIFONT();
    XCTAssertNotNil(font);
    XCTAssertTrue(font.pointSize >= 10);
    XCTAssertTrue(font.pointSize <= 20);

    UIFont *font2 = AGXRandom.UIFONT_LIMITIN(20, 30);
    XCTAssertNotNil(font2);
    XCTAssertTrue(font2.pointSize >= 20);
    XCTAssertTrue(font2.pointSize <= 30);
}

@end
