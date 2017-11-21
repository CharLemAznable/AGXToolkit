//
//  AGXCaptchaView.m
//  AGXWidget
//
//  Created by Char Aznable on 2017/11/7.
//  Copyright © 2017年 AI-CUC-EC. All rights reserved.
//

#import <AGXCore/AGXCore/AGXRandom.h>
#import <AGXCore/AGXCore/NSString+AGXCore.h>
#import <AGXCore/AGXCore/UIView+AGXCore.h>
#import <AGXCore/AGXCore/UIImage+AGXCore.h>
#import "AGXCaptchaView.h"

@implementation AGXCaptchaView {
    NSString *_captchaCode;
}

- (void)agxInitial {
    _captchaType = AGXCaptchaDefault;
    _captchaLength = 4;

    [self p_updateCaptchaImage];
}

- (void)dealloc {
    AGX_RELEASE(_captchaCode);
    AGX_SUPER_DEALLOC;
}

- (void)setCaptchaType:(AGXCaptchaType)captchaType {
    _captchaType = captchaType;
    [self p_updateCaptchaImage];
}

- (void)setCaptchaLength:(int)captchaLength {
    _captchaLength = captchaLength;
    [self p_updateCaptchaImage];
}

- (void)endTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event {
    [super endTrackingWithTouch:touch withEvent:event];

    if (!self.touchInside) return;
    [self p_updateCaptchaImage];
}

- (BOOL)verifyCaptcha:(NSString *)inputCode {
    return [_captchaCode isCaseInsensitiveEqualToString:inputCode];
}

- (void)p_updateCaptchaImage {
    NSString *(^randomBlock)(int count) = _captchaType == AGXCaptchaDecimalDigit ? AGXRandom.NUM :
    (_captchaType == AGXCaptchaLetter ? AGXRandom.LETTERS : AGXRandom.ALPHANUMERIC);
    NSString *temp = AGX_RETAIN(randomBlock(_captchaLength));
    AGX_RELEASE(_captchaCode);
    _captchaCode = temp;

    self.backgroundImage = [UIImage captchaImageWithCaptchaCode:_captchaCode size:self.bounds.size];
}

@end
