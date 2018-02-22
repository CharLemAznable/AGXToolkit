//
//  AGXPhotoManager.h
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

#ifndef AGXWidget_AGXPhotoManager_h
#define AGXWidget_AGXPhotoManager_h

#import <Photos/Photos.h>
#import <AGXCore/AGXCore/AGXSingleton.h>
#import "AGXPhotoModel.h"

typedef void (^AGXPhotoManagerImageHandler)(UIImage *image, NSDictionary *info, BOOL isDegraded);
typedef void (^AGXPhotoManagerImageDataHandler)(NSData *data, NSDictionary *info, BOOL isDegraded);
typedef void (^AGXPhotoManagerProgressHandler)(double progress, NSError *error, BOOL *stop, NSDictionary *info);
typedef void (^AGXPhotoManagerCoverImageHandler)(UIImage *image);
typedef void (^AGXPhotoManagerVideoHandler)(AVPlayerItem *playerItem, NSDictionary *info);
typedef void (^AGXPhotoManagerVideoExportHandler)(NSString *outputPath);
typedef void (^AGXPhotoManagerVideoExportFailureHandler)(NSString *errorMessage, NSError *error);

@protocol AGXPhotoManagerDelegate;

@singleton_interface(AGXPhotoManager, NSObject)
@property (nonatomic, AGX_WEAK) id<AGXPhotoManagerDelegate> delegate;
@property (nonatomic, assign)   BOOL hideWhenSizeUnfit; // default NO
@property (nonatomic, assign)   CGSize assetMinSize; // default {0, 0}
@property (nonatomic, assign)   CGSize assetMaxSize; // default {CGFLOAT_MAX, CGFLOAT_MAX}

+ (CGFloat)assetImageScale;

- (NSArray<AGXAlbumModel *> *)allAlbumModelsAllowPickingVideo:(BOOL)allowPickingVideo sortByCreateDateDescending:(BOOL)sortByCreateDateDescending;
- (AGXAlbumModel *)cameraRollAlbumModelAllowPickingVideo:(BOOL)allowPickingVideo sortByCreateDateDescending:(BOOL)sortByCreateDateDescending;
- (NSArray<AGXAssetModel *> *)allAssetModelsFromAlbumModel:(AGXAlbumModel *)albumModel;

- (PHImageRequestID)imageForAsset:(PHAsset *)asset size:(CGSize)size completion:(AGXPhotoManagerImageHandler)completion;
- (PHImageRequestID)imageForAsset:(PHAsset *)asset size:(CGSize)size completion:(AGXPhotoManagerImageHandler)completion progressHandler:(AGXPhotoManagerProgressHandler)progressHandler networkAccessAllowed:(BOOL)networkAccessAllowed;

- (PHImageRequestID)coverImageForAlbumModel:(AGXAlbumModel *)albumModel size:(CGSize)size completion:(void (^)(UIImage *image))completion;

- (PHImageRequestID)originalImageForAsset:(PHAsset *)asset completion:(AGXPhotoManagerImageHandler)completion;
- (PHImageRequestID)originalImageDataForAsset:(PHAsset *)asset completion:(AGXPhotoManagerImageDataHandler)completion;

- (void)saveImage:(UIImage *)image completion:(void (^)(NSError *error))completion;

- (PHImageRequestID)videoForAsset:(PHAsset *)asset completion:(AGXPhotoManagerVideoHandler)completion;
- (PHImageRequestID)videoForAsset:(PHAsset *)asset completion:(AGXPhotoManagerVideoHandler)completion progressHandler:(AGXPhotoManagerProgressHandler)progressHandler;

- (PHImageRequestID)exportVideoForAsset:(PHAsset *)asset success:(AGXPhotoManagerVideoExportHandler)success failure:(AGXPhotoManagerVideoExportFailureHandler)failure;
- (PHImageRequestID)exportVideoForAsset:(PHAsset *)asset presetName:(NSString *)presetName success:(AGXPhotoManagerVideoExportHandler)success failure:(AGXPhotoManagerVideoExportFailureHandler)failure;

- (void)totalBytesForAssetModels:(NSArray<AGXAssetModel *> *)assetModels completion:(void (^)(NSString *totalBytes))completion;
@end

@protocol AGXPhotoManagerDelegate <NSObject>
@optional
- (BOOL)photoManager:(AGXPhotoManager *)photoManager canSelectAlbumModel:(AGXAlbumModel *)albumModel;
- (BOOL)photoManager:(AGXPhotoManager *)photoManager canSelectAssetModel:(AGXAssetModel *)assetModel;
@end

#endif /* AGXWidget_AGXPhotoManager_h */
