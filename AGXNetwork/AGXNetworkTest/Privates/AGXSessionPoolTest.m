//
//  AGXSessionPoolTest.m
//  AGXNetwork
//
//  Created by Char Aznable on 16/4/26.
//  Copyright © 2016年 AI-CUC-EC. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "AGXSessionPool.h"

@interface AGXSessionPoolTest : XCTestCase

@end

@implementation AGXSessionPoolTest

- (void)testSessionPool {
    XCTAssertNotNil([AGXSessionPool shareAGXSessionPool]);
    XCTAssertNotNil([AGXSessionPool shareAGXSessionPool].defaultSession);
    XCTAssertNotNil([AGXSessionPool shareAGXSessionPool].ephemeralSession);
    XCTAssertNotNil([AGXSessionPool shareAGXSessionPool].backgroundSession);
    XCTAssertEqualObjects([AGXSessionPool shareAGXSessionPool].backgroundSession.configuration.identifier, @"org.cuc.n3.AGXNetworkTest");
    XCTAssertNotNil([AGXSessionPool shareAGXSessionPool].runningTasksSynchronizingQueue);
    XCTAssertNotNil([AGXSessionPool shareAGXSessionPool].activeTasks);
}

@end
