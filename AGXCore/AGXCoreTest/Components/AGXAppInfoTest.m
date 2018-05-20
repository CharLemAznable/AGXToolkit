//
//  AGXAppInfoTest.m
//  AGXCoreTest
//
//  Created by Char Aznable on 2018/3/14.
//  Copyright © 2018年 AI-CUC-EC. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "AGXCore.h"

@interface AGXAppInfoTest : XCTestCase

@end

@implementation AGXAppInfoTest

- (void)testAppInfo {
    XCTAssertEqualObjects(AGXAppInfo.appIdentifier, @"org.cuc.n3.AGXCoreTest");
    XCTAssertEqualObjects(AGXAppInfo.appVersion, @"1.0");
    XCTAssertEqualObjects(AGXAppInfo.appBuildNumber, @"1");
}

@end
