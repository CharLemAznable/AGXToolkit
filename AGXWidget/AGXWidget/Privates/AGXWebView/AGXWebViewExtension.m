//
//  AGXWebViewExtension.m
//  AGXWidget
//
//  Created by Char Aznable on 2016/3/16.
//  Copyright © 2016 github.com/CharLemAznable. All rights reserved.
//

#import <AGXCore/AGXCore/NSString+AGXCore.h>
#import <AGXCore/AGXCore/UIColor+AGXCore.h>
#import "AGXWebViewExtension.h"
#import "AGXWidgetLocalization.h"

@implementation AGXWebViewExtension

- (AGX_INSTANCETYPE)init {
    if AGX_EXPECT_T(self = [super init]) {
        _autoCoordinateBackgroundColor = YES;
        _autoRevealCurrentLocationHost = YES;
        _currentLocationHostRevealFormat = nil;
    }
    return self;
}

- (void)dealloc {
    AGX_RELEASE(_currentLocationHostRevealFormat);
    _delegate = nil;
    AGX_SUPER_DEALLOC;
}

AGX_STATIC NSString *const documentBodyBackgroundColorJS
= @"document.defaultView.getComputedStyle(document.body,null).getPropertyValue('background-color')";

- (void)coordinateBackgroundColor {
    if (_autoCoordinateBackgroundColor && [self.delegate respondsToSelector:@selector(evaluateJavascript:)]) {
        NSString *backgroundColorString = [self.delegate evaluateJavascript:documentBodyBackgroundColorJS];
        if (AGXIsNotEmpty(backgroundColorString) && [self.delegate respondsToSelector:@selector(webViewExtension:coordinateWithBackgroundColor:)]) {
            NSArray *colors = [backgroundColorString arraySeparatedByCharactersInSet:
                               [NSCharacterSet characterSetWithCharactersInString:@"RGBrgb(, )"] filterEmpty:YES];
            [self.delegate webViewExtension:self coordinateWithBackgroundColor:
             [UIColor colorWithIntegerRed:[colors[0] integerValue]
                                    green:[colors[1] integerValue]
                                     blue:[colors[2] integerValue]]];
        }
    }
}

AGX_STATIC NSString *const currentWindowLocationHostJS = @"window.location.host";

- (void)revealCurrentLocationHost {
    if (_autoRevealCurrentLocationHost && [self.delegate respondsToSelector:@selector(evaluateJavascript:)]) {
        NSString *locationHostString = [self.delegate evaluateJavascript:currentWindowLocationHostJS];
        if ([self.delegate respondsToSelector:@selector(webViewExtension:revealWithCurrentLocationHost:)]) {
            NSString *format = [_currentLocationHostRevealFormat containsString:@"%@"]
            ? _currentLocationHostRevealFormat : AGXWidgetLocalizedStringDefault
            (@"AGXWebView.currentLocationHostRevealFormat", @"Provided by: %@");
            [self.delegate webViewExtension:self revealWithCurrentLocationHost:
             AGXIsNotEmpty(locationHostString) ? [NSString stringWithFormat:format, locationHostString] : @""];
        }
    }
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidChangeAdjustedContentInset:(UIScrollView *)scrollView {
    if ([self.delegate respondsToSelector:@selector(webViewExtension:didChangeAdjustedContentInset:)]) {
        [self.delegate webViewExtension:self didChangeAdjustedContentInset:scrollView];
    }
}

- (void)scrollViewDidChangeAutomaticallyAdjustedContentInset:(UIScrollView *)scrollView {
    if ([self.delegate respondsToSelector:@selector(webViewExtension:didChangeAdjustedContentInset:)]) {
        [self.delegate webViewExtension:self didChangeAdjustedContentInset:scrollView];
    }
}

@end
