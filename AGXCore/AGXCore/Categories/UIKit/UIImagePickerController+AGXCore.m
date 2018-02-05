//
//  UIImagePickerController+AGXCore.m
//  AGXCore
//
//  Created by Char Aznable on 17/7/27.
//  Copyright © 2017年 AI-CUC-EC. All rights reserved.
//

#import "UIImagePickerController+AGXCore.h"
#import "AGXArc.h"
#import "NSObject+AGXCore.h"

@interface AGXImagePickerControllerNavigationInternalDelegate : NSObject <UINavigationControllerDelegate, UIImagePickerControllerDelegate>
@property (nonatomic, AGX_WEAK) id<UINavigationControllerDelegate, UIImagePickerControllerDelegate> delegate;
@end

@implementation AGXImagePickerControllerNavigationInternalDelegate

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

- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated {
    if ([self.delegate respondsToSelector:@selector(navigationController:willShowViewController:animated:)]) {
        [self.delegate navigationController:navigationController willShowViewController:viewController animated:animated];
    }
}

@end

@category_implementation(UIImagePickerController, AGXCore)

NSString *const agxImagePickerControllerNavigationInternalDelegateKey = @"agxImagePickerControllerNavigationInternalDelegate";

- (AGXImagePickerControllerNavigationInternalDelegate *)pickerNavigationInternalDelegate {
    return [self retainPropertyForAssociateKey:agxImagePickerControllerNavigationInternalDelegateKey];
}

- (void)setPickerNavigationInternalDelegate:(AGXImagePickerControllerNavigationInternalDelegate *)pickerNavigationInternalDelegate {
    [self setRetainProperty:pickerNavigationInternalDelegate forAssociateKey:agxImagePickerControllerNavigationInternalDelegateKey];
}

- (AGX_INSTANCETYPE)AGXCore_UIImagePickerController_initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    UIImagePickerController *instance = [self AGXCore_UIImagePickerController_initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    instance.pickerNavigationInternalDelegate = AGXImagePickerControllerNavigationInternalDelegate.instance;
    [instance AGXCore_UIImagePickerController_setDelegate:instance.pickerNavigationInternalDelegate];
    return instance;
}

- (void)AGXCore_UIImagePickerController_setDelegate:(id<UINavigationControllerDelegate, UIImagePickerControllerDelegate>)delegate {
    if (!delegate || [delegate isKindOfClass:AGXImagePickerControllerNavigationInternalDelegate.class]) {
        [self AGXCore_UIImagePickerController_setDelegate:delegate];
        return;
    }
    self.pickerNavigationInternalDelegate.delegate = delegate;
}

- (void)AGXCore_UIImagePickerController_dealloc {
    [self setRetainProperty:NULL forAssociateKey:agxImagePickerControllerNavigationInternalDelegateKey];
    [self AGXCore_UIImagePickerController_dealloc];
}

+ (void)load {
    agx_once
    ([UIImagePickerController
      swizzleInstanceOriSelector:@selector(initWithNibName:bundle:)
      withNewSelector:@selector(AGXCore_UIImagePickerController_initWithNibName:bundle:)];
     [UIImagePickerController
      swizzleInstanceOriSelector:@selector(setDelegate:)
      withNewSelector:@selector(AGXCore_UIImagePickerController_setDelegate:)];
     [UIImagePickerController
      swizzleInstanceOriSelector:NSSelectorFromString(@"dealloc")
      withNewSelector:@selector(AGXCore_UIImagePickerController_dealloc)];)
}

@end
