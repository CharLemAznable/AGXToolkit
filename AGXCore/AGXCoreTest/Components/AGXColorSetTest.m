//
//  AGXColorSetTest.m
//  AGXCore
//
//  Created by Char Aznable on 16/2/18.
//  Copyright © 2016年 AI-CUC-EC. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "AGXCore.h"

@interface AGXColorSetTest : XCTestCase

@end

@implementation AGXColorSetTest

- (void)testAGXColorSet {
    AGXColorSet *cs = [[AGXColorSet alloc] initWithContentsOfUserFile:@"AGXColorSetTest"];
    XCTAssertEqualObjects(cs[@"blackColor"], [UIColor colorWithRed:0 green:0 blue:0 alpha:1]);
    XCTAssertEqualObjects(cs[@"whiteColor"], [UIColor colorWithRed:1 green:1 blue:1 alpha:1]);
    [cs reloadWithContentsOfUserFile:@"AGXColorSetTest2"];
    XCTAssertEqualObjects(cs[@"blackColor"], [UIColor colorWithRed:1 green:1 blue:1 alpha:1]);
    XCTAssertEqualObjects(cs[@"whiteColor"], [UIColor colorWithRed:0 green:0 blue:0 alpha:1]);
}

@end
