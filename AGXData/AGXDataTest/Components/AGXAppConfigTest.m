//
//  AGXAppConfigTest.m
//  AGXData
//
//  Created by Char Aznable on 2016/2/22.
//  Copyright © 2016年 AI-CUC-EC. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "AGXData.h"

@appconfig_interface(AppConfig, NSObject, shareInstance)
@property (nonatomic, strong) NSString *key;
@property (nonatomic, strong) NSString *key1;
@end
@appconfig_implementation(AppConfig, shareInstance)
@appconfig(AppConfig, key)
@appconfig(AppConfig, key1)
@end

@appconfig_interface(BundleConfig, NSObject, shareInstance)
@property (nonatomic, strong) NSString *key;
@property (nonatomic, strong) NSString *key2;
@end
@appconfig_implementation(BundleConfig, shareInstance)
appconfig_bundle(BundleConfig, @"AGXAppConfig")
appconfig_plistName(@"BundleConfig.dev")
@appconfig(BundleConfig, key)
@appconfig(BundleConfig, key2)
@end

@interface AGXAppConfigTest : XCTestCase

@end

@implementation AGXAppConfigTest

- (void)testAGXAppConfig {
    XCTAssertNil(AppConfig.shareInstance.key);
    XCTAssertEqualObjects(AppConfig.shareInstance.key1, @"value1");
    XCTAssertNil(BundleConfig.shareInstance.key);
    XCTAssertEqualObjects(BundleConfig.shareInstance.key2, @"value2");

    AGXResources.document.writeDictionaryWithPlistNamed(@"AppConfig", @{@"key": @"value", @"key1": @"value11"});
    AGXResources.document.subpathAppendBundleNamed(@"AGXAppConfig").writeDictionaryWithPlistNamed(@"BundleConfig.dev", @{@"key": @"value", @"key2": @"value22"});
    XCTAssertEqualObjects(AppConfig.shareInstance.key, @"value");
    XCTAssertEqualObjects(AppConfig.shareInstance.key1, @"value11");
    XCTAssertEqualObjects(BundleConfig.shareInstance.key, @"value");
    XCTAssertEqualObjects(BundleConfig.shareInstance.key2, @"value22");
    AGXResources.document.removePlistNamed(@"AppConfig");
    AGXResources.document.removeBundleNamed(@"AGXAppConfig");

    XCTAssertNil(AppConfig.shareInstance.key);
    XCTAssertEqualObjects(AppConfig.shareInstance.key1, @"value1");
    XCTAssertNil(BundleConfig.shareInstance.key);
    XCTAssertEqualObjects(BundleConfig.shareInstance.key2, @"value2");
}

@end
