//
//  UIViewController+AGXCore.m
//  AGXCore
//
//  Created by Char Aznable on 16/2/17.
//  Copyright © 2016年 AI-CUC-EC. All rights reserved.
//

#import "UIViewController+AGXCore.h"
#import "AGXBundle.h"
#import "NSObject+AGXCore.h"

NSTimeInterval AGXStatusBarStyleSettingDuration = 0.2;

@category_implementation(UIViewController, AGXCore)

- (UIStatusBarStyle)statusBarStyle {
    return [AGXBundle viewControllerBasedStatusBarAppearance] ?
    [self agxStatusBarStyle] : [UIApplication sharedApplication].statusBarStyle;
}

- (void)setStatusBarStyle:(UIStatusBarStyle)statusBarStyle {
    [self setStatusBarStyle:statusBarStyle animated:NO];
}

- (void)setStatusBarStyle:(UIStatusBarStyle)statusBarStyle animated:(BOOL)animated {
    if ([AGXBundle viewControllerBasedStatusBarAppearance]) {
        [self setAGXStatusBarStyle:statusBarStyle];
        if (animated) [UIView animateWithDuration:AGXStatusBarStyleSettingDuration
                                       animations:^{ [self setNeedsStatusBarAppearanceUpdate]; }];
        else agx_async_main([self setNeedsStatusBarAppearanceUpdate];)
    } else {
        AGX_CLANG_Diagnostic
        (-Wdeprecated-declarations,
         [[UIApplication sharedApplication]
          setStatusBarStyle:statusBarStyle animated:animated];)
    }
}

- (BOOL)isStatusBarHidden {
    return [AGXBundle viewControllerBasedStatusBarAppearance] ?
    [self agxStatusBarHidden] : [UIApplication sharedApplication].statusBarHidden;
}

- (void)setStatusBarHidden:(BOOL)statusBarHidden {
    [self setStatusBarHidden:statusBarHidden animated:NO];
}

- (void)setStatusBarHidden:(BOOL)statusBarHidden animated:(BOOL)animated {
    if ([AGXBundle viewControllerBasedStatusBarAppearance]) {
        [self setAGXStatusBarHidden:statusBarHidden];
        if (animated) [UIView animateWithDuration:AGXStatusBarStyleSettingDuration
                                       animations:^{ [self setNeedsStatusBarAppearanceUpdate]; }];
        else agx_async_main([self setNeedsStatusBarAppearanceUpdate];)
    } else {
        AGX_CLANG_Diagnostic
        (-Wdeprecated-declarations,
         [[UIApplication sharedApplication]
          setStatusBarHidden:statusBarHidden withAnimation:UIStatusBarAnimationFade];)
    }
}

#pragma mark - associate

NSString *const agxStatusBarStyleKey = @"agxStatusBarStyle";

- (UIStatusBarStyle)agxStatusBarStyle {
    return [[self retainPropertyForAssociateKey:agxStatusBarStyleKey] integerValue];
}

- (void)setAGXStatusBarStyle:(UIStatusBarStyle)agxStatusBarStyle {
    [self setKVORetainProperty:@(agxStatusBarStyle) forAssociateKey:agxStatusBarStyleKey];
}

NSString *const agxStatusBarHiddenKey = @"agxStatusBarHidden";

- (BOOL)agxStatusBarHidden {
    return [[self retainPropertyForAssociateKey:agxStatusBarHiddenKey] boolValue];
}

- (void)setAGXStatusBarHidden:(BOOL)agxStatusBarHidden {
    [self setKVORetainProperty:@(agxStatusBarHidden) forAssociateKey:agxStatusBarHiddenKey];
}

#pragma mark - swizzle

- (UIStatusBarStyle)AGXCore_preferredStatusBarStyle {
    return [self agxStatusBarStyle];
}

- (BOOL)AGXCore_prefersStatusBarHidden {
    return [self agxStatusBarHidden];
}

- (void)AGXCore_UIViewController_dealloc {
    [self setRetainProperty:NULL forAssociateKey:agxStatusBarStyleKey];
    [self setRetainProperty:NULL forAssociateKey:agxStatusBarHiddenKey];
    [self AGXCore_UIViewController_dealloc];
}

- (AGX_INSTANCETYPE)AGXCore_initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    UIViewController *instance = [self AGXCore_initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    instance.automaticallyAdjustsScrollViewInsets = NO; // change Defaults to NO
    return instance;
}

+ (void)load {
    static dispatch_once_t once_t;
    dispatch_once(&once_t, ^{
        [self swizzleInstanceOriSelector:@selector(preferredStatusBarStyle)
                         withNewSelector:@selector(AGXCore_preferredStatusBarStyle)];
        [self swizzleInstanceOriSelector:@selector(prefersStatusBarHidden)
                         withNewSelector:@selector(AGXCore_prefersStatusBarHidden)];
        [self swizzleInstanceOriSelector:NSSelectorFromString(@"dealloc")
                         withNewSelector:@selector(AGXCore_UIViewController_dealloc)];
        [self swizzleInstanceOriSelector:@selector(initWithNibName:bundle:)
                         withNewSelector:@selector(AGXCore_initWithNibName:bundle:)];
    });
}

- (UINavigationBar *)navigationBar {
    return self.navigationController.navigationBar;
}

- (BOOL)isNavigationBarHidden {
    return self.navigationController ? self.navigationController.navigationBarHidden : YES;
}

- (void)setNavigationBarHidden:(BOOL)navigationBarHidden {
    self.navigationController.navigationBarHidden = navigationBarHidden;
}

- (void)setNavigationBarHidden:(BOOL)hidden animated:(BOOL)animated {
    [self.navigationController setNavigationBarHidden:hidden animated:animated];
}

@end

@category_interface(UINavigationController, AGXCoreStatusBarStyle)
@end
@category_implementation(UINavigationController, AGXCoreStatusBarStyle)

- (UIStatusBarStyle)preferredStatusBarStyle {
    return [self agxStatusBarStyle];
}

- (BOOL)prefersStatusBarHidden {
    return [self agxStatusBarHidden];
}

- (UIViewController *)childViewControllerForStatusBarStyle {
    return [self retainPropertyForAssociateKey:agxStatusBarStyleKey] ? nil : self.topViewController;
}

- (UIViewController *)childViewControllerForStatusBarHidden {
    return [self retainPropertyForAssociateKey:agxStatusBarHiddenKey] ? nil : self.topViewController;
}

@end
