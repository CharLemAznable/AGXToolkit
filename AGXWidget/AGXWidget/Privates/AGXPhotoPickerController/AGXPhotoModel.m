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

#import <AGXCore/AGXCore/AGXAdapt.h>
#import <AGXCore/AGXCore/NSObject+AGXCore.h>
#import "AGXPhotoModel.h"
#import "AGXPhotoManager.h"

@implementation AGXAlbumModel {
    PHFetchResult<PHAsset *> *_assets;
    NSArray<AGXAssetModel *> *_assetModels;
}

+ (AGX_INSTANCETYPE)albumModelWithCollection:(PHAssetCollection *)collection allowPickingVideo:(BOOL)allowPickingVideo sortByCreateDateDescending:(BOOL)sortByCreateDateDescending {
    return AGX_AUTORELEASE([[self alloc] initWithCollection:collection
                                    allowPickingVideo:allowPickingVideo
                           sortByCreateDateDescending:sortByCreateDateDescending]);
}

- (AGX_INSTANCETYPE)initWithCollection:(PHAssetCollection *)collection allowPickingVideo:(BOOL)allowPickingVideo sortByCreateDateDescending:(BOOL)sortByCreateDateDescending {
    if AGX_EXPECT_T(self = [super init]) {
        _collection = AGX_RETAIN(collection);
        _allowPickingVideo = allowPickingVideo;
        _sortByCreateDateDescending = sortByCreateDateDescending;
    }
    return self;
}

- (void)dealloc {
    AGX_RELEASE(_collection);
    AGX_RELEASE(_assets);
    AGX_RELEASE(_assetModels);
    AGX_SUPER_DEALLOC;
}

- (NSString *)name {
    return _collection.localizedTitle ?: @"";
}

- (void)setAllowPickingVideo:(BOOL)allowPickingVideo {
    if (_allowPickingVideo == allowPickingVideo) return;
    _allowPickingVideo = allowPickingVideo;
    [self resetAssets];
}

- (void)setSortByCreateDateDescending:(BOOL)sortByCreateDateDescending {
    if (_sortByCreateDateDescending == sortByCreateDateDescending) return;
    _sortByCreateDateDescending = sortByCreateDateDescending;
    [self resetAssets];
}

- (PHFetchResult<PHAsset *> *)assets {
    if (!_assets) {
        _assets = AGX_RETAIN([PHAsset fetchAssetsInAssetCollection:_collection options:
                              [self prepareFetchOptionsAllowPickingVideo:_allowPickingVideo
                                              sortByCreateDateDescending:_sortByCreateDateDescending]]);
    }
    return _assets;
}

- (NSArray<AGXAssetModel *> *)assetModels {
    if (!_assetModels) {
        _assetModels = AGX_RETAIN([AGXPhotoManager.shareInstance allAssetModelsFromAlbumModel:self]);
    }
    return _assetModels;
}

- (NSInteger)count {
    return self.assets.count;
}

- (BOOL)isCameraRollAlbum {
    // 8.0.0 ~ 8.0.2
    return (NSOrderedDescending != AGX_SYSTEM_VERSION_COMPARE("8.0.2") ? PHAssetCollectionSubtypeSmartAlbumRecentlyAdded : PHAssetCollectionSubtypeSmartAlbumUserLibrary) == _collection.assetCollectionSubtype;
}

#pragma mark - private methods

- (void)resetAssets {
    AGX_RELEASE(_assets);
    _assets = nil;
    AGX_RELEASE(_assetModels);
    _assetModels = nil;
}

- (PHFetchOptions *)prepareFetchOptionsAllowPickingVideo:(BOOL)allowPickingVideo sortByCreateDateDescending:(BOOL)sortByCreateDateDescending {
    PHFetchOptions *options = PHFetchOptions.instance;
    if (!allowPickingVideo) options.predicate =
        [NSPredicate predicateWithFormat:@"mediaType == %ld", PHAssetMediaTypeImage];
    if (sortByCreateDateDescending) options.sortDescriptors =
        @[[NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:
           !sortByCreateDateDescending]];
    return options;
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
