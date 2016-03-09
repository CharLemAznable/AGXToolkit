//
//  NSDictionaryAGXCoreTest.m
//  AGXCore
//
//  Created by Char Aznable on 16/2/5.
//  Copyright © 2016年 AI-CUC-EC. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "AGXCore.h"

@interface NSDictionaryAGXCoreTest : XCTestCase

@end

@implementation NSDictionaryAGXCoreTest

- (void)testNSDictionaryAGXCore {
    NSDictionary *dict = @{@"AAA":@"aaa", @"BBB":@"bbb", @"CCC":@"ccc"};
    NSDictionary *dictCopy = [dict deepCopy];
    NSDictionary *dictMutableCopy = [dict deepMutableCopy];
    
    XCTAssertEqualObjects(dict, dictCopy);
    XCTAssertEqualObjects(dict, dictMutableCopy);
    XCTAssertNotEqual([dict objectForKey:@"AAA"], [dictCopy objectForKey:@"AAA"]);
    XCTAssertNotEqual([dict objectForKey:@"AAA"], [dictMutableCopy objectForKey:@"AAA"]);
    XCTAssertTrue([dictMutableCopy isKindOfClass:[NSMutableDictionary class]]);
    
    NSObject *nilObject = nil;
    XCTAssertNil(dict[nilObject]);
    XCTAssertEqualObjects([dict objectForKey:nilObject defaultValue:@"bbb"], @"bbb");
    ((NSMutableDictionary *)dictMutableCopy)[[nilObject description]] = @"bbb";
    XCTAssertNil(dict[nilObject]);
    [((NSMutableDictionary *)dictMutableCopy) setObject:nilObject forKey:@"AAA"];
    XCTAssertNil(dictMutableCopy[@"AAA"]);
    XCTAssertEqualObjects([dictMutableCopy objectForKey:@"AAA" defaultValue:@"bbb"], @"bbb");
    ((NSMutableDictionary *)dictMutableCopy)[@"BBB"] = nilObject;
    XCTAssertNil(dictMutableCopy[@"BBB"]);
    XCTAssertEqualObjects([dictMutableCopy objectForKey:@"BBB" defaultValue:@"ccc"], @"ccc");
    [((NSMutableDictionary *)dictMutableCopy) removeObjectForKey:@"CCC"];
    XCTAssertNil(dictMutableCopy[@"CCC"]);
    XCTAssertEqualObjects([dictMutableCopy objectForKey:@"CCC" defaultValue:@"ddd"], @"ddd");
}

