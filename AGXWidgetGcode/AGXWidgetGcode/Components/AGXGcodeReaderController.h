//
//  AGXGcodeReaderController.h
//  AGXWidgetGcode
//
//  Created by Char Aznable on 2018/6/27.
//  Copyright © 2018 github.com/CharLemAznable. All rights reserved.
//

#ifndef AGXWidgetGcode_AGXGcodeReaderController_h
#define AGXWidgetGcode_AGXGcodeReaderController_h

#import <AGXWidget/AGXWidget/AGXPhotoPickerController.h>
#import <AGXGcode/AGXGcode/AGXDecodeHints.h>
#import <AGXGcode/AGXGcode/AGXGcodeResult.h>

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

#endif /* AGXWidgetGcode_AGXGcodeReaderController_h */
