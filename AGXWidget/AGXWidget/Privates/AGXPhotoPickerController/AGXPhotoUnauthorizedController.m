//
//  AGXPhotoUnauthorizedController.m
//  AGXWidget
//
//  Created by Char Aznable on 2018/1/18.
//  Copyright © 2018年 AI-CUC-EC. All rights reserved.
//

#import <AGXCore/AGXCore/AGXMath.h>
#import <AGXCore/AGXCore/UIApplication+AGXCore.h>
#import <AGXCore/AGXCore/UIView+AGXCore.h>
#import <AGXCore/AGXCore/UIColor+AGXCore.h>
#import "AGXPhotoUnauthorizedController.h"
#import "AGXWidgetLocalization.h"

static const CGFloat AGXPhotoUnauthorizedMargin = 10;
static const CGFloat AGXPhotoUnauthorizedSettingWidth = 100;
static const CGFloat AGXPhotoUnauthorizedSettingHeight = 44;

@implementation AGXPhotoUnauthorizedController {
    UILabel *_messageLabel;
    UIButton *_settingButton;
}

- (AGX_INSTANCETYPE)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if AGX_EXPECT_T(self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        _settingButtonColor = [AGXColor(@"4cd864") copy];

        _messageLabel = [[UILabel alloc] init];
        _messageLabel.font = [UIFont systemFontOfSize:16];
        _messageLabel.textColor = [UIColor lightGrayColor];
        _messageLabel.textAlignment = NSTextAlignmentCenter;
        _messageLabel.numberOfLines = 0;
        _messageLabel.text = AGXWidgetLocalizedStringDefault
        (@"AGXPhotoPickerController.unauthorizedMessage", @"No permission to access Photos Library");

        _settingButton = [[UIButton alloc] init];
        _settingButton.cornerRadius = 4;
        _settingButton.backgroundColor = _settingButtonColor;
        _settingButton.titleLabel.font = [UIFont systemFontOfSize:16];
        [_settingButton setTitleColor:[UIColor whiteColor]
                             forState:UIControlStateNormal];
        [_settingButton setTitle:AGXWidgetLocalizedStringDefault
         (@"AGXPhotoPickerController.unauthorizedSetting", @"Setting")
                        forState:UIControlStateNormal];
        [_settingButton addTarget:self action:@selector(settingButtonClick:)
                 forControlEvents:UIControlEventTouchUpInside];
    }
    return self;
}

- (void)dealloc {
    AGX_RELEASE(_settingButtonColor);
    AGX_RELEASE(_messageLabel);
    AGX_RELEASE(_settingButton);
    AGX_SUPER_DEALLOC;
}

- (void)setSettingButtonColor:(UIColor *)settingButtonColor {
    UIColor *temp = [settingButtonColor copy];
    AGX_RELEASE(_settingButtonColor);
    _settingButtonColor = temp;

    _settingButton.backgroundColor = _settingButtonColor;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:_messageLabel];
    [self.view addSubview:_settingButton];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    CGFloat width = self.view.bounds.size.width, height = self.view.bounds.size.height;

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
    if ([UIApplication canOpenApplicationSetting]) [UIApplication openApplicationSetting];
}

@end
