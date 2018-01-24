//
//  AGXPhotoCommon.m
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

#import "AGXPhotoCommon.h"
#import "AGXWidgetLocalization.h"

@implementation AGXPhotoUtils

+ (BOOL)authorized {
    if (PHAuthorizationStatusNotDetermined == [PHPhotoLibrary authorizationStatus]) {
        dispatch_semaphore_t semaphore_t = dispatch_semaphore_create(0);
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
                dispatch_semaphore_signal(semaphore_t);
            }];
        });
        dispatch_semaphore_wait(semaphore_t, DISPATCH_TIME_FOREVER);
    }
    return(PHAuthorizationStatusAuthorized == [PHPhotoLibrary authorizationStatus]);
}

@end

@implementation AGXPhotoPickerSubController

- (void)dealloc {
    _delegate = nil;
    AGX_SUPER_DEALLOC;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:AGXWidgetLocalizedStringDefault
                                              (@"AGXPhotoPickerController.cancelButtonTitle",
                                               @"Cancel") style:UIBarButtonItemStylePlain target:self action:@selector(cancelButtonClick:)];
}

#pragma mark - user event

- (void)cancelButtonClick:(id)sender {
    if ([self.delegate respondsToSelector:@selector(pickerSubControllerDidCancel:)])
        [self.delegate pickerSubControllerDidCancel:self];
}

@end
