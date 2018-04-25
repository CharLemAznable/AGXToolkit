//
//  UIImageAGXCoreTest.m
//  AGXCore
//
//  Created by Char Aznable on 2016/2/18.
//  Copyright © 2016年 AI-CUC-EC. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "AGXCore.h"

@interface UIImageAGXCoreTest : XCTestCase

@end

@implementation UIImageAGXCoreTest

- (void)testUIImageAGXCore {
    UIImage *bluePoint = [UIImage imageRectWithColor:UIColor.blueColor size:CGSizeMake(1, 1)];
    UIColor *blueDominantColor = [bluePoint dominantColor];
    XCTAssertEqualObjects(blueDominantColor, UIColor.blueColor);

    UIImage *redImage = [UIImage imageRectWithColor:UIColor.redColor size:CGSizeMake(100, 100)];
    UIColor *redDominantColor = [redImage dominantColor];
    XCTAssertEqualObjects(redDominantColor, UIColor.redColor);
}

- (void)testCaptchaImage {
    AGXResources.document.writeImageWithImageNamed(@"captcha", [UIImage captchaImageWithCaptchaCode:@"1234" size:CGSizeMake(80, 30)]);
    UIImage *captchaImage = AGXResources.document.imageWithImageNamed(@"captcha");
    XCTAssertEqual(captchaImage.size.width, 80 * UIScreen.mainScreen.scale);
    XCTAssertEqual(captchaImage.size.height, 30 * UIScreen.mainScreen.scale);
    AGXResources.document.deleteImageNamed(@"captcha");
}

- (void)testWatermarkImage {
    UIImage *baseImage = AGXResources.application.imageWithImageNamed(@"BaseImage");
    UIImage *markImage = AGXResources.application.imageWithImageNamed(@"MarkImage");
    UIImage *resultImage = [UIImage imageBaseOnImage:baseImage watermarkedWithImage:markImage
                                         inDirection:AGXDirectionSouth withOffset:CGVectorMake(20, 20)];
    AGXResources.document.writeImageWithImageNamed(@"ResultImage", resultImage);
    UIImage *savedImage = AGXResources.document.imageWithImageNamed(@"ResultImage");
    XCTAssertEqual(savedImage.size.width, baseImage.size.width);
    XCTAssertEqual(savedImage.size.height, baseImage.size.height);
    AGXResources.document.deleteImageNamed(@"ResultImage");
}

- (void)testWatermarkText {
    UIImage *baseImage = AGXResources.application.imageWithImageNamed(@"BaseImage");
    UIImage *resultImage = [UIImage imageBaseOnImage:baseImage watermarkedWithText:@"立即体验"
                                      withAttributes:@{NSForegroundColorAttributeName: AGXColor(@"ffffff80"),
                                                       NSFontAttributeName: [UIFont systemFontOfSize:16]}
                                         inDirection:AGXDirectionSouth withOffset:CGVectorMake(20, 20)];
    AGXResources.document.writeImageWithImageNamed(@"ResultImage", resultImage);
    UIImage *savedImage = AGXResources.document.imageWithImageNamed(@"ResultImage");
    XCTAssertEqual(savedImage.size.width, baseImage.size.width);
    XCTAssertEqual(savedImage.size.height, baseImage.size.height);
    AGXResources.document.deleteImageNamed(@"ResultImage");
}

- (void)testCrop {
    UIImage *baseImage = AGXResources.application.imageWithImageNamed(@"BaseImage");
    UIImage *resultImage = [baseImage imageWithCropRect:AGX_CGRectMake(baseImage.size)];
    XCTAssertEqual(resultImage.size.width, baseImage.size.width);
    XCTAssertEqual(resultImage.size.height, baseImage.size.height);
    resultImage = [baseImage imageWithCropInsets:UIEdgeInsetsMake(100, 100, 100, 100)];
    XCTAssertEqual(resultImage.size.width, baseImage.size.width-200);
    XCTAssertEqual(resultImage.size.height, baseImage.size.height-200);

    baseImage = AGXResources.application.imageWithImageNamed(@"MarkImage");
    resultImage = [baseImage imageWithCropRect:AGX_CGRectMake(baseImage.size)];
    XCTAssertEqual(resultImage.size.width, baseImage.size.width);
    XCTAssertEqual(resultImage.size.height, baseImage.size.height);
    resultImage = [baseImage imageWithCropInsets:UIEdgeInsetsMake(10, 10, 10, 10)];
    XCTAssertEqual(resultImage.size.width, baseImage.size.width-20);
    XCTAssertEqual(resultImage.size.height, baseImage.size.height-20);
}

@end
