//
//  AGXBundleTest.m
//  AGXCore
//
//  Created by Char Aznable on 16/2/5.
//  Copyright © 2016年 AI-CUC-EC. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "AGXCore.h"

@interface AGXBundleTest : XCTestCase

@end

@implementation AGXBundleTest

- (void)testAGXBundle {
    XCTAssertEqualObjects(AGXBundle.appIdentifier, @"org.cuc.n3.AGXCoreTest");
    XCTAssertEqualObjects(AGXBundle.appVersion, @"1.0");
}

@end
