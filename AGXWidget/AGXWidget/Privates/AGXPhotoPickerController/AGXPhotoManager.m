//
//  AGXPhotoManager.m
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
#import <AGXCore/AGXCore/NSString+AGXCore.h>
#import <AGXCore/AGXCore/NSDate+AGXCore.h>
#import <AGXCore/AGXCore/NSError+AGXCore.h>
#import <AGXCore/AGXCore/UIImage+AGXCore.h>
#import "AGXPhotoManager.h"
#import "AGXWidgetLocalization.h"
#import "AGXPhotoCommon.h"

AGX_STATIC const NSInteger PHAssetCollectionSubtypeSmartAlbumDeleted_AGX = 1000000201;

@singleton_implementation(AGXPhotoManager)

- (AGX_INSTANCETYPE)init {
    if (!AGXPhotoUtils.authorized) return nil;

    if AGX_EXPECT_T(self = [super init]) {
        _assetMinSize = CGSizeMake(0, 0);
        _assetMaxSize = CGSizeMake(CGFLOAT_MAX, CGFLOAT_MAX);
    }
    return self;
}

- (void)dealloc {
    _delegate = nil;
    AGX_SUPER_DEALLOC;
}

#pragma mark - fetch methods

- (NSArray<AGXAlbumModel *> *)allAlbumModelsAllowPickingVideo:(BOOL)allowPickingVideo allowPickingGif:(BOOL)allowPickingGif allowPickingLivePhoto:(BOOL)allowPickingLivePhoto sortByCreateDateDescending:(BOOL)sortByCreateDateDescending {
    NSArray *albums = @[[PHAssetCollection fetchAssetCollectionsWithType:
                         PHAssetCollectionTypeAlbum subtype:
                         PHAssetCollectionSubtypeAlbumMyPhotoStream options:nil],

                        [PHAssetCollection fetchAssetCollectionsWithType:
                         PHAssetCollectionTypeSmartAlbum subtype:
                         PHAssetCollectionSubtypeAlbumRegular options:nil],

                        [PHCollectionList fetchTopLevelUserCollectionsWithOptions:nil],

                        [PHAssetCollection fetchAssetCollectionsWithType:
                         PHAssetCollectionTypeAlbum subtype:
                         PHAssetCollectionSubtypeAlbumSyncedAlbum options:nil],

                        [PHAssetCollection fetchAssetCollectionsWithType:
                         PHAssetCollectionTypeAlbum subtype:
                         PHAssetCollectionSubtypeAlbumCloudShared options:nil]];
    NSMutableArray *allAlbumModels = NSMutableArray.instance;

    BOOL delegateResponds = [self.delegate respondsToSelector:
                             @selector(photoManager:canSelectAlbumModel:)];
    for (PHFetchResult<PHAssetCollection *> *fetchResult in albums) {
        for (PHAssetCollection *collection in fetchResult) {
            if (![collection isKindOfClass:PHAssetCollection.class]) continue;
            if (PHAssetCollectionSubtypeSmartAlbumAllHidden == collection.assetCollectionSubtype ||
                PHAssetCollectionSubtypeSmartAlbumDeleted_AGX == collection.assetCollectionSubtype) continue;
            if (collection.estimatedAssetCount <= 0) continue;

            AGXAlbumModel *albumModel = [AGXAlbumModel albumModelWithCollection:collection
                                                              allowPickingVideo:allowPickingVideo
                                                                allowPickingGif:allowPickingGif
                                                          allowPickingLivePhoto:allowPickingLivePhoto
                                                     sortByCreateDateDescending:sortByCreateDateDescending];
            if (albumModel.count < 1) continue;
            if (delegateResponds && ![self.delegate photoManager:
                                      self canSelectAlbumModel:albumModel]) continue;

            if (albumModel.isCameraRollAlbum) {
                [allAlbumModels insertObject:albumModel atIndex:0];
            } else {
                [allAlbumModels addObject:albumModel];
            }
        }
    }
    return AGX_AUTORELEASE([allAlbumModels copy]);
}

