//
//  AGXAssetPreviewController.m
//  AGXWidget
//
//  Created by Char Aznable on 2018/2/2.
//  Copyright © 2018年 AI-CUC-EC. All rights reserved.
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

#import <PhotosUI/PhotosUI.h>
#import <AVFoundation/AVFoundation.h>
#import <AGXCore/AGXCore/AGXAdapt.h>
#import <AGXCore/AGXCore/AGXMath.h>
#import <AGXCore/AGXCore/UIApplication+AGXCore.h>
#import <AGXCore/AGXCore/UIView+AGXCore.h>
#import <AGXCore/AGXCore/UIButton+AGXCore.h>
#import <AGXCore/AGXCore/UIImage+AGXCore.h>
#import <AGXCore/AGXCore/UIImageView+AGXCore.h>
#import <AGXCore/AGXCore/UIColor+AGXCore.h>
#import <AGXCore/AGXCore/UIViewController+AGXCore.h>
#import <AGXCore/AGXCore/UIScrollView+AGXCore.h>
#import "AGXAssetPreviewController.h"
#import "AGXWidgetLocalization.h"
#import "AGXSwitch.h"
#import "AGXProgressHUD.h"
#import "AGXProgressBar.h"
#import "UIView+AGXWidgetAnimation.h"
#import "AGXPhotoManager.h"

static NSString *const AGXPhotoPreviewCellReuseIdentifier       = @"AGXPhotoPreviewCellReuseIdentifier";
static NSString *const AGXGifPreviewCellReuseIdentifier         = @"AGXGifPreviewCellReuseIdentifier";
static NSString *const AGXLivePhotoPreviewCellReuseIdentifier   = @"AGXLivePhotoPreviewCellReuseIdentifier";
static NSString *const AGXVideoPreviewCellReuseIdentifier       = @"AGXVideoPreviewCellReuseIdentifier";

static NSString *const AGXAssetPreviewCollectionViewToggleBarsHiddenNotification = @"AGXAssetPreviewCollectionViewToggleBarsHidden";
static NSString *const AGXAssetPreviewCollectionViewDidScrollNotification = @"AGXAssetPreviewCollectionViewDidScroll";

static NSString *const AGXAssetPreviewCollectionViewToggleBarsHiddenKey = @"AGXAssetPreviewCollectionViewToggleBarsHiddenKey";

static const CGFloat AGXAssetPreviewCellMargin = 20;
static const CGFloat AGXAssetPreviewCellProgressHeight = 8;
static const CGFloat AGXAssetPreviewToolbarHeight = 49;
static const CGFloat AGXAssetPreviewToolbarIPhoneXOffset = 34;
static const CGFloat AGXAssetPreviewToolbarMargin = 10;
static const CGSize  AGXAssetPreviewToolbarSwitchSize = (CGSize){.width = 30, .height = 22};
static const CGFloat AGXLivePhotoPlaybackMargin = 10;
static const CGFloat AGXVideoPlayButtonImageSize = 44;
static const CGFloat AGXVideoPlayButtonSize = 54;

@interface AGXAssetPreviewCollectionView : UICollectionView
@end

@interface AGXAssetPreviewCollectionViewCell : UICollectionViewCell
@property (nonatomic, AGX_STRONG)   AGXAssetModel *assetModel;
- (void)initialPreviewCell;
- (void)layoutPreviewCell;
- (void)cooperateWithGestureRecognizer:(UITapGestureRecognizer *)otherGestureRecognizer;
@end

@interface AGXPhotoPreviewCollectionViewCell : AGXAssetPreviewCollectionViewCell
@end

@interface AGXGifPreviewCollectionViewCell : AGXPhotoPreviewCollectionViewCell
@end

@interface AGXLivePhotoPreviewCollectionViewCell : AGXPhotoPreviewCollectionViewCell
@end

@interface AGXVideoPreviewCollectionViewCell : AGXAssetPreviewCollectionViewCell
@end

@interface AGXAssetPreviewController () <UICollectionViewDataSource, UICollectionViewDelegate>
@end

@implementation AGXAssetPreviewController {
    UIView *_contentView;
    UICollectionView *_collectionView;
    UIView *_toolBar;
    AGXSwitch *_originalSwitch;
    UIButton *_originalPhotoButton;
    UILabel *_originalPhotoLabel;
    UIButton *_doneButton;
    BOOL _toolBarHidden;
    UITapGestureRecognizer *_tapGestureRecognizer;
}

@dynamic delegate;

