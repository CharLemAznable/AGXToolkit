//
//  AGXImagePickerController.h
//  AGXWidget
//
//  Created by Char Aznable on 2016/6/7.
//  Copyright © 2016 github.com/CharLemAznable. All rights reserved.
//

#ifndef AGXWidget_AGXImagePickerController_h
#define AGXWidget_AGXImagePickerController_h

#import <UIKit/UIKit.h>
#import <AGXCore/AGXCore/AGXArc.h>

@protocol AGXImagePickerControllerDelegate;

@interface AGXImagePickerController : UIImagePickerController
@property (nonatomic, AGX_WEAK) id<AGXImagePickerControllerDelegate> imagePickerDelegate;
@property (nonatomic, assign)   CGFloat pickingImageScale; // default UIScreen.mainScreen.scale
@property (nonatomic, assign)   CGSize pickingImageSize; // default UIScreen.mainScreen.bounds.size

+ (AGX_INSTANCETYPE)album;
+ (AGX_INSTANCETYPE)camera;
@end

@protocol AGXImagePickerControllerDelegate <NSObject>
@optional
- (void)imagePickerController:(AGXImagePickerController *)picker didFinishPickingImage:(UIImage *)image;
@end

#endif /* AGXWidget_AGXImagePickerController_h */
