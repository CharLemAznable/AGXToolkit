//
//  NSDictionaryAGXCoreTest.m
//  AGXCore
//
//  Created by Char Aznable on 2016/2/5.
//  Copyright © 2016 github.com/CharLemAznable. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "AGXCore.h"

@interface DictionaryItem : NSObject <NSCoding, NSMutableCopying>
@property (nonatomic, AGX_STRONG) NSString *name;
@end
@implementation DictionaryItem
- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super init]) {
        _name = AGX_RETAIN([aDecoder decodeObjectOfClass:NSString.class forKey:@"name"]);
    }
    return self;
}
- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:_name forKey:@"name"];
}
- (id)mutableCopyWithZone:(NSZone *)zone {
    DictionaryItem *copy = [[DictionaryItem allocWithZone:zone] init];
    copy.name = [_name mutableCopy];
    return copy;
}
- (void)dealloc {
    AGX_RELEASE(_name);
    AGX_SUPER_DEALLOC;
}
- (BOOL)isEqual:(id)object {
    if (object == self) return YES;
    if (!object || ![object isKindOfClass:DictionaryItem.class]) return NO;
    return [self isEqualToDictionaryItem:object];
}
- (BOOL)isEqualToDictionaryItem:(DictionaryItem *)item {
    if (item == self) return YES;
    return [self.name isEqualToString:item.name];
}
@end

@interface NSDictionaryAGXCoreTest : XCTestCase

@end

@implementation NSDictionaryAGXCoreTest

