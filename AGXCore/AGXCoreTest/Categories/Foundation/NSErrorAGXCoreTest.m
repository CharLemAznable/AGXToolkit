//
//  NSErrorAGXCoreTest.m
//  AGXCore
//
//  Created by Char Aznable on 17/9/29.
//  Copyright © 2017年 AI-CUC-EC. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "AGXCore.h"

@interface NSErrorAGXCoreTest : XCTestCase

@end

@implementation NSErrorAGXCoreTest

- (void)testErrorWithDomain {
    NSString *expectedDomain = @"Domain";
    NSInteger expectedCode = 10;
    NSString *expectedDescriptionFmt = @"A description %d";
    NSError *error = [NSError errorWithDomain:expectedDomain code:expectedCode description:expectedDescriptionFmt, 1];
    XCTAssertEqualObjects(error.domain, expectedDomain);
    XCTAssertEqual(error.code, expectedCode);
    XCTAssertEqualObjects(error.localizedDescription, ([NSString stringWithFormat:expectedDescriptionFmt, 1]));
}

- (void)testFillError {
    NSError *error = nil;
    NSString *expectedDomain = @"Domain";
    NSInteger expectedCode = 10;
    NSString *expectedDescriptionFmt = @"A description %d";
    XCTAssertTrue(([NSError fillError:&error withDomain:expectedDomain code:expectedCode description:expectedDescriptionFmt, 1]));
    XCTAssertEqualObjects(error.domain, expectedDomain);
    XCTAssertEqual(error.code, expectedCode);
    XCTAssertEqualObjects(error.localizedDescription, ([NSString stringWithFormat:expectedDescriptionFmt, 1]));
}

- (void)testFillErrorNil {
    XCTAssertFalse(([NSError fillError:nil withDomain:@"Domain" code:10 description:@"A description %d", 1]));
}

- (void)testClearError {
    NSError *error = [NSError errorWithDomain:@"" code:1 description:@""];
    XCTAssertNotNil(error);
    XCTAssertTrue([NSError clearError:&error]);
    XCTAssertNil(error);
}

- (void)testClearErrorNil {
    XCTAssertFalse([NSError clearError:nil]);
}

@end
