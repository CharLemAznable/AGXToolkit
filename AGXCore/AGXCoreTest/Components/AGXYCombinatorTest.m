//
//  AGXYCombinatorTest.m
//  AGXCore
//
//  Created by Char Aznable on 16/12/18.
//  Copyright © 2016年 AI-CUC-EC. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "AGXCore.h"

@interface AGXYCombinatorTest : XCTestCase

@end

@implementation AGXYCombinatorTest

- (void)testYComb {
    AGXRecursiveBlock fib = AGXYCombinator(^(int n) {
        if (n <= 2) return @(1);
        return @([recursive_with(n - 1) intValue] + [recursive_with(n - 2) intValue]);
    });
    XCTAssertEqual(55, [fib(10) intValue]);

    AGXRecursiveBlock fac = AGXYCombinator(^(int n) {
        if (n <= 1) return @(1);
        return @(n * [recursive_with(n - 1) intValue]);
    });
    XCTAssertEqual(3628800, [fac(10) intValue]);
}

@end
