//
//  AGXColorSetTest.m
//  AGXCore
//
//  Created by Char Aznable on 16/2/18.
//  Copyright © 2016年 AI-CUC-EC. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "AGXCore.h"

@interface SimpleSynthesize : NSObject
- (UIColor *)blackColor;
- (UIColor *)whiteColor;
@end
@implementation SimpleSynthesize
AGXColorSetSynthesize
- (UIColor *)blackColor {
    return SimpleSynthesize.agxColorSet.colorForKey(@"blackColor");
}
- (UIColor *)whiteColor {
    return SimpleSynthesize.agxColorSet.colorForKey(@"whiteColor");
}
@end

@interface BundleSynthesize : NSObject
- (UIColor *)blackColor;
- (UIColor *)whiteColor;
@end
@implementation BundleSynthesize
AGXColorSetSynthesize
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
    XCTAssertEqualObjects(cs[@"blackColor"], [UIColor colorWithRed:0 green:0 blue:0 alpha:1]);
    XCTAssertEqualObjects(cs[@"whiteColor"], [UIColor colorWithRed:1 green:1 blue:1 alpha:1]);
    cs.fileNameAs(@"AGXColorSetTest2");
    XCTAssertEqualObjects(cs.colorForKey(@"blackColor"), [UIColor colorWithRed:1 green:1 blue:1 alpha:1]);
    XCTAssertEqualObjects(cs.colorForKey(@"whiteColor"), [UIColor colorWithRed:0 green:0 blue:0 alpha:1]);
}

- (void)testAGXColorSetSynthesize {
    SimpleSynthesize *s = [[SimpleSynthesize alloc] init];
    XCTAssertEqualObjects([s blackColor], [UIColor colorWithRed:0 green:0 blue:0 alpha:1]);
    XCTAssertEqualObjects([s whiteColor], [UIColor colorWithRed:1 green:1 blue:1 alpha:1]);

    AGXColorSetBundleName = @"AGXColorSettings";
    BundleSynthesize *b = BundleSynthesize.instance;
    XCTAssertEqualObjects(b.blackColor, [UIColor colorWithRed:1 green:1 blue:1 alpha:1]);
    XCTAssertEqualObjects(b.whiteColor, [UIColor colorWithRed:0 green:0 blue:0 alpha:1]);
}

@end