- (void)testNSDictionaryAGXCore {
    DictionaryItem *item = DictionaryItem.instance;
    item.name = @"ddd";
    NSDictionary *dict = @{@"AAA":@"aaa", @"BBB":@"bbb", @"CCC":@"ccc", @"DDD":@{@"d":@"ddd"}, @"item":item};

    NSDictionary *dictDeepCopy = [dict deepCopy];
    XCTAssertEqualObjects(dict, dictDeepCopy);
    XCTAssertNotEqual(dict[@"AAA"], dictDeepCopy[@"AAA"]);
    XCTAssertNotEqual(dict[@"DDD"], dictDeepCopy[@"DDD"]);
    XCTAssertNotEqual(dict[@"DDD"][@"d"], dictDeepCopy[@"DDD"][@"d"]);
    XCTAssertNotEqual(dict[@"item"], dictDeepCopy[@"item"]);
    XCTAssertFalse([dictDeepCopy isKindOfClass:NSMutableDictionary.class]);
    XCTAssertFalse([dictDeepCopy[@"AAA"] isKindOfClass:NSMutableString.class]);
    XCTAssertFalse([dictDeepCopy[@"DDD"] isKindOfClass:NSMutableDictionary.class]);
    XCTAssertFalse([dictDeepCopy[@"DDD"][@"d"] isKindOfClass:NSMutableString.class]);
    XCTAssertFalse([[dictDeepCopy[@"item"] name] isKindOfClass:NSMutableString.class]);

    NSDictionary *dictMutableDeepCopy = [dict mutableDeepCopy];
    XCTAssertEqualObjects(dict, dictMutableDeepCopy);
    XCTAssertNotEqual(dict[@"AAA"], dictMutableDeepCopy[@"AAA"]);
    XCTAssertNotEqual(dict[@"DDD"], dictMutableDeepCopy[@"DDD"]);
    XCTAssertNotEqual(dict[@"DDD"][@"d"], dictMutableDeepCopy[@"DDD"][@"d"]);
    XCTAssertNotEqual(dict[@"item"], dictMutableDeepCopy[@"item"]);
    XCTAssertTrue([dictMutableDeepCopy isKindOfClass:NSMutableDictionary.class]);
    XCTAssertFalse([dictMutableDeepCopy[@"AAA"] isKindOfClass:NSMutableString.class]);
    XCTAssertFalse([dictMutableDeepCopy[@"DDD"] isKindOfClass:NSMutableDictionary.class]);
    XCTAssertFalse([dictMutableDeepCopy[@"DDD"][@"d"] isKindOfClass:NSMutableString.class]);
    XCTAssertFalse([[dictMutableDeepCopy[@"item"] name] isKindOfClass:NSMutableString.class]);

    NSDictionary *dictDeepMutableCopy = [dict deepMutableCopy];
    XCTAssertEqualObjects(dict, dictDeepMutableCopy);
    XCTAssertNotEqual(dict[@"AAA"], dictDeepMutableCopy[@"AAA"]);
    XCTAssertNotEqual(dict[@"DDD"], dictDeepMutableCopy[@"DDD"]);
    XCTAssertNotEqual(dict[@"DDD"][@"d"], dictDeepMutableCopy[@"DDD"][@"d"]);
    XCTAssertNotEqual(dict[@"item"], dictDeepMutableCopy[@"item"]);
    XCTAssertFalse([dictDeepMutableCopy isKindOfClass:NSMutableDictionary.class]);
    XCTAssertTrue([dictDeepMutableCopy[@"AAA"] isKindOfClass:NSMutableString.class]);
    XCTAssertTrue([dictDeepMutableCopy[@"DDD"] isKindOfClass:NSMutableDictionary.class]);
    XCTAssertTrue([dictDeepMutableCopy[@"DDD"][@"d"] isKindOfClass:NSMutableString.class]);
    XCTAssertTrue([[dictDeepMutableCopy[@"item"] name] isKindOfClass:NSMutableString.class]);

    NSDictionary *dictMutableDeepMutableCopy = [dict mutableDeepMutableCopy];
    XCTAssertEqualObjects(dict, dictMutableDeepMutableCopy);
    XCTAssertNotEqual(dict[@"AAA"], dictMutableDeepMutableCopy[@"AAA"]);
    XCTAssertNotEqual(dict[@"DDD"], dictMutableDeepMutableCopy[@"DDD"]);
    XCTAssertNotEqual(dict[@"DDD"][@"d"], dictMutableDeepMutableCopy[@"DDD"][@"d"]);
    XCTAssertNotEqual(dict[@"item"], dictMutableDeepMutableCopy[@"item"]);
    XCTAssertTrue([dictMutableDeepMutableCopy isKindOfClass:NSMutableDictionary.class]);
    XCTAssertTrue([dictMutableDeepMutableCopy[@"AAA"] isKindOfClass:NSMutableString.class]);
    XCTAssertTrue([dictMutableDeepMutableCopy[@"DDD"] isKindOfClass:NSMutableDictionary.class]);
    XCTAssertTrue([dictMutableDeepMutableCopy[@"DDD"][@"d"] isKindOfClass:NSMutableString.class]);
    XCTAssertTrue([[dictMutableDeepMutableCopy[@"item"] name] isKindOfClass:NSMutableString.class]);

    NSObject *nilObject = nil;
    XCTAssertNil(dict[nilObject]);
    XCTAssertEqualObjects([dict itemForKey:nilObject]?:@"bbb", @"bbb");
    ((NSMutableDictionary *)dictMutableDeepCopy)[[nilObject description]] = @"bbb";
    XCTAssertNil(dict[nilObject]);
    [((NSMutableDictionary *)dictMutableDeepCopy) setObject:nilObject forKey:@"AAA"];
    XCTAssertNil(dictMutableDeepCopy[@"AAA"]);
    XCTAssertEqualObjects([dictMutableDeepCopy itemForKey:@"AAA"]?:@"bbb", @"bbb");
    ((NSMutableDictionary *)dictMutableDeepCopy)[@"BBB"] = nilObject;
    XCTAssertNil(dictMutableDeepCopy[@"BBB"]);
    XCTAssertEqualObjects([dictMutableDeepCopy itemForKey:@"BBB"]?:@"ccc", @"ccc");
    [((NSMutableDictionary *)dictMutableDeepCopy) removeObjectForKey:@"CCC"];
    XCTAssertNil(dictMutableDeepCopy[@"CCC"]);
    XCTAssertEqualObjects([dictMutableDeepCopy itemForKey:@"CCC"]?:@"ddd", @"ddd");

    NSMutableDictionary *mdict = NSMutableDictionary.instance;
    [mdict addEntriesFromDictionary:@{@"AAA":@"aaa", @"BBB":@"bbb"}];
    [mdict addEntriesFromDictionary:@{@"AAA":@"AAA", @"BBB":@"BBB"}];
    XCTAssertEqualObjects(mdict[@"AAA"], @"AAA");
    XCTAssertEqualObjects(mdict[@"BBB"], @"BBB");
    [mdict addAbsenceEntriesFromDictionary:@{@"AAA":@"aaa", @"BBB":@"bbb", @"CCC":@"ccc"}];
    XCTAssertEqualObjects(mdict[@"AAA"], @"AAA");
    XCTAssertEqualObjects(mdict[@"BBB"], @"BBB");
    XCTAssertEqualObjects(mdict[@"CCC"], @"ccc");
}

