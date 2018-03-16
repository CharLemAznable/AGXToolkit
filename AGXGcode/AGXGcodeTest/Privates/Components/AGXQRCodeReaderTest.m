//
//  AGXQRCodeReaderTest.m
//  AGXGcode
//
//  Created by Char Aznable on 2016/8/8.
//  Copyright © 2016年 AI-CUC-EC. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <AGXCore/AGXCore.h>
#import "AGXQRCodeReader.h"
#import "AGXGcodeError.h"

@interface AGXQRCodeReaderTest : XCTestCase
@property (nonatomic, AGX_STRONG) AGXResources *resources;
@property (nonatomic, AGX_STRONG) AGXQRCodeReader *reader;
@end

@implementation AGXQRCodeReaderTest

- (void)setUp {
    [super setUp];
    _resources = AGX_RETAIN(AGXResources.application.subpathAppendBundleNamed(@"Resources"));
    _reader = [[AGXQRCodeReader alloc] init];
}

- (void)tearDown {
    AGX_RELEASE(_resources);
    AGX_RELEASE(_reader);
    [super tearDown];
}

- (void)testqrcode1 {
    _resources.subpathAppend(@"blackbox/qrcode-1");
    AGXGcodeResult *result = nil;
    NSError *error = nil;
    int all = 0, passed = 0;

    result = [_reader decode:_resources.imageWithFileNamed(@"1.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(_resources.stringWithFileNamed(@"1.txt", NSUTF8StringEncoding), result.text); passed++; }
    all++;
    error = nil;
    result = [_reader decode:_resources.imageWithFileNamed(@"2.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(_resources.stringWithFileNamed(@"2.txt", NSUTF8StringEncoding), result.text); passed++; }
    all++;
    error = nil;
    result = [_reader decode:_resources.imageWithFileNamed(@"3.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(_resources.stringWithFileNamed(@"3.txt", NSUTF8StringEncoding), result.text); passed++; }
    all++;
    error = nil;
    result = [_reader decode:_resources.imageWithFileNamed(@"4.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(_resources.stringWithFileNamed(@"4.txt", NSUTF8StringEncoding), result.text); passed++; }
    all++;
    error = nil;
    result = [_reader decode:_resources.imageWithFileNamed(@"5.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(_resources.stringWithFileNamed(@"5.txt", NSUTF8StringEncoding), result.text); passed++; }
    all++;
    error = nil;
    result = [_reader decode:_resources.imageWithFileNamed(@"6.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(_resources.stringWithFileNamed(@"6.txt", NSUTF8StringEncoding), result.text); passed++; }
    all++;
    error = nil;
    result = [_reader decode:_resources.imageWithFileNamed(@"7.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(_resources.stringWithFileNamed(@"7.txt", NSUTF8StringEncoding), result.text); passed++; }
    all++;
    error = nil;
    result = [_reader decode:_resources.imageWithFileNamed(@"8.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(_resources.stringWithFileNamed(@"8.txt", NSUTF8StringEncoding), result.text); passed++; }
    all++;
    error = nil;
    result = [_reader decode:_resources.imageWithFileNamed(@"9.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(_resources.stringWithFileNamed(@"9.txt", NSUTF8StringEncoding), result.text); passed++; }
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
    if (!error) { XCTAssertEqualObjects(@"Sean Owen\r\nsrowen@google.com\r\n917-364-2918\r\nhttp://awesome-thoughts.com", result.text); passed++; }
    all++;
    error = nil;
    result = [_reader decode:_resources.imageWithFileNamed(@"17.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(@"Sean Owen\r\nsrowen@google.com\r\n917-364-2918\r\nhttp://awesome-thoughts.com", result.text); passed++; }
    all++;
    error = nil;
    result = [_reader decode:_resources.imageWithFileNamed(@"18.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(@"Sean Owen\r\nsrowen@google.com\r\n917-364-2918\r\nhttp://awesome-thoughts.com", result.text); passed++; }
    all++;
    error = nil;
    result = [_reader decode:_resources.imageWithFileNamed(@"19.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(@"Sean Owen\r\nsrowen@google.com\r\n917-364-2918\r\nhttp://awesome-thoughts.com", result.text); passed++; }
    all++;
    error = nil;
    result = [_reader decode:_resources.imageWithFileNamed(@"20.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(@"Sean Owen\r\nsrowen@google.com\r\n917-364-2918\r\nhttp://awesome-thoughts.com", result.text); passed++; }
    all++;
    error = nil;
    NSLog(@"%@:%@, all:%d, passed:%d", NSStringFromClass(self.class), NSStringFromSelector(_cmd), all, passed);
}

- (void)testqrcode2 {
    _resources.subpathAppend(@"blackbox/qrcode-2");
    AGXGcodeResult *result = nil;
    NSError *error = nil;
    int all = 0, passed = 0;

    result = [_reader decode:_resources.imageWithFileNamed(@"1.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(_resources.stringWithFileNamed(@"1.txt", NSUTF8StringEncoding), result.text); passed++; }
    all++;
    error = nil;
    result = [_reader decode:_resources.imageWithFileNamed(@"2.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(_resources.stringWithFileNamed(@"2.txt", NSUTF8StringEncoding), result.text); passed++; }
    all++;
    error = nil;
    result = [_reader decode:_resources.imageWithFileNamed(@"4.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(_resources.stringWithFileNamed(@"4.txt", NSUTF8StringEncoding), result.text); passed++; }
    all++;
    error = nil;
    result = [_reader decode:_resources.imageWithFileNamed(@"5.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(_resources.stringWithFileNamed(@"5.txt", NSUTF8StringEncoding), result.text); passed++; }
    all++;
    error = nil;
    result = [_reader decode:_resources.imageWithFileNamed(@"6.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(_resources.stringWithFileNamed(@"6.txt", NSUTF8StringEncoding), result.text); passed++; }
    all++;
    error = nil;
    result = [_reader decode:_resources.imageWithFileNamed(@"7.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(_resources.stringWithFileNamed(@"7.txt", NSUTF8StringEncoding), result.text); passed++; }
    all++;
    error = nil;
    result = [_reader decode:_resources.imageWithFileNamed(@"8.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(_resources.stringWithFileNamed(@"8.txt", NSUTF8StringEncoding), result.text); passed++; }
    all++;
    error = nil;
    result = [_reader decode:_resources.imageWithFileNamed(@"9.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(_resources.stringWithFileNamed(@"9.txt", NSUTF8StringEncoding), result.text); passed++; }
    all++;
    error = nil;
    result = [_reader decode:_resources.imageWithFileNamed(@"10.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(@"Google モバイル\r\nhttp://google.jp", result.text); passed++; }
    all++;
    error = nil;
    result = [_reader decode:_resources.imageWithFileNamed(@"11.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(@"BEGIN:VCARD\r\nN:Kennedy;Steve\r\nTEL:+44 (0)7775 755503\r\nADR;HOME:;;Flat 2, 43 Howitt Road, Belsize Park;London;;NW34LU;UK\r\nORG:NetTek Ltd;\r\nTITLE:Consultant\r\nEMAIL:steve@nettek.co.uk\r\nURL:www.nettek.co.uk\r\nEMAIL;IM:MSN:steve@gbnet.net\r\nNOTE:Testing 1 2 3\r\nBDAY:19611105\r\nEND:VCARD", result.text); passed++; }
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
    if (!error) { XCTAssertEqualObjects(@"[外側QRコード]\r\n \r\n*ﾀﾞﾌﾞﾙQR*\r\nhttp://d-qr.net/ex/", result.text); passed++; }
    all++;
    error = nil;
    result = [_reader decode:_resources.imageWithFileNamed(@"17.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(@"ﾃﾞｻﾞｲﾝQR\r\nhttp://d-qr.net/ex/", result.text); passed++; }
    all++;
    error = nil;
    result = [_reader decode:_resources.imageWithFileNamed(@"18.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(@"*ﾃﾞｻﾞｲﾝQR*     \r\nhttp://d-qr.net/ex/       ", result.text); passed++; }
    all++;
    error = nil;
    result = [_reader decode:_resources.imageWithFileNamed(@"19.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(@"*ﾃﾞｻﾞｲﾝQR*    \r\nhttp://d-qr.net/ex/         ", result.text); passed++; }
    all++;
    error = nil;
    result = [_reader decode:_resources.imageWithFileNamed(@"20.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(@"*ﾃﾞｻﾞｲﾝQR*\r\nhttp://d-qr.net/ex/    ", result.text); passed++; }
    all++;
    error = nil;
    result = [_reader decode:_resources.imageWithFileNamed(@"21.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(@"*ﾃﾞｻﾞｲﾝQR*  \r\nhttp://d-qr.net/ex/        ", result.text); passed++; }
    all++;
    error = nil;
    result = [_reader decode:_resources.imageWithFileNamed(@"22.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(_resources.stringWithFileNamed(@"22.txt", NSUTF8StringEncoding), result.text); passed++; }
    all++;
    error = nil;
    result = [_reader decode:_resources.imageWithFileNamed(@"23.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(_resources.stringWithFileNamed(@"23.txt", NSUTF8StringEncoding), result.text); passed++; }
    all++;
    error = nil;
    result = [_reader decode:_resources.imageWithFileNamed(@"24.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(@"*ﾃﾞｻﾞｲﾝQR* \r\nhttp://d-qr.net/ex/      ", result.text); passed++; }
    all++;
    error = nil;
    result = [_reader decode:_resources.imageWithFileNamed(@"25.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(_resources.stringWithFileNamed(@"25.txt", NSUTF8StringEncoding), result.text); passed++; }
    all++;
    error = nil;
    result = [_reader decode:_resources.imageWithFileNamed(@"26.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(@"<ﾃﾞｻﾞｲﾝQR> \r\nｲﾗｽﾄ入りｶﾗｰQRｺｰﾄﾞ\r\nhttp://d-qr.net/ex/ ", result.text); passed++; }
    all++;
    error = nil;
    result = [_reader decode:_resources.imageWithFileNamed(@"27.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(@"*ﾃﾞｻﾞｲﾝQR*   \r\nhttp://d-qr.net/ex/ ", result.text); passed++; }
    all++;
    error = nil;
    result = [_reader decode:_resources.imageWithFileNamed(@"28.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(_resources.stringWithFileNamed(@"28.txt", NSUTF8StringEncoding), result.text); passed++; }
    all++;
    error = nil;
    result = [_reader decode:_resources.imageWithFileNamed(@"29.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(@"http://live.fdgm.jp/u/event/hype/hype_top.html \r\n\r\nMEBKM:TITLE:hypeモバイル;URL:http\\://live.fdgm.jp/u/event/hype/hype_top.html;;", result.text); passed++; }
    all++;
    error = nil;
    result = [_reader decode:_resources.imageWithFileNamed(@"30.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(_resources.stringWithFileNamed(@"30.txt", NSUTF8StringEncoding), result.text); passed++; }
    all++;
    error = nil;
    result = [_reader decode:_resources.imageWithFileNamed(@"31.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(_resources.stringWithFileNamed(@"31.txt", NSUTF8StringEncoding), result.text); passed++; }
    all++;
    error = nil;
    result = [_reader decode:_resources.imageWithFileNamed(@"32.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(@"BEGIN:VCARD\r\nN:Kennedy;Steve\r\nTEL:+44 (0)7775 755503\r\nADR;HOME:;;Flat 2, 43 Howitt Road, Belsize Park;London;;NW34LU;UK\r\nORG:NetTek Ltd;\r\nTITLE:Consultant\r\nEMAIL:steve@nettek.co.uk\r\nURL:www.nettek.co.uk\r\nEMAIL;IM:MSN:steve@gbnet.net\r\nNOTE:Testing 1 2 3\r\nBDAY:19611105\r\nEND:VCARD", result.text); passed++; }
    all++;
    error = nil;
    result = [_reader decode:_resources.imageWithFileNamed(@"33.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(_resources.stringWithFileNamed(@"33.txt", NSUTF8StringEncoding), result.text); passed++; }
    all++;
    error = nil;
    result = [_reader decode:_resources.imageWithFileNamed(@"34.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(_resources.stringWithFileNamed(@"34.txt", NSUTF8StringEncoding), result.text); passed++; }
    all++;
    error = nil;
    result = [_reader decode:_resources.imageWithFileNamed(@"35.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(_resources.stringWithFileNamed(@"35.txt", NSUTF8StringEncoding), result.text); passed++; }
    all++;
    error = nil;
    NSLog(@"%@:%@, all:%d, passed:%d", NSStringFromClass(self.class), NSStringFromSelector(_cmd), all, passed);
}

- (void)testqrcode3 {
    _resources.subpathAppend(@"blackbox/qrcode-3");
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
    if (!error) { XCTAssertEqualObjects(@"UI office hours signup\r\nhttp://www.corp.google.com/sparrow/ui_office_hours/ \r\n", result.text); passed++; }
    all++;
    error = nil;
    result = [_reader decode:_resources.imageWithFileNamed(@"19.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(@"UI office hours signup\r\nhttp://www.corp.google.com/sparrow/ui_office_hours/ \r\n", result.text); passed++; }
    all++;
    error = nil;
    result = [_reader decode:_resources.imageWithFileNamed(@"20.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(@"UI office hours signup\r\nhttp://www.corp.google.com/sparrow/ui_office_hours/ \r\n", result.text); passed++; }
    all++;
    error = nil;
    result = [_reader decode:_resources.imageWithFileNamed(@"21.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(@"UI office hours signup\r\nhttp://www.corp.google.com/sparrow/ui_office_hours/ \r\n", result.text); passed++; }
    all++;
    error = nil;
    result = [_reader decode:_resources.imageWithFileNamed(@"22.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(@"UI office hours signup\r\nhttp://www.corp.google.com/sparrow/ui_office_hours/ \r\n", result.text); passed++; }
    all++;
    error = nil;
    result = [_reader decode:_resources.imageWithFileNamed(@"23.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(@"UI office hours signup\r\nhttp://www.corp.google.com/sparrow/ui_office_hours/ \r\n", result.text); passed++; }
    all++;
    error = nil;
    result = [_reader decode:_resources.imageWithFileNamed(@"24.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(@"UI office hours signup\r\nhttp://www.corp.google.com/sparrow/ui_office_hours/ \r\n", result.text); passed++; }
    all++;
    error = nil;
    result = [_reader decode:_resources.imageWithFileNamed(@"25.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(@"UI office hours signup\r\nhttp://www.corp.google.com/sparrow/ui_office_hours/ \r\n", result.text); passed++; }
    all++;
    error = nil;
    result = [_reader decode:_resources.imageWithFileNamed(@"26.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(_resources.stringWithFileNamed(@"26.txt", NSUTF8StringEncoding), result.text); passed++; }
    all++;
    error = nil;
    result = [_reader decode:_resources.imageWithFileNamed(@"27.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(_resources.stringWithFileNamed(@"27.txt", NSUTF8StringEncoding), result.text); passed++; }
    all++;
    error = nil;
    result = [_reader decode:_resources.imageWithFileNamed(@"28.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(_resources.stringWithFileNamed(@"28.txt", NSUTF8StringEncoding), result.text); passed++; }
    all++;
    error = nil;
    result = [_reader decode:_resources.imageWithFileNamed(@"29.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(_resources.stringWithFileNamed(@"29.txt", NSUTF8StringEncoding), result.text); passed++; }
    all++;
    error = nil;
    result = [_reader decode:_resources.imageWithFileNamed(@"30.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(_resources.stringWithFileNamed(@"30.txt", NSUTF8StringEncoding), result.text); passed++; }
    all++;
    error = nil;
    result = [_reader decode:_resources.imageWithFileNamed(@"31.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(_resources.stringWithFileNamed(@"31.txt", NSUTF8StringEncoding), result.text); passed++; }
    all++;
    error = nil;
    result = [_reader decode:_resources.imageWithFileNamed(@"32.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(_resources.stringWithFileNamed(@"32.txt", NSUTF8StringEncoding), result.text); passed++; }
    all++;
    error = nil;
    result = [_reader decode:_resources.imageWithFileNamed(@"33.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(_resources.stringWithFileNamed(@"33.txt", NSUTF8StringEncoding), result.text); passed++; }
    all++;
    error = nil;
    result = [_reader decode:_resources.imageWithFileNamed(@"34.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(_resources.stringWithFileNamed(@"34.txt", NSUTF8StringEncoding), result.text); passed++; }
    all++;
    error = nil;
    result = [_reader decode:_resources.imageWithFileNamed(@"35.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(_resources.stringWithFileNamed(@"35.txt", NSUTF8StringEncoding), result.text); passed++; }
    all++;
    error = nil;
    result = [_reader decode:_resources.imageWithFileNamed(@"36.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(_resources.stringWithFileNamed(@"36.txt", NSUTF8StringEncoding), result.text); passed++; }
    all++;
    error = nil;
    result = [_reader decode:_resources.imageWithFileNamed(@"37.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(_resources.stringWithFileNamed(@"37.txt", NSUTF8StringEncoding), result.text); passed++; }
    all++;
    error = nil;
    result = [_reader decode:_resources.imageWithFileNamed(@"38.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(_resources.stringWithFileNamed(@"38.txt", NSUTF8StringEncoding), result.text); passed++; }
    all++;
    error = nil;
    result = [_reader decode:_resources.imageWithFileNamed(@"39.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(_resources.stringWithFileNamed(@"39.txt", NSUTF8StringEncoding), result.text); passed++; }
    all++;
    error = nil;
    result = [_reader decode:_resources.imageWithFileNamed(@"40.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(_resources.stringWithFileNamed(@"40.txt", NSUTF8StringEncoding), result.text); passed++; }
    all++;
    error = nil;
    result = [_reader decode:_resources.imageWithFileNamed(@"41.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(_resources.stringWithFileNamed(@"41.txt", NSUTF8StringEncoding), result.text); passed++; }
    all++;
    error = nil;
    result = [_reader decode:_resources.imageWithFileNamed(@"42.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(_resources.stringWithFileNamed(@"42.txt", NSUTF8StringEncoding), result.text); passed++; }
    all++;
    error = nil;
    NSLog(@"%@:%@, all:%d, passed:%d", NSStringFromClass(self.class), NSStringFromSelector(_cmd), all, passed);
}

- (void)testqrcode4 {
    _resources.subpathAppend(@"blackbox/qrcode-4");
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
    result = [_reader decode:_resources.imageWithFileNamed(@"23.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(_resources.stringWithFileNamed(@"23.txt", NSUTF8StringEncoding), result.text); passed++; }
    all++;
    error = nil;
    result = [_reader decode:_resources.imageWithFileNamed(@"24.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(_resources.stringWithFileNamed(@"24.txt", NSUTF8StringEncoding), result.text); passed++; }
    all++;
    error = nil;
    result = [_reader decode:_resources.imageWithFileNamed(@"25.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(_resources.stringWithFileNamed(@"25.txt", NSUTF8StringEncoding), result.text); passed++; }
    all++;
    error = nil;
    result = [_reader decode:_resources.imageWithFileNamed(@"26.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(_resources.stringWithFileNamed(@"26.txt", NSUTF8StringEncoding), result.text); passed++; }
    all++;
    error = nil;
    result = [_reader decode:_resources.imageWithFileNamed(@"27.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(_resources.stringWithFileNamed(@"27.txt", NSUTF8StringEncoding), result.text); passed++; }
    all++;
    error = nil;
    result = [_reader decode:_resources.imageWithFileNamed(@"28.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(_resources.stringWithFileNamed(@"28.txt", NSUTF8StringEncoding), result.text); passed++; }
    all++;
    error = nil;
    result = [_reader decode:_resources.imageWithFileNamed(@"29.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(_resources.stringWithFileNamed(@"29.txt", NSUTF8StringEncoding), result.text); passed++; }
    all++;
    error = nil;
    result = [_reader decode:_resources.imageWithFileNamed(@"30.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(_resources.stringWithFileNamed(@"30.txt", NSUTF8StringEncoding), result.text); passed++; }
    all++;
    error = nil;
    result = [_reader decode:_resources.imageWithFileNamed(@"31.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(_resources.stringWithFileNamed(@"31.txt", NSUTF8StringEncoding), result.text); passed++; }
    all++;
    error = nil;
    result = [_reader decode:_resources.imageWithFileNamed(@"32.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(_resources.stringWithFileNamed(@"32.txt", NSUTF8StringEncoding), result.text); passed++; }
    all++;
    error = nil;
    result = [_reader decode:_resources.imageWithFileNamed(@"33.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(_resources.stringWithFileNamed(@"33.txt", NSUTF8StringEncoding), result.text); passed++; }
    all++;
    error = nil;
    result = [_reader decode:_resources.imageWithFileNamed(@"34.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(_resources.stringWithFileNamed(@"34.txt", NSUTF8StringEncoding), result.text); passed++; }
    all++;
    error = nil;
    result = [_reader decode:_resources.imageWithFileNamed(@"35.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(_resources.stringWithFileNamed(@"35.txt", NSUTF8StringEncoding), result.text); passed++; }
    all++;
    error = nil;
    result = [_reader decode:_resources.imageWithFileNamed(@"36.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(_resources.stringWithFileNamed(@"36.txt", NSUTF8StringEncoding), result.text); passed++; }
    all++;
    error = nil;
    result = [_reader decode:_resources.imageWithFileNamed(@"37.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(_resources.stringWithFileNamed(@"37.txt", NSUTF8StringEncoding), result.text); passed++; }
    all++;
    error = nil;
    result = [_reader decode:_resources.imageWithFileNamed(@"38.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(_resources.stringWithFileNamed(@"38.txt", NSUTF8StringEncoding), result.text); passed++; }
    all++;
    error = nil;
    result = [_reader decode:_resources.imageWithFileNamed(@"39.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(_resources.stringWithFileNamed(@"39.txt", NSUTF8StringEncoding), result.text); passed++; }
    all++;
    error = nil;
    result = [_reader decode:_resources.imageWithFileNamed(@"40.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(_resources.stringWithFileNamed(@"40.txt", NSUTF8StringEncoding), result.text); passed++; }
    all++;
    error = nil;
    result = [_reader decode:_resources.imageWithFileNamed(@"41.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(_resources.stringWithFileNamed(@"41.txt", NSUTF8StringEncoding), result.text); passed++; }
    all++;
    error = nil;
    result = [_reader decode:_resources.imageWithFileNamed(@"42.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(_resources.stringWithFileNamed(@"42.txt", NSUTF8StringEncoding), result.text); passed++; }
    all++;
    error = nil;
    result = [_reader decode:_resources.imageWithFileNamed(@"43.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(_resources.stringWithFileNamed(@"43.txt", NSUTF8StringEncoding), result.text); passed++; }
    all++;
    error = nil;
    result = [_reader decode:_resources.imageWithFileNamed(@"44.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(_resources.stringWithFileNamed(@"44.txt", NSUTF8StringEncoding), result.text); passed++; }
    all++;
    error = nil;
    result = [_reader decode:_resources.imageWithFileNamed(@"45.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(_resources.stringWithFileNamed(@"45.txt", NSUTF8StringEncoding), result.text); passed++; }
    all++;
    error = nil;
    result = [_reader decode:_resources.imageWithFileNamed(@"46.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(_resources.stringWithFileNamed(@"46.txt", NSUTF8StringEncoding), result.text); passed++; }
    all++;
    error = nil;
    result = [_reader decode:_resources.imageWithFileNamed(@"47.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(_resources.stringWithFileNamed(@"47.txt", NSUTF8StringEncoding), result.text); passed++; }
    all++;
    error = nil;
    result = [_reader decode:_resources.imageWithFileNamed(@"48.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(_resources.stringWithFileNamed(@"48.txt", NSUTF8StringEncoding), result.text); passed++; }
    all++;
    error = nil;
    NSLog(@"%@:%@, all:%d, passed:%d", NSStringFromClass(self.class), NSStringFromSelector(_cmd), all, passed);
}

- (void)testqrcode5 {
    _resources.subpathAppend(@"blackbox/qrcode-5");
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
    NSLog(@"%@:%@, all:%d, passed:%d", NSStringFromClass(self.class), NSStringFromSelector(_cmd), all, passed);
}

- (void)testqrcode6 {
    _resources.subpathAppend(@"blackbox/qrcode-6");
    AGXGcodeResult *result = nil;
    NSError *error = nil;
    int all = 0, passed = 0;

    result = [_reader decode:_resources.imageWithFileNamed(@"1.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(_resources.stringWithFileNamed(@"1.txt", NSUTF8StringEncoding), result.text); passed++; }
    all++;
    error = nil;
    result = [_reader decode:_resources.imageWithFileNamed(@"2.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(_resources.stringWithFileNamed(@"2.txt", NSUTF8StringEncoding), result.text); passed++; }
    all++;
    error = nil;
    result = [_reader decode:_resources.imageWithFileNamed(@"3.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(_resources.stringWithFileNamed(@"3.txt", NSUTF8StringEncoding), result.text); passed++; }
    all++;
    error = nil;
    result = [_reader decode:_resources.imageWithFileNamed(@"4.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(_resources.stringWithFileNamed(@"4.txt", NSUTF8StringEncoding), result.text); passed++; }
    all++;
    error = nil;
    result = [_reader decode:_resources.imageWithFileNamed(@"5.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(_resources.stringWithFileNamed(@"5.txt", NSUTF8StringEncoding), result.text); passed++; }
    all++;
    error = nil;
    result = [_reader decode:_resources.imageWithFileNamed(@"6.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(_resources.stringWithFileNamed(@"6.txt", NSUTF8StringEncoding), result.text); passed++; }
    all++;
    error = nil;
    result = [_reader decode:_resources.imageWithFileNamed(@"7.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(_resources.stringWithFileNamed(@"7.txt", NSUTF8StringEncoding), result.text); passed++; }
    all++;
    error = nil;
    result = [_reader decode:_resources.imageWithFileNamed(@"8.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(_resources.stringWithFileNamed(@"8.txt", NSUTF8StringEncoding), result.text); passed++; }
    all++;
    error = nil;
    result = [_reader decode:_resources.imageWithFileNamed(@"9.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(_resources.stringWithFileNamed(@"9.txt", NSUTF8StringEncoding), result.text); passed++; }
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
    NSLog(@"%@:%@, all:%d, passed:%d", NSStringFromClass(self.class), NSStringFromSelector(_cmd), all, passed);
}

@end