- (AGXAlbumModel *)cameraRollAlbumModelAllowPickingVideo:(BOOL)allowPickingVideo allowPickingGif:(BOOL)allowPickingGif allowPickingLivePhoto:(BOOL)allowPickingLivePhoto sortByCreateDateDescending:(BOOL)sortByCreateDateDescending {
    PHFetchResult<PHAssetCollection *> *smartAlbums = [PHAssetCollection fetchAssetCollectionsWithType:
                                                       PHAssetCollectionTypeSmartAlbum subtype:
                                                       PHAssetCollectionSubtypeAlbumRegular options:nil];
    for (PHAssetCollection *collection in smartAlbums) {
        if (![collection isKindOfClass:PHAssetCollection.class]) continue;
        AGXAlbumModel *albumModel = [AGXAlbumModel albumModelWithCollection:collection
                                                          allowPickingVideo:allowPickingVideo
                                                            allowPickingGif:allowPickingGif
                                                      allowPickingLivePhoto:allowPickingLivePhoto
                                                 sortByCreateDateDescending:sortByCreateDateDescending];
        if (!albumModel.isCameraRollAlbum) continue;

        return albumModel;
    }
    return nil;
}

- (NSArray<AGXAssetModel *> *)allAssetModelsFromAlbumModel:(AGXAlbumModel *)albumModel {
    NSMutableArray *allAssetModels = NSMutableArray.instance;
    BOOL delegateResponds = [self.delegate respondsToSelector:@selector(photoManager:canSelectAssetModel:)];
    for (PHAsset *asset in albumModel.assets) {
        if (_hideWhenSizeUnfit && ![self isSizeFitAsset:asset]) continue;

        AGXAssetModelMediaType mediaType = [self mediaTypeOfAsset:asset];
        NSString *timeLength = (AGXAssetModelMediaTypeVideo == mediaType ?
                                [self formatTimeLengthOfAsset:asset] : nil);
        AGXAssetModel *assetModel = [AGXAssetModel assetModelWithAsset:asset mediaType:mediaType
                                                            timeLength:timeLength];
        if (delegateResponds && ![self.delegate photoManager:self canSelectAssetModel:assetModel]) continue;

        [allAssetModels addObject:assetModel];
    }
    return AGX_AUTORELEASE([allAssetModels copy]);
}

- (PHImageRequestID)imageForAsset:(PHAsset *)asset size:(CGSize)size completion:(AGXPhotoManagerImageHandler)completion {
    return [self imageForAsset:asset scale:UIScreen.mainScreen.scale size:size completion:completion];
}

- (PHImageRequestID)imageForAsset:(PHAsset *)asset size:(CGSize)size completion:(AGXPhotoManagerImageHandler)completion progressHandler:(AGXPhotoManagerProgressHandler)progressHandler networkAccessAllowed:(BOOL)networkAccessAllowed {
    return [self imageForAsset:asset scale:UIScreen.mainScreen.scale size:size completion:completion progressHandler:NULL networkAccessAllowed:YES];
}

- (PHImageRequestID)imageForAsset:(PHAsset *)asset size:(CGSize)size completion:(AGXPhotoManagerImageHandler)completion failure:(AGXPhotoManagerErrorHandler)failure progressHandler:(AGXPhotoManagerProgressHandler)progressHandler networkAccessAllowed:(BOOL)networkAccessAllowed {
    return [self imageForAsset:asset scale:UIScreen.mainScreen.scale size:size completion:completion failure:NULL progressHandler:NULL networkAccessAllowed:YES];
}

- (PHImageRequestID)imageForAsset:(PHAsset *)asset scale:(CGFloat)scale size:(CGSize)size completion:(AGXPhotoManagerImageHandler)completion {
    return [self imageForAsset:asset scale:scale size:size completion:completion progressHandler:NULL networkAccessAllowed:YES];
}

- (PHImageRequestID)imageForAsset:(PHAsset *)asset scale:(CGFloat)scale size:(CGSize)size completion:(AGXPhotoManagerImageHandler)completion progressHandler:(AGXPhotoManagerProgressHandler)progressHandler networkAccessAllowed:(BOOL)networkAccessAllowed {
    return [self imageForAsset:asset scale:scale size:size completion:completion failure:NULL progressHandler:NULL networkAccessAllowed:YES];
}

