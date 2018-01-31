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
@property (nonatomic, AGX_STRONG) AGXBundle *bundle;
@property (nonatomic, AGX_STRONG) AGXQRCodeReader *reader;
@end

@implementation AGXQRCodeReaderTest

- (void)setUp {
    [super setUp];
    _bundle = AGX_RETAIN(AGXBundle.bundleNameAs(@"Resources"));
    _reader = [[AGXQRCodeReader alloc] init];
}

- (void)tearDown {
    AGX_RELEASE(_bundle);
    AGX_RELEASE(_reader);
    [super tearDown];
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
    if (!error) { XCTAssertEqualObjects(@"Sean Owen\r\nsrowen@google.com\r\n917-364-2918\r\nhttp://awesome-thoughts.com", result.text); passed++; }
    all++;
    error = nil;
    result = [_reader decode:_bundle.imageWithFile(@"17.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(@"Sean Owen\r\nsrowen@google.com\r\n917-364-2918\r\nhttp://awesome-thoughts.com", result.text); passed++; }
    all++;
    error = nil;
    result = [_reader decode:_bundle.imageWithFile(@"18.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(@"Sean Owen\r\nsrowen@google.com\r\n917-364-2918\r\nhttp://awesome-thoughts.com", result.text); passed++; }
    all++;
    error = nil;
    result = [_reader decode:_bundle.imageWithFile(@"19.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(@"Sean Owen\r\nsrowen@google.com\r\n917-364-2918\r\nhttp://awesome-thoughts.com", result.text); passed++; }
    all++;
    error = nil;
    result = [_reader decode:_bundle.imageWithFile(@"20.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(@"Sean Owen\r\nsrowen@google.com\r\n917-364-2918\r\nhttp://awesome-thoughts.com", result.text); passed++; }
    all++;
    error = nil;
    NSLog(@"%@:%@, all:%d, passed:%d", NSStringFromClass(self.class), NSStringFromSelector(_cmd), all, passed);
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
    if (!error) { XCTAssertEqualObjects(@"Google モバイル\r\nhttp://google.jp", result.text); passed++; }
    all++;
    error = nil;
    result = [_reader decode:_bundle.imageWithFile(@"11.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(@"BEGIN:VCARD\r\nN:Kennedy;Steve\r\nTEL:+44 (0)7775 755503\r\nADR;HOME:;;Flat 2, 43 Howitt Road, Belsize Park;London;;NW34LU;UK\r\nORG:NetTek Ltd;\r\nTITLE:Consultant\r\nEMAIL:steve@nettek.co.uk\r\nURL:www.nettek.co.uk\r\nEMAIL;IM:MSN:steve@gbnet.net\r\nNOTE:Testing 1 2 3\r\nBDAY:19611105\r\nEND:VCARD", result.text); passed++; }
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
    if (!error) { XCTAssertEqualObjects(@"[外側QRコード]\r\n \r\n*ﾀﾞﾌﾞﾙQR*\r\nhttp://d-qr.net/ex/", result.text); passed++; }
    all++;
    error = nil;
    result = [_reader decode:_bundle.imageWithFile(@"17.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(@"ﾃﾞｻﾞｲﾝQR\r\nhttp://d-qr.net/ex/", result.text); passed++; }
    all++;
    error = nil;
    result = [_reader decode:_bundle.imageWithFile(@"18.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(@"*ﾃﾞｻﾞｲﾝQR*     \r\nhttp://d-qr.net/ex/       ", result.text); passed++; }
    all++;
    error = nil;
    result = [_reader decode:_bundle.imageWithFile(@"19.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(@"*ﾃﾞｻﾞｲﾝQR*    \r\nhttp://d-qr.net/ex/         ", result.text); passed++; }
    all++;
    error = nil;
    result = [_reader decode:_bundle.imageWithFile(@"20.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(@"*ﾃﾞｻﾞｲﾝQR*\r\nhttp://d-qr.net/ex/    ", result.text); passed++; }
    all++;
    error = nil;
    result = [_reader decode:_bundle.imageWithFile(@"21.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(@"*ﾃﾞｻﾞｲﾝQR*  \r\nhttp://d-qr.net/ex/        ", result.text); passed++; }
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
    if (!error) { XCTAssertEqualObjects(@"*ﾃﾞｻﾞｲﾝQR* \r\nhttp://d-qr.net/ex/      ", result.text); passed++; }
    all++;
    error = nil;
    result = [_reader decode:_bundle.imageWithFile(@"25.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(_bundle.stringWithFile(@"25.txt", NSUTF8StringEncoding), result.text); passed++; }
    all++;
    error = nil;
    result = [_reader decode:_bundle.imageWithFile(@"26.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(@"<ﾃﾞｻﾞｲﾝQR> \r\nｲﾗｽﾄ入りｶﾗｰQRｺｰﾄﾞ\r\nhttp://d-qr.net/ex/ ", result.text); passed++; }
    all++;
    error = nil;
    result = [_reader decode:_bundle.imageWithFile(@"27.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(@"*ﾃﾞｻﾞｲﾝQR*   \r\nhttp://d-qr.net/ex/ ", result.text); passed++; }
    all++;
    error = nil;
    result = [_reader decode:_bundle.imageWithFile(@"28.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(_bundle.stringWithFile(@"28.txt", NSUTF8StringEncoding), result.text); passed++; }
    all++;
    error = nil;
    result = [_reader decode:_bundle.imageWithFile(@"29.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(@"http://live.fdgm.jp/u/event/hype/hype_top.html \r\n\r\nMEBKM:TITLE:hypeモバイル;URL:http\\://live.fdgm.jp/u/event/hype/hype_top.html;;", result.text); passed++; }
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
    if (!error) { XCTAssertEqualObjects(@"BEGIN:VCARD\r\nN:Kennedy;Steve\r\nTEL:+44 (0)7775 755503\r\nADR;HOME:;;Flat 2, 43 Howitt Road, Belsize Park;London;;NW34LU;UK\r\nORG:NetTek Ltd;\r\nTITLE:Consultant\r\nEMAIL:steve@nettek.co.uk\r\nURL:www.nettek.co.uk\r\nEMAIL;IM:MSN:steve@gbnet.net\r\nNOTE:Testing 1 2 3\r\nBDAY:19611105\r\nEND:VCARD", result.text); passed++; }
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
    NSLog(@"%@:%@, all:%d, passed:%d", NSStringFromClass(self.class), NSStringFromSelector(_cmd), all, passed);
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
    if (!error) { XCTAssertEqualObjects(@"UI office hours signup\r\nhttp://www.corp.google.com/sparrow/ui_office_hours/ \r\n", result.text); passed++; }
    all++;
    error = nil;
    result = [_reader decode:_bundle.imageWithFile(@"19.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(@"UI office hours signup\r\nhttp://www.corp.google.com/sparrow/ui_office_hours/ \r\n", result.text); passed++; }
    all++;
    error = nil;
    result = [_reader decode:_bundle.imageWithFile(@"20.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(@"UI office hours signup\r\nhttp://www.corp.google.com/sparrow/ui_office_hours/ \r\n", result.text); passed++; }
    all++;
    error = nil;
    result = [_reader decode:_bundle.imageWithFile(@"21.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(@"UI office hours signup\r\nhttp://www.corp.google.com/sparrow/ui_office_hours/ \r\n", result.text); passed++; }
    all++;
    error = nil;
    result = [_reader decode:_bundle.imageWithFile(@"22.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(@"UI office hours signup\r\nhttp://www.corp.google.com/sparrow/ui_office_hours/ \r\n", result.text); passed++; }
    all++;
    error = nil;
    result = [_reader decode:_bundle.imageWithFile(@"23.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(@"UI office hours signup\r\nhttp://www.corp.google.com/sparrow/ui_office_hours/ \r\n", result.text); passed++; }
    all++;
    error = nil;
    result = [_reader decode:_bundle.imageWithFile(@"24.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(@"UI office hours signup\r\nhttp://www.corp.google.com/sparrow/ui_office_hours/ \r\n", result.text); passed++; }
    all++;
    error = nil;
    result = [_reader decode:_bundle.imageWithFile(@"25.png") hints:nil error:&error];
    if (!error) { XCTAssertEqualObjects(@"UI office hours signup\r\nhttp://www.corp.google.com/sparrow/ui_office_hours/ \r\n", result.text); passed++; }
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
    NSLog(@"%@:%@, all:%d, passed:%d", NSStringFromClass(self.class), NSStringFromSelector(_cmd), all, passed);
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
    NSLog(@"%@:%@, all:%d, passed:%d", NSStringFromClass(self.class), NSStringFromSelector(_cmd), all, passed);
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
    NSLog(@"%@:%@, all:%d, passed:%d", NSStringFromClass(self.class), NSStringFromSelector(_cmd), all, passed);
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
    NSLog(@"%@:%@, all:%d, passed:%d", NSStringFromClass(self.class), NSStringFromSelector(_cmd), all, passed);
}

@end
