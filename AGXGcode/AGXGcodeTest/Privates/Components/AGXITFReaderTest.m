//
//  AGXITFReaderTest.m
//  AGXGcode
//
//  Created by Char Aznable on 2016/8/1.
//  Copyright © 2016年 AI-CUC-EC. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <AGXCore/AGXCore.h>
#import "AGXITFReader.h"
#import "AGXGcodeError.h"

@interface AGXITFReaderTest : XCTestCase
@property (nonatomic, AGX_STRONG) AGXBundle *bundle;
@property (nonatomic, AGX_STRONG) AGXITFReader *reader;
@end

@implementation AGXITFReaderTest

- (void)setUp {
    [super setUp];
    _bundle = AGX_RETAIN(AGXBundle.bundleNameAs(@"Resources"));
    _reader = [[AGXITFReader alloc] init];
}

- (void)tearDown {
    AGX_RELEASE(_bundle);
    AGX_RELEASE(_reader);
    [super tearDown];
}

- (void)testitf1 {
    _bundle.subpathAs(@"blackbox/itf-1");
    AGXGcodeResult *result = nil;
    NSError *error = nil;
    int all = 0, passed = 0;

    result = [_reader decode:_bundle.imageWithFile(@"1.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(@"30712345000010", result.text); passed++; }
    else XCTAssertEqual(AGXNotFoundError, error.code);
    all++;
    error = nil;
    result = [_reader decode:_bundle.imageWithFile(@"2.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(@"00012345678905", result.text); passed++; }
    else XCTAssertEqual(AGXNotFoundError, error.code);
    all++;
    error = nil;
    result = [_reader decode:_bundle.imageWithFile(@"3.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(@"0053611912", result.text); passed++; }
    else XCTAssertEqual(AGXNotFoundError, error.code);
    all++;
    error = nil;
    result = [_reader decode:_bundle.imageWithFile(@"5.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(@"0829220875", result.text); passed++; }
    else XCTAssertEqual(AGXNotFoundError, error.code);
    all++;
    error = nil;
    result = [_reader decode:_bundle.imageWithFile(@"6.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(@"0829220874", result.text); passed++; }
    else XCTAssertEqual(AGXNotFoundError, error.code);
    all++;
    error = nil;
    result = [_reader decode:_bundle.imageWithFile(@"7.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(@"0817605453", result.text); passed++; }
    else XCTAssertEqual(AGXNotFoundError, error.code);
    all++;
    error = nil;
    result = [_reader decode:_bundle.imageWithFile(@"8.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(@"0829220874", result.text); passed++; }
    else XCTAssertEqual(AGXNotFoundError, error.code);
    all++;
    error = nil;
    result = [_reader decode:_bundle.imageWithFile(@"9.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(@"0053611912", result.text); passed++; }
    else XCTAssertEqual(AGXNotFoundError, error.code);
    all++;
    error = nil;
    result = [_reader decode:_bundle.imageWithFile(@"10.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(@"0053611912", result.text); passed++; }
    else XCTAssertEqual(AGXNotFoundError, error.code);
    all++;
    error = nil;
    result = [_reader decode:_bundle.imageWithFile(@"13.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(@"0829220875", result.text); passed++; }
    else XCTAssertEqual(AGXNotFoundError, error.code);
    all++;
    error = nil;
    result = [_reader decode:_bundle.imageWithFile(@"14.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(@"0829220875", result.text); passed++; }
    else XCTAssertEqual(AGXNotFoundError, error.code);
    all++;
    error = nil;
    result = [_reader decode:_bundle.imageWithFile(@"15.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(@"0829220875", result.text); passed++; }
    else XCTAssertEqual(AGXNotFoundError, error.code);
    all++;
    error = nil;
    result = [_reader decode:_bundle.imageWithFile(@"16.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(@"0829220874", result.text); passed++; }
    else XCTAssertEqual(AGXNotFoundError, error.code);
    all++;
    error = nil;
    result = [_reader decode:_bundle.imageWithFile(@"17.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(@"3018108390", result.text); passed++; }
    else XCTAssertEqual(AGXNotFoundError, error.code);
    all++;
    error = nil;
    NSLog(@"%@:%@, all:%d, passed:%d", NSStringFromClass(self.class), NSStringFromSelector(_cmd), all, passed);
}

- (void)testitf2 {
    _bundle.subpathAs(@"blackbox/itf-2");
    AGXGcodeResult *result = nil;
    NSError *error = nil;
    int all = 0, passed = 0;

    result = [_reader decode:_bundle.imageWithFile(@"01.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(@"070429", result.text); passed++; }
    else XCTAssertEqual(AGXNotFoundError, error.code);
    all++;
    error = nil;
    result = [_reader decode:_bundle.imageWithFile(@"02.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(@"070429", result.text); passed++; }
    else XCTAssertEqual(AGXNotFoundError, error.code);
    all++;
    error = nil;
    result = [_reader decode:_bundle.imageWithFile(@"03.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(@"070429", result.text); passed++; }
    else XCTAssertEqual(AGXNotFoundError, error.code);
    all++;
    error = nil;
    result = [_reader decode:_bundle.imageWithFile(@"04.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(@"070429", result.text); passed++; }
    else XCTAssertEqual(AGXNotFoundError, error.code);
    all++;
    error = nil;
    result = [_reader decode:_bundle.imageWithFile(@"05.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(@"070429", result.text); passed++; }
    else XCTAssertEqual(AGXNotFoundError, error.code);
    all++;
    error = nil;
    result = [_reader decode:_bundle.imageWithFile(@"06.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(@"070429", result.text); passed++; }
    else XCTAssertEqual(AGXNotFoundError, error.code);
    all++;
    error = nil;
    result = [_reader decode:_bundle.imageWithFile(@"07.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(@"070429", result.text); passed++; }
    else XCTAssertEqual(AGXNotFoundError, error.code);
    all++;
    error = nil;
    result = [_reader decode:_bundle.imageWithFile(@"08.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(@"070429", result.text); passed++; }
    else XCTAssertEqual(AGXNotFoundError, error.code);
    all++;
    error = nil;
    result = [_reader decode:_bundle.imageWithFile(@"09.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(@"070429", result.text); passed++; }
    else XCTAssertEqual(AGXNotFoundError, error.code);
    all++;
    error = nil;
    result = [_reader decode:_bundle.imageWithFile(@"10.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(@"070429", result.text); passed++; }
    else XCTAssertEqual(AGXNotFoundError, error.code);
    all++;
    error = nil;
    result = [_reader decode:_bundle.imageWithFile(@"11.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(@"070429", result.text); passed++; }
    else XCTAssertEqual(AGXNotFoundError, error.code);
    all++;
    error = nil;
    result = [_reader decode:_bundle.imageWithFile(@"12.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(@"070429", result.text); passed++; }
    else XCTAssertEqual(AGXNotFoundError, error.code);
    all++;
    error = nil;
    result = [_reader decode:_bundle.imageWithFile(@"13.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(@"070429", result.text); passed++; }
    else XCTAssertEqual(AGXNotFoundError, error.code);
    all++;
    error = nil;
    NSLog(@"%@:%@, all:%d, passed:%d", NSStringFromClass(self.class), NSStringFromSelector(_cmd), all, passed);
}

@end
