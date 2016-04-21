//
//  AGXJSONKitTest.m
//  AGXJson
//
//  Created by Char Aznable on 16/2/19.
//  Copyright © 2016年 AI-CUC-EC. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "AGXJSONKit.h"

@interface JSONDemoBean : NSObject
@property (nonatomic, strong) NSString *desc;
@end
@implementation JSONDemoBean
- (NSString *)description {
    return [NSString stringWithFormat:@"JSONDemoBean:%@", _desc];
}
@end

@interface AGXJSONKitTest : XCTestCase

@end

@implementation AGXJSONKitTest

- (void)testAGXJSONKit {
    XCTAssertEqualObjects([@"Hello, World!" JSONString], @"\"Hello, World!\"");
    XCTAssertNil([@"\"Hello, World!\"" objectFromJSONString]);

    NSArray *array = @[@"AAA", @"BBB"];
    XCTAssertEqualObjects([array JSONString], @"[\"AAA\",\"BBB\"]");
    XCTAssertEqualObjects([@"[\"AAA\",\"BBB\"]" objectFromJSONString], array);

    NSDictionary *dict = @{@"1":@"AAA", @"2":@"BBB"};
    XCTAssertEqualObjects([dict JSONString], @"{\"1\":\"AAA\",\"2\":\"BBB\"}");
    XCTAssertEqualObjects([@"{\"1\":\"AAA\", \"2\":\"BBB\"}" objectFromJSONString], dict);

    NSDictionary *dict2 = @{@1:@"AAA", @2:@"BBB"};
    NSError *error;
    XCTAssertNil([dict2 JSONStringWithOptions:0 error:&error]);
    XCTAssertEqualObjects(error.domain, @"JKErrorDomain");
    XCTAssertEqual(error.code, -1);
    XCTAssertEqualObjects(error.userInfo[NSLocalizedDescriptionKey], @"Key must be a string object.");

    JSONDemoBean *demo = [[JSONDemoBean alloc] init];
    demo.desc = @"JSON";
    NSDictionary *dict3 = @{@"1":@"AAA", @"2":demo};
    XCTAssertNil([dict3 JSONStringWithOptions:0 error:&error]);
    XCTAssertEqualObjects(error.userInfo[NSLocalizedDescriptionKey], @"Unable to serialize object class JSONDemoBean.");
    XCTAssertEqualObjects([dict3 JSONStringWithOptions:0 serializeUnsupportedClassesUsingBlock:^id(id object) {
        return([object isKindOfClass:[JSONDemoBean class]]?[object desc]:[NSString stringWithFormat:@"%@", object]);
    } error:NULL], @"{\"1\":\"AAA\",\"2\":\"JSON\"}");
}

@end
