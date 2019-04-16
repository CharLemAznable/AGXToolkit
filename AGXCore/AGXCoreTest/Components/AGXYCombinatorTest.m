//
//  AGXYCombinatorTest.m
//  AGXCore
//
//  Created by Char Aznable on 2016/12/18.
//  Copyright © 2016 github.com/CharLemAznable. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "AGXCore.h"

@interface AGXYCombinatorTest : XCTestCase

@end

@implementation AGXYCombinatorTest

- (void)testYComb {
    AGXRecursiveBlock fib = AGXYCombinator(^(id n) {
        int i = [n intValue];
        if (i <= 2) return @(1);
        return @([SELF(@(i - 1)) intValue] + [SELF(@(i - 2)) intValue]);
    });
    XCTAssertEqual(55, [fib(@10) intValue]);

    AGXRecursiveBlock fac = AGXYCombinator(^(id n) {
        int i = [n intValue];
        if (i <= 1) return @(1);
        return @(i * [SELF(@(i - 1)) intValue]);
    });
    XCTAssertEqual(3628800, [fac(@10) intValue]);
}

@end
