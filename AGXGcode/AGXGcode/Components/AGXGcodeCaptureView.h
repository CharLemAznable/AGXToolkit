//
//  AGXGcodeCaptureView.h
//  AGXGcode
//
//  Created by Char Aznable on 2016/8/12.
//  Copyright © 2016年 AI-CUC-EC. All rights reserved.
//

#ifndef AGXGcode_AGXGcodeCaptureView_h
#define AGXGcode_AGXGcodeCaptureView_h

#import <UIKit/UIKit.h>
#import <AGXCore/AGXCore/AGXArc.h>
#import "AGXGcodeResult.h"

@protocol AGXGcodeCaptureViewDelegate;

@interface AGXGcodeCaptureView : UIView
@property (nonatomic, AGX_WEAK) id<AGXGcodeCaptureViewDelegate> delegate;
@property (nonatomic, copy)     NSArray *formats;
@property (nonatomic, assign)   CGRect frameOfInterest;

- (void)startCapture;
- (void)stopCapture;
- (void)switchCaptureDevice;
@end

@protocol AGXGcodeCaptureViewDelegate <NSObject>
// should stop capture first, then process the result, restart capture if needed.
- (void)gcodeCaptureView:(AGXGcodeCaptureView *)captureView didReadResult:(AGXGcodeResult *)result;
@end

#endif /* AGXGcode_AGXGcodeCaptureView_h */
