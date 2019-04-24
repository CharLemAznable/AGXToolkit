//
//  AGXDelegateForwarderTest.m
//  AGXCoreTest
//
//  Created by Char Aznable on 2019/4/18.
//  Copyright © 2019 github.com/CharLemAznable. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "AGXCore.h"

static int count = 0;

@protocol MyDelegate <NSObject>
@optional
- (void)increaseCount;
@end

@interface MyDelegateTarget : NSObject
@end
@implementation MyDelegateTarget
- (void)increaseCount {
    count = count + 1;
}
@end

@interface MyDelegateTarget2 : NSObject <MyDelegate>
@end
@implementation MyDelegateTarget2
- (void)increaseCount {
    count = count + 2;
}
@end

@forwarder_interface(MyDelegateForwarder, MyDelegateTarget, MyDelegate)
@forwarder_implementation(MyDelegateForwarder, MyDelegateTarget, MyDelegate)

@interface AGXDelegateForwarderTest : XCTestCase

@end

@implementation AGXDelegateForwarderTest

- (void)testDelegateForwarder {
    MyDelegateForwarder *forwarder = MyDelegateForwarder.instance;
    XCTAssertFalse([forwarder respondsToSelector:@selector(increaseCount)]);
    XCTAssertThrows([forwarder increaseCount]);
    XCTAssertEqual(0, count);

    MyDelegateTarget *target1 = MyDelegateTarget.instance;
    forwarder.internalDelegate = target1;
    XCTAssertTrue([forwarder respondsToSelector:@selector(increaseCount)]);
    XCTAssertNoThrow([forwarder increaseCount]);
    XCTAssertEqual(1, count);
    forwarder.internalDelegate = nil;

    MyDelegateTarget2 *target2 = MyDelegateTarget2.instance;
    forwarder.externalDelegate = target2;
    XCTAssertTrue([forwarder respondsToSelector:@selector(increaseCount)]);
    XCTAssertNoThrow([forwarder increaseCount]);
    XCTAssertEqual(3, count);
    forwarder.externalDelegate = nil;

    forwarder.internalDelegate = target1;
    forwarder.externalDelegate = target2;
    XCTAssertTrue([forwarder respondsToSelector:@selector(increaseCount)]);
    XCTAssertNoThrow([forwarder increaseCount]);
    XCTAssertEqual(6, count);
}

@end
