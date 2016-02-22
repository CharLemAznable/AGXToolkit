//
//  AGXKeychainTest.m
//  AGXData
//
//  Created by Char Aznable on 16/2/22.
//  Copyright © 2016年 AI-CUC-EC. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "AGXData.h"

@interface AGXKeychainTest : XCTestCase

@end

@implementation AGXKeychainTest

- (void)testAGXKeychain {
    NSError *error = nil;
    NSString *password = [AGXKeychain passwordForUsername:@"admin" andService:@"AGXKeychainTest" error:&error];
    XCTAssertNil(password);
    XCTAssertNil(error);
    
    error = nil;
    XCTAssertTrue([AGXKeychain storePassword:@"passwd" forUsername:@"admin" andService:@"AGXKeychainTest" updateExisting:YES error:&error]);
    XCTAssertEqualObjects([AGXKeychain passwordForUsername:@"admin" andService:@"AGXKeychainTest" error:&error], @"passwd");
    XCTAssertNil(error);
    
    error = nil;
    XCTAssertTrue([AGXKeychain deletePasswordForUsername:@"admin" andService:@"AGXKeychainTest" error:&error]);
    XCTAssertNil(error);
    
    error = nil;
    password = [AGXKeychain passwordForUsername:@"admin" andService:@"AGXKeychainTest" error:&error];
    XCTAssertNil(password);
    XCTAssertNil(error);
}

@end
