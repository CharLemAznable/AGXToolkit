//
//  AGXAssetPickerController.m
//  AGXWidget
//
//  Created by Char Aznable on 2018/1/19.
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
#import <AGXCore/AGXCore/AGXMath.h>
#import <AGXCore/AGXCore/AGXGeometry.h>
#import <AGXCore/AGXCore/UIView+AGXCore.h>
#import <AGXCore/AGXCore/UIImage+AGXCore.h>
#import <AGXCore/AGXCore/UIColor+AGXCore.h>
#import <AGXCore/AGXCore/UIViewController+AGXCore.h>
#import <AGXCore/AGXCore/UIScrollView+AGXCore.h>
#import "AGXAssetPickerController.h"
#import "AGXLine.h"
#import "AGXProgressHUD.h"
#import "AGXProgressBar.h"
#import "AGXPhotoManager.h"

static NSString *const AGXAssetCellReuseIdentifier = @"AGXAssetCellReuseIdentifier";

static const CGFloat AGXAssetCellMargin = 4;
static const CGFloat AGXAssetCellBottomMargin = 2;

@interface AGXAssetCollectionViewCell : UICollectionViewCell
@property (nonatomic, AGX_STRONG)   AGXAssetModel *assetModel;
@property (nonatomic, copy)         NSString *assetIdentifier;
@property (nonatomic, assign)       PHImageRequestID imageRequestID;
@property (nonatomic, assign)       CGSize imageRequestSize;
@end

@interface AGXAssetPickerController () <UICollectionViewDataSource, UICollectionViewDelegate>
@property (nonatomic, AGX_STRONG)   NSArray<AGXAssetModel *> *assetModels;
@property (nonatomic, readonly)     CGSize assetThumbSize; // auto calculate
@end

@implementation AGXAssetPickerController {
    UICollectionView *_collectionView;
}

@dynamic delegate;

- (AGX_INSTANCETYPE)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if AGX_EXPECT_T(self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        _columnNumber = 4;
        _assetModels = [[NSArray alloc] init];

        _collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero
                                             collectionViewLayout:[self calculatedLayout]];
        _collectionView.backgroundColor = UIColor.whiteColor;
        _collectionView.alwaysBounceHorizontal = NO;
        _collectionView.alwaysBounceVertical = YES;
        [_collectionView registerClass:AGXAssetCollectionViewCell.class
            forCellWithReuseIdentifier:AGXAssetCellReuseIdentifier];
    }
    return self;
}

- (void)dealloc {
    AGX_RELEASE(_albumModel);
    AGX_RELEASE(_assetModels);
    AGX_RELEASE(_collectionView);
    AGX_SUPER_DEALLOC;
}

- (void)setColumnNumber:(NSUInteger)columnNumber {
    if AGX_EXPECT_F(_columnNumber == columnNumber) return;
    _columnNumber = columnNumber;
    [_collectionView setCollectionViewLayout:[self calculatedLayout]];
    if (self.isViewVisible) [self reloadAssets];
}

- (BOOL)allowPickingVideo {
    return _albumModel.allowPickingVideo;
}

- (void)setAllowPickingVideo:(BOOL)allowPickingVideo {
    if AGX_EXPECT_F(_albumModel.allowPickingVideo == allowPickingVideo) return;
    _albumModel.allowPickingVideo = allowPickingVideo;
    if (self.isViewVisible) [self reloadAssets];
}

- (BOOL)sortByCreateDateDescending {
    return _albumModel.sortByCreateDateDescending;
}

- (void)setSortByCreateDateDescending:(BOOL)sortByCreateDateDescending {
    if AGX_EXPECT_F(_albumModel.sortByCreateDateDescending == sortByCreateDateDescending) return;
    _albumModel.sortByCreateDateDescending = sortByCreateDateDescending;
    if (self.isViewVisible) [self reloadAssets];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = _albumModel.name;
    self.navigationItem.title = _albumModel.name;

    self.view.backgroundColor = UIColor.whiteColor;
    [self.view addSubview:_collectionView];
    _collectionView.dataSource = self;
    _collectionView.delegate = self;

    [self reloadAssets];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    _collectionView.frame = self.view.bounds;
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return _assetModels.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    AGXAssetCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:
                                        AGXAssetCellReuseIdentifier forIndexPath:indexPath];
    cell.imageRequestSize = self.assetThumbSize;
    cell.assetModel = _assetModels[indexPath.row];
    return cell;
}

#pragma mark - UICollectionViewDelegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if ([self.delegate respondsToSelector:@selector(assetPickerController:didSelectAssetModel:)])
        [self.delegate assetPickerController:self didSelectAssetModel:_assetModels[indexPath.row]];
}

#pragma mark - private methods

