//
//  AGXJsonTest.m
//  AGXJson
//
//  Created by Char Aznable on 16/2/19.
//  Copyright © 2016年 AI-CUC-EC. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <AGXCore/AGXCore/NSValue+AGXCore.h>
#import "AGXJson.h"

@interface People : NSObject
@property (nonatomic, strong) NSString *name;
@property (nonatomic, assign) int age;
@end
@implementation People
- (BOOL)isEqual:(id)object {
    if (object == self) return YES;
    if (!object || ![object isKindOfClass:[self class]]) return NO;
    return [self isEqualToPeople:object];
}
- (BOOL)isEqualToPeople:(People *)people {
    if (self == people) return YES;
    if (_age != people.age) return NO;
    if (_name == nil && people.name == nil) return YES;
    if (_name == nil || people.name == nil) return NO;
    return [_name isEqualToString:people.name];
}
@end

@interface JsonBean : NSObject
@property (nonatomic, strong) id field1;
@property (nonatomic, strong) NSString *field2;
@property (nonatomic, assign) int field3;
@end
@implementation JsonBean
- (BOOL)isEqual:(id)object {
    if (object == self) return YES;
    if (!object || ![object isKindOfClass:[self class]]) return NO;
    return [self isEqualToJsonBean:object];
}
- (BOOL)isEqualToJsonBean:(JsonBean *)jsonBean {
    if (self == jsonBean) return YES;
    if (_field3 != jsonBean.field3) return NO;
    if (_field1 == nil && jsonBean.field1 == nil &&
        _field2 == nil && jsonBean.field2 == nil) return YES;
    if (_field1 == nil || jsonBean.field1 == nil ||
        _field2 == nil || jsonBean.field2 == nil) return NO;
    return [_field1 isEqual:jsonBean.field1] && [_field2 isEqualToString:jsonBean.field2];
}
@end

typedef struct AGXTestStructBool {
    bool a;
    bool b;
} AGXTestStructBool;
@struct_boxed_interface(AGXTestStructBool)
@struct_boxed_implementation(AGXTestStructBool)

@struct_jsonable_interface(AGXTestStructBool)
@struct_jsonable_implementation(AGXTestStructBool)
- (id)validJsonObjectForAGXTestStructBool {
    AGXTestStructBool v = [self AGXTestStructBoolValue];
    return @{@"a": @(v.a), @"b": @(v.b)};
}
+ (NSValue *)valueWithValidJsonObjectForAGXTestStructBool:(id)jsonObject {
    BOOL a = [[jsonObject objectForKey:@"a"] boolValue];
    BOOL b = [[jsonObject objectForKey:@"b"] boolValue];
    AGXTestStructBool v = {.a = a, .b = b};
    return [NSValue valueWithAGXTestStructBool:v];
}
@end

@interface JsonBean2 : NSObject
@property (nonatomic, strong) NSArray *array;
@end
@implementation JsonBean2
@end

@interface AGXJsonTest : XCTestCase

@end

@implementation AGXJsonTest

- (void)testAGXJson {
    XCTAssertNil([AGXJson jsonStringFromObject:nil]);
    
    NSString *str = @"JSON";
    AGX_USE_JSONKIT = YES;
    XCTAssertEqualObjects([AGXJson jsonStringFromObject:str], @"\"JSON\"");
    AGX_USE_JSONKIT = NO;
    XCTAssertEqualObjects([AGXJson jsonStringFromObject:str], @"JSON");
    
    NSDictionary *dict = @{@"key" : @"KEY", @"value" : @"VALUE"};
    NSString *dictJson = @"{\"key\":\"KEY\",\"value\":\"VALUE\"}";
    XCTAssertEqualObjects([AGXJson jsonStringFromObject:dict], dictJson);
    XCTAssertEqualObjects([AGXJson objectFromJsonString:dictJson], dict);
    
    People *people = [[People alloc] init];
    people.name = @"John";
    people.age = 10;
    NSString *peopleJson = @"{\"name\":\"John\",\"age\":10}";
    XCTAssertEqualObjects([AGXJson jsonStringFromObject:people], peopleJson);
    XCTAssertEqualObjects([AGXJson objectFromJsonString:peopleJson asClass:[People class]], people);
}

