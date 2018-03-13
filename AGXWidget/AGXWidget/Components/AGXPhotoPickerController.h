//
//  AGXPhotoPickerController.h
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

#ifndef AGXWidget_AGXPhotoPickerController_h
#define AGXWidget_AGXPhotoPickerController_h

#import <UIKit/UIKit.h>
#import <AGXCore/AGXCore/AGXArc.h>

AGX_EXTERN NSString *const AGXAlbumControllerMediaType; // @(AGXAssetModelMediaType)
AGX_EXTERN NSString *const AGXAlbumControllerPHAsset;  // PHAsset
AGX_EXTERN NSString *const AGXAlbumControllerPickedImage; // UIImage
AGX_EXTERN NSString *const AGXAlbumControllerOriginalImage; // UIImage
AGX_EXTERN NSString *const AGXAlbumCongrollerLivePhoto; // PHLivePhoto
AGX_EXTERN NSString *const AGXAlbumCongrollerLivePhotoExportPath; // NSString file path
AGX_EXTERN NSString *const AGXAlbumCongrollerLivePhotoVideoExportPath; // NSString file path
AGX_EXTERN NSString *const AGXAlbumCongrollerGifImageData; // NSData
AGX_EXTERN NSString *const AGXAlbumCongrollerGifImage; // UIImage animated
AGX_EXTERN NSString *const AGXAlbumCongrollerVideoExportPath; // NSString file path

AGX_EXTERN NSString *const AGXAlbumCongrollerPickingError; // NSError

@protocol AGXPhotoPickerControllerDelegate;

@interface AGXPhotoPickerController : UINavigationController
@property (nonatomic, AGX_WEAK) id<AGXPhotoPickerControllerDelegate> photoPickerDelegate;
@property (nonatomic, copy)     UIColor *tintColor; // default 4cd864
@property (nonatomic, assign)   NSUInteger columnNumber; // default 4
@property (nonatomic, assign)   BOOL allowPickingVideo; // default NO
@property (nonatomic, assign)   BOOL allowPickingGif; // default NO
@property (nonatomic, assign)   BOOL allowPickingLivePhoto; // default NO
@property (nonatomic, assign)   BOOL sortByCreateDateDescending; // default NO
@property (nonatomic, assign)   BOOL allowAssetPreviewing; // default YES
@property (nonatomic, assign)   BOOL allowPickingOriginal; // default NO
@property (nonatomic, assign)   CGSize pickingImageSize; // default UIScreen.mainScreen.bounds.size
@property (nonatomic, assign)   BOOL autoDismissViewController; // default YES;

- (void)presentAnimated:(BOOL)animated completion:(void (^)(void))completion;
@end

@protocol AGXPhotoPickerControllerDelegate <NSObject>
@optional
- (void)photoPickerControllerDidCancel:(AGXPhotoPickerController *)picker;
- (void)photoPickerController:(AGXPhotoPickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info;
@end

#endif /* AGXWidget_AGXPhotoPickerController_h */
