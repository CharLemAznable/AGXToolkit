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
    XCTAssertTrue(AGXIsEmpty(AGXLocalization.supportedLanguages));
    XCTAssertEqualObjects(AGXLocalization.localizedString(@"Group"), @"Group");
    XCTAssertEqualObjects(AGXLocalization.localizedStringDefault(@"Group", @"Unknown"), @"Unknown");

    AGXLocalization *localization = AGXLocalization
    .bundleNameAs(@"AGXLocalizationTest").tableNameAs(@"Root");

    XCTAssertEqual(localization.supportedLanguages.count, 3);
    XCTAssertEqualObjects(localization.languageAs(@"en").localizedString(@"Group"), @"Group");
    XCTAssertEqualObjects(localization.languageAs(@"zh-Hans").localizedString(@"Group"), @"组织");
    XCTAssertEqualObjects(localization.languageAs(@"zh-Hant").localizedString(@"Group"), @"組織");

    localization.languageAs(nil);
    XCTAssertEqualObjects(localization.localizedString(@"Group"), @"Group");
    XCTAssertEqualObjects(localization.localizedString(@"Name"), @"Name");
    XCTAssertEqualObjects(localization.localizedString(@"none given"), @"none given");
    XCTAssertEqualObjects(localization.localizedString(@"Enabled"), @"Enabled");

    AGXLocalization.defaultLanguage = @"en";
    XCTAssertEqualObjects(localization.localizedString(@"Group"), @"Group");
    XCTAssertEqualObjects(localization.localizedString(@"Name"), @"Name");
    XCTAssertEqualObjects(localization.localizedString(@"none given"), @"none given");
    XCTAssertEqualObjects(localization.localizedString(@"Enabled"), @"Enabled");

    AGXLocalization.defaultLanguage = @"zh-Hans";
    XCTAssertEqualObjects(localization.localizedString(@"Group"), @"组织");
    XCTAssertEqualObjects(localization.localizedString(@"Name"), @"名称");
    XCTAssertEqualObjects(localization.localizedString(@"none given"), @"未定义");
    XCTAssertEqualObjects(localization.localizedString(@"Enabled"), @"有效");

    AGXLocalization.defaultLanguage = @"zh-Hant";
    XCTAssertEqualObjects(localization.localizedString(@"Group"), @"組織");
    XCTAssertEqualObjects(localization.localizedString(@"Name"), @"名稱");
    XCTAssertEqualObjects(localization.localizedString(@"none given"), @"未定義");
    XCTAssertEqualObjects(localization.localizedString(@"Enabled"), @"有效");

    NSString *zh_Hans = AGXResources.application.subpathAppendBundleNamed(@"AGXLocalizationTest").subpathAppendLprojNamed(@"zh-Hans").stringWithFileNamed(@"Root.strings", NSUTF8StringEncoding);
    NSString *zh_Hant = AGXResources.application.subpathAppendBundleNamed(@"AGXLocalizationTest").subpathAppendLprojNamed(@"zh-Hant").stringWithFileNamed(@"Root.strings", NSUTF8StringEncoding);

    AGXResources.document.subpathAppendBundleNamed(@"AGXLocalizationTest").subpathAppendLprojNamed(@"zh-Hans").writeStringWithFileNamed(@"Root.strings", zh_Hant, NSUTF8StringEncoding);
    AGXResources.document.subpathAppendBundleNamed(@"AGXLocalizationTest").subpathAppendLprojNamed(@"zh-Hant").writeStringWithFileNamed(@"Root.strings", zh_Hans, NSUTF8StringEncoding);

    AGXLocalization.defaultLanguage = @"zh-Hans";
    XCTAssertEqualObjects(localization.localizedString(@"Group"), @"組織");
    XCTAssertEqualObjects(localization.localizedString(@"Name"), @"名稱");
    XCTAssertEqualObjects(localization.localizedString(@"none given"), @"未定義");
    XCTAssertEqualObjects(localization.localizedString(@"Enabled"), @"有效");

    AGXLocalization.defaultLanguage = @"zh-Hant";
    XCTAssertEqualObjects(localization.localizedString(@"Group"), @"组织");
    XCTAssertEqualObjects(localization.localizedString(@"Name"), @"名称");
    XCTAssertEqualObjects(localization.localizedString(@"none given"), @"未定义");
    XCTAssertEqualObjects(localization.localizedString(@"Enabled"), @"有效");

    AGXResources.document.removeBundleNamed(@"AGXLocalizationTest");

    AGXLocalization.defaultLanguage = @"jp";
    XCTAssertEqualObjects(localization.localizedString(@"Group"), @"Group");
    XCTAssertEqualObjects(localization.localizedString(@"Name"), @"Name");
    XCTAssertEqualObjects(localization.localizedString(@"none given"), @"none given");
    XCTAssertEqualObjects(localization.localizedString(@"Enabled"), @"Enabled");

    localization = AGXLocalization
    .bundleNameAs(@"AGXLocalizationNone").tableNameAs(@"Root");
    XCTAssertEqual(localization.supportedLanguages.count, 0);
    XCTAssertEqualObjects(localization.localizedString(@"Group"), @"Group");
    XCTAssertEqualObjects(localization.languageAs(@"en").localizedString(@"Group"), @"Group");
    XCTAssertEqualObjects(localization.languageAs(@"zh-Hans").localizedString(@"Group"), @"Group");
    XCTAssertEqualObjects(localization.languageAs(@"zh-Hant").localizedString(@"Group"), @"Group");
    XCTAssertEqualObjects(localization.languageAs(@"jp").localizedString(@"Group"), @"Group");
}

@end
