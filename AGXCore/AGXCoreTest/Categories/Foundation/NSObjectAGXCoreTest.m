//
//  NSObjectAGXCoreTest.m
//  AGXCore
//
//  Created by Char Aznable on 16/2/5.
//  Copyright © 2016年 AI-CUC-EC. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "AGXCore.h"
#import <objc/runtime.h>

@interface MyObjectTemplate : NSObject
@end
@implementation MyObjectTemplate
@end

@interface MyObject : NSObject
+ (NSString *)classMethod;
- (NSString *)instanceMethod;
+ (NSString *)swizzleClassMethod;
- (NSString *)swizzleInstanceMethod;
@end
@implementation MyObject
+ (NSString *)classMethod { return @"classMethod"; }
- (NSString *)instanceMethod { return @"instanceMethod"; }
+ (NSString *)swizzleClassMethod { return @"swizzleClassMethod"; }
- (NSString *)swizzleInstanceMethod { return @"swizzleInstanceMethod"; }
@end

@interface MyObject2 : NSObject
- (NSString *)instanceMethod;
@end
@implementation MyObject2
- (NSString *)instanceMethod {
    return @"instanceMethod";
}
@end

@interface MyObject2Dummy : NSObject
- (NSString *)instanceMethod;
- (NSString *)swizzleInstanceMethod;
@end
@implementation MyObject2Dummy
- (NSString *)instanceMethod {
    return @"instanceDummy";
}
- (NSString *)swizzleInstanceMethod {
    return [NSString stringWithFormat:@"swizzleInstanceMethod: %@",
            [self swizzleInstanceMethod]];
}
@end

@interface NSObjectAGXCoreTest : XCTestCase

@end

@implementation NSObjectAGXCoreTest

- (void)testNSObjectAGXCoreAdd {
    Method cMethod = class_getInstanceMethod(object_getClass([MyObject class]), @selector(classMethod));
    Method scMethod = class_getInstanceMethod(object_getClass([MyObject class]), @selector(swizzleClassMethod));
    Method iMethod = class_getInstanceMethod([MyObject class], @selector(instanceMethod));
    Method siMethod = class_getInstanceMethod([MyObject class], @selector(swizzleInstanceMethod));

    [MyObjectTemplate addClassMethodWithSelector:@selector(classMethod)
                                        andBlock:^NSString *() { return @"classMethod"; }
                                 andTypeEncoding:method_getTypeEncoding(cMethod)];
    [MyObjectTemplate addClassMethodWithSelector:@selector(swizzleClassMethod)
                                        andBlock:^NSString *() { return @"swizzleClassMethod"; }
                                 andTypeEncoding:method_getTypeEncoding(scMethod)];
    [MyObjectTemplate addInstanceMethodWithSelector:@selector(instanceMethod)
                                           andBlock:^NSString *() { return @"instanceMethod"; }
                                    andTypeEncoding:method_getTypeEncoding(iMethod)];
    [MyObjectTemplate addInstanceMethodWithSelector:@selector(swizzleInstanceMethod)
                                           andBlock:^NSString *() { return @"swizzleInstanceMethod"; }
                                    andTypeEncoding:method_getTypeEncoding(siMethod)];

    AGX_PerformSelector
    (
    XCTAssertEqualObjects([MyObjectTemplate performSelector:@selector(classMethod)], @"classMethod");
    XCTAssertEqualObjects([MyObjectTemplate performSelector:@selector(swizzleClassMethod)], @"swizzleClassMethod");

    MyObjectTemplate *template = [[MyObjectTemplate alloc] init];
    XCTAssertEqualObjects([template performSelector:@selector(instanceMethod)], @"instanceMethod");
    XCTAssertEqualObjects([template performSelector:@selector(swizzleInstanceMethod)], @"swizzleInstanceMethod");
     )
}

- (void)testNSObjectAGXCore {
    [MyObject swizzleClassOriSelector:@selector(classMethod) withNewSelector:@selector(swizzleClassMethod)];
    [MyObject swizzleInstanceOriSelector:@selector(instanceMethod) withNewSelector:@selector(swizzleInstanceMethod)];

    XCTAssertEqualObjects([MyObject classMethod], @"swizzleClassMethod");
    XCTAssertEqualObjects([MyObject swizzleClassMethod], @"classMethod");

    MyObject *myObject = [[MyObject alloc] init];
    XCTAssertEqualObjects([myObject instanceMethod], @"swizzleInstanceMethod");
    XCTAssertEqualObjects([myObject swizzleInstanceMethod], @"instanceMethod");

    [MyObject swizzleClassOriSelector:@selector(classMethod)
                      withNewSelector:@selector(swizzleClassMethod)
                            fromClass:[MyObject class]];
    [MyObject swizzleInstanceOriSelector:@selector(instanceMethod)
                         withNewSelector:@selector(swizzleInstanceMethod)
                               fromClass:[MyObject class]];

    XCTAssertEqualObjects([MyObject classMethod], @"classMethod");
    XCTAssertEqualObjects([MyObject swizzleClassMethod], @"swizzleClassMethod");

    myObject = [[MyObject alloc] init];
    XCTAssertEqualObjects([myObject instanceMethod], @"instanceMethod");
    XCTAssertEqualObjects([myObject swizzleInstanceMethod], @"swizzleInstanceMethod");
}

- (void)testSwizzleMethod {
    [MyObject2 swizzleInstanceOriSelector:@selector(instanceMethod) withNewSelector:@selector(swizzleInstanceMethod) fromClass:[MyObject2Dummy class]];
    MyObject2 *m2 = [MyObject2 new];
    XCTAssertEqualObjects([m2 instanceMethod], @"swizzleInstanceMethod: instanceMethod");
}

@end
