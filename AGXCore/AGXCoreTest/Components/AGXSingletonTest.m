//
//  AGXSingletonTest.m
//  AGXCore
//
//  Created by Char Aznable on 16/2/5.
//  Copyright © 2016年 AI-CUC-EC. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "AGXCore.h"

@singleton_interface(MySingleton, NSObject)
@end
@singleton_implementation(MySingleton)
@end

@singleton_interface(MySubSingleton, MySingleton)
@end
@singleton_implementation(MySubSingleton)
@end

@interface AGXSingletonTest : XCTestCase

@end

@implementation AGXSingletonTest

- (void)testAGXSingleton {
    XCTAssertEqual([MySingleton new], [MySingleton shareMySingleton]);
    XCTAssertEqual([MySingleton shareMySingleton], [[MySingleton shareMySingleton] copy]);
    XCTAssertNil([MySingleton new]);
    XCTAssertEqual([MySubSingleton new], [MySubSingleton shareMySubSingleton]);
    XCTAssertEqual([MySubSingleton shareMySubSingleton], [[MySubSingleton shareMySubSingleton] copy]);
    XCTAssertNil([MySubSingleton new]);
    XCTAssertNotEqual([MySingleton shareMySingleton], [MySubSingleton shareMySubSingleton]);
}

@end
