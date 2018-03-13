//
//  AGXPhotoPickerController.m
//  AGXWidget
//
//  Created by Char Aznable on 2018/3/9.
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

#import <AGXCore/AGXCore/AGXAdapt.h>
#import <AGXCore/AGXCore/NSObject+AGXCore.h>
#import <AGXCore/AGXCore/UIApplication+AGXCore.h>
#import <AGXCore/AGXCore/UIColor+AGXCore.h>
#import "AGXPhotoPickerController.h"
#import "AGXPhotoUnauthorizedController.h"
#import "AGXAlbumPickerController.h"
#import "AGXAssetPickerController.h"
#import "AGXAssetPreviewController.h"

@interface AGXPhotoPickerController () <AGXAlbumPickerControllerDelegate, AGXAssetPickerControllerDelegate, AGXAssetPreviewControllerDelegate>
@end

@implementation AGXPhotoPickerController

@dynamic delegate;

- (AGX_INSTANCETYPE)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if AGX_EXPECT_T(self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        _tintColor = [AGXColor(@"4cd864") copy];
        _columnNumber = 4;
        _allowAssetPreviewing = YES;
        _pickingImageSize = AGX_ScreenSize;
        _autoDismissViewController = YES;
        [self pushViewController:(AGXPhotoUtils.authorized?self.albumPickerController
                                  :self.unauthorizedController) animated:NO];
    }
    return self;
}

- (AGX_INSTANCETYPE)initWithNavigationBarClass:(Class)navigationBarClass toolbarClass:(Class)toolbarClass {
    [NSException raise:NSInvalidArgumentException format:
     @"*** - [%@ %@]: The %@ class should not be init by %@ method.",
     NSStringFromClass(self.class), NSStringFromSelector(_cmd),
     NSStringFromClass(self.class), NSStringFromSelector(_cmd)];
    return nil;
}

- (AGX_INSTANCETYPE)initWithRootViewController:(UIViewController *)rootViewController {
    [NSException raise:NSInvalidArgumentException format:
     @"*** - [%@ %@]: The %@ class should not be init by %@ method.",
     NSStringFromClass(self.class), NSStringFromSelector(_cmd),
     NSStringFromClass(self.class), NSStringFromSelector(_cmd)];
    return nil;
}

- (void)dealloc {
    _photoPickerDelegate = nil;
    AGX_RELEASE(_tintColor);
    AGX_SUPER_DEALLOC;
}

- (void)setTintColor:(UIColor *)tintColor {
    UIColor *temp = [tintColor copy];
    AGX_RELEASE(_tintColor);
    _tintColor = temp;

    [self enumerateViewControllersUsingBlock:^(UIViewController *viewController) {
        if ([viewController isKindOfClass:AGXPhotoUnauthorizedController.class]) {
            ((AGXPhotoUnauthorizedController *)viewController).settingButtonColor = _tintColor;
        } else if ([viewController isKindOfClass:AGXAssetPreviewController.class]) {
            ((AGXAssetPreviewController *)viewController).highlightColor = _tintColor;
        }
    }];
}

- (void)setColumnNumber:(NSUInteger)columnNumber {
    _columnNumber = columnNumber;

    [self enumerateViewControllersUsingBlock:^(UIViewController *viewController) {
        if ([viewController isKindOfClass:AGXAssetPickerController.class]) {
            ((AGXAssetPickerController *)viewController).columnNumber = _columnNumber;
        }
    }];
}

- (void)setAllowPickingVideo:(BOOL)allowPickingVideo {
    _allowPickingVideo = allowPickingVideo;

    [self enumerateViewControllersUsingBlock:^(UIViewController *viewController) {
        if ([viewController isKindOfClass:AGXAlbumPickerController.class]) {
            ((AGXAlbumPickerController *)viewController).allowPickingVideo = _allowPickingVideo;
        } else if ([viewController isKindOfClass:AGXAssetPickerController.class]) {
            ((AGXAssetPickerController *)viewController).allowPickingVideo = _allowPickingVideo;
        }
    }];
}

