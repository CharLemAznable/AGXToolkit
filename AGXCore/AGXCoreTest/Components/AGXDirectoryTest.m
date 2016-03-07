//
//  AGXDirectoryTest.m
//  AGXCore
//
//  Created by Char Aznable on 16/2/5.
//  Copyright © 2016年 AI-CUC-EC. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "AGXCore.h"

@interface AGXDirectoryTest : XCTestCase

@end

@implementation AGXDirectoryTest

- (void)testAGXDirectory {
    XCTAssertFalse([AGXDirectory fileExists:@"tempfile"]);
    XCTAssertTrue([AGXDirectory createDirectory:@"tempfile"]);
    XCTAssertTrue([AGXDirectory directoryExists:@"tempfile"]);
    XCTAssertTrue([AGXDirectory deleteDirectory:@"tempfile"]);
}

@end
