//
//  AGXAlbumPickerController.m
//  AGXWidget
//
//  Created by Char Aznable on 2018/1/17.
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
#import <AGXCore/AGXCore/NSObject+AGXCore.h>
#import <AGXCore/AGXCore/NSAttributedString+AGXCore.h>
#import <AGXCore/AGXCore/UIView+AGXCore.h>
#import <AGXCore/AGXCore/UIColor+AGXCore.h>
#import <AGXCore/AGXCore/UIViewController+AGXCore.h>
#import "AGXAlbumPickerController.h"
#import "AGXWidgetLocalization.h"
#import "AGXLine.h"
#import "AGXPhotoManager.h"

static NSString *const AGXAlbumPickerCellReuseIdentifier = @"AGXAlbumPickerCell";

static const CGFloat AGXAlbumPickerCellHeight = 68;
static const CGFloat AGXAlbumPickerCellCoverImageSize = 60;
static const CGFloat AGXAlbumPickerCellAccessoryMargin = 36;

@interface AGXAlbumPickerCell : UITableViewCell
- (void)setWithAlbumModel:(AGXAlbumModel *)albumModel;
@end

@interface AGXAlbumPickerController () <UITableViewDataSource, UITableViewDelegate>
@property (nonatomic, AGX_STRONG) NSArray<AGXAlbumModel *> *albumModels;
@end

@implementation AGXAlbumPickerController {
    UITableView *_tableView;
}

@dynamic delegate;

- (AGX_INSTANCETYPE)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if AGX_EXPECT_T(self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        _tableView = [[UITableView alloc] init];
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _tableView.tableHeaderView = AGX_AUTORELEASE([[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, AGX_SinglePixel)]);
        _tableView.tableHeaderView.backgroundColor = [UIColor lightGrayColor];
        _tableView.tableFooterView = UIView.instance;
        [_tableView registerClass:[AGXAlbumPickerCell class]
           forCellReuseIdentifier:AGXAlbumPickerCellReuseIdentifier];
    }
    return self;
}

- (void)dealloc {
    AGX_RELEASE(_albumModels);
    AGX_RELEASE(_tableView);
    AGX_SUPER_DEALLOC;
}

- (void)setAllowPickingVideo:(BOOL)allowPickingVideo {
    _allowPickingVideo = allowPickingVideo;
    [self reloadAlbums];
}

- (void)setSortByCreateDateDescending:(BOOL)sortByCreateDateDescending {
    _sortByCreateDateDescending = sortByCreateDateDescending;
    [self reloadAlbums];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    _tableView.dataSource = self;
    _tableView.delegate = self;
    [self.view addSubview:_tableView];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];

    NSString *title =  AGXWidgetLocalizedStringDefault
    (@"AGXPhotoPickerController.albumTitle", @"Photos");
    self.title = title;
    self.navigationItem.title = title;

    [self reloadAlbums];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    _tableView.frame = self.view.bounds;
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _albumModels.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    AGXAlbumPickerCell *cell = [tableView dequeueReusableCellWithIdentifier:AGXAlbumPickerCellReuseIdentifier
                                                               forIndexPath:indexPath];
    [cell setWithAlbumModel:_albumModels[indexPath.row]];
    return cell;
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return AGXAlbumPickerCellHeight;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([self.delegate respondsToSelector:@selector(albumPickerController:didSelectAlbumModel:)])
        [self.delegate albumPickerController:self didSelectAlbumModel:_albumModels[indexPath.row]];
}

#pragma mark - private methods

- (void)reloadAlbums {
    if (!self.isViewVisible) return;

    agx_async_main
    (self.albumModels = [AGXPhotoManager.shareInstance allAlbumModelsAllowPickingVideo:
                         _allowPickingVideo sortByCreateDateDescending:_sortByCreateDateDescending];
     [_tableView reloadData];)
}

@end

@implementation AGXAlbumPickerCell {
    UIImageView *_coverImageView;
    UILabel *_titleLabel;
    AGXLine *_bottomLine;
}

- (AGX_INSTANCETYPE)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if AGX_EXPECT_T(self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;

        _coverImageView = [[UIImageView alloc] init];
        _coverImageView.contentMode = UIViewContentModeScaleAspectFill;
        _coverImageView.clipsToBounds = YES;
        [self addSubview:_coverImageView];

        _titleLabel = [[UILabel alloc] init];
        _titleLabel.font = [UIFont boldSystemFontOfSize:16];
        _titleLabel.textColor = [UIColor blackColor];
        _titleLabel.textAlignment = NSTextAlignmentLeft;
        [self addSubview:_titleLabel];

        _bottomLine = [[AGXLine alloc] init];
        _bottomLine.lineColor = [UIColor lightGrayColor];
        [self addSubview:_bottomLine];
    }
    return self;
}

- (void)dealloc {
    AGX_RELEASE(_coverImageView);
    AGX_RELEASE(_titleLabel);
    AGX_RELEASE(_bottomLine);
    AGX_SUPER_DEALLOC;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    CGFloat width = self.bounds.size.width, height = self.bounds.size.height;

    CGFloat coverImageMargin = (height-AGXAlbumPickerCellCoverImageSize)/2;
    _coverImageView.frame = CGRectMake(coverImageMargin, coverImageMargin,
                                       AGXAlbumPickerCellCoverImageSize, AGXAlbumPickerCellCoverImageSize);
    CGFloat coverImageWidth = height+coverImageMargin;
    CGFloat titleLabelHeight = cgceil(_titleLabel.font.lineHeight);
    _titleLabel.frame = CGRectMake(coverImageWidth, (height-titleLabelHeight)/2,
                                   width-coverImageWidth-AGXAlbumPickerCellAccessoryMargin,
                                   titleLabelHeight);
    _bottomLine.frame = CGRectMake(0, height-AGX_SinglePixel, width, AGX_SinglePixel);
}

#pragma mark - public methods

- (void)setWithAlbumModel:(AGXAlbumModel *)albumModel {
    [AGXPhotoManager.shareInstance coverImageForAlbumModel:albumModel width:
     AGXAlbumPickerCellCoverImageSize completion:^(UIImage *image) { _coverImageView.image = image; }];
    NSMutableAttributedString *nameString = [NSMutableAttributedString attrStringWithString:albumModel.name attributes:
                                             @{NSFontAttributeName : [UIFont systemFontOfSize:16],
                                               NSForegroundColorAttributeName : [UIColor blackColor]}];
    NSAttributedString *countString = [NSAttributedString attrStringWithString:
                                       [NSString stringWithFormat:@"  (%zd)", albumModel.count] attributes:
                                       @{NSFontAttributeName : [UIFont systemFontOfSize:16],
                                         NSForegroundColorAttributeName : [UIColor lightGrayColor]}];
    [nameString appendAttributedString:countString];
    _titleLabel.attributedText = nameString;
    [self setNeedsLayout];
}

@end
