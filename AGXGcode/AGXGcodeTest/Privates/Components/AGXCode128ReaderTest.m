//
//  AGXCode128ReaderTest.m
//  AGXGcode
//
//  Created by Char Aznable on 2016/8/1.
//  Copyright © 2016 github.com/CharLemAznable. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <AGXCore/AGXCore.h>
#import "AGXCode128Reader.h"
#import "AGXGcodeError.h"

@interface AGXCode128ReaderTest : XCTestCase
@property (nonatomic, AGX_STRONG) AGXResources *resources;
@property (nonatomic, AGX_STRONG) AGXCode128Reader *reader;
@end

@implementation AGXCode128ReaderTest

- (void)setUp {
    [super setUp];
    _resources = AGX_RETAIN(AGXResources.application.subpathAppendBundleNamed(@"Resources"));
    _reader = [[AGXCode128Reader alloc] init];
}

- (void)tearDown {
    AGX_RELEASE(_resources);
    AGX_RELEASE(_reader);
    [super tearDown];
}

- (void)testcode1281 {
    _resources.subpathAppend(@"blackbox/code128-1");
    AGXGcodeResult *result = nil;
    NSError *error = nil;
    int all = 0, passed = 0;

    result = [_reader decode:_resources.imageWithFileNamed(@"1.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(@"168901", result.text); passed++; }
    else XCTAssertEqual(AGXNotFoundError, error.code);
    all++;
    error = nil;
    result = [_reader decode:_resources.imageWithFileNamed(@"2.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(@"Code 128", result.text); passed++; }
    else XCTAssertEqual(AGXNotFoundError, error.code);
    all++;
    error = nil;
    result = [_reader decode:_resources.imageWithFileNamed(@"3.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(@"102030405060708090", result.text); passed++; }
    else XCTAssertEqual(AGXNotFoundError, error.code);
    all++;
    error = nil;
    result = [_reader decode:_resources.imageWithFileNamed(@"4.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(@"123456", result.text); passed++; }
    else XCTAssertEqual(AGXNotFoundError, error.code);
    all++;
    error = nil;
    result = [_reader decode:_resources.imageWithFileNamed(@"5.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(@"8101054321120021123456", result.text); passed++; }
    else XCTAssertEqual(AGXNotFoundError, error.code);
    all++;
    error = nil;
    result = [_reader decode:_resources.imageWithFileNamed(@"6.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(@"óóóó1234óóabózz", result.text); passed++; }
    else XCTAssertEqual(AGXNotFoundError, error.code);
    all++;
    error = nil;
    NSLog(@"%@:%@, all:%d, passed:%d", NSStringFromClass(self.class), NSStringFromSelector(_cmd), all, passed);
}

- (void)testcode1282 {
    _resources.subpathAppend(@"blackbox/code128-2");
    AGXGcodeResult *result = nil;
    NSError *error = nil;
    int all = 0, passed = 0;

    result = [_reader decode:_resources.imageWithFileNamed(@"01.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(@"005-3379497200006", result.text); passed++; }
    else XCTAssertEqual(AGXNotFoundError, error.code);
    all++;
    error = nil;
    result = [_reader decode:_resources.imageWithFileNamed(@"02.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(@"005-3379497200006", result.text); passed++; }
    else XCTAssertEqual(AGXNotFoundError, error.code);
    all++;
    error = nil;
    result = [_reader decode:_resources.imageWithFileNamed(@"03.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(@"005-3379497200006", result.text); passed++; }
    else XCTAssertEqual(AGXNotFoundError, error.code);
    all++;
    error = nil;
    result = [_reader decode:_resources.imageWithFileNamed(@"04.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(@"005-3379497200006", result.text); passed++; }
    else XCTAssertEqual(AGXNotFoundError, error.code);
    all++;
    error = nil;
    result = [_reader decode:_resources.imageWithFileNamed(@"05.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(@"15182881", result.text); passed++; }
    else XCTAssertEqual(AGXNotFoundError, error.code);
    all++;
    error = nil;
    result = [_reader decode:_resources.imageWithFileNamed(@"06.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(@"15182881", result.text); passed++; }
    else XCTAssertEqual(AGXNotFoundError, error.code);
    all++;
    error = nil;
    result = [_reader decode:_resources.imageWithFileNamed(@"07.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(@"15182881", result.text); passed++; }
    else XCTAssertEqual(AGXNotFoundError, error.code);
    all++;
    error = nil;
    result = [_reader decode:_resources.imageWithFileNamed(@"08.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(@"15182881", result.text); passed++; }
    else XCTAssertEqual(AGXNotFoundError, error.code);
    all++;
    error = nil;
    result = [_reader decode:_resources.imageWithFileNamed(@"09.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(@"CNK8181G2C", result.text); passed++; }
    else XCTAssertEqual(AGXNotFoundError, error.code);
    all++;
    error = nil;
    result = [_reader decode:_resources.imageWithFileNamed(@"10.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(@"CNK8181G2C", result.text); passed++; }
    else XCTAssertEqual(AGXNotFoundError, error.code);
    all++;
    error = nil;
    result = [_reader decode:_resources.imageWithFileNamed(@"11.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(@"CNK8181G2C", result.text); passed++; }
    else XCTAssertEqual(AGXNotFoundError, error.code);
    all++;
    error = nil;
    result = [_reader decode:_resources.imageWithFileNamed(@"12.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(@"CNK8181G2C", result.text); passed++; }
    else XCTAssertEqual(AGXNotFoundError, error.code);
    all++;
    error = nil;
    result = [_reader decode:_resources.imageWithFileNamed(@"13.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(@"1PEF224A4", result.text); passed++; }
    else XCTAssertEqual(AGXNotFoundError, error.code);
    all++;
    error = nil;
    result = [_reader decode:_resources.imageWithFileNamed(@"14.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(@"1PEF224A4", result.text); passed++; }
    else XCTAssertEqual(AGXNotFoundError, error.code);
    all++;
    error = nil;
    result = [_reader decode:_resources.imageWithFileNamed(@"15.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(@"1PEF224A4", result.text); passed++; }
    else XCTAssertEqual(AGXNotFoundError, error.code);
    all++;
    error = nil;
    result = [_reader decode:_resources.imageWithFileNamed(@"16.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(@"1PEF224A4", result.text); passed++; }
    else XCTAssertEqual(AGXNotFoundError, error.code);
    all++;
    error = nil;
    result = [_reader decode:_resources.imageWithFileNamed(@"17.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(@"FW727", result.text); passed++; }
    else XCTAssertEqual(AGXNotFoundError, error.code);
    all++;
    error = nil;
    result = [_reader decode:_resources.imageWithFileNamed(@"18.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(@"FW727", result.text); passed++; }
    else XCTAssertEqual(AGXNotFoundError, error.code);
    all++;
    error = nil;
    result = [_reader decode:_resources.imageWithFileNamed(@"19.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(@"FW727", result.text); passed++; }
    else XCTAssertEqual(AGXNotFoundError, error.code);
    all++;
    error = nil;
    result = [_reader decode:_resources.imageWithFileNamed(@"20.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(@"FW727", result.text); passed++; }
    else XCTAssertEqual(AGXNotFoundError, error.code);
    all++;
    error = nil;
    result = [_reader decode:_resources.imageWithFileNamed(@"21.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(@"005-3354174500018", result.text); passed++; }
    else XCTAssertEqual(AGXNotFoundError, error.code);
    all++;
    error = nil;
    result = [_reader decode:_resources.imageWithFileNamed(@"22.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(@"005-3354174500018", result.text); passed++; }
    else XCTAssertEqual(AGXNotFoundError, error.code);
    all++;
    error = nil;
    result = [_reader decode:_resources.imageWithFileNamed(@"23.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(@"005-3354174500018", result.text); passed++; }
    else XCTAssertEqual(AGXNotFoundError, error.code);
    all++;
    error = nil;
    result = [_reader decode:_resources.imageWithFileNamed(@"24.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(@"005-3354174500018", result.text); passed++; }
    else XCTAssertEqual(AGXNotFoundError, error.code);
    all++;
    error = nil;
    result = [_reader decode:_resources.imageWithFileNamed(@"25.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(@"31001171800000017989625355702636", result.text); passed++; }
    else XCTAssertEqual(AGXNotFoundError, error.code);
    all++;
    error = nil;
    result = [_reader decode:_resources.imageWithFileNamed(@"26.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(@"31001171800000017989625355702636", result.text); passed++; }
    else XCTAssertEqual(AGXNotFoundError, error.code);
    all++;
    error = nil;
    result = [_reader decode:_resources.imageWithFileNamed(@"27.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(@"31001171800000017989625355702636", result.text); passed++; }
    else XCTAssertEqual(AGXNotFoundError, error.code);
    all++;
    error = nil;
    result = [_reader decode:_resources.imageWithFileNamed(@"28.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(@"31001171800000017989625355702636", result.text); passed++; }
    else XCTAssertEqual(AGXNotFoundError, error.code);
    all++;
    error = nil;
    result = [_reader decode:_resources.imageWithFileNamed(@"29.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(@"42094043", result.text); passed++; }
    else XCTAssertEqual(AGXNotFoundError, error.code);
    all++;
    error = nil;
    result = [_reader decode:_resources.imageWithFileNamed(@"30.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(@"42094043", result.text); passed++; }
    else XCTAssertEqual(AGXNotFoundError, error.code);
    all++;
    error = nil;
    result = [_reader decode:_resources.imageWithFileNamed(@"31.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(@"42094043", result.text); passed++; }
    else XCTAssertEqual(AGXNotFoundError, error.code);
    all++;
    error = nil;
    result = [_reader decode:_resources.imageWithFileNamed(@"32.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(@"42094043", result.text); passed++; }
    else XCTAssertEqual(AGXNotFoundError, error.code);
    all++;
    error = nil;
    result = [_reader decode:_resources.imageWithFileNamed(@"33.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(@"30885909173823", result.text); passed++; }
    else XCTAssertEqual(AGXNotFoundError, error.code);
    all++;
    error = nil;
    result = [_reader decode:_resources.imageWithFileNamed(@"34.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(@"30885909173823", result.text); passed++; }
    else XCTAssertEqual(AGXNotFoundError, error.code);
    all++;
    error = nil;
    result = [_reader decode:_resources.imageWithFileNamed(@"35.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(@"30885909173823", result.text); passed++; }
    else XCTAssertEqual(AGXNotFoundError, error.code);
    all++;
    error = nil;
    result = [_reader decode:_resources.imageWithFileNamed(@"36.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(@"30885909173823", result.text); passed++; }
    else XCTAssertEqual(AGXNotFoundError, error.code);
    all++;
    error = nil;
    result = [_reader decode:_resources.imageWithFileNamed(@"37.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(@"FGGQ6D1", result.text); passed++; }
    else XCTAssertEqual(AGXNotFoundError, error.code);
    all++;
    error = nil;
    result = [_reader decode:_resources.imageWithFileNamed(@"38.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(@"FGGQ6D1", result.text); passed++; }
    else XCTAssertEqual(AGXNotFoundError, error.code);
    all++;
    error = nil;
    result = [_reader decode:_resources.imageWithFileNamed(@"39.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(@"FGGQ6D1", result.text); passed++; }
    else XCTAssertEqual(AGXNotFoundError, error.code);
    all++;
    error = nil;
    result = [_reader decode:_resources.imageWithFileNamed(@"40.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(@"FGGQ6D1", result.text); passed++; }
    else XCTAssertEqual(AGXNotFoundError, error.code);
    all++;
    error = nil;
    NSLog(@"%@:%@, all:%d, passed:%d", NSStringFromClass(self.class), NSStringFromSelector(_cmd), all, passed);
}

- (void)testcode1283 {
    _resources.subpathAppend(@"blackbox/code128-3");
    AGXGcodeResult *result = nil;
    NSError *error = nil;
    int all = 0, passed = 0;

    result = [_reader decode:_resources.imageWithFileNamed(@"1.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(@"10064908", result.text); passed++; }
    else XCTAssertEqual(AGXNotFoundError, error.code);
    all++;
    error = nil;
    result = [_reader decode:_resources.imageWithFileNamed(@"2.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(@"10068408", result.text); passed++; }
    else XCTAssertEqual(AGXNotFoundError, error.code);
    all++;
    error = nil;
    NSLog(@"%@:%@, all:%d, passed:%d", NSStringFromClass(self.class), NSStringFromSelector(_cmd), all, passed);
}

@end
