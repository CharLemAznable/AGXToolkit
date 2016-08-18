//
//  AGXEAN8ReaderTest.m
//  AGXGcode
//
//  Created by Char Aznable on 16/8/1.
//  Copyright © 2016年 AI-CUC-EC. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <AGXCore/AGXCore.h>
#import "AGXEAN8Reader.h"
#import "AGXGcodeError.h"

@interface AGXEAN8ReaderTest : XCTestCase
@property (nonatomic, AGX_STRONG) AGXBundle *bundle;
@property (nonatomic, AGX_STRONG) AGXEAN8Reader *reader;
@end

@implementation AGXEAN8ReaderTest

- (void)setUp {
    [super setUp];
    _bundle = AGX_RETAIN(AGXBundle.bundleNameAs(@"Resources"));
    _reader = [[AGXEAN8Reader alloc] init];
}

- (void)tearDown {
    AGX_RELEASE(_bundle);
    AGX_RELEASE(_reader);
    [super tearDown];
}

- (void)testean81 {
    _bundle.subpathAs(@"blackbox/ean8-1");
    AGXGcodeResult *result = nil;
    NSError *error = nil;
    int all = 0, passed = 0;

    result = [_reader decode:_bundle.imageWithFile(@"1.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(@"48512343", result.text); passed++; }
    else XCTAssertEqual(AGXNotFoundError, error.code);
    all++;
    error = nil;
    result = [_reader decode:_bundle.imageWithFile(@"2.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(@"12345670", result.text); passed++; }
    else XCTAssertEqual(AGXNotFoundError, error.code);
    all++;
    error = nil;
    result = [_reader decode:_bundle.imageWithFile(@"3.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(@"12345670", result.text); passed++; }
    else XCTAssertEqual(AGXNotFoundError, error.code);
    all++;
    error = nil;
    result = [_reader decode:_bundle.imageWithFile(@"4.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(@"67678983", result.text); passed++; }
    else XCTAssertEqual(AGXNotFoundError, error.code);
    all++;
    error = nil;
    result = [_reader decode:_bundle.imageWithFile(@"5.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(@"80674313", result.text); passed++; }
    else XCTAssertEqual(AGXNotFoundError, error.code);
    all++;
    error = nil;
    result = [_reader decode:_bundle.imageWithFile(@"6.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(@"59001270", result.text); passed++; }
    else XCTAssertEqual(AGXNotFoundError, error.code);
    all++;
    error = nil;
    result = [_reader decode:_bundle.imageWithFile(@"7.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(@"50487066", result.text); passed++; }
    else XCTAssertEqual(AGXNotFoundError, error.code);
    all++;
    error = nil;
    result = [_reader decode:_bundle.imageWithFile(@"8.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(@"55123457", result.text); passed++; }
    else XCTAssertEqual(AGXNotFoundError, error.code);
    all++;
    error = nil;
    NSLog(@"%@:%@, all:%d, passed:%d", NSStringFromClass([self class]), NSStringFromSelector(_cmd), all, passed);
}

@end
