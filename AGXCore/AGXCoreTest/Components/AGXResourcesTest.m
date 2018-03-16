//
//  AGXResourcesTest.m
//  AGXCoreTest
//
//  Created by Char Aznable on 2018/3/14.
//  Copyright © 2018年 AI-CUC-EC. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "AGXCore.h"

@interface AGXResourcesTest : XCTestCase

@end

@implementation AGXResourcesTest

- (void)testDirectory {
    XCTAssertFalse(AGXResources.document.isExistsDirectoryNamed(@"tempdir"));
    XCTAssertTrue(AGXResources.document.createDirectoryNamed(@"tempdir"));
    XCTAssertTrue(AGXResources.document.isExistsDirectoryNamed(@"tempdir"));
    XCTAssertFalse(AGXResources.document.isExistsPlistNamed(@"tempdir/tempsubdir/tempfile"));

    NSArray *tempArray = @[@"AAA", @"BBB", @"CCC"];

    XCTAssertTrue(AGXResources.document.subpathAs(@"tempdir/tempsubdir").writeArrayWithPlistNamed(@"tempfile", tempArray));
    XCTAssertTrue(AGXResources.document.isExistsDirectoryNamed(@"tempdir/tempsubdir"));
    XCTAssertTrue(AGXResources.document.isExistsPlistNamed(@"tempdir/tempsubdir/tempfile"));
    XCTAssertEqualObjects(tempArray, AGXResources.document.arrayWithPlistNamed(@"tempdir/tempsubdir/tempfile"));
    XCTAssertTrue(AGXResources.document.deleteDirectoryNamed(@"tempdir"));

    XCTAssertTrue(AGXResources.document.writeArrayWithPlistNamed(@"tempdir/tempsubdir/tempfile", tempArray));
    XCTAssertTrue(AGXResources.document.isExistsDirectoryNamed(@"tempdir/tempsubdir"));
    XCTAssertTrue(AGXResources.document.isExistsPlistNamed(@"tempdir/tempsubdir/tempfile"));
    XCTAssertEqualObjects(tempArray, AGXResources.document.arrayWithPlistNamed(@"tempdir/tempsubdir/tempfile"));
    XCTAssertTrue(AGXResources.document.deleteDirectoryNamed(@"tempdir"));

    XCTAssertTrue(AGXResources.document.writeArrayWithPlistNamed(@"tempfile", tempArray));
    XCTAssertTrue(AGXResources.document.isExistsPlistNamed(@"tempfile"));
    XCTAssertEqualObjects(tempArray, AGXResources.document.arrayWithPlistNamed(@"tempfile"));
    XCTAssertTrue(AGXResources.document.deletePlistNamed(@"tempfile"));

    XCTAssertTrue(AGXResources.document.writeContentWithFileNamed(@"tempdir/tempsubdir/tempfile", tempArray));
    XCTAssertTrue(AGXResources.document.isExistsDirectoryNamed(@"tempdir/tempsubdir"));
    XCTAssertTrue(AGXResources.document.isExistsFileNamed(@"tempdir/tempsubdir/tempfile"));
    XCTAssertEqualObjects(tempArray, AGXResources.document.contentWithFileNamed(@"tempdir/tempsubdir/tempfile"));
    XCTAssertTrue(AGXResources.document.deleteDirectoryNamed(@"tempdir"));

    XCTAssertTrue(AGXResources.document.writeContentWithFileNamed(@"tempfile", tempArray));
    XCTAssertTrue(AGXResources.document.isExistsFileNamed(@"tempfile"));
    XCTAssertEqualObjects(tempArray, AGXResources.document.contentWithFileNamed(@"tempfile"));
    XCTAssertTrue(AGXResources.document.deleteFileNamed(@"tempfile"));

    XCTAssertTrue(AGXResources.document.writeStringWithFileNamed(@"tempfile", @"ASDFGHJKL", NSUTF8StringEncoding));
    XCTAssertTrue(AGXResources.document.isExistsFileNamed(@"tempfile"));
    XCTAssertEqualObjects(@"ASDFGHJKL", AGXResources.document.stringWithFileNamed(@"tempfile", NSUTF8StringEncoding));
    XCTAssertTrue(AGXResources.document.deleteFileNamed(@"tempfile"));

    XCTAssertNotNil(AGXResources.document.bundle);
}

- (void)testBundle {
    XCTAssertEqualObjects(AGXResources.application.path, [NSBundle bundleForClass:AGXResources.class].resourcePath);
    XCTAssertEqualObjects(AGXResources.application.pathWithBundleNamed(@"AGXResourcesTest"), [[NSBundle bundleForClass:AGXResources.class] pathForResource:@"AGXResourcesTest" ofType:@"bundle"]);
    XCTAssertEqualObjects(AGXResources.application.subpathAppendBundleNamed(@"AGXResourcesTest").pathWithLprojNamed(@"en"), [[NSBundle bundleWithPath:[[NSBundle bundleForClass:AGXResources.class] pathForResource:@"AGXResourcesTest" ofType:@"bundle"]] pathForResource:@"en" ofType:@"lproj"]);

    XCTAssertTrue(AGXResources.application.isExistsBundleNamed(@"AGXResourcesTest"));

    XCTAssertThrows(AGXResources.application.subpathAppendBundleNamed(@"AGXResourcesTest").createDirectoryNamed(@"en.lproj"));
    XCTAssertThrows(AGXResources.application.subpathAppendBundleNamed(@"AGXResourcesTest").deleteDirectoryNamed(@"en.lproj"));
}

@end
