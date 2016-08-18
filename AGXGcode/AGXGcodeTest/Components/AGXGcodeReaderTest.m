//
//  AGXGcodeReaderTest.m
//  AGXGcode
//
//  Created by Char Aznable on 16/8/10.
//  Copyright © 2016年 AI-CUC-EC. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <AGXCore/AGXCore.h>
#import "AGXGcodeReader.h"
#import "AGXGcodeError.h"

@interface AGXGcodeReaderTest : XCTestCase
@property (nonatomic, AGX_STRONG) AGXBundle *bundle;
@property (nonatomic, AGX_STRONG) AGXGcodeReader *reader;
@end

@implementation AGXGcodeReaderTest

- (void)setUp {
    [super setUp];
    _bundle = AGX_RETAIN(AGXBundle.bundleNameAs(@"Resources"));
    _reader = [[AGXGcodeReader alloc] init];
}

- (void)tearDown {
    AGX_RELEASE(_bundle);
    AGX_RELEASE(_reader);
    [super tearDown];
}

- (void)testupce1 {
    _bundle.subpathAs(@"blackbox/upce-1");
    AGXGcodeResult *result = nil;
    NSError *error = nil;
    int all = 0, passed = 0;

    result = [_reader decode:_bundle.imageWithFile(@"1.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(@"01234565", result.text); passed++; }
    else XCTAssertEqual(AGXNotFoundError, error.code);
    all++;
    error = nil;
    result = [_reader decode:_bundle.imageWithFile(@"2.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(@"00123457", result.text); passed++; }
    else XCTAssertEqual(AGXNotFoundError, error.code);
    all++;
    error = nil;
    result = [_reader decode:_bundle.imageWithFile(@"4.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(@"01234531", result.text); passed++; }
    else XCTAssertEqual(AGXNotFoundError, error.code);
    all++;
    error = nil;
    NSLog(@"%@:%@, all:%d, passed:%d", NSStringFromClass([self class]), NSStringFromSelector(_cmd), all, passed);
}

- (void)testupce2 {
    _bundle.subpathAs(@"blackbox/upce-2");
    AGXGcodeResult *result = nil;
    NSError *error = nil;
    int all = 0, passed = 0;

    result = [_reader decode:_bundle.imageWithFile(@"01.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(@"05096893", result.text); passed++; }
    else XCTAssertEqual(AGXNotFoundError, error.code);
    all++;
    error = nil;
    result = [_reader decode:_bundle.imageWithFile(@"02.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(@"05096893", result.text); passed++; }
    else XCTAssertEqual(AGXNotFoundError, error.code);
    all++;
    error = nil;
    result = [_reader decode:_bundle.imageWithFile(@"03.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(@"05096893", result.text); passed++; }
    else XCTAssertEqual(AGXNotFoundError, error.code);
    all++;
    error = nil;
    result = [_reader decode:_bundle.imageWithFile(@"04.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(@"05096893", result.text); passed++; }
    else XCTAssertEqual(AGXNotFoundError, error.code);
    all++;
    error = nil;
    result = [_reader decode:_bundle.imageWithFile(@"05.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(@"05096893", result.text); passed++; }
    else XCTAssertEqual(AGXNotFoundError, error.code);
    all++;
    error = nil;
    result = [_reader decode:_bundle.imageWithFile(@"06.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(@"05096893", result.text); passed++; }
    else XCTAssertEqual(AGXNotFoundError, error.code);
    all++;
    error = nil;
    result = [_reader decode:_bundle.imageWithFile(@"07.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(@"05096893", result.text); passed++; }
    else XCTAssertEqual(AGXNotFoundError, error.code);
    all++;
    error = nil;
    result = [_reader decode:_bundle.imageWithFile(@"08.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(@"04963406", result.text); passed++; }
    else XCTAssertEqual(AGXNotFoundError, error.code);
    all++;
    error = nil;
    result = [_reader decode:_bundle.imageWithFile(@"09.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(@"04963406", result.text); passed++; }
    else XCTAssertEqual(AGXNotFoundError, error.code);
    all++;
    error = nil;
    result = [_reader decode:_bundle.imageWithFile(@"10.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(@"04963406", result.text); passed++; }
    else XCTAssertEqual(AGXNotFoundError, error.code);
    all++;
    error = nil;
    result = [_reader decode:_bundle.imageWithFile(@"11.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(@"04963406", result.text); passed++; }
    else XCTAssertEqual(AGXNotFoundError, error.code);
    all++;
    error = nil;
    result = [_reader decode:_bundle.imageWithFile(@"12.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(@"04963406", result.text); passed++; }
    else XCTAssertEqual(AGXNotFoundError, error.code);
    all++;
    error = nil;
    result = [_reader decode:_bundle.imageWithFile(@"13.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(@"04963406", result.text); passed++; }
    else XCTAssertEqual(AGXNotFoundError, error.code);
    all++;
    error = nil;
    result = [_reader decode:_bundle.imageWithFile(@"14.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(@"04963406", result.text); passed++; }
    else XCTAssertEqual(AGXNotFoundError, error.code);
    all++;
    error = nil;
    result = [_reader decode:_bundle.imageWithFile(@"15.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(@"04963406", result.text); passed++; }
    else XCTAssertEqual(AGXNotFoundError, error.code);
    all++;
    error = nil;
    result = [_reader decode:_bundle.imageWithFile(@"16.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(@"04124498", result.text); passed++; }
    else XCTAssertEqual(AGXNotFoundError, error.code);
    all++;
    error = nil;
    result = [_reader decode:_bundle.imageWithFile(@"17.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(@"04124498", result.text); passed++; }
    else XCTAssertEqual(AGXNotFoundError, error.code);
    all++;
    error = nil;
    result = [_reader decode:_bundle.imageWithFile(@"18.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(@"04124498", result.text); passed++; }
    else XCTAssertEqual(AGXNotFoundError, error.code);
    all++;
    error = nil;
    result = [_reader decode:_bundle.imageWithFile(@"19.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(@"04124498", result.text); passed++; }
    else XCTAssertEqual(AGXNotFoundError, error.code);
    all++;
    error = nil;
    result = [_reader decode:_bundle.imageWithFile(@"20.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(@"04124498", result.text); passed++; }
    else XCTAssertEqual(AGXNotFoundError, error.code);
    all++;
    error = nil;
    result = [_reader decode:_bundle.imageWithFile(@"21.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(@"04124498", result.text); passed++; }
    else XCTAssertEqual(AGXNotFoundError, error.code);
    all++;
    error = nil;
    result = [_reader decode:_bundle.imageWithFile(@"22.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(@"04124498", result.text); passed++; }
    else XCTAssertEqual(AGXNotFoundError, error.code);
    all++;
    error = nil;
    result = [_reader decode:_bundle.imageWithFile(@"23.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(@"04124498", result.text); passed++; }
    else XCTAssertEqual(AGXNotFoundError, error.code);
    all++;
    error = nil;
    result = [_reader decode:_bundle.imageWithFile(@"24.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(@"04124498", result.text); passed++; }
    else XCTAssertEqual(AGXNotFoundError, error.code);
    all++;
    error = nil;
    result = [_reader decode:_bundle.imageWithFile(@"25.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(@"04124498", result.text); passed++; }
    else XCTAssertEqual(AGXNotFoundError, error.code);
    all++;
    error = nil;
    result = [_reader decode:_bundle.imageWithFile(@"26.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(@"04124498", result.text); passed++; }
    else XCTAssertEqual(AGXNotFoundError, error.code);
    all++;
    error = nil;
    result = [_reader decode:_bundle.imageWithFile(@"27.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(@"04124498", result.text); passed++; }
    else XCTAssertEqual(AGXNotFoundError, error.code);
    all++;
    error = nil;
    result = [_reader decode:_bundle.imageWithFile(@"28.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(@"04124498", result.text); passed++; }
    else XCTAssertEqual(AGXNotFoundError, error.code);
    all++;
    error = nil;
    result = [_reader decode:_bundle.imageWithFile(@"29.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(@"04124498", result.text); passed++; }
    else XCTAssertEqual(AGXNotFoundError, error.code);
    all++;
    error = nil;
    result = [_reader decode:_bundle.imageWithFile(@"30.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(@"04124498", result.text); passed++; }
    else XCTAssertEqual(AGXNotFoundError, error.code);
    all++;
    error = nil;
    result = [_reader decode:_bundle.imageWithFile(@"31.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(@"01264904", result.text); passed++; }
    else XCTAssertEqual(AGXNotFoundError, error.code);
    all++;
    error = nil;
    result = [_reader decode:_bundle.imageWithFile(@"32.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(@"01264904", result.text); passed++; }
    else XCTAssertEqual(AGXNotFoundError, error.code);
    all++;
    error = nil;
    result = [_reader decode:_bundle.imageWithFile(@"33.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(@"01264904", result.text); passed++; }
    else XCTAssertEqual(AGXNotFoundError, error.code);
    all++;
    error = nil;
    result = [_reader decode:_bundle.imageWithFile(@"34.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(@"01264904", result.text); passed++; }
    else XCTAssertEqual(AGXNotFoundError, error.code);
    all++;
    error = nil;
    result = [_reader decode:_bundle.imageWithFile(@"35.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(@"01264904", result.text); passed++; }
    else XCTAssertEqual(AGXNotFoundError, error.code);
    all++;
    error = nil;
    result = [_reader decode:_bundle.imageWithFile(@"36.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(@"01264904", result.text); passed++; }
    else XCTAssertEqual(AGXNotFoundError, error.code);
    all++;
    error = nil;
    result = [_reader decode:_bundle.imageWithFile(@"37.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(@"01264904", result.text); passed++; }
    else XCTAssertEqual(AGXNotFoundError, error.code);
    all++;
    error = nil;
    result = [_reader decode:_bundle.imageWithFile(@"38.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(@"01264904", result.text); passed++; }
    else XCTAssertEqual(AGXNotFoundError, error.code);
    all++;
    error = nil;
    result = [_reader decode:_bundle.imageWithFile(@"39.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(@"01264904", result.text); passed++; }
    else XCTAssertEqual(AGXNotFoundError, error.code);
    all++;
    error = nil;
    result = [_reader decode:_bundle.imageWithFile(@"40.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(@"01264904", result.text); passed++; }
    else XCTAssertEqual(AGXNotFoundError, error.code);
    all++;
    error = nil;
    result = [_reader decode:_bundle.imageWithFile(@"41.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(@"01264904", result.text); passed++; }
    else XCTAssertEqual(AGXNotFoundError, error.code);
    all++;
    error = nil;
    NSLog(@"%@:%@, all:%d, passed:%d", NSStringFromClass([self class]), NSStringFromSelector(_cmd), all, passed);
}

- (void)testupce3 {
    _bundle.subpathAs(@"blackbox/upce-3");
    AGXGcodeResult *result = nil;
    NSError *error = nil;
    int all = 0, passed = 0;

    result = [_reader decode:_bundle.imageWithFile(@"01.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(@"04965802", result.text); passed++; }
    else XCTAssertEqual(AGXNotFoundError, error.code);
    all++;
    error = nil;
    result = [_reader decode:_bundle.imageWithFile(@"02.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(@"04965802", result.text); passed++; }
    else XCTAssertEqual(AGXNotFoundError, error.code);
    all++;
    error = nil;
    result = [_reader decode:_bundle.imageWithFile(@"03.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(@"04965802", result.text); passed++; }
    else XCTAssertEqual(AGXNotFoundError, error.code);
    all++;
    error = nil;
    result = [_reader decode:_bundle.imageWithFile(@"04.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(@"04965802", result.text); passed++; }
    else XCTAssertEqual(AGXNotFoundError, error.code);
    all++;
    error = nil;
    result = [_reader decode:_bundle.imageWithFile(@"05.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(@"04965802", result.text); passed++; }
    else XCTAssertEqual(AGXNotFoundError, error.code);
    all++;
    error = nil;
    result = [_reader decode:_bundle.imageWithFile(@"06.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(@"04965802", result.text); passed++; }
    else XCTAssertEqual(AGXNotFoundError, error.code);
    all++;
    error = nil;
    result = [_reader decode:_bundle.imageWithFile(@"07.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(@"04965802", result.text); passed++; }
    else XCTAssertEqual(AGXNotFoundError, error.code);
    all++;
    error = nil;
    result = [_reader decode:_bundle.imageWithFile(@"08.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(@"04965802", result.text); passed++; }
    else XCTAssertEqual(AGXNotFoundError, error.code);
    all++;
    error = nil;
    result = [_reader decode:_bundle.imageWithFile(@"09.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(@"04965802", result.text); passed++; }
    else XCTAssertEqual(AGXNotFoundError, error.code);
    all++;
    error = nil;
    result = [_reader decode:_bundle.imageWithFile(@"10.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(@"04965802", result.text); passed++; }
    else XCTAssertEqual(AGXNotFoundError, error.code);
    all++;
    error = nil;
    result = [_reader decode:_bundle.imageWithFile(@"11.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(@"04965802", result.text); passed++; }
    else XCTAssertEqual(AGXNotFoundError, error.code);
    all++;
    error = nil;
    NSLog(@"%@:%@, all:%d, passed:%d", NSStringFromClass([self class]), NSStringFromSelector(_cmd), all, passed);
}

- (void)testupca1 {
    _bundle.subpathAs(@"blackbox/upca-1");
    AGXGcodeResult *result = nil;
    NSError *error = nil;
    int all = 0, passed = 0;

    result = [_reader decode:_bundle.imageWithFile(@"1.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(@"036602301467", result.text); passed++; }
    else XCTAssertEqual(AGXNotFoundError, error.code);
    all++;
    error = nil;
    result = [_reader decode:_bundle.imageWithFile(@"2.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(@"036602301467", result.text); passed++; }
    else XCTAssertEqual(AGXNotFoundError, error.code);
    all++;
    error = nil;
    result = [_reader decode:_bundle.imageWithFile(@"3.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(@"070097025088", result.text); passed++; }
    else XCTAssertEqual(AGXNotFoundError, error.code);
    all++;
    error = nil;
    result = [_reader decode:_bundle.imageWithFile(@"4.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(@"070097025088", result.text); passed++; }
    else XCTAssertEqual(AGXNotFoundError, error.code);
    all++;
    error = nil;
    result = [_reader decode:_bundle.imageWithFile(@"5.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(@"070097025088", result.text); passed++; }
    else XCTAssertEqual(AGXNotFoundError, error.code);
    all++;
    error = nil;
    result = [_reader decode:_bundle.imageWithFile(@"8.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(@"071831007995", result.text); passed++; }
    else XCTAssertEqual(AGXNotFoundError, error.code);
    all++;
    error = nil;
    result = [_reader decode:_bundle.imageWithFile(@"9.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(@"071831007995", result.text); passed++; }
    else XCTAssertEqual(AGXNotFoundError, error.code);
    all++;
    error = nil;
    result = [_reader decode:_bundle.imageWithFile(@"10.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(@"027011006951", result.text); passed++; }
    else XCTAssertEqual(AGXNotFoundError, error.code);
    all++;
    error = nil;
    result = [_reader decode:_bundle.imageWithFile(@"11.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(@"027011006951", result.text); passed++; }
    else XCTAssertEqual(AGXNotFoundError, error.code);
    all++;
    error = nil;
    result = [_reader decode:_bundle.imageWithFile(@"12.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(@"781735802045", result.text); passed++; }
    else XCTAssertEqual(AGXNotFoundError, error.code);
    all++;
    error = nil;
    result = [_reader decode:_bundle.imageWithFile(@"13.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(@"781735802045", result.text); passed++; }
    else XCTAssertEqual(AGXNotFoundError, error.code);
    all++;
    error = nil;
    result = [_reader decode:_bundle.imageWithFile(@"16.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(@"456314319671", result.text); passed++; }
    else XCTAssertEqual(AGXNotFoundError, error.code);
    all++;
    error = nil;
    result = [_reader decode:_bundle.imageWithFile(@"17.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(@"434704791429", result.text); passed++; }
    else XCTAssertEqual(AGXNotFoundError, error.code);
    all++;
    error = nil;
    result = [_reader decode:_bundle.imageWithFile(@"18.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(@"024543136538", result.text); passed++; }
    else XCTAssertEqual(AGXNotFoundError, error.code);
    all++;
    error = nil;
    result = [_reader decode:_bundle.imageWithFile(@"19.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(@"024543136538", result.text); passed++; }
    else XCTAssertEqual(AGXNotFoundError, error.code);
    all++;
    error = nil;
    result = [_reader decode:_bundle.imageWithFile(@"20.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(@"752919460009", result.text); passed++; }
    else XCTAssertEqual(AGXNotFoundError, error.code);
    all++;
    error = nil;
    result = [_reader decode:_bundle.imageWithFile(@"21.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(@"752919460009", result.text); passed++; }
    else XCTAssertEqual(AGXNotFoundError, error.code);
    all++;
    error = nil;
    result = [_reader decode:_bundle.imageWithFile(@"27.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(@"606949762520", result.text); passed++; }
    else XCTAssertEqual(AGXNotFoundError, error.code);
    all++;
    error = nil;
    result = [_reader decode:_bundle.imageWithFile(@"28.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(@"061869053712", result.text); passed++; }
    else XCTAssertEqual(AGXNotFoundError, error.code);
    all++;
    error = nil;
    result = [_reader decode:_bundle.imageWithFile(@"29.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(@"619659023935", result.text); passed++; }
    else XCTAssertEqual(AGXNotFoundError, error.code);
    all++;
    error = nil;
    result = [_reader decode:_bundle.imageWithFile(@"35.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(@"045496442736", result.text); passed++; }
    else XCTAssertEqual(AGXNotFoundError, error.code);
    all++;
    error = nil;
    NSLog(@"%@:%@, all:%d, passed:%d", NSStringFromClass([self class]), NSStringFromSelector(_cmd), all, passed);
}

- (void)testupca2 {
    _bundle.subpathAs(@"blackbox/upca-2");
    AGXGcodeResult *result = nil;
    NSError *error = nil;
    int all = 0, passed = 0;

    result = [_reader decode:_bundle.imageWithFile(@"01.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(@"890444000335", result.text); passed++; }
    else XCTAssertEqual(AGXNotFoundError, error.code);
    all++;
    error = nil;
    result = [_reader decode:_bundle.imageWithFile(@"02.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(@"890444000335", result.text); passed++; }
    else XCTAssertEqual(AGXNotFoundError, error.code);
    all++;
    error = nil;
    result = [_reader decode:_bundle.imageWithFile(@"03.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(@"890444000335", result.text); passed++; }
    else XCTAssertEqual(AGXNotFoundError, error.code);
    all++;
    error = nil;
    result = [_reader decode:_bundle.imageWithFile(@"04.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(@"890444000335", result.text); passed++; }
    else XCTAssertEqual(AGXNotFoundError, error.code);
    all++;
    error = nil;
    result = [_reader decode:_bundle.imageWithFile(@"05.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(@"890444000335", result.text); passed++; }
    else XCTAssertEqual(AGXNotFoundError, error.code);
    all++;
    error = nil;
    result = [_reader decode:_bundle.imageWithFile(@"06.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(@"890444000335", result.text); passed++; }
    else XCTAssertEqual(AGXNotFoundError, error.code);
    all++;
    error = nil;
    result = [_reader decode:_bundle.imageWithFile(@"07.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(@"890444000335", result.text); passed++; }
    else XCTAssertEqual(AGXNotFoundError, error.code);
    all++;
    error = nil;
    result = [_reader decode:_bundle.imageWithFile(@"08.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(@"181497000879", result.text); passed++; }
    else XCTAssertEqual(AGXNotFoundError, error.code);
    all++;
    error = nil;
    result = [_reader decode:_bundle.imageWithFile(@"09.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(@"181497000879", result.text); passed++; }
    else XCTAssertEqual(AGXNotFoundError, error.code);
    all++;
    error = nil;
    result = [_reader decode:_bundle.imageWithFile(@"10.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(@"181497000879", result.text); passed++; }
    else XCTAssertEqual(AGXNotFoundError, error.code);
    all++;
    error = nil;
    result = [_reader decode:_bundle.imageWithFile(@"11.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(@"181497000879", result.text); passed++; }
    else XCTAssertEqual(AGXNotFoundError, error.code);
    all++;
    error = nil;
    result = [_reader decode:_bundle.imageWithFile(@"12.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(@"181497000879", result.text); passed++; }
    else XCTAssertEqual(AGXNotFoundError, error.code);
    all++;
    error = nil;
    result = [_reader decode:_bundle.imageWithFile(@"13.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(@"181497000879", result.text); passed++; }
    else XCTAssertEqual(AGXNotFoundError, error.code);
    all++;
    error = nil;
    result = [_reader decode:_bundle.imageWithFile(@"14.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(@"051000000675", result.text); passed++; }
    else XCTAssertEqual(AGXNotFoundError, error.code);
    all++;
    error = nil;
    result = [_reader decode:_bundle.imageWithFile(@"15.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(@"051000000675", result.text); passed++; }
    else XCTAssertEqual(AGXNotFoundError, error.code);
    all++;
    error = nil;
    result = [_reader decode:_bundle.imageWithFile(@"16.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(@"051000000675", result.text); passed++; }
    else XCTAssertEqual(AGXNotFoundError, error.code);
    all++;
    error = nil;
    result = [_reader decode:_bundle.imageWithFile(@"17.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(@"051000000675", result.text); passed++; }
    else XCTAssertEqual(AGXNotFoundError, error.code);
    all++;
    error = nil;
    result = [_reader decode:_bundle.imageWithFile(@"18.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(@"051000000675", result.text); passed++; }
    else XCTAssertEqual(AGXNotFoundError, error.code);
    all++;
    error = nil;
    result = [_reader decode:_bundle.imageWithFile(@"19.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(@"051000000675", result.text); passed++; }
    else XCTAssertEqual(AGXNotFoundError, error.code);
    all++;
    error = nil;
    result = [_reader decode:_bundle.imageWithFile(@"20.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(@"051000000675", result.text); passed++; }
    else XCTAssertEqual(AGXNotFoundError, error.code);
    all++;
    error = nil;
    result = [_reader decode:_bundle.imageWithFile(@"21.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(@"051000000675", result.text); passed++; }
    else XCTAssertEqual(AGXNotFoundError, error.code);
    all++;
    error = nil;
    result = [_reader decode:_bundle.imageWithFile(@"22.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(@"051000000675", result.text); passed++; }
    else XCTAssertEqual(AGXNotFoundError, error.code);
    all++;
    error = nil;
    result = [_reader decode:_bundle.imageWithFile(@"23.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(@"752050200137", result.text); passed++; }
    else XCTAssertEqual(AGXNotFoundError, error.code);
    all++;
    error = nil;
    result = [_reader decode:_bundle.imageWithFile(@"24.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(@"752050200137", result.text); passed++; }
    else XCTAssertEqual(AGXNotFoundError, error.code);
    all++;
    error = nil;
    result = [_reader decode:_bundle.imageWithFile(@"25.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(@"752050200137", result.text); passed++; }
    else XCTAssertEqual(AGXNotFoundError, error.code);
    all++;
    error = nil;
    result = [_reader decode:_bundle.imageWithFile(@"26.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(@"752050200137", result.text); passed++; }
    else XCTAssertEqual(AGXNotFoundError, error.code);
    all++;
    error = nil;
    result = [_reader decode:_bundle.imageWithFile(@"27.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(@"752050200137", result.text); passed++; }
    else XCTAssertEqual(AGXNotFoundError, error.code);
    all++;
    error = nil;
    result = [_reader decode:_bundle.imageWithFile(@"28.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(@"752050200137", result.text); passed++; }
    else XCTAssertEqual(AGXNotFoundError, error.code);
    all++;
    error = nil;
    result = [_reader decode:_bundle.imageWithFile(@"29.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(@"752050200137", result.text); passed++; }
    else XCTAssertEqual(AGXNotFoundError, error.code);
    all++;
    error = nil;
    result = [_reader decode:_bundle.imageWithFile(@"30.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(@"752050200137", result.text); passed++; }
    else XCTAssertEqual(AGXNotFoundError, error.code);
    all++;
    error = nil;
    result = [_reader decode:_bundle.imageWithFile(@"31.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(@"899684001003", result.text); passed++; }
    else XCTAssertEqual(AGXNotFoundError, error.code);
    all++;
    error = nil;
    result = [_reader decode:_bundle.imageWithFile(@"32.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(@"899684001003", result.text); passed++; }
    else XCTAssertEqual(AGXNotFoundError, error.code);
    all++;
    error = nil;
    result = [_reader decode:_bundle.imageWithFile(@"33.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(@"899684001003", result.text); passed++; }
    else XCTAssertEqual(AGXNotFoundError, error.code);
    all++;
    error = nil;
    result = [_reader decode:_bundle.imageWithFile(@"34.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(@"899684001003", result.text); passed++; }
    else XCTAssertEqual(AGXNotFoundError, error.code);
    all++;
    error = nil;
    result = [_reader decode:_bundle.imageWithFile(@"35.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(@"899684001003", result.text); passed++; }
    else XCTAssertEqual(AGXNotFoundError, error.code);
    all++;
    error = nil;
    result = [_reader decode:_bundle.imageWithFile(@"36.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(@"899684001003", result.text); passed++; }
    else XCTAssertEqual(AGXNotFoundError, error.code);
    all++;
    error = nil;
    result = [_reader decode:_bundle.imageWithFile(@"37.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(@"899684001003", result.text); passed++; }
    else XCTAssertEqual(AGXNotFoundError, error.code);
    all++;
    error = nil;
    result = [_reader decode:_bundle.imageWithFile(@"38.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(@"012546619592", result.text); passed++; }
    else XCTAssertEqual(AGXNotFoundError, error.code);
    all++;
    error = nil;
    result = [_reader decode:_bundle.imageWithFile(@"39.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(@"012546619592", result.text); passed++; }
    else XCTAssertEqual(AGXNotFoundError, error.code);
    all++;
    error = nil;
    result = [_reader decode:_bundle.imageWithFile(@"40.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(@"012546619592", result.text); passed++; }
    else XCTAssertEqual(AGXNotFoundError, error.code);
    all++;
    error = nil;
    result = [_reader decode:_bundle.imageWithFile(@"41.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(@"012546619592", result.text); passed++; }
    else XCTAssertEqual(AGXNotFoundError, error.code);
    all++;
    error = nil;
    result = [_reader decode:_bundle.imageWithFile(@"42.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(@"012546619592", result.text); passed++; }
    else XCTAssertEqual(AGXNotFoundError, error.code);
    all++;
    error = nil;
    result = [_reader decode:_bundle.imageWithFile(@"43.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(@"012546619592", result.text); passed++; }
    else XCTAssertEqual(AGXNotFoundError, error.code);
    all++;
    error = nil;
    result = [_reader decode:_bundle.imageWithFile(@"44.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(@"012546619592", result.text); passed++; }
    else XCTAssertEqual(AGXNotFoundError, error.code);
    all++;
    error = nil;
    result = [_reader decode:_bundle.imageWithFile(@"45.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(@"075720003259", result.text); passed++; }
    else XCTAssertEqual(AGXNotFoundError, error.code);
    all++;
    error = nil;
    result = [_reader decode:_bundle.imageWithFile(@"46.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(@"075720003259", result.text); passed++; }
    else XCTAssertEqual(AGXNotFoundError, error.code);
    all++;
    error = nil;
    result = [_reader decode:_bundle.imageWithFile(@"47.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(@"075720003259", result.text); passed++; }
    else XCTAssertEqual(AGXNotFoundError, error.code);
    all++;
    error = nil;
    result = [_reader decode:_bundle.imageWithFile(@"48.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(@"075720003259", result.text); passed++; }
    else XCTAssertEqual(AGXNotFoundError, error.code);
    all++;
    error = nil;
    result = [_reader decode:_bundle.imageWithFile(@"49.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(@"075720003259", result.text); passed++; }
    else XCTAssertEqual(AGXNotFoundError, error.code);
    all++;
    error = nil;
    result = [_reader decode:_bundle.imageWithFile(@"50.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(@"075720003259", result.text); passed++; }
    else XCTAssertEqual(AGXNotFoundError, error.code);
    all++;
    error = nil;
    result = [_reader decode:_bundle.imageWithFile(@"51.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(@"075720003259", result.text); passed++; }
    else XCTAssertEqual(AGXNotFoundError, error.code);
    all++;
    error = nil;
    result = [_reader decode:_bundle.imageWithFile(@"52.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(@"075720003259", result.text); passed++; }
    else XCTAssertEqual(AGXNotFoundError, error.code);
    all++;
    error = nil;
    NSLog(@"%@:%@, all:%d, passed:%d", NSStringFromClass([self class]), NSStringFromSelector(_cmd), all, passed);
}

- (void)testupca3 {
    _bundle.subpathAs(@"blackbox/upca-3");
    AGXGcodeResult *result = nil;
    NSError *error = nil;
    int all = 0, passed = 0;

    result = [_reader decode:_bundle.imageWithFile(@"01.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(@"049000042566", result.text); passed++; }
    else XCTAssertEqual(AGXNotFoundError, error.code);
    all++;
    error = nil;
    result = [_reader decode:_bundle.imageWithFile(@"02.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(@"049000042566", result.text); passed++; }
    else XCTAssertEqual(AGXNotFoundError, error.code);
    all++;
    error = nil;
    result = [_reader decode:_bundle.imageWithFile(@"03.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(@"049000042566", result.text); passed++; }
    else XCTAssertEqual(AGXNotFoundError, error.code);
    all++;
    error = nil;
    result = [_reader decode:_bundle.imageWithFile(@"04.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(@"049000042566", result.text); passed++; }
    else XCTAssertEqual(AGXNotFoundError, error.code);
    all++;
    error = nil;
    result = [_reader decode:_bundle.imageWithFile(@"05.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(@"049000042566", result.text); passed++; }
    else XCTAssertEqual(AGXNotFoundError, error.code);
    all++;
    error = nil;
    result = [_reader decode:_bundle.imageWithFile(@"06.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(@"049000042566", result.text); passed++; }
    else XCTAssertEqual(AGXNotFoundError, error.code);
    all++;
    error = nil;
    result = [_reader decode:_bundle.imageWithFile(@"07.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(@"049000042566", result.text); passed++; }
    else XCTAssertEqual(AGXNotFoundError, error.code);
    all++;
    error = nil;
    result = [_reader decode:_bundle.imageWithFile(@"08.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(@"049000042566", result.text); passed++; }
    else XCTAssertEqual(AGXNotFoundError, error.code);
    all++;
    error = nil;
    result = [_reader decode:_bundle.imageWithFile(@"09.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(@"049000042566", result.text); passed++; }
    else XCTAssertEqual(AGXNotFoundError, error.code);
    all++;
    error = nil;
    result = [_reader decode:_bundle.imageWithFile(@"10.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(@"049000042566", result.text); passed++; }
    else XCTAssertEqual(AGXNotFoundError, error.code);
    all++;
    error = nil;
    result = [_reader decode:_bundle.imageWithFile(@"11.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(@"854818000116", result.text); passed++; }
    else XCTAssertEqual(AGXNotFoundError, error.code);
    all++;
    error = nil;
    result = [_reader decode:_bundle.imageWithFile(@"12.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(@"854818000116", result.text); passed++; }
    else XCTAssertEqual(AGXNotFoundError, error.code);
    all++;
    error = nil;
    result = [_reader decode:_bundle.imageWithFile(@"13.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(@"854818000116", result.text); passed++; }
    else XCTAssertEqual(AGXNotFoundError, error.code);
    all++;
    error = nil;
    result = [_reader decode:_bundle.imageWithFile(@"14.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(@"854818000116", result.text); passed++; }
    else XCTAssertEqual(AGXNotFoundError, error.code);
    all++;
    error = nil;
    result = [_reader decode:_bundle.imageWithFile(@"15.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(@"854818000116", result.text); passed++; }
    else XCTAssertEqual(AGXNotFoundError, error.code);
    all++;
    error = nil;
    result = [_reader decode:_bundle.imageWithFile(@"16.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(@"854818000116", result.text); passed++; }
    else XCTAssertEqual(AGXNotFoundError, error.code);
    all++;
    error = nil;
    result = [_reader decode:_bundle.imageWithFile(@"17.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(@"854818000116", result.text); passed++; }
    else XCTAssertEqual(AGXNotFoundError, error.code);
    all++;
    error = nil;
    result = [_reader decode:_bundle.imageWithFile(@"18.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(@"854818000116", result.text); passed++; }
    else XCTAssertEqual(AGXNotFoundError, error.code);
    all++;
    error = nil;
    result = [_reader decode:_bundle.imageWithFile(@"19.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(@"854818000116", result.text); passed++; }
    else XCTAssertEqual(AGXNotFoundError, error.code);
    all++;
    error = nil;
    result = [_reader decode:_bundle.imageWithFile(@"20.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(@"854818000116", result.text); passed++; }
    else XCTAssertEqual(AGXNotFoundError, error.code);
    all++;
    error = nil;
    result = [_reader decode:_bundle.imageWithFile(@"21.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(@"854818000116", result.text); passed++; }
    else XCTAssertEqual(AGXNotFoundError, error.code);
    all++;
    error = nil;
    NSLog(@"%@:%@, all:%d, passed:%d", NSStringFromClass([self class]), NSStringFromSelector(_cmd), all, passed);
}

- (void)testupca4 {
    _bundle.subpathAs(@"blackbox/upca-4");
    AGXGcodeResult *result = nil;
    NSError *error = nil;
    int all = 0, passed = 0;

    result = [_reader decode:_bundle.imageWithFile(@"1.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(@"023942431015", result.text); passed++; }
    else XCTAssertEqual(AGXNotFoundError, error.code);
    all++;
    error = nil;
    result = [_reader decode:_bundle.imageWithFile(@"2.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(@"023942431015", result.text); passed++; }
    else XCTAssertEqual(AGXNotFoundError, error.code);
    all++;
    error = nil;
    result = [_reader decode:_bundle.imageWithFile(@"3.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(@"023942431015", result.text); passed++; }
    else XCTAssertEqual(AGXNotFoundError, error.code);
    all++;
    error = nil;
    result = [_reader decode:_bundle.imageWithFile(@"4.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(@"023942431015", result.text); passed++; }
    else XCTAssertEqual(AGXNotFoundError, error.code);
    all++;
    error = nil;
    result = [_reader decode:_bundle.imageWithFile(@"5.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(@"023942431015", result.text); passed++; }
    else XCTAssertEqual(AGXNotFoundError, error.code);
    all++;
    error = nil;
    result = [_reader decode:_bundle.imageWithFile(@"6.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(@"023942431015", result.text); passed++; }
    else XCTAssertEqual(AGXNotFoundError, error.code);
    all++;
    error = nil;
    result = [_reader decode:_bundle.imageWithFile(@"7.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(@"023942431015", result.text); passed++; }
    else XCTAssertEqual(AGXNotFoundError, error.code);
    all++;
    error = nil;
    result = [_reader decode:_bundle.imageWithFile(@"8.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(@"060410049235", result.text); passed++; }
    else XCTAssertEqual(AGXNotFoundError, error.code);
    all++;
    error = nil;
    result = [_reader decode:_bundle.imageWithFile(@"9.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(@"060410049235", result.text); passed++; }
    else XCTAssertEqual(AGXNotFoundError, error.code);
    all++;
    error = nil;
    result = [_reader decode:_bundle.imageWithFile(@"10.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(@"066721010995", result.text); passed++; }
    else XCTAssertEqual(AGXFormatError, error.code);
    all++;
    error = nil;
    result = [_reader decode:_bundle.imageWithFile(@"11.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(@"059290522143", result.text); passed++; }
    else XCTAssertEqual(AGXFormatError, error.code);
    all++;
    error = nil;
    result = [_reader decode:_bundle.imageWithFile(@"12.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(@"057961000228", result.text); passed++; }
    else XCTAssertEqual(AGXNotFoundError, error.code);
    all++;
    error = nil;
    result = [_reader decode:_bundle.imageWithFile(@"13.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(@"059290522143", result.text); passed++; }
    else XCTAssertEqual(AGXFormatError, error.code);
    all++;
    error = nil;
    result = [_reader decode:_bundle.imageWithFile(@"14.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(@"066721017185", result.text); passed++; }
    else XCTAssertEqual(AGXFormatError, error.code);
    all++;
    error = nil;
    result = [_reader decode:_bundle.imageWithFile(@"15.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(@"059290571110", result.text); passed++; }
    else XCTAssertEqual(AGXFormatError, error.code);
    all++;
    error = nil;
    result = [_reader decode:_bundle.imageWithFile(@"16.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(@"067932000263", result.text); passed++; }
    else XCTAssertEqual(AGXNotFoundError, error.code);
    all++;
    error = nil;
    result = [_reader decode:_bundle.imageWithFile(@"17.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(@"069000061015", result.text); passed++; }
    else XCTAssertEqual(AGXFormatError, error.code);
    all++;
    error = nil;
    result = [_reader decode:_bundle.imageWithFile(@"18.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(@"071691155775", result.text); passed++; }
    else XCTAssertEqual(AGXFormatError, error.code);
    all++;
    error = nil;
    result = [_reader decode:_bundle.imageWithFile(@"19.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(@"807648011401", result.text); passed++; }
    else XCTAssertEqual(AGXFormatError, error.code);
    all++;
    error = nil;
    NSLog(@"%@:%@, all:%d, passed:%d", NSStringFromClass([self class]), NSStringFromSelector(_cmd), all, passed);
}

- (void)testupca5 {
    _bundle.subpathAs(@"blackbox/upca-5");
    AGXGcodeResult *result = nil;
    NSError *error = nil;
    int all = 0, passed = 0;

    result = [_reader decode:_bundle.imageWithFile(@"01.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(@"312547701310", result.text); passed++; }
    else XCTAssertEqual(AGXNotFoundError, error.code);
    all++;
    error = nil;
    result = [_reader decode:_bundle.imageWithFile(@"02.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(@"312547701310", result.text); passed++; }
    else XCTAssertEqual(AGXNotFoundError, error.code);
    all++;
    error = nil;
    result = [_reader decode:_bundle.imageWithFile(@"03.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(@"312547701310", result.text); passed++; }
    else XCTAssertEqual(AGXNotFoundError, error.code);
    all++;
    error = nil;
    result = [_reader decode:_bundle.imageWithFile(@"04.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(@"312547701310", result.text); passed++; }
    else XCTAssertEqual(AGXNotFoundError, error.code);
    all++;
    error = nil;
    result = [_reader decode:_bundle.imageWithFile(@"05.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(@"312547701310", result.text); passed++; }
    else XCTAssertEqual(AGXNotFoundError, error.code);
    all++;
    error = nil;
    result = [_reader decode:_bundle.imageWithFile(@"06.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(@"312547701310", result.text); passed++; }
    else XCTAssertEqual(AGXNotFoundError, error.code);
    all++;
    error = nil;
    result = [_reader decode:_bundle.imageWithFile(@"07.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(@"312547701310", result.text); passed++; }
    else XCTAssertEqual(AGXNotFoundError, error.code);
    all++;
    error = nil;
    result = [_reader decode:_bundle.imageWithFile(@"08.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(@"312547701310", result.text); passed++; }
    else XCTAssertEqual(AGXNotFoundError, error.code);
    all++;
    error = nil;
    result = [_reader decode:_bundle.imageWithFile(@"09.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(@"312547701310", result.text); passed++; }
    else XCTAssertEqual(AGXNotFoundError, error.code);
    all++;
    error = nil;
    result = [_reader decode:_bundle.imageWithFile(@"10.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(@"312547701310", result.text); passed++; }
    else XCTAssertEqual(AGXNotFoundError, error.code);
    all++;
    error = nil;
    result = [_reader decode:_bundle.imageWithFile(@"11.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(@"312547701310", result.text); passed++; }
    else XCTAssertEqual(AGXNotFoundError, error.code);
    all++;
    error = nil;
    result = [_reader decode:_bundle.imageWithFile(@"12.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(@"312547701310", result.text); passed++; }
    else XCTAssertEqual(AGXNotFoundError, error.code);
    all++;
    error = nil;
    result = [_reader decode:_bundle.imageWithFile(@"13.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(@"312547701310", result.text); passed++; }
    else XCTAssertEqual(AGXNotFoundError, error.code);
    all++;
    error = nil;
    result = [_reader decode:_bundle.imageWithFile(@"14.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(@"312547701310", result.text); passed++; }
    else XCTAssertEqual(AGXNotFoundError, error.code);
    all++;
    error = nil;
    result = [_reader decode:_bundle.imageWithFile(@"15.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(@"312547701310", result.text); passed++; }
    else XCTAssertEqual(AGXNotFoundError, error.code);
    all++;
    error = nil;
    result = [_reader decode:_bundle.imageWithFile(@"16.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(@"312547701310", result.text); passed++; }
    else XCTAssertEqual(AGXNotFoundError, error.code);
    all++;
    error = nil;
    result = [_reader decode:_bundle.imageWithFile(@"17.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(@"312547701310", result.text); passed++; }
    else XCTAssertEqual(AGXNotFoundError, error.code);
    all++;
    error = nil;
    result = [_reader decode:_bundle.imageWithFile(@"18.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(@"312547701310", result.text); passed++; }
    else XCTAssertEqual(AGXNotFoundError, error.code);
    all++;
    error = nil;
    result = [_reader decode:_bundle.imageWithFile(@"19.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(@"625034201058", result.text); passed++; }
    else XCTAssertEqual(AGXNotFoundError, error.code);
    all++;
    error = nil;
    result = [_reader decode:_bundle.imageWithFile(@"20.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(@"625034201058", result.text); passed++; }
    else XCTAssertEqual(AGXNotFoundError, error.code);
    all++;
    error = nil;
    result = [_reader decode:_bundle.imageWithFile(@"21.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(@"625034201058", result.text); passed++; }
    else XCTAssertEqual(AGXNotFoundError, error.code);
    all++;
    error = nil;
    result = [_reader decode:_bundle.imageWithFile(@"22.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(@"625034201058", result.text); passed++; }
    else XCTAssertEqual(AGXNotFoundError, error.code);
    all++;
    error = nil;
    result = [_reader decode:_bundle.imageWithFile(@"23.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(@"625034201058", result.text); passed++; }
    else XCTAssertEqual(AGXNotFoundError, error.code);
    all++;
    error = nil;
    result = [_reader decode:_bundle.imageWithFile(@"24.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(@"625034201058", result.text); passed++; }
    else XCTAssertEqual(AGXNotFoundError, error.code);
    all++;
    error = nil;
    result = [_reader decode:_bundle.imageWithFile(@"25.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(@"625034201058", result.text); passed++; }
    else XCTAssertEqual(AGXNotFoundError, error.code);
    all++;
    error = nil;
    result = [_reader decode:_bundle.imageWithFile(@"26.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(@"625034201058", result.text); passed++; }
    else XCTAssertEqual(AGXNotFoundError, error.code);
    all++;
    error = nil;
    result = [_reader decode:_bundle.imageWithFile(@"27.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(@"625034201058", result.text); passed++; }
    else XCTAssertEqual(AGXNotFoundError, error.code);
    all++;
    error = nil;
    result = [_reader decode:_bundle.imageWithFile(@"28.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(@"625034201058", result.text); passed++; }
    else XCTAssertEqual(AGXNotFoundError, error.code);
    all++;
    error = nil;
    result = [_reader decode:_bundle.imageWithFile(@"29.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(@"625034201058", result.text); passed++; }
    else XCTAssertEqual(AGXNotFoundError, error.code);
    all++;
    error = nil;
    result = [_reader decode:_bundle.imageWithFile(@"30.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(@"625034201058", result.text); passed++; }
    else XCTAssertEqual(AGXNotFoundError, error.code);
    all++;
    error = nil;
    result = [_reader decode:_bundle.imageWithFile(@"31.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(@"625034201058", result.text); passed++; }
    else XCTAssertEqual(AGXNotFoundError, error.code);
    all++;
    error = nil;
    result = [_reader decode:_bundle.imageWithFile(@"32.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(@"625034201058", result.text); passed++; }
    else XCTAssertEqual(AGXNotFoundError, error.code);
    all++;
    error = nil;
    result = [_reader decode:_bundle.imageWithFile(@"33.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(@"625034201058", result.text); passed++; }
    else XCTAssertEqual(AGXNotFoundError, error.code);
    all++;
    error = nil;
    result = [_reader decode:_bundle.imageWithFile(@"34.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(@"625034201058", result.text); passed++; }
    else XCTAssertEqual(AGXNotFoundError, error.code);
    all++;
    error = nil;
    result = [_reader decode:_bundle.imageWithFile(@"35.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(@"625034201058", result.text); passed++; }
    else XCTAssertEqual(AGXNotFoundError, error.code);
    all++;
    error = nil;
    NSLog(@"%@:%@, all:%d, passed:%d", NSStringFromClass([self class]), NSStringFromSelector(_cmd), all, passed);
}

- (void)testupca6 {
    _bundle.subpathAs(@"blackbox/upca-6");
    AGXGcodeResult *result = nil;
    NSError *error = nil;
    int all = 0, passed = 0;

    result = [_reader decode:_bundle.imageWithFile(@"01.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(@"071831007995", result.text); passed++; }
    else XCTAssertEqual(AGXNotFoundError, error.code);
    all++;
    error = nil;
    result = [_reader decode:_bundle.imageWithFile(@"02.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(@"071831007995", result.text); passed++; }
    else XCTAssertEqual(AGXNotFoundError, error.code);
    all++;
    error = nil;
    result = [_reader decode:_bundle.imageWithFile(@"03.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(@"071831007995", result.text); passed++; }
    else XCTAssertEqual(AGXNotFoundError, error.code);
    all++;
    error = nil;
    result = [_reader decode:_bundle.imageWithFile(@"04.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(@"071831007995", result.text); passed++; }
    else XCTAssertEqual(AGXNotFoundError, error.code);
    all++;
    error = nil;
    result = [_reader decode:_bundle.imageWithFile(@"05.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(@"071831007995", result.text); passed++; }
    else XCTAssertEqual(AGXNotFoundError, error.code);
    all++;
    error = nil;
    result = [_reader decode:_bundle.imageWithFile(@"06.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(@"071831007995", result.text); passed++; }
    else XCTAssertEqual(AGXNotFoundError, error.code);
    all++;
    error = nil;
    result = [_reader decode:_bundle.imageWithFile(@"07.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(@"605482330012", result.text); passed++; }
    else XCTAssertEqual(AGXNotFoundError, error.code);
    all++;
    error = nil;
    result = [_reader decode:_bundle.imageWithFile(@"08.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(@"605482330012", result.text); passed++; }
    else XCTAssertEqual(AGXNotFoundError, error.code);
    all++;
    error = nil;
    result = [_reader decode:_bundle.imageWithFile(@"09.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(@"605482330012", result.text); passed++; }
    else XCTAssertEqual(AGXNotFoundError, error.code);
    all++;
    error = nil;
    result = [_reader decode:_bundle.imageWithFile(@"10.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(@"605482330012", result.text); passed++; }
    else XCTAssertEqual(AGXNotFoundError, error.code);
    all++;
    error = nil;
    result = [_reader decode:_bundle.imageWithFile(@"11.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(@"605482330012", result.text); passed++; }
    else XCTAssertEqual(AGXNotFoundError, error.code);
    all++;
    error = nil;
    result = [_reader decode:_bundle.imageWithFile(@"12.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(@"605482330012", result.text); passed++; }
    else XCTAssertEqual(AGXNotFoundError, error.code);
    all++;
    error = nil;
    result = [_reader decode:_bundle.imageWithFile(@"13.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(@"073333531084", result.text); passed++; }
    else XCTAssertEqual(AGXNotFoundError, error.code);
    all++;
    error = nil;
    result = [_reader decode:_bundle.imageWithFile(@"14.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(@"073333531084", result.text); passed++; }
    else XCTAssertEqual(AGXNotFoundError, error.code);
    all++;
    error = nil;
    result = [_reader decode:_bundle.imageWithFile(@"15.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(@"073333531084", result.text); passed++; }
    else XCTAssertEqual(AGXNotFoundError, error.code);
    all++;
    error = nil;
    result = [_reader decode:_bundle.imageWithFile(@"16.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(@"073333531084", result.text); passed++; }
    else XCTAssertEqual(AGXNotFoundError, error.code);
    all++;
    error = nil;
    result = [_reader decode:_bundle.imageWithFile(@"17.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(@"073333531084", result.text); passed++; }
    else XCTAssertEqual(AGXNotFoundError, error.code);
    all++;
    error = nil;
    result = [_reader decode:_bundle.imageWithFile(@"18.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(@"073333531084", result.text); passed++; }
    else XCTAssertEqual(AGXNotFoundError, error.code);
    all++;
    error = nil;
    result = [_reader decode:_bundle.imageWithFile(@"19.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(@"073333531084", result.text); passed++; }
    else XCTAssertEqual(AGXNotFoundError, error.code);
    all++;
    error = nil;
    NSLog(@"%@:%@, all:%d, passed:%d", NSStringFromClass([self class]), NSStringFromSelector(_cmd), all, passed);
}

- (void)testean131 {
    _bundle.subpathAs(@"blackbox/ean13-1");
    AGXGcodeResult *result = nil;
    NSError *error = nil;
    int all = 0, passed = 0;

    result = [_reader decode:_bundle.imageWithFile(@"1.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(@"8413000065504", result.text); passed++; }
    else XCTAssertEqual(AGXNotFoundError, error.code);
    all++;
    error = nil;
    result = [_reader decode:_bundle.imageWithFile(@"2.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(@"8480010092271", result.text); passed++; }
    else XCTAssertEqual(AGXNotFoundError, error.code);
    all++;
    error = nil;
    result = [_reader decode:_bundle.imageWithFile(@"3.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(@"8480000823274", result.text); passed++; }
    else XCTAssertEqual(AGXNotFoundError, error.code);
    all++;
    error = nil;
    result = [_reader decode:_bundle.imageWithFile(@"4.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(@"5449000039231", result.text); passed++; }
    else XCTAssertEqual(AGXNotFoundError, error.code);
    all++;
    error = nil;
    result = [_reader decode:_bundle.imageWithFile(@"5.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(@"8410054010412", result.text); passed++; }
    else XCTAssertEqual(AGXNotFoundError, error.code);
    all++;
    error = nil;
    result = [_reader decode:_bundle.imageWithFile(@"6.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(@"8480010045062", result.text); passed++; }
    else XCTAssertEqual(AGXNotFoundError, error.code);
    all++;
    error = nil;
    result = [_reader decode:_bundle.imageWithFile(@"7.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(@"9788430532674", result.text); passed++; }
    else XCTAssertEqual(AGXNotFoundError, error.code);
    all++;
    error = nil;
    result = [_reader decode:_bundle.imageWithFile(@"8.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(@"8480017507990", result.text); passed++; }
    else XCTAssertEqual(AGXNotFoundError, error.code);
    all++;
    error = nil;
    result = [_reader decode:_bundle.imageWithFile(@"9.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(@"3166298099809", result.text); passed++; }
    else XCTAssertEqual(AGXNotFoundError, error.code);
    all++;
    error = nil;
    result = [_reader decode:_bundle.imageWithFile(@"10.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(@"8480010001136", result.text); passed++; }
    else XCTAssertEqual(AGXNotFoundError, error.code);
    all++;
    error = nil;
    result = [_reader decode:_bundle.imageWithFile(@"12.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(@"5201815331227", result.text); passed++; }
    else XCTAssertEqual(AGXNotFoundError, error.code);
    all++;
    error = nil;
    result = [_reader decode:_bundle.imageWithFile(@"13.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(@"8413600298517", result.text); passed++; }
    else XCTAssertEqual(AGXNotFoundError, error.code);
    all++;
    error = nil;
    result = [_reader decode:_bundle.imageWithFile(@"14.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(@"3560070169443", result.text); passed++; }
    else XCTAssertEqual(AGXNotFoundError, error.code);
    all++;
    error = nil;
    result = [_reader decode:_bundle.imageWithFile(@"15.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(@"4045787034318", result.text); passed++; }
    else XCTAssertEqual(AGXNotFoundError, error.code);
    all++;
    error = nil;
    result = [_reader decode:_bundle.imageWithFile(@"18.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(@"3086126100326", result.text); passed++; }
    else XCTAssertEqual(AGXNotFoundError, error.code);
    all++;
    error = nil;
    result = [_reader decode:_bundle.imageWithFile(@"19.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(@"4820024790635", result.text); passed++; }
    else XCTAssertEqual(AGXNotFoundError, error.code);
    all++;
    error = nil;
    result = [_reader decode:_bundle.imageWithFile(@"20.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(@"4000539017100", result.text); passed++; }
    else XCTAssertEqual(AGXNotFoundError, error.code);
    all++;
    error = nil;
    result = [_reader decode:_bundle.imageWithFile(@"21.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(@"7622200008018", result.text); passed++; }
    else XCTAssertEqual(AGXNotFoundError, error.code);
    all++;
    error = nil;
    result = [_reader decode:_bundle.imageWithFile(@"22.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(@"5603667020517", result.text); passed++; }
    else XCTAssertEqual(AGXNotFoundError, error.code);
    all++;
    error = nil;
    result = [_reader decode:_bundle.imageWithFile(@"23.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(@"7622400791949", result.text); passed++; }
    else XCTAssertEqual(AGXNotFoundError, error.code);
    all++;
    error = nil;
    result = [_reader decode:_bundle.imageWithFile(@"24.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(@"5709262942503", result.text); passed++; }
    else XCTAssertEqual(AGXNotFoundError, error.code);
    all++;
    error = nil;
    result = [_reader decode:_bundle.imageWithFile(@"25.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(@"9780140013993", result.text); passed++; }
    else XCTAssertEqual(AGXNotFoundError, error.code);
    all++;
    error = nil;
    result = [_reader decode:_bundle.imageWithFile(@"26.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(@"4901780188352", result.text); passed++; }
    else XCTAssertEqual(AGXNotFoundError, error.code);
    all++;
    error = nil;
    result = [_reader decode:_bundle.imageWithFile(@"28.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(@"9771699057002", result.text); passed++; }
    else XCTAssertEqual(AGXNotFoundError, error.code);
    all++;
    error = nil;
    result = [_reader decode:_bundle.imageWithFile(@"29.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(@"4007817327098", result.text); passed++; }
    else XCTAssertEqual(AGXNotFoundError, error.code);
    all++;
    error = nil;
    result = [_reader decode:_bundle.imageWithFile(@"30.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(@"5025121072311", result.text); passed++; }
    else XCTAssertEqual(AGXNotFoundError, error.code);
    all++;
    error = nil;
    result = [_reader decode:_bundle.imageWithFile(@"31.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(@"9780393058673", result.text); passed++; }
    else XCTAssertEqual(AGXNotFoundError, error.code);
    all++;
    error = nil;
    result = [_reader decode:_bundle.imageWithFile(@"32.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(@"9780393058673", result.text); passed++; }
    else XCTAssertEqual(AGXNotFoundError, error.code);
    all++;
    error = nil;
    result = [_reader decode:_bundle.imageWithFile(@"33.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(@"9781558604971", result.text); passed++; }
    else XCTAssertEqual(AGXNotFoundError, error.code);
    all++;
    error = nil;
    result = [_reader decode:_bundle.imageWithFile(@"34.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(@"9781558604971", result.text); passed++; }
    else XCTAssertEqual(AGXNotFoundError, error.code);
    all++;
    error = nil;
    result = [_reader decode:_bundle.imageWithFile(@"35.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(@"5030159003930", result.text); passed++; }
    else XCTAssertEqual(AGXNotFoundError, error.code);
    all++;
    error = nil;
    result = [_reader decode:_bundle.imageWithFile(@"36.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(@"5000213101025", result.text); passed++; }
    else XCTAssertEqual(AGXNotFoundError, error.code);
    all++;
    error = nil;
    result = [_reader decode:_bundle.imageWithFile(@"37.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(@"5000213002834", result.text); passed++; }
    else XCTAssertEqual(AGXNotFoundError, error.code);
    all++;
    error = nil;
    result = [_reader decode:_bundle.imageWithFile(@"38.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(@"9780201752847", result.text); passed++; }
    else XCTAssertEqual(AGXNotFoundError, error.code);
    all++;
    error = nil;
    NSLog(@"%@:%@, all:%d, passed:%d", NSStringFromClass([self class]), NSStringFromSelector(_cmd), all, passed);
}

- (void)testean132 {
    _bundle.subpathAs(@"blackbox/ean13-2");
    AGXGcodeResult *result = nil;
    NSError *error = nil;
    int all = 0, passed = 0;

    result = [_reader decode:_bundle.imageWithFile(@"01.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(@"9780804816632", result.text); passed++; }
    else XCTAssertEqual(AGXNotFoundError, error.code);
    all++;
    error = nil;
    result = [_reader decode:_bundle.imageWithFile(@"02.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(@"9780804816632", result.text); passed++; }
    else XCTAssertEqual(AGXNotFoundError, error.code);
    all++;
    error = nil;
    result = [_reader decode:_bundle.imageWithFile(@"03.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(@"9780804816632", result.text); passed++; }
    else XCTAssertEqual(AGXNotFoundError, error.code);
    all++;
    error = nil;
    result = [_reader decode:_bundle.imageWithFile(@"04.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(@"9780804816632", result.text); passed++; }
    else XCTAssertEqual(AGXNotFoundError, error.code);
    all++;
    error = nil;
    result = [_reader decode:_bundle.imageWithFile(@"05.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(@"9780804816632", result.text); passed++; }
    else XCTAssertEqual(AGXNotFoundError, error.code);
    all++;
    error = nil;
    result = [_reader decode:_bundle.imageWithFile(@"06.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(@"9780804816632", result.text); passed++; }
    else XCTAssertEqual(AGXNotFoundError, error.code);
    all++;
    error = nil;
    result = [_reader decode:_bundle.imageWithFile(@"07.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(@"9780804816632", result.text); passed++; }
    else XCTAssertEqual(AGXNotFoundError, error.code);
    all++;
    error = nil;
    result = [_reader decode:_bundle.imageWithFile(@"08.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(@"9780345348036", result.text); passed++; }
    else XCTAssertEqual(AGXNotFoundError, error.code);
    all++;
    error = nil;
    result = [_reader decode:_bundle.imageWithFile(@"09.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(@"9780345348036", result.text); passed++; }
    else XCTAssertEqual(AGXNotFoundError, error.code);
    all++;
    error = nil;
    result = [_reader decode:_bundle.imageWithFile(@"10.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(@"9780345348036", result.text); passed++; }
    else XCTAssertEqual(AGXNotFoundError, error.code);
    all++;
    error = nil;
    result = [_reader decode:_bundle.imageWithFile(@"11.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(@"9780345348036", result.text); passed++; }
    else XCTAssertEqual(AGXNotFoundError, error.code);
    all++;
    error = nil;
    result = [_reader decode:_bundle.imageWithFile(@"12.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(@"9780345348036", result.text); passed++; }
    else XCTAssertEqual(AGXNotFoundError, error.code);
    all++;
    error = nil;
    result = [_reader decode:_bundle.imageWithFile(@"13.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(@"9784872348880", result.text); passed++; }
    else XCTAssertEqual(AGXNotFoundError, error.code);
    all++;
    error = nil;
    result = [_reader decode:_bundle.imageWithFile(@"14.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(@"9784872348880", result.text); passed++; }
    else XCTAssertEqual(AGXNotFoundError, error.code);
    all++;
    error = nil;
    result = [_reader decode:_bundle.imageWithFile(@"15.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(@"9784872348880", result.text); passed++; }
    else XCTAssertEqual(AGXNotFoundError, error.code);
    all++;
    error = nil;
    result = [_reader decode:_bundle.imageWithFile(@"16.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(@"9784872348880", result.text); passed++; }
    else XCTAssertEqual(AGXNotFoundError, error.code);
    all++;
    error = nil;
    result = [_reader decode:_bundle.imageWithFile(@"17.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(@"9784872348880", result.text); passed++; }
    else XCTAssertEqual(AGXNotFoundError, error.code);
    all++;
    error = nil;
    result = [_reader decode:_bundle.imageWithFile(@"18.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(@"9784872348880", result.text); passed++; }
    else XCTAssertEqual(AGXNotFoundError, error.code);
    all++;
    error = nil;
    result = [_reader decode:_bundle.imageWithFile(@"19.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(@"9784872348880", result.text); passed++; }
    else XCTAssertEqual(AGXNotFoundError, error.code);
    all++;
    error = nil;
    result = [_reader decode:_bundle.imageWithFile(@"20.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(@"9784872348880", result.text); passed++; }
    else XCTAssertEqual(AGXNotFoundError, error.code);
    all++;
    error = nil;
    result = [_reader decode:_bundle.imageWithFile(@"21.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(@"9784872348880", result.text); passed++; }
    else XCTAssertEqual(AGXNotFoundError, error.code);
    all++;
    error = nil;
    result = [_reader decode:_bundle.imageWithFile(@"22.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(@"9784872348880", result.text); passed++; }
    else XCTAssertEqual(AGXNotFoundError, error.code);
    all++;
    error = nil;
    result = [_reader decode:_bundle.imageWithFile(@"23.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(@"1920081045006", result.text); passed++; }
    else XCTAssertEqual(AGXNotFoundError, error.code);
    all++;
    error = nil;
    result = [_reader decode:_bundle.imageWithFile(@"24.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(@"9784872348880", result.text); passed++; }
    else XCTAssertEqual(AGXNotFoundError, error.code);
    all++;
    error = nil;
    result = [_reader decode:_bundle.imageWithFile(@"25.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(@"9784872348880", result.text); passed++; }
    else XCTAssertEqual(AGXNotFoundError, error.code);
    all++;
    error = nil;
    result = [_reader decode:_bundle.imageWithFile(@"26.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(@"9784872348880", result.text); passed++; }
    else XCTAssertEqual(AGXNotFoundError, error.code);
    all++;
    error = nil;
    result = [_reader decode:_bundle.imageWithFile(@"27.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(@"9784872348880", result.text); passed++; }
    else XCTAssertEqual(AGXNotFoundError, error.code);
    all++;
    error = nil;
    result = [_reader decode:_bundle.imageWithFile(@"28.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(@"1920081045006", result.text); passed++; }
    else XCTAssertEqual(AGXNotFoundError, error.code);
    all++;
    error = nil;
    NSLog(@"%@:%@, all:%d, passed:%d", NSStringFromClass([self class]), NSStringFromSelector(_cmd), all, passed);
}

- (void)testean133 {
    _bundle.subpathAs(@"blackbox/ean13-3");
    AGXGcodeResult *result = nil;
    NSError *error = nil;
    int all = 0, passed = 0;

    result = [_reader decode:_bundle.imageWithFile(@"01.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(@"9780764544200", result.text); passed++; }
    else XCTAssertEqual(AGXNotFoundError, error.code);
    all++;
    error = nil;
    result = [_reader decode:_bundle.imageWithFile(@"02.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(@"9780764544200", result.text); passed++; }
    else XCTAssertEqual(AGXNotFoundError, error.code);
    all++;
    error = nil;
    result = [_reader decode:_bundle.imageWithFile(@"03.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(@"9780764544200", result.text); passed++; }
    else XCTAssertEqual(AGXNotFoundError, error.code);
    all++;
    error = nil;
    result = [_reader decode:_bundle.imageWithFile(@"04.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(@"9780764544200", result.text); passed++; }
    else XCTAssertEqual(AGXNotFoundError, error.code);
    all++;
    error = nil;
    result = [_reader decode:_bundle.imageWithFile(@"05.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(@"9780764544200", result.text); passed++; }
    else XCTAssertEqual(AGXNotFoundError, error.code);
    all++;
    error = nil;
    result = [_reader decode:_bundle.imageWithFile(@"06.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(@"9780764544200", result.text); passed++; }
    else XCTAssertEqual(AGXNotFoundError, error.code);
    all++;
    error = nil;
    result = [_reader decode:_bundle.imageWithFile(@"07.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(@"9780764544200", result.text); passed++; }
    else XCTAssertEqual(AGXNotFoundError, error.code);
    all++;
    error = nil;
    result = [_reader decode:_bundle.imageWithFile(@"08.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(@"9780764544200", result.text); passed++; }
    else XCTAssertEqual(AGXNotFoundError, error.code);
    all++;
    error = nil;
    result = [_reader decode:_bundle.imageWithFile(@"09.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(@"9780764544200", result.text); passed++; }
    else XCTAssertEqual(AGXNotFoundError, error.code);
    all++;
    error = nil;
    result = [_reader decode:_bundle.imageWithFile(@"10.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(@"9780596008574", result.text); passed++; }
    else XCTAssertEqual(AGXNotFoundError, error.code);
    all++;
    error = nil;
    result = [_reader decode:_bundle.imageWithFile(@"11.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(@"9780596008574", result.text); passed++; }
    else XCTAssertEqual(AGXNotFoundError, error.code);
    all++;
    error = nil;
    result = [_reader decode:_bundle.imageWithFile(@"12.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(@"9780596008574", result.text); passed++; }
    else XCTAssertEqual(AGXNotFoundError, error.code);
    all++;
    error = nil;
    result = [_reader decode:_bundle.imageWithFile(@"13.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(@"9780596008574", result.text); passed++; }
    else XCTAssertEqual(AGXNotFoundError, error.code);
    all++;
    error = nil;
    result = [_reader decode:_bundle.imageWithFile(@"14.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(@"9780596008574", result.text); passed++; }
    else XCTAssertEqual(AGXNotFoundError, error.code);
    all++;
    error = nil;
    result = [_reader decode:_bundle.imageWithFile(@"15.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(@"9780596008574", result.text); passed++; }
    else XCTAssertEqual(AGXNotFoundError, error.code);
    all++;
    error = nil;
    result = [_reader decode:_bundle.imageWithFile(@"16.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(@"9780596008574", result.text); passed++; }
    else XCTAssertEqual(AGXNotFoundError, error.code);
    all++;
    error = nil;
    result = [_reader decode:_bundle.imageWithFile(@"17.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(@"9780596008574", result.text); passed++; }
    else XCTAssertEqual(AGXNotFoundError, error.code);
    all++;
    error = nil;
    result = [_reader decode:_bundle.imageWithFile(@"18.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(@"9780596008574", result.text); passed++; }
    else XCTAssertEqual(AGXNotFoundError, error.code);
    all++;
    error = nil;
    result = [_reader decode:_bundle.imageWithFile(@"19.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(@"9780596008574", result.text); passed++; }
    else XCTAssertEqual(AGXNotFoundError, error.code);
    all++;
    error = nil;
    result = [_reader decode:_bundle.imageWithFile(@"20.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(@"9780596008574", result.text); passed++; }
    else XCTAssertEqual(AGXNotFoundError, error.code);
    all++;
    error = nil;
    result = [_reader decode:_bundle.imageWithFile(@"21.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(@"9780596008574", result.text); passed++; }
    else XCTAssertEqual(AGXNotFoundError, error.code);
    all++;
    error = nil;
    result = [_reader decode:_bundle.imageWithFile(@"22.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(@"9780201310054", result.text); passed++; }
    else XCTAssertEqual(AGXNotFoundError, error.code);
    all++;
    error = nil;
    result = [_reader decode:_bundle.imageWithFile(@"23.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(@"9780201310054", result.text); passed++; }
    else XCTAssertEqual(AGXNotFoundError, error.code);
    all++;
    error = nil;
    result = [_reader decode:_bundle.imageWithFile(@"24.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(@"9780201310054", result.text); passed++; }
    else XCTAssertEqual(AGXNotFoundError, error.code);
    all++;
    error = nil;
    result = [_reader decode:_bundle.imageWithFile(@"25.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(@"9780201310054", result.text); passed++; }
    else XCTAssertEqual(AGXNotFoundError, error.code);
    all++;
    error = nil;
    result = [_reader decode:_bundle.imageWithFile(@"26.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(@"9780201310054", result.text); passed++; }
    else XCTAssertEqual(AGXNotFoundError, error.code);
    all++;
    error = nil;
    result = [_reader decode:_bundle.imageWithFile(@"27.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(@"9780201310054", result.text); passed++; }
    else XCTAssertEqual(AGXNotFoundError, error.code);
    all++;
    error = nil;
    result = [_reader decode:_bundle.imageWithFile(@"28.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(@"9780201310054", result.text); passed++; }
    else XCTAssertEqual(AGXNotFoundError, error.code);
    all++;
    error = nil;
    result = [_reader decode:_bundle.imageWithFile(@"29.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(@"9780201310054", result.text); passed++; }
    else XCTAssertEqual(AGXNotFoundError, error.code);
    all++;
    error = nil;
    result = [_reader decode:_bundle.imageWithFile(@"30.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(@"9780201310054", result.text); passed++; }
    else XCTAssertEqual(AGXNotFoundError, error.code);
    all++;
    error = nil;
    result = [_reader decode:_bundle.imageWithFile(@"31.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(@"9780201310054", result.text); passed++; }
    else XCTAssertEqual(AGXNotFoundError, error.code);
    all++;
    error = nil;
    result = [_reader decode:_bundle.imageWithFile(@"32.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(@"9780201310054", result.text); passed++; }
    else XCTAssertEqual(AGXNotFoundError, error.code);
    all++;
    error = nil;
    result = [_reader decode:_bundle.imageWithFile(@"33.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(@"9780201310054", result.text); passed++; }
    else XCTAssertEqual(AGXNotFoundError, error.code);
    all++;
    error = nil;
    result = [_reader decode:_bundle.imageWithFile(@"34.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(@"9780201310054", result.text); passed++; }
    else XCTAssertEqual(AGXNotFoundError, error.code);
    all++;
    error = nil;
    result = [_reader decode:_bundle.imageWithFile(@"35.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(@"9780201310054", result.text); passed++; }
    else XCTAssertEqual(AGXNotFoundError, error.code);
    all++;
    error = nil;
    result = [_reader decode:_bundle.imageWithFile(@"36.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(@"9781585730575", result.text); passed++; }
    else XCTAssertEqual(AGXNotFoundError, error.code);
    all++;
    error = nil;
    result = [_reader decode:_bundle.imageWithFile(@"37.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(@"9781585730575", result.text); passed++; }
    else XCTAssertEqual(AGXNotFoundError, error.code);
    all++;
    error = nil;
    result = [_reader decode:_bundle.imageWithFile(@"38.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(@"9781585730575", result.text); passed++; }
    else XCTAssertEqual(AGXNotFoundError, error.code);
    all++;
    error = nil;
    result = [_reader decode:_bundle.imageWithFile(@"39.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(@"9781585730575", result.text); passed++; }
    else XCTAssertEqual(AGXNotFoundError, error.code);
    all++;
    error = nil;
    result = [_reader decode:_bundle.imageWithFile(@"40.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(@"9781585730575", result.text); passed++; }
    else XCTAssertEqual(AGXNotFoundError, error.code);
    all++;
    error = nil;
    result = [_reader decode:_bundle.imageWithFile(@"41.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(@"9781585730575", result.text); passed++; }
    else XCTAssertEqual(AGXNotFoundError, error.code);
    all++;
    error = nil;
    result = [_reader decode:_bundle.imageWithFile(@"42.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(@"9781585730575", result.text); passed++; }
    else XCTAssertEqual(AGXNotFoundError, error.code);
    all++;
    error = nil;
    result = [_reader decode:_bundle.imageWithFile(@"43.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(@"9781585730575", result.text); passed++; }
    else XCTAssertEqual(AGXNotFoundError, error.code);
    all++;
    error = nil;
    result = [_reader decode:_bundle.imageWithFile(@"44.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(@"9780735619937", result.text); passed++; }
    else XCTAssertEqual(AGXNotFoundError, error.code);
    all++;
    error = nil;
    result = [_reader decode:_bundle.imageWithFile(@"45.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(@"9780735619937", result.text); passed++; }
    else XCTAssertEqual(AGXNotFoundError, error.code);
    all++;
    error = nil;
    result = [_reader decode:_bundle.imageWithFile(@"46.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(@"9780735619937", result.text); passed++; }
    else XCTAssertEqual(AGXNotFoundError, error.code);
    all++;
    error = nil;
    result = [_reader decode:_bundle.imageWithFile(@"47.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(@"9780735619937", result.text); passed++; }
    else XCTAssertEqual(AGXNotFoundError, error.code);
    all++;
    error = nil;
    result = [_reader decode:_bundle.imageWithFile(@"48.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(@"9780735619937", result.text); passed++; }
    else XCTAssertEqual(AGXNotFoundError, error.code);
    all++;
    error = nil;
    result = [_reader decode:_bundle.imageWithFile(@"49.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(@"9780735619937", result.text); passed++; }
    else XCTAssertEqual(AGXNotFoundError, error.code);
    all++;
    error = nil;
    result = [_reader decode:_bundle.imageWithFile(@"50.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(@"9780735619937", result.text); passed++; }
    else XCTAssertEqual(AGXNotFoundError, error.code);
    all++;
    error = nil;
    result = [_reader decode:_bundle.imageWithFile(@"51.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(@"9780735619937", result.text); passed++; }
    else XCTAssertEqual(AGXNotFoundError, error.code);
    all++;
    error = nil;
    result = [_reader decode:_bundle.imageWithFile(@"52.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(@"9780735619937", result.text); passed++; }
    else XCTAssertEqual(AGXNotFoundError, error.code);
    all++;
    error = nil;
    result = [_reader decode:_bundle.imageWithFile(@"53.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(@"9780735619937", result.text); passed++; }
    else XCTAssertEqual(AGXNotFoundError, error.code);
    all++;
    error = nil;
    result = [_reader decode:_bundle.imageWithFile(@"54.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(@"9780735619937", result.text); passed++; }
    else XCTAssertEqual(AGXNotFoundError, error.code);
    all++;
    error = nil;
    result = [_reader decode:_bundle.imageWithFile(@"55.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(@"9780735619937", result.text); passed++; }
    else XCTAssertEqual(AGXNotFoundError, error.code);
    all++;
    error = nil;
    NSLog(@"%@:%@, all:%d, passed:%d", NSStringFromClass([self class]), NSStringFromSelector(_cmd), all, passed);
}

- (void)testean134 {
    _bundle.subpathAs(@"blackbox/ean13-4");
    AGXGcodeResult *result = nil;
    NSError *error = nil;
    int all = 0, passed = 0;

    result = [_reader decode:_bundle.imageWithFile(@"01.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(@"9780441014989", result.text); passed++; }
    else XCTAssertEqual(AGXNotFoundError, error.code);
    all++;
    error = nil;
    result = [_reader decode:_bundle.imageWithFile(@"02.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(@"9780441014989", result.text); passed++; }
    else XCTAssertEqual(AGXNotFoundError, error.code);
    all++;
    error = nil;
    result = [_reader decode:_bundle.imageWithFile(@"03.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(@"9780441014989", result.text); passed++; }
    else XCTAssertEqual(AGXNotFoundError, error.code);
    all++;
    error = nil;
    result = [_reader decode:_bundle.imageWithFile(@"04.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(@"9780441014989", result.text); passed++; }
    else XCTAssertEqual(AGXNotFoundError, error.code);
    all++;
    error = nil;
    result = [_reader decode:_bundle.imageWithFile(@"05.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(@"9780441014989", result.text); passed++; }
    else XCTAssertEqual(AGXNotFoundError, error.code);
    all++;
    error = nil;
    result = [_reader decode:_bundle.imageWithFile(@"06.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(@"9780441014989", result.text); passed++; }
    else XCTAssertEqual(AGXNotFoundError, error.code);
    all++;
    error = nil;
    result = [_reader decode:_bundle.imageWithFile(@"07.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(@"9780441014989", result.text); passed++; }
    else XCTAssertEqual(AGXNotFoundError, error.code);
    all++;
    error = nil;
    result = [_reader decode:_bundle.imageWithFile(@"08.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(@"9780441014989", result.text); passed++; }
    else XCTAssertEqual(AGXNotFoundError, error.code);
    all++;
    error = nil;
    result = [_reader decode:_bundle.imageWithFile(@"09.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(@"9780441014989", result.text); passed++; }
    else XCTAssertEqual(AGXNotFoundError, error.code);
    all++;
    error = nil;
    result = [_reader decode:_bundle.imageWithFile(@"10.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(@"9780441014989", result.text); passed++; }
    else XCTAssertEqual(AGXNotFoundError, error.code);
    all++;
    error = nil;
    result = [_reader decode:_bundle.imageWithFile(@"11.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(@"9780441014989", result.text); passed++; }
    else XCTAssertEqual(AGXNotFoundError, error.code);
    all++;
    error = nil;
    result = [_reader decode:_bundle.imageWithFile(@"12.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(@"9780441014989", result.text); passed++; }
    else XCTAssertEqual(AGXNotFoundError, error.code);
    all++;
    error = nil;
    result = [_reader decode:_bundle.imageWithFile(@"13.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(@"9780441014989", result.text); passed++; }
    else XCTAssertEqual(AGXNotFoundError, error.code);
    all++;
    error = nil;
    result = [_reader decode:_bundle.imageWithFile(@"14.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(@"9780441014989", result.text); passed++; }
    else XCTAssertEqual(AGXNotFoundError, error.code);
    all++;
    error = nil;
    result = [_reader decode:_bundle.imageWithFile(@"15.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(@"9780441014989", result.text); passed++; }
    else XCTAssertEqual(AGXNotFoundError, error.code);
    all++;
    error = nil;
    result = [_reader decode:_bundle.imageWithFile(@"16.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(@"9780441014989", result.text); passed++; }
    else XCTAssertEqual(AGXNotFoundError, error.code);
    all++;
    error = nil;
    result = [_reader decode:_bundle.imageWithFile(@"17.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(@"9780441014989", result.text); passed++; }
    else XCTAssertEqual(AGXNotFoundError, error.code);
    all++;
    error = nil;
    result = [_reader decode:_bundle.imageWithFile(@"18.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(@"9780441014989", result.text); passed++; }
    else XCTAssertEqual(AGXNotFoundError, error.code);
    all++;
    error = nil;
    result = [_reader decode:_bundle.imageWithFile(@"19.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(@"9780441014989", result.text); passed++; }
    else XCTAssertEqual(AGXNotFoundError, error.code);
    all++;
    error = nil;
    result = [_reader decode:_bundle.imageWithFile(@"20.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(@"9780441014989", result.text); passed++; }
    else XCTAssertEqual(AGXNotFoundError, error.code);
    all++;
    error = nil;
    result = [_reader decode:_bundle.imageWithFile(@"21.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(@"9780441014989", result.text); passed++; }
    else XCTAssertEqual(AGXNotFoundError, error.code);
    all++;
    error = nil;
    result = [_reader decode:_bundle.imageWithFile(@"22.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(@"9780441014989", result.text); passed++; }
    else XCTAssertEqual(AGXNotFoundError, error.code);
    all++;
    error = nil;
    NSLog(@"%@:%@, all:%d, passed:%d", NSStringFromClass([self class]), NSStringFromSelector(_cmd), all, passed);
}

- (void)testean135 {
    _bundle.subpathAs(@"blackbox/ean13-5");
    AGXGcodeResult *result = nil;
    NSError *error = nil;
    int all = 0, passed = 0;

    result = [_reader decode:_bundle.imageWithFile(@"01.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(@"9780679601050", result.text); passed++; }
    else XCTAssertEqual(AGXNotFoundError, error.code);
    all++;
    error = nil;
    result = [_reader decode:_bundle.imageWithFile(@"02.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(@"9780679601050", result.text); passed++; }
    else XCTAssertEqual(AGXNotFoundError, error.code);
    all++;
    error = nil;
    result = [_reader decode:_bundle.imageWithFile(@"03.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(@"9780679601050", result.text); passed++; }
    else XCTAssertEqual(AGXNotFoundError, error.code);
    all++;
    error = nil;
    result = [_reader decode:_bundle.imageWithFile(@"04.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(@"9780679601050", result.text); passed++; }
    else XCTAssertEqual(AGXNotFoundError, error.code);
    all++;
    error = nil;
    result = [_reader decode:_bundle.imageWithFile(@"05.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(@"9780679601050", result.text); passed++; }
    else XCTAssertEqual(AGXNotFoundError, error.code);
    all++;
    error = nil;
    result = [_reader decode:_bundle.imageWithFile(@"06.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(@"9780345460950", result.text); passed++; }
    else XCTAssertEqual(AGXNotFoundError, error.code);
    all++;
    error = nil;
    result = [_reader decode:_bundle.imageWithFile(@"07.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(@"9780345460950", result.text); passed++; }
    else XCTAssertEqual(AGXNotFoundError, error.code);
    all++;
    error = nil;
    result = [_reader decode:_bundle.imageWithFile(@"08.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(@"9780345460950", result.text); passed++; }
    else XCTAssertEqual(AGXNotFoundError, error.code);
    all++;
    error = nil;
    result = [_reader decode:_bundle.imageWithFile(@"09.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(@"9780345460950", result.text); passed++; }
    else XCTAssertEqual(AGXNotFoundError, error.code);
    all++;
    error = nil;
    result = [_reader decode:_bundle.imageWithFile(@"10.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(@"9780345460950", result.text); passed++; }
    else XCTAssertEqual(AGXNotFoundError, error.code);
    all++;
    error = nil;
    result = [_reader decode:_bundle.imageWithFile(@"11.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(@"9780345460950", result.text); passed++; }
    else XCTAssertEqual(AGXNotFoundError, error.code);
    all++;
    error = nil;
    result = [_reader decode:_bundle.imageWithFile(@"12.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(@"9780345460950", result.text); passed++; }
    else XCTAssertEqual(AGXNotFoundError, error.code);
    all++;
    error = nil;
    result = [_reader decode:_bundle.imageWithFile(@"13.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(@"9780446579803", result.text); passed++; }
    else XCTAssertEqual(AGXNotFoundError, error.code);
    all++;
    error = nil;
    result = [_reader decode:_bundle.imageWithFile(@"14.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(@"9780446579803", result.text); passed++; }
    else XCTAssertEqual(AGXNotFoundError, error.code);
    all++;
    error = nil;
    result = [_reader decode:_bundle.imageWithFile(@"15.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(@"9780446579803", result.text); passed++; }
    else XCTAssertEqual(AGXNotFoundError, error.code);
    all++;
    error = nil;
    result = [_reader decode:_bundle.imageWithFile(@"16.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(@"9780446579803", result.text); passed++; }
    else XCTAssertEqual(AGXNotFoundError, error.code);
    all++;
    error = nil;
    result = [_reader decode:_bundle.imageWithFile(@"17.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(@"9780446579803", result.text); passed++; }
    else XCTAssertEqual(AGXNotFoundError, error.code);
    all++;
    error = nil;
    result = [_reader decode:_bundle.imageWithFile(@"18.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(@"9780446579803", result.text); passed++; }
    else XCTAssertEqual(AGXNotFoundError, error.code);
    all++;
    error = nil;
    NSLog(@"%@:%@, all:%d, passed:%d", NSStringFromClass([self class]), NSStringFromSelector(_cmd), all, passed);
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

- (void)testcode391 {
    _bundle.subpathAs(@"blackbox/code39-1");
    AGXGcodeResult *result = nil;
    NSError *error = nil;
    int all = 0, passed = 0;

    result = [_reader decode:_bundle.imageWithFile(@"1.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(@"TEST-SHEET", result.text); passed++; }
    else XCTAssertEqual(AGXNotFoundError, error.code);
    all++;
    error = nil;
    result = [_reader decode:_bundle.imageWithFile(@"2.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(@" WWW.CITRONSOFT.COM ", result.text); passed++; }
    else XCTAssertEqual(AGXNotFoundError, error.code);
    all++;
    error = nil;
    result = [_reader decode:_bundle.imageWithFile(@"3.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(@"MOROVIA", result.text); passed++; }
    else XCTAssertEqual(AGXNotFoundError, error.code);
    all++;
    error = nil;
    result = [_reader decode:_bundle.imageWithFile(@"4.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(@"ABC123", result.text); passed++; }
    else XCTAssertEqual(AGXNotFoundError, error.code);
    all++;
    error = nil;
    NSLog(@"%@:%@, all:%d, passed:%d", NSStringFromClass([self class]), NSStringFromSelector(_cmd), all, passed);
}

- (void)testcode392 {
    _bundle.subpathAs(@"blackbox/code39-2");
    AGXGcodeResult *result = nil;
    NSError *error = nil;
    int all = 0, passed = 0;

    result = [_reader decode:_bundle.imageWithFile(@"1.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(@"Extended !?*#", result.text); passed++; }
    else XCTAssertEqual(AGXNotFoundError, error.code);
    all++;
    error = nil;
    result = [_reader decode:_bundle.imageWithFile(@"2.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(@"12ab", result.text); passed++; }
    else XCTAssertEqual(AGXNotFoundError, error.code);
    all++;
    error = nil;
    NSLog(@"%@:%@, all:%d, passed:%d", NSStringFromClass([self class]), NSStringFromSelector(_cmd), all, passed);
}

- (void)testcode393 {
    _bundle.subpathAs(@"blackbox/code39-3");
    AGXGcodeResult *result = nil;
    NSError *error = nil;
    int all = 0, passed = 0;

    result = [_reader decode:_bundle.imageWithFile(@"01.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(@"165627", result.text); passed++; }
    else XCTAssertEqual(AGXNotFoundError, error.code);
    all++;
    error = nil;
    result = [_reader decode:_bundle.imageWithFile(@"02.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(@"165627", result.text); passed++; }
    else XCTAssertEqual(AGXNotFoundError, error.code);
    all++;
    error = nil;
    result = [_reader decode:_bundle.imageWithFile(@"03.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(@"001EC947D49B", result.text); passed++; }
    else XCTAssertEqual(AGXNotFoundError, error.code);
    all++;
    error = nil;
    result = [_reader decode:_bundle.imageWithFile(@"04.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(@"001EC947D49B", result.text); passed++; }
    else XCTAssertEqual(AGXNotFoundError, error.code);
    all++;
    error = nil;
    result = [_reader decode:_bundle.imageWithFile(@"05.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(@"001EC947D49B", result.text); passed++; }
    else XCTAssertEqual(AGXNotFoundError, error.code);
    all++;
    error = nil;
    result = [_reader decode:_bundle.imageWithFile(@"06.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(@"165340", result.text); passed++; }
    else XCTAssertEqual(AGXNotFoundError, error.code);
    all++;
    error = nil;
    result = [_reader decode:_bundle.imageWithFile(@"07.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(@"165340", result.text); passed++; }
    else XCTAssertEqual(AGXNotFoundError, error.code);
    all++;
    error = nil;
    result = [_reader decode:_bundle.imageWithFile(@"08.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(@"165340", result.text); passed++; }
    else XCTAssertEqual(AGXNotFoundError, error.code);
    all++;
    error = nil;
    result = [_reader decode:_bundle.imageWithFile(@"09.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(@"165340", result.text); passed++; }
    else XCTAssertEqual(AGXNotFoundError, error.code);
    all++;
    error = nil;
    result = [_reader decode:_bundle.imageWithFile(@"10.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(@"001EC94767E0", result.text); passed++; }
    else XCTAssertEqual(AGXNotFoundError, error.code);
    all++;
    error = nil;
    result = [_reader decode:_bundle.imageWithFile(@"11.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(@"001EC94767E0", result.text); passed++; }
    else XCTAssertEqual(AGXNotFoundError, error.code);
    all++;
    error = nil;
    result = [_reader decode:_bundle.imageWithFile(@"12.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(@"001EC94767E0", result.text); passed++; }
    else XCTAssertEqual(AGXNotFoundError, error.code);
    all++;
    error = nil;
    result = [_reader decode:_bundle.imageWithFile(@"13.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(@"001EC94767E0", result.text); passed++; }
    else XCTAssertEqual(AGXNotFoundError, error.code);
    all++;
    error = nil;
    result = [_reader decode:_bundle.imageWithFile(@"14.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(@"404785", result.text); passed++; }
    else XCTAssertEqual(AGXNotFoundError, error.code);
    all++;
    error = nil;
    result = [_reader decode:_bundle.imageWithFile(@"15.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(@"404785", result.text); passed++; }
    else XCTAssertEqual(AGXNotFoundError, error.code);
    all++;
    error = nil;
    result = [_reader decode:_bundle.imageWithFile(@"16.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(@"404785", result.text); passed++; }
    else XCTAssertEqual(AGXNotFoundError, error.code);
    all++;
    error = nil;
    result = [_reader decode:_bundle.imageWithFile(@"17.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(@"404785", result.text); passed++; }
    else XCTAssertEqual(AGXNotFoundError, error.code);
    all++;
    error = nil;
    NSLog(@"%@:%@, all:%d, passed:%d", NSStringFromClass([self class]), NSStringFromSelector(_cmd), all, passed);
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
    NSLog(@"%@:%@, all:%d, passed:%d", NSStringFromClass([self class]), NSStringFromSelector(_cmd), all, passed);
}

- (void)testcode1281 {
    _bundle.subpathAs(@"blackbox/code128-1");
    AGXGcodeResult *result = nil;
    NSError *error = nil;
    int all = 0, passed = 0;

    result = [_reader decode:_bundle.imageWithFile(@"1.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(@"168901", result.text); passed++; }
    else XCTAssertEqual(AGXNotFoundError, error.code);
    all++;
    error = nil;
    result = [_reader decode:_bundle.imageWithFile(@"2.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(@"Code 128", result.text); passed++; }
    else XCTAssertEqual(AGXNotFoundError, error.code);
    all++;
    error = nil;
    result = [_reader decode:_bundle.imageWithFile(@"3.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(@"102030405060708090", result.text); passed++; }
    else XCTAssertEqual(AGXNotFoundError, error.code);
    all++;
    error = nil;
    result = [_reader decode:_bundle.imageWithFile(@"4.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(@"123456", result.text); passed++; }
    else XCTAssertEqual(AGXNotFoundError, error.code);
    all++;
    error = nil;
    result = [_reader decode:_bundle.imageWithFile(@"5.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(@"8101054321120021123456", result.text); passed++; }
    else XCTAssertEqual(AGXNotFoundError, error.code);
    all++;
    error = nil;
    result = [_reader decode:_bundle.imageWithFile(@"6.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(@"óóóó1234óóabózz", result.text); passed++; }
    else XCTAssertEqual(AGXNotFoundError, error.code);
    all++;
    error = nil;
    NSLog(@"%@:%@, all:%d, passed:%d", NSStringFromClass([self class]), NSStringFromSelector(_cmd), all, passed);
}

- (void)testcode1282 {
    _bundle.subpathAs(@"blackbox/code128-2");
    AGXGcodeResult *result = nil;
    NSError *error = nil;
    int all = 0, passed = 0;

    result = [_reader decode:_bundle.imageWithFile(@"01.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(@"005-3379497200006", result.text); passed++; }
    else XCTAssertEqual(AGXNotFoundError, error.code);
    all++;
    error = nil;
    result = [_reader decode:_bundle.imageWithFile(@"02.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(@"005-3379497200006", result.text); passed++; }
    else XCTAssertEqual(AGXNotFoundError, error.code);
    all++;
    error = nil;
    result = [_reader decode:_bundle.imageWithFile(@"03.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(@"005-3379497200006", result.text); passed++; }
    else XCTAssertEqual(AGXNotFoundError, error.code);
    all++;
    error = nil;
    result = [_reader decode:_bundle.imageWithFile(@"04.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(@"005-3379497200006", result.text); passed++; }
    else XCTAssertEqual(AGXNotFoundError, error.code);
    all++;
    error = nil;
    result = [_reader decode:_bundle.imageWithFile(@"05.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(@"15182881", result.text); passed++; }
    else XCTAssertEqual(AGXNotFoundError, error.code);
    all++;
    error = nil;
    result = [_reader decode:_bundle.imageWithFile(@"06.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(@"15182881", result.text); passed++; }
    else XCTAssertEqual(AGXNotFoundError, error.code);
    all++;
    error = nil;
    result = [_reader decode:_bundle.imageWithFile(@"07.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(@"15182881", result.text); passed++; }
    else XCTAssertEqual(AGXNotFoundError, error.code);
    all++;
    error = nil;
    result = [_reader decode:_bundle.imageWithFile(@"08.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(@"15182881", result.text); passed++; }
    else XCTAssertEqual(AGXNotFoundError, error.code);
    all++;
    error = nil;
    result = [_reader decode:_bundle.imageWithFile(@"09.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(@"CNK8181G2C", result.text); passed++; }
    else XCTAssertEqual(AGXNotFoundError, error.code);
    all++;
    error = nil;
    result = [_reader decode:_bundle.imageWithFile(@"10.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(@"CNK8181G2C", result.text); passed++; }
    else XCTAssertEqual(AGXNotFoundError, error.code);
    all++;
    error = nil;
    result = [_reader decode:_bundle.imageWithFile(@"11.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(@"CNK8181G2C", result.text); passed++; }
    else XCTAssertEqual(AGXNotFoundError, error.code);
    all++;
    error = nil;
    result = [_reader decode:_bundle.imageWithFile(@"12.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(@"CNK8181G2C", result.text); passed++; }
    else XCTAssertEqual(AGXNotFoundError, error.code);
    all++;
    error = nil;
    result = [_reader decode:_bundle.imageWithFile(@"13.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(@"1PEF224A4", result.text); passed++; }
    else XCTAssertEqual(AGXNotFoundError, error.code);
    all++;
    error = nil;
    result = [_reader decode:_bundle.imageWithFile(@"14.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(@"1PEF224A4", result.text); passed++; }
    else XCTAssertEqual(AGXNotFoundError, error.code);
    all++;
    error = nil;
    result = [_reader decode:_bundle.imageWithFile(@"15.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(@"1PEF224A4", result.text); passed++; }
    else XCTAssertEqual(AGXNotFoundError, error.code);
    all++;
    error = nil;
    result = [_reader decode:_bundle.imageWithFile(@"16.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(@"1PEF224A4", result.text); passed++; }
    else XCTAssertEqual(AGXNotFoundError, error.code);
    all++;
    error = nil;
    result = [_reader decode:_bundle.imageWithFile(@"17.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(@"FW727", result.text); passed++; }
    else XCTAssertEqual(AGXNotFoundError, error.code);
    all++;
    error = nil;
    result = [_reader decode:_bundle.imageWithFile(@"18.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(@"FW727", result.text); passed++; }
    else XCTAssertEqual(AGXNotFoundError, error.code);
    all++;
    error = nil;
    result = [_reader decode:_bundle.imageWithFile(@"19.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(@"FW727", result.text); passed++; }
    else XCTAssertEqual(AGXNotFoundError, error.code);
    all++;
    error = nil;
    result = [_reader decode:_bundle.imageWithFile(@"20.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(@"FW727", result.text); passed++; }
    else XCTAssertEqual(AGXNotFoundError, error.code);
    all++;
    error = nil;
    result = [_reader decode:_bundle.imageWithFile(@"21.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(@"005-3354174500018", result.text); passed++; }
    else XCTAssertEqual(AGXNotFoundError, error.code);
    all++;
    error = nil;
    result = [_reader decode:_bundle.imageWithFile(@"22.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(@"005-3354174500018", result.text); passed++; }
    else XCTAssertEqual(AGXNotFoundError, error.code);
    all++;
    error = nil;
    result = [_reader decode:_bundle.imageWithFile(@"23.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(@"005-3354174500018", result.text); passed++; }
    else XCTAssertEqual(AGXNotFoundError, error.code);
    all++;
    error = nil;
    result = [_reader decode:_bundle.imageWithFile(@"24.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(@"005-3354174500018", result.text); passed++; }
    else XCTAssertEqual(AGXNotFoundError, error.code);
    all++;
    error = nil;
    result = [_reader decode:_bundle.imageWithFile(@"25.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(@"31001171800000017989625355702636", result.text); passed++; }
    else XCTAssertEqual(AGXNotFoundError, error.code);
    all++;
    error = nil;
    result = [_reader decode:_bundle.imageWithFile(@"26.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(@"31001171800000017989625355702636", result.text); passed++; }
    else XCTAssertEqual(AGXNotFoundError, error.code);
    all++;
    error = nil;
    result = [_reader decode:_bundle.imageWithFile(@"27.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(@"31001171800000017989625355702636", result.text); passed++; }
    else XCTAssertEqual(AGXNotFoundError, error.code);
    all++;
    error = nil;
    result = [_reader decode:_bundle.imageWithFile(@"28.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(@"31001171800000017989625355702636", result.text); passed++; }
    else XCTAssertEqual(AGXNotFoundError, error.code);
    all++;
    error = nil;
    result = [_reader decode:_bundle.imageWithFile(@"29.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(@"42094043", result.text); passed++; }
    else XCTAssertEqual(AGXNotFoundError, error.code);
    all++;
    error = nil;
    result = [_reader decode:_bundle.imageWithFile(@"30.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(@"42094043", result.text); passed++; }
    else XCTAssertEqual(AGXNotFoundError, error.code);
    all++;
    error = nil;
    result = [_reader decode:_bundle.imageWithFile(@"31.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(@"42094043", result.text); passed++; }
    else XCTAssertEqual(AGXNotFoundError, error.code);
    all++;
    error = nil;
    result = [_reader decode:_bundle.imageWithFile(@"32.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(@"42094043", result.text); passed++; }
    else XCTAssertEqual(AGXNotFoundError, error.code);
    all++;
    error = nil;
    result = [_reader decode:_bundle.imageWithFile(@"33.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(@"30885909173823", result.text); passed++; }
    else XCTAssertEqual(AGXNotFoundError, error.code);
    all++;
    error = nil;
    result = [_reader decode:_bundle.imageWithFile(@"34.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(@"30885909173823", result.text); passed++; }
    else XCTAssertEqual(AGXNotFoundError, error.code);
    all++;
    error = nil;
    result = [_reader decode:_bundle.imageWithFile(@"35.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(@"30885909173823", result.text); passed++; }
    else XCTAssertEqual(AGXNotFoundError, error.code);
    all++;
    error = nil;
    result = [_reader decode:_bundle.imageWithFile(@"36.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(@"30885909173823", result.text); passed++; }
    else XCTAssertEqual(AGXNotFoundError, error.code);
    all++;
    error = nil;
    result = [_reader decode:_bundle.imageWithFile(@"37.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(@"FGGQ6D1", result.text); passed++; }
    else XCTAssertEqual(AGXNotFoundError, error.code);
    all++;
    error = nil;
    result = [_reader decode:_bundle.imageWithFile(@"38.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(@"FGGQ6D1", result.text); passed++; }
    else XCTAssertEqual(AGXNotFoundError, error.code);
    all++;
    error = nil;
    result = [_reader decode:_bundle.imageWithFile(@"39.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(@"FGGQ6D1", result.text); passed++; }
    else XCTAssertEqual(AGXNotFoundError, error.code);
    all++;
    error = nil;
    result = [_reader decode:_bundle.imageWithFile(@"40.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(@"FGGQ6D1", result.text); passed++; }
    else XCTAssertEqual(AGXNotFoundError, error.code);
    all++;
    error = nil;
    NSLog(@"%@:%@, all:%d, passed:%d", NSStringFromClass([self class]), NSStringFromSelector(_cmd), all, passed);
}

- (void)testcode1283 {
    _bundle.subpathAs(@"blackbox/code128-3");
    AGXGcodeResult *result = nil;
    NSError *error = nil;
    int all = 0, passed = 0;

    result = [_reader decode:_bundle.imageWithFile(@"1.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(@"10064908", result.text); passed++; }
    else XCTAssertEqual(AGXNotFoundError, error.code);
    all++;
    error = nil;
    result = [_reader decode:_bundle.imageWithFile(@"2.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(@"10068408", result.text); passed++; }
    else XCTAssertEqual(AGXNotFoundError, error.code);
    all++;
    error = nil;
    NSLog(@"%@:%@, all:%d, passed:%d", NSStringFromClass([self class]), NSStringFromSelector(_cmd), all, passed);
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
    NSLog(@"%@:%@, all:%d, passed:%d", NSStringFromClass([self class]), NSStringFromSelector(_cmd), all, passed);
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
    NSLog(@"%@:%@, all:%d, passed:%d", NSStringFromClass([self class]), NSStringFromSelector(_cmd), all, passed);
}

- (void)testpdf4171 {
    _bundle.subpathAs(@"blackbox/pdf417-1");
    AGXGcodeResult *result = nil;
    NSError *error = nil;
    int all = 0, passed = 0;

    result = [_reader decode:_bundle.imageWithFile(@"01.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(@"This is PDF417", result.text); passed++; }
    else XCTAssertEqual(AGXNotFoundError, error.code);
    all++;
    error = nil;
    result = [_reader decode:_bundle.imageWithFile(@"02.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(@"12345678", result.text); passed++; }
    else XCTAssertEqual(AGXNotFoundError, error.code);
    all++;
    error = nil;
    result = [_reader decode:_bundle.imageWithFile(@"03.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(@"ActiveBarcode", result.text); passed++; }
    else XCTAssertEqual(AGXNotFoundError, error.code);
    all++;
    error = nil;
    result = [_reader decode:_bundle.imageWithFile(@"04.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(@"-ActiveBarcode-ABCDEFGHIJKLMNOPQRSTUVWXYZ", result.text); passed++; }
    else XCTAssertEqual(AGXNotFoundError, error.code);
    all++;
    error = nil;
    result = [_reader decode:_bundle.imageWithFile(@"05.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(@"-ActiveBarcode-ABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890-ActiveBarcode-ABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890", result.text); passed++; }
    else XCTAssertEqual(AGXNotFoundError, error.code);
    all++;
    error = nil;
    result = [_reader decode:_bundle.imageWithFile(@"06.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(@"-ActiveBarcode-ABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890-ActiveBarcode-ABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890-ActiveBarcode-ABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890-ActiveBarcode-ABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890-ActiveBarcode-ABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890-ActiveBarcode-ABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890", result.text); passed++; }
    else XCTAssertEqual(AGXNotFoundError, error.code);
    all++;
    error = nil;
    result = [_reader decode:_bundle.imageWithFile(@"07.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(@"-ActiveBarcode-ABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890-ActiveBarcode-ABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890-ActiveBarcode-ABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890-ActiveBarcode-ABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890-ActiveBarcode-ABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890-ActiveBarcode-ABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890-ActiveBarcode-ABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890-ActiveBarcode-ABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890-ActiveBarcode-ABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890-ActiveBarcode-ABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890-ActiveBarcode-ABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890-ActiveBarcode-ABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890", result.text); passed++; }
    else XCTAssertEqual(AGXNotFoundError, error.code);
    all++;
    error = nil;
    result = [_reader decode:_bundle.imageWithFile(@"09.png") hints:nil error:&error];
    if (!error) {
        XCTAssertEqualObjects(_bundle.stringWithFile(@"09.bin", NSISOLatin1StringEncoding), result.text); passed++;
    } else XCTAssertEqual(AGXNotFoundError, error.code);
    all++;
    error = nil;
    result = [_reader decode:_bundle.imageWithFile(@"10.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(@"PDF-417", result.text); passed++; }
    else XCTAssertEqual(AGXNotFoundError, error.code);
    all++;
    error = nil;
    NSLog(@"%@:%@, all:%d, passed:%d", NSStringFromClass([self class]), NSStringFromSelector(_cmd), all, passed);
}

- (void)testpdf4172 {
    _bundle.subpathAs(@"blackbox/pdf417-2");
    AGXGcodeResult *result = nil;
    NSError *error = nil;
    int all = 0, passed = 0;

    result = [_reader decode:_bundle.imageWithFile(@"01.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(@"1234567890", result.text); passed++; }
    else XCTAssertEqual(AGXNotFoundError, error.code);
    all++;
    error = nil;
    result = [_reader decode:_bundle.imageWithFile(@"02.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(@"1234567890", result.text); passed++; }
    else XCTAssertEqual(AGXNotFoundError, error.code);
    all++;
    error = nil;
    result = [_reader decode:_bundle.imageWithFile(@"03.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(@"1234567890", result.text); passed++; }
    else XCTAssertEqual(AGXNotFoundError, error.code);
    all++;
    error = nil;
    result = [_reader decode:_bundle.imageWithFile(@"04.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(@"1234567890", result.text); passed++; }
    else XCTAssertEqual(AGXNotFoundError, error.code);
    all++;
    error = nil;
    result = [_reader decode:_bundle.imageWithFile(@"05.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(@"1234567890", result.text); passed++; }
    else XCTAssertEqual(AGXNotFoundError, error.code);
    all++;
    error = nil;
    result = [_reader decode:_bundle.imageWithFile(@"06.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(@"1234567890", result.text); passed++; }
    else XCTAssertEqual(AGXNotFoundError, error.code);
    all++;
    error = nil;
    result = [_reader decode:_bundle.imageWithFile(@"07.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(@"1234567890", result.text); passed++; }
    else XCTAssertEqual(AGXNotFoundError, error.code);
    all++;
    error = nil;
    result = [_reader decode:_bundle.imageWithFile(@"08.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(@"A PDF 417 barcode with ASCII text", result.text); passed++; }
    else XCTAssertEqual(AGXNotFoundError, error.code);
    all++;
    error = nil;
    result = [_reader decode:_bundle.imageWithFile(@"09.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(@"A PDF 417 barcode with ASCII text", result.text); passed++; }
    else XCTAssertEqual(AGXNotFoundError, error.code);
    all++;
    error = nil;
    result = [_reader decode:_bundle.imageWithFile(@"10.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(@"A PDF 417 barcode with ASCII text", result.text); passed++; }
    else XCTAssertEqual(AGXNotFoundError, error.code);
    all++;
    error = nil;
    result = [_reader decode:_bundle.imageWithFile(@"11.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(@"A PDF 417 barcode with ASCII text", result.text); passed++; }
    else XCTAssertEqual(AGXNotFoundError, error.code);
    all++;
    error = nil;
    result = [_reader decode:_bundle.imageWithFile(@"12.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(@"A PDF 417 barcode with ASCII text", result.text); passed++; }
    else XCTAssertEqual(AGXNotFoundError, error.code);
    all++;
    error = nil;
    result = [_reader decode:_bundle.imageWithFile(@"13.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(@"A PDF 417 barcode with ASCII text", result.text); passed++; }
    else XCTAssertEqual(AGXNotFoundError, error.code);
    all++;
    error = nil;
    result = [_reader decode:_bundle.imageWithFile(@"14.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(@"A PDF 417 barcode with ASCII text", result.text); passed++; }
    else XCTAssertEqual(AGXNotFoundError, error.code);
    all++;
    error = nil;
    result = [_reader decode:_bundle.imageWithFile(@"15.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(@"A PDF 417 barcode with ASCII text", result.text); passed++; }
    else XCTAssertEqual(AGXNotFoundError, error.code);
    all++;
    error = nil;
    result = [_reader decode:_bundle.imageWithFile(@"16.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(@"A larger PDF 417 barcode with a greater amount of text. This is a more difficult test for mobile devices to resolve.", result.text); passed++; }
    else XCTAssertEqual(AGXNotFoundError, error.code);
    all++;
    error = nil;
    result = [_reader decode:_bundle.imageWithFile(@"17.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(@"A larger PDF 417 barcode with a greater amount of text. This is a more difficult test for mobile devices to resolve.", result.text); passed++; }
    else XCTAssertEqual(AGXNotFoundError, error.code);
    all++;
    error = nil;
    result = [_reader decode:_bundle.imageWithFile(@"18.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(@"A larger PDF 417 barcode with a greater amount of text. This is a more difficult test for mobile devices to resolve.", result.text); passed++; }
    else XCTAssertEqual(AGXNotFoundError, error.code);
    all++;
    error = nil;
    result = [_reader decode:_bundle.imageWithFile(@"19.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(@"A larger PDF 417 barcode with a greater amount of text. This is a more difficult test for mobile devices to resolve.", result.text); passed++; }
    else XCTAssertEqual(AGXNotFoundError, error.code);
    all++;
    error = nil;
    result = [_reader decode:_bundle.imageWithFile(@"20.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(@"A larger PDF 417 barcode with a greater amount of text. This is a more difficult test for mobile devices to resolve.", result.text); passed++; }
    else XCTAssertEqual(AGXNotFoundError, error.code);
    all++;
    error = nil;
    result = [_reader decode:_bundle.imageWithFile(@"21.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(@"A larger PDF 417 barcode with a greater amount of text. This is a more difficult test for mobile devices to resolve.", result.text); passed++; }
    else XCTAssertEqual(AGXNotFoundError, error.code);
    all++;
    error = nil;
    result = [_reader decode:_bundle.imageWithFile(@"22.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(@"A larger PDF 417 barcode with a greater amount of text. This is a more difficult test for mobile devices to resolve.", result.text); passed++; }
    else XCTAssertEqual(AGXNotFoundError, error.code);
    all++;
    error = nil;
    result = [_reader decode:_bundle.imageWithFile(@"23.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(@"A larger PDF 417 barcode with a greater amount of text. This is a more difficult test for mobile devices to resolve.", result.text); passed++; }
    else XCTAssertEqual(AGXNotFoundError, error.code);
    all++;
    error = nil;
    result = [_reader decode:_bundle.imageWithFile(@"24.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(_bundle.stringWithFile(@"24.bin", NSISOLatin1StringEncoding), result.text); passed++; }
    else XCTAssertEqual(AGXNotFoundError, error.code);
    all++;
    error = nil;
    result = [_reader decode:_bundle.imageWithFile(@"25.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(@"This is PDF417", result.text); passed++; }
    else XCTAssertEqual(AGXNotFoundError, error.code);
    all++;
    error = nil;
    NSLog(@"%@:%@, all:%d, passed:%d", NSStringFromClass([self class]), NSStringFromSelector(_cmd), all, passed);
}

- (void)testpdf4173 {
    _bundle.subpathAs(@"blackbox/pdf417-3");
    AGXGcodeResult *result = nil;
    NSError *error = nil;
    int all = 0, passed = 0;

    result = [_reader decode:_bundle.imageWithFile(@"01.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(@"A larger PDF417 barcode with text and error correction level 8.", result.text); passed++; }
    else XCTAssertEqual(AGXNotFoundError, error.code);
    all++;
    error = nil;
    result = [_reader decode:_bundle.imageWithFile(@"02.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(@"A larger PDF417 barcode with text and error correction level 8.", result.text); passed++; }
    else XCTAssertEqual(AGXNotFoundError, error.code);
    all++;
    error = nil;
    result = [_reader decode:_bundle.imageWithFile(@"03.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(@"A larger PDF417 barcode with text and error correction level 8.", result.text); passed++; }
    else XCTAssertEqual(AGXNotFoundError, error.code);
    all++;
    error = nil;
    result = [_reader decode:_bundle.imageWithFile(@"04.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(@"A larger PDF417 barcode with text and error correction level 8.", result.text); passed++; }
    else XCTAssertEqual(AGXNotFoundError, error.code);
    all++;
    error = nil;
    result = [_reader decode:_bundle.imageWithFile(@"05.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(@"A larger PDF417 barcode with text and error correction level 8.", result.text); passed++; }
    else XCTAssertEqual(AGXNotFoundError, error.code);
    all++;
    error = nil;
    result = [_reader decode:_bundle.imageWithFile(@"06.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(@"A larger PDF417 barcode with text and error correction level 8.", result.text); passed++; }
    else XCTAssertEqual(AGXNotFoundError, error.code);
    all++;
    error = nil;
    result = [_reader decode:_bundle.imageWithFile(@"07.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(@"A larger PDF417 barcode with text and error correction level 4.", result.text); passed++; }
    else XCTAssertEqual(AGXNotFoundError, error.code);
    all++;
    error = nil;
    result = [_reader decode:_bundle.imageWithFile(@"08.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(@"A larger PDF417 barcode with text and error correction level 4.", result.text); passed++; }
    else XCTAssertEqual(AGXNotFoundError, error.code);
    all++;
    error = nil;
    result = [_reader decode:_bundle.imageWithFile(@"09.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(@"A larger PDF417 barcode with text and error correction level 4.", result.text); passed++; }
    else XCTAssertEqual(AGXNotFoundError, error.code);
    all++;
    error = nil;
    result = [_reader decode:_bundle.imageWithFile(@"10.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(@"A larger PDF417 barcode with text and error correction level 4.", result.text); passed++; }
    else XCTAssertEqual(AGXNotFoundError, error.code);
    all++;
    error = nil;
    result = [_reader decode:_bundle.imageWithFile(@"11.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(@"A larger PDF417 barcode with text and error correction level 4.", result.text); passed++; }
    else XCTAssertEqual(AGXNotFoundError, error.code);
    all++;
    error = nil;
    result = [_reader decode:_bundle.imageWithFile(@"12.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(@"[)>010210011840539080122327430201FDE238351251289 1/13.0LBY76 NINTH AVENUENEW YORK CITYNYSUSAN ZOLEZZI0610ZED00411ZGOOGLE12Z212565418630Z3100119200000114Z4TH FLOOR15Z39795720Z0.000.0028Z9080122327430201K533 PROGRAMS26Z584a", result.text); passed++; }
    else XCTAssertEqual(AGXNotFoundError, error.code);
    all++;
    error = nil;
    result = [_reader decode:_bundle.imageWithFile(@"13.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(@"A larger PDF417 barcode with text and error correction level 8.", result.text); passed++; }
    else XCTAssertEqual(AGXNotFoundError, error.code);
    all++;
    error = nil;
    result = [_reader decode:_bundle.imageWithFile(@"14.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(@"A larger PDF417 barcode with text and error correction level 8.", result.text); passed++; }
    else XCTAssertEqual(AGXNotFoundError, error.code);
    all++;
    error = nil;
    result = [_reader decode:_bundle.imageWithFile(@"15.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(@"A larger PDF417 barcode with text and error correction level 8.", result.text); passed++; }
    else XCTAssertEqual(AGXNotFoundError, error.code);
    all++;
    error = nil;
    result = [_reader decode:_bundle.imageWithFile(@"16.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(@"A larger PDF417 barcode with text and error correction level 8.", result.text); passed++; }
    else XCTAssertEqual(AGXNotFoundError, error.code);
    all++;
    error = nil;
    result = [_reader decode:_bundle.imageWithFile(@"17.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(@"A larger PDF417 barcode with text and error correction level 8.", result.text); passed++; }
    else XCTAssertEqual(AGXNotFoundError, error.code);
    all++;
    error = nil;
    result = [_reader decode:_bundle.imageWithFile(@"18.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(@"A larger PDF417 barcode with text and error correction level 8.", result.text); passed++; }
    else XCTAssertEqual(AGXNotFoundError, error.code);
    all++;
    error = nil;
    NSLog(@"%@:%@, all:%d, passed:%d", NSStringFromClass([self class]), NSStringFromSelector(_cmd), all, passed);
}

- (void)testpdf4174 {
    _bundle.subpathAs(@"blackbox/pdf417-4");
    AGXGcodeResult *result = nil;
    NSError *error = nil;
    int all = 0, passed = 0;

    result = [_reader decode:_bundle.imageWithFile(@"01-01.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(_bundle.stringWithFile(@"01.bin", NSISOLatin1StringEncoding), result.text); passed++; }
    else XCTAssertEqual(AGXNotFoundError, error.code);
    all++;
    error = nil;
    NSLog(@"%@:%@, all:%d, passed:%d", NSStringFromClass([self class]), NSStringFromSelector(_cmd), all, passed);
}

- (void)testqrcode1 {
    _bundle.subpathAs(@"blackbox/qrcode-1");
    AGXGcodeResult *result = nil;
    NSError *error = nil;
    int all = 0, passed = 0;

    result = [_reader decode:_bundle.imageWithFile(@"1.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(_bundle.stringWithFile(@"1.txt", NSUTF8StringEncoding), result.text); passed++; }
    all++;
    error = nil;
    result = [_reader decode:_bundle.imageWithFile(@"2.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(_bundle.stringWithFile(@"2.txt", NSUTF8StringEncoding), result.text); passed++; }
    all++;
    error = nil;
    result = [_reader decode:_bundle.imageWithFile(@"3.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(_bundle.stringWithFile(@"3.txt", NSUTF8StringEncoding), result.text); passed++; }
    all++;
    error = nil;
    result = [_reader decode:_bundle.imageWithFile(@"4.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(_bundle.stringWithFile(@"4.txt", NSUTF8StringEncoding), result.text); passed++; }
    all++;
    error = nil;
    result = [_reader decode:_bundle.imageWithFile(@"5.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(_bundle.stringWithFile(@"5.txt", NSUTF8StringEncoding), result.text); passed++; }
    all++;
    error = nil;
    result = [_reader decode:_bundle.imageWithFile(@"6.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(_bundle.stringWithFile(@"6.txt", NSUTF8StringEncoding), result.text); passed++; }
    all++;
    error = nil;
    result = [_reader decode:_bundle.imageWithFile(@"7.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(_bundle.stringWithFile(@"7.txt", NSUTF8StringEncoding), result.text); passed++; }
    all++;
    error = nil;
    result = [_reader decode:_bundle.imageWithFile(@"8.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(_bundle.stringWithFile(@"8.txt", NSUTF8StringEncoding), result.text); passed++; }
    all++;
    error = nil;
    result = [_reader decode:_bundle.imageWithFile(@"9.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(_bundle.stringWithFile(@"9.txt", NSUTF8StringEncoding), result.text); passed++; }
    all++;
    error = nil;
    result = [_reader decode:_bundle.imageWithFile(@"10.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(_bundle.stringWithFile(@"10.txt", NSUTF8StringEncoding), result.text); passed++; }
    all++;
    error = nil;
    result = [_reader decode:_bundle.imageWithFile(@"11.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(_bundle.stringWithFile(@"11.txt", NSUTF8StringEncoding), result.text); passed++; }
    all++;
    error = nil;
    result = [_reader decode:_bundle.imageWithFile(@"12.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(_bundle.stringWithFile(@"12.txt", NSUTF8StringEncoding), result.text); passed++; }
    all++;
    error = nil;
    result = [_reader decode:_bundle.imageWithFile(@"13.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(_bundle.stringWithFile(@"13.txt", NSUTF8StringEncoding), result.text); passed++; }
    all++;
    error = nil;
    result = [_reader decode:_bundle.imageWithFile(@"14.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(_bundle.stringWithFile(@"14.txt", NSUTF8StringEncoding), result.text); passed++; }
    all++;
    error = nil;
    result = [_reader decode:_bundle.imageWithFile(@"15.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(_bundle.stringWithFile(@"15.txt", NSUTF8StringEncoding), result.text); passed++; }
    all++;
    error = nil;
    result = [_reader decode:_bundle.imageWithFile(@"16.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(_bundle.stringWithFile(@"16.txt", NSUTF8StringEncoding), result.text); passed++; }
    all++;
    error = nil;
    result = [_reader decode:_bundle.imageWithFile(@"17.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(_bundle.stringWithFile(@"17.txt", NSUTF8StringEncoding), result.text); passed++; }
    all++;
    error = nil;
    result = [_reader decode:_bundle.imageWithFile(@"18.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(_bundle.stringWithFile(@"18.txt", NSUTF8StringEncoding), result.text); passed++; }
    all++;
    error = nil;
    result = [_reader decode:_bundle.imageWithFile(@"19.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(_bundle.stringWithFile(@"19.txt", NSUTF8StringEncoding), result.text); passed++; }
    all++;
    error = nil;
    result = [_reader decode:_bundle.imageWithFile(@"20.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(_bundle.stringWithFile(@"20.txt", NSUTF8StringEncoding), result.text); passed++; }
    all++;
    error = nil;
    NSLog(@"%@:%@, all:%d, passed:%d", NSStringFromClass([self class]), NSStringFromSelector(_cmd), all, passed);
}

- (void)testqrcode2 {
    _bundle.subpathAs(@"blackbox/qrcode-2");
    AGXGcodeResult *result = nil;
    NSError *error = nil;
    int all = 0, passed = 0;

    result = [_reader decode:_bundle.imageWithFile(@"1.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(_bundle.stringWithFile(@"1.txt", NSUTF8StringEncoding), result.text); passed++; }
    all++;
    error = nil;
    result = [_reader decode:_bundle.imageWithFile(@"2.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(_bundle.stringWithFile(@"2.txt", NSUTF8StringEncoding), result.text); passed++; }
    all++;
    error = nil;
    result = [_reader decode:_bundle.imageWithFile(@"4.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(_bundle.stringWithFile(@"4.txt", NSUTF8StringEncoding), result.text); passed++; }
    all++;
    error = nil;
    result = [_reader decode:_bundle.imageWithFile(@"5.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(_bundle.stringWithFile(@"5.txt", NSUTF8StringEncoding), result.text); passed++; }
    all++;
    error = nil;
    result = [_reader decode:_bundle.imageWithFile(@"6.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(_bundle.stringWithFile(@"6.txt", NSUTF8StringEncoding), result.text); passed++; }
    all++;
    error = nil;
    result = [_reader decode:_bundle.imageWithFile(@"7.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(_bundle.stringWithFile(@"7.txt", NSUTF8StringEncoding), result.text); passed++; }
    all++;
    error = nil;
    result = [_reader decode:_bundle.imageWithFile(@"8.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(_bundle.stringWithFile(@"8.txt", NSUTF8StringEncoding), result.text); passed++; }
    all++;
    error = nil;
    result = [_reader decode:_bundle.imageWithFile(@"9.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(_bundle.stringWithFile(@"9.txt", NSUTF8StringEncoding), result.text); passed++; }
    all++;
    error = nil;
    result = [_reader decode:_bundle.imageWithFile(@"10.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(_bundle.stringWithFile(@"10.txt", NSUTF8StringEncoding), result.text); passed++; }
    all++;
    error = nil;
    result = [_reader decode:_bundle.imageWithFile(@"11.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(_bundle.stringWithFile(@"11.txt", NSUTF8StringEncoding), result.text); passed++; }
    all++;
    error = nil;
    result = [_reader decode:_bundle.imageWithFile(@"12.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(_bundle.stringWithFile(@"12.txt", NSUTF8StringEncoding), result.text); passed++; }
    all++;
    error = nil;
    result = [_reader decode:_bundle.imageWithFile(@"13.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(_bundle.stringWithFile(@"13.txt", NSUTF8StringEncoding), result.text); passed++; }
    all++;
    error = nil;
    result = [_reader decode:_bundle.imageWithFile(@"14.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(_bundle.stringWithFile(@"14.txt", NSUTF8StringEncoding), result.text); passed++; }
    all++;
    error = nil;
    result = [_reader decode:_bundle.imageWithFile(@"15.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(_bundle.stringWithFile(@"15.txt", NSUTF8StringEncoding), result.text); passed++; }
    all++;
    error = nil;
    result = [_reader decode:_bundle.imageWithFile(@"16.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(_bundle.stringWithFile(@"16.txt", NSUTF8StringEncoding), result.text); passed++; }
    all++;
    error = nil;
    result = [_reader decode:_bundle.imageWithFile(@"17.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(_bundle.stringWithFile(@"17.txt", NSUTF8StringEncoding), result.text); passed++; }
    all++;
    error = nil;
    result = [_reader decode:_bundle.imageWithFile(@"18.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(_bundle.stringWithFile(@"18.txt", NSUTF8StringEncoding), result.text); passed++; }
    all++;
    error = nil;
    result = [_reader decode:_bundle.imageWithFile(@"19.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(_bundle.stringWithFile(@"19.txt", NSUTF8StringEncoding), result.text); passed++; }
    all++;
    error = nil;
    result = [_reader decode:_bundle.imageWithFile(@"20.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(_bundle.stringWithFile(@"20.txt", NSUTF8StringEncoding), result.text); passed++; }
    all++;
    error = nil;
    result = [_reader decode:_bundle.imageWithFile(@"21.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(_bundle.stringWithFile(@"21.txt", NSUTF8StringEncoding), result.text); passed++; }
    all++;
    error = nil;
    result = [_reader decode:_bundle.imageWithFile(@"22.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(_bundle.stringWithFile(@"22.txt", NSUTF8StringEncoding), result.text); passed++; }
    all++;
    error = nil;
    result = [_reader decode:_bundle.imageWithFile(@"23.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(_bundle.stringWithFile(@"23.txt", NSUTF8StringEncoding), result.text); passed++; }
    all++;
    error = nil;
    result = [_reader decode:_bundle.imageWithFile(@"24.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(_bundle.stringWithFile(@"24.txt", NSUTF8StringEncoding), result.text); passed++; }
    all++;
    error = nil;
    result = [_reader decode:_bundle.imageWithFile(@"25.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(_bundle.stringWithFile(@"25.txt", NSUTF8StringEncoding), result.text); passed++; }
    all++;
    error = nil;
    result = [_reader decode:_bundle.imageWithFile(@"26.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(_bundle.stringWithFile(@"26.txt", NSUTF8StringEncoding), result.text); passed++; }
    all++;
    error = nil;
    result = [_reader decode:_bundle.imageWithFile(@"27.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(_bundle.stringWithFile(@"27.txt", NSUTF8StringEncoding), result.text); passed++; }
    all++;
    error = nil;
    result = [_reader decode:_bundle.imageWithFile(@"28.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(_bundle.stringWithFile(@"28.txt", NSUTF8StringEncoding), result.text); passed++; }
    all++;
    error = nil;
    result = [_reader decode:_bundle.imageWithFile(@"29.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(_bundle.stringWithFile(@"29.txt", NSUTF8StringEncoding), result.text); passed++; }
    all++;
    error = nil;
    result = [_reader decode:_bundle.imageWithFile(@"30.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(_bundle.stringWithFile(@"30.txt", NSUTF8StringEncoding), result.text); passed++; }
    all++;
    error = nil;
    result = [_reader decode:_bundle.imageWithFile(@"31.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(_bundle.stringWithFile(@"31.txt", NSUTF8StringEncoding), result.text); passed++; }
    all++;
    error = nil;
    result = [_reader decode:_bundle.imageWithFile(@"32.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(_bundle.stringWithFile(@"32.txt", NSUTF8StringEncoding), result.text); passed++; }
    all++;
    error = nil;
    result = [_reader decode:_bundle.imageWithFile(@"33.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(_bundle.stringWithFile(@"33.txt", NSUTF8StringEncoding), result.text); passed++; }
    all++;
    error = nil;
    result = [_reader decode:_bundle.imageWithFile(@"34.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(_bundle.stringWithFile(@"34.txt", NSUTF8StringEncoding), result.text); passed++; }
    all++;
    error = nil;
    result = [_reader decode:_bundle.imageWithFile(@"35.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(_bundle.stringWithFile(@"35.txt", NSUTF8StringEncoding), result.text); passed++; }
    all++;
    error = nil;
    NSLog(@"%@:%@, all:%d, passed:%d", NSStringFromClass([self class]), NSStringFromSelector(_cmd), all, passed);
}

- (void)testqrcode3 {
    _bundle.subpathAs(@"blackbox/qrcode-3");
    AGXGcodeResult *result = nil;
    NSError *error = nil;
    int all = 0, passed = 0;

    result = [_reader decode:_bundle.imageWithFile(@"01.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(_bundle.stringWithFile(@"01.txt", NSUTF8StringEncoding), result.text); passed++; }
    all++;
    error = nil;
    result = [_reader decode:_bundle.imageWithFile(@"02.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(_bundle.stringWithFile(@"02.txt", NSUTF8StringEncoding), result.text); passed++; }
    all++;
    error = nil;
    result = [_reader decode:_bundle.imageWithFile(@"03.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(_bundle.stringWithFile(@"03.txt", NSUTF8StringEncoding), result.text); passed++; }
    all++;
    error = nil;
    result = [_reader decode:_bundle.imageWithFile(@"04.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(_bundle.stringWithFile(@"04.txt", NSUTF8StringEncoding), result.text); passed++; }
    all++;
    error = nil;
    result = [_reader decode:_bundle.imageWithFile(@"05.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(_bundle.stringWithFile(@"05.txt", NSUTF8StringEncoding), result.text); passed++; }
    all++;
    error = nil;
    result = [_reader decode:_bundle.imageWithFile(@"06.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(_bundle.stringWithFile(@"06.txt", NSUTF8StringEncoding), result.text); passed++; }
    all++;
    error = nil;
    result = [_reader decode:_bundle.imageWithFile(@"07.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(_bundle.stringWithFile(@"07.txt", NSUTF8StringEncoding), result.text); passed++; }
    all++;
    error = nil;
    result = [_reader decode:_bundle.imageWithFile(@"08.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(_bundle.stringWithFile(@"08.txt", NSUTF8StringEncoding), result.text); passed++; }
    all++;
    error = nil;
    result = [_reader decode:_bundle.imageWithFile(@"09.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(_bundle.stringWithFile(@"09.txt", NSUTF8StringEncoding), result.text); passed++; }
    all++;
    error = nil;
    result = [_reader decode:_bundle.imageWithFile(@"10.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(_bundle.stringWithFile(@"10.txt", NSUTF8StringEncoding), result.text); passed++; }
    all++;
    error = nil;
    result = [_reader decode:_bundle.imageWithFile(@"11.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(_bundle.stringWithFile(@"11.txt", NSUTF8StringEncoding), result.text); passed++; }
    all++;
    error = nil;
    result = [_reader decode:_bundle.imageWithFile(@"12.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(_bundle.stringWithFile(@"12.txt", NSUTF8StringEncoding), result.text); passed++; }
    all++;
    error = nil;
    result = [_reader decode:_bundle.imageWithFile(@"13.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(_bundle.stringWithFile(@"13.txt", NSUTF8StringEncoding), result.text); passed++; }
    all++;
    error = nil;
    result = [_reader decode:_bundle.imageWithFile(@"14.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(_bundle.stringWithFile(@"14.txt", NSUTF8StringEncoding), result.text); passed++; }
    all++;
    error = nil;
    result = [_reader decode:_bundle.imageWithFile(@"15.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(_bundle.stringWithFile(@"15.txt", NSUTF8StringEncoding), result.text); passed++; }
    all++;
    error = nil;
    result = [_reader decode:_bundle.imageWithFile(@"16.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(_bundle.stringWithFile(@"16.txt", NSUTF8StringEncoding), result.text); passed++; }
    all++;
    error = nil;
    result = [_reader decode:_bundle.imageWithFile(@"17.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(_bundle.stringWithFile(@"17.txt", NSUTF8StringEncoding), result.text); passed++; }
    all++;
    error = nil;
    result = [_reader decode:_bundle.imageWithFile(@"18.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(_bundle.stringWithFile(@"18.txt", NSUTF8StringEncoding), result.text); passed++; }
    all++;
    error = nil;
    result = [_reader decode:_bundle.imageWithFile(@"19.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(_bundle.stringWithFile(@"19.txt", NSUTF8StringEncoding), result.text); passed++; }
    all++;
    error = nil;
    result = [_reader decode:_bundle.imageWithFile(@"20.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(_bundle.stringWithFile(@"20.txt", NSUTF8StringEncoding), result.text); passed++; }
    all++;
    error = nil;
    result = [_reader decode:_bundle.imageWithFile(@"21.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(_bundle.stringWithFile(@"21.txt", NSUTF8StringEncoding), result.text); passed++; }
    all++;
    error = nil;
    result = [_reader decode:_bundle.imageWithFile(@"22.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(_bundle.stringWithFile(@"22.txt", NSUTF8StringEncoding), result.text); passed++; }
    all++;
    error = nil;
    result = [_reader decode:_bundle.imageWithFile(@"23.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(_bundle.stringWithFile(@"23.txt", NSUTF8StringEncoding), result.text); passed++; }
    all++;
    error = nil;
    result = [_reader decode:_bundle.imageWithFile(@"24.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(_bundle.stringWithFile(@"24.txt", NSUTF8StringEncoding), result.text); passed++; }
    all++;
    error = nil;
    result = [_reader decode:_bundle.imageWithFile(@"25.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(_bundle.stringWithFile(@"25.txt", NSUTF8StringEncoding), result.text); passed++; }
    all++;
    error = nil;
    result = [_reader decode:_bundle.imageWithFile(@"26.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(_bundle.stringWithFile(@"26.txt", NSUTF8StringEncoding), result.text); passed++; }
    all++;
    error = nil;
    result = [_reader decode:_bundle.imageWithFile(@"27.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(_bundle.stringWithFile(@"27.txt", NSUTF8StringEncoding), result.text); passed++; }
    all++;
    error = nil;
    result = [_reader decode:_bundle.imageWithFile(@"28.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(_bundle.stringWithFile(@"28.txt", NSUTF8StringEncoding), result.text); passed++; }
    all++;
    error = nil;
    result = [_reader decode:_bundle.imageWithFile(@"29.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(_bundle.stringWithFile(@"29.txt", NSUTF8StringEncoding), result.text); passed++; }
    all++;
    error = nil;
    result = [_reader decode:_bundle.imageWithFile(@"30.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(_bundle.stringWithFile(@"30.txt", NSUTF8StringEncoding), result.text); passed++; }
    all++;
    error = nil;
    result = [_reader decode:_bundle.imageWithFile(@"31.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(_bundle.stringWithFile(@"31.txt", NSUTF8StringEncoding), result.text); passed++; }
    all++;
    error = nil;
    result = [_reader decode:_bundle.imageWithFile(@"32.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(_bundle.stringWithFile(@"32.txt", NSUTF8StringEncoding), result.text); passed++; }
    all++;
    error = nil;
    result = [_reader decode:_bundle.imageWithFile(@"33.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(_bundle.stringWithFile(@"33.txt", NSUTF8StringEncoding), result.text); passed++; }
    all++;
    error = nil;
    result = [_reader decode:_bundle.imageWithFile(@"34.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(_bundle.stringWithFile(@"34.txt", NSUTF8StringEncoding), result.text); passed++; }
    all++;
    error = nil;
    result = [_reader decode:_bundle.imageWithFile(@"35.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(_bundle.stringWithFile(@"35.txt", NSUTF8StringEncoding), result.text); passed++; }
    all++;
    error = nil;
    result = [_reader decode:_bundle.imageWithFile(@"36.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(_bundle.stringWithFile(@"36.txt", NSUTF8StringEncoding), result.text); passed++; }
    all++;
    error = nil;
    result = [_reader decode:_bundle.imageWithFile(@"37.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(_bundle.stringWithFile(@"37.txt", NSUTF8StringEncoding), result.text); passed++; }
    all++;
    error = nil;
    result = [_reader decode:_bundle.imageWithFile(@"38.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(_bundle.stringWithFile(@"38.txt", NSUTF8StringEncoding), result.text); passed++; }
    all++;
    error = nil;
    result = [_reader decode:_bundle.imageWithFile(@"39.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(_bundle.stringWithFile(@"39.txt", NSUTF8StringEncoding), result.text); passed++; }
    all++;
    error = nil;
    result = [_reader decode:_bundle.imageWithFile(@"40.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(_bundle.stringWithFile(@"40.txt", NSUTF8StringEncoding), result.text); passed++; }
    all++;
    error = nil;
    result = [_reader decode:_bundle.imageWithFile(@"41.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(_bundle.stringWithFile(@"41.txt", NSUTF8StringEncoding), result.text); passed++; }
    all++;
    error = nil;
    result = [_reader decode:_bundle.imageWithFile(@"42.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(_bundle.stringWithFile(@"42.txt", NSUTF8StringEncoding), result.text); passed++; }
    all++;
    error = nil;
    NSLog(@"%@:%@, all:%d, passed:%d", NSStringFromClass([self class]), NSStringFromSelector(_cmd), all, passed);
}

- (void)testqrcode4 {
    _bundle.subpathAs(@"blackbox/qrcode-4");
    AGXGcodeResult *result = nil;
    NSError *error = nil;
    int all = 0, passed = 0;

    result = [_reader decode:_bundle.imageWithFile(@"01.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(_bundle.stringWithFile(@"01.txt", NSUTF8StringEncoding), result.text); passed++; }
    all++;
    error = nil;
    result = [_reader decode:_bundle.imageWithFile(@"02.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(_bundle.stringWithFile(@"02.txt", NSUTF8StringEncoding), result.text); passed++; }
    all++;
    error = nil;
    result = [_reader decode:_bundle.imageWithFile(@"03.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(_bundle.stringWithFile(@"03.txt", NSUTF8StringEncoding), result.text); passed++; }
    all++;
    error = nil;
    result = [_reader decode:_bundle.imageWithFile(@"04.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(_bundle.stringWithFile(@"04.txt", NSUTF8StringEncoding), result.text); passed++; }
    all++;
    error = nil;
    result = [_reader decode:_bundle.imageWithFile(@"05.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(_bundle.stringWithFile(@"05.txt", NSUTF8StringEncoding), result.text); passed++; }
    all++;
    error = nil;
    result = [_reader decode:_bundle.imageWithFile(@"06.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(_bundle.stringWithFile(@"06.txt", NSUTF8StringEncoding), result.text); passed++; }
    all++;
    error = nil;
    result = [_reader decode:_bundle.imageWithFile(@"07.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(_bundle.stringWithFile(@"07.txt", NSUTF8StringEncoding), result.text); passed++; }
    all++;
    error = nil;
    result = [_reader decode:_bundle.imageWithFile(@"08.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(_bundle.stringWithFile(@"08.txt", NSUTF8StringEncoding), result.text); passed++; }
    all++;
    error = nil;
    result = [_reader decode:_bundle.imageWithFile(@"09.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(_bundle.stringWithFile(@"09.txt", NSUTF8StringEncoding), result.text); passed++; }
    all++;
    error = nil;
    result = [_reader decode:_bundle.imageWithFile(@"10.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(_bundle.stringWithFile(@"10.txt", NSUTF8StringEncoding), result.text); passed++; }
    all++;
    error = nil;
    result = [_reader decode:_bundle.imageWithFile(@"11.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(_bundle.stringWithFile(@"11.txt", NSUTF8StringEncoding), result.text); passed++; }
    all++;
    error = nil;
    result = [_reader decode:_bundle.imageWithFile(@"12.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(_bundle.stringWithFile(@"12.txt", NSUTF8StringEncoding), result.text); passed++; }
    all++;
    error = nil;
    result = [_reader decode:_bundle.imageWithFile(@"13.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(_bundle.stringWithFile(@"13.txt", NSUTF8StringEncoding), result.text); passed++; }
    all++;
    error = nil;
    result = [_reader decode:_bundle.imageWithFile(@"14.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(_bundle.stringWithFile(@"14.txt", NSUTF8StringEncoding), result.text); passed++; }
    all++;
    error = nil;
    result = [_reader decode:_bundle.imageWithFile(@"15.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(_bundle.stringWithFile(@"15.txt", NSUTF8StringEncoding), result.text); passed++; }
    all++;
    error = nil;
    result = [_reader decode:_bundle.imageWithFile(@"16.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(_bundle.stringWithFile(@"16.txt", NSUTF8StringEncoding), result.text); passed++; }
    all++;
    error = nil;
    result = [_reader decode:_bundle.imageWithFile(@"17.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(_bundle.stringWithFile(@"17.txt", NSUTF8StringEncoding), result.text); passed++; }
    all++;
    error = nil;
    result = [_reader decode:_bundle.imageWithFile(@"18.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(_bundle.stringWithFile(@"18.txt", NSUTF8StringEncoding), result.text); passed++; }
    all++;
    error = nil;
    result = [_reader decode:_bundle.imageWithFile(@"19.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(_bundle.stringWithFile(@"19.txt", NSUTF8StringEncoding), result.text); passed++; }
    all++;
    error = nil;
    result = [_reader decode:_bundle.imageWithFile(@"20.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(_bundle.stringWithFile(@"20.txt", NSUTF8StringEncoding), result.text); passed++; }
    all++;
    error = nil;
    result = [_reader decode:_bundle.imageWithFile(@"21.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(_bundle.stringWithFile(@"21.txt", NSUTF8StringEncoding), result.text); passed++; }
    all++;
    error = nil;
    result = [_reader decode:_bundle.imageWithFile(@"22.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(_bundle.stringWithFile(@"22.txt", NSUTF8StringEncoding), result.text); passed++; }
    all++;
    error = nil;
    result = [_reader decode:_bundle.imageWithFile(@"23.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(_bundle.stringWithFile(@"23.txt", NSUTF8StringEncoding), result.text); passed++; }
    all++;
    error = nil;
    result = [_reader decode:_bundle.imageWithFile(@"24.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(_bundle.stringWithFile(@"24.txt", NSUTF8StringEncoding), result.text); passed++; }
    all++;
    error = nil;
    result = [_reader decode:_bundle.imageWithFile(@"25.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(_bundle.stringWithFile(@"25.txt", NSUTF8StringEncoding), result.text); passed++; }
    all++;
    error = nil;
    result = [_reader decode:_bundle.imageWithFile(@"26.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(_bundle.stringWithFile(@"26.txt", NSUTF8StringEncoding), result.text); passed++; }
    all++;
    error = nil;
    result = [_reader decode:_bundle.imageWithFile(@"27.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(_bundle.stringWithFile(@"27.txt", NSUTF8StringEncoding), result.text); passed++; }
    all++;
    error = nil;
    result = [_reader decode:_bundle.imageWithFile(@"28.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(_bundle.stringWithFile(@"28.txt", NSUTF8StringEncoding), result.text); passed++; }
    all++;
    error = nil;
    result = [_reader decode:_bundle.imageWithFile(@"29.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(_bundle.stringWithFile(@"29.txt", NSUTF8StringEncoding), result.text); passed++; }
    all++;
    error = nil;
    result = [_reader decode:_bundle.imageWithFile(@"30.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(_bundle.stringWithFile(@"30.txt", NSUTF8StringEncoding), result.text); passed++; }
    all++;
    error = nil;
    result = [_reader decode:_bundle.imageWithFile(@"31.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(_bundle.stringWithFile(@"31.txt", NSUTF8StringEncoding), result.text); passed++; }
    all++;
    error = nil;
    result = [_reader decode:_bundle.imageWithFile(@"32.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(_bundle.stringWithFile(@"32.txt", NSUTF8StringEncoding), result.text); passed++; }
    all++;
    error = nil;
    result = [_reader decode:_bundle.imageWithFile(@"33.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(_bundle.stringWithFile(@"33.txt", NSUTF8StringEncoding), result.text); passed++; }
    all++;
    error = nil;
    result = [_reader decode:_bundle.imageWithFile(@"34.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(_bundle.stringWithFile(@"34.txt", NSUTF8StringEncoding), result.text); passed++; }
    all++;
    error = nil;
    result = [_reader decode:_bundle.imageWithFile(@"35.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(_bundle.stringWithFile(@"35.txt", NSUTF8StringEncoding), result.text); passed++; }
    all++;
    error = nil;
    result = [_reader decode:_bundle.imageWithFile(@"36.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(_bundle.stringWithFile(@"36.txt", NSUTF8StringEncoding), result.text); passed++; }
    all++;
    error = nil;
    result = [_reader decode:_bundle.imageWithFile(@"37.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(_bundle.stringWithFile(@"37.txt", NSUTF8StringEncoding), result.text); passed++; }
    all++;
    error = nil;
    result = [_reader decode:_bundle.imageWithFile(@"38.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(_bundle.stringWithFile(@"38.txt", NSUTF8StringEncoding), result.text); passed++; }
    all++;
    error = nil;
    result = [_reader decode:_bundle.imageWithFile(@"39.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(_bundle.stringWithFile(@"39.txt", NSUTF8StringEncoding), result.text); passed++; }
    all++;
    error = nil;
    result = [_reader decode:_bundle.imageWithFile(@"40.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(_bundle.stringWithFile(@"40.txt", NSUTF8StringEncoding), result.text); passed++; }
    all++;
    error = nil;
    result = [_reader decode:_bundle.imageWithFile(@"41.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(_bundle.stringWithFile(@"41.txt", NSUTF8StringEncoding), result.text); passed++; }
    all++;
    error = nil;
    result = [_reader decode:_bundle.imageWithFile(@"42.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(_bundle.stringWithFile(@"42.txt", NSUTF8StringEncoding), result.text); passed++; }
    all++;
    error = nil;
    result = [_reader decode:_bundle.imageWithFile(@"43.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(_bundle.stringWithFile(@"43.txt", NSUTF8StringEncoding), result.text); passed++; }
    all++;
    error = nil;
    result = [_reader decode:_bundle.imageWithFile(@"44.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(_bundle.stringWithFile(@"44.txt", NSUTF8StringEncoding), result.text); passed++; }
    all++;
    error = nil;
    result = [_reader decode:_bundle.imageWithFile(@"45.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(_bundle.stringWithFile(@"45.txt", NSUTF8StringEncoding), result.text); passed++; }
    all++;
    error = nil;
    result = [_reader decode:_bundle.imageWithFile(@"46.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(_bundle.stringWithFile(@"46.txt", NSUTF8StringEncoding), result.text); passed++; }
    all++;
    error = nil;
    result = [_reader decode:_bundle.imageWithFile(@"47.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(_bundle.stringWithFile(@"47.txt", NSUTF8StringEncoding), result.text); passed++; }
    all++;
    error = nil;
    result = [_reader decode:_bundle.imageWithFile(@"48.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(_bundle.stringWithFile(@"48.txt", NSUTF8StringEncoding), result.text); passed++; }
    all++;
    error = nil;
    NSLog(@"%@:%@, all:%d, passed:%d", NSStringFromClass([self class]), NSStringFromSelector(_cmd), all, passed);
}

- (void)testqrcode5 {
    _bundle.subpathAs(@"blackbox/qrcode-5");
    AGXGcodeResult *result = nil;
    NSError *error = nil;
    int all = 0, passed = 0;

    result = [_reader decode:_bundle.imageWithFile(@"01.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(_bundle.stringWithFile(@"01.txt", NSUTF8StringEncoding), result.text); passed++; }
    all++;
    error = nil;
    result = [_reader decode:_bundle.imageWithFile(@"02.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(_bundle.stringWithFile(@"02.txt", NSUTF8StringEncoding), result.text); passed++; }
    all++;
    error = nil;
    result = [_reader decode:_bundle.imageWithFile(@"03.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(_bundle.stringWithFile(@"03.txt", NSUTF8StringEncoding), result.text); passed++; }
    all++;
    error = nil;
    result = [_reader decode:_bundle.imageWithFile(@"04.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(_bundle.stringWithFile(@"04.txt", NSUTF8StringEncoding), result.text); passed++; }
    all++;
    error = nil;
    result = [_reader decode:_bundle.imageWithFile(@"05.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(_bundle.stringWithFile(@"05.txt", NSUTF8StringEncoding), result.text); passed++; }
    all++;
    error = nil;
    result = [_reader decode:_bundle.imageWithFile(@"06.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(_bundle.stringWithFile(@"06.txt", NSUTF8StringEncoding), result.text); passed++; }
    all++;
    error = nil;
    result = [_reader decode:_bundle.imageWithFile(@"07.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(_bundle.stringWithFile(@"07.txt", NSUTF8StringEncoding), result.text); passed++; }
    all++;
    error = nil;
    result = [_reader decode:_bundle.imageWithFile(@"08.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(_bundle.stringWithFile(@"08.txt", NSUTF8StringEncoding), result.text); passed++; }
    all++;
    error = nil;
    result = [_reader decode:_bundle.imageWithFile(@"09.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(_bundle.stringWithFile(@"09.txt", NSUTF8StringEncoding), result.text); passed++; }
    all++;
    error = nil;
    result = [_reader decode:_bundle.imageWithFile(@"10.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(_bundle.stringWithFile(@"10.txt", NSUTF8StringEncoding), result.text); passed++; }
    all++;
    error = nil;
    result = [_reader decode:_bundle.imageWithFile(@"11.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(_bundle.stringWithFile(@"11.txt", NSUTF8StringEncoding), result.text); passed++; }
    all++;
    error = nil;
    result = [_reader decode:_bundle.imageWithFile(@"12.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(_bundle.stringWithFile(@"12.txt", NSUTF8StringEncoding), result.text); passed++; }
    all++;
    error = nil;
    result = [_reader decode:_bundle.imageWithFile(@"13.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(_bundle.stringWithFile(@"13.txt", NSUTF8StringEncoding), result.text); passed++; }
    all++;
    error = nil;
    result = [_reader decode:_bundle.imageWithFile(@"14.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(_bundle.stringWithFile(@"14.txt", NSUTF8StringEncoding), result.text); passed++; }
    all++;
    error = nil;
    result = [_reader decode:_bundle.imageWithFile(@"15.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(_bundle.stringWithFile(@"15.txt", NSUTF8StringEncoding), result.text); passed++; }
    all++;
    error = nil;
    result = [_reader decode:_bundle.imageWithFile(@"16.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(_bundle.stringWithFile(@"16.txt", NSUTF8StringEncoding), result.text); passed++; }
    all++;
    error = nil;
    result = [_reader decode:_bundle.imageWithFile(@"17.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(_bundle.stringWithFile(@"17.txt", NSUTF8StringEncoding), result.text); passed++; }
    all++;
    error = nil;
    result = [_reader decode:_bundle.imageWithFile(@"18.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(_bundle.stringWithFile(@"18.txt", NSUTF8StringEncoding), result.text); passed++; }
    all++;
    error = nil;
    result = [_reader decode:_bundle.imageWithFile(@"19.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(_bundle.stringWithFile(@"19.txt", NSUTF8StringEncoding), result.text); passed++; }
    all++;
    error = nil;
    NSLog(@"%@:%@, all:%d, passed:%d", NSStringFromClass([self class]), NSStringFromSelector(_cmd), all, passed);
}

- (void)testqrcode6 {
    _bundle.subpathAs(@"blackbox/qrcode-6");
    AGXGcodeResult *result = nil;
    NSError *error = nil;
    int all = 0, passed = 0;

    result = [_reader decode:_bundle.imageWithFile(@"1.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(_bundle.stringWithFile(@"1.txt", NSUTF8StringEncoding), result.text); passed++; }
    all++;
    error = nil;
    result = [_reader decode:_bundle.imageWithFile(@"2.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(_bundle.stringWithFile(@"2.txt", NSUTF8StringEncoding), result.text); passed++; }
    all++;
    error = nil;
    result = [_reader decode:_bundle.imageWithFile(@"3.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(_bundle.stringWithFile(@"3.txt", NSUTF8StringEncoding), result.text); passed++; }
    all++;
    error = nil;
    result = [_reader decode:_bundle.imageWithFile(@"4.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(_bundle.stringWithFile(@"4.txt", NSUTF8StringEncoding), result.text); passed++; }
    all++;
    error = nil;
    result = [_reader decode:_bundle.imageWithFile(@"5.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(_bundle.stringWithFile(@"5.txt", NSUTF8StringEncoding), result.text); passed++; }
    all++;
    error = nil;
    result = [_reader decode:_bundle.imageWithFile(@"6.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(_bundle.stringWithFile(@"6.txt", NSUTF8StringEncoding), result.text); passed++; }
    all++;
    error = nil;
    result = [_reader decode:_bundle.imageWithFile(@"7.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(_bundle.stringWithFile(@"7.txt", NSUTF8StringEncoding), result.text); passed++; }
    all++;
    error = nil;
    result = [_reader decode:_bundle.imageWithFile(@"8.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(_bundle.stringWithFile(@"8.txt", NSUTF8StringEncoding), result.text); passed++; }
    all++;
    error = nil;
    result = [_reader decode:_bundle.imageWithFile(@"9.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(_bundle.stringWithFile(@"9.txt", NSUTF8StringEncoding), result.text); passed++; }
    all++;
    error = nil;
    result = [_reader decode:_bundle.imageWithFile(@"10.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(_bundle.stringWithFile(@"10.txt", NSUTF8StringEncoding), result.text); passed++; }
    all++;
    error = nil;
    result = [_reader decode:_bundle.imageWithFile(@"11.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(_bundle.stringWithFile(@"11.txt", NSUTF8StringEncoding), result.text); passed++; }
    all++;
    error = nil;
    result = [_reader decode:_bundle.imageWithFile(@"12.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(_bundle.stringWithFile(@"12.txt", NSUTF8StringEncoding), result.text); passed++; }
    all++;
    error = nil;
    result = [_reader decode:_bundle.imageWithFile(@"13.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(_bundle.stringWithFile(@"13.txt", NSUTF8StringEncoding), result.text); passed++; }
    all++;
    error = nil;
    result = [_reader decode:_bundle.imageWithFile(@"14.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(_bundle.stringWithFile(@"14.txt", NSUTF8StringEncoding), result.text); passed++; }
    all++;
    error = nil;
    result = [_reader decode:_bundle.imageWithFile(@"15.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(_bundle.stringWithFile(@"15.txt", NSUTF8StringEncoding), result.text); passed++; }
    all++;
    error = nil;
    NSLog(@"%@:%@, all:%d, passed:%d", NSStringFromClass([self class]), NSStringFromSelector(_cmd), all, passed);
}

- (void)testaztec1 {
    _bundle.subpathAs(@"blackbox/aztec-1");
    AGXGcodeResult *result = nil;
    NSError *error = nil;
    int all = 0, passed = 0;

    result = [_reader decode:_bundle.imageWithFile(@"7.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(_bundle.stringWithFile(@"7.txt", NSUTF8StringEncoding), result.text); passed++; }
    all++;
    error = nil;
    result = [_reader decode:_bundle.imageWithFile(@"abc-19x19C.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(_bundle.stringWithFile(@"abc-19x19C.txt", NSUTF8StringEncoding), result.text); passed++; }
    all++;
    error = nil;
    result = [_reader decode:_bundle.imageWithFile(@"abc-37x37.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(_bundle.stringWithFile(@"abc-37x37.txt", NSUTF8StringEncoding), result.text); passed++; }
    all++;
    error = nil;
    result = [_reader decode:_bundle.imageWithFile(@"hello.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(_bundle.stringWithFile(@"hello.txt", NSUTF8StringEncoding), result.text); passed++; }
    all++;
    error = nil;
    result = [_reader decode:_bundle.imageWithFile(@"05.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(_bundle.stringWithFile(@"05.txt", NSUTF8StringEncoding), result.text); passed++; }
    all++;
    error = nil;
    result = [_reader decode:_bundle.imageWithFile(@"06.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(_bundle.stringWithFile(@"06.txt", NSUTF8StringEncoding), result.text); passed++; }
    all++;
    error = nil;
    result = [_reader decode:_bundle.imageWithFile(@"Historico.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(_bundle.stringWithFile(@"Historico.txt", NSUTF8StringEncoding), result.text); passed++; }
    all++;
    error = nil;
    result = [_reader decode:_bundle.imageWithFile(@"HistoricoLong.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(_bundle.stringWithFile(@"HistoricoLong.txt", NSUTF8StringEncoding), result.text); passed++; }
    all++;
    error = nil;
    result = [_reader decode:_bundle.imageWithFile(@"lorem-075x075.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(_bundle.stringWithFile(@"lorem-075x075.txt", NSUTF8StringEncoding), result.text); passed++; }
    all++;
    error = nil;
    result = [_reader decode:_bundle.imageWithFile(@"lorem-105x105.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(_bundle.stringWithFile(@"lorem-105x105.txt", NSUTF8StringEncoding), result.text); passed++; }
    all++;
    error = nil;
    result = [_reader decode:_bundle.imageWithFile(@"lorem-151x151.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(_bundle.stringWithFile(@"lorem-151x151.txt", NSUTF8StringEncoding), result.text); passed++; }
    all++;
    error = nil;
    result = [_reader decode:_bundle.imageWithFile(@"tableShifts.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(_bundle.stringWithFile(@"tableShifts.txt", NSUTF8StringEncoding), result.text); passed++; }
    all++;
    error = nil;
    result = [_reader decode:_bundle.imageWithFile(@"tag.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(_bundle.stringWithFile(@"tag.txt", NSUTF8StringEncoding), result.text); passed++; }
    all++;
    error = nil;
    result = [_reader decode:_bundle.imageWithFile(@"texte.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(_bundle.stringWithFile(@"texte.txt", NSUTF8StringEncoding), result.text); passed++; }
    all++;
    error = nil;
    NSLog(@"%@:%@, all:%d, passed:%d", NSStringFromClass([self class]), NSStringFromSelector(_cmd), all, passed);
}

- (void)testaztec2 {
    _bundle.subpathAs(@"blackbox/aztec-2");
    AGXGcodeResult *result = nil;
    NSError *error = nil;
    int all = 0, passed = 0;

    result = [_reader decode:_bundle.imageWithFile(@"01.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(_bundle.stringWithFile(@"01.txt", NSUTF8StringEncoding), result.text); passed++; }
    all++;
    error = nil;
    result = [_reader decode:_bundle.imageWithFile(@"02.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(_bundle.stringWithFile(@"02.txt", NSUTF8StringEncoding), result.text); passed++; }
    all++;
    error = nil;
    result = [_reader decode:_bundle.imageWithFile(@"03.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(_bundle.stringWithFile(@"03.txt", NSUTF8StringEncoding), result.text); passed++; }
    all++;
    error = nil;
    result = [_reader decode:_bundle.imageWithFile(@"04.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(_bundle.stringWithFile(@"04.txt", NSUTF8StringEncoding), result.text); passed++; }
    all++;
    error = nil;
    result = [_reader decode:_bundle.imageWithFile(@"05.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(_bundle.stringWithFile(@"05.txt", NSUTF8StringEncoding), result.text); passed++; }
    all++;
    error = nil;
    result = [_reader decode:_bundle.imageWithFile(@"06.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(_bundle.stringWithFile(@"06.txt", NSUTF8StringEncoding), result.text); passed++; }
    all++;
    error = nil;
    result = [_reader decode:_bundle.imageWithFile(@"07.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(_bundle.stringWithFile(@"07.txt", NSUTF8StringEncoding), result.text); passed++; }
    all++;
    error = nil;
    result = [_reader decode:_bundle.imageWithFile(@"08.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(_bundle.stringWithFile(@"08.txt", NSUTF8StringEncoding), result.text); passed++; }
    all++;
    error = nil;
    result = [_reader decode:_bundle.imageWithFile(@"09.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(_bundle.stringWithFile(@"09.txt", NSUTF8StringEncoding), result.text); passed++; }
    all++;
    error = nil;
    result = [_reader decode:_bundle.imageWithFile(@"10.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(_bundle.stringWithFile(@"10.txt", NSUTF8StringEncoding), result.text); passed++; }
    all++;
    error = nil;
    result = [_reader decode:_bundle.imageWithFile(@"11.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(_bundle.stringWithFile(@"11.txt", NSUTF8StringEncoding), result.text); passed++; }
    all++;
    error = nil;
    result = [_reader decode:_bundle.imageWithFile(@"12.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(_bundle.stringWithFile(@"12.txt", NSUTF8StringEncoding), result.text); passed++; }
    all++;
    error = nil;
    result = [_reader decode:_bundle.imageWithFile(@"13.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(_bundle.stringWithFile(@"13.txt", NSUTF8StringEncoding), result.text); passed++; }
    all++;
    error = nil;
    result = [_reader decode:_bundle.imageWithFile(@"14.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(_bundle.stringWithFile(@"14.txt", NSUTF8StringEncoding), result.text); passed++; }
    all++;
    error = nil;
    result = [_reader decode:_bundle.imageWithFile(@"15.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(_bundle.stringWithFile(@"15.txt", NSUTF8StringEncoding), result.text); passed++; }
    all++;
    error = nil;
    result = [_reader decode:_bundle.imageWithFile(@"16.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(_bundle.stringWithFile(@"16.txt", NSUTF8StringEncoding), result.text); passed++; }
    all++;
    error = nil;
    result = [_reader decode:_bundle.imageWithFile(@"17.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(_bundle.stringWithFile(@"17.txt", NSUTF8StringEncoding), result.text); passed++; }
    all++;
    error = nil;
    result = [_reader decode:_bundle.imageWithFile(@"18.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(_bundle.stringWithFile(@"18.txt", NSUTF8StringEncoding), result.text); passed++; }
    all++;
    error = nil;
    result = [_reader decode:_bundle.imageWithFile(@"19.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(_bundle.stringWithFile(@"19.txt", NSUTF8StringEncoding), result.text); passed++; }
    all++;
    error = nil;
    result = [_reader decode:_bundle.imageWithFile(@"20.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(_bundle.stringWithFile(@"20.txt", NSUTF8StringEncoding), result.text); passed++; }
    all++;
    error = nil;
    result = [_reader decode:_bundle.imageWithFile(@"21.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(_bundle.stringWithFile(@"21.txt", NSUTF8StringEncoding), result.text); passed++; }
    all++;
    error = nil;
    result = [_reader decode:_bundle.imageWithFile(@"22.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(_bundle.stringWithFile(@"22.txt", NSUTF8StringEncoding), result.text); passed++; }
    all++;
    error = nil;
    NSLog(@"%@:%@, all:%d, passed:%d", NSStringFromClass([self class]), NSStringFromSelector(_cmd), all, passed);
}

- (void)testdatamatrix1 {
    _bundle.subpathAs(@"blackbox/datamatrix-1");
    AGXGcodeResult *result = nil;
    NSError *error = nil;
    int all = 0, passed = 0;

    result = [_reader decode:_bundle.imageWithFile(@"0123456789.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(_bundle.stringWithFile(@"0123456789.txt", NSUTF8StringEncoding), result.text); passed++; }
    all++;
    error = nil;
    result = [_reader decode:_bundle.imageWithFile(@"abcd-18x8.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(_bundle.stringWithFile(@"abcd-18x8.txt", NSUTF8StringEncoding), result.text); passed++; }
    all++;
    error = nil;
    result = [_reader decode:_bundle.imageWithFile(@"abcd-26x12.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(_bundle.stringWithFile(@"abcd-26x12.txt", NSUTF8StringEncoding), result.text); passed++; }
    all++;
    error = nil;
    result = [_reader decode:_bundle.imageWithFile(@"abcd-32x8.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(_bundle.stringWithFile(@"abcd-32x8.txt", NSUTF8StringEncoding), result.text); passed++; }
    all++;
    error = nil;
    result = [_reader decode:_bundle.imageWithFile(@"abcd-36x12.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(_bundle.stringWithFile(@"abcd-36x12.txt", NSUTF8StringEncoding), result.text); passed++; }
    all++;
    error = nil;
    result = [_reader decode:_bundle.imageWithFile(@"abcd-36x16.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(_bundle.stringWithFile(@"abcd-36x16.txt", NSUTF8StringEncoding), result.text); passed++; }
    all++;
    error = nil;
    result = [_reader decode:_bundle.imageWithFile(@"abcd-48x16.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(_bundle.stringWithFile(@"abcd-48x16.txt", NSUTF8StringEncoding), result.text); passed++; }
    all++;
    error = nil;
    result = [_reader decode:_bundle.imageWithFile(@"abcd-52x52-IDAutomation.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(_bundle.stringWithFile(@"abcd-52x52-IDAutomation.txt", NSUTF8StringEncoding), result.text); passed++; }
    all++;
    error = nil;
    result = [_reader decode:_bundle.imageWithFile(@"abcd-52x52.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(_bundle.stringWithFile(@"abcd-52x52.txt", NSUTF8StringEncoding), result.text); passed++; }
    all++;
    error = nil;
    result = [_reader decode:_bundle.imageWithFile(@"abcdefg-64x64.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(_bundle.stringWithFile(@"abcdefg-64x64.txt", NSUTF8StringEncoding), result.text); passed++; }
    all++;
    error = nil;
    result = [_reader decode:_bundle.imageWithFile(@"abcdefg.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(_bundle.stringWithFile(@"abcdefg.txt", NSUTF8StringEncoding), result.text); passed++; }
    all++;
    error = nil;
    result = [_reader decode:_bundle.imageWithFile(@"GUID.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(_bundle.stringWithFile(@"GUID.txt", NSUTF8StringEncoding), result.text); passed++; }
    all++;
    error = nil;
    result = [_reader decode:_bundle.imageWithFile(@"HelloWorld_Text_L_Kaywa_1_error_byte.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(_bundle.stringWithFile(@"HelloWorld_Text_L_Kaywa_1_error_byte.txt", NSUTF8StringEncoding), result.text); passed++; }
    all++;
    error = nil;
    result = [_reader decode:_bundle.imageWithFile(@"HelloWorld_Text_L_Kaywa_2_error_byte.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(_bundle.stringWithFile(@"HelloWorld_Text_L_Kaywa_2_error_byte.txt", NSUTF8StringEncoding), result.text); passed++; }
    all++;
    error = nil;
    result = [_reader decode:_bundle.imageWithFile(@"HelloWorld_Text_L_Kaywa_3_error_byte.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(_bundle.stringWithFile(@"HelloWorld_Text_L_Kaywa_3_error_byte.txt", NSUTF8StringEncoding), result.text); passed++; }
    all++;
    error = nil;
    result = [_reader decode:_bundle.imageWithFile(@"HelloWorld_Text_L_Kaywa_4_error_byte.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(_bundle.stringWithFile(@"HelloWorld_Text_L_Kaywa_4_error_byte.txt", NSUTF8StringEncoding), result.text); passed++; }
    all++;
    error = nil;
    result = [_reader decode:_bundle.imageWithFile(@"HelloWorld_Text_L_Kaywa_6_error_byte.png.error") hints:nil error:&error];
    if (error) { XCTAssertEqual(AGXNotFoundError, error.code); passed++; }
    all++;
    error = nil;
    result = [_reader decode:_bundle.imageWithFile(@"HelloWorld_Text_L_Kaywa.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(_bundle.stringWithFile(@"HelloWorld_Text_L_Kaywa.txt", NSUTF8StringEncoding), result.text); passed++; }
    all++;
    error = nil;
    result = [_reader decode:_bundle.imageWithFile(@"zxing_URL_L_Kayway.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(_bundle.stringWithFile(@"zxing_URL_L_Kayway.txt", NSUTF8StringEncoding), result.text); passed++; }
    all++;
    error = nil;
    NSLog(@"%@:%@, all:%d, passed:%d", NSStringFromClass([self class]), NSStringFromSelector(_cmd), all, passed);
}

- (void)testdatamatrix2 {
    _bundle.subpathAs(@"blackbox/datamatrix-2");
    AGXGcodeResult *result = nil;
    NSError *error = nil;
    int all = 0, passed = 0;

    result = [_reader decode:_bundle.imageWithFile(@"01.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(_bundle.stringWithFile(@"01.txt", NSUTF8StringEncoding), result.text); passed++; }
    all++;
    error = nil;
    result = [_reader decode:_bundle.imageWithFile(@"02.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(_bundle.stringWithFile(@"02.txt", NSUTF8StringEncoding), result.text); passed++; }
    all++;
    error = nil;
    result = [_reader decode:_bundle.imageWithFile(@"03.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(_bundle.stringWithFile(@"03.txt", NSUTF8StringEncoding), result.text); passed++; }
    all++;
    error = nil;
    result = [_reader decode:_bundle.imageWithFile(@"04.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(_bundle.stringWithFile(@"04.txt", NSUTF8StringEncoding), result.text); passed++; }
    all++;
    error = nil;
    result = [_reader decode:_bundle.imageWithFile(@"05.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(_bundle.stringWithFile(@"05.txt", NSUTF8StringEncoding), result.text); passed++; }
    all++;
    error = nil;
    result = [_reader decode:_bundle.imageWithFile(@"06.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(_bundle.stringWithFile(@"06.txt", NSUTF8StringEncoding), result.text); passed++; }
    all++;
    error = nil;
    result = [_reader decode:_bundle.imageWithFile(@"07.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(_bundle.stringWithFile(@"07.txt", NSUTF8StringEncoding), result.text); passed++; }
    all++;
    error = nil;
    result = [_reader decode:_bundle.imageWithFile(@"08.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(_bundle.stringWithFile(@"08.txt", NSUTF8StringEncoding), result.text); passed++; }
    all++;
    error = nil;
    result = [_reader decode:_bundle.imageWithFile(@"09.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(_bundle.stringWithFile(@"09.txt", NSUTF8StringEncoding), result.text); passed++; }
    all++;
    error = nil;
    result = [_reader decode:_bundle.imageWithFile(@"10.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(_bundle.stringWithFile(@"10.txt", NSUTF8StringEncoding), result.text); passed++; }
    all++;
    error = nil;
    result = [_reader decode:_bundle.imageWithFile(@"11.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(_bundle.stringWithFile(@"11.txt", NSUTF8StringEncoding), result.text); passed++; }
    all++;
    error = nil;
    result = [_reader decode:_bundle.imageWithFile(@"12.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(_bundle.stringWithFile(@"12.txt", NSUTF8StringEncoding), result.text); passed++; }
    all++;
    error = nil;
    result = [_reader decode:_bundle.imageWithFile(@"13.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(_bundle.stringWithFile(@"13.txt", NSUTF8StringEncoding), result.text); passed++; }
    all++;
    error = nil;
    result = [_reader decode:_bundle.imageWithFile(@"14.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(_bundle.stringWithFile(@"14.txt", NSUTF8StringEncoding), result.text); passed++; }
    all++;
    error = nil;
    result = [_reader decode:_bundle.imageWithFile(@"15.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(_bundle.stringWithFile(@"15.txt", NSUTF8StringEncoding), result.text); passed++; }
    all++;
    error = nil;
    result = [_reader decode:_bundle.imageWithFile(@"16.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(_bundle.stringWithFile(@"16.txt", NSUTF8StringEncoding), result.text); passed++; }
    all++;
    error = nil;
    result = [_reader decode:_bundle.imageWithFile(@"17.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(_bundle.stringWithFile(@"17.txt", NSUTF8StringEncoding), result.text); passed++; }
    all++;
    error = nil;
    result = [_reader decode:_bundle.imageWithFile(@"18.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(_bundle.stringWithFile(@"18.txt", NSUTF8StringEncoding), result.text); passed++; }
    all++;
    error = nil;
    NSLog(@"%@:%@, all:%d, passed:%d", NSStringFromClass([self class]), NSStringFromSelector(_cmd), all, passed);
}

@end
