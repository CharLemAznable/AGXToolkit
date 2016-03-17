//
//  AGXWebViewExtension.m
//  AGXWidget
//
//  Created by Char Aznable on 16/3/16.
//  Copyright © 2016年 AI-CUC-EC. All rights reserved.
//

#import "AGXWebViewExtension.h"
#import <AGXCore/AGXCore/AGXObjC.h>
#import <AGXCore/AGXCore/NSString+AGXCore.h>
#import <AGXCore/AGXCore/UIColor+AGXCore.h>

@implementation AGXWebViewExtension

- (AGX_INSTANCETYPE)init {
    if (AGX_EXPECT_T(self = [super init])) {
        _coordinateBackgroundColor = YES;
    }
    return self;
}

- (void)dealloc {
    _delegate = nil;
    AGX_SUPER_DEALLOC;
}

static NSString *documentBodyBackgroundColorJS
= @"document.defaultView.getComputedStyle(document.body,null).getPropertyValue('background-color')";

- (void)coordinate {
    if (_coordinateBackgroundColor) {
        NSString *backgroundColorString = [_delegate evaluateJavascript:documentBodyBackgroundColorJS];
        if ([backgroundColorString isNotEmpty]) {
            NSArray *colors = [backgroundColorString arraySplitedByCharactersInSet:
                               [NSCharacterSet characterSetWithCharactersInString:@"RGBrgb(, )"]];
            [_delegate coordinateWithBackgroundColor:
             [UIColor colorWithIntegerRed:[colors[0] integerValue]
                                    green:[colors[1] integerValue]
                                     blue:[colors[2] integerValue]]];
        }
    }
}

@end