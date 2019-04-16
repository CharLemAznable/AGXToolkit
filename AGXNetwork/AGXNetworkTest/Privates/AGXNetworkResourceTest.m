//
//  AGXNetworkResourceTest.m
//  AGXNetwork
//
//  Created by Char Aznable on 2016/4/26.
//  Copyright © 2016 github.com/CharLemAznable. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "AGXNetworkResource.h"

@interface AGXNetworkResourceTest : XCTestCase

@end

@implementation AGXNetworkResourceTest

- (void)testSessionPool {
    XCTAssertNotNil(AGXNetworkResource.shareNetwork);
    XCTAssertNotNil(AGXNetworkResource.defaultSession);
    XCTAssertNotNil(AGXNetworkResource.ephemeralSession);
    XCTAssertNotNil(AGXNetworkResource.backgroundSession);
    XCTAssertEqualObjects(AGXNetworkResource.backgroundSession.configuration.identifier, @"org.cuc.n3.AGXNetworkTest");
}

@end
