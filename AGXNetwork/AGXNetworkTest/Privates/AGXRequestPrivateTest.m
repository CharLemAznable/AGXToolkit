//
//  AGXRequestPrivateTest.m
//  AGXNetwork
//
//  Created by Char Aznable on 16/4/26.
//  Copyright © 2016年 AI-CUC-EC. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "AGXRequest+Private.h"

@interface AGXRequestPrivateTest : XCTestCase

@end

@implementation AGXRequestPrivateTest

- (void)testExample {
    AGXRequest *request = [[AGXRequest alloc] initWithURLString:@"" params:@{} httpMethod:@"" bodyData:nil];
    XCTAssertEqual(request.state, AGXRequestStateReady);
    XCTAssertEqualObjects([request valueForKey:@"stateHistory"], @[@(AGXRequestStateReady)]);
    request.state = AGXRequestStateCancelled;
    XCTAssertEqual(request.state, AGXRequestStateCancelled);
    XCTAssertEqualObjects([request valueForKey:@"stateHistory"], (@[@(AGXRequestStateReady), @(AGXRequestStateCancelled)]));
}

@end