- (AGX_INSTANCETYPE)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if AGX_EXPECT_T(self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        self.extendedLayoutIncludesOpaqueBars = YES;
        _highlightColor = [AGXColor(@"4cd864") copy];
        _pickingImageSize = AGX_ScreenSize;

        _contentView = [[UIView alloc] init];
        _contentView.clipsToBounds = YES;

        _collectionView = [[AGXAssetPreviewCollectionView alloc] initWithFrame:
                           CGRectZero collectionViewLayout:[self calculatedLayoutBySize:AGX_ScreenSize]];
        _collectionView.backgroundColor = UIColor.blackColor;
        _collectionView.alwaysBounceHorizontal = YES;
        _collectionView.alwaysBounceVertical = NO;
        _collectionView.pagingEnabled = YES;
        _collectionView.scrollsToTop = NO;
        _collectionView.showsHorizontalScrollIndicator = NO;
        if (@available(iOS 11.0, *)) {
            _collectionView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        } else {
            _collectionView.automaticallyAdjustsContentInsetByBars = NO;
        }
        [_collectionView registerClass:AGXPhotoPreviewCollectionViewCell.class
            forCellWithReuseIdentifier:AGXPhotoPreviewCellReuseIdentifier];
        [_collectionView registerClass:AGXGifPreviewCollectionViewCell.class
            forCellWithReuseIdentifier:AGXGifPreviewCellReuseIdentifier];
        [_collectionView registerClass:AGXLivePhotoPreviewCollectionViewCell.class
            forCellWithReuseIdentifier:AGXLivePhotoPreviewCellReuseIdentifier];
        [_collectionView registerClass:AGXVideoPreviewCollectionViewCell.class
            forCellWithReuseIdentifier:AGXVideoPreviewCellReuseIdentifier];
        [_contentView addSubview:_collectionView];

        _toolBar = [[UIView alloc] initWithFrame:CGRectZero];
        _toolBar.backgroundColor = AGXColor(@"3f3f3faa");

        _originalSwitch = [[AGXSwitch alloc] init];
        _originalSwitch.onColor = _highlightColor;
        [_originalSwitch addTarget:self action:@selector(originalSwitch:)
                  forControlEvents:UIControlEventTouchUpInside];
        [_toolBar addSubview:_originalSwitch];
        _originalSwitch.hidden = !_allowPickingOriginal;

        _originalPhotoButton = [[UIButton alloc] init];
        _originalPhotoButton.backgroundColor = UIColor.clearColor;
        _originalPhotoButton.titleLabel.font = [UIFont systemFontOfSize:16];
        [_originalPhotoButton setTitleColor:_originalSwitch.offColor forState:UIControlStateNormal];
        [_originalPhotoButton setTitleColor:_highlightColor forState:UIControlStateSelected];
        [_originalPhotoButton setTitle:AGXWidgetLocalizedStringDefault
         (@"AGXPhotoPickerController.originalPhotoTitle", @"Original") forState:UIControlStateNormal];
        [_originalPhotoButton addTarget:self action:@selector(originalPhotoButtonClick:)
                       forControlEvents:UIControlEventTouchUpInside];
        [_toolBar addSubview:_originalPhotoButton];
        _originalPhotoButton.hidden = !_allowPickingOriginal;

        _originalPhotoLabel = [[UILabel alloc] init];
        _originalPhotoLabel.backgroundColor = UIColor.clearColor;
        _originalPhotoLabel.textColor = UIColor.whiteColor;
        _originalPhotoLabel.textAlignment = NSTextAlignmentLeft;
        _originalPhotoLabel.font = [UIFont systemFontOfSize:14];
        _originalPhotoLabel.hidden = !_originalPhotoButton.selected;
        [_toolBar addSubview:_originalPhotoLabel];

        _doneButton = [[UIButton alloc] init];
        _doneButton.backgroundColor = UIColor.clearColor;
        _doneButton.titleLabel.font = [UIFont systemFontOfSize:16];
        [_doneButton setTitleColor:_highlightColor forState:UIControlStateNormal];
        [_doneButton setTitle:AGXWidgetLocalizedStringDefault
         (@"AGXPhotoPickerController.doneButtonTitle", @"Done") forState:UIControlStateNormal];
        [_doneButton addTarget:self action:@selector(doneButtonClick:)
              forControlEvents:UIControlEventTouchUpInside];
        [_toolBar addSubview:_doneButton];

        _tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:
                                 self action:@selector(singleTap:)];
        [_contentView addGestureRecognizer:_tapGestureRecognizer];

        [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(toggleBarsHidden:) name:
         AGXAssetPreviewCollectionViewToggleBarsHiddenNotification object:nil];
    }
    return self;
}

- (void)dealloc {
    [NSNotificationCenter.defaultCenter removeObserver:self name:
     AGXAssetPreviewCollectionViewToggleBarsHiddenNotification object:nil];

    AGX_RELEASE(_assetModels);
    AGX_RELEASE(_highlightColor);
    AGX_RELEASE(_contentView);
    AGX_RELEASE(_collectionView);
    AGX_RELEASE(_toolBar);
    AGX_RELEASE(_originalSwitch);
    AGX_RELEASE(_originalPhotoButton);
    AGX_RELEASE(_originalPhotoLabel);
    AGX_RELEASE(_doneButton);
    AGX_RELEASE(_tapGestureRecognizer);
    AGX_SUPER_DEALLOC;
}

- (void)setAssetModels:(NSArray<AGXAssetModel *> *)assetModels {
    NSArray<AGXAssetModel *> *temp = AGX_RETAIN(assetModels);
    AGX_RELEASE(_assetModels);
    _assetModels = temp;

    [self updateIndexTitle];
}

