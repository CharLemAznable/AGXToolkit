//
//  UIViewController+AGXCore.m
//  AGXCore
//
//  Created by Char Aznable on 16/2/17.
//  Copyright © 2016年 AI-CUC-EC. All rights reserved.
//

#import "UIViewController+AGXCore.h"
#import "AGXAdapt.h"
#import "AGXBundle.h"
#import "NSObject+AGXCore.h"

@category_implementation(UIViewController, AGXCore)

- (UIStatusBarStyle)statusBarStyle {
    return
#if __IPHONE_OS_VERSION_MIN_REQUIRED < 70000
    AGX_BEFORE_IOS7 ? [UIApplication sharedApplication].statusBarStyle :
#endif
    [AGXBundle viewControllerBasedStatusBarAppearance] ?
    [self p_statusBarStyle] : [UIApplication sharedApplication].statusBarStyle;
}

- (void)setStatusBarStyle:(UIStatusBarStyle)statusBarStyle {
    [self setStatusBarStyle:statusBarStyle animated:NO];
}

- (void)setStatusBarStyle:(UIStatusBarStyle)statusBarStyle animated:(BOOL)animated {
#if __IPHONE_OS_VERSION_MIN_REQUIRED < 70000
    if (AGX_BEFORE_IOS7) {
        [[UIApplication sharedApplication] setStatusBarStyle:statusBarStyle animated:animated];
        return;
    }
#endif
    if ([AGXBundle viewControllerBasedStatusBarAppearance]) {
        [self setP_statusBarStyle:statusBarStyle];
        agx_async_main([self setNeedsStatusBarAppearanceUpdate];);
    } else {
        AGX_CLANG_Diagnostic(-Wdeprecated-declarations,
        [[UIApplication sharedApplication] setStatusBarStyle:statusBarStyle animated:animated];)
    }
}

NSString *const p_statusBarStyleKey = @"p_statusBarStyle";

- (UIStatusBarStyle)p_statusBarStyle {
    return [[self propertyForAssociateKey:p_statusBarStyleKey] integerValue];
}

- (void)setP_statusBarStyle:(UIStatusBarStyle)p_statusBarStyle {
    [self setProperty:@(p_statusBarStyle) forAssociateKey:p_statusBarStyleKey];
}

- (UIStatusBarStyle)AGXCore_preferredStatusBarStyle {
    return [self p_statusBarStyle];
}

- (void)AGXCore_UIViewController_dealloc {
    [self assignProperty:nil forAssociateKey:p_statusBarStyleKey];
    
    [self AGXCore_UIViewController_dealloc];
}

+ (void)load {
    static dispatch_once_t once_t;
    dispatch_once(&once_t, ^{
        [self swizzleInstanceOriSelector:@selector(preferredStatusBarStyle)
                         withNewSelector:@selector(AGXCore_preferredStatusBarStyle)];
        [self swizzleInstanceOriSelector:NSSelectorFromString(@"dealloc")
                         withNewSelector:@selector(AGXCore_UIViewController_dealloc)];
    });
}

@end

@category_interface(UINavigationController, AGXCoreStatusBarStyle)
@end
@category_implementation(UINavigationController, AGXCoreStatusBarStyle)

- (UIStatusBarStyle)preferredStatusBarStyle {
    return [self p_statusBarStyle];
}

- (UIViewController *)childViewControllerForStatusBarStyle {
    return [self propertyForAssociateKey:p_statusBarStyleKey] ? nil : self.topViewController;
}

@end
