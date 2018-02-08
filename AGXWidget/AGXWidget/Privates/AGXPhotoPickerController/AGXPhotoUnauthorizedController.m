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

@interface AGXPhotoUnauthorizedView : UIView
@property (nonatomic, copy) UIColor *settingButtonColor; // default 4cd864
@end

@interface AGXPhotoUnauthorizedController ()
@property (nonatomic, AGX_STRONG) AGXPhotoUnauthorizedView *view;
@end

@implementation AGXPhotoUnauthorizedController

@dynamic view;

- (UIColor *)settingButtonColor {
    return self.view.settingButtonColor;
}

- (void)setSettingButtonColor:(UIColor *)settingButtonColor {
    self.view.settingButtonColor = settingButtonColor;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    NSString *title = AGXWidgetLocalizedStringDefault
    (@"AGXPhotoPickerController.albumTitle", @"Photos");
    self.title = title;
    self.navigationItem.title = title;
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
