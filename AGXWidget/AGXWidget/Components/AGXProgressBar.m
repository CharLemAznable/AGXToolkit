//
//  AGXProgressBar.m
//  AGXWidget
//
//  Created by Char Aznable on 16/3/10.
//  Copyright © 2016年 AI-CUC-EC. All rights reserved.
//

//
//  Modify from:
//  ninjinkun/NJKWebViewProgress
//

//  The MIT License (MIT)
//
//  Copyright (c) 2013 Satoshi Asano
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.

#import <AGXCore/AGXCore/UIView+AGXCore.h>
#import <AGXCore/AGXCore/UIColor+AGXCore.h>
#import "AGXProgressBar.h"
#import "UIView+AGXWidgetAnimation.h"

@implementation AGXProgressBar {
    UIView *_progressingView;
}

- (void)agxInitial {
    self.userInteractionEnabled = NO;
    _progressDuration = 0.3;
    _fadingDuration = 0.3;
    _fadeDelay = 0.3;
    _progress = 0.0;

    _progressingView = [[UIView alloc] init];
    _progressingView.backgroundColor = [UIColor colorWithRGBHexString:@"167efb"];
    [self addSubview:_progressingView];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    _progressingView.frame = CGRectMake(0, 0, _progress * self.bounds.size.width, self.bounds.size.height);
}

- (void)dealloc {
    AGX_RELEASE(_progressingView);
    AGX_SUPER_DEALLOC;
}

- (UIColor *)progressColor {
    return _progressingView.backgroundColor;
}

- (void)setProgressColor:(UIColor *)progressColor {
    _progressingView.backgroundColor = progressColor;
}

+ (UIColor *)progressColor {
    return [[self appearance] progressColor];
}

+ (void)setProgressColor:(UIColor *)progressColor {
    [[self appearance] setProgressColor:progressColor];
}

- (void)setProgress:(float)progress {
    [self setProgress:progress animated:NO];
}

- (void)setProgress:(float)progress animated:(BOOL)animated {
    _progress = progress;
    [UIView animateWithDuration:(_progress > 0.0 && animated) ? _progressDuration : 0 animations:^{
         [_progressingView resizeFrame:^CGRect(CGRect rect) {
             rect.size.width = _progress * self.bounds.size.width; return rect;
         }];
     }];

    if (_progress >= 1.0) {
        [_progressingView agxAnimate:AGXAnimationMake
         (AGXAnimateFade|AGXAnimateOut, AGXAnimateStay, animated ? _fadingDuration : 0, _fadeDelay)
                          completion:^{ [_progressingView removeFromSuperview]; }];
    } else {
        if (_progressingView.superview) return;
        [self addSubview:_progressingView];
        [_progressingView agxAnimate:AGXImmediateAnimationMake
         (AGXAnimateFade|AGXAnimateIn|AGXAnimateNotReset, AGXAnimateStay, animated ? _fadingDuration : 0)];
    }
}

@end