- (void)setCurrentIndex:(NSInteger)currentIndex {
    _currentIndex = currentIndex;

    [self updateIndexTitle];
}

- (void)setHighlightColor:(UIColor *)highlightColor {
    UIColor *temp = [highlightColor copy];
    AGX_RELEASE(_highlightColor);
    _highlightColor = temp;

    _originalSwitch.onColor = _highlightColor;
    [_originalPhotoButton setTitleColor:_highlightColor forState:UIControlStateSelected];
    [_doneButton setTitleColor:_highlightColor forState:UIControlStateNormal];
}

- (void)setAllowPickingOriginal:(BOOL)allowPickingOriginal {
    _allowPickingOriginal = allowPickingOriginal;

    [self updateOriginalControls];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = UIColor.blackColor;

    [self.view addSubview:_contentView];
    _collectionView.dataSource = self;
    _collectionView.delegate = self;
    [self.view addSubview:_toolBar];

    [self updateIndexTitle];
    [self updateOriginalControls];
    agx_async_main
    ([_collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:_currentIndex inSection:0]
                             atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally animated:NO];);
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    _contentView.frame = self.view.bounds;

    CGSize contentSize = _contentView.bounds.size;
    _collectionView.frame = CGRectMake(-AGXAssetPreviewCellMargin/2, 0,
                                       contentSize.width+AGXAssetPreviewCellMargin, contentSize.height);
    _collectionView.collectionViewLayout = [self calculatedLayoutBySize:contentSize];

    CGFloat offset = AGX_IS_IPHONEX ? AGXAssetPreviewToolbarIPhoneXOffset : 0;
    _toolBar.frame = CGRectMake(0, self.view.bounds.size.height-AGXAssetPreviewToolbarHeight-offset,
                                self.view.bounds.size.width, AGXAssetPreviewToolbarHeight+offset);
    CGFloat xPosition = AGXAssetPreviewToolbarMargin;
    _originalSwitch.frame = AGX_CGRectMake
    (CGPointMake(xPosition, (AGXAssetPreviewToolbarHeight-AGXAssetPreviewToolbarSwitchSize.height)/2),
     AGXAssetPreviewToolbarSwitchSize);
    xPosition += AGXAssetPreviewToolbarMargin+AGXAssetPreviewToolbarSwitchSize.width;
    [_originalPhotoButton sizeToFit];
    _originalPhotoButton.frame = CGRectMake
    (xPosition, 0, _originalPhotoButton.bounds.size.width, AGXAssetPreviewToolbarHeight);
    xPosition += AGXAssetPreviewToolbarMargin+_originalPhotoButton.bounds.size.width;
    [_originalPhotoLabel sizeToFit];
    _originalPhotoLabel.frame = AGX_CGRectMake
    (CGPointMake(xPosition, (AGXAssetPreviewToolbarHeight-_originalPhotoLabel.bounds.size.height)/2),
     _originalPhotoLabel.bounds.size);
    [_doneButton sizeToFit];
    _doneButton.frame = CGRectMake(self.view.bounds.size.width-AGXAssetPreviewToolbarMargin-_doneButton.bounds.size.width,
                                   0, _doneButton.bounds.size.width, AGXAssetPreviewToolbarHeight);
}

#pragma mark - user event

- (void)originalSwitch:(id)sender {
    _originalPhotoButton.selected = _originalSwitch.on;

    [self updateOriginalPhotoLabel];
}

- (void)originalPhotoButtonClick:(id)sender {
    _originalPhotoButton.selected = !_originalPhotoButton.selected;
    [_originalSwitch setOn:_originalPhotoButton.selected animated:YES];

    [self updateOriginalPhotoLabel];
}

- (void)doneButtonClick:(id)sender {
    if (!_originalPhotoButton.selected) {
        [self pickingMediaWithAssetModel:_assetModels[_currentIndex] size:_pickingImageSize];
    } else {
        [self pickingOriginalImageWithAssetModel:_assetModels[_currentIndex]];
    }
}

- (void)singleTap:(UITapGestureRecognizer *)tapGestureRecognizer {
    _toolBarHidden = !_toolBarHidden;

    [NSNotificationCenter.defaultCenter postNotificationName:
     AGXAssetPreviewCollectionViewToggleBarsHiddenNotification object:nil userInfo:
     @{AGXAssetPreviewCollectionViewToggleBarsHiddenKey: @(_toolBarHidden)}];
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return _assetModels.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    AGXAssetModel *assetModel = _assetModels[indexPath.row];
    NSString *reuseIdentifier = (AGXAssetModelMediaTypeVideo==assetModel.mediaType ? AGXVideoPreviewCellReuseIdentifier :
                                 (AGXAssetModelMediaTypeGif==assetModel.mediaType ? AGXGifPreviewCellReuseIdentifier :
                                  (AGXAssetModelMediaTypeLivePhoto==assetModel.mediaType ? AGXLivePhotoPreviewCellReuseIdentifier :
                                   AGXPhotoPreviewCellReuseIdentifier)));
    AGXAssetPreviewCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:
                                               reuseIdentifier forIndexPath:indexPath];
    cell.assetModel = assetModel;
    [cell cooperateWithGestureRecognizer:_tapGestureRecognizer];
    return cell;
}