- (UICollectionViewFlowLayout *)calculatedLayout {
    UICollectionViewFlowLayout *layout = UICollectionViewFlowLayout.instance;
    CGFloat cellWH = ((AGX_ScreenWidth-(_columnNumber-1)
                       *AGXAssetCellMargin)/_columnNumber);
    layout.itemSize = CGSizeMake(cellWH, cellWH);
    layout.minimumInteritemSpacing = AGXAssetCellMargin;
    layout.minimumLineSpacing = AGXAssetCellMargin;
    layout.sectionInset = UIEdgeInsetsMake
    (AGXAssetCellMargin, 0, AGXAssetCellMargin+cellWH, 0);

    CGFloat thumbWH = cellWH*AGXPhotoManager.assetImageScale;
    _assetThumbSize = CGSizeMake(thumbWH, thumbWH);

    return layout;
}

- (void)reloadAssets {
    [self.view showLoadingHUD:YES title:nil];
    agx_async_main
    (self.assetModels = [NSArray arrayWithArray:_albumModel.assetModels];
     [_collectionView reloadData];
     agx_async_main
     ([_collectionView scrollToBottom:NO];
      [self.view hideHUD];))
}

@end

@implementation AGXAssetCollectionViewCell {
    UIImageView *_imageView;
    UIView *_bottomView;
    UILabel *_bottomLabel;
}

- (AGX_INSTANCETYPE)initWithFrame:(CGRect)frame {
    if AGX_EXPECT_T(self = [super initWithFrame:frame]) {
        _imageView = [[UIImageView alloc] init];
        _imageView.contentMode = UIViewContentModeScaleAspectFill;
        _imageView.clipsToBounds = YES;
        [self.contentView addSubview:_imageView];

        _bottomView = [[UIView alloc] init];
        _bottomView.backgroundColor = AGXColor(@"000000aa");
        [self.contentView addSubview:_bottomView];

        _bottomLabel = [[UILabel alloc] init];
        _bottomLabel.font = [UIFont systemFontOfSize:12];
        _bottomLabel.textColor = UIColor.whiteColor;
        _bottomLabel.textAlignment = NSTextAlignmentRight;
        [_bottomView addSubview:_bottomLabel];
    }
    return self;
}

- (void)dealloc {
    AGX_RELEASE(_assetModel);
    AGX_RELEASE(_assetIdentifier);
    AGX_RELEASE(_imageView);
    AGX_RELEASE(_bottomView);
    AGX_RELEASE(_bottomLabel);
    AGX_SUPER_DEALLOC;
}

- (void)setAssetModel:(AGXAssetModel *)assetModel {
    AGXAssetModel *temp = AGX_RETAIN(assetModel);
    AGX_RELEASE(_assetModel);
    _assetModel = temp;

    self.assetIdentifier = _assetModel.asset.localIdentifier;
    PHImageRequestID imageRequestID =
    [AGXPhotoManager.shareInstance imageForAsset:_assetModel.asset size:_imageRequestSize completion:
     ^(UIImage *image, NSDictionary *info, BOOL isDegraded) {
         if ([_assetIdentifier isEqualToString:_assetModel.asset.localIdentifier]) {
             _imageView.image = image;
         } else {
             [PHImageManager.defaultManager cancelImageRequest:_imageRequestID];
         }
         if (!isDegraded) _imageRequestID = 0;
     } progressHandler:nil networkAccessAllowed:NO];
    if (imageRequestID && _imageRequestID && imageRequestID != _imageRequestID) {
        [PHImageManager.defaultManager cancelImageRequest:_imageRequestID];
    }
    _imageRequestID = imageRequestID;

    _bottomView.hidden = (AGXAssetModelMediaTypePhoto == _assetModel.mediaType);
    _bottomLabel.text = (AGXAssetModelMediaTypeVideo == _assetModel.mediaType ? _assetModel.timeLength :
                         (AGXAssetModelMediaTypeGif == _assetModel.mediaType ? @"GIF" :
                          (AGXAssetModelMediaTypeLivePhoto == _assetModel.mediaType ? @"LIVE" : @"")));

    [self setNeedsLayout];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    CGFloat width = self.bounds.size.width, height = self.bounds.size.height;

    _imageView.frame = self.bounds;
    CGFloat bottomHeight = cgceil(_bottomLabel.font.lineHeight)+AGXAssetCellBottomMargin*2;
    _bottomView.frame = CGRectMake(0, height-bottomHeight, width, bottomHeight);
    _bottomLabel.frame = CGRectMake(AGXAssetCellBottomMargin, AGXAssetCellBottomMargin,
                                    width-AGXAssetCellBottomMargin*2,
                                    bottomHeight-AGXAssetCellBottomMargin*2);
}

@end
