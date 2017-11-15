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

@protocol AGXImagePickerControllerDelegate;

@interface AGXImagePickerController : UIImagePickerController
@property (nonatomic, AGX_WEAK) id<AGXImagePickerControllerDelegate> imagePickerDelegate;

+ (AGX_INSTANCETYPE)album;
+ (AGX_INSTANCETYPE)camera;
- (void)presentAnimated:(BOOL)animated completion:(void (^)(void))completion;
@end

@protocol AGXImagePickerControllerDelegate <NSObject>
@optional
- (void)imagePickerController:(AGXImagePickerController *)picker didFinishPickingImage:(UIImage *)image;
@end

#endif /* AGXWidget_AGXImagePickerController_h */
