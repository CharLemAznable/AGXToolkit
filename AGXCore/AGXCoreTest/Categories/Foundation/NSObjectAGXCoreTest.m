//
//  NSObjectAGXCoreTest.m
//  AGXCore
//
//  Created by Char Aznable on 16/2/5.
//  Copyright © 2016年 AI-CUC-EC. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "AGXCore.h"

@interface MyObject : NSObject
+ (NSString *)classMethod;
- (NSString *)instanceMethod;
+ (NSString *)swizzleClassMethod;
- (NSString *)swizzleInstanceMethod;
@end
@implementation MyObject
+ (NSString *)classMethod {
    return @"classMethod";
}
- (NSString *)instanceMethod {
    return @"instanceMethod";
}
+ (NSString *)swizzleClassMethod {
    return @"swizzleClassMethod";
}
- (NSString *)swizzleInstanceMethod {
    return @"swizzleInstanceMethod";
}
@end

@interface NSObjectAGXCoreTest : XCTestCase

@end

@implementation NSObjectAGXCoreTest

- (void)testNSObjectAGXCore {
    [MyObject swizzleClassOriSelector:@selector(classMethod) withNewSelector:@selector(swizzleClassMethod)];
    [MyObject swizzleInstanceOriSelector:@selector(instanceMethod) withNewSelector:@selector(swizzleInstanceMethod)];
    
    XCTAssertEqualObjects([MyObject classMethod], @"swizzleClassMethod");
    XCTAssertEqualObjects([MyObject swizzleClassMethod], @"classMethod");
    
    MyObject *myObject = [[MyObject alloc] init];
    XCTAssertEqualObjects([myObject instanceMethod], @"swizzleInstanceMethod");
    XCTAssertEqualObjects([myObject swizzleInstanceMethod], @"instanceMethod");
}

@end
