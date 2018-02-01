//
//  AGXMethodTest.m
//  AGXRuntime
//
//  Created by Char Aznable on 2016/2/19.
//  Copyright © 2016年 AI-CUC-EC. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <AGXCore/AGXCore/NSObject+AGXCore.h>
#import "AGXRuntime.h"

@interface MethodTestBean : NSObject
+ (NSString *)classMethod1;
+ (NSString *)classMethod2;
- (NSString *)instanceMethod1:(NSString *)param;
- (NSString *)instanceMethod2:(NSString *)param;

- (void)method1:(NSString *)param1;
- (void)method2:(NSString *)param1 param:(NSString *)param2;
- (void)method3:(NSString *)param1 param:(NSString *)param2 param:(NSUInteger)param3;
@end
@implementation MethodTestBean
+ (NSString *)classMethod1 { return @"classMethod1"; }
+ (NSString *)classMethod2 { return @"classMethod2"; }
- (NSString *)instanceMethod1:(NSString *)param { return @"instanceMethod1"; }
- (NSString *)instanceMethod2:(NSString *)param { return @"instanceMethod2"; }

- (void)method1:(NSString *)param1 {}
- (void)method2:(NSString *)param1 param:(NSString *)param2 {}
- (void)method3:(NSString *)param1 param:(NSString *)param2 param:(NSUInteger)param3 {}
@end

@interface AGXMethodTest : XCTestCase

@end

@implementation AGXMethodTest

- (void)testAGXMethod {
    AGXMethod *method1 = [AGXMethod classMethodWithName:@"classMethod1" inClassNamed:@"MethodTestBean"];
    AGXMethod *method2 = [AGXMethod classMethodWithName:@"classMethod2" inClassNamed:@"MethodTestBean"];
    AGXMethod *method3 = [AGXMethod classMethodWithName:@"classMethod3" inClassNamed:@"MethodTestBean"];
    XCTAssertEqualObjects(method1.selectorName, @"classMethod1");
    XCTAssertEqualObjects(method2.selectorName, @"classMethod2");
    XCTAssertNil(method3);
    IMP imp1 = method1.implementation;
    IMP imp2 = method2.implementation;
    [method1 setImplementation:imp2];
    [method2 setImplementation:imp1];
    XCTAssertEqualObjects(MethodTestBean.classMethod1, @"classMethod2");
    XCTAssertEqualObjects(MethodTestBean.classMethod2, @"classMethod1");

    method1 = [AGXMethod instanceMethodWithName:@"instanceMethod1:" inClassNamed:@"MethodTestBean"];
    method2 = [AGXMethod instanceMethodWithName:@"instanceMethod2:" inClassNamed:@"MethodTestBean"];
    method3 = [AGXMethod instanceMethodWithName:@"instanceMethod3:" inClassNamed:@"MethodTestBean"];
    XCTAssertEqualObjects(method1.selectorName, @"instanceMethod1:");
    XCTAssertEqualObjects(method2.selectorName, @"instanceMethod2:");
    XCTAssertNil(method3);
    imp1 = method1.implementation;
    imp2 = method2.implementation;
    [method1 setImplementation:imp2];
    [method2 setImplementation:imp1];
    XCTAssertEqualObjects([MethodTestBean.instance instanceMethod1:nil], @"instanceMethod2");
    XCTAssertEqualObjects([MethodTestBean.instance instanceMethod2:nil], @"instanceMethod1");
}

- (void)testPurifiedSignature {
    XCTAssertEqualObjects(@"v@:@", [AGXMethod instanceMethodWithName:
                                    @"method1:" inClassNamed:@"MethodTestBean"].purifiedSignature);
    XCTAssertEqualObjects(@"v@:@@", [AGXMethod instanceMethodWithName:
                                    @"method2:param:" inClassNamed:@"MethodTestBean"].purifiedSignature);
    XCTAssertEqualObjects(@"v@:@@Q", [AGXMethod instanceMethodWithName:
                                    @"method3:param:param:" inClassNamed:@"MethodTestBean"].purifiedSignature);
}

@end
