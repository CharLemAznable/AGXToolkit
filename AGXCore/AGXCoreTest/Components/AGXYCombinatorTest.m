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

AGXYCombinator(YCombIntInt, int, int)

- (void)testYComb {
    YCombIntIntRecFunc fib = YCombIntInt(^YCombIntIntRecFunc(YCombIntIntRecFunc recFunc) {
        return AGX_BLOCK_AUTORELEASE(^int(int n) {
            if (n <= 2) return 1;
            return recFunc(n - 1) + recFunc(n - 2);
        });
    });
    XCTAssertEqual(55, fib(10));

    YCombIntIntRecFunc fac = YCombIntInt(^YCombIntIntRecFunc(YCombIntIntRecFunc recFunc) {
        return AGX_BLOCK_AUTORELEASE(^int(int n) {
            if (n <= 1) return 1;
            return n * recFunc(n - 1);
        });
    });
    XCTAssertEqual(3628800, fac(10));
}

@end
