//
//  AGXLocalizationTest.m
//  AGXCoreTest
//
//  Created by Char Aznable on 2017/12/22.
//  Copyright © 2017年 AI-CUC-EC. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "AGXCore.h"

@interface AGXLocalizationTest : XCTestCase

@end

@implementation AGXLocalizationTest

- (void)testAGXLocalization {
    XCTAssertTrue([AGXLocalization.supportedLanguages isEmpty]);
    XCTAssertEqualObjects(AGXLocalization.localizedString(@"Group"), @"Group");
    XCTAssertEqualObjects(AGXLocalization.localizedStringDefault(@"Group", @"Unknown"), @"Unknown");

    XCTAssertEqual(AGXLocalization.bundleNameAs(@"AGXLocalizationTest").supportedLanguages.count, 3);
    XCTAssertEqualObjects(AGXLocalization.bundleNameAs(@"AGXLocalizationTest").tableNameAs(@"Root")
                          .languageAs(@"en").localizedString(@"Group"), @"Group");
    XCTAssertEqualObjects(AGXLocalization.bundleNameAs(@"AGXLocalizationTest").tableNameAs(@"Root")
                          .languageAs(@"zh-Hans").localizedString(@"Group"), @"组织");
    XCTAssertEqualObjects(AGXLocalization.bundleNameAs(@"AGXLocalizationTest").tableNameAs(@"Root")
                          .languageAs(@"zh-Hant").localizedString(@"Group"), @"組織");
    
    XCTAssertEqualObjects(AGXLocalization.bundleNameAs(@"AGXLocalizationTest")
                          .tableNameAs(@"Root").localizedString(@"Group"), @"Group");
    XCTAssertEqualObjects(AGXLocalization.bundleNameAs(@"AGXLocalizationTest")
                          .tableNameAs(@"Root").localizedString(@"Name"), @"Name");
    XCTAssertEqualObjects(AGXLocalization.bundleNameAs(@"AGXLocalizationTest")
                          .tableNameAs(@"Root").localizedString(@"none given"), @"none given");
    XCTAssertEqualObjects(AGXLocalization.bundleNameAs(@"AGXLocalizationTest")
                          .tableNameAs(@"Root").localizedString(@"Enabled"), @"Enabled");

    AGXLocalization.defaultLanguage = @"en";
    XCTAssertEqualObjects(AGXLocalization.bundleNameAs(@"AGXLocalizationTest")
                          .tableNameAs(@"Root").localizedString(@"Group"), @"Group");
    XCTAssertEqualObjects(AGXLocalization.bundleNameAs(@"AGXLocalizationTest")
                          .tableNameAs(@"Root").localizedString(@"Name"), @"Name");
    XCTAssertEqualObjects(AGXLocalization.bundleNameAs(@"AGXLocalizationTest")
                          .tableNameAs(@"Root").localizedString(@"none given"), @"none given");
    XCTAssertEqualObjects(AGXLocalization.bundleNameAs(@"AGXLocalizationTest")
                          .tableNameAs(@"Root").localizedString(@"Enabled"), @"Enabled");

    AGXLocalization.defaultLanguage = @"zh-Hans";
    XCTAssertEqualObjects(AGXLocalization.bundleNameAs(@"AGXLocalizationTest")
                          .tableNameAs(@"Root").localizedString(@"Group"), @"组织");
    XCTAssertEqualObjects(AGXLocalization.bundleNameAs(@"AGXLocalizationTest")
                          .tableNameAs(@"Root").localizedString(@"Name"), @"名称");
    XCTAssertEqualObjects(AGXLocalization.bundleNameAs(@"AGXLocalizationTest")
                          .tableNameAs(@"Root").localizedString(@"none given"), @"未定义");
    XCTAssertEqualObjects(AGXLocalization.bundleNameAs(@"AGXLocalizationTest")
                          .tableNameAs(@"Root").localizedString(@"Enabled"), @"有效");

    AGXLocalization.defaultLanguage = @"zh-Hant";
    XCTAssertEqualObjects(AGXLocalization.bundleNameAs(@"AGXLocalizationTest")
                          .tableNameAs(@"Root").localizedString(@"Group"), @"組織");
    XCTAssertEqualObjects(AGXLocalization.bundleNameAs(@"AGXLocalizationTest")
                          .tableNameAs(@"Root").localizedString(@"Name"), @"名稱");
    XCTAssertEqualObjects(AGXLocalization.bundleNameAs(@"AGXLocalizationTest")
                          .tableNameAs(@"Root").localizedString(@"none given"), @"未定義");
    XCTAssertEqualObjects(AGXLocalization.bundleNameAs(@"AGXLocalizationTest")
                          .tableNameAs(@"Root").localizedString(@"Enabled"), @"有效");
}

@end
