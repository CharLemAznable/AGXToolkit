//
//  AGXSingletonTest.m
//  AGXCore
//
//  Created by Char Aznable on 2016/2/5.
//  Copyright © 2016年 AI-CUC-EC. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "AGXCore.h"

@singleton_interface(MySingleton, NSObject, shareInstance)
@end
@singleton_implementation(MySingleton, shareInstance)
@end

@singleton_interface(MySubSingleton, MySingleton, shareInstance)
@end
@singleton_implementation(MySubSingleton, shareInstance)
@end

@interface AGXSingletonTest : XCTestCase

@end

@implementation AGXSingletonTest

- (void)testAGXSingleton {
    XCTAssertEqual([MySingleton new], MySingleton.shareInstance);
    XCTAssertEqual(MySingleton.shareInstance, [MySingleton.shareInstance copy]);
    XCTAssertNil([MySingleton new]);
    XCTAssertEqual([MySubSingleton new], MySubSingleton.shareInstance);
    XCTAssertEqual(MySubSingleton.shareInstance, [MySubSingleton.shareInstance copy]);
    XCTAssertNil([MySubSingleton new]);
    XCTAssertNotEqual(MySingleton.shareInstance, MySubSingleton.shareInstance);
}

@end
