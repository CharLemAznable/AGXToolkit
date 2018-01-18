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
#import "AGXAlbumPickerController.h"
#import "AGXWidgetLocalization.h"
#import "AGXLine.h"
#import "AGXPhotoManager.h"

static NSString *const AGXAlbumPickerCellReuseIdentifier = @"AGXAlbumPickerCell";

static const CGFloat AGXAlbumPickerCellHeight = 68;
static const CGFloat AGXAlbumPickerCellCoverImageSize = 60;
static const CGFloat AGXAlbumPickerCellSelectedCountSize = 24;
static const CGFloat AGXAlbumPickerCellSelectedMargin = 36;

@interface AGXAlbumPickerCell : UITableViewCell
@property (nonatomic, copy) UIColor *selectedCountColor; // default 4cd864

- (void)setWithAlbumModel:(AGXAlbumModel *)albumModel;
@end

@interface AGXAlbumPickerController () <UITableViewDataSource, UITableViewDelegate>
@property (nonatomic, strong) NSArray *albums;
@end

@implementation AGXAlbumPickerController {
    UITableView *_tableView;
}

- (AGX_INSTANCETYPE)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if AGX_EXPECT_T(self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        _selectedCountColor = [AGXColor(@"4cd864") copy];
    }
    return self;
}

- (void)dealloc {
    _dataSource = nil;
    _delegate = nil;
    AGX_RELEASE(_selectedCountColor);
    AGX_RELEASE(_albums);
    AGX_RELEASE(_tableView);
    AGX_SUPER_DEALLOC;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:AGXWidgetLocalizedStringDefault
                                             (@"AGXPhotoPickerController.cancelButtonTitle",
                                              @"Cancel") style:UIBarButtonItemStylePlain target:self action:@selector(cancelButtonClick:)];

    _tableView = [[UITableView alloc] init];
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    _tableView.tableHeaderView = AGX_AUTORELEASE([[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, AGX_SinglePixel)]);
    _tableView.tableHeaderView.backgroundColor = [UIColor lightGrayColor];
    _tableView.tableFooterView = UIView.instance;
    _tableView.dataSource = self;
    _tableView.delegate = self;
    [_tableView registerClass:[AGXAlbumPickerCell class]
       forCellReuseIdentifier:AGXAlbumPickerCellReuseIdentifier];
    [self.view addSubview:_tableView];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];

    NSString *title =  AGXWidgetLocalizedStringDefault
    (@"AGXPhotoPickerController.albumTitle", @"Photos");
    self.title = title;
    self.navigationItem.title = title;

    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        BOOL allowPickingVideo = NO;
        if ([self.dataSource respondsToSelector:@selector(albumPickerControllerAllowPickingVideo:)]) {
            allowPickingVideo = [self.dataSource albumPickerControllerAllowPickingVideo:self];
        }
        BOOL sortByCreateDateDescending = NO;
        if ([self.dataSource respondsToSelector:@selector(albumPickerControllerSortByCreateDateDescending:)]) {
            sortByCreateDateDescending = [self.dataSource albumPickerControllerSortByCreateDateDescending:self];
        }
        self.albums = [AGXPhotoManager.shareInstance allAlbumsAllowPickingVideo:allowPickingVideo sortByCreateDateDescending:sortByCreateDateDescending];

        NSArray<AGXAssetModel *> *selectedModels = NSArray.instance;
        if ([self.dataSource respondsToSelector:@selector(albumPickerControllerSelectedModels:)]) {
            selectedModels = [NSArray arrayWithArray:[self.dataSource albumPickerControllerSelectedModels:self]];
        }

        for (AGXAlbumModel *albumModel in self.albums) {
            albumModel.selectedModels = selectedModels;
        }
        agx_async_main([_tableView reloadData];)
    });
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    _tableView.frame = self.view.bounds;
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _albums.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    AGXAlbumPickerCell *cell = [tableView dequeueReusableCellWithIdentifier:AGXAlbumPickerCellReuseIdentifier
                                                               forIndexPath:indexPath];
    cell.selectedCountColor = self.selectedCountColor;
    [cell setWithAlbumModel:_albums[indexPath.row]];
    return cell;
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return AGXAlbumPickerCellHeight;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([self.delegate respondsToSelector:@selector(albumPickerController:didSelectAlbumModel:)])
        [self.delegate albumPickerController:self didSelectAlbumModel:_albums[indexPath.row]];
}

