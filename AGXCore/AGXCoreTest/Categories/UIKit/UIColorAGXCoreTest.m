//
//  UIColorAGXCoreTest.m
//  AGXCore
//
//  Created by Char Aznable on 16/2/18.
//  Copyright © 2016年 AI-CUC-EC. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "AGXCore.h"

@interface UIColorAGXCoreTest : XCTestCase

@end

@implementation UIColorAGXCoreTest

- (void)testUIColorAGXCore {
    UIColor *integerDarkGrayColor = AGXColor(85, 85, 85);
    UIColor *darkGrayColor = [UIColor darkGrayColor];
    XCTAssertTrue([integerDarkGrayColor isEqualToColor:darkGrayColor]);

    UIColor *integerLightGrayColor = AGXColor(170, 170, 170);
    UIColor *lightGrayColor = [UIColor lightGrayColor];
    XCTAssertTrue([integerLightGrayColor isEqualToColor:lightGrayColor]);

    XCTAssertEqual(AGXColor(@"ffaadd").colorAlpha, 1.0);
    XCTAssertEqual(AGXColor(@"ffaadd33").colorAlpha, 0.2);
}

@end
