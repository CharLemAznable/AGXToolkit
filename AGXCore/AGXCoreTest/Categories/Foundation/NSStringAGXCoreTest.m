//
//  NSStringAGXCoreTest.m
//  AGXCore
//
//  Created by Char Aznable on 2016/2/5.
//  Copyright © 2016年 AI-CUC-EC. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "AGXCore.h"

@interface NSStringAGXCoreTest : XCTestCase

@end

@implementation NSStringAGXCoreTest

- (void)testNSStringAGXCoreSafe {
    NSString *string = nil;
    const char *cString = string.UTF8String;
    XCTAssert(cString == NULL);
    XCTAssertNil(@(cString));
}

- (void)testNSStringAGXCore {
    XCTAssertEqual(@"15".unsignedIntegerValue, 15);
    AGX_CLANG_Diagnostic
    (-Wimplicitly-unsigned-literal,
     XCTAssertEqual(@"9223372036854775808".unsignedIntegerValue, 9223372036854775808);)

    XCTAssertEqualObjects
    (@"foo://example.com:8042/over/there/中文?name=参数#nose".stringEncodedForURLComponent,
     @"foo%3A%2F%2Fexample.com%3A8042%2Fover%2Fthere%2F%E4%B8%AD%E6%96%87%3Fname%3D%E5%8F%82%E6%95%B0%23nose");
    XCTAssertEqualObjects
    (@"foo%3A%2F%2Fexample.com%3A8042%2Fover%2Fthere%2F%E4%B8%AD%E6%96%87%3Fname%3D%E5%8F%82%E6%95%B0%23nose".stringDecodedForURL,
     @"foo://example.com:8042/over/there/中文?name=参数#nose");
    XCTAssertEqualObjects
    (@"foo://example.com:8042/over/there/中文?name=参数&name2=%E5%8F%82%E6%95%B0#nose".stringEncodedForURL,
     @"foo://example.com:8042/over/there/%E4%B8%AD%E6%96%87?name=%E5%8F%82%E6%95%B0&name2=%E5%8F%82%E6%95%B0#nose");
    XCTAssertEqualObjects
    (@"foo://example.com:8042/over/there/%E4%B8%AD%E6%96%87?name=%E5%8F%82%E6%95%B0&name2=%E5%8F%82%E6%95%B0#nose"
     .stringDecodedForURL, @"foo://example.com:8042/over/there/中文?name=参数&name2=参数#nose");
    XCTAssertEqualObjects
    ([NSURL URLWithString:@"foo://example.com:8042/over/there/中文?name=参数&name2=%E5%8F%82%E6%95%B0#nose"
      .stringEncodedForURL].absoluteString,
     @"foo://example.com:8042/over/there/%E4%B8%AD%E6%96%87?name=%E5%8F%82%E6%95%B0&name2=%E5%8F%82%E6%95%B0#nose");

    XCTAssertEqualObjects(@"1234567890".base64EncodedString, @"MTIzNDU2Nzg5MA==");
    XCTAssertEqualObjects([NSString stringWithBase64String:@"MTIzNDU2Nzg5MA=="], @"1234567890");

    XCTAssertEqualObjects(@"1234567890".base64URLSafeEncodedString, @"MTIzNDU2Nzg5MA");
    XCTAssertEqualObjects([NSString stringWithBase64URLSafeString:@"MTIzNDU2Nzg5MA"], @"1234567890");

    XCTAssertEqualObjects([@"abc" stringByAppendingObjects:nil], @"abc");
    XCTAssertEqualObjects(([@"abc" stringByAppendingObjects:@"def", @"ghi", nil]), @"abcdefghi");

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

    NSString *nilStr = nil;
    NSDictionary *nilDict = @{@"Nil":nilStr, nilStr:@"Nil",
                              @"AAA":@"aaa", @"BBB":@"bbb", @"CCC":@"ccc",
                              NSNull.null:@"nil", @"nil":NSNull.null};
    NSComparator nilComparator = ^NSComparisonResult(id key1, id key2) { return AGXIsNil(key1)?NSOrderedAscending:AGXIsNil(key2)?NSOrderedDescending:[key1 compare:key2 options:NSNumericSearch]; };
    XCTAssertEqualObjects(@"AAA=aaa&BBB=bbb&CCC=ccc", [NSString stringWithDictionary:nilDict joinedByString:@"&" keyValueJoinedByString:@"=" usingKeysComparator:nilComparator filterEmpty:YES]);
    XCTAssertEqualObjects(@"(null)=nil&AAA=aaa&BBB=bbb&CCC=ccc&nil=(null)", [NSString stringWithDictionary:nilDict joinedByString:@"&" keyValueJoinedByString:@"=" usingKeysComparator:nilComparator filterEmpty:NO]);

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
