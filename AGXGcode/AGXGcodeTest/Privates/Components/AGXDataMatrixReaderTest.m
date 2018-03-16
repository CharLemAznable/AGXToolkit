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
@property (nonatomic, AGX_STRONG) AGXResources *resources;
@property (nonatomic, AGX_STRONG) AGXDataMatrixReader *reader;
@end

@implementation AGXDataMatrixReaderTest

- (void)setUp {
    [super setUp];
    _resources = AGX_RETAIN(AGXResources.application.subpathAppendBundleNamed(@"Resources"));
    _reader = [[AGXDataMatrixReader alloc] init];
}

- (void)tearDown {
    AGX_RELEASE(_resources);
    AGX_RELEASE(_reader);
    [super tearDown];
}

- (void)testdatamatrix1 {
    _resources.subpathAppend(@"blackbox/datamatrix-1");
    AGXGcodeResult *result = nil;
    NSError *error = nil;
    int all = 0, passed = 0;

    result = [_reader decode:_resources.imageWithFileNamed(@"0123456789.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(_resources.stringWithFileNamed(@"0123456789.txt", NSUTF8StringEncoding), result.text); passed++; }
    all++;
    error = nil;
    result = [_reader decode:_resources.imageWithFileNamed(@"abcd-18x8.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(_resources.stringWithFileNamed(@"abcd-18x8.txt", NSUTF8StringEncoding), result.text); passed++; }
    all++;
    error = nil;
    result = [_reader decode:_resources.imageWithFileNamed(@"abcd-26x12.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(_resources.stringWithFileNamed(@"abcd-26x12.txt", NSUTF8StringEncoding), result.text); passed++; }
    all++;
    error = nil;
    result = [_reader decode:_resources.imageWithFileNamed(@"abcd-32x8.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(_resources.stringWithFileNamed(@"abcd-32x8.txt", NSUTF8StringEncoding), result.text); passed++; }
    all++;
    error = nil;
    result = [_reader decode:_resources.imageWithFileNamed(@"abcd-36x12.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(_resources.stringWithFileNamed(@"abcd-36x12.txt", NSUTF8StringEncoding), result.text); passed++; }
    all++;
    error = nil;
    result = [_reader decode:_resources.imageWithFileNamed(@"abcd-36x16.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(_resources.stringWithFileNamed(@"abcd-36x16.txt", NSUTF8StringEncoding), result.text); passed++; }
    all++;
    error = nil;
    result = [_reader decode:_resources.imageWithFileNamed(@"abcd-48x16.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(_resources.stringWithFileNamed(@"abcd-48x16.txt", NSUTF8StringEncoding), result.text); passed++; }
    all++;
    error = nil;
    result = [_reader decode:_resources.imageWithFileNamed(@"abcd-52x52-IDAutomation.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(_resources.stringWithFileNamed(@"abcd-52x52-IDAutomation.txt", NSUTF8StringEncoding), result.text); passed++; }
    all++;
    error = nil;
    result = [_reader decode:_resources.imageWithFileNamed(@"abcd-52x52.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(_resources.stringWithFileNamed(@"abcd-52x52.txt", NSUTF8StringEncoding), result.text); passed++; }
    all++;
    error = nil;
    result = [_reader decode:_resources.imageWithFileNamed(@"abcdefg-64x64.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(_resources.stringWithFileNamed(@"abcdefg-64x64.txt", NSUTF8StringEncoding), result.text); passed++; }
    all++;
    error = nil;
    result = [_reader decode:_resources.imageWithFileNamed(@"abcdefg.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(_resources.stringWithFileNamed(@"abcdefg.txt", NSUTF8StringEncoding), result.text); passed++; }
    all++;
    error = nil;
    result = [_reader decode:_resources.imageWithFileNamed(@"GUID.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(_resources.stringWithFileNamed(@"GUID.txt", NSUTF8StringEncoding), result.text); passed++; }
    all++;
    error = nil;
    result = [_reader decode:_resources.imageWithFileNamed(@"HelloWorld_Text_L_Kaywa_1_error_byte.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(_resources.stringWithFileNamed(@"HelloWorld_Text_L_Kaywa_1_error_byte.txt", NSUTF8StringEncoding), result.text); passed++; }
    all++;
    error = nil;
    result = [_reader decode:_resources.imageWithFileNamed(@"HelloWorld_Text_L_Kaywa_2_error_byte.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(_resources.stringWithFileNamed(@"HelloWorld_Text_L_Kaywa_2_error_byte.txt", NSUTF8StringEncoding), result.text); passed++; }
    all++;
    error = nil;
    result = [_reader decode:_resources.imageWithFileNamed(@"HelloWorld_Text_L_Kaywa_3_error_byte.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(_resources.stringWithFileNamed(@"HelloWorld_Text_L_Kaywa_3_error_byte.txt", NSUTF8StringEncoding), result.text); passed++; }
    all++;
    error = nil;
    result = [_reader decode:_resources.imageWithFileNamed(@"HelloWorld_Text_L_Kaywa_4_error_byte.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(_resources.stringWithFileNamed(@"HelloWorld_Text_L_Kaywa_4_error_byte.txt", NSUTF8StringEncoding), result.text); passed++; }
    all++;
    error = nil;
    result = [_reader decode:_resources.imageWithFileNamed(@"HelloWorld_Text_L_Kaywa_6_error_byte.png.error") hints:nil error:&error];
    if (error) { XCTAssertEqual(AGXChecksumError, error.code); passed++; }
    all++;
    error = nil;
    result = [_reader decode:_resources.imageWithFileNamed(@"HelloWorld_Text_L_Kaywa.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(_resources.stringWithFileNamed(@"HelloWorld_Text_L_Kaywa.txt", NSUTF8StringEncoding), result.text); passed++; }
    all++;
    error = nil;
    result = [_reader decode:_resources.imageWithFileNamed(@"zxing_URL_L_Kayway.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(_resources.stringWithFileNamed(@"zxing_URL_L_Kayway.txt", NSUTF8StringEncoding), result.text); passed++; }
    all++;
    error = nil;
    NSLog(@"%@:%@, all:%d, passed:%d", NSStringFromClass(self.class), NSStringFromSelector(_cmd), all, passed);
}

- (void)testdatamatrix2 {
    _resources.subpathAppend(@"blackbox/datamatrix-2");
    AGXGcodeResult *result = nil;
    NSError *error = nil;
    int all = 0, passed = 0;

    result = [_reader decode:_resources.imageWithFileNamed(@"01.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(_resources.stringWithFileNamed(@"01.txt", NSUTF8StringEncoding), result.text); passed++; }
    all++;
    error = nil;
    result = [_reader decode:_resources.imageWithFileNamed(@"02.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(_resources.stringWithFileNamed(@"02.txt", NSUTF8StringEncoding), result.text); passed++; }
    all++;
    error = nil;
    result = [_reader decode:_resources.imageWithFileNamed(@"03.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(_resources.stringWithFileNamed(@"03.txt", NSUTF8StringEncoding), result.text); passed++; }
    all++;
    error = nil;
    result = [_reader decode:_resources.imageWithFileNamed(@"04.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(_resources.stringWithFileNamed(@"04.txt", NSUTF8StringEncoding), result.text); passed++; }
    all++;
    error = nil;
    result = [_reader decode:_resources.imageWithFileNamed(@"05.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(_resources.stringWithFileNamed(@"05.txt", NSUTF8StringEncoding), result.text); passed++; }
    all++;
    error = nil;
    result = [_reader decode:_resources.imageWithFileNamed(@"06.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(_resources.stringWithFileNamed(@"06.txt", NSUTF8StringEncoding), result.text); passed++; }
    all++;
    error = nil;
    result = [_reader decode:_resources.imageWithFileNamed(@"07.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(_resources.stringWithFileNamed(@"07.txt", NSUTF8StringEncoding), result.text); passed++; }
    all++;
    error = nil;
    result = [_reader decode:_resources.imageWithFileNamed(@"08.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(_resources.stringWithFileNamed(@"08.txt", NSUTF8StringEncoding), result.text); passed++; }
    all++;
    error = nil;
    result = [_reader decode:_resources.imageWithFileNamed(@"09.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(_resources.stringWithFileNamed(@"09.txt", NSUTF8StringEncoding), result.text); passed++; }
    all++;
    error = nil;
    result = [_reader decode:_resources.imageWithFileNamed(@"10.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(_resources.stringWithFileNamed(@"10.txt", NSUTF8StringEncoding), result.text); passed++; }
    all++;
    error = nil;
    result = [_reader decode:_resources.imageWithFileNamed(@"11.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(_resources.stringWithFileNamed(@"11.txt", NSUTF8StringEncoding), result.text); passed++; }
    all++;
    error = nil;
    result = [_reader decode:_resources.imageWithFileNamed(@"12.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(_resources.stringWithFileNamed(@"12.txt", NSUTF8StringEncoding), result.text); passed++; }
    all++;
    error = nil;
    result = [_reader decode:_resources.imageWithFileNamed(@"13.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(_resources.stringWithFileNamed(@"13.txt", NSUTF8StringEncoding), result.text); passed++; }
    all++;
    error = nil;
    result = [_reader decode:_resources.imageWithFileNamed(@"14.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(_resources.stringWithFileNamed(@"14.txt", NSUTF8StringEncoding), result.text); passed++; }
    all++;
    error = nil;
    result = [_reader decode:_resources.imageWithFileNamed(@"15.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(_resources.stringWithFileNamed(@"15.txt", NSUTF8StringEncoding), result.text); passed++; }
    all++;
    error = nil;
    result = [_reader decode:_resources.imageWithFileNamed(@"16.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(_resources.stringWithFileNamed(@"16.txt", NSUTF8StringEncoding), result.text); passed++; }
    all++;
    error = nil;
    result = [_reader decode:_resources.imageWithFileNamed(@"17.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(_resources.stringWithFileNamed(@"17.txt", NSUTF8StringEncoding), result.text); passed++; }
    all++;
    error = nil;
    result = [_reader decode:_resources.imageWithFileNamed(@"18.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(_resources.stringWithFileNamed(@"18.txt", NSUTF8StringEncoding), result.text); passed++; }
    all++;
    error = nil;
    NSLog(@"%@:%@, all:%d, passed:%d", NSStringFromClass(self.class), NSStringFromSelector(_cmd), all, passed);
}

@end
