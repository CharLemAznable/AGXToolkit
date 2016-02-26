//
//  UIViewController+AGXCore.m
//  AGXCore
//
//  Created by Char Aznable on 16/2/17.
//  Copyright © 2016年 AI-CUC-EC. All rights reserved.
//

#import "UIViewController+AGXCore.h"
#import "AGXAdapt.h"
#import "NSObject+AGXCore.h"

@category_implementation(UIViewController, AGXCore)

- (UIStatusBarStyle)statusBarStyle {
    return
#if __IPHONE_OS_VERSION_MIN_REQUIRED < 70000
    BEFORE_IOS7 ? [UIApplication sharedApplication].statusBarStyle :
#endif
    [controllerForStatusBarStyle() p_StatusBarStyle];
}

- (void)setStatusBarStyle:(UIStatusBarStyle)statusBarStyle {
    [self setStatusBarStyle:statusBarStyle animated:NO];
}

- (void)setStatusBarStyle:(UIStatusBarStyle)statusBarStyle animated:(BOOL)animated {
#if __IPHONE_OS_VERSION_MIN_REQUIRED < 70000
    if (BEFORE_IOS7) {
        [[UIApplication sharedApplication] setStatusBarStyle:statusBarStyle animated:animated];
        return;
    }
#endif
    UIViewController *controller = controllerForStatusBarStyle();
    [controller setP_StatusBarStyle:statusBarStyle];
    [controller setNeedsStatusBarAppearanceUpdate];
}

NSString *const p_StatusBarStyleKey = @"p_StatusBarStyle";

- (UIStatusBarStyle)p_StatusBarStyle {
    return [[self propertyForAssociateKey:p_StatusBarStyleKey] integerValue];
}

- (void)setP_StatusBarStyle:(UIStatusBarStyle)p_StatusBarStyle {
    [self setProperty:@(p_StatusBarStyle) forAssociateKey:p_StatusBarStyleKey];
}

AGX_STATIC_INLINE UIViewController *controllerForStatusBarStyle() {
    UIViewController *root = [UIApplication sharedApplication].keyWindow.rootViewController;
    return root.childViewControllerForStatusBarStyle ?: root;
}

- (UIStatusBarStyle)agx_preferredStatusBarStyle {
    return [self p_StatusBarStyle];
}

- (void)agx_dealloc_uiviewcontroller_agxcore {
    [self assignProperty:nil forAssociateKey:p_StatusBarStyleKey];
    
    [self agx_dealloc_uiviewcontroller_agxcore];
}

+ (void)load {
    static dispatch_once_t once_t;
    dispatch_once(&once_t, ^{
        [self swizzleInstanceOriSelector:@selector(preferredStatusBarStyle)
                         withNewSelector:@selector(agx_preferredStatusBarStyle)];
        [self swizzleInstanceOriSelector:NSSelectorFromString(@"dealloc")
                         withNewSelector:@selector(agx_dealloc_uiviewcontroller_agxcore)];
    });
}

@end
