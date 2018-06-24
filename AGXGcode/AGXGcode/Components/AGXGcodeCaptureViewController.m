//
//  AGXGcodeCaptureViewController.m
//  AGXGcode
//
//  Created by Char Aznable on 2018/6/24.
//  Copyright © 2018年 AI-CUC-EC. All rights reserved.
//

#import <AGXCore/AGXCore/NSObject+AGXCore.h>
#import <AGXCore/AGXCore/UIColor+AGXCore.h>
#import <AGXCore/AGXCore/UIViewController+AGXCore.h>
#import "AGXGcodeCaptureViewController.h"
#import "AGXGcodeLocalization.h"

@implementation AGXGcodeCaptureViewController {
    AGXGcodeCaptureView *_captureView;
    UIButton *_cancelButton;
    UIButton *_readerButton;
}

@dynamic view;

- (AGX_INSTANCETYPE)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if AGX_EXPECT_T(self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        self.statusBarHidden = YES;
        _tintColor = [AGXColor(@"4cd864") copy];
        _autoDismissViewController = YES;
        _allowPhotoPickingReader = YES;

        _captureView = [[AGXGcodeCaptureView alloc] init];

        _cancelButton = [[UIButton alloc] init];
        _cancelButton.backgroundColor = UIColor.clearColor;
        _cancelButton.titleLabel.font = [UIFont systemFontOfSize:16];
        [_cancelButton setTitleColor:_tintColor forState:UIControlStateNormal];
        [_cancelButton setTitle:AGXGcodeLocalizedStringDefault
         (@"AGXGcodeCaptureViewController.cancelButtonTitle", @"Cancel")
                       forState:UIControlStateNormal];
        [_cancelButton addTarget:self action:@selector(cancelButtonClick:)
                forControlEvents:UIControlEventTouchUpInside];

        _readerButton = [[UIButton alloc] init];
        _readerButton.backgroundColor = UIColor.clearColor;
        _readerButton.titleLabel.font = [UIFont systemFontOfSize:16];
        [_readerButton setTitleColor:_tintColor forState:UIControlStateNormal];
        [_readerButton setTitle:AGXGcodeLocalizedStringDefault
         (@"AGXGcodeCaptureViewController.albumButtonTitle", @"Album")
                       forState:UIControlStateNormal];
        [_readerButton addTarget:self action:@selector(readerButtonClick:)
                forControlEvents:UIControlEventTouchUpInside];
        _readerButton.hidden = !_allowPhotoPickingReader;

        AGXAddNotification(agxGcodeCaptureViewControllerWillResignActive:, UIApplicationWillResignActiveNotification);
        AGXAddNotification(agxGcodeCaptureViewControllerDidBecomeActive:, UIApplicationDidBecomeActiveNotification);
    }
    return self;
}

- (void)dealloc {
    AGXRemoveNotification(UIApplicationWillResignActiveNotification);
    AGXRemoveNotification(UIApplicationDidBecomeActiveNotification);
    _delegate = nil;
    AGX_RELEASE(_tintColor);
    AGX_RELEASE(_captureView);
    AGX_RELEASE(_cancelButton);
    AGX_RELEASE(_readerButton);
    AGX_SUPER_DEALLOC;
}

- (NSArray *)formats {
    return _captureView.formats;
}

- (void)setFormats:(NSArray *)formats {
    _captureView.formats = formats;
}

- (CGRect)frameOfInterest {
    return _captureView.frameOfInterest;
}

- (void)setFrameOfInterest:(CGRect)frameOfInterest {
    _captureView.frameOfInterest = frameOfInterest;
}

- (void)setTintColor:(UIColor *)tintColor {
    UIColor *temp = [tintColor copy];
    AGX_RELEASE(_tintColor);
    _tintColor = temp;

    [_cancelButton setTitleColor:_tintColor forState:UIControlStateNormal];
    [_readerButton setTitleColor:_tintColor forState:UIControlStateNormal];
}

- (void)setAllowPhotoPickingReader:(BOOL)allowPhotoPickingReader {
    _allowPhotoPickingReader = allowPhotoPickingReader;

    _readerButton.hidden = !_allowPhotoPickingReader;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = UIColor.blackColor;
    _captureView.delegate = self;
    [self.view addSubview:_captureView];
    [self.view addSubview:_cancelButton];
    [self.view addSubview:_readerButton];
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];

    _captureView.frame = self.view.bounds;
    [self.view bringSubviewToFront:_cancelButton];
    [_cancelButton sizeToFit];
    _cancelButton.frame = CGRectMake(0, 0, _cancelButton.bounds.size.width*2, 44);
    [self.view bringSubviewToFront:_readerButton];
    [_readerButton sizeToFit];
    _readerButton.frame = CGRectMake(self.view.frame.size.width - _readerButton.bounds.size.width*2, 0,
                                     _readerButton.bounds.size.width*2, 44);
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [_captureView startCapture];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [_captureView stopCapture];
}

- (void)agxGcodeCaptureViewControllerWillResignActive:(NSNotification *)notification {
    [_captureView stopCapture];
}

- (void)agxGcodeCaptureViewControllerDidBecomeActive:(NSNotification *)notification {
    [_captureView startCapture];
}

#pragma mark - user event

- (void)cancelButtonClick:(id)sender {
    if (_autoDismissViewController)
        [self.presentingViewController dismissViewControllerAnimated:YES completion:NULL];

    if ([self.delegate respondsToSelector:@selector(gcodeCaptureViewControllerDidCancel:)])
        [self.delegate gcodeCaptureViewControllerDidCancel:self];
}

- (void)readerButtonClick:(id)sender {
    AGXGcodeReaderController *reader = AGXGcodeReaderController.instance;
    reader.hint = [AGXDecodeHints hintsWithFormats:_captureView.formats];
    reader.gcodeReaderDelegate = self;
    [self presentViewController:reader animated:YES completion:NULL];
}

#pragma mark - AGXGcodeCaptureViewDelegate

- (void)gcodeCaptureView:(AGXGcodeCaptureView *)captureView didReadResult:(AGXGcodeResult *)result {
    [_captureView stopCapture];
    if (_autoDismissViewController)
        [self.presentingViewController dismissViewControllerAnimated:YES completion:NULL];

    if ([self.delegate respondsToSelector:@selector(gcodeCaptureViewController:didReadResult:)]) {
        [self.delegate gcodeCaptureViewController:self didReadResult:result];
    }
}

#pragma mark - AGXGcodeReaderControllerDelegate

- (void)gcodeReaderController:(AGXGcodeReaderController *)reader didReadResult:(AGXGcodeResult *)result {
    [_captureView stopCapture];
    if (_autoDismissViewController)
        [self.presentingViewController dismissViewControllerAnimated:YES completion:NULL];
    else [reader.presentingViewController dismissViewControllerAnimated:YES completion:NULL];

    if ([self.delegate respondsToSelector:@selector(gcodeCaptureViewController:didReadResult:)]) {
        [self.delegate gcodeCaptureViewController:self didReadResult:result];
    }
}

- (void)gcodeReaderController:(AGXGcodeReaderController *)reader failedWithError:(NSError *)error {
    [reader.presentingViewController dismissViewControllerAnimated:YES completion:NULL];

    if ([self.delegate respondsToSelector:@selector(gcodeCaptureViewController:failedWithError:)]) {
        [self.delegate gcodeCaptureViewController:self failedWithError:error];
    }
}

@end
