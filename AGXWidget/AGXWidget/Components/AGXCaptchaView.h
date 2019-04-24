//
//  AGXCaptchaView.h
//  AGXWidget
//
//  Created by Char Aznable on 2017/11/7.
//  Copyright © 2017 github.com/CharLemAznable. All rights reserved.
//

#ifndef AGXWidget_AGXCaptchaView_h
#define AGXWidget_AGXCaptchaView_h

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, AGXCaptchaType) {
    AGXCaptchaDefault,
    AGXCaptchaDecimalDigit,
    AGXCaptchaLetter
};

@interface AGXCaptchaView : UIControl
@property (nonatomic, assign) AGXCaptchaType captchaType;
@property (nonatomic, assign) int captchaLength; // default 4

- (BOOL)verifyCaptcha:(NSString *)inputCode;
@end

#endif /* AGXWidget_AGXCaptchaView_h */
