//
//  AGXGcodeCaptureViewController.h
//  AGXGcode
//
//  Created by Char Aznable on 2018/6/24.
//  Copyright © 2018年 AI-CUC-EC. All rights reserved.
//

#ifndef AGXGcode_AGXGcodeCaptureViewController_h
#define AGXGcode_AGXGcodeCaptureViewController_h

#import "AGXGcodeCaptureView.h"
#import "AGXGcodeReaderController.h"

@protocol AGXGcodeCaptureViewControllerDelegate;

@interface AGXGcodeCaptureViewController : UIViewController <AGXGcodeCaptureViewDelegate, AGXGcodeReaderControllerDelegate>
@property (nonatomic, AGX_WEAK)     id<AGXGcodeCaptureViewControllerDelegate> delegate;
@property (nonatomic, copy)         NSArray *formats;
@property (nonatomic, assign)       CGRect frameOfInterest;
@property (nonatomic, copy)         UIColor *tintColor; // default 4cd864
@property (nonatomic, assign)       BOOL autoDismissViewController; // default YES;
@property (nonatomic, assign)       BOOL allowPhotoPickingReader; // default YES;
@end

@protocol AGXGcodeCaptureViewControllerDelegate <NSObject>
@optional
- (void)gcodeCaptureViewControllerDidCancel:(AGXGcodeCaptureViewController *)captureViewController;
- (void)gcodeCaptureViewController:(AGXGcodeCaptureViewController *)captureViewController didReadResult:(AGXGcodeResult *)result;
- (void)gcodeCaptureViewController:(AGXGcodeCaptureViewController *)captureViewController failedWithError:(NSError *)error;
@end

#endif /* AGXGcode_AGXGcodeCaptureViewController_h */