- (PHImageRequestID)imageForAsset:(PHAsset *)asset scale:(CGFloat)scale size:(CGSize)size completion:(AGXPhotoManagerImageHandler)completion failure:(AGXPhotoManagerErrorHandler)failure progressHandler:(AGXPhotoManagerProgressHandler)progressHandler networkAccessAllowed:(BOOL)networkAccessAllowed {
    __block UIImage *image;
    PHImageRequestOptions *option = PHImageRequestOptions.instance;
    option.resizeMode = PHImageRequestOptionsResizeModeFast;
    CGSize targetSize = CGSizeMake(size.width*scale, size.height*scale);
    return [PHImageManager.defaultManager requestImageForAsset:asset targetSize:
            targetSize contentMode:PHImageContentModeAspectFill options:option resultHandler:
            ^(UIImage *result, NSDictionary *info) {
                if (result) image = result;

                BOOL downloadFinined = (![info[PHImageCancelledKey] boolValue] && !info[PHImageErrorKey]);
                if (downloadFinined && result) {
                    agx_async_main(!completion?:completion([UIImage imageFixedOrientation:result], info,
                                                           [info[PHImageResultIsDegradedKey] boolValue]););
                    return;
                }
                // Download image from iCloud
                if (info[PHImageResultIsInCloudKey] && !result && networkAccessAllowed) {
                    PHImageRequestOptions *options = PHImageRequestOptions.instance;
                    options.progressHandler = ^(double progress, NSError *error, BOOL *stop, NSDictionary *info) {
                        agx_async_main(!progressHandler?:progressHandler(progress, error, stop, info););
                    };
                    options.networkAccessAllowed = YES;
                    options.resizeMode = PHImageRequestOptionsResizeModeFast;
                    [PHImageManager.defaultManager requestImageDataForAsset:asset options:options resultHandler:
                     ^(NSData *imageData, NSString *dataUTI, UIImageOrientation orientation, NSDictionary *info) {
                         if (![info[PHImageCancelledKey] boolValue] && !info[PHImageErrorKey] && imageData) {
                             UIImage *resultImage = [UIImage image:[UIImage imageWithData:imageData scale:0.1]
                                                          fillSize:targetSize] ?: image;
                             agx_async_main(!completion?:completion([UIImage imageFixedOrientation:resultImage], info, NO););
                         } else {
                             agx_async_main(!failure?:failure(AGXWidgetLocalizedStringDefault
                                                              (@"AGXPhotoPickerController.requestImageDataForAssetError",
                                                               @"Request image data for asset Error"),
                                                              (NSError *)info[PHImageErrorKey]););
                         }
                     }];
                } else {
                    agx_async_main(!failure?:failure(AGXWidgetLocalizedStringDefault
                                                     (@"AGXPhotoPickerController.requestImageForAssetError",
                                                      @"Request image for asset Error"),
                                                     (NSError *)info[PHImageErrorKey]););
                }
            }];
}

- (PHImageRequestID)coverImageForAlbumModel:(AGXAlbumModel *)albumModel size:(CGSize)size completion:(void (^)(UIImage *image))completion {
    PHAsset *asset = (albumModel.sortByCreateDateDescending ?
                      albumModel.assets.firstObject : albumModel.assets.lastObject);
    return [self imageForAsset:asset size:size completion:
            ^(UIImage *image, NSDictionary *info, BOOL isDegraded) {
                !completion?:completion(image);
            }];
}

- (PHImageRequestID)originalImageForAsset:(PHAsset *)asset completion:(AGXPhotoManagerImageHandler)completion {
    return [self originalImageForAsset:asset completion:completion failure:NULL];
}

- (PHImageRequestID)originalImageDataForAsset:(PHAsset *)asset completion:(AGXPhotoManagerImageDataHandler)completion {
    return [self originalImageDataForAsset:asset completion:completion failure:NULL];
}

- (PHImageRequestID)originalLivePhotoForAsset:(PHAsset *)asset completion:(AGXPhotoManagerLivePhotoHandler)completion {
    return [self originalLivePhotoForAsset:asset completion:completion failure:NULL];
}

