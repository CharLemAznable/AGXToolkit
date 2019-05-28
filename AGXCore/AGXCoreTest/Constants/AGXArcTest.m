//
//  AGXArcTest.m
//  AGXCoreTest
//
//  Created by Char on 2019/5/28.
//  Copyright © 2019 github.com/CharLemAznable. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "AGXCore.h"

@interface BlockTestClass : NSObject
@property (nonatomic, AGX_STRONG) NSString *name;
@property (nonatomic, copy) void (^block)(void);
@end
@implementation BlockTestClass
static int deallocCount = 0;
- (void)dealloc {
    deallocCount++;
    AGX_RELEASE(_name);
    AGX_BLOCK_RELEASE(_block);
    AGX_SUPER_DEALLOC;
}
@end

@interface AGXArcTest : XCTestCase

@end

@implementation AGXArcTest

- (void)testWeakifyAndStrongify {
    BlockTestClass *blockTest = [[BlockTestClass alloc] init];
    blockTest.name = @"John Doe";
    AGX_WEAKIFY(weakBlockTest, blockTest);
    void (^block)(void) = ^{
        AGX_STRONGIFY(strongBlockTest, weakBlockTest);
        if (strongBlockTest) {
            XCTAssertEqual(@"John Doe", strongBlockTest.name);
        } else XCTAssertEqual(1, deallocCount);
        AGX_UNSTRONGIFY(strongBlockTest);
    };
    blockTest.block = block;
    blockTest.block();
    AGX_RELEASE(blockTest);
    blockTest = nil;
    XCTAssertEqual(1, deallocCount);
    block();
}

@end