- (void)setAllowPickingGif:(BOOL)allowPickingGif {
    _allowPickingGif = allowPickingGif;

    [self enumerateViewControllersUsingBlock:^(UIViewController *viewController) {
        if ([viewController isKindOfClass:AGXAlbumPickerController.class]) {
            ((AGXAlbumPickerController *)viewController).allowPickingGif = _allowPickingGif;
        } else if ([viewController isKindOfClass:AGXAssetPickerController.class]) {
            ((AGXAssetPickerController *)viewController).allowPickingGif = _allowPickingGif;
        }
    }];
}

- (void)setAllowPickingLivePhoto:(BOOL)allowPickingLivePhoto {
    _allowPickingLivePhoto = allowPickingLivePhoto;

    [self enumerateViewControllersUsingBlock:^(UIViewController *viewController) {
        if ([viewController isKindOfClass:AGXAlbumPickerController.class]) {
            ((AGXAlbumPickerController *)viewController).allowPickingLivePhoto = _allowPickingLivePhoto;
        } else if ([viewController isKindOfClass:AGXAssetPickerController.class]) {
            ((AGXAssetPickerController *)viewController).allowPickingLivePhoto = _allowPickingLivePhoto;
        }
    }];
}

- (void)setSortByCreateDateDescending:(BOOL)sortByCreateDateDescending {
    _sortByCreateDateDescending = sortByCreateDateDescending;

    [self enumerateViewControllersUsingBlock:^(UIViewController *viewController) {
        if ([viewController isKindOfClass:AGXAlbumPickerController.class]) {
            ((AGXAlbumPickerController *)viewController).sortByCreateDateDescending = _sortByCreateDateDescending;
        } else if ([viewController isKindOfClass:AGXAssetPickerController.class]) {
            ((AGXAssetPickerController *)viewController).sortByCreateDateDescending = _sortByCreateDateDescending;
        }
    }];
}

- (void)setAllowAssetPreviewing:(BOOL)allowAssetPreviewing {
    _allowAssetPreviewing = allowAssetPreviewing;

    [self enumerateViewControllersUsingBlock:^(UIViewController *viewController) {
        if ([viewController isKindOfClass:AGXAssetPickerController.class]) {
            ((AGXAssetPickerController *)viewController).allowAssetPreviewing = _allowAssetPreviewing;
        }
    }];
}

- (void)setAllowPickingOriginal:(BOOL)allowPickingOriginal {
    _allowPickingOriginal = allowPickingOriginal;

    [self enumerateViewControllersUsingBlock:^(UIViewController *viewController) {
        if ([viewController isKindOfClass:AGXAssetPreviewController.class]) {
            ((AGXAssetPreviewController *)viewController).allowPickingOriginal = _allowPickingOriginal;
        }
    }];
}

- (void)setPickingImageSize:(CGSize)pickingImageSize {
    _pickingImageSize = pickingImageSize;

    [self enumerateViewControllersUsingBlock:^(UIViewController *viewController) {
        if ([viewController isKindOfClass:AGXAssetPickerController.class]) {
            ((AGXAssetPickerController *)viewController).pickingImageSize = _pickingImageSize;
        } else if ([viewController isKindOfClass:AGXAssetPreviewController.class]) {
            ((AGXAssetPreviewController *)viewController).pickingImageSize = _pickingImageSize;
        }
    }];
}

- (void)presentAnimated:(BOOL)animated completion:(void (^)(void))completion {
    [UIApplication.sharedRootViewController presentViewController:self animated:animated completion:completion];
}

#pragma mark - AGXPhotoPickerSubControllerDelegate

- (void)pickerSubControllerDidCancel:(AGXPhotoPickerSubController *)pickerSubController {
    BOOL isUnauthorizedController = [pickerSubController isKindOfClass:AGXPhotoUnauthorizedController.class];
    if (_autoDismissViewController || isUnauthorizedController) [self dismissViewControllerAnimated:YES completion:NULL];
    if (isUnauthorizedController) return;

    if ([self.photoPickerDelegate respondsToSelector:@selector(photoPickerControllerDidCancel:)])
        [self.photoPickerDelegate photoPickerControllerDidCancel:self];
}