#pragma mark - UICollectionViewDelegate

- (void)collectionView:(UICollectionView *)collectionView willDisplayCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath {
    [(AGXAssetPreviewCollectionViewCell *)cell layoutPreviewCell];
}

- (void)collectionView:(UICollectionView *)collectionView didEndDisplayingCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath {
    [(AGXAssetPreviewCollectionViewCell *)cell layoutPreviewCell];
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    CGFloat viewWidth = self.view.bounds.size.width;
    CGFloat offSetWidth = scrollView.contentOffset.x;
    offSetWidth += (viewWidth+AGXAssetPreviewCellMargin)/2;
    NSInteger currentIndex = offSetWidth/(viewWidth+AGXAssetPreviewCellMargin);
    if (currentIndex < _assetModels.count && _currentIndex != currentIndex) {
        _currentIndex = currentIndex;
    }
    [self updateIndexTitle];
    [self updateOriginalControls];

    [NSNotificationCenter.defaultCenter postNotificationName:
     AGXAssetPreviewCollectionViewDidScrollNotification object:nil];
}

#pragma mark - private methods

- (UICollectionViewFlowLayout *)calculatedLayoutBySize:(CGSize)size {
    UICollectionViewFlowLayout *layout = UICollectionViewFlowLayout.instance;
    layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    layout.minimumInteritemSpacing = 0;
    layout.minimumLineSpacing = 0;
    layout.itemSize = CGSizeMake(size.width+AGXAssetPreviewCellMargin, size.height);
    return layout;
}

- (void)updateIndexTitle {
    NSString *title = [NSString stringWithFormat:@"%zd/%zd",
                       _currentIndex+1, _assetModels.count];
    self.navigationItem.title = title;
}

- (void)updateOriginalControls {
    BOOL currentMediaHasNoOriginal = (!_assetModels[_currentIndex] || AGXAssetModelMediaTypeVideo ==
                                      _assetModels[_currentIndex].mediaType);
    _originalSwitch.hidden = !_allowPickingOriginal || currentMediaHasNoOriginal;
    _originalSwitch.on = !_originalSwitch.hidden && _originalSwitch.on;
    _originalPhotoButton.hidden = !_allowPickingOriginal || currentMediaHasNoOriginal;
    _originalPhotoButton.selected = !_originalSwitch.hidden && _originalPhotoButton.selected;

    [self updateOriginalPhotoLabel];
}

- (void)updateOriginalPhotoLabel {
    BOOL currentMediaHasNoOriginal = (!_assetModels[_currentIndex] || AGXAssetModelMediaTypeVideo ==
                                      _assetModels[_currentIndex].mediaType);

    _originalPhotoLabel.hidden = !_originalPhotoButton.selected;
    if (!_originalPhotoLabel.hidden && !currentMediaHasNoOriginal) {
        [AGXPhotoManager.shareInstance bytesStringForAssetModel:_assetModels[_currentIndex] completion:
         ^(NSString *bytesString) {
             _originalPhotoLabel.text = bytesString;
             [_originalPhotoLabel sizeToFit];
             _originalPhotoLabel.frame = AGX_CGRectMake
             (CGPointMake(_originalPhotoLabel.frame.origin.x,
                          (AGXAssetPreviewToolbarHeight-_originalPhotoLabel.bounds.size.height)/2),
              _originalPhotoLabel.bounds.size);
         }];
    }
}

- (void)toggleBarsHidden:(NSNotification *)notification {
    BOOL hidden = [notification.userInfo[AGXAssetPreviewCollectionViewToggleBarsHiddenKey] boolValue];
    [self setStatusBarHidden:hidden animated:YES];
    [self setNavigationBarHidden:hidden animated:YES];
    if (hidden != _toolBar.hidden) {
        _toolBar.hidden = NO;
        [_toolBar agxAnimate:AGXAnimationMake
         (AGXAnimateFade|(hidden?AGXAnimateOut:AGXAnimateIn)
          |AGXAnimateNotReset, AGXAnimateStay, 0.2)
                  completion:^{ _toolBar.hidden = hidden; }];
    }
}

@end

@implementation AGXAssetPreviewCollectionView
- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
    BOOL should = [gestureRecognizer isKindOfClass:UIPanGestureRecognizer.class];
    if ([super respondsToSelector:@selector(gestureRecognizerShouldBegin:)]) {
        should = [super gestureRecognizerShouldBegin:gestureRecognizer];
    }
    return should && (cgfabs([gestureRecognizer locationInView:UIApplication.sharedKeyWindow].x)
                      /UIApplication.sharedKeyWindow.bounds.size.width > .1);
}
@end

@implementation AGXAssetPreviewCollectionViewCell

- (AGX_INSTANCETYPE)initWithFrame:(CGRect)frame {
    if AGX_EXPECT_T(self = [super initWithFrame:frame]) {
        self.backgroundColor = UIColor.clearColor;
        [self initialPreviewCell];
    }
    return self;
}

