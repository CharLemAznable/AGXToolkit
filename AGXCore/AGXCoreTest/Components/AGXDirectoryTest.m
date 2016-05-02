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
    XCTAssertFalse([AGXDirectory fileExists:@"tempdir"]);
    XCTAssertTrue([AGXDirectory createDirectory:@"tempdir"]);
    XCTAssertTrue([AGXDirectory directoryExists:@"tempdir"]);
    XCTAssertFalse([AGXDirectory fileExists:@"tempdir/tempsubdir/tempfile"]);

    NSArray *tempArray = @[@"AAA", @"BBB", @"CCC"];

    [tempArray writeToUserFile:@"tempfile" inDirectory:AGXDocument subpath:@"tempdir/tempsubdir"];
    XCTAssertTrue([AGXDirectory directoryExists:@"tempdir/tempsubdir"]);
    XCTAssertTrue([AGXDirectory fileExists:@"tempdir/tempsubdir/tempfile"]);
    XCTAssertEqualObjects(tempArray, [NSArray arrayWithContentsOfUserFile:@"tempdir/tempsubdir/tempfile"]);
    XCTAssertTrue([AGXDirectory deleteDirectory:@"tempdir"]);

    [tempArray writeToUserFile:@"tempdir/tempsubdir/tempfile" inDirectory:AGXDocument];
    XCTAssertTrue([AGXDirectory directoryExists:@"tempdir/tempsubdir"]);
    XCTAssertTrue([AGXDirectory fileExists:@"tempdir/tempsubdir/tempfile"]);
    XCTAssertEqualObjects(tempArray, [NSArray arrayWithContentsOfUserFile:@"tempdir/tempsubdir/tempfile"]);
    XCTAssertTrue([AGXDirectory deleteDirectory:@"tempdir"]);

    [tempArray writeToUserFile:@"tempfile" inDirectory:AGXDocument];
    XCTAssertTrue([AGXDirectory fileExists:@"tempfile"]);
    XCTAssertEqualObjects(tempArray, [NSArray arrayWithContentsOfUserFile:@"tempfile"]);
    XCTAssertTrue([AGXDirectory deleteFile:@"tempfile"]);

    XCTAssertTrue([AGXDirectory createFile:@"tempdir/tempsubdir/tempfile" content:tempArray]);
    XCTAssertTrue([AGXDirectory directoryExists:@"tempdir/tempsubdir"]);
    XCTAssertTrue([AGXDirectory fileExists:@"tempdir/tempsubdir/tempfile"]);
    XCTAssertEqualObjects(tempArray, [AGXDirectory contentOfFile:@"tempdir/tempsubdir/tempfile"]);
    XCTAssertTrue([AGXDirectory deleteDirectory:@"tempdir"]);

    XCTAssertTrue([AGXDirectory createFile:@"tempfile" content:tempArray]);
    XCTAssertTrue([AGXDirectory fileExists:@"tempfile"]);
    XCTAssertEqualObjects(tempArray, [AGXDirectory contentOfFile:@"tempfile"]);
    XCTAssertTrue([AGXDirectory deleteFile:@"tempfile"]);
}

@end
