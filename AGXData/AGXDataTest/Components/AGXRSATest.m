//
//  AGXRSATest.m
//  AGXCoreTest
//
//  Created by Char on 2018/10/22.
//  Copyright © 2018 github.com/CharLemAznable. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "AGXData.h"

@interface AGXRSATest : XCTestCase

@end

@implementation AGXRSATest

static NSString *plainText = @"{ mac=\"MAC Address\", appId=\"16位字符串\", signature=SHA1(\"appId=xxx&mac=yyy\") }";
static NSString *publicKeyString = @"MIGfMA0GCSqGSIb3DQEBAQUAA4GNADCBiQKBgQCrmNSP6sJ4fiX088u3fUMZwnzLj2CcQQcIZM1Dn9yaQUYnOkdMUg+OAZZVQ929ywQNbh/w66DiCAcmHDoBhGQ6oN61uekVIg4KGeVfacwKXYuoLtMUrGGRtuFx8pyiXFEWNkbfxNawzkzupnKZlfiIwDbCqWF2yS0gJk52jdtITQIDAQAB";
static NSString *privateKeyString = @"MIICeAIBADANBgkqhkiG9w0BAQEFAASCAmIwggJeAgEAAoGBAKuY1I/qwnh+JfTzy7d9QxnCfMuPYJxBBwhkzUOf3JpBRic6R0xSD44BllVD3b3LBA1uH/DroOIIByYcOgGEZDqg3rW56RUiDgoZ5V9pzApdi6gu0xSsYZG24XHynKJcURY2Rt/E1rDOTO6mcpmV+IjANsKpYXbJLSAmTnaN20hNAgMBAAECgYEAhFcqGJSFx0gDHheoVatVxNgqRxQc/mVodyDG7hCsoosU/8wCkOn49RxkRP5CVc3tIi58k+ImAi0O1mWOlvz0DsAHcJXaAQ6Kz8NuI5d+KEVtW6KeotN4PARwIdtRWMKzQgyVjqvQeGedU1RijsLHI2AgFTsugTffmYpd8LT8ogECQQDV3zQJovUyYiJLZpB2E/qyQ4J7nhvvO0YaHLj0i79iMyiuvZPct97FOwaPitavUU+jkrNEZ5BflSK/BGY5Ig4VAkEAzWXa2CwTkzpMYlHgq7+EltTnyXDAFRnmK1WWVMK+u36VHhEkB2fQiSmYa49+o8RI4KeuAqhkzMfLmHERc16XWQJBAMr44tUGb7faRHvUoeM+AN1vjoUtP4uicFxVx/5mJkLXFJQJ3StK4UPDSe2usSJ/g5pUnoeb1fuweOJaFX3BYSUCQQCVXFD0y7B8anNrN9Eh84YOTMo0sPntHkVDE9zazDb4jwcOszY48GQzqfy9kr5rhmvcefLO2fda9pr1wpsHAy0ZAkAYIPb6wokynXKODY7S8mt7U5QRbO6fEgoJqllC6WfrGtIVvNxm5D7DkvmzfMovbX9MEnsWjPMblynYHxHH+xoC";

- (void)testEncryptAndDecrypt {
    NSString *encryptByPubKey = [AGXRSA encryptString:plainText publicKey:publicKeyString];
    XCTAssertEqualObjects(plainText, [AGXRSA decryptString:encryptByPubKey privateKey:privateKeyString]);
}

- (void)testSignAndVerify {
    NSString *sign = [AGXRSA signSHA1String:plainText privateKey:privateKeyString];
    XCTAssertTrue([AGXRSA verifySHA1String:plainText signString:sign publicKey:publicKeyString]);
}

@end