- (PHImageRequestID)originalImageForAsset:(PHAsset *)asset completion:(AGXPhotoManagerImageHandler)completion failure:(AGXPhotoManagerErrorHandler)failure {
    PHImageRequestOptions *option = PHImageRequestOptions.instance;
    option.networkAccessAllowed = YES;
    option.resizeMode = PHImageRequestOptionsResizeModeFast;
    return [PHImageManager.defaultManager requestImageForAsset:asset targetSize:
            PHImageManagerMaximumSize contentMode:PHImageContentModeAspectFit options:option resultHandler:
            ^(UIImage *result, NSDictionary *info) {
                if (![info[PHImageCancelledKey] boolValue] && !info[PHImageErrorKey] && result) {
                    agx_async_main(!completion?:completion([UIImage imageFixedOrientation:result], info,
                                                           [info[PHImageResultIsDegradedKey] boolValue]););
                } else {
                    agx_async_main(!failure?:failure(AGXWidgetLocalizedStringDefault
                                                     (@"AGXPhotoPickerController.requestImageForAssetError",
                                                      @"Request image for asset Error"),
                                                     (NSError *)info[PHImageErrorKey]););
                }
            }];
}

- (PHImageRequestID)originalImageDataForAsset:(PHAsset *)asset completion:(AGXPhotoManagerImageDataHandler)completion failure:(AGXPhotoManagerErrorHandler)failure {
    PHImageRequestOptions *option = PHImageRequestOptions.instance;
    option.networkAccessAllowed = YES;
    option.resizeMode = PHImageRequestOptionsResizeModeFast;
    return [PHImageManager.defaultManager requestImageDataForAsset:asset options:option resultHandler:
            ^(NSData *data, NSString *dataUTI, UIImageOrientation orientation, NSDictionary *info) {
                if (![info[PHImageCancelledKey] boolValue] && !info[PHImageErrorKey] && data) {
                    agx_async_main(!completion?:completion(data, info, NO););
                } else {
                    agx_async_main(!failure?:failure(AGXWidgetLocalizedStringDefault
                                                     (@"AGXPhotoPickerController.requestImageDataForAssetError",
                                                      @"Request image data for asset Error"),
                                                     (NSError *)info[PHImageErrorKey]););
                }
            }];
}

- (PHImageRequestID)originalLivePhotoForAsset:(PHAsset *)asset completion:(AGXPhotoManagerLivePhotoHandler)completion failure:(AGXPhotoManagerErrorHandler)failure {
    if (@available(iOS 9.1, *)) {
        PHLivePhotoRequestOptions *option = PHLivePhotoRequestOptions.instance;
        option.version = PHImageRequestOptionsVersionCurrent;
        option.deliveryMode = PHImageRequestOptionsDeliveryModeHighQualityFormat;
        option.networkAccessAllowed = YES;
        option.progressHandler = NULL;
        return [PHImageManager.defaultManager requestLivePhotoForAsset:asset targetSize:
                PHImageManagerMaximumSize contentMode:PHImageContentModeAspectFit options:option resultHandler:
                ^(PHLivePhoto *result, NSDictionary *info) {
                    if ([info[PHImageCancelledKey] boolValue] || info[PHImageErrorKey] || !result) return;
                    if (![info[PHImageCancelledKey] boolValue] && !info[PHImageErrorKey] && result) {
                        agx_async_main(!completion?:completion(result, info, [info[PHImageResultIsDegradedKey] boolValue]););
                    } else {
                        agx_async_main(!failure?:failure(AGXWidgetLocalizedStringDefault
                                                         (@"AGXPhotoPickerController.requestLivePhotoForAssetError",
                                                          @"Request live photo for asset Error"),
                                                         (NSError *)info[PHImageErrorKey]););
                    }
                }];
    } else {
        agx_async_main(!failure?:failure(AGXWidgetLocalizedStringDefault
                                         (@"AGXPhotoPickerController.requestLivePhotoForAssetError",
                                          @"Request live photo for asset Error"),
                                         [NSError errorWithDomain:@"com.agxwidget.photomanager"
                                                             code:-1 description:@"LivePhoto UNAVAILABLE"]););
        return -1;
    }
}

- (void)exportLivePhoto:(PHLivePhoto *)livePhoto success:(AGXPhotoManagerLivePhotoExportHandler)success failure:(AGXPhotoManagerErrorHandler)failure {
    if (@available(iOS 9.1, *)) {
        [self exportLivePhotoForAssetResources:[PHAssetResource assetResourcesForLivePhoto:livePhoto]
                                       success:success failure:failure];
    } else {
        agx_async_main(!failure?:failure(AGXWidgetLocalizedStringDefault
                                         (@"AGXPhotoPickerController.requestLivePhotoForAssetError",
                                          @"Request live photo for asset Error"),
                                         [NSError errorWithDomain:@"com.agxwidget.photomanager"
                                                             code:-1 description:@"LivePhoto UNAVAILABLE"]););
    }
}

