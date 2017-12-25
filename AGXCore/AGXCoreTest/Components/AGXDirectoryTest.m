//
//  AGXDirectoryTest.m
//  AGXCore
//
//  Created by Char Aznable on 2016/2/5.
//  Copyright © 2016年 AI-CUC-EC. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "AGXCore.h"
#import <objc/runtime.h>

@interface AGXDirectoryTest : XCTestCase

@end

@implementation AGXDirectoryTest

- (void)testAGXDirectory {
    XCTAssertFalse(AGXDirectory.fileExists(@"tempdir"));
    XCTAssertTrue(AGXDirectory.createDirectory(@"tempdir"));
    XCTAssertTrue(AGXDirectory.directoryExists(@"tempdir"));
    XCTAssertFalse(AGXDirectory.plistFileExists(@"tempdir/tempsubdir/tempfile"));

    NSArray *tempArray = @[@"AAA", @"BBB", @"CCC"];

    XCTAssertTrue(AGXDirectory.subpathAs(@"tempdir/tempsubdir").writeToFileWithArray(@"tempfile", tempArray));
    XCTAssertTrue(AGXDirectory.directoryExists(@"tempdir/tempsubdir"));
    XCTAssertTrue(AGXDirectory.plistFileExists(@"tempdir/tempsubdir/tempfile"));
    XCTAssertEqualObjects(tempArray, AGXDirectory.arrayWithFile(@"tempdir/tempsubdir/tempfile"));
    XCTAssertTrue(AGXDirectory.deleteDirectory(@"tempdir"));

    XCTAssertTrue(AGXDirectory.writeToFileWithArray(@"tempdir/tempsubdir/tempfile", tempArray));
    XCTAssertTrue(AGXDirectory.directoryExists(@"tempdir/tempsubdir"));
    XCTAssertTrue(AGXDirectory.plistFileExists(@"tempdir/tempsubdir/tempfile"));
    XCTAssertEqualObjects(tempArray, AGXDirectory.arrayWithFile(@"tempdir/tempsubdir/tempfile"));
    XCTAssertTrue(AGXDirectory.deleteDirectory(@"tempdir"));

    XCTAssertTrue(AGXDirectory.writeToFileWithArray(@"tempfile", tempArray));
    XCTAssertTrue(AGXDirectory.plistFileExists(@"tempfile"));
    XCTAssertEqualObjects(tempArray, AGXDirectory.arrayWithFile(@"tempfile"));
    XCTAssertTrue(AGXDirectory.deletePlistFile(@"tempfile"));

    XCTAssertTrue(AGXDirectory.writeToFileWithContent(@"tempdir/tempsubdir/tempfile", tempArray));
    XCTAssertTrue(AGXDirectory.directoryExists(@"tempdir/tempsubdir"));
    XCTAssertTrue(AGXDirectory.fileExists(@"tempdir/tempsubdir/tempfile"));
    XCTAssertEqualObjects(tempArray, AGXDirectory.contentWithFile(@"tempdir/tempsubdir/tempfile"));
    XCTAssertTrue(AGXDirectory.deleteDirectory(@"tempdir"));

    XCTAssertTrue(AGXDirectory.writeToFileWithContent(@"tempfile", tempArray));
    XCTAssertTrue(AGXDirectory.fileExists(@"tempfile"));
    XCTAssertEqualObjects(tempArray, AGXDirectory.contentWithFile(@"tempfile"));
    XCTAssertTrue(AGXDirectory.deleteFile(@"tempfile"));

    XCTAssertTrue(AGXDirectory.writeToFileWithString(@"tempfile", @"ASDFGHJKL", NSUTF8StringEncoding));
    XCTAssertTrue(AGXDirectory.fileExists(@"tempfile"));
    XCTAssertEqualObjects(@"ASDFGHJKL", AGXDirectory.stringWithFile(@"tempfile", NSUTF8StringEncoding));
    XCTAssertTrue(AGXDirectory.deleteFile(@"tempfile"));
}

@end
