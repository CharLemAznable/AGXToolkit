//
//  AGXCode93ReaderTest.m
//  AGXGcode
//
//  Created by Char Aznable on 2016/8/1.
//  Copyright © 2016年 AI-CUC-EC. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <AGXCore/AGXCore.h>
#import "AGXCode93Reader.h"
#import "AGXGcodeError.h"

@interface AGXCode93ReaderTest : XCTestCase
@property (nonatomic, AGX_STRONG) AGXBundle *bundle;
@property (nonatomic, AGX_STRONG) AGXCode93Reader *reader;
@end

@implementation AGXCode93ReaderTest

- (void)setUp {
    [super setUp];
    _bundle = AGX_RETAIN(AGXBundle.bundleNameAs(@"Resources"));
    _reader = [[AGXCode93Reader alloc] init];
}

- (void)tearDown {
    AGX_RELEASE(_bundle);
    AGX_RELEASE(_reader);
    [super tearDown];
}

- (void)testcode931 {
    _bundle.subpathAs(@"blackbox/code93-1");
    AGXGcodeResult *result = nil;
    NSError *error = nil;
    int all = 0, passed = 0;

    result = [_reader decode:_bundle.imageWithFile(@"1.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(@"1234567890", result.text); passed++; }
    else XCTAssertEqual(AGXNotFoundError, error.code);
    all++;
    error = nil;
    result = [_reader decode:_bundle.imageWithFile(@"2.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(@"CODE 93", result.text); passed++; }
    else XCTAssertEqual(AGXNotFoundError, error.code);
    all++;
    error = nil;
    result = [_reader decode:_bundle.imageWithFile(@"3.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(@"DATA", result.text); passed++; }
    else XCTAssertEqual(AGXNotFoundError, error.code);
    all++;
    error = nil;
    NSLog(@"%@:%@, all:%d, passed:%d", NSStringFromClass(self.class), NSStringFromSelector(_cmd), all, passed);
}

@end