- (void)exportLivePhotoForAsset:(PHAsset *)asset success:(AGXPhotoManagerLivePhotoExportHandler)success failure:(AGXPhotoManagerErrorHandler)failure {
    if (@available(iOS 9.1, *)) {
        [self exportLivePhotoForAssetResources:[PHAssetResource assetResourcesForAsset:asset]
                                       success:success failure:failure];
    } else {
        agx_async_main(!failure?:failure(AGXWidgetLocalizedStringDefault
                                         (@"AGXPhotoPickerController.requestLivePhotoForAssetError",
                                          @"Request live photo for asset Error"),
                                         [NSError errorWithDomain:@"com.agxwidget.photomanager"
                                                             code:-1 description:@"LivePhoto UNAVAILABLE"]););
    }
}

- (void)saveImage:(UIImage *)image completion:(void (^)(NSError *error))completion {
    [PHPhotoLibrary.sharedPhotoLibrary performChanges:^{
        PHAssetChangeRequest *request = [PHAssetChangeRequest creationRequestForAssetFromImage:image];
        request.creationDate = [NSDate date];
    } completionHandler:^(BOOL success, NSError *error) {
        agx_async_main(!completion?:completion
                       (success?nil:
                        (error?:[NSError errorWithDomain:@"com.agxwidget.saveimageerrordomain"
                                                    code:-1 userInfo:nil])););
    }];
}

- (PHImageRequestID)videoForAsset:(PHAsset *)asset completion:(AGXPhotoManagerVideoHandler)completion {
    return [self videoForAsset:asset completion:completion progressHandler:NULL];
}

- (PHImageRequestID)videoForAsset:(PHAsset *)asset completion:(AGXPhotoManagerVideoHandler)completion progressHandler:(AGXPhotoManagerProgressHandler)progressHandler {
    PHVideoRequestOptions *option = PHVideoRequestOptions.instance;
    option.networkAccessAllowed = YES;
    option.progressHandler = ^(double progress, NSError *error, BOOL *stop, NSDictionary *info) {
        agx_async_main(!progressHandler?:progressHandler(progress, error, stop, info););
    };
    return [PHImageManager.defaultManager requestPlayerItemForVideo:asset options:option resultHandler:
            ^(AVPlayerItem *playerItem, NSDictionary *info) { agx_async_main(!completion?:completion(playerItem, info);); }];
}

- (PHImageRequestID)exportVideoForAsset:(PHAsset *)asset success:(AGXPhotoManagerVideoExportHandler)success failure:(AGXPhotoManagerErrorHandler)failure {
    return [self exportVideoForAsset:asset presetName:AVAssetExportPreset640x480 success:success failure:failure];
}

- (PHImageRequestID)exportVideoForAsset:(PHAsset *)asset presetName:(NSString *)presetName success:(AGXPhotoManagerVideoExportHandler)success failure:(AGXPhotoManagerErrorHandler)failure {
    PHVideoRequestOptions *options = PHVideoRequestOptions.instance;
    options.version = PHVideoRequestOptionsVersionOriginal;
    options.deliveryMode = PHVideoRequestOptionsDeliveryModeAutomatic;
    options.networkAccessAllowed = YES;
    return [PHImageManager.defaultManager requestAVAssetForVideo:asset options:options resultHandler:
            ^(AVAsset *avasset, AVAudioMix *audioMix, NSDictionary *info) {
                [self startExportVideoWithVideoAsset:(AVURLAsset *)avasset presetName:presetName
                                             success:success failure:failure];
            }];
}

- (void)bytesStringForAssetModel:(AGXAssetModel *)assetModel completion:(void (^)(NSString *bytesString))completion {
    if (!assetModel) { agx_async_main(!completion?:completion(@"0B");); return; }

    PHImageRequestOptions *options = PHImageRequestOptions.instance;
    options.resizeMode = PHImageRequestOptionsResizeModeFast;
    [PHImageManager.defaultManager requestImageDataForAsset:assetModel.asset options:options resultHandler:
     ^(NSData *imageData, NSString *dataUTI, UIImageOrientation orientation, NSDictionary *info) {
         NSInteger dataLength = 0;
         if (assetModel.mediaType != AGXAssetModelMediaTypeVideo) dataLength += imageData.length;
         agx_async_main(!completion?:completion([self bytesStringWithDataLength:dataLength]););
     }];
}

