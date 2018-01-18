//
//  AGXPhotoModel.m
//  AGXWidget
//
//  Created by Char Aznable on 2018/1/16.
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

#import <AGXCore/AGXCore/NSObject+AGXCore.h>
#import "AGXPhotoModel.h"
#import "AGXPhotoManager.h"

@implementation AGXAlbumModel {
    NSString *_name;
}

+ (AGX_INSTANCETYPE)albumModelWithName:(NSString *)name fetchResultAssets:(PHFetchResult<PHAsset *> *)result allowPickingVideo:(BOOL)allowPickingVideo sortByCreateDateDescending:(BOOL)sortByCreateDateDescending {
    return AGX_AUTORELEASE([[self alloc] initWithName:name fetchResultAssets:result
                                    allowPickingVideo:allowPickingVideo
                           sortByCreateDateDescending:sortByCreateDateDescending]);
}

- (AGX_INSTANCETYPE)initWithName:(NSString *)name fetchResultAssets:(PHFetchResult<PHAsset *> *)result allowPickingVideo:(BOOL)allowPickingVideo sortByCreateDateDescending:(BOOL)sortByCreateDateDescending {
    if AGX_EXPECT_T(self = [super init]) {
        _name = [name copy];
        _result = AGX_RETAIN(result);
        _allowPickingVideo = allowPickingVideo;
        _sortByCreateDateDescending = sortByCreateDateDescending;
        _models = AGX_RETAIN([AGXPhotoManager.shareInstance
                              allAssetsFromFetchResult:_result
                              allowPickingVideo:_allowPickingVideo]);
    }
    return self;
}

- (void)dealloc {
    AGX_RELEASE(_name);
    AGX_RELEASE(_result);
    AGX_RELEASE(_models);
    AGX_RELEASE(_selectedModels);
    AGX_SUPER_DEALLOC;
}

- (NSString *)name {
    return _name ?: @"";
}

- (NSInteger)count {
    return _result.count;
}

- (void)setSelectedModels:(NSArray<AGXAssetModel *> *)selectedModels {
    NSArray *temp = AGX_RETAIN(selectedModels);
    AGX_RELEASE(_selectedModels);
    _selectedModels = temp;

    _selectedCount = 0;
    NSMutableArray *selectedAssets = NSMutableArray.instance;
    for (AGXAssetModel *assetModel in _selectedModels) {
        [selectedAssets addObject:assetModel.asset];
    }
    for (AGXAssetModel *assetModel in _models) {
        if ([selectedAssets containsObject:assetModel.asset]) {
            _selectedCount++;
        }
    }
}

@end

@implementation AGXAssetModel

+ (AGX_INSTANCETYPE)assetModelWithAsset:(PHAsset *)asset mediaType:(AGXAssetModelMediaType)mediaType {
    return AGX_AUTORELEASE([[self alloc] initWithAsset:asset mediaType:mediaType]);
}

+ (AGX_INSTANCETYPE)assetModelWithAsset:(PHAsset *)asset mediaType:(AGXAssetModelMediaType)mediaType timeLength:(NSString *)timeLength {
    return AGX_AUTORELEASE([[self alloc] initWithAsset:asset mediaType:mediaType timeLength:timeLength]);
}

- (AGX_INSTANCETYPE)initWithAsset:(PHAsset *)asset mediaType:(AGXAssetModelMediaType)mediaType {
    return [self initWithAsset:asset mediaType:mediaType timeLength:nil];
}

- (AGX_INSTANCETYPE)initWithAsset:(PHAsset *)asset mediaType:(AGXAssetModelMediaType)mediaType timeLength:(NSString *)timeLength {
    if AGX_EXPECT_T(self = [super init]) {
        _asset = AGX_RETAIN(asset);
        _mediaType = mediaType;
        _timeLength = [timeLength copy];
    }
    return self;
}

- (void)dealloc {
    AGX_RELEASE(_asset);
    AGX_RELEASE(_timeLength);
    AGX_SUPER_DEALLOC;
}

@end