- (void)pickerSubController:(AGXPhotoPickerSubController *)pickerSubController didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info {
    if (_autoDismissViewController) [self dismissViewControllerAnimated:YES completion:NULL];

    if ([self.photoPickerDelegate respondsToSelector:@selector(photoPickerController:didFinishPickingMediaWithInfo:)])
        [self.photoPickerDelegate photoPickerController:self didFinishPickingMediaWithInfo:info];
}

#pragma mark - AGXAlbumPickerControllerDelegate

- (void)albumPickerController:(AGXAlbumPickerController *)albumPicker didSelectAlbumModel:(AGXAlbumModel *)albumModel {
    [self pushViewController:[self assetPickerControllerWithAlbumModel:albumModel] animated:YES];
}

#pragma mark - AGXAssetPickerControllerDelegate

- (void)assetPickerController:(AGXAssetPickerController *)assetPicker didSelectIndex:(NSInteger)index inAssetModels:(NSArray<AGXAssetModel *> *)assetModels {
    [self pushViewController:[self assetPreviewControllerWithCurrentIndex:index inAssetModels:assetModels] animated:YES];
}

#pragma mark - AGXAssetPreviewControllerDelegate

#pragma mark - private methods

- (AGXPhotoUnauthorizedController *)unauthorizedController {
    AGXPhotoUnauthorizedController *unauthorizedController = AGXPhotoUnauthorizedController.instance;
    unauthorizedController.delegate = self;
    unauthorizedController.settingButtonColor = _tintColor;
    return unauthorizedController;
}

- (AGXAlbumPickerController *)albumPickerController {
    AGXAlbumPickerController *albumPickerController = AGXAlbumPickerController.instance;
    albumPickerController.delegate = self;
    albumPickerController.allowPickingVideo = _allowPickingVideo;
    albumPickerController.allowPickingGif = _allowPickingGif;
    albumPickerController.allowPickingLivePhoto = _allowPickingLivePhoto;
    albumPickerController.sortByCreateDateDescending = _sortByCreateDateDescending;
    return albumPickerController;
}

- (AGXAssetPickerController *)assetPickerControllerWithAlbumModel:(AGXAlbumModel *)albumModel {
    AGXAssetPickerController *assetPickerController = AGXAssetPickerController.instance;
    assetPickerController.delegate = self;
    assetPickerController.albumModel = albumModel;
    assetPickerController.columnNumber = _columnNumber;
    assetPickerController.allowPickingVideo = _allowPickingVideo;
    assetPickerController.allowPickingGif = _allowPickingGif;
    assetPickerController.allowPickingLivePhoto = _allowPickingLivePhoto;
    assetPickerController.sortByCreateDateDescending = _sortByCreateDateDescending;
    assetPickerController.allowAssetPreviewing = _allowAssetPreviewing;
    assetPickerController.pickingImageSize = _pickingImageSize;
    return assetPickerController;
}

- (AGXAssetPreviewController *)assetPreviewControllerWithCurrentIndex:(NSInteger)currentIndex inAssetModels:(NSArray<AGXAssetModel *> *)assetModels {
    AGXAssetPreviewController *assetPreviewController = AGXAssetPreviewController.instance;
    assetPreviewController.delegate = self;
    assetPreviewController.currentIndex = currentIndex;
    assetPreviewController.assetModels = assetModels;
    assetPreviewController.highlightColor = _tintColor;
    assetPreviewController.allowPickingOriginal = _allowPickingOriginal;
    assetPreviewController.pickingImageSize = _pickingImageSize;
    return assetPreviewController;
}

- (void)enumerateViewControllersUsingBlock:(void (^)(UIViewController *viewController))block {
    [self.viewControllers enumerateObjectsUsingBlock:
     ^(__kindof UIViewController *viewController, NSUInteger idx, BOOL *stop)
     { !block?:block(viewController); }];
}

@end