- (void)testNSObjectAGXJson {
    AGX_USE_JSONKIT = YES;
    XCTAssertEqualObjects([@"JSON" agxJsonString], @"\"JSON\"");
    AGX_USE_JSONKIT = NO;
    XCTAssertEqualObjects([@"JSON" agxJsonString], @"JSON");
    
    JsonBean *jsonBean = [[JsonBean alloc] initWithValidJsonObject:@{@"field1":@[]}];
    XCTAssertEqualObjects([jsonBean agxJsonStringWithOptions:AGXJsonWriteClassName],
                          @"{\"AGXClassName\":\"JsonBean\",\"field3\":0,\"field1\":[]}");
    
    jsonBean.field1 = [NSNull null];
    XCTAssertEqualObjects([jsonBean agxJsonStringWithOptions:AGXJsonWriteClassName],
                          @"{\"AGXClassName\":\"JsonBean\",\"field3\":0}");
    
    jsonBean.field2 = @"JSON";
    XCTAssertEqualObjects([jsonBean agxJsonStringWithOptions:AGXJsonWriteClassName],
                          @"{\"AGXClassName\":\"JsonBean\",\"field2\":\"JSON\",\"field3\":0}");
    
    jsonBean.field1 = [NSArray array];
    XCTAssertEqualObjects([jsonBean agxJsonStringWithOptions:AGXJsonWriteClassName],
                          @"{\"AGXClassName\":\"JsonBean\",\"field1\":[],\"field2\":\"JSON\",\"field3\":0}");
    
    NSDictionary *dict = @{@"json":jsonBean};
    XCTAssertEqualObjects([dict agxJsonStringWithOptions:AGXJsonWriteClassName],
                          @"{\"json\":{\"AGXClassName\":\"JsonBean\",\"field1\":[],\"field2\":\"JSON\",\"field3\":0}}");
    
    NSArray *array = @[dict];
    XCTAssertEqualObjects([array agxJsonStringWithOptions:AGXJsonWriteClassName],
                          @"[{\"json\":{\"AGXClassName\":\"JsonBean\",\"field1\":[],\"field2\":\"JSON\",\"field3\":0}}]");
    
    NSValue *pointValue = [NSValue valueWithCGPoint:CGPointMake(1, 1)];
    id pointJson = [pointValue validJsonObject];
    NSDictionary *expectDict = @{@"AGXStructName":@"{CGPoint=dd}", @"x":@1, @"y":@1};
    XCTAssertEqualObjects(pointJson, expectDict);
    NSValue *pointValue2 = [NSValue valueWithValidJsonObject:pointJson];
    XCTAssertEqual([pointValue2 CGPointValue].x, 1);
    XCTAssertEqual([pointValue2 CGPointValue].y, 1);
    
    AGXTestStructBool b = {.a = YES, .b = NO};
    NSValue *boolValue = [NSValue valueWithAGXTestStructBool:b];
    id boolJson = [boolValue validJsonObject];
    expectDict = @{@"AGXStructName":@(@encode(AGXTestStructBool)), @"a":@1, @"b":@0};
    XCTAssertEqualObjects(boolJson, expectDict);
    NSValue *boolValue2 = [NSValue valueWithValidJsonObject:boolJson];
    XCTAssertEqual([boolValue2 AGXTestStructBoolValue].a, YES);
    XCTAssertEqual([boolValue2 AGXTestStructBoolValue].b, NO);
    
    JsonBean2 *j2 = [[JsonBean2 alloc] initWithValidJsonObject:
                     @{@"array":@[@{@"AGXStructName":@(@encode(AGXTestStructBool)), @"a":@1, @"b":@0}]}];
    XCTAssertEqual([j2.array[0] AGXTestStructBoolValue].a, YES);
    XCTAssertEqual([j2.array[0] AGXTestStructBoolValue].b, NO);
    
    NSDictionary *d1 = [[NSDictionary alloc] initWithValidJsonObject:
                        @{@"array":@[@{@"AGXStructName":@(@encode(AGXTestStructBool)), @"a":@1, @"b":@0}]}];
    XCTAssertEqual([d1[@"array"][0] AGXTestStructBoolValue].a, YES);
    XCTAssertEqual([d1[@"array"][0] AGXTestStructBoolValue].b, NO);
}

@end