- (void)testNSDictionaryAGXCoreSafe {
    NSDictionary *dict0 = @{};
    XCTAssertNil(dict0[@0]);
    NSDictionary *dict1 = @{@0:@0};
    XCTAssertNil(dict1[@1]);
    NSDictionary *dict2 = @{@0:@0, @1:@1};
    XCTAssertNil(dict2[@2]);

    NSString *nilStr = nil;
    NSDictionary *dict = @{@"Nil":nilStr, nilStr:@"Nil",
                           @"AAA":@"aaa", @"BBB":@"bbb", @"CCC":@"ccc",
                           NSNull.null:@"nil", @"nil":NSNull.null};
    XCTAssertNil([dict objectForKey:nilStr]);
    XCTAssertNil(dict[nilStr]);
    XCTAssertEqualObjects([dict itemForKey:nilStr]?:@"bbb", @"bbb");
    XCTAssertEqualObjects(dict[nilStr]?:@"bbb", @"bbb");
    XCTAssertNotNil([dict objectForKey:NSNull.null]);
    XCTAssertNotNil(dict[NSNull.null]);
    XCTAssertEqualObjects([dict itemForKey:NSNull.null]?:@"bbb", @"nil");
    XCTAssertEqualObjects(dict[NSNull.null]?:@"bbb", @"nil");
    XCTAssertNotNil([dict objectForKey:@"nil"]);
    XCTAssertNotNil(dict[@"nil"]);
    XCTAssertEqualObjects([dict itemForKey:@"nil"]?:@"bbb", @"bbb");
    XCTAssertEqualObjects(dict[@"nil"]?:@"bbb", NSNull.null);

    NSMutableDictionary *dictMutable = [dict mutableCopy];
    XCTAssertNil([dictMutable objectForKey:nilStr]);
    XCTAssertNil(dictMutable[nilStr]);
    XCTAssertEqualObjects([dictMutable itemForKey:nilStr]?:@"bbb", @"bbb");
    XCTAssertEqualObjects(dictMutable[nilStr]?:@"bbb", @"bbb");
    XCTAssertNotNil([dictMutable objectForKey:NSNull.null]);
    XCTAssertNotNil(dictMutable[NSNull.null]);
    XCTAssertEqualObjects([dictMutable itemForKey:NSNull.null]?:@"bbb", @"nil");
    XCTAssertEqualObjects(dictMutable[NSNull.null]?:@"bbb", @"nil");
    XCTAssertNotNil([dictMutable objectForKey:@"nil"]);
    XCTAssertNotNil(dictMutable[@"nil"]);
    XCTAssertEqualObjects([dictMutable itemForKey:@"nil"]?:@"bbb", @"bbb");
    XCTAssertEqualObjects(dictMutable[@"nil"]?:@"bbb", NSNull.null);

    [dictMutable setObject:@"ccc" forKey:nilStr];
    XCTAssertNil([dictMutable objectForKey:nilStr]);
    XCTAssertNil(dictMutable[nilStr]);
    XCTAssertEqualObjects([dictMutable itemForKey:nilStr]?:@"bbb", @"bbb");
    XCTAssertEqualObjects(dictMutable[nilStr]?:@"bbb", @"bbb");
    dictMutable[nilStr] = @"ccc";
    XCTAssertNil([dictMutable objectForKey:nilStr]);
    XCTAssertNil(dictMutable[nilStr]);
    XCTAssertEqualObjects([dictMutable itemForKey:nilStr]?:@"bbb", @"bbb");
    XCTAssertEqualObjects(dictMutable[nilStr]?:@"bbb", @"bbb");
    [dictMutable setObject:@"ccc" forKey:NSNull.null];
    XCTAssertNotNil([dictMutable objectForKey:NSNull.null]);
    XCTAssertNotNil(dictMutable[NSNull.null]);
    XCTAssertEqualObjects([dictMutable itemForKey:NSNull.null]?:@"bbb", @"ccc");
    XCTAssertEqualObjects(dictMutable[NSNull.null]?:@"bbb", @"ccc");
    dictMutable[NSNull.null] = @"ccc";
    XCTAssertNotNil([dictMutable objectForKey:NSNull.null]);
    XCTAssertNotNil(dictMutable[NSNull.null]);
    XCTAssertEqualObjects([dictMutable itemForKey:NSNull.null]?:@"bbb", @"ccc");
    XCTAssertEqualObjects(dictMutable[NSNull.null]?:@"bbb", @"ccc");

    [dictMutable setObject:nilStr forKey:@"BBB"];
    XCTAssertNil([dictMutable objectForKey:@"BBB"]);
    XCTAssertNil(dictMutable[@"BBB"]);
    XCTAssertEqualObjects([dictMutable itemForKey:@"BBB"]?:@"ccc", @"ccc");
    XCTAssertEqualObjects(dictMutable[@"BBB"]?:@"ccc", @"ccc");
    dictMutable[@"CCC"] = nilStr;
    XCTAssertNil([dictMutable objectForKey:@"CCC"]);
    XCTAssertNil(dictMutable[@"CCC"]);
    XCTAssertEqualObjects([dictMutable itemForKey:@"CCC"]?:@"ddd", @"ddd");
    XCTAssertEqualObjects(dictMutable[@"CCC"]?:@"ddd", @"ddd");
    [dictMutable setObject:NSNull.null forKey:@"AAA"];
    XCTAssertNotNil([dictMutable objectForKey:@"AAA"]);
    XCTAssertNotNil(dictMutable[@"AAA"]);
    XCTAssertEqualObjects([dictMutable itemForKey:@"AAA"]?:@"bbb", @"bbb");
    XCTAssertEqualObjects(dictMutable[@"AAA"]?:@"bbb", NSNull.null);
    dictMutable[@"AAA"] = NSNull.null;
    XCTAssertNotNil([dictMutable objectForKey:@"AAA"]);
    XCTAssertNotNil(dictMutable[@"AAA"]);
    XCTAssertEqualObjects([dictMutable itemForKey:@"AAA"]?:@"bbb", @"bbb");
    XCTAssertEqualObjects(dictMutable[@"AAA"]?:@"bbb", NSNull.null);
}

- (void)testNSDictionaryAGXCoreDirectory {
    XCTAssertFalse(AGXResources.document.isExistsPlistNamed(@"dictionaryfile"));
    XCTAssertNil(AGXResources.document.dictionaryWithPlistNamed(@"dictionaryfile"));
    NSDictionary *dict1 = @{@"AAA":@"aaa"};
    AGXResources.document.writeDictionaryWithPlistNamed(@"dictionaryfile", dict1);
    XCTAssertTrue(AGXResources.document.isExistsPlistNamed(@"dictionaryfile"));
    NSDictionary *dict2 = AGXResources.document.dictionaryWithPlistNamed(@"dictionaryfile");
    XCTAssertEqualObjects(dict1, dict2);
    XCTAssertTrue(AGXResources.document.isExistsPlistNamed(@"dictionaryfile"));
    XCTAssertTrue(AGXResources.document.removePlistNamed(@"dictionaryfile"));
}

@end
