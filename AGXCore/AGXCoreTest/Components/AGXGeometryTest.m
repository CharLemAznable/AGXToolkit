//
//  AGXGeometryTest.m
//  AGXCore
//
//  Created by Char Aznable on 2016/2/5.
//  Copyright © 2016 github.com/CharLemAznable. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "AGXCore.h"

@interface AGXGeometryTest : XCTestCase

@end

@implementation AGXGeometryTest

- (void)testAGXGeometry {
    CGRect rect = AGX_CGRectMake(CGPointMake(0, 10), CGSizeMake(100, 200));
    XCTAssertEqual(rect.origin.x, 0);
    XCTAssertEqual(rect.origin.y, 10);
    XCTAssertEqual(rect.size.width, 100);
    XCTAssertEqual(rect.size.height, 200);
}

@end
