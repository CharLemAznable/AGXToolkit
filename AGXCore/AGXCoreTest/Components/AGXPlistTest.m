//
//  AGXPlistTest.m
//  AGXCore
//
//  Created by Char Aznable on 16/4/27.
//  Copyright © 2016年 AI-CUC-EC. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "AGXPlist.h"

@interface AGXPlistTest : XCTestCase

@end

@implementation AGXPlistTest

- (void)testAGXPlist {
    NSDictionary *dict = @{@"AAA":@"aaa", @"BBB":@"bbb", @"CCC":@"ccc"};
    NSString *dictPlist = [AGXPlist plistStringFromObject:dict];
    XCTAssertEqualObjects([AGXPlist objectFromPlistString:dictPlist], dict);
}

@end
