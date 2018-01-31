//
//  AGXAztecReaderTest.m
//  AGXGcode
//
//  Created by Char Aznable on 2016/8/9.
//  Copyright © 2016年 AI-CUC-EC. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <AGXCore/AGXCore.h>
#import "AGXAztecReader.h"
#import "AGXGcodeError.h"

@interface AGXAztecReaderTest : XCTestCase
@property (nonatomic, AGX_STRONG) AGXBundle *bundle;
@property (nonatomic, AGX_STRONG) AGXAztecReader *reader;
@end

@implementation AGXAztecReaderTest

- (void)setUp {
    [super setUp];
    _bundle = AGX_RETAIN(AGXBundle.bundleNameAs(@"Resources"));
    _reader = [[AGXAztecReader alloc] init];
}

- (void)tearDown {
    AGX_RELEASE(_bundle);
    AGX_RELEASE(_reader);
    [super tearDown];
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
    NSLog(@"%@:%@, all:%d, passed:%d", NSStringFromClass(self.class), NSStringFromSelector(_cmd), all, passed);
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
    NSLog(@"%@:%@, all:%d, passed:%d", NSStringFromClass(self.class), NSStringFromSelector(_cmd), all, passed);
}

@end
