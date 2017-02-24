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
    XCTAssertEqual(@"15".unsignedIntegerValue, 15);
    AGX_CLANG_Diagnostic
    (-Wimplicitly-unsigned-literal,
     XCTAssertEqual(@"9223372036854775808".unsignedIntegerValue, 9223372036854775808);
     )

    NSDictionary *dict = @{@"properties":@{@"0":@"name"}, @"last name":@"Doe", @"first name":@"John"};
    NSString *parametric = @"He's ${properties.0} is ${first name}·${last name}.";
    XCTAssertEqualObjects([parametric parametricStringWithObject:dict], @"He's name is John·Doe.");

    NSArray *array = @[@1, @"is", @"name"];
    XCTAssertTrue([@"He's name is John·Doe. 1" containsAllOfStringInArray:array]);

    NSString *oriString = @"Lorem<==>ipsum=dolar>=<sit<>amet.";
    XCTAssertEqualObjects([oriString stringByReplacingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"=><"] withString:@" " mergeContinuous:NO], @"Lorem    ipsum dolar   sit  amet.");
    XCTAssertEqualObjects([oriString stringByReplacingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"=><"] withString:@" " mergeContinuous:YES], @"Lorem ipsum dolar sit amet.");
    XCTAssertEqualObjects([oriString stringByReplacingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"=><"] withString:@"" mergeContinuous:NO], @"Loremipsumdolarsitamet.");

    NSString *urlParam = @"key1=value2&key2==value1&key3value3&&key4=&=value4";
    NSDictionary *urlParamDict = [urlParam dictionarySeparatedByString:@"&"
                                             keyValueSeparatedByString:@"=" filterEmpty:YES];
    XCTAssertEqual(urlParamDict.count, 2);
    XCTAssertEqualObjects(urlParamDict[@"key1"], @"value2");
    XCTAssertEqualObjects(urlParamDict[@"key2"], @"=value1");
    XCTAssertNil(urlParamDict[@"key3"]);
    XCTAssertNil(urlParamDict[@"key4"]);

    NSComparator positive = ^NSComparisonResult(id key1, id key2) { return [key1 compare:key2 options:NSNumericSearch]; };
    NSComparator negative = ^NSComparisonResult(id key1, id key2) { return -[key1 compare:key2 options:NSNumericSearch]; };
    XCTAssertEqualObjects(@"key1=value2&key2==value1", [NSString stringWithDictionary:urlParamDict joinedByString:@"&" keyValueJoinedByString:@"=" usingKeysComparator:positive filterEmpty:YES]);
    XCTAssertEqualObjects(@"key2==value1&key1=value2", [NSString stringWithDictionary:urlParamDict joinedByString:@"&" keyValueJoinedByString:@"=" usingKeysComparator:negative filterEmpty:YES]);

    XCTAssertEqualObjects(parametric, [[parametric AES256EncryptedStringUsingKey:@"john"] AES256DecryptedStringUsingKey:@"john"]);
    XCTAssertEqualObjects(oriString, [[oriString AES256EncryptedStringUsingKey:@"123"] AES256DecryptedStringUsingKey:@"123"]);
    XCTAssertEqualObjects(urlParam, [[urlParam AES256EncryptedStringUsingKey:@"Q*1_3@c!4kd^j&g%"] AES256DecryptedStringUsingKey:@"Q*1_3@c!4kd^j&g%"]);
}

- (void)testNSStringCaseInsensitive {
    NSString *tempStr = @"123a456A789";
    NSArray *components = [tempStr componentsSeparatedByCaseInsensitiveString:@"a"];
    XCTAssertEqual(3, components.count);
    XCTAssertEqualObjects(@"123", components[0]);
    XCTAssertEqualObjects(@"456", components[1]);
    XCTAssertEqualObjects(@"789", components[2]);

    NSString *urlParam = @"key1abcvalue2xyzkey2ABCAbcvalue1XYZkey3value3XyZxYzkey4aBcxYZAbCvalue4";
    NSDictionary *urlParamDict = [urlParam dictionarySeparatedByCaseInsensitiveString:@"xyz"
                                             keyValueSeparatedByCaseInsensitiveString:@"abc" filterEmpty:YES];
    XCTAssertEqual(urlParamDict.count, 2);
    XCTAssertEqualObjects(urlParamDict[@"key1"], @"value2");
    XCTAssertEqualObjects(urlParamDict[@"key2"], @"Abcvalue1");
    XCTAssertNil(urlParamDict[@"key3"]);
    XCTAssertNil(urlParamDict[@"key4"]);
}

@end
