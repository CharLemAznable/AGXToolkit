//
//  AGXDirectoryTest.m
//  AGXCore
//
//  Created by Char Aznable on 16/2/5.
//  Copyright © 2016年 AI-CUC-EC. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "AGXCore.h"
#import <objc/runtime.h>

@interface AGXDirectoryTest : XCTestCase

@end

@implementation AGXDirectoryTest

- (void)testAGXDirectory {
    XCTAssertFalse(AGXDirectory.document.fileExists(@"tempdir"));
    XCTAssertTrue(AGXDirectory.document.createDirectory(@"tempdir"));
    XCTAssertTrue(AGXDirectory.document.directoryExists(@"tempdir"));
    XCTAssertFalse(AGXDirectory.document.fileExists(@"tempdir/tempsubdir/tempfile"));

    NSArray *tempArray = @[@"AAA", @"BBB", @"CCC"];

    [tempArray writeToUserFile:@"tempfile" inDirectory:AGXDocument subpath:@"tempdir/tempsubdir"];
    XCTAssertTrue(AGXDirectory.document.directoryExists(@"tempdir/tempsubdir"));
    XCTAssertTrue(AGXDirectory.document.fileExists(@"tempdir/tempsubdir/tempfile"));
    XCTAssertEqualObjects(tempArray, [NSArray arrayWithContentsOfUserFile:@"tempdir/tempsubdir/tempfile"]);
    XCTAssertTrue(AGXDirectory.document.deleteDirectory(@"tempdir"));

    [tempArray writeToUserFile:@"tempdir/tempsubdir/tempfile" inDirectory:AGXDocument];
    XCTAssertTrue(AGXDirectory.document.directoryExists(@"tempdir/tempsubdir"));
    XCTAssertTrue(AGXDirectory.document.fileExists(@"tempdir/tempsubdir/tempfile"));
    XCTAssertEqualObjects(tempArray, [NSArray arrayWithContentsOfUserFile:@"tempdir/tempsubdir/tempfile"]);
    XCTAssertTrue(AGXDirectory.document.deleteDirectory(@"tempdir"));

    [tempArray writeToUserFile:@"tempfile" inDirectory:AGXDocument];
    XCTAssertTrue(AGXDirectory.document.fileExists(@"tempfile"));
    XCTAssertEqualObjects(tempArray, [NSArray arrayWithContentsOfUserFile:@"tempfile"]);
    XCTAssertTrue(AGXDirectory.document.deleteFile(@"tempfile"));

    XCTAssertTrue(AGXDirectory.document.createFileWithContent(@"tempdir/tempsubdir/tempfile", tempArray));
    XCTAssertTrue(AGXDirectory.document.directoryExists(@"tempdir/tempsubdir"));
    XCTAssertTrue(AGXDirectory.document.fileExists(@"tempdir/tempsubdir/tempfile"));
    XCTAssertEqualObjects(tempArray, AGXDirectory.document.contentOfFile(@"tempdir/tempsubdir/tempfile"));
    XCTAssertTrue(AGXDirectory.document.deleteDirectory(@"tempdir"));

    XCTAssertTrue(AGXDirectory.document.createFileWithContent(@"tempfile", tempArray));
    XCTAssertTrue(AGXDirectory.document.fileExists(@"tempfile"));
    XCTAssertEqualObjects(tempArray, AGXDirectory.document.contentOfFile(@"tempfile"));
    XCTAssertTrue(AGXDirectory.document.deleteFile(@"tempfile"));
}

@end
