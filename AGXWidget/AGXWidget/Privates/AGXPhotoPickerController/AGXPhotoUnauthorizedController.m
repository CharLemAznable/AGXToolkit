//
//  AGXPhotoUnauthorizedController.m
//  AGXWidget
//
//  Created by Char Aznable on 2018/1/18.
//  Copyright © 2018 github.com/CharLemAznable. All rights reserved.
//

//
//  Modify from:
//  banchichen/TZImagePickerController
//

//  The MIT License (MIT)
//
//  Copyright (c) 2016 Zhen Tan
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.

#import <AGXCore/AGXCore/AGXMath.h>
#import <AGXCore/AGXCore/UIApplication+AGXCore.h>
#import <AGXCore/AGXCore/UIView+AGXCore.h>
#import <AGXCore/AGXCore/UIColor+AGXCore.h>
#import "AGXPhotoUnauthorizedController.h"
#import "AGXWidgetLocalization.h"

AGX_STATIC const CGFloat AGXPhotoUnauthorizedMargin = 10;
AGX_STATIC const CGFloat AGXPhotoUnauthorizedSettingWidth = 100;
AGX_STATIC const CGFloat AGXPhotoUnauthorizedSettingHeight = 44;

@interface AGXPhotoUnauthorizedView : UIView
@property (nonatomic, copy) UIColor *settingButtonColor; // default 4cd864
@end

@interface AGXPhotoUnauthorizedController ()
@property (nonatomic, AGX_STRONG) AGXPhotoUnauthorizedView *view;
@end

@implementation AGXPhotoUnauthorizedController

@dynamic view;

- (AGX_INSTANCETYPE)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if AGX_EXPECT_T(self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        self.navigationItem.title = AGXWidgetLocalizedStringDefault
        (@"AGXPhotoPickerController.albumTitle", @"Photos");
    }
    return self;
}

- (UIColor *)settingButtonColor {
    return self.view.settingButtonColor;
}

- (void)setSettingButtonColor:(UIColor *)settingButtonColor {
    self.view.settingButtonColor = settingButtonColor;
}

@end

@implementation AGXPhotoUnauthorizedView {
    UILabel *_messageLabel;
    UIButton *_settingButton;
}

- (void)agxInitial {
    [super agxInitial];
    self.backgroundColor = UIColor.whiteColor;

    _messageLabel = [[UILabel alloc] init];
    _messageLabel.font = [UIFont systemFontOfSize:16];
    _messageLabel.textColor = UIColor.lightGrayColor;
    _messageLabel.textAlignment = NSTextAlignmentCenter;
    _messageLabel.numberOfLines = 0;
    _messageLabel.text = AGXWidgetLocalizedStringDefault
    (@"AGXPhotoPickerController.unauthorizedMessage", @"No permission to access Photos Library");
    [self addSubview:_messageLabel];

    _settingButton = [[UIButton alloc] init];
    _settingButton.cornerRadius = 4;
    _settingButton.backgroundColor = AGXColor(@"4cd864");
    _settingButton.titleLabel.font = [UIFont systemFontOfSize:16];
    [_settingButton setTitleColor:UIColor.whiteColor
                         forState:UIControlStateNormal];
    [_settingButton setTitle:AGXWidgetLocalizedStringDefault
     (@"AGXPhotoPickerController.unauthorizedSetting", @"Setting")
                    forState:UIControlStateNormal];
    [_settingButton addTarget:self action:@selector(settingButtonClick:)
             forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:_settingButton];
}

- (void)dealloc {
    AGX_RELEASE(_messageLabel);
    AGX_RELEASE(_settingButton);
    AGX_SUPER_DEALLOC;
}

- (UIColor *)settingButtonColor {
    return _settingButton.backgroundColor;
}

- (void)setSettingButtonColor:(UIColor *)settingButtonColor {
    _settingButton.backgroundColor = settingButtonColor;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    CGFloat width = self.bounds.size.width, height = self.bounds.size.height;

    CGFloat messageLabelHeight = cgceil(_messageLabel.font.lineHeight)*3;
    _messageLabel.frame = CGRectMake(0, height/2-messageLabelHeight,
                                     width, messageLabelHeight);
    _settingButton.frame = CGRectMake((width-AGXPhotoUnauthorizedSettingWidth)/2,
                                      height/2+AGXPhotoUnauthorizedMargin,
                                      AGXPhotoUnauthorizedSettingWidth,
                                      AGXPhotoUnauthorizedSettingHeight);
}

#pragma mark - user event

- (void)settingButtonClick:(id)sender {
    if (UIApplication.canOpenApplicationSetting) [UIApplication openApplicationSetting];
}

@end
