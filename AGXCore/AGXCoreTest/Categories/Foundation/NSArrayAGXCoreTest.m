//
//  NSArrayAGXCoreTest.m
//  AGXCore
//
//  Created by Char Aznable on 16/2/5.
//  Copyright © 2016年 AI-CUC-EC. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "AGXCore.h"

@interface ArrayItem : NSObject <NSCoding>
@property (nonatomic, AGX_STRONG) NSString *name;
@end
@implementation ArrayItem
- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super init]) {
        _name = AGX_RETAIN([aDecoder decodeObjectOfClass:[NSString class] forKey:@"name"]);
    }
    return self;
}
- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:_name forKey:@"name"];
}
- (id)mutableCopy {
    ArrayItem *copy = [[ArrayItem alloc] init];
    copy.name = [_name mutableCopy];
    return copy;
}
- (void)dealloc {
    AGX_RELEASE(_name);
    AGX_SUPER_DEALLOC;
}
- (BOOL)isEqual:(id)object {
    if (object == self) return YES;
    if (!object || ![object isKindOfClass:[ArrayItem class]]) return NO;
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
    ArrayItem *item = [[ArrayItem alloc] init];
    item.name = @"AAA";
    NSArray *array = @[@"AAA", @[@"AAA"], item];

    NSArray *arrayDeepCopy = [array deepCopy];
    XCTAssertEqualObjects(array, arrayDeepCopy);
    XCTAssertNotEqual(array[0], arrayDeepCopy[0]);
    XCTAssertNotEqual(array[1], arrayDeepCopy[1]);
    XCTAssertNotEqual(array[1][0], arrayDeepCopy[1][0]);
    XCTAssertNotEqual(array[2], arrayDeepCopy[2]);
    XCTAssertFalse([arrayDeepCopy isKindOfClass:[NSMutableArray class]]);
    XCTAssertFalse([arrayDeepCopy[0] isKindOfClass:[NSMutableString class]]);
    XCTAssertFalse([arrayDeepCopy[1] isKindOfClass:[NSMutableArray class]]);
    XCTAssertFalse([arrayDeepCopy[1][0] isKindOfClass:[NSMutableString class]]);
    XCTAssertFalse([[arrayDeepCopy[2] name] isKindOfClass:[NSMutableString class]]);

    NSArray *arrayMutableDeepCopy = [array mutableDeepCopy];
    XCTAssertEqualObjects(array, arrayMutableDeepCopy);
    XCTAssertNotEqual(array[0], arrayMutableDeepCopy[0]);
    XCTAssertNotEqual(array[1], arrayMutableDeepCopy[1]);
    XCTAssertNotEqual(array[1][0], arrayMutableDeepCopy[1][0]);
    XCTAssertNotEqual(array[2], arrayMutableDeepCopy[2]);
    XCTAssertTrue([arrayMutableDeepCopy isKindOfClass:[NSMutableArray class]]);
    XCTAssertFalse([arrayMutableDeepCopy[0] isKindOfClass:[NSMutableString class]]);
    XCTAssertFalse([arrayMutableDeepCopy[1] isKindOfClass:[NSMutableArray class]]);
    XCTAssertFalse([arrayMutableDeepCopy[1][0] isKindOfClass:[NSMutableString class]]);
    XCTAssertFalse([[arrayMutableDeepCopy[2] name] isKindOfClass:[NSMutableString class]]);

    NSArray *arrayDeepMutableCopy = [array deepMutableCopy];
    XCTAssertEqualObjects(array, arrayDeepMutableCopy);
    XCTAssertNotEqual(array[0], arrayDeepMutableCopy[0]);
    XCTAssertNotEqual(array[1], arrayDeepMutableCopy[1]);
    XCTAssertNotEqual(array[1][0], arrayDeepMutableCopy[1][0]);
    XCTAssertNotEqual(array[2], arrayDeepMutableCopy[2]);
    XCTAssertFalse([arrayDeepMutableCopy isKindOfClass:[NSMutableArray class]]);
    XCTAssertTrue([arrayDeepMutableCopy[0] isKindOfClass:[NSMutableString class]]);
    XCTAssertTrue([arrayDeepMutableCopy[1] isKindOfClass:[NSMutableArray class]]);
    XCTAssertTrue([arrayDeepMutableCopy[1][0] isKindOfClass:[NSMutableString class]]);
    XCTAssertTrue([[arrayDeepMutableCopy[2] name] isKindOfClass:[NSMutableString class]]);

    NSArray *arrayMutableDeepMutableCopy = [array mutableDeepMutableCopy];
    XCTAssertEqualObjects(array, arrayMutableDeepMutableCopy);
    XCTAssertNotEqual(array[0], arrayMutableDeepMutableCopy[0]);
    XCTAssertNotEqual(array[1], arrayMutableDeepMutableCopy[1]);
    XCTAssertNotEqual(array[1][0], arrayMutableDeepMutableCopy[1][0]);
    XCTAssertNotEqual(array[2], arrayMutableDeepMutableCopy[2]);
    XCTAssertTrue([arrayMutableDeepMutableCopy isKindOfClass:[NSMutableArray class]]);
    XCTAssertTrue([arrayMutableDeepMutableCopy[0] isKindOfClass:[NSMutableString class]]);
    XCTAssertTrue([arrayMutableDeepMutableCopy[1] isKindOfClass:[NSMutableArray class]]);
    XCTAssertTrue([arrayMutableDeepMutableCopy[1][0] isKindOfClass:[NSMutableString class]]);
    XCTAssertTrue([[arrayMutableDeepMutableCopy[2] name] isKindOfClass:[NSMutableString class]]);

    array = @[@"AAA", @"BBB", @"CCC"];
    XCTAssertEqualObjects([array reverseArray], (@[@"CCC", @"BBB", @"AAA"]));
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
    XCTAssertFalse(AGXDirectory.document.fileExists(@"arrayfile.plist"));
    [array writeToUserFile:@"arrayfile.plist"];
    XCTAssertTrue(AGXDirectory.document.fileExists(@"arrayfile.plist"));
    NSArray *array2 = [NSArray arrayWithContentsOfUserFile:@"arrayfile.plist"];
    XCTAssertEqualObjects(array, array2);
    XCTAssertTrue(AGXDirectory.document.deleteFile(@"arrayfile.plist"));
}

@end
