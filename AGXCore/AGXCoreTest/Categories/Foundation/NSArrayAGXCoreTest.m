//
//  NSArrayAGXCoreTest.m
//  AGXCore
//
//  Created by Char Aznable on 2016/2/5.
//  Copyright © 2016年 AI-CUC-EC. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "AGXCore.h"

@interface ArrayItem : NSObject <NSCoding, NSMutableCopying>
@property (nonatomic, AGX_STRONG) NSString *name;
@end
@implementation ArrayItem
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
    ArrayItem *copy = [[ArrayItem allocWithZone:zone] init];
    copy.name = [_name mutableCopy];
    return copy;
}
- (void)dealloc {
    AGX_RELEASE(_name);
    AGX_SUPER_DEALLOC;
}
- (BOOL)isEqual:(id)object {
    if (object == self) return YES;
    if (!object || ![object isKindOfClass:ArrayItem.class]) return NO;
    return [self isEqualToArrayItem:object];
}
- (BOOL)isEqualToArrayItem:(ArrayItem *)item {
    if (item == self) return YES;
    return [self.name isEqualToString:item.name];
}
@end

@interface NSArrayAGXCoreTest : XCTestCase

@end

@implementation NSArrayAGXCoreTest

- (void)testNSArrayAGXCore {
    ArrayItem *item = ArrayItem.instance;
    item.name = @"AAA";
    NSArray *array = @[@"AAA", @[@"AAA"], item];

    NSArray *arrayDeepCopy = [array deepCopy];
    XCTAssertEqualObjects(array, arrayDeepCopy);
    XCTAssertNotEqual(array[0], arrayDeepCopy[0]);
    XCTAssertNotEqual(array[1], arrayDeepCopy[1]);
    XCTAssertNotEqual(array[1][0], arrayDeepCopy[1][0]);
    XCTAssertNotEqual(array[2], arrayDeepCopy[2]);
    XCTAssertFalse([arrayDeepCopy isKindOfClass:NSMutableArray.class]);
    XCTAssertFalse([arrayDeepCopy[0] isKindOfClass:NSMutableString.class]);
    XCTAssertFalse([arrayDeepCopy[1] isKindOfClass:NSMutableArray.class]);
    XCTAssertFalse([arrayDeepCopy[1][0] isKindOfClass:NSMutableString.class]);
    XCTAssertFalse([[arrayDeepCopy[2] name] isKindOfClass:NSMutableString.class]);

    NSArray *arrayMutableDeepCopy = [array mutableDeepCopy];
    XCTAssertEqualObjects(array, arrayMutableDeepCopy);
    XCTAssertNotEqual(array[0], arrayMutableDeepCopy[0]);
    XCTAssertNotEqual(array[1], arrayMutableDeepCopy[1]);
    XCTAssertNotEqual(array[1][0], arrayMutableDeepCopy[1][0]);
    XCTAssertNotEqual(array[2], arrayMutableDeepCopy[2]);
    XCTAssertTrue([arrayMutableDeepCopy isKindOfClass:NSMutableArray.class]);
    XCTAssertFalse([arrayMutableDeepCopy[0] isKindOfClass:NSMutableString.class]);
    XCTAssertFalse([arrayMutableDeepCopy[1] isKindOfClass:NSMutableArray.class]);
    XCTAssertFalse([arrayMutableDeepCopy[1][0] isKindOfClass:NSMutableString.class]);
    XCTAssertFalse([[arrayMutableDeepCopy[2] name] isKindOfClass:NSMutableString.class]);

    NSArray *arrayDeepMutableCopy = [array deepMutableCopy];
    XCTAssertEqualObjects(array, arrayDeepMutableCopy);
    XCTAssertNotEqual(array[0], arrayDeepMutableCopy[0]);
    XCTAssertNotEqual(array[1], arrayDeepMutableCopy[1]);
    XCTAssertNotEqual(array[1][0], arrayDeepMutableCopy[1][0]);
    XCTAssertNotEqual(array[2], arrayDeepMutableCopy[2]);
    XCTAssertFalse([arrayDeepMutableCopy isKindOfClass:NSMutableArray.class]);
    XCTAssertTrue([arrayDeepMutableCopy[0] isKindOfClass:NSMutableString.class]);
    XCTAssertTrue([arrayDeepMutableCopy[1] isKindOfClass:NSMutableArray.class]);
    XCTAssertTrue([arrayDeepMutableCopy[1][0] isKindOfClass:NSMutableString.class]);
    XCTAssertTrue([[arrayDeepMutableCopy[2] name] isKindOfClass:NSMutableString.class]);

    NSArray *arrayMutableDeepMutableCopy = [array mutableDeepMutableCopy];
    XCTAssertEqualObjects(array, arrayMutableDeepMutableCopy);
    XCTAssertNotEqual(array[0], arrayMutableDeepMutableCopy[0]);
    XCTAssertNotEqual(array[1], arrayMutableDeepMutableCopy[1]);
    XCTAssertNotEqual(array[1][0], arrayMutableDeepMutableCopy[1][0]);
    XCTAssertNotEqual(array[2], arrayMutableDeepMutableCopy[2]);
    XCTAssertTrue([arrayMutableDeepMutableCopy isKindOfClass:NSMutableArray.class]);
    XCTAssertTrue([arrayMutableDeepMutableCopy[0] isKindOfClass:NSMutableString.class]);
    XCTAssertTrue([arrayMutableDeepMutableCopy[1] isKindOfClass:NSMutableArray.class]);
    XCTAssertTrue([arrayMutableDeepMutableCopy[1][0] isKindOfClass:NSMutableString.class]);
    XCTAssertTrue([[arrayMutableDeepMutableCopy[2] name] isKindOfClass:NSMutableString.class]);

    array = @[@"AAA", @"BBB", @"CCC"];
    XCTAssertEqualObjects(array.reverseArray, (@[@"CCC", @"BBB", @"AAA"]));

    NSMutableArray *marr = NSMutableArray.instance;
    [marr addObject:@"AAA"];
    [marr addObject:@"AAA"];
    XCTAssertEqualObjects(marr[0], @"AAA");
    XCTAssertEqualObjects(marr[1], @"AAA");
    [marr addAbsenceObject:@"aaa"];
    [marr addAbsenceObject:@"aaa"];
    XCTAssertEqualObjects(marr[0], @"AAA");
    XCTAssertEqualObjects(marr[1], @"AAA");
    XCTAssertEqualObjects(marr[2], @"aaa");
    XCTAssertNil(marr[3]);
    marr = NSMutableArray.instance;
    [marr addObjectsFromArray:@[@"AAA", @"AAA"]];
    XCTAssertEqualObjects(marr[0], @"AAA");
    XCTAssertEqualObjects(marr[1], @"AAA");
    [marr addAbsenceObjectsFromArray:@[@"aaa", @"aaa", @"AAA", @"AAA"]];
    XCTAssertEqualObjects(marr[0], @"AAA");
    XCTAssertEqualObjects(marr[1], @"AAA");
    XCTAssertEqualObjects(marr[2], @"aaa");
    XCTAssertNil(marr[3]);
}

