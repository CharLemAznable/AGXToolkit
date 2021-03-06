//
//  AGXAssetPreviewController.h
//  AGXWidget
//
//  Created by Char Aznable on 2018/2/2.
//  Copyright © 2018 github.com/CharLemAznable. All rights reserved.
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

#ifndef AGXWidget_AGXAssetPreviewController_h
#define AGXWidget_AGXAssetPreviewController_h

#import "AGXPhotoCommon.h"
#import "AGXPhotoModel.h"

@class AGXAssetPreviewController;

@protocol AGXAssetPreviewControllerDelegate <NSObject, AGXPhotoPickerSubControllerDelegate>
@end

@interface AGXAssetPreviewController : AGXPhotoPickerSubController
@property (nonatomic, AGX_WEAK)     id<AGXAssetPreviewControllerDelegate> delegate;
@property (nonatomic, AGX_STRONG)   NSArray<AGXAssetModel *> *assetModels;
@property (nonatomic, assign)       NSInteger currentIndex;
@property (nonatomic, copy)         UIColor *highlightColor; // default 4cd864
@property (nonatomic, assign)       CGFloat pickingImageScale; // default UIScreen.mainScreen.scale
@property (nonatomic, assign)       CGSize pickingImageSize; // default UIScreen.mainScreen.bounds.size
@property (nonatomic, assign)       BOOL allowPickingOriginal; // default NO
@end

#endif /* AGXWidget_AGXAssetPreviewController_h */