#pragma mark - private methods

- (AGXAssetModelMediaType)mediaTypeOfAsset:(PHAsset *)asset {
    if (asset.mediaType == PHAssetMediaTypeVideo) return AGXAssetModelMediaTypeVideo;
    if (asset.mediaType == PHAssetMediaTypeImage) {
        if (asset.mediaSubtypes == PHAssetMediaSubtypePhotoLive) return AGXAssetModelMediaTypeLivePhoto;
        if ([[asset valueForKey:@"filename"] hasCaseInsensitiveSuffix:@"GIF"])
            return AGXAssetModelMediaTypeGif;
    }
    return AGXAssetModelMediaTypePhoto;
}

- (BOOL)isSizeFitAsset:(PHAsset *)asset {
    CGSize assetSize = CGSizeMake(asset.pixelWidth, asset.pixelHeight);
    return(BETWEEN(assetSize.width, _assetMinSize.width, _assetMaxSize.width) &&
           BETWEEN(assetSize.height, _assetMinSize.height, _assetMaxSize.height));
}

- (NSString *)formatTimeLengthOfAsset:(PHAsset *)asset {
    NSInteger duration = asset.duration;
    if (duration < 10) {
        return [NSString stringWithFormat:@"0:0%zd", (long)duration];
    } else if (duration < 60) {
        return [NSString stringWithFormat:@"0:%zd", (long)duration];
    } else {
        NSInteger min = duration / 60;
        NSInteger sec = duration - (min * 60);
        if (sec < 10) {
            return [NSString stringWithFormat:@"%zd:0%zd", (long)min, (long)sec];
        } else {
            return [NSString stringWithFormat:@"%zd:%zd", (long)min, (long)sec];
        }
    }
}

- (CGSize)imageSizeForAsset:(PHAsset *)asset scale:(CGFloat)scale width:(CGFloat)width {
    CGFloat aspectRatio = (CGFloat)asset.pixelWidth / (CGFloat)asset.pixelHeight;
    CGFloat pixelWidth = width * scale * 1.5;
    pixelWidth = pixelWidth * (aspectRatio > 1.8 ? aspectRatio : (aspectRatio < 0.2 ? 0.5 : 1));
    return CGSizeMake(pixelWidth, pixelWidth / aspectRatio);
}

- (void)exportLivePhotoForAssetResources:(NSArray<PHAssetResource *> *)assetResources success:(AGXPhotoManagerLivePhotoExportHandler)success failure:(AGXPhotoManagerErrorHandler)failure {
    PHAssetResource *photoResource = nil, *videoResource = nil;
    for (PHAssetResource *assetResource in assetResources) {
        if (PHAssetResourceTypePhoto == assetResource.type) photoResource = assetResource;
        else if (PHAssetResourceTypePairedVideo == assetResource.type) videoResource = assetResource;
    }
    if (!photoResource || !videoResource) {
        agx_async_main(!failure?:failure(AGXWidgetLocalizedStringDefault
                                         (@"AGXPhotoPickerController.assetResourcesError",
                                          @"LivePhoto Asset Resources Error"), nil););
        return;
    }

    NSString *dateString = [[NSDate date] stringWithDateFormat:@"yyyy-MM-dd-HH:mm:ss-SSS"];
    NSString *photoFileName = [NSString stringWithFormat:@"output-livephoto-%@.jpg", dateString];
    NSString *videoFileName = [NSString stringWithFormat:@"output-livephoto-%@.mov", dateString];
    NSString *outputPhotoPath = AGXResources.temporary.pathWithFileNamed(photoFileName);
    NSString *outputVideoPath = AGXResources.temporary.pathWithFileNamed(videoFileName);

    PHAssetResourceRequestOptions *option = PHAssetResourceRequestOptions.instance;
    option.networkAccessAllowed = YES;
    [PHAssetResourceManager.defaultManager writeDataForAssetResource:photoResource toFile:
     [NSURL fileURLWithPath:outputPhotoPath] options:option completionHandler:
     ^(NSError *error) {
         if (error) {
             agx_async_main(!failure?:failure(AGXWidgetLocalizedStringDefault
                                              (@"AGXPhotoPickerController.livePhotoExportFailed",
                                               @"LivePhoto export failed"), error););
             return;
         }

         [PHAssetResourceManager.defaultManager writeDataForAssetResource:videoResource toFile:
          [NSURL fileURLWithPath:outputVideoPath] options:option completionHandler:
          ^(NSError *error) {
              if (error) {
                  agx_async_main(!failure?:failure(AGXWidgetLocalizedStringDefault
                                                   (@"AGXPhotoPickerController.livePhotoExportFailed",
                                                    @"LivePhoto export failed"), error););
                  return;
              }

              agx_async_main(!success?:success(outputPhotoPath, outputVideoPath););
          }];
     }];
}