- (void)testNSDictionaryAGXCoreSafe {
    NSString *nilStr = nil;
    
    NSDictionary *dict = @{@"Nil":nilStr, nilStr:@"Nil",
                           @"AAA":@"aaa", @"BBB":@"bbb", @"CCC":@"ccc",
                           [NSNull null]:@"nil", @"nil":[NSNull null]};
    XCTAssertNil([dict objectForKey:nilStr]);
    XCTAssertNil(dict[nilStr]);
    XCTAssertEqualObjects([dict objectForKey:nilStr defaultValue:@"bbb"], @"bbb");
    XCTAssertNotNil([dict objectForKey:[NSNull null]]);
    XCTAssertNotNil(dict[[NSNull null]]);
    XCTAssertEqualObjects([dict objectForKey:[NSNull null] defaultValue:@"bbb"], @"nil");
    XCTAssertNotNil([dict objectForKey:@"nil"]);
    XCTAssertNotNil(dict[@"nil"]);
    XCTAssertEqualObjects([dict objectForKey:@"nil" defaultValue:@"bbb"], @"bbb");
    
    NSMutableDictionary *dictMutable = [dict mutableCopy];
    XCTAssertNil([dictMutable objectForKey:nilStr]);
    XCTAssertNil(dictMutable[nilStr]);
    XCTAssertEqualObjects([dictMutable objectForKey:nilStr defaultValue:@"bbb"], @"bbb");
    XCTAssertNotNil([dictMutable objectForKey:[NSNull null]]);
    XCTAssertNotNil(dictMutable[[NSNull null]]);
    XCTAssertEqualObjects([dictMutable objectForKey:[NSNull null] defaultValue:@"bbb"], @"nil");
    XCTAssertNotNil([dictMutable objectForKey:@"nil"]);
    XCTAssertNotNil(dictMutable[@"nil"]);
    XCTAssertEqualObjects([dictMutable objectForKey:@"nil" defaultValue:@"bbb"], @"bbb");
    
    [dictMutable setObject:@"ccc" forKey:nilStr];
    XCTAssertNil([dictMutable objectForKey:nilStr]);
    XCTAssertNil(dictMutable[nilStr]);
    XCTAssertEqualObjects([dictMutable objectForKey:nilStr defaultValue:@"bbb"], @"bbb");
    dictMutable[nilStr] = @"ccc";
    XCTAssertNil([dictMutable objectForKey:nilStr]);
    XCTAssertNil(dictMutable[nilStr]);
    XCTAssertEqualObjects([dictMutable objectForKey:nilStr defaultValue:@"bbb"], @"bbb");
    [dictMutable setObject:@"ccc" forKey:[NSNull null]];
    XCTAssertNotNil([dictMutable objectForKey:[NSNull null]]);
    XCTAssertNotNil(dictMutable[[NSNull null]]);
    XCTAssertEqualObjects([dictMutable objectForKey:[NSNull null] defaultValue:@"bbb"], @"ccc");
    dictMutable[[NSNull null]] = @"ccc";
    XCTAssertNotNil([dictMutable objectForKey:[NSNull null]]);
    XCTAssertNotNil(dictMutable[[NSNull null]]);
    XCTAssertEqualObjects([dictMutable objectForKey:[NSNull null] defaultValue:@"bbb"], @"ccc");
    
    [dictMutable setObject:nilStr forKey:@"BBB"];
    XCTAssertNil([dictMutable objectForKey:@"BBB"]);
    XCTAssertNil(dictMutable[@"BBB"]);
    XCTAssertEqualObjects([dictMutable objectForKey:@"BBB" defaultValue:@"ccc"], @"ccc");
    dictMutable[@"CCC"] = nilStr;
    XCTAssertNil([dictMutable objectForKey:@"CCC"]);
    XCTAssertNil(dictMutable[@"CCC"]);
    XCTAssertEqualObjects([dictMutable objectForKey:@"CCC" defaultValue:@"ddd"], @"ddd");
    [dictMutable setObject:[NSNull null] forKey:@"AAA"];
    XCTAssertNotNil([dictMutable objectForKey:@"AAA"]);
    XCTAssertNotNil(dictMutable[@"AAA"]);
    XCTAssertEqualObjects([dictMutable objectForKey:@"AAA" defaultValue:@"bbb"], @"bbb");
    dictMutable[@"AAA"] = [NSNull null];
    XCTAssertNotNil([dictMutable objectForKey:@"AAA"]);
    XCTAssertNotNil(dictMutable[@"AAA"]);
    XCTAssertEqualObjects([dictMutable objectForKey:@"AAA" defaultValue:@"bbb"], @"bbb");
}

- (void)testNSDictionaryAGXCoreDirectory {
    XCTAssertFalse([AGXDirectory fileExists:@"dictionaryfile.plist"]);
    XCTAssertNil([NSDictionary dictionaryWithContentsOfUserFile:@"dictionaryfile.plist"]);
    NSDictionary *dict1 = @{@"AAA":@"aaa"};
    [dict1 writeToUserFile:@"dictionaryfile.plist"];
    XCTAssertTrue([AGXDirectory fileExists:@"dictionaryfile.plist"]);
    NSDictionary *dict2 = [NSDictionary dictionaryWithContentsOfUserFile:@"dictionaryfile.plist"];
    XCTAssertEqualObjects(dict1, dict2);
    XCTAssertTrue([AGXDirectory deleteFile:@"dictionaryfile.plist"]);
}

@end
