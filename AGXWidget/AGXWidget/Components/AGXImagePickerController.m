//
//  AGXImagePickerController.m
//  AGXWidget
//
//  Created by Char Aznable on 2016/6/7.
//  Copyright © 2016年 AI-CUC-EC. All rights reserved.
//

#import <AGXCore/AGXCore/NSObject+AGXCore.h>
#import <AGXCore/AGXCore/UIApplication+AGXCore.h>
#import "AGXImagePickerController.h"
#import "AGXProgressHUD.h"

@interface AGXImagePickerControllerInternalDelegate : NSObject <UINavigationControllerDelegate, UIImagePickerControllerDelegate>
@property (nonatomic, AGX_WEAK) id<UINavigationControllerDelegate, UIImagePickerControllerDelegate> delegate;
@end

@implementation AGXImagePickerControllerInternalDelegate

- (void)dealloc {
    _delegate = nil;
    AGX_SUPER_DEALLOC;
}

- (BOOL)respondsToSelector:(SEL)aSelector {
    return [super respondsToSelector:aSelector]
    || [self.delegate respondsToSelector:aSelector];
}

- (id)forwardingTargetForSelector:(SEL)aSelector {
    return self.delegate;
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    [UIApplication.sharedRootViewController dismissViewControllerAnimated:YES completion:nil];

    AGXImagePickerController *agxPicker = (AGXImagePickerController *)picker;
    if (![agxPicker.imagePickerDelegate respondsToSelector:@selector(imagePickerController:didFinishPickingImage:)]) return;
    NSString *key = agxPicker.allowsEditing ? UIImagePickerControllerEditedImage : UIImagePickerControllerOriginalImage;
    UIImage *image = [info objectForKey:key];
    if AGX_EXPECT_F(!image) return;

    agx_async_main([agxPicker.imagePickerDelegate imagePickerController:agxPicker didFinishPickingImage:image];);
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [UIApplication.sharedRootViewController dismissViewControllerAnimated:YES completion:nil];
}

@end

@implementation AGXImagePickerController {
    AGXImagePickerControllerInternalDelegate *_pickerInternalDelegate;
}

- (AGX_INSTANCETYPE)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if AGX_EXPECT_T(self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        _pickerInternalDelegate = [[AGXImagePickerControllerInternalDelegate alloc] init];
        self.delegate = _pickerInternalDelegate;
    }
    return self;
}

- (void)dealloc {
    _imagePickerDelegate = nil;
    AGX_RELEASE(_pickerInternalDelegate);
    AGX_SUPER_DEALLOC;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = UIColor.whiteColor;
}

- (void)setDelegate:(id<UINavigationControllerDelegate, UIImagePickerControllerDelegate>)delegate {
    if (!delegate || [delegate isKindOfClass:AGXImagePickerControllerInternalDelegate.class])  {
        [super setDelegate:delegate];
        return;
    }
    _pickerInternalDelegate.delegate = delegate;
}

- (void)setSourceType:(UIImagePickerControllerSourceType)sourceType {
    if AGX_EXPECT_F(![UIImagePickerController isSourceTypeAvailable:sourceType]) {
        agx_async_main
        ([UIApplication showMessageHUD:YES title:@"Failed" detail:@"Image source Unavailable." duration:2];);
        return;
    }
    [super setSourceType:sourceType];
}

- (void)presentAnimated:(BOOL)animated completion:(void (^)(void))completion {
    [UIApplication.sharedRootViewController presentViewController:self animated:animated completion:completion];
}

+ (AGX_INSTANCETYPE)album {
    return AGXImagePickerController.instance;
}

+ (AGX_INSTANCETYPE)camera {
    AGXImagePickerController *camera = AGXImagePickerController.instance;
    camera.sourceType = UIImagePickerControllerSourceTypeCamera;
    return camera;
}

@end