- (void)dealloc {
    AGX_RELEASE(_assetModel);
    AGX_SUPER_DEALLOC;
}

- (void)initialPreviewCell {}

- (void)layoutPreviewCell {}

- (void)cooperateWithGestureRecognizer:(UITapGestureRecognizer *)otherGestureRecognizer {}

@end

@interface AGXPhotoPreviewCollectionViewCell () <UIScrollViewDelegate>
@property (nonatomic, AGX_STRONG) UIImageView *imagePreviewView;
- (void)updatePreviewImage:(UIImage *)image;
@end
@implementation AGXPhotoPreviewCollectionViewCell {
    UIScrollView *_scrollView;
    UIView *_imageContainerView;
    AGXProgressBar *_progressBar;
    UITapGestureRecognizer *_doubleTapGestureRecognizer;

    NSString *_assetIdentifier;
    PHImageRequestID _imageRequestID;
}

- (void)initialPreviewCell {
    [super initialPreviewCell];

    _scrollView = [[UIScrollView alloc] init];
    _scrollView.bouncesZoom = YES;
    _scrollView.maximumZoomScale = 2.5;
    _scrollView.minimumZoomScale = 1.0;
    _scrollView.multipleTouchEnabled = YES;
    _scrollView.delegate = self;
    _scrollView.scrollsToTop = NO;
    _scrollView.showsHorizontalScrollIndicator = NO;
    _scrollView.showsVerticalScrollIndicator = YES;
    _scrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    _scrollView.delaysContentTouches = NO;
    _scrollView.canCancelContentTouches = YES;
    _scrollView.alwaysBounceVertical = NO;
    if (@available(iOS 11.0, *)) {
        _scrollView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    } else {
        _scrollView.automaticallyAdjustsContentInsetByBars = NO;
    }
    [self.contentView addSubview:_scrollView];

    _imageContainerView = [[UIView alloc] init];
    _imageContainerView.clipsToBounds = YES;
    _imageContainerView.contentMode = UIViewContentModeScaleAspectFill;
    [_scrollView addSubview:_imageContainerView];

    _imagePreviewView = [[UIImageView alloc] init];
    _imagePreviewView.backgroundColor = UIColor.clearColor;
    _imagePreviewView.clipsToBounds = YES;
    _imagePreviewView.contentMode = UIViewContentModeScaleAspectFill;
    [_imageContainerView addSubview:_imagePreviewView];

    _progressBar = [[AGXProgressBar alloc] init];
    _progressBar.progressColor = UIColor.lightGrayColor;
    _progressBar.fadeDelay = 1;
    [self.contentView addSubview:_progressBar];

    _doubleTapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:
                                   self action:@selector(doubleTap:)];
    _doubleTapGestureRecognizer.numberOfTapsRequired = 2;
    [self addGestureRecognizer:_doubleTapGestureRecognizer];
}

- (void)dealloc {
    AGX_RELEASE(_scrollView);
    AGX_RELEASE(_imageContainerView);
    AGX_RELEASE(_imagePreviewView);
    AGX_RELEASE(_progressBar);
    AGX_RELEASE(_doubleTapGestureRecognizer);
    AGX_RELEASE(_assetIdentifier);
    AGX_SUPER_DEALLOC;
}

- (void)setAssetModel:(AGXAssetModel *)assetModel {
    super.assetModel = assetModel;

    _scrollView.maximumZoomScale = ({
        CGSize screenSize = AGX_ScreenSize;
        PHAsset *asset = super.assetModel.asset;
        CGFloat assetRatio = (CGFloat)asset.pixelWidth/(CGFloat)asset.pixelHeight;

        BOOL fited = screenSize.width / assetRatio <= screenSize.height;
        CGFloat fitWidth = MIN(fited ? screenSize.width : screenSize.height*assetRatio,
                               asset.pixelWidth/UIScreen.mainScreen.scale);
        CGFloat fitHeight = MIN(fited ? screenSize.width/assetRatio : screenSize.height,
                                asset.pixelHeight/UIScreen.mainScreen.scale);

        BOOL filled = screenSize.width / assetRatio >= screenSize.height;
        CGFloat fillWidth = filled ? screenSize.width : screenSize.height*assetRatio;
        CGFloat fillHeight = filled ? screenSize.width/assetRatio : screenSize.height;

        MAX(2.5, MAX(fillWidth/fitWidth, fillHeight/fitHeight));
    });

    NSString *assetIdentifier = [super.assetModel.asset.localIdentifier copy];
    AGX_RELEASE(_assetIdentifier);
    _assetIdentifier = assetIdentifier;

    PHImageRequestID imageRequestID =
    [AGXPhotoManager.shareInstance imageForAsset:super.assetModel.asset size:AGX_ScreenSize completion:
     ^(UIImage *image, NSDictionary *info, BOOL isDegraded) {
         if ([_assetIdentifier isEqualToString:super.assetModel.asset.localIdentifier]) {
             [self updatePreviewImage:image];
         } else {
             [PHImageManager.defaultManager cancelImageRequest:_imageRequestID];
         }
         [_progressBar setProgress:1.0 animated:YES];
         if (!isDegraded) _imageRequestID = 0;
     } progressHandler:
     ^(double progress, NSError *error, BOOL *stop, NSDictionary *info) {
         [_progressBar setProgress:progress animated:YES];
         if (progress >= 1) _imageRequestID = 0;
     } networkAccessAllowed:YES];
    if (imageRequestID && _imageRequestID && imageRequestID != _imageRequestID) {
        [PHImageManager.defaultManager cancelImageRequest:_imageRequestID];
    }
    _imageRequestID = imageRequestID;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    CGFloat width = self.bounds.size.width, height = self.bounds.size.height;

    _scrollView.frame = CGRectMake(AGXAssetPreviewCellMargin/2, 0,
                                   width-AGXAssetPreviewCellMargin, height);
    [self refreshImageContainerViewCenter];
    _progressBar.frame = CGRectMake(width/4, (height-AGXAssetPreviewCellProgressHeight)/2,
                                    width/2, AGXAssetPreviewCellProgressHeight);
    _progressBar.cornerRadius = AGXAssetPreviewCellProgressHeight/2;
}

