//
//  AGXDataBoxTest.m
//  AGXData
//
//  Created by Char Aznable on 16/2/22.
//  Copyright © 2016年 AI-CUC-EC. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "AGXData.h"

@databox_interface(UserDefaults, NSObject)
@property (nonatomic, strong) NSString *userId;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *version;
@property (nonatomic, strong) NSValue *center;
@property (nonatomic, strong) NSValue *size;
@end

@databox_implementation(UserDefaults)
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
    [UserDefaults shareUserDefaults].userId = @"111";
    [UserDefaults shareUserDefaults].name = @"aaa";
    [UserDefaults shareUserDefaults].version = @"0.0.1";
    [UserDefaults shareUserDefaults].center = [NSValue valueWithCGPoint:CGPointMake(10, 10)];
    [UserDefaults shareUserDefaults].size = [NSValue valueWithCGSize:CGSizeMake(20, 20)];
    XCTAssertEqualObjects([UserDefaults shareUserDefaults].userId, @"111");
    XCTAssertEqualObjects([UserDefaults shareUserDefaults].name, @"aaa");
    XCTAssertEqualObjects([UserDefaults shareUserDefaults].version, @"0.0.1");
    XCTAssertEqual([[UserDefaults shareUserDefaults].center CGPointValue].x, 10);
    XCTAssertEqual([[UserDefaults shareUserDefaults].center CGPointValue].y, 10);
    XCTAssertEqual([[UserDefaults shareUserDefaults].size CGSizeValue].width, 20);
    XCTAssertEqual([[UserDefaults shareUserDefaults].size CGSizeValue].height, 20);
    [[UserDefaults shareUserDefaults] synchronize];
    
    [UserDefaults shareUserDefaults].userId = @"222";
    [UserDefaults shareUserDefaults].name = @"bbb";
    [UserDefaults shareUserDefaults].version = @"0.0.2";
    [UserDefaults shareUserDefaults].center = [NSValue valueWithCGPoint:CGPointMake(40, 40)];
    [UserDefaults shareUserDefaults].size = [NSValue valueWithCGSize:CGSizeMake(30, 30)];
    XCTAssertEqualObjects([UserDefaults shareUserDefaults].userId, @"222");
    XCTAssertEqualObjects([UserDefaults shareUserDefaults].name, @"bbb");
    XCTAssertEqualObjects([UserDefaults shareUserDefaults].version, @"0.0.2");
    XCTAssertEqual([[UserDefaults shareUserDefaults].center CGPointValue].x, 40);
    XCTAssertEqual([[UserDefaults shareUserDefaults].center CGPointValue].y, 40);
    XCTAssertEqual([[UserDefaults shareUserDefaults].size CGSizeValue].width, 30);
    XCTAssertEqual([[UserDefaults shareUserDefaults].size CGSizeValue].height, 30);
    [[UserDefaults shareUserDefaults] synchronize];
    
    [UserDefaults shareUserDefaults].userId = @"111";
    [UserDefaults shareUserDefaults].version = nil;
    XCTAssertEqualObjects([UserDefaults shareUserDefaults].userId, @"111");
    XCTAssertEqualObjects([UserDefaults shareUserDefaults].name, @"aaa");
    XCTAssertNil([UserDefaults shareUserDefaults].version);
    XCTAssertEqual([[UserDefaults shareUserDefaults].center CGPointValue].x, 10);
    XCTAssertEqual([[UserDefaults shareUserDefaults].center CGPointValue].y, 10);
    XCTAssertEqual([[UserDefaults shareUserDefaults].size CGSizeValue].width, 20);
    XCTAssertEqual([[UserDefaults shareUserDefaults].size CGSizeValue].height, 20);
    
    [UserDefaults shareUserDefaults].userId = @"222";
    [UserDefaults shareUserDefaults].name = nil;
    XCTAssertEqualObjects([UserDefaults shareUserDefaults].userId, @"222");
    XCTAssertNil([UserDefaults shareUserDefaults].name);
    XCTAssertEqualObjects([UserDefaults shareUserDefaults].version, @"0.0.2");
    XCTAssertEqual([[UserDefaults shareUserDefaults].center CGPointValue].x, 40);
    XCTAssertEqual([[UserDefaults shareUserDefaults].center CGPointValue].y, 40);
    XCTAssertEqual([[UserDefaults shareUserDefaults].size CGSizeValue].width, 30);
    XCTAssertEqual([[UserDefaults shareUserDefaults].size CGSizeValue].height, 30);
}

@end
