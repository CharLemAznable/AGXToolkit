//
//  AGXIvarTest.m
//  AGXRuntime
//
//  Created by Char Aznable on 2016/2/19.
//  Copyright © 2016年 AI-CUC-EC. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "AGXRuntime.h"

@interface IvarDetailBean : NSObject
@end
@implementation IvarDetailBean
@end

@interface IvarTestBean : NSObject {
    NSString *name;
    int age;
    IvarDetailBean *detail;
    CGPoint point;
    id others;
}
@end
@implementation IvarTestBean
@end

@interface AGXIvarTest : XCTestCase

@end

@implementation AGXIvarTest

- (void)testAGXIvar {
    AGXIvar *ivar = [AGXIvar instanceIvarWithName:@"name" inClassNamed:@"IvarTestBean"];
    XCTAssertEqualObjects([ivar name], @"name");
    XCTAssertEqualObjects([ivar typeName], @"NSString");
    XCTAssertEqualObjects([ivar typeEncoding], @"@\"NSString\"");

    ivar = [AGXIvar instanceIvarWithName:@"age" inClassNamed:@"IvarTestBean"];
    XCTAssertEqualObjects([ivar name], @"age");
    XCTAssertEqualObjects([ivar typeName], @"i");
    XCTAssertEqualObjects([ivar typeEncoding], @"i");

    ivar = [AGXIvar instanceIvarWithName:@"detail" inClassNamed:@"IvarTestBean"];
    XCTAssertEqualObjects([ivar name], @"detail");
    XCTAssertEqualObjects([ivar typeName], @"IvarDetailBean");
    XCTAssertEqualObjects([ivar typeEncoding], @"@\"IvarDetailBean\"");

    ivar = [AGXIvar instanceIvarWithName:@"point" inClassNamed:@"IvarTestBean"];
    XCTAssertEqualObjects([ivar name], @"point");
    XCTAssertEqualObjects([ivar typeName], @"{CGPoint=\"x\"d\"y\"d}");
    XCTAssertEqualObjects([ivar typeEncoding], @"{CGPoint=\"x\"d\"y\"d}");

    ivar = [AGXIvar instanceIvarWithName:@"others" inClassNamed:@"IvarTestBean"];
    XCTAssertEqualObjects([ivar name], @"others");
    XCTAssertEqualObjects([ivar typeName], @"");
    XCTAssertEqualObjects([ivar typeEncoding], @"@");
}

@end
