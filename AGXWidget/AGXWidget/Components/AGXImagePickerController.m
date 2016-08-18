//
//  AGXImagePickerController.m
//  AGXWidget
//
//  Created by Char Aznable on 16/6/7.
//  Copyright © 2016年 AI-CUC-EC. All rights reserved.
//

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
    if (!image) return;

    [agxPicker.imagePickerDelegate imagePickerController:agxPicker didFinishPickingImage:image];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [UIApplication.sharedRootViewController dismissViewControllerAnimated:YES completion:nil];
}

- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated {
    if ([self.delegate respondsToSelector:@selector(navigationController:willShowViewController:animated:)]) {
        [self.delegate navigationController:navigationController willShowViewController:viewController animated:animated];
    }
    viewController.automaticallyAdjustsScrollViewInsets = YES; // fix scroll view insets
}

@end

@implementation AGXImagePickerController {
    AGXImagePickerControllerInternalDelegate *_pickerInternalDelegate;
}

- (AGX_INSTANCETYPE)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
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
    self.view.backgroundColor = [UIColor whiteColor];
}

- (void)setDelegate:(id<UINavigationControllerDelegate, UIImagePickerControllerDelegate>)delegate {
    if (!delegate || [delegate isKindOfClass:[AGXImagePickerControllerInternalDelegate class]])  {
        [super setDelegate:delegate];
        return;
    }
    _pickerInternalDelegate.delegate = delegate;
}

- (void)setSourceType:(UIImagePickerControllerSourceType)sourceType {
    if (![UIImagePickerController isSourceTypeAvailable:sourceType]) {
        agx_async_main
        ([UIApplication showMessageHUD:YES title:@"Failed" detail:@"Image source Unavailable." duration:2];)
        return;
    }
    [super setSourceType:sourceType];
}

- (void)presentAnimated:(BOOL)animated completion:(void (^)())completion {
    [UIApplication.sharedRootViewController presentViewController:self animated:animated completion:completion];
}

@end
