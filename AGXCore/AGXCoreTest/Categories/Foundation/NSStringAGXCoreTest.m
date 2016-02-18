//
//  NSStringAGXCoreTest.m
//  AGXCore
//
//  Created by Char Aznable on 16/2/5.
//  Copyright © 2016年 AI-CUC-EC. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "AGXCore.h"

@interface NSStringAGXCoreTest : XCTestCase

@end

@implementation NSStringAGXCoreTest

- (void)testNSStringAGXCoreSafe {
    NSString *string = nil;
    const char *cString = [string UTF8String];
    XCTAssert(cString == NULL);
    XCTAssertNil(@(cString));
}

- (void)testNSStringAGXCore {
    NSDictionary *dict = @{@"last name":@"Doe", @"first name":@"John"};
    NSString *parametric = @"He's name is ${first name}·${last name}.";
    XCTAssertEqualObjects([parametric parametricStringWithObject:dict], @"He's name is John·Doe.");
    
    NSArray *array = @[@1, @"is", @"name"];
    XCTAssertTrue([@"He's name is John·Doe. 1" containsAllOfStringInArray:array]);
    
    NSString *oriString = @"Lorem<==>ipsum=dolar>=<sit<>amet.";
    XCTAssertEqualObjects([oriString stringByReplacingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"=><"] withString:@" "], @"Lorem    ipsum dolar   sit  amet.");
    XCTAssertEqualObjects([oriString stringByReplacingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"=><"] withString:@" " mergeContinuous:YES], @"Lorem ipsum dolar sit amet.");
    XCTAssertEqualObjects([oriString stringByReplacingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"=><"] withString:@""], @"Loremipsumdolarsitamet.");
}

@end
