//
//  AGXImageManager.h
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

#ifndef AGXWidget_AGXImageManager_h
#define AGXWidget_AGXImageManager_h

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import <Photos/Photos.h>
#import <AGXCore/AGXCore/AGXSingleton.h>
#import "AGXImagePickerModel.h"

typedef void (^AGXImageManagerImageHandler)(UIImage *image, NSDictionary *info, BOOL isDegraded);
typedef void (^AGXImageManagerImageDataHandler)(NSData *data, NSDictionary *info, BOOL isDegraded);
typedef void (^AGXImageManagerProgressHandler)(double progress, NSError *error, BOOL *stop, NSDictionary *info);
typedef void (^AGXImageManagerCoverImageHandler)(UIImage *image);
typedef void (^AGXImageManagerVideoHandler)(AVPlayerItem *playerItem, NSDictionary *info);
typedef void (^AGXImageManagerVideoExportHandler)(NSString *outputPath);
typedef void (^AGXImageManagerVideoExportFailureHandler)(NSString *errorMessage, NSError *error);

@protocol AGXImageManagerDelegate;

@singleton_interface(AGXImageManager, NSObject)
@property (nonatomic, AGX_WEAK) id<AGXImageManagerDelegate> delegate;
@property (nonatomic, assign) BOOL allowPickingVideo; // default NO
@property (nonatomic, assign) BOOL sortByCreateDateDescending; // default NO
@property (nonatomic, assign) BOOL hideWhenSizeUnfit; // default NO
@property (nonatomic, assign) CGSize assetMinSize; // default {0, 0}
@property (nonatomic, assign) CGSize assetMaxSize; // default {CGFLOAT_MAX, CGFLOAT_MAX}
@property (nonatomic, assign) CGSize assetThumbSize; // default {(ScreenWidth-12)/4, (ScreenWidth-12)/4}

+ (PHAuthorizationStatus)authorizationStatus;
- (NSArray<AGXAlbumModel *> *)allAlbums;
- (AGXAlbumModel *)cameraRollAlbum;
- (NSArray<AGXAssetModel *> *)allAssetsFromAlbum:(AGXAlbumModel *)album;
- (NSArray<AGXAssetModel *> *)allAssetsFromFetchResult:(PHFetchResult<PHAsset *> *)fetchResult;

- (PHImageRequestID)imageForAsset:(PHAsset *)asset completion:(AGXImageManagerImageHandler)completion;
- (PHImageRequestID)imageForAsset:(PHAsset *)asset completion:(AGXImageManagerImageHandler)completion progressHandler:(AGXImageManagerProgressHandler)progressHandler networkAccessAllowed:(BOOL)networkAccessAllowed;

- (PHImageRequestID)imageForAsset:(PHAsset *)asset width:(CGFloat)width completion:(AGXImageManagerImageHandler)completion;
- (PHImageRequestID)imageForAsset:(PHAsset *)asset width:(CGFloat)width completion:(AGXImageManagerImageHandler)completion progressHandler:(AGXImageManagerProgressHandler)progressHandler networkAccessAllowed:(BOOL)networkAccessAllowed;

- (PHImageRequestID)coverImageForAlbum:(AGXAlbumModel *)album width:(CGFloat)width completion:(void (^)(UIImage *image))completion;

- (PHImageRequestID)originalImageForAsset:(PHAsset *)asset completion:(AGXImageManagerImageHandler)completion;
- (PHImageRequestID)originalImageDataForAsset:(PHAsset *)asset completion:(AGXImageManagerImageDataHandler)completion;

- (void)saveImage:(UIImage *)image completion:(void (^)(NSError *error))completion;

- (PHImageRequestID)videoForAsset:(PHAsset *)asset completion:(AGXImageManagerVideoHandler)completion;
- (PHImageRequestID)videoForAsset:(PHAsset *)asset completion:(AGXImageManagerVideoHandler)completion progressHandler:(AGXImageManagerProgressHandler)progressHandler;

- (PHImageRequestID)exportVideoForAsset:(PHAsset *)asset success:(AGXImageManagerVideoExportHandler)success failure:(AGXImageManagerVideoExportFailureHandler)failure;
- (PHImageRequestID)exportVideoForAsset:(PHAsset *)asset presetName:(NSString *)presetName success:(AGXImageManagerVideoExportHandler)success failure:(AGXImageManagerVideoExportFailureHandler)failure;
@end

@protocol AGXImageManagerDelegate <NSObject>
@optional
- (BOOL)imageManager:(AGXImageManager *)imageManager canSelectAlbumWithName:(NSString *)name fetchResultAssets:(PHFetchResult<PHAsset *> *)result;
- (BOOL)imageManager:(AGXImageManager *)imageManager canSelectAsset:(PHAsset *)asset;
@end

#endif /* AGXWidget_AGXImageManager_h */