#pragma mark - user event

- (void)cancelButtonClick:(id)sender {
    if ([self.delegate respondsToSelector:@selector(albumPickerControllerDidCancel:)])
        [self.delegate albumPickerControllerDidCancel:self];
}

@end

@implementation AGXAlbumPickerCell {
    UIImageView *_coverImageView;
    UILabel *_titleLabel;
    UILabel *_selectedCountLabel;
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

        _selectedCountLabel = [[UILabel alloc] init];
        _selectedCountLabel.backgroundColor = AGXColor(@"4cd864");
        _selectedCountLabel.font = [UIFont boldSystemFontOfSize:14];
        _selectedCountLabel.textColor = [UIColor whiteColor];
        _selectedCountLabel.textAlignment = NSTextAlignmentCenter;
        _selectedCountLabel.cornerRadius = AGXAlbumPickerCellSelectedCountSize/2;
        [self addSubview:_selectedCountLabel];

        _bottomLine = [[AGXLine alloc] init];
        _bottomLine.lineColor = [UIColor lightGrayColor];
        [self addSubview:_bottomLine];
    }
    return self;
}

- (void)dealloc {
    AGX_RELEASE(_coverImageView);
    AGX_RELEASE(_titleLabel);
    AGX_RELEASE(_selectedCountLabel);
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
    CGFloat selectedCountX = AGXAlbumPickerCellSelectedCountSize+AGXAlbumPickerCellSelectedMargin;
    _titleLabel.frame = CGRectMake(coverImageWidth, (height-titleLabelHeight)/2,
                                   width-coverImageWidth-selectedCountX, titleLabelHeight);
    _selectedCountLabel.frame = CGRectMake(width-selectedCountX, (height-AGXAlbumPickerCellSelectedCountSize)/2,
                                           AGXAlbumPickerCellSelectedCountSize, AGXAlbumPickerCellSelectedCountSize);
    _bottomLine.frame = CGRectMake(0, height-AGX_SinglePixel, width, AGX_SinglePixel);
}

- (UIColor *)selectedCountColor {
    return _selectedCountLabel.backgroundColor;
}

- (void)setSelectedCountColor:(UIColor *)selectedCountColor {
    _selectedCountLabel.backgroundColor = selectedCountColor;
    [self setNeedsLayout];
}

#pragma mark - public methods

- (void)setWithAlbumModel:(AGXAlbumModel *)albumModel {
    NSMutableAttributedString *nameString = [NSMutableAttributedString attrStringWithString:albumModel.name attributes:
                                             @{NSFontAttributeName : [UIFont systemFontOfSize:16],
                                               NSForegroundColorAttributeName : [UIColor blackColor]}];
    NSAttributedString *countString = [NSAttributedString attrStringWithString:
                                       [NSString stringWithFormat:@"  (%zd)", albumModel.count] attributes:
                                       @{NSFontAttributeName : [UIFont systemFontOfSize:16],
                                         NSForegroundColorAttributeName : [UIColor lightGrayColor]}];
    [nameString appendAttributedString:countString];
    _titleLabel.attributedText = nameString;
    [AGXPhotoManager.shareInstance coverImageForAlbum:albumModel width:
     AGXAlbumPickerCellCoverImageSize completion:^(UIImage *image) { _coverImageView.image = image; }];
    if (albumModel.selectedCount) {
        _selectedCountLabel.hidden = NO;
        _selectedCountLabel.text = [NSString stringWithFormat:@"%zd", albumModel.selectedCount];
    } else {
        _selectedCountLabel.hidden = YES;
    }
    [self setNeedsLayout];
}

@end