- (void)layoutPreviewCell {
    [super layoutPreviewCell];

    _scrollView.zoomScale = 1.0;
    [self resizeSubviews];
}

- (void)cooperateWithGestureRecognizer:(UITapGestureRecognizer *)otherGestureRecognizer {
    [super cooperateWithGestureRecognizer:otherGestureRecognizer];

    [otherGestureRecognizer requireGestureRecognizerToFail:_doubleTapGestureRecognizer];
}

- (void)updatePreviewImage:(UIImage *)image {
    _imagePreviewView.image = image;
    [self layoutPreviewCell];
}

#pragma mark - user event

- (void)doubleTap:(UITapGestureRecognizer *)tapGestureRecognizer {
    if (_scrollView.zoomScale > 1.0) {
        _scrollView.contentInset = UIEdgeInsetsZero;
        [_scrollView setZoomScale:1.0 animated:YES];
    } else {
        CGPoint touchPoint = [tapGestureRecognizer locationInView:_imagePreviewView];
        CGFloat xsize = _scrollView.bounds.size.width/_scrollView.maximumZoomScale;
        CGFloat ysize = _scrollView.bounds.size.height/_scrollView.maximumZoomScale;
        [_scrollView zoomToRect:CGRectMake(touchPoint.x-xsize/2, touchPoint.y-ysize/2,
                                           xsize, ysize) animated:YES];
    }
}

#pragma mark - UIScrollViewDelegate

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return _imageContainerView;
}

