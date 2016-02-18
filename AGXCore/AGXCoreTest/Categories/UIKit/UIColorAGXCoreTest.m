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
    UIColor *integerDarkGrayColor = [UIColor colorWithIntegerRed:85 green:85 blue:85];
    UIColor *darkGrayColor = [UIColor darkGrayColor];
    XCTAssertTrue([integerDarkGrayColor isEqualToColor:darkGrayColor]);
    
    UIColor *integerLightGrayColor = [UIColor colorWithIntegerRed:170 green:170 blue:170];
    UIColor *lightGrayColor = [UIColor lightGrayColor];
    XCTAssertTrue([integerLightGrayColor isEqualToColor:lightGrayColor]);
}

@end
