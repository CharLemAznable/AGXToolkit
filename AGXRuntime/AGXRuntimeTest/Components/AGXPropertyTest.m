//
//  AGXPropertyTest.m
//  AGXRuntime
//
//  Created by Char Aznable on 2016/2/19.
//  Copyright © 2016年 AI-CUC-EC. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "AGXRuntime.h"

@interface PropertyDetailBean : NSObject
@end
@implementation PropertyDetailBean
@end

@interface PropertyTestBean : NSObject
@property (nonatomic, strong) NSString *name;
@property (nonatomic, assign) int age;
@property (nonatomic, strong) PropertyDetailBean *detail;
@property (nonatomic, assign) CGPoint point;
@property (nonatomic, assign) CGRect rect;
@property (nonatomic, strong) id others;
@end
@implementation PropertyTestBean
@end

@interface AGXPropertyTest : XCTestCase

@end

@implementation AGXPropertyTest

- (void)testAGXProperty {
    AGXProperty *property = [AGXProperty propertyWithName:@"name" inClassNamed:@"PropertyTestBean"];
    XCTAssertFalse([property isReadOnly]);
    XCTAssertTrue([property isNonAtomic]);
    XCTAssertFalse([property isWeakReference]);
    XCTAssertFalse([property isEligibleForGarbageCollection]);
    XCTAssertFalse([property isDynamic]);
    XCTAssertEqual([property memoryManagementPolicy], AGXPropertyMemoryManagementPolicyRetain);
    XCTAssertEqualObjects(NSStringFromSelector([property getter]), @"name");
    XCTAssertEqualObjects(NSStringFromSelector([property setter]), @"setName:");
    XCTAssertEqualObjects([property ivarName], @"_name");
    XCTAssertEqualObjects([property typeName], @"NSString");
    XCTAssertEqualObjects([property typeEncoding], @"@\"NSString\"");
    XCTAssertEqualObjects([property objectClass], [NSString class]);

    property = [AGXProperty propertyWithName:@"age" inClassNamed:@"PropertyTestBean"];
    XCTAssertFalse([property isReadOnly]);
    XCTAssertTrue([property isNonAtomic]);
    XCTAssertFalse([property isWeakReference]);
    XCTAssertFalse([property isEligibleForGarbageCollection]);
    XCTAssertFalse([property isDynamic]);
    XCTAssertEqual([property memoryManagementPolicy], AGXPropertyMemoryManagementPolicyAssign);
    XCTAssertEqualObjects(NSStringFromSelector([property getter]), @"age");
    XCTAssertEqualObjects(NSStringFromSelector([property setter]), @"setAge:");
    XCTAssertEqualObjects([property ivarName], @"_age");
    XCTAssertEqualObjects([property typeName], @"i");
    XCTAssertEqualObjects([property typeEncoding], @"i");
    XCTAssertNil([property objectClass]);

    property = [AGXProperty propertyWithName:@"detail" inClassNamed:@"PropertyTestBean"];
    XCTAssertFalse([property isReadOnly]);
    XCTAssertTrue([property isNonAtomic]);
    XCTAssertFalse([property isWeakReference]);
    XCTAssertFalse([property isEligibleForGarbageCollection]);
    XCTAssertFalse([property isDynamic]);
    XCTAssertEqual([property memoryManagementPolicy], AGXPropertyMemoryManagementPolicyRetain);
    XCTAssertEqualObjects(NSStringFromSelector([property getter]), @"detail");
    XCTAssertEqualObjects(NSStringFromSelector([property setter]), @"setDetail:");
    XCTAssertEqualObjects([property ivarName], @"_detail");
    XCTAssertEqualObjects([property typeName], @"PropertyDetailBean");
    XCTAssertEqualObjects([property typeEncoding], @"@\"PropertyDetailBean\"");
    XCTAssertEqualObjects([property objectClass], [PropertyDetailBean class]);

    property = [AGXProperty propertyWithName:@"point" inClassNamed:@"PropertyTestBean"];
    XCTAssertFalse([property isReadOnly]);
    XCTAssertTrue([property isNonAtomic]);
    XCTAssertFalse([property isWeakReference]);
    XCTAssertFalse([property isEligibleForGarbageCollection]);
    XCTAssertFalse([property isDynamic]);
    XCTAssertEqual([property memoryManagementPolicy], AGXPropertyMemoryManagementPolicyAssign);
    XCTAssertEqualObjects(NSStringFromSelector([property getter]), @"point");
    XCTAssertEqualObjects(NSStringFromSelector([property setter]), @"setPoint:");
    XCTAssertEqualObjects([property ivarName], @"_point");
    XCTAssertEqualObjects([property typeName], @"CGPoint");
    XCTAssertEqualObjects([property typeEncoding], @"{CGPoint=dd}");
    XCTAssertEqualObjects([property objectClass], [NSValue class]);

    property = [AGXProperty propertyWithName:@"rect" inClassNamed:@"PropertyTestBean"];
    XCTAssertFalse([property isReadOnly]);
    XCTAssertTrue([property isNonAtomic]);
    XCTAssertFalse([property isWeakReference]);
    XCTAssertFalse([property isEligibleForGarbageCollection]);
    XCTAssertFalse([property isDynamic]);
    XCTAssertEqual([property memoryManagementPolicy], AGXPropertyMemoryManagementPolicyAssign);
    XCTAssertEqualObjects(NSStringFromSelector([property getter]), @"rect");
    XCTAssertEqualObjects(NSStringFromSelector([property setter]), @"setRect:");
    XCTAssertEqualObjects([property ivarName], @"_rect");
    XCTAssertEqualObjects([property typeName], @"CGRect");
    XCTAssertEqualObjects([property typeEncoding], @"{CGRect={CGPoint=dd}{CGSize=dd}}");
    XCTAssertEqualObjects([property objectClass], [NSValue class]);

    property = [AGXProperty propertyWithName:@"others" inClassNamed:@"PropertyTestBean"];
    XCTAssertFalse([property isReadOnly]);
    XCTAssertTrue([property isNonAtomic]);
    XCTAssertFalse([property isWeakReference]);
    XCTAssertFalse([property isEligibleForGarbageCollection]);
    XCTAssertFalse([property isDynamic]);
    XCTAssertEqual([property memoryManagementPolicy], AGXPropertyMemoryManagementPolicyRetain);
    XCTAssertEqualObjects(NSStringFromSelector([property getter]), @"others");
    XCTAssertEqualObjects(NSStringFromSelector([property setter]), @"setOthers:");
    XCTAssertEqualObjects([property ivarName], @"_others");
    XCTAssertEqualObjects([property typeName], @"");
    XCTAssertEqualObjects([property typeEncoding], @"@");
    XCTAssertNil([property objectClass]);
}

@end
