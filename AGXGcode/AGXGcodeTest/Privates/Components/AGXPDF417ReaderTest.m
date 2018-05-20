//
//  AGXPDF417ReaderTest.m
//  AGXGcode
//
//  Created by Char Aznable on 2016/8/4.
//  Copyright © 2016年 AI-CUC-EC. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <AGXCore/AGXCore.h>
#import "AGXPDF417Reader.h"
#import "AGXGcodeError.h"

@interface AGXPDF417ReaderTest : XCTestCase
@property (nonatomic, AGX_STRONG) AGXResources *resources;
@property (nonatomic, AGX_STRONG) AGXPDF417Reader *reader;
@end

@implementation AGXPDF417ReaderTest

- (void)setUp {
    [super setUp];
    _resources = AGX_RETAIN(AGXResources.application.subpathAppendBundleNamed(@"Resources"));
    _reader = [[AGXPDF417Reader alloc] init];
}

- (void)tearDown {
    AGX_RELEASE(_resources);
    AGX_RELEASE(_reader);
    [super tearDown];
}

- (void)testpdf4171 {
    _resources.subpathAppend(@"blackbox/pdf417-1");
    AGXGcodeResult *result = nil;
    NSError *error = nil;
    int all = 0, passed = 0;

    result = [_reader decode:_resources.imageWithFileNamed(@"01.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(@"This is PDF417", result.text); passed++; }
    else XCTAssertEqual(AGXNotFoundError, error.code);
    all++;
    error = nil;
    result = [_reader decode:_resources.imageWithFileNamed(@"02.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(@"12345678", result.text); passed++; }
    else XCTAssertEqual(AGXNotFoundError, error.code);
    all++;
    error = nil;
    result = [_reader decode:_resources.imageWithFileNamed(@"03.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(@"ActiveBarcode", result.text); passed++; }
    else XCTAssertEqual(AGXNotFoundError, error.code);
    all++;
    error = nil;
    result = [_reader decode:_resources.imageWithFileNamed(@"04.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(@"-ActiveBarcode-ABCDEFGHIJKLMNOPQRSTUVWXYZ", result.text); passed++; }
    else XCTAssertEqual(AGXNotFoundError, error.code);
    all++;
    error = nil;
    result = [_reader decode:_resources.imageWithFileNamed(@"05.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(@"-ActiveBarcode-ABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890-ActiveBarcode-ABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890", result.text); passed++; }
    else XCTAssertEqual(AGXNotFoundError, error.code);
    all++;
    error = nil;
    result = [_reader decode:_resources.imageWithFileNamed(@"06.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(@"-ActiveBarcode-ABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890-ActiveBarcode-ABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890-ActiveBarcode-ABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890-ActiveBarcode-ABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890-ActiveBarcode-ABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890-ActiveBarcode-ABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890", result.text); passed++; }
    else XCTAssertEqual(AGXNotFoundError, error.code);
    all++;
    error = nil;
    result = [_reader decode:_resources.imageWithFileNamed(@"07.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(@"-ActiveBarcode-ABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890-ActiveBarcode-ABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890-ActiveBarcode-ABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890-ActiveBarcode-ABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890-ActiveBarcode-ABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890-ActiveBarcode-ABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890-ActiveBarcode-ABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890-ActiveBarcode-ABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890-ActiveBarcode-ABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890-ActiveBarcode-ABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890-ActiveBarcode-ABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890-ActiveBarcode-ABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890", result.text); passed++; }
    else XCTAssertEqual(AGXNotFoundError, error.code);
    all++;
    error = nil;
    result = [_reader decode:_resources.imageWithFileNamed(@"09.png") hints:nil error:&error];
    if (!error) {
        XCTAssertEqualObjects(_resources.stringWithFileNamed(@"09.bin", NSISOLatin1StringEncoding), result.text); passed++;
    } else XCTAssertEqual(AGXNotFoundError, error.code);
    all++;
    error = nil;
    result = [_reader decode:_resources.imageWithFileNamed(@"10.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(@"PDF-417", result.text); passed++; }
    else XCTAssertEqual(AGXNotFoundError, error.code);
    all++;
    error = nil;
    NSLog(@"%@:%@, all:%d, passed:%d", NSStringFromClass(self.class), NSStringFromSelector(_cmd), all, passed);
}

- (void)testpdf4172 {
    _resources.subpathAppend(@"blackbox/pdf417-2");
    AGXGcodeResult *result = nil;
    NSError *error = nil;
    int all = 0, passed = 0;

    result = [_reader decode:_resources.imageWithFileNamed(@"01.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(@"1234567890", result.text); passed++; }
    else XCTAssertEqual(AGXNotFoundError, error.code);
    all++;
    error = nil;
    result = [_reader decode:_resources.imageWithFileNamed(@"02.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(@"1234567890", result.text); passed++; }
    else XCTAssertEqual(AGXNotFoundError, error.code);
    all++;
    error = nil;
    result = [_reader decode:_resources.imageWithFileNamed(@"03.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(@"1234567890", result.text); passed++; }
    else XCTAssertEqual(AGXNotFoundError, error.code);
    all++;
    error = nil;
    result = [_reader decode:_resources.imageWithFileNamed(@"04.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(@"1234567890", result.text); passed++; }
    else XCTAssertEqual(AGXNotFoundError, error.code);
    all++;
    error = nil;
    result = [_reader decode:_resources.imageWithFileNamed(@"05.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(@"1234567890", result.text); passed++; }
    else XCTAssertEqual(AGXNotFoundError, error.code);
    all++;
    error = nil;
    result = [_reader decode:_resources.imageWithFileNamed(@"06.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(@"1234567890", result.text); passed++; }
    else XCTAssertEqual(AGXNotFoundError, error.code);
    all++;
    error = nil;
    result = [_reader decode:_resources.imageWithFileNamed(@"07.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(@"1234567890", result.text); passed++; }
    else XCTAssertEqual(AGXNotFoundError, error.code);
    all++;
    error = nil;
    result = [_reader decode:_resources.imageWithFileNamed(@"08.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(@"A PDF 417 barcode with ASCII text", result.text); passed++; }
    else XCTAssertEqual(AGXNotFoundError, error.code);
    all++;
    error = nil;
    result = [_reader decode:_resources.imageWithFileNamed(@"09.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(@"A PDF 417 barcode with ASCII text", result.text); passed++; }
    else XCTAssertEqual(AGXNotFoundError, error.code);
    all++;
    error = nil;
    result = [_reader decode:_resources.imageWithFileNamed(@"10.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(@"A PDF 417 barcode with ASCII text", result.text); passed++; }
    else XCTAssertEqual(AGXNotFoundError, error.code);
    all++;
    error = nil;
    result = [_reader decode:_resources.imageWithFileNamed(@"11.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(@"A PDF 417 barcode with ASCII text", result.text); passed++; }
    else XCTAssertEqual(AGXNotFoundError, error.code);
    all++;
    error = nil;
    result = [_reader decode:_resources.imageWithFileNamed(@"12.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(@"A PDF 417 barcode with ASCII text", result.text); passed++; }
    else XCTAssertEqual(AGXNotFoundError, error.code);
    all++;
    error = nil;
    result = [_reader decode:_resources.imageWithFileNamed(@"13.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(@"A PDF 417 barcode with ASCII text", result.text); passed++; }
    else XCTAssertEqual(AGXNotFoundError, error.code);
    all++;
    error = nil;
    result = [_reader decode:_resources.imageWithFileNamed(@"14.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(@"A PDF 417 barcode with ASCII text", result.text); passed++; }
    else XCTAssertEqual(AGXNotFoundError, error.code);
    all++;
    error = nil;
    result = [_reader decode:_resources.imageWithFileNamed(@"15.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(@"A PDF 417 barcode with ASCII text", result.text); passed++; }
    else XCTAssertEqual(AGXNotFoundError, error.code);
    all++;
    error = nil;
    result = [_reader decode:_resources.imageWithFileNamed(@"16.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(@"A larger PDF 417 barcode with a greater amount of text. This is a more difficult test for mobile devices to resolve.", result.text); passed++; }
    else XCTAssertEqual(AGXNotFoundError, error.code);
    all++;
    error = nil;
    result = [_reader decode:_resources.imageWithFileNamed(@"17.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(@"A larger PDF 417 barcode with a greater amount of text. This is a more difficult test for mobile devices to resolve.", result.text); passed++; }
    else XCTAssertEqual(AGXNotFoundError, error.code);
    all++;
    error = nil;
    result = [_reader decode:_resources.imageWithFileNamed(@"18.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(@"A larger PDF 417 barcode with a greater amount of text. This is a more difficult test for mobile devices to resolve.", result.text); passed++; }
    else XCTAssertEqual(AGXNotFoundError, error.code);
    all++;
    error = nil;
    result = [_reader decode:_resources.imageWithFileNamed(@"19.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(@"A larger PDF 417 barcode with a greater amount of text. This is a more difficult test for mobile devices to resolve.", result.text); passed++; }
    else XCTAssertEqual(AGXNotFoundError, error.code);
    all++;
    error = nil;
    result = [_reader decode:_resources.imageWithFileNamed(@"20.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(@"A larger PDF 417 barcode with a greater amount of text. This is a more difficult test for mobile devices to resolve.", result.text); passed++; }
    else XCTAssertEqual(AGXNotFoundError, error.code);
    all++;
    error = nil;
    result = [_reader decode:_resources.imageWithFileNamed(@"21.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(@"A larger PDF 417 barcode with a greater amount of text. This is a more difficult test for mobile devices to resolve.", result.text); passed++; }
    else XCTAssertEqual(AGXNotFoundError, error.code);
    all++;
    error = nil;
    result = [_reader decode:_resources.imageWithFileNamed(@"22.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(@"A larger PDF 417 barcode with a greater amount of text. This is a more difficult test for mobile devices to resolve.", result.text); passed++; }
    else XCTAssertEqual(AGXNotFoundError, error.code);
    all++;
    error = nil;
    result = [_reader decode:_resources.imageWithFileNamed(@"23.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(@"A larger PDF 417 barcode with a greater amount of text. This is a more difficult test for mobile devices to resolve.", result.text); passed++; }
    else XCTAssertEqual(AGXNotFoundError, error.code);
    all++;
    error = nil;
    result = [_reader decode:_resources.imageWithFileNamed(@"24.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(_resources.stringWithFileNamed(@"24.bin", NSISOLatin1StringEncoding), result.text); passed++; }
    else XCTAssertEqual(AGXNotFoundError, error.code);
    all++;
    error = nil;
    result = [_reader decode:_resources.imageWithFileNamed(@"25.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(@"This is PDF417", result.text); passed++; }
    else XCTAssertEqual(AGXNotFoundError, error.code);
    all++;
    error = nil;
    NSLog(@"%@:%@, all:%d, passed:%d", NSStringFromClass(self.class), NSStringFromSelector(_cmd), all, passed);
}

- (void)testpdf4173 {
    _resources.subpathAppend(@"blackbox/pdf417-3");
    AGXGcodeResult *result = nil;
    NSError *error = nil;
    int all = 0, passed = 0;

    result = [_reader decode:_resources.imageWithFileNamed(@"01.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(@"A larger PDF417 barcode with text and error correction level 8.", result.text); passed++; }
    else XCTAssertEqual(AGXNotFoundError, error.code);
    all++;
    error = nil;
    result = [_reader decode:_resources.imageWithFileNamed(@"02.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(@"A larger PDF417 barcode with text and error correction level 8.", result.text); passed++; }
    else XCTAssertEqual(AGXNotFoundError, error.code);
    all++;
    error = nil;
    result = [_reader decode:_resources.imageWithFileNamed(@"03.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(@"A larger PDF417 barcode with text and error correction level 8.", result.text); passed++; }
    else XCTAssertEqual(AGXNotFoundError, error.code);
    all++;
    error = nil;
    result = [_reader decode:_resources.imageWithFileNamed(@"04.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(@"A larger PDF417 barcode with text and error correction level 8.", result.text); passed++; }
    else XCTAssertEqual(AGXNotFoundError, error.code);
    all++;
    error = nil;
    result = [_reader decode:_resources.imageWithFileNamed(@"05.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(@"A larger PDF417 barcode with text and error correction level 8.", result.text); passed++; }
    else XCTAssertEqual(AGXNotFoundError, error.code);
    all++;
    error = nil;
    result = [_reader decode:_resources.imageWithFileNamed(@"06.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(@"A larger PDF417 barcode with text and error correction level 8.", result.text); passed++; }
    else XCTAssertEqual(AGXNotFoundError, error.code);
    all++;
    error = nil;
    result = [_reader decode:_resources.imageWithFileNamed(@"07.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(@"A larger PDF417 barcode with text and error correction level 4.", result.text); passed++; }
    else XCTAssertEqual(AGXNotFoundError, error.code);
    all++;
    error = nil;
    result = [_reader decode:_resources.imageWithFileNamed(@"08.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(@"A larger PDF417 barcode with text and error correction level 4.", result.text); passed++; }
    else XCTAssertEqual(AGXNotFoundError, error.code);
    all++;
    error = nil;
    result = [_reader decode:_resources.imageWithFileNamed(@"09.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(@"A larger PDF417 barcode with text and error correction level 4.", result.text); passed++; }
    else XCTAssertEqual(AGXNotFoundError, error.code);
    all++;
    error = nil;
    result = [_reader decode:_resources.imageWithFileNamed(@"10.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(@"A larger PDF417 barcode with text and error correction level 4.", result.text); passed++; }
    else XCTAssertEqual(AGXNotFoundError, error.code);
    all++;
    error = nil;
    result = [_reader decode:_resources.imageWithFileNamed(@"11.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(@"A larger PDF417 barcode with text and error correction level 4.", result.text); passed++; }
    else XCTAssertEqual(AGXNotFoundError, error.code);
    all++;
    error = nil;
    result = [_reader decode:_resources.imageWithFileNamed(@"12.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(@"[)>010210011840539080122327430201FDE238351251289 1/13.0LBY76 NINTH AVENUENEW YORK CITYNYSUSAN ZOLEZZI0610ZED00411ZGOOGLE12Z212565418630Z3100119200000114Z4TH FLOOR15Z39795720Z0.000.0028Z9080122327430201K533 PROGRAMS26Z584a", result.text); passed++; }
    else XCTAssertEqual(AGXNotFoundError, error.code);
    all++;
    error = nil;
    result = [_reader decode:_resources.imageWithFileNamed(@"13.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(@"A larger PDF417 barcode with text and error correction level 8.", result.text); passed++; }
    else XCTAssertEqual(AGXNotFoundError, error.code);
    all++;
    error = nil;
    result = [_reader decode:_resources.imageWithFileNamed(@"14.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(@"A larger PDF417 barcode with text and error correction level 8.", result.text); passed++; }
    else XCTAssertEqual(AGXNotFoundError, error.code);
    all++;
    error = nil;
    result = [_reader decode:_resources.imageWithFileNamed(@"15.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(@"A larger PDF417 barcode with text and error correction level 8.", result.text); passed++; }
    else XCTAssertEqual(AGXNotFoundError, error.code);
    all++;
    error = nil;
    result = [_reader decode:_resources.imageWithFileNamed(@"16.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(@"A larger PDF417 barcode with text and error correction level 8.", result.text); passed++; }
    else XCTAssertEqual(AGXNotFoundError, error.code);
    all++;
    error = nil;
    result = [_reader decode:_resources.imageWithFileNamed(@"17.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(@"A larger PDF417 barcode with text and error correction level 8.", result.text); passed++; }
    else XCTAssertEqual(AGXNotFoundError, error.code);
    all++;
    error = nil;
    result = [_reader decode:_resources.imageWithFileNamed(@"18.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(@"A larger PDF417 barcode with text and error correction level 8.", result.text); passed++; }
    else XCTAssertEqual(AGXNotFoundError, error.code);
    all++;
    error = nil;
    NSLog(@"%@:%@, all:%d, passed:%d", NSStringFromClass(self.class), NSStringFromSelector(_cmd), all, passed);
}

- (void)testpdf4174 {
    _resources.subpathAppend(@"blackbox/pdf417-4");
    AGXGcodeResult *result = nil;
    NSError *error = nil;
    int all = 0, passed = 0;

    result = [_reader decode:_resources.imageWithFileNamed(@"01-01.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(_resources.stringWithFileNamed(@"01.bin", NSISOLatin1StringEncoding), result.text); passed++; }
    else XCTAssertEqual(AGXNotFoundError, error.code);
    all++;
    error = nil;
    NSLog(@"%@:%@, all:%d, passed:%d", NSStringFromClass(self.class), NSStringFromSelector(_cmd), all, passed);
}

@end
