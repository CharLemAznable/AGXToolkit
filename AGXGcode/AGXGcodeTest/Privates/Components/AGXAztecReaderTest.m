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
@property (nonatomic, AGX_STRONG) AGXResources *resources;
@property (nonatomic, AGX_STRONG) AGXAztecReader *reader;
@end

@implementation AGXAztecReaderTest

- (void)setUp {
    [super setUp];
    _resources = AGX_RETAIN(AGXResources.application.subpathAppendBundleNamed(@"Resources"));
    _reader = [[AGXAztecReader alloc] init];
}

- (void)tearDown {
    AGX_RELEASE(_resources);
    AGX_RELEASE(_reader);
    [super tearDown];
}

- (void)testaztec1 {
    _resources.subpathAppend(@"blackbox/aztec-1");
    AGXGcodeResult *result = nil;
    NSError *error = nil;
    int all = 0, passed = 0;

    result = [_reader decode:_resources.imageWithFileNamed(@"7.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(_resources.stringWithFileNamed(@"7.txt", NSUTF8StringEncoding), result.text); passed++; }
    all++;
    error = nil;
    result = [_reader decode:_resources.imageWithFileNamed(@"abc-19x19C.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(_resources.stringWithFileNamed(@"abc-19x19C.txt", NSUTF8StringEncoding), result.text); passed++; }
    all++;
    error = nil;
    result = [_reader decode:_resources.imageWithFileNamed(@"abc-37x37.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(_resources.stringWithFileNamed(@"abc-37x37.txt", NSUTF8StringEncoding), result.text); passed++; }
    all++;
    error = nil;
    result = [_reader decode:_resources.imageWithFileNamed(@"hello.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(_resources.stringWithFileNamed(@"hello.txt", NSUTF8StringEncoding), result.text); passed++; }
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
    result = [_reader decode:_resources.imageWithFileNamed(@"Historico.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(_resources.stringWithFileNamed(@"Historico.txt", NSUTF8StringEncoding), result.text); passed++; }
    all++;
    error = nil;
    result = [_reader decode:_resources.imageWithFileNamed(@"HistoricoLong.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(_resources.stringWithFileNamed(@"HistoricoLong.txt", NSUTF8StringEncoding), result.text); passed++; }
    all++;
    error = nil;
    result = [_reader decode:_resources.imageWithFileNamed(@"lorem-075x075.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(_resources.stringWithFileNamed(@"lorem-075x075.txt", NSUTF8StringEncoding), result.text); passed++; }
    all++;
    error = nil;
    result = [_reader decode:_resources.imageWithFileNamed(@"lorem-105x105.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(_resources.stringWithFileNamed(@"lorem-105x105.txt", NSUTF8StringEncoding), result.text); passed++; }
    all++;
    error = nil;
    result = [_reader decode:_resources.imageWithFileNamed(@"lorem-151x151.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(_resources.stringWithFileNamed(@"lorem-151x151.txt", NSUTF8StringEncoding), result.text); passed++; }
    all++;
    error = nil;
    result = [_reader decode:_resources.imageWithFileNamed(@"tableShifts.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(_resources.stringWithFileNamed(@"tableShifts.txt", NSUTF8StringEncoding), result.text); passed++; }
    all++;
    error = nil;
    result = [_reader decode:_resources.imageWithFileNamed(@"tag.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(_resources.stringWithFileNamed(@"tag.txt", NSUTF8StringEncoding), result.text); passed++; }
    all++;
    error = nil;
    result = [_reader decode:_resources.imageWithFileNamed(@"texte.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(_resources.stringWithFileNamed(@"texte.txt", NSUTF8StringEncoding), result.text); passed++; }
    all++;
    error = nil;
    NSLog(@"%@:%@, all:%d, passed:%d", NSStringFromClass(self.class), NSStringFromSelector(_cmd), all, passed);
}

- (void)testaztec2 {
    _resources.subpathAppend(@"blackbox/aztec-2");
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
    result = [_reader decode:_resources.imageWithFileNamed(@"19.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(_resources.stringWithFileNamed(@"19.txt", NSUTF8StringEncoding), result.text); passed++; }
    all++;
    error = nil;
    result = [_reader decode:_resources.imageWithFileNamed(@"20.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(_resources.stringWithFileNamed(@"20.txt", NSUTF8StringEncoding), result.text); passed++; }
    all++;
    error = nil;
    result = [_reader decode:_resources.imageWithFileNamed(@"21.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(_resources.stringWithFileNamed(@"21.txt", NSUTF8StringEncoding), result.text); passed++; }
    all++;
    error = nil;
    result = [_reader decode:_resources.imageWithFileNamed(@"22.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(_resources.stringWithFileNamed(@"22.txt", NSUTF8StringEncoding), result.text); passed++; }
    all++;
    error = nil;
    NSLog(@"%@:%@, all:%d, passed:%d", NSStringFromClass(self.class), NSStringFromSelector(_cmd), all, passed);
}

@end