- (void)startExportVideoWithVideoAsset:(AVURLAsset *)videoAsset presetName:(NSString *)presetName success:(void (^)(NSString *outputPath))success failure:(void (^)(NSString *errorMessage, NSError *error))failure {
    // Find compatible presets by video asset.
    NSArray *presets = [AVAssetExportSession exportPresetsCompatibleWithAsset:videoAsset];

    // Begin to compress video
    // Now we just compress to low resolution if it supports
    // If you need to upload to the server, but server does't support to upload by streaming,
    // You can compress the resolution to lower. Or you can support more higher resolution.
    if (![presets containsObject:presetName]) {
        agx_async_main(!failure?:failure([NSString stringWithFormat:AGXWidgetLocalizedStringDefault
                                          (@"AGXPhotoPickerController.unsupportedExportPresetFormat",
                                           @"Unsupported export preset: %@"), presetName], nil););
        return;
    }

    AVAssetExportSession *session = AGX_AUTORELEASE([[AVAssetExportSession alloc]
                                                     initWithAsset:videoAsset presetName:presetName]);
    NSString *fileName = [NSString stringWithFormat:@"output-%@.mp4",
                          [[NSDate date] stringWithDateFormat:@"yyyy-MM-dd-HH:mm:ss-SSS"]];
    NSString *outputPath = AGXResources.temporary.pathWithFileNamed(fileName);
    session.outputURL = [NSURL fileURLWithPath:outputPath];
    // Optimize for network use.
    session.shouldOptimizeForNetworkUse = true;

    NSArray *supportedTypeArray = session.supportedFileTypes;
    if (supportedTypeArray.count == 0) {
        agx_async_main(!failure?:failure(AGXWidgetLocalizedStringDefault
                                         (@"AGXPhotoPickerController.unsupportedFileTypes",
                                          @"Unsupported file types"), nil););
        return;
    }
    session.outputFileType = ([supportedTypeArray containsObject:AVFileTypeMPEG4]
                              ? AVFileTypeMPEG4 : supportedTypeArray[0]);
    AGXResources.temporary.createPathOfFileNamed(fileName);

    AVMutableVideoComposition *videoComposition = [self fixedCompositionWithAsset:videoAsset];
    if (videoComposition.renderSize.width) { session.videoComposition = videoComposition; }

    // Begin to export video to the output path asynchronously.
    [session exportAsynchronouslyWithCompletionHandler:^(void) {
        agx_async_main
        (switch (session.status) {
            case AVAssetExportSessionStatusUnknown: {
                AGXLog(@"AVAssetExportSessionStatusUnknown");
            }   break;
            case AVAssetExportSessionStatusWaiting: {
                AGXLog(@"AVAssetExportSessionStatusWaiting");
            }   break;
            case AVAssetExportSessionStatusExporting: {
                AGXLog(@"AVAssetExportSessionStatusExporting");
            }   break;
            case AVAssetExportSessionStatusCompleted: {
                AGXLog(@"AVAssetExportSessionStatusCompleted");
                !success?:success(outputPath);
            }   break;
            case AVAssetExportSessionStatusFailed: {
                AGXLog(@"AVAssetExportSessionStatusFailed");
                !failure?:failure(AGXWidgetLocalizedStringDefault
                                  (@"AGXPhotoPickerController.videoExportFailed",
                                   @"Video export failed"), session.error);
            }   break;
            case AVAssetExportSessionStatusCancelled: {
                AGXLog(@"AVAssetExportSessionStatusCancelled");
                !failure?:failure(AGXWidgetLocalizedStringDefault
                                  (@"AGXPhotoPickerController.videoExportCancelled",
                                   @"Video export cancelled"), nil);
            }   break;
            default: break;
        });
    }];
}

