//
//  NSSetAGXCoreTest.m
//  AGXCoreTest
//
//  Created by Char Aznable on 2017/11/2.
//  Copyright © 2017年 AI-CUC-EC. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "AGXCore.h"

@interface SetItem : NSObject <NSCoding>
@property (nonatomic, AGX_STRONG) NSString *name;
@end
@implementation SetItem
- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super init]) {
        _name = AGX_RETAIN([aDecoder decodeObjectOfClass:NSString.class forKey:@"name"]);
    }
    return self;
}
- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:_name forKey:@"name"];
}
- (id)mutableCopy {
    SetItem *copy = SetItem.instance;
    copy.name = [_name mutableCopy];
    return copy;
}
- (void)dealloc {
    AGX_RELEASE(_name);
    AGX_SUPER_DEALLOC;
}
- (BOOL)isEqual:(id)object {
    if (object == self) return YES;
    if (!object || ![object isKindOfClass:SetItem.class]) return NO;
    return [self isEqualToSetItem:object];
}
- (BOOL)isEqualToSetItem:(SetItem *)item {
    if (item == self) return YES;
    return [self.name isEqualToString:item.name];
}
@end

@interface NSSetAGXCoreTest : XCTestCase

@end

@implementation NSSetAGXCoreTest

- (void)testNSSetAGXCore {
    SetItem *item = SetItem.instance;
    item.name = @"AAA";
    NSSet *set = [NSSet setWithObjects:@"AAA", @[@"AAA"], item, nil];

    NSSet *setDeepCopy = [set deepCopy];
    XCTAssertEqualObjects(set, setDeepCopy);
    XCTAssertNotEqual([set member:@"AAA"], [setDeepCopy member:@"AAA"]);
    XCTAssertNotEqual([set member:@[@"AAA"]], [setDeepCopy member:@[@"AAA"]]);
    XCTAssertNotEqual([set member:@[@"AAA"]][0], [setDeepCopy member:@[@"AAA"]][0]);
    XCTAssertNotEqual([set member:item], [setDeepCopy member:item]);
    XCTAssertFalse([setDeepCopy isKindOfClass:NSMutableSet.class]);
    XCTAssertFalse([[setDeepCopy member:@"AAA"] isKindOfClass:NSMutableString.class]);
    XCTAssertFalse([[setDeepCopy member:@[@"AAA"]] isKindOfClass:NSMutableArray.class]);
    XCTAssertFalse([[setDeepCopy member:@[@"AAA"]][0] isKindOfClass:NSMutableString.class]);
    XCTAssertFalse([[[setDeepCopy member:item] name] isKindOfClass:NSMutableString.class]);

    NSSet *setMutableDeepCopy = [set mutableDeepCopy];
    XCTAssertEqualObjects(set, setMutableDeepCopy);
    XCTAssertNotEqual([set member:@"AAA"], [setMutableDeepCopy member:@"AAA"]);
    XCTAssertNotEqual([set member:@[@"AAA"]], [setMutableDeepCopy member:@[@"AAA"]]);
    XCTAssertNotEqual([set member:@[@"AAA"]][0], [setMutableDeepCopy member:@[@"AAA"]][0]);
    XCTAssertNotEqual([set member:item], [setMutableDeepCopy member:item]);
    XCTAssertTrue([setMutableDeepCopy isKindOfClass:NSMutableSet.class]);
    XCTAssertFalse([[setMutableDeepCopy member:@"AAA"] isKindOfClass:NSMutableString.class]);
    XCTAssertFalse([[setMutableDeepCopy member:@[@"AAA"]] isKindOfClass:NSMutableArray.class]);
    XCTAssertFalse([[setMutableDeepCopy member:@[@"AAA"]][0] isKindOfClass:NSMutableString.class]);
    XCTAssertFalse([[[setMutableDeepCopy member:item] name] isKindOfClass:NSMutableString.class]);

    NSSet *setDeepMutableCopy = [set deepMutableCopy];
    XCTAssertEqualObjects(set, setDeepMutableCopy);
    XCTAssertNotEqual([set member:@"AAA"], [setDeepMutableCopy member:@"AAA"]);
    XCTAssertNotEqual([set member:@[@"AAA"]], [setDeepMutableCopy member:@[@"AAA"]]);
    XCTAssertNotEqual([set member:@[@"AAA"]][0], [setDeepMutableCopy member:@[@"AAA"]][0]);
    XCTAssertNotEqual([set member:item], [setDeepMutableCopy member:item]);
    XCTAssertFalse([setDeepMutableCopy isKindOfClass:NSMutableSet.class]);
    XCTAssertTrue([[setDeepMutableCopy member:@"AAA"] isKindOfClass:NSMutableString.class]);
    XCTAssertTrue([[setDeepMutableCopy member:@[@"AAA"]] isKindOfClass:NSMutableArray.class]);
    XCTAssertTrue([[setDeepMutableCopy member:@[@"AAA"]][0] isKindOfClass:NSMutableString.class]);
    XCTAssertTrue([[[setDeepMutableCopy member:item] name] isKindOfClass:NSMutableString.class]);

    NSSet *setMutableDeepMutableCopy = [set mutableDeepMutableCopy];
    XCTAssertEqualObjects(set, setMutableDeepMutableCopy);
    XCTAssertNotEqual([set member:@"AAA"], [setMutableDeepMutableCopy member:@"AAA"]);
    XCTAssertNotEqual([set member:@[@"AAA"]], [setMutableDeepMutableCopy member:@[@"AAA"]]);
    XCTAssertNotEqual([set member:@[@"AAA"]][0], [setMutableDeepMutableCopy member:@[@"AAA"]][0]);
    XCTAssertNotEqual([set member:item], [setMutableDeepMutableCopy member:item]);
    XCTAssertTrue([setMutableDeepMutableCopy isKindOfClass:NSMutableSet.class]);
    XCTAssertTrue([[setMutableDeepMutableCopy member:@"AAA"] isKindOfClass:NSMutableString.class]);
    XCTAssertTrue([[setMutableDeepMutableCopy member:@[@"AAA"]] isKindOfClass:NSMutableArray.class]);
    XCTAssertTrue([[setMutableDeepMutableCopy member:@[@"AAA"]][0] isKindOfClass:NSMutableString.class]);
    XCTAssertTrue([[[setMutableDeepMutableCopy member:item] name] isKindOfClass:NSMutableString.class]);
}

- (void)testNSSetAGXCoreSafe {
    NSMutableSet *set = [NSMutableSet setWithObjects:@"AAA", nil];
    NSString *nilStr = nil;
    [set addObject:@"BBB"];
    XCTAssertEqual(set.count, 2);
    [set addObject:nilStr];
    XCTAssertEqual(set.count, 2);
    [set removeObject:@"BBB"];
    XCTAssertEqual(set.count, 1);
    [set removeObject:nilStr];
    XCTAssertEqual(set.count, 1);
}

- (void)testNSSetAGXCoreDirectory {
    NSSet *set = [NSSet setWithObjects:@"AAA", nil];
    XCTAssertFalse(AGXResources.document.isExistsPlistNamed(@"setfile"));
    AGXResources.document.writeSetWithPlistNamed(@"setfile", set);
    XCTAssertTrue(AGXResources.document.isExistsPlistNamed(@"setfile"));
    NSSet *set2 = AGXResources.document.setWithPlistNamed(@"setfile");
    XCTAssertEqualObjects(set, set2);
    XCTAssertTrue(AGXResources.document.deletePlistNamed(@"setfile"));
}

@end
