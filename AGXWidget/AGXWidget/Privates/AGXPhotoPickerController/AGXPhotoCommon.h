//
//  AGXPhotoCommon.h
//  AGXWidget
//
//  Created by Char Aznable on 2018/1/18.
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

#ifndef AGXWidget_AGXPhotoCommon_h
#define AGXWidget_AGXPhotoCommon_h

#import <Photos/Photos.h>
#import <AGXCore/AGXCore/AGXArc.h>

typedef struct AGXPhotoAuthorizationStatus {
    BOOL authorized;
    BOOL firstRequestAuthorization;
} AGXPhotoAuthorizationStatus;

@interface AGXPhotoUtils : NSObject
+ (AGXPhotoAuthorizationStatus)authorizationStatus;
@end

@protocol AGXPhotoPickerSubControllerDelegate;

@interface AGXPhotoPickerSubController : UIViewController
@property (nonatomic, AGX_WEAK) id<AGXPhotoPickerSubControllerDelegate> delegate;
@end

@protocol AGXPhotoPickerSubControllerDelegate <NSObject>
@required
- (void)pickerSubControllerDidCancel:(AGXPhotoPickerSubController *)pickerSubController;
@end

#endif /* AGXWidget_AGXPhotoCommon_h */