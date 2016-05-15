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
    XCTAssertFalse(AGXDirectory.document.plistFileExists(@"tempdir/tempsubdir/tempfile"));

    NSArray *tempArray = @[@"AAA", @"BBB", @"CCC"];

    XCTAssertTrue(AGXDirectory.document.inSubpath(@"tempdir/tempsubdir").writeToFileWithArray(@"tempfile", tempArray));
    XCTAssertTrue(AGXDirectory.document.directoryExists(@"tempdir/tempsubdir"));
    XCTAssertTrue(AGXDirectory.document.plistFileExists(@"tempdir/tempsubdir/tempfile"));
    XCTAssertEqualObjects(tempArray, AGXDirectory.document.arrayWithFile(@"tempdir/tempsubdir/tempfile"));
    XCTAssertTrue(AGXDirectory.document.deleteDirectory(@"tempdir"));

    XCTAssertTrue(AGXDirectory.document.writeToFileWithArray(@"tempdir/tempsubdir/tempfile", tempArray));
    XCTAssertTrue(AGXDirectory.document.directoryExists(@"tempdir/tempsubdir"));
    XCTAssertTrue(AGXDirectory.document.plistFileExists(@"tempdir/tempsubdir/tempfile"));
    XCTAssertEqualObjects(tempArray, AGXDirectory.document.arrayWithFile(@"tempdir/tempsubdir/tempfile"));
    XCTAssertTrue(AGXDirectory.document.deleteDirectory(@"tempdir"));

    XCTAssertTrue(AGXDirectory.document.writeToFileWithArray(@"tempfile", tempArray));
    XCTAssertTrue(AGXDirectory.document.plistFileExists(@"tempfile"));
    XCTAssertEqualObjects(tempArray, AGXDirectory.document.arrayWithFile(@"tempfile"));
    XCTAssertTrue(AGXDirectory.document.deletePlistFile(@"tempfile"));

    XCTAssertTrue(AGXDirectory.document.writeToFileWithContent(@"tempdir/tempsubdir/tempfile", tempArray));
    XCTAssertTrue(AGXDirectory.document.directoryExists(@"tempdir/tempsubdir"));
    XCTAssertTrue(AGXDirectory.document.fileExists(@"tempdir/tempsubdir/tempfile"));
    XCTAssertEqualObjects(tempArray, AGXDirectory.document.contentWithFile(@"tempdir/tempsubdir/tempfile"));
    XCTAssertTrue(AGXDirectory.document.deleteDirectory(@"tempdir"));

    XCTAssertTrue(AGXDirectory.document.writeToFileWithContent(@"tempfile", tempArray));
    XCTAssertTrue(AGXDirectory.document.fileExists(@"tempfile"));
    XCTAssertEqualObjects(tempArray, AGXDirectory.document.contentWithFile(@"tempfile"));
    XCTAssertTrue(AGXDirectory.document.deleteFile(@"tempfile"));
}

@end