- (void)scrollViewWillBeginZooming:(UIScrollView *)scrollView withView:(UIView *)view {
    scrollView.contentInset = UIEdgeInsetsZero;
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView {
    [self refreshImageContainerViewCenter];
}

#pragma mark - private methods

- (void)resizeSubviews {
    CGRect scrollBounds = _scrollView.bounds;

    if (!_imagePreviewView.image) {
        _imageContainerView.frame = scrollBounds;
    } else {
        CGSize screenSize = AGX_ScreenSize;
        CGSize imageSize = _imagePreviewView.image.size;
        if (imageSize.width <= screenSize.width &&
            imageSize.height <= screenSize.height) {
            _imageContainerView.frame = CGRectMake((scrollBounds.size.width-imageSize.width)/2,
                                                   (scrollBounds.size.height-imageSize.height)/2,
                                                   imageSize.width, imageSize.height);
        } else {
            CGFloat imageRatio = imageSize.width/imageSize.height;
            BOOL fited = screenSize.width / imageRatio <= screenSize.height;
            CGFloat fitWidth = fited ? screenSize.width : screenSize.height*imageRatio;
            CGFloat fitHeight = fited ? screenSize.width/imageRatio : screenSize.height;
            _imageContainerView.frame = CGRectMake((scrollBounds.size.width-fitWidth)/2,
                                                   (scrollBounds.size.height-fitHeight)/2,
                                                   fitWidth, fitHeight);
        }
    }

    _scrollView.contentSize = _imageContainerView.bounds.size;
    [_scrollView scrollRectToVisible:scrollBounds animated:NO];
    _scrollView.alwaysBounceVertical =
    (_imageContainerView.bounds.size.height <= scrollBounds.size.height ? NO : YES);
    _imagePreviewView.frame = _imageContainerView.bounds;
}

- (void)refreshImageContainerViewCenter {
    CGSize scrollSize = _scrollView.bounds.size;
    CGFloat offsetX = (scrollSize.width > _scrollView.contentSize.width) ?
    ((scrollSize.width - _scrollView.contentSize.width) * 0.5) : 0.0;
    CGFloat offsetY = (scrollSize.height > _scrollView.contentSize.height) ?
    ((scrollSize.height - _scrollView.contentSize.height) * 0.5) : 0.0;
    _imageContainerView.center = CGPointMake(_scrollView.contentSize.width * 0.5 + offsetX,
                                             _scrollView.contentSize.height * 0.5 + offsetY);
}

@end

@implementation AGXGifPreviewCollectionViewCell

- (void)updatePreviewImage:(UIImage *)image {
    [super updatePreviewImage:image];

    [AGXPhotoManager.shareInstance originalImageDataForAsset:super.assetModel.asset completion:
     ^(NSData *data, NSDictionary *info, BOOL isDegraded) {
         self.imagePreviewView.image = [UIImage gifImageWithData:data scale:1];
         [self layoutPreviewCell];
     }];
}

@end

@interface AGXLivePhotoPreviewCollectionViewCell () <PHLivePhotoViewDelegate>
@end
@implementation AGXLivePhotoPreviewCollectionViewCell {
    PHLivePhotoView *_livePhotoView;
    UIImageView *_badgeImageView;
    UIButton *_playbackButton;
}

- (void)initialPreviewCell {
    [super initialPreviewCell];

    _livePhotoView = [[PHLivePhotoView alloc] init];
    _livePhotoView.contentMode = UIViewContentModeScaleAspectFill;
    _livePhotoView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    _livePhotoView.delegate = self;
    [self.imagePreviewView addSubview:_livePhotoView];

    _badgeImageView = [[UIImageView alloc] initWithImage:
                       [PHLivePhotoView livePhotoBadgeImageWithOptions:PHLivePhotoBadgeOptionsOverContent]];
    [self.imagePreviewView addSubview:_badgeImageView];

    _playbackButton = [[UIButton alloc] init];
    _playbackButton.backgroundColor = AGXColor(@"3f3f3faa");
    _playbackButton.titleLabel.font = [UIFont systemFontOfSize:16];
    [_playbackButton setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
    [_playbackButton setTitle:AGXWidgetLocalizedStringDefault
     (@"AGXPhotoPickerController.livePhotoPlaybackTitle", @"Click to playback")
                     forState:UIControlStateNormal];
    [_playbackButton addTarget:self action:@selector(playback:)
              forControlEvents:UIControlEventTouchUpInside];
    [self.contentView addSubview:_playbackButton];
}

- (void)dealloc {
    AGX_RELEASE(_livePhotoView);
    AGX_RELEASE(_badgeImageView);
    AGX_RELEASE(_playbackButton);
    AGX_SUPER_DEALLOC;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    CGFloat width = self.bounds.size.width, height = self.bounds.size.height;

    [_playbackButton sizeToFit];
    CGSize playbackSize = _playbackButton.bounds.size;
    _playbackButton.frame = CGRectMake((width-playbackSize.width-AGXLivePhotoPlaybackMargin*2)/2, height*3/4,
                                       playbackSize.width+AGXLivePhotoPlaybackMargin*2,
                                       playbackSize.height+AGXLivePhotoPlaybackMargin);
    _playbackButton.cornerRadius = AGXLivePhotoPlaybackMargin;
}

- (void)layoutPreviewCell {
    [super layoutPreviewCell];

    [_livePhotoView stopPlayback];
}

- (void)updatePreviewImage:(UIImage *)image {
    [super updatePreviewImage:image];

    [AGXPhotoManager.shareInstance originalLivePhotoForAsset:super.assetModel.asset completion:
     ^(PHLivePhoto *livePhoto, NSDictionary *info, BOOL isDegraded) {
         _livePhotoView.livePhoto = livePhoto;
         [self layoutPreviewCell];
     }];
}

#pragma mark - user event

- (void)playback:(id)sender {
    [_livePhotoView startPlaybackWithStyle:PHLivePhotoViewPlaybackStyleHint];
}

#pragma mark - PHLivePhotoViewDelegate

- (void)livePhotoView:(PHLivePhotoView *)livePhotoView willBeginPlaybackWithStyle:(PHLivePhotoViewPlaybackStyle)playbackStyle {
    _playbackButton.hidden = YES;
}

- (void)livePhotoView:(PHLivePhotoView *)livePhotoView didEndPlaybackWithStyle:(PHLivePhotoViewPlaybackStyle)playbackStyle {
    _playbackButton.hidden = NO;
}

@end

@implementation AGXVideoPreviewCollectionViewCell {
    AVPlayer *_player;
    AVPlayerLayer *_playerLayer;
    UIButton *_playButton;
    BOOL _needPlayback;
}

- (void)initialPreviewCell {
    [super initialPreviewCell];

    _player = [[AVPlayer alloc] initWithPlayerItem:nil];

    _playerLayer = AGX_RETAIN([AVPlayerLayer playerLayerWithPlayer:_player]);
    _playerLayer.backgroundColor = [UIColor blackColor].CGColor;
    [self.layer addSublayer:_playerLayer];

    _playButton = [[UIButton alloc] init];
    [_playButton setBackgroundColor:AGXColor(@"aaaaaaaa") forState:UIControlStateNormal];
    [_playButton setBackgroundColor:AGXColor(@"7f7f7faa") forState:UIControlStateHighlighted];
    [_playButton setImage:[UIImage imageRegularTriangleWithColor:UIColor.whiteColor edge:
                           AGXVideoPlayButtonImageSize direction:AGXDirectionEast]
                 forState:UIControlStateNormal];
    [_playButton setImage:[UIImage imageRegularTriangleWithColor:UIColor.lightGrayColor edge:
                           AGXVideoPlayButtonImageSize direction:AGXDirectionEast]
                 forState:UIControlStateHighlighted];
    [_playButton addTarget:self action:@selector(play:)
          forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:_playButton];

    [NSNotificationCenter.defaultCenter addObserver:self selector:
     @selector(pausePlayer) name:AVPlayerItemDidPlayToEndTimeNotification object:_player.currentItem];
    [NSNotificationCenter.defaultCenter addObserver:self selector:
     @selector(assetPreviewCollectionViewDidScroll:) name:
     AGXAssetPreviewCollectionViewDidScrollNotification object:nil];
}

- (void)dealloc {
    [NSNotificationCenter.defaultCenter removeObserver:self name:
     AGXAssetPreviewCollectionViewDidScrollNotification object:nil];
    [NSNotificationCenter.defaultCenter removeObserver:self name:
     AVPlayerItemDidPlayToEndTimeNotification object:_player.currentItem];

    AGX_RELEASE(_player);
    AGX_RELEASE(_playerLayer);
    AGX_RELEASE(_playButton);
    AGX_SUPER_DEALLOC;
}

- (void)setAssetModel:(AGXAssetModel *)assetModel {
    super.assetModel = assetModel;

    [AGXPhotoManager.shareInstance videoForAsset:super.assetModel.asset completion:
     ^(AVPlayerItem *playerItem, NSDictionary *info) { agx_async_main
         ([NSNotificationCenter.defaultCenter removeObserver:self name:
           AVPlayerItemDidPlayToEndTimeNotification object:_player.currentItem];

          [_player replaceCurrentItemWithPlayerItem:playerItem];

          [NSNotificationCenter.defaultCenter addObserver:self selector:
           @selector(pausePlayer) name:AVPlayerItemDidPlayToEndTimeNotification object:_player.currentItem];
          );}];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    CGFloat width = self.bounds.size.width, height = self.bounds.size.height;

    _playerLayer.frame = CGRectMake(AGXAssetPreviewCellMargin/2, 0,
                                    width-AGXAssetPreviewCellMargin, height);
    _playButton.frame = CGRectMake((width-AGXVideoPlayButtonSize)/2,
                                   (height-AGXVideoPlayButtonSize)/2,
                                    AGXVideoPlayButtonSize, AGXVideoPlayButtonSize);
    _playButton.cornerRadius = AGXVideoPlayButtonSize/2;
}

- (void)layoutPreviewCell {
    [super layoutPreviewCell];

    [self pausePlayer];
}

#pragma mark - user event

- (void)play:(id)sender {
    CMTime currentTime = _player.currentItem.currentTime;
    CMTime durationTime = _player.currentItem.duration;
    if (_player.rate == 0.0f) {
        if (currentTime.value == durationTime.value || _needPlayback) {
            [_player.currentItem seekToTime:CMTimeMake(0, 1)];
        }
        [_player play];
        [_playButton setBackgroundColor:UIColor.clearColor forState:UIControlStateNormal];
        [_playButton setBackgroundColor:UIColor.clearColor forState:UIControlStateHighlighted];
        [_playButton setImage:nil forState:UIControlStateNormal];
        [_playButton setImage:nil forState:UIControlStateHighlighted];

        [NSNotificationCenter.defaultCenter postNotificationName:
         AGXAssetPreviewCollectionViewToggleBarsHiddenNotification object:nil userInfo:
         @{AGXAssetPreviewCollectionViewToggleBarsHiddenKey: @(YES)}];

    } else {
        [self pausePlayer];
        _needPlayback = NO;
    }
}

- (void)assetPreviewCollectionViewDidScroll:(NSNotification *)notification {
    [self pausePlayer];
}

#pragma mark - private methods

- (void)pausePlayer {
    if (_player.rate != 0.0) { [_player pause]; }
    [_playButton setBackgroundColor:AGXColor(@"aaaaaaaa") forState:UIControlStateNormal];
    [_playButton setBackgroundColor:AGXColor(@"7f7f7faa") forState:UIControlStateHighlighted];
    [_playButton setImage:[UIImage imageRegularTriangleWithColor:UIColor.whiteColor edge:
                           AGXVideoPlayButtonImageSize direction:AGXDirectionEast]
                 forState:UIControlStateNormal];
    [_playButton setImage:[UIImage imageRegularTriangleWithColor:UIColor.lightGrayColor edge:
                           AGXVideoPlayButtonImageSize direction:AGXDirectionEast]
                 forState:UIControlStateHighlighted];
    _needPlayback = YES;

    [NSNotificationCenter.defaultCenter postNotificationName:
     AGXAssetPreviewCollectionViewToggleBarsHiddenNotification object:nil userInfo:
     @{AGXAssetPreviewCollectionViewToggleBarsHiddenKey: @(NO)}];
}

@end
