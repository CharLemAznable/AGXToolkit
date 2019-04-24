//
//  AGXDataBoxTest.m
//  AGXData
//
//  Created by Char Aznable on 2016/2/22.
//  Copyright © 2016 github.com/CharLemAznable. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "AGXData.h"

@databox_interface(UserDefaults, NSObject, shareInstance)
@databox_property(UserDefaults, NSString *, userId)
@databox_property(UserDefaults, NSString *, name)
@databox_property(UserDefaults, NSString *, version)
@databox_property(UserDefaults, NSValue *, center)
@databox_property(UserDefaults, NSValue *, size)
@end

@databox_implementation(UserDefaults, shareInstance)
@default_share(UserDefaults, userId)
@keychain_users(UserDefaults, name, userId)
@restrict_users(UserDefaults, version, userId)
@default_users(UserDefaults, center, userId)
@keychain_users(UserDefaults, size, userId)
@end

@interface AGXDataBoxTest : XCTestCase

@end

@implementation AGXDataBoxTest

- (void)testAGXDataBox {
    UserDefaults *userDefaults = UserDefaults.shareInstance;

    userDefaults.userIdAs(@"111").nameAs(@"aaa").versionAs(@"0.0.1");
    userDefaults.centerAs([NSValue valueWithCGPoint:CGPointMake(10, 10)]);
    userDefaults.sizeAs([NSValue valueWithCGSize:CGSizeMake(20, 20)]);
    XCTAssertEqualObjects(userDefaults.userId, @"111");
    XCTAssertEqualObjects(userDefaults.name, @"aaa");
    XCTAssertEqualObjects(userDefaults.version, @"0.0.1");
    XCTAssertEqual(userDefaults.center.CGPointValue.x, 10);
    XCTAssertEqual(userDefaults.center.CGPointValue.y, 10);
    XCTAssertEqual(userDefaults.size.CGSizeValue.width, 20);
    XCTAssertEqual(userDefaults.size.CGSizeValue.height, 20);
    [userDefaults synchronize];

    [userDefaults setDefaultShareObject:@"222" forKey:@"userId"];
    [userDefaults setKeychainUsersObject:@"bbb" forKey:@"name" userId:@"222"];
    [userDefaults setRestrictUsersObject:@"0.0.2" forKey:@"version" userId:@"222"];
    [userDefaults setDefaultUsersObject:[NSValue valueWithCGPoint:CGPointMake(40, 40)]
                                 forKey:@"center" userId:@"222"];
    [userDefaults setKeychainUsersObject:[NSValue valueWithCGSize:CGSizeMake(30, 30)]
                                  forKey:@"size" userId:@"222"];
    [userDefaults setDefaultUsersObject:@"extendValue1" forKey:@"extendKey1" userId:@"222"];
    [userDefaults setKeychainUsersObject:[NSValue valueWithCGVector:CGVectorMake(20, 20)]
                                  forKey:@"extendKey2" userId:@"222"];
    XCTAssertEqualObjects([userDefaults defaultShareObjectForKey:@"userId"], @"222");
    XCTAssertEqualObjects([userDefaults keychainUsersObjectForKey:@"name" userId:@"222"], @"bbb");
    XCTAssertEqualObjects([userDefaults restrictUsersObjectForKey:@"version" userId:@"222"], @"0.0.2");
    NSValue *center = [userDefaults defaultUsersObjectForKey:@"center" userId:@"222"];
    XCTAssertEqual(center.CGPointValue.x, 40);
    XCTAssertEqual(center.CGPointValue.y, 40);
    NSValue *size = [userDefaults keychainUsersObjectForKey:@"size" userId:@"222"];
    XCTAssertEqual(size.CGSizeValue.width, 30);
    XCTAssertEqual(size.CGSizeValue.height, 30);
    XCTAssertEqualObjects([userDefaults defaultUsersObjectForKey:@"extendKey1" userId:@"222"], @"extendValue1");
    NSValue *vector = [userDefaults keychainUsersObjectForKey:@"extendKey2" userId:@"222"];
    XCTAssertEqual(vector.CGVectorValue.dx, 20);
    XCTAssertEqual(vector.CGVectorValue.dy, 20);
    [userDefaults synchronize];

    userDefaults.userIdAs(@"111").versionAs(nil);
    XCTAssertEqualObjects(userDefaults.userId, @"111");
    XCTAssertEqualObjects(userDefaults.name, @"aaa");
    XCTAssertNil(userDefaults.version);
    XCTAssertEqual(userDefaults.center.CGPointValue.x, 10);
    XCTAssertEqual(userDefaults.center.CGPointValue.y, 10);
    XCTAssertEqual(userDefaults.size.CGSizeValue.width, 20);
    XCTAssertEqual(userDefaults.size.CGSizeValue.height, 20);

    [userDefaults setDefaultShareObject:@"222" forKey:@"userId"];
    [userDefaults setKeychainUsersObject:nil forKey:@"name" userId:@"222"];
    XCTAssertEqualObjects([userDefaults defaultShareObjectForKey:@"userId"], @"222");
    XCTAssertNil([userDefaults keychainUsersObjectForKey:@"name" userId:@"222"]);
    XCTAssertEqualObjects([userDefaults restrictUsersObjectForKey:@"version" userId:@"222"], @"0.0.2");
    center = [userDefaults defaultUsersObjectForKey:@"center" userId:@"222"];
    XCTAssertEqual(center.CGPointValue.x, 40);
    XCTAssertEqual(center.CGPointValue.y, 40);
    size = [userDefaults keychainUsersObjectForKey:@"size" userId:@"222"];
    XCTAssertEqual(size.CGSizeValue.width, 30);
    XCTAssertEqual(size.CGSizeValue.height, 30);
    XCTAssertEqualObjects([userDefaults defaultUsersObjectForKey:@"extendKey1" userId:@"222"], @"extendValue1");
    vector = [userDefaults keychainUsersObjectForKey:@"extendKey2" userId:@"222"];
    XCTAssertEqual(vector.CGVectorValue.dx, 20);
    XCTAssertEqual(vector.CGVectorValue.dy, 20);
}

@end
