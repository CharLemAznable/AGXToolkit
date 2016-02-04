//
//  NSValueAGXCoreTest.m
//  AGXCore
//
//  Created by Char Aznable on 16/2/5.
//  Copyright © 2016年 AI-CUC-EC. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "AGXCore.h"

typedef struct {
    int identity;
    float height;
    unsigned char flag;
} MyTestStruct;

@struct_boxed_interface(MyTestStruct)
@struct_boxed_implementation(MyTestStruct)

@interface NSValueAGXCoreTest : XCTestCase

@end

@implementation NSValueAGXCoreTest

- (void)testNSValueAGXCore {
    CGPoint point = CGPointMake(0, 10);
    NSValue *pointValue = [NSValue valueWithCGPoint:point];
    XCTAssertEqualObjects([pointValue valueForKey:@"x"], @0);
    XCTAssertEqualObjects([pointValue valueForKey:@"y"], @10);
    
    MyTestStruct testStruct = { 100, 20.0f, 'c' };
    NSValue *testStructValue = [NSValue valueWithMyTestStruct:testStruct];
    XCTAssertNotNil(testStructValue);
    MyTestStruct testStruct2 = [testStructValue MyTestStructValue];
    XCTAssertEqual(testStruct.identity, testStruct2.identity);
    XCTAssertEqual(testStruct.height, testStruct2.height);
    XCTAssertEqual(testStruct.flag, testStruct2.flag);
}

@end
