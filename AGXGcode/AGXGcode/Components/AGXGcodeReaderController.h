//
//  AGXGcodeReaderController.h
//  AGXGcode
//
//  Created by Char Aznable on 16/8/11.
//  Copyright © 2016年 AI-CUC-EC. All rights reserved.
//

#ifndef AGXGcode_AGXGcodeReaderController_h
#define AGXGcode_AGXGcodeReaderController_h

#if __has_include(<AGXWidget/AGXWidget/AGXImagePickerController.h>)

#import <AGXWidget/AGXWidget/AGXImagePickerController.h>
#import "AGXDecodeHints.h"
#import "AGXGcodeResult.h"

@protocol AGXGcodeReaderControllerDelegate;

@interface AGXGcodeReaderController : AGXImagePickerController
@property (nonatomic, AGX_WEAK)   id<AGXGcodeReaderControllerDelegate> gcodeReaderDelegate;
@property (nonatomic, AGX_STRONG) AGXDecodeHints *hint;
@end

@protocol AGXGcodeReaderControllerDelegate <NSObject>
@optional
- (void)gcodeReaderController:(AGXGcodeReaderController *)reader didReadResult:(AGXGcodeResult *)result;
- (void)gcodeReaderController:(AGXGcodeReaderController *)reader failedWithError:(NSError *)error;
@end

#endif // __has_include(<AGXWidget/AGXWidget/AGXImagePickerController.h>)

#endif /* AGXGcode_AGXGcodeReaderController_h */