- (AVMutableVideoComposition *)fixedCompositionWithAsset:(AVAsset *)videoAsset {
    AVMutableVideoComposition *videoComposition = AVMutableVideoComposition.videoComposition;
    int degrees = [self degreesFromVideoFileWithAsset:videoAsset];
    if (0 == degrees) return videoComposition;

    CGAffineTransform translateToCenter;
    CGAffineTransform mixedTransform;
    videoComposition.frameDuration = CMTimeMake(1, 30);
    AVAssetTrack *videoTrack = [videoAsset tracksWithMediaType:AVMediaTypeVideo][0];

    AVMutableVideoCompositionInstruction *roateInstruction = AVMutableVideoCompositionInstruction.videoCompositionInstruction;
    roateInstruction.timeRange = CMTimeRangeMake(kCMTimeZero, videoAsset.duration);
    AVMutableVideoCompositionLayerInstruction *roateLayerInstruction = [AVMutableVideoCompositionLayerInstruction videoCompositionLayerInstructionWithAssetTrack:videoTrack];

    if (90 == degrees) { // clockwise90°
        translateToCenter = CGAffineTransformMakeTranslation(videoTrack.naturalSize.height, 0.0);
        mixedTransform = CGAffineTransformRotate(translateToCenter, M_PI_2);
        videoComposition.renderSize = CGSizeMake(videoTrack.naturalSize.height, videoTrack.naturalSize.width);
        [roateLayerInstruction setTransform:mixedTransform atTime:kCMTimeZero];
    } else if (180 == degrees) { // clockwise180°
        translateToCenter = CGAffineTransformMakeTranslation(videoTrack.naturalSize.width, videoTrack.naturalSize.height);
        mixedTransform = CGAffineTransformRotate(translateToCenter, M_PI);
        videoComposition.renderSize = CGSizeMake(videoTrack.naturalSize.width, videoTrack.naturalSize.height);
        [roateLayerInstruction setTransform:mixedTransform atTime:kCMTimeZero];
    } else if (270 == degrees) { // clockwise270°
        translateToCenter = CGAffineTransformMakeTranslation(0.0, videoTrack.naturalSize.width);
        mixedTransform = CGAffineTransformRotate(translateToCenter, M_PI_2*3.0);
        videoComposition.renderSize = CGSizeMake(videoTrack.naturalSize.height, videoTrack.naturalSize.width);
        [roateLayerInstruction setTransform:mixedTransform atTime:kCMTimeZero];
    }

    roateInstruction.layerInstructions = @[roateLayerInstruction];
    videoComposition.instructions = @[roateInstruction];
    return videoComposition;
}

- (int)degreesFromVideoFileWithAsset:(AVAsset *)asset {
    int degrees = 0;
    NSArray *tracks = [asset tracksWithMediaType:AVMediaTypeVideo];
    if (tracks.count > 0) {
        AVAssetTrack *videoTrack = tracks[0];
        CGAffineTransform t = videoTrack.preferredTransform;
        if (0 == t.a && 1.0 == t.b && -1.0 == t.c && 0 == t.d) {
            degrees = 90; // Portrait
        } else if (0 == t.a && -1.0 == t.b && 1.0 == t.c && 0 == t.d) {
            degrees = 270; // PortraitUpsideDown
        } else if (1.0 == t.a && 0 == t.b && 0 == t.c && 1.0 == t.d) {
            degrees = 0; // LandscapeRight
        } else if (-1.0 == t.a && 0 == t.b && 0 == t.c && -1.0 == t.d) {
            degrees = 180; // LandscapeLeft
        }
    }
    return degrees;
}

- (NSString *)bytesStringWithDataLength:(NSInteger)dataLength {
    if (dataLength >= 0.1*(1024*1024)) {
        return [NSString stringWithFormat:@"%0.1fM", dataLength/1024./1024.];
    } else if (dataLength >= 1024) {
        return [NSString stringWithFormat:@"%0.0fK", dataLength/1024.];
    } else {
        return [NSString stringWithFormat:@"%zdB", (long)dataLength];
    }
}

@end
