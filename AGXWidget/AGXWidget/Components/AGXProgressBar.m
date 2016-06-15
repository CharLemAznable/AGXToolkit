//
//  AGXProgressBar.m
//  AGXWidget
//
//  Created by Char Aznable on 16/3/10.
//  Copyright © 2016年 AI-CUC-EC. All rights reserved.
//

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
                          completion:^{
                              _progressingView.alpha = 0.0;
                          }];
    } else {
        _progressingView.alpha = 1.0;
        [_progressingView agxAnimate:AGXImmediateAnimationMake
         (AGXAnimateFade|AGXAnimateIn|AGXAnimateNotReset, AGXAnimateStay, animated ? _fadingDuration : 0)];
    }
}

@end
