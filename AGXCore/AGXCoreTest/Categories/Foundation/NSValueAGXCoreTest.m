//
//  NSValueAGXCoreTest.m
//  AGXCore
//
//  Created by Char Aznable on 16/2/5.
//  Copyright © 2016年 AI-CUC-EC. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "AGXCore.h"
#import <objc/runtime.h>

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
    
    id setter = ^(id self, ...) {
        agx_va_start(self);
        MyTestStruct value = [[NSValue valueWithMyTestStructFromVaList:_argvs_] MyTestStructValue];
        XCTAssertEqual(value.identity, 10);
        XCTAssertEqual(value.height, 2.f);
        XCTAssertEqual(value.flag, 'd');
        agx_va_end;
    };
    Method setMyTestStruct = class_getInstanceMethod([self class], @selector(setMyTestStruct:));
    method_setImplementation(setMyTestStruct, imp_implementationWithBlock(setter));
    MyTestStruct setterStruct = { 10, 2.f, 'd' };
    [self setMyTestStruct:setterStruct];
}

- (void)setMyTestStruct:(MyTestStruct)testStruct {
    XCTFail(@"set implementation FAILED");
}

@end
