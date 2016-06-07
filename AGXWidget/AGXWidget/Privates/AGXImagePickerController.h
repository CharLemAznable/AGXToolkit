//
//  AGXImagePickerController.h
//  AGXWidget
//
//  Created by Char Aznable on 16/6/7.
//  Copyright © 2016年 AI-CUC-EC. All rights reserved.
//

#ifndef AGXWidget_AGXImagePickerController_h
#define AGXWidget_AGXImagePickerController_h

#import <UIKit/UIKit.h>
#import <AGXCore/AGXCore/AGXArc.h>

@interface AGXImagePickerController : UIImagePickerController
@property (nonatomic, AGX_WEAK) id  pickedTarget;
@property (nonatomic, assign)   SEL pickedAction;
@end

#endif /* AGXWidget_AGXImagePickerController_h */
