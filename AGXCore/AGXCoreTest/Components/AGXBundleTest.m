//
//  AGXBundleTest.m
//  AGXCore
//
//  Created by Char Aznable on 2016/2/5.
//  Copyright © 2016年 AI-CUC-EC. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "AGXCore.h"

@interface AGXBundleTest : XCTestCase

@end

@implementation AGXBundleTest

- (void)testAGXBundle {
    XCTAssertEqualObjects(AGXBundle.bundlePath, [NSBundle bundleForClass:AGXBundle.class].resourcePath);
    XCTAssertEqualObjects(AGXBundle.bundleNameAs(@"AGXBundleTest").bundlePath, [[NSBundle bundleForClass:AGXBundle.class] pathForResource:@"AGXBundleTest" ofType:@"bundle"]);
    XCTAssertEqualObjects(AGXBundle.bundleNameAs(@"AGXBundleTest").subpathAs(@"en.lproj").bundlePath, [[NSBundle bundleWithPath:[[NSBundle bundleForClass:AGXBundle.class] pathForResource:@"AGXBundleTest" ofType:@"bundle"]] pathForResource:@"en" ofType:@"lproj"]);

    XCTAssertEqualObjects(AGXBundle.appIdentifier, @"org.cuc.n3.AGXCoreTest");
    XCTAssertEqualObjects(AGXBundle.appVersion, @"1.0");
    XCTAssertEqualObjects(AGXBundle.appBuildNumber, @"1");
}

@end
