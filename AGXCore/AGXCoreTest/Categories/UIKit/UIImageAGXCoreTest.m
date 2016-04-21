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

@end
