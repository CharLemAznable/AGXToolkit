//
//  UIImageAGXCoreTest.m
//  AGXCore
//
//  Created by Char Aznable on 16/2/18.
//  Copyright © 2016年 AI-CUC-EC. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "AGXCore.h"

@interface UIImageAGXCoreTest : XCTestCase

@end

@implementation UIImageAGXCoreTest

- (void)testUIImageAGXCore {
    UIImage *bluePoint = [UIImage imageRectWithColor:[UIColor blueColor] size:CGSizeMake(1, 1)];
    UIColor *blueDominantColor = [bluePoint dominantColor];
    XCTAssertEqualObjects(blueDominantColor, [UIColor blueColor]);

    UIImage *redImage = [UIImage imageRectWithColor:[UIColor redColor] size:CGSizeMake(100, 100)];
    UIColor *redDominantColor = [redImage dominantColor];
    XCTAssertEqualObjects(redDominantColor, [UIColor redColor]);
}

- (void)testCaptchaImage {
    AGXDirectory.writeToFileWithImage(@"captcha", [UIImage captchaImageWithCaptchaCode:@"1234" size:CGSizeMake(80, 30)]);
    UIImage *captchaImage = AGXDirectory.imageWithFile(@"captcha");
    XCTAssertEqual(captchaImage.size.width, 80 * UIScreen.mainScreen.scale);
    XCTAssertEqual(captchaImage.size.height, 30 * UIScreen.mainScreen.scale);
    AGXDirectory.deleteFile(@"captcha.png");
}

@end
