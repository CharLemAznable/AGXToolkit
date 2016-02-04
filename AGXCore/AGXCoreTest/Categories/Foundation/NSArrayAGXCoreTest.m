//
//  NSArrayAGXCoreTest.m
//  AGXCore
//
//  Created by Char Aznable on 16/2/5.
//  Copyright © 2016年 AI-CUC-EC. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "AGXCore.h"

@interface NSArrayAGXCoreTest : XCTestCase

@end

@implementation NSArrayAGXCoreTest

- (void)testNSArrayAGXCore {
    NSArray *array = @[@"AAA"];
    NSArray *arrayCopy = [array deepCopy];
    NSArray *arrayMutableCopy = [array deepMutableCopy];
    
    XCTAssertEqualObjects(array, arrayCopy);
    XCTAssertEqualObjects(array, arrayMutableCopy);
    XCTAssertNotEqual(array[0], arrayCopy[0]);
    XCTAssertNotEqual(array[0], arrayMutableCopy[0]);
    XCTAssertTrue([arrayMutableCopy isKindOfClass:[NSMutableArray class]]);
}

- (void)testNSArrayAGXCoreSafe {
    NSString *nilStr = nil;
    NSArray *array = @[nilStr, @"AAA", [NSNull null]];
    
    XCTAssertNotNil([array objectAtIndex:1]);
    XCTAssertNotNil(array[1]);
    XCTAssertEqualObjects([array objectAtIndex:1 defaultValue:@"BBB"], @"BBB");
    XCTAssertNil([array objectAtIndex:2]);
    XCTAssertNil(array[2]);
    XCTAssertEqualObjects([array objectAtIndex:2 defaultValue:@"BBB"], @"BBB");
    
    NSMutableArray *arrayMutable = [array mutableCopy];
    XCTAssertNotNil([arrayMutable objectAtIndex:1]);
    XCTAssertNotNil(arrayMutable[1]);
    XCTAssertEqualObjects([arrayMutable objectAtIndex:1 defaultValue:@"BBB"], @"BBB");
    XCTAssertNil([arrayMutable objectAtIndex:2]);
    XCTAssertNil(arrayMutable[2]);
    XCTAssertEqualObjects([arrayMutable objectAtIndex:2 defaultValue:@"BBB"], @"BBB");
    NSObject *nilObject = nil;
    arrayMutable[1] = nilObject;
    XCTAssertNil([arrayMutable objectAtIndex:1]);
    XCTAssertNil(arrayMutable[1]);
    arrayMutable[2] = nilObject;
    XCTAssertNil([arrayMutable objectAtIndex:2]);
    XCTAssertNil(arrayMutable[2]);
    arrayMutable[0] = nilObject;
    XCTAssertNil([arrayMutable objectAtIndex:0]);
    XCTAssertNil(arrayMutable[0]);
    XCTAssertEqualObjects([arrayMutable objectAtIndex:0 defaultValue:@"BBB"], @"BBB");
    
    nilObject = [NSNull null];
    arrayMutable[0] = nilObject;
    XCTAssertNotNil([arrayMutable objectAtIndex:0]);
    XCTAssertNotNil(arrayMutable[0]);
    arrayMutable[1] = nilObject;
    XCTAssertNotNil([arrayMutable objectAtIndex:1]);
    XCTAssertNotNil(arrayMutable[1]);
    arrayMutable[2] = nilObject;
    XCTAssertNotNil([arrayMutable objectAtIndex:2]);
    XCTAssertNotNil(arrayMutable[2]);
    XCTAssertEqualObjects([arrayMutable objectAtIndex:0 defaultValue:@"BBB"], @"BBB");
}

- (void)testNSArrayAGXCoreDirectory {
    NSArray *array = @[@"AAA"];
    XCTAssertFalse([AGXDirectory fileExists:@"arrayfile.plist"]);
    [array writeToUserFile:@"arrayfile.plist"];
    XCTAssertTrue([AGXDirectory fileExists:@"arrayfile.plist"]);
    NSArray *array2 = [NSArray arrayWithContentsOfUserFile:@"arrayfile.plist"];
    XCTAssertEqualObjects(array, array2);
    XCTAssertTrue([AGXDirectory deleteAllFiles]);
}

@end
