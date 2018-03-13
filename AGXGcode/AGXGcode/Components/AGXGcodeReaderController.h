//
//  AGXGcodeReaderController.h
//  AGXGcode
//
//  Created by Char Aznable on 2016/8/11.
//  Copyright © 2016年 AI-CUC-EC. All rights reserved.
//

#ifndef AGXGcode_AGXGcodeReaderController_h
#define AGXGcode_AGXGcodeReaderController_h

#import <AGXWidget/AGXWidget/AGXPhotoPickerController.h>
#import "AGXDecodeHints.h"
#import "AGXGcodeResult.h"

@protocol AGXGcodeReaderControllerDelegate;

@interface AGXGcodeReaderController : AGXPhotoPickerController
@property (nonatomic, AGX_WEAK)     id<AGXGcodeReaderControllerDelegate> gcodeReaderDelegate;
@property (nonatomic, AGX_STRONG)   AGXDecodeHints *hint;
@end

@protocol AGXGcodeReaderControllerDelegate <NSObject>
@optional
- (void)gcodeReaderController:(AGXGcodeReaderController *)reader didReadResult:(AGXGcodeResult *)result;
- (void)gcodeReaderController:(AGXGcodeReaderController *)reader failedWithError:(NSError *)error;
@end

#endif /* AGXGcode_AGXGcodeReaderController_h */