- (void)testNSArrayAGXCoreSafe {
    NSArray *array0 = @[];
    XCTAssertNil(array0[0]);
    NSArray *array1 = @[@0];
    XCTAssertNil(array1[1]);
    NSArray *array2 = @[@0, @1];
    XCTAssertNil(array2[2]);

    NSString *nilStr = nil;
    NSArray *array = @[nilStr, @"AAA", NSNull.null];

    XCTAssertNotNil([array objectAtIndex:1]);
    XCTAssertNotNil(array[1]);
    XCTAssertEqualObjects([array itemAtIndex:1]?:@"BBB", @"BBB");
    XCTAssertEqualObjects(array[1]?:@"BBB", NSNull.null);
    XCTAssertNil([array objectAtIndex:2]);
    XCTAssertNil(array[2]);
    XCTAssertEqualObjects([array itemAtIndex:2]?:@"BBB", @"BBB");
    XCTAssertEqualObjects(array[2]?:@"BBB", @"BBB");

    NSMutableArray *arrayMutable = [array mutableCopy];
    XCTAssertNotNil([arrayMutable objectAtIndex:1]);
    XCTAssertNotNil(arrayMutable[1]);
    XCTAssertEqualObjects([arrayMutable itemAtIndex:1]?:@"BBB", @"BBB");
    XCTAssertEqualObjects(arrayMutable[1]?:@"BBB", NSNull.null);
    XCTAssertNil([arrayMutable objectAtIndex:2]);
    XCTAssertNil(arrayMutable[2]);
    XCTAssertEqualObjects([arrayMutable itemAtIndex:2]?:@"BBB", @"BBB");
    XCTAssertEqualObjects(arrayMutable[2]?:@"BBB", @"BBB");
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
    XCTAssertEqualObjects([arrayMutable itemAtIndex:0]?:@"BBB", @"BBB");
    XCTAssertEqualObjects(arrayMutable[0]?:@"BBB", @"BBB");

    nilObject = NSNull.null;
    arrayMutable[0] = nilObject;
    XCTAssertNotNil([arrayMutable objectAtIndex:0]);
    XCTAssertNotNil(arrayMutable[0]);
    arrayMutable[1] = nilObject;
    XCTAssertNotNil([arrayMutable objectAtIndex:1]);
    XCTAssertNotNil(arrayMutable[1]);
    arrayMutable[2] = nilObject;
    XCTAssertNotNil([arrayMutable objectAtIndex:2]);
    XCTAssertNotNil(arrayMutable[2]);
    XCTAssertEqualObjects([arrayMutable itemAtIndex:0]?:@"BBB", @"BBB");
    XCTAssertEqualObjects(arrayMutable[0]?:@"BBB", NSNull.null);
}

- (void)testNSArrayAGXCoreDirectory {
    NSArray *array = @[@"AAA"];
    XCTAssertFalse(AGXResources.document.isExistsPlistNamed(@"arrayfile"));
    AGXResources.document.writeArrayWithPlistNamed(@"arrayfile", array);
    XCTAssertTrue(AGXResources.document.isExistsPlistNamed(@"arrayfile"));
    NSArray *array2 = AGXResources.document.arrayWithPlistNamed(@"arrayfile");
    XCTAssertEqualObjects(array, array2);
    XCTAssertTrue(AGXResources.document.removePlistNamed(@"arrayfile"));
}

@end
