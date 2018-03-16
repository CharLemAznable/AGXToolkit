//
//  AGXColorSetTest.m
//  AGXCore
//
//  Created by Char Aznable on 2016/2/18.
//  Copyright © 2016年 AI-CUC-EC. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "AGXCore.h"

@interface SimpleSynthesize : NSObject
- (UIColor *)errorColor;
- (UIColor *)blackColor;
- (UIColor *)whiteColor;
@end
@implementation SimpleSynthesize
AGXColorSetSynthesize(nil)
- (UIColor *)errorColor {
    return SimpleSynthesize.agxColorSet.colorForKey(@"errorColor");
}
- (UIColor *)blackColor {
    return SimpleSynthesize.agxColorSet.colorForKey(@"blackColor");
}
- (UIColor *)whiteColor {
    return SimpleSynthesize.agxColorSet.colorForKey(@"whiteColor");
}
@end

@interface BundleSynthesize : NSObject
- (UIColor *)errorColor;
- (UIColor *)blackColor;
- (UIColor *)whiteColor;
@end
@implementation BundleSynthesize
AGXColorSetSynthesize(@"AGXColorSettings.bundle")
- (UIColor *)errorColor {
    return BundleSynthesize.agxColorSet[@"errorColor"];
}
- (UIColor *)blackColor {
    return BundleSynthesize.agxColorSet[@"blackColor"];
}
- (UIColor *)whiteColor {
    return BundleSynthesize.agxColorSet[@"whiteColor"];
}
@end

@interface AGXColorSetTest : XCTestCase

@end

@implementation AGXColorSetTest

- (void)testAGXColorSet {
    AGXColorSet *cs = AGXColorSet.fileNameAs(@"AGXColorSetTest");
    XCTAssertNil(cs[@"errorColor"]);
    XCTAssertEqualObjects(cs[@"blackColor"], [UIColor colorWithRed:0 green:0 blue:0 alpha:1]);
    XCTAssertEqualObjects(cs[@"whiteColor"], [UIColor colorWithRed:1 green:1 blue:1 alpha:1]);
    cs.fileNameAs(@"AGXColorSetTest2");
    XCTAssertNil(cs.colorForKey(@"errorColor"));
    XCTAssertEqualObjects(cs.colorForKey(@"blackColor"), [UIColor colorWithRed:1 green:1 blue:1 alpha:1]);
    XCTAssertEqualObjects(cs.colorForKey(@"whiteColor"), [UIColor colorWithRed:0 green:0 blue:0 alpha:1]);
}

- (void)testAGXColorSetSynthesize {
    [SimpleSynthesize.agxColorSet reload];
    [BundleSynthesize.agxColorSet reload];

    SimpleSynthesize *s = [[SimpleSynthesize alloc] init];
    XCTAssertNil([s errorColor]);
    XCTAssertEqualObjects([s blackColor], [UIColor colorWithRed:0 green:0 blue:0 alpha:1]);
    XCTAssertEqualObjects([s whiteColor], [UIColor colorWithRed:1 green:1 blue:1 alpha:1]);

    BundleSynthesize *b = BundleSynthesize.instance;
    XCTAssertNil([b errorColor]);
    XCTAssertEqualObjects(b.blackColor, [UIColor colorWithRed:1 green:1 blue:1 alpha:1]);
    XCTAssertEqualObjects(b.whiteColor, [UIColor colorWithRed:0 green:0 blue:0 alpha:1]);
}

- (void)testAGXColorSetSynthesize2 {
    AGXResources.temporary.writeDictionaryWithPlistNamed
    (@"SimpleSynthesize", @{@"errorColor": @"0000", @"blackColor": @"FFFFFF", @"whiteColor": @"000000FF"});
    [SimpleSynthesize.agxColorSet reload];
    AGXResources.document.createBundleNamed(@"AGXColorSettings");
    AGXResources.document.subpathAppendBundleNamed(@"AGXColorSettings").writeDictionaryWithPlistNamed
    (@"BundleSynthesize", @{@"errorColor": @"0000", @"blackColor": @"000000", @"whiteColor": @"FFFFFFFF"});
    [BundleSynthesize.agxColorSet reload];

    SimpleSynthesize *s = [[SimpleSynthesize alloc] init];
    XCTAssertNil([s errorColor]);
    XCTAssertEqualObjects([s blackColor], [UIColor colorWithRed:1 green:1 blue:1 alpha:1]);
    XCTAssertEqualObjects([s whiteColor], [UIColor colorWithRed:0 green:0 blue:0 alpha:1]);

    BundleSynthesize *b = BundleSynthesize.instance;
    XCTAssertNil([b errorColor]);
    XCTAssertEqualObjects(b.blackColor, [UIColor colorWithRed:0 green:0 blue:0 alpha:1]);
    XCTAssertEqualObjects(b.whiteColor, [UIColor colorWithRed:1 green:1 blue:1 alpha:1]);

    AGXResources.temporary.deletePlistNamed(@"SimpleSynthesize");
    AGXResources.document.deleteBundleNamed(@"AGXColorSettings");
}

@end
