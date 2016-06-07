//
//  AGXImagePickerController.m
//  AGXWidget
//
//  Created by Char Aznable on 16/6/7.
//  Copyright © 2016年 AI-CUC-EC. All rights reserved.
//

#import "AGXImagePickerController.h"
#import <AGXCore/AGXCore/AGXObjC.h>
#import <AGXCore/AGXCore/NSData+AGXCore.h>
#import <AGXCore/AGXCore/UIApplication+AGXCore.h>

@interface AGXImagePickerControllerDelegate : NSObject <UINavigationControllerDelegate, UIImagePickerControllerDelegate>
@end

@implementation AGXImagePickerController {
    AGXImagePickerControllerDelegate *_retainedDelegate;
}

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        _retainedDelegate = [[AGXImagePickerControllerDelegate alloc] init];
        self.delegate = _retainedDelegate;
    }
    return self;
}

- (void)dealloc {
    _pickedTarget = nil;
    AGX_RELEASE(_retainedDelegate);
    AGX_SUPER_DEALLOC;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
}

@end

@implementation AGXImagePickerControllerDelegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    [UIApplication.sharedRootViewController dismissViewControllerAnimated:YES completion:nil];

    AGXImagePickerController *agxPicker = (AGXImagePickerController *)picker;
    if (!agxPicker.pickedTarget || !agxPicker.pickedAction ||
        ![agxPicker.pickedTarget respondsToSelector:agxPicker.pickedAction]) return;
    NSString *key = agxPicker.allowsEditing ? UIImagePickerControllerEditedImage : UIImagePickerControllerOriginalImage;
    UIImage *photo = [info objectForKey:key];
    if (!photo) return;

    NSString *photoURLString = [NSString stringWithFormat:@"data:image/png;base64,%@",
                                UIImagePNGRepresentation(photo).base64EncodedString];
    [agxPicker.pickedTarget performSelector:agxPicker.pickedAction withObject:photoURLString];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [UIApplication.sharedRootViewController dismissViewControllerAnimated:YES completion:nil];
}

- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated {
    viewController.automaticallyAdjustsScrollViewInsets = YES; // fix scroll view insets
}

@end
