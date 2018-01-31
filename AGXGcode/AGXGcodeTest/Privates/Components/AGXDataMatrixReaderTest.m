//
//  AGXDataMatrixReaderTest.m
//  AGXGcode
//
//  Created by Char Aznable on 2016/8/10.
//  Copyright © 2016年 AI-CUC-EC. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <AGXCore/AGXCore.h>
#import "AGXDataMatrixReader.h"
#import "AGXGcodeError.h"

@interface AGXDataMatrixReaderTest : XCTestCase
@property (nonatomic, AGX_STRONG) AGXBundle *bundle;
@property (nonatomic, AGX_STRONG) AGXDataMatrixReader *reader;
@end

@implementation AGXDataMatrixReaderTest

- (void)setUp {
    [super setUp];
    _bundle = AGX_RETAIN(AGXBundle.bundleNameAs(@"Resources"));
    _reader = [[AGXDataMatrixReader alloc] init];
}

- (void)tearDown {
    AGX_RELEASE(_bundle);
    AGX_RELEASE(_reader);
    [super tearDown];
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
    if (error) { XCTAssertEqual(AGXChecksumError, error.code); passed++; }
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
    NSLog(@"%@:%@, all:%d, passed:%d", NSStringFromClass(self.class), NSStringFromSelector(_cmd), all, passed);
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
    NSLog(@"%@:%@, all:%d, passed:%d", NSStringFromClass(self.class), NSStringFromSelector(_cmd), all, passed);
}

@end
