//
//  AGXGcodeReaderController.h
//  AGXGcode
//
//  Created by Char Aznable on 2016/8/11.
//  Copyright © 2016年 AI-CUC-EC. All rights reserved.
//

#ifndef AGXGcode_AGXGcodeReaderController_h
#define AGXGcode_AGXGcodeReaderController_h

#import <UIKit/UIKit.h>
#import <AGXCore/AGXCore/AGXArc.h>
#import "AGXDecodeHints.h"
#import "AGXGcodeResult.h"

@protocol AGXGcodeReaderControllerDelegate;

@interface AGXGcodeReaderController : UIImagePickerController
@property (nonatomic, AGX_WEAK)   id<AGXGcodeReaderControllerDelegate> gcodeReaderDelegate;
@property (nonatomic, AGX_STRONG) AGXDecodeHints *hint;

- (void)presentAnimated:(BOOL)animated completion:(void (^)(void))completion;
@end

@protocol AGXGcodeReaderControllerDelegate <NSObject>
@optional
- (void)gcodeReaderController:(AGXGcodeReaderController *)reader didReadResult:(AGXGcodeResult *)result;
- (void)gcodeReaderController:(AGXGcodeReaderController *)reader failedWithError:(NSError *)error;
@end

#endif /* AGXGcode_AGXGcodeReaderController_h */
