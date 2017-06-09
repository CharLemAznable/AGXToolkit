//
//  UIViewController+AGXCore.m
//  AGXCore
//
//  Created by Char Aznable on 16/2/17.
//  Copyright © 2016年 AI-CUC-EC. All rights reserved.
//

#import "UIViewController+AGXCore.h"
#import "AGXArc.h"
#import "AGXBundle.h"
#import "NSObject+AGXCore.h"
#import "UIColor+AGXCore.h"
#import "UINavigationBar+AGXCore.h"

NSTimeInterval AGXStatusBarStyleSettingDuration = 0.2;

@category_implementation(UIViewController, AGXCore)

- (BOOL)isViewVisible {
    return (self.isViewLoaded && self.view.window);
}

- (BOOL)automaticallyAdjustsStatusBarStyle {
    return [self agxAutomaticallyAdjustsStatusBarStyle];
}

- (void)setAutomaticallyAdjustsStatusBarStyle:(BOOL)automaticallyAdjustsStatusBarStyle {
    [self setAGXAutomaticallyAdjustsStatusBarStyle:automaticallyAdjustsStatusBarStyle];
}

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

#pragma mark - associate

NSString *const agxAutomaticallyAdjustsStatusBarStyleKey = @"agxAutomaticallyAdjustsStatusBarStyle";

- (BOOL)agxAutomaticallyAdjustsStatusBarStyle {
    return [[self retainPropertyForAssociateKey:agxAutomaticallyAdjustsStatusBarStyleKey] boolValue];
}

- (void)setAGXAutomaticallyAdjustsStatusBarStyle:(BOOL)agxAutomaticallyAdjustsStatusBarStyle {
    [self setKVORetainProperty:@(agxAutomaticallyAdjustsStatusBarStyle) forAssociateKey:agxAutomaticallyAdjustsStatusBarStyleKey];
}

NSString *const agxStatusBarStyleKey = @"agxStatusBarStyle";

- (UIStatusBarStyle)agxStatusBarStyle {
    return ([self agxAutomaticallyAdjustsStatusBarStyle] ? [self p_automaticallyMeasuredStatusBarStyle]
            : [[self retainPropertyForAssociateKey:agxStatusBarStyleKey] integerValue]);
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

#pragma mark - KVO

NSString *const agxCoreUIViewControllerKVOContext = @"agxCoreUIViewControllerKVOContext";

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context {
    if (![agxCoreUIViewControllerKVOContext isEqual:(AGX_BRIDGE id)(context)]) {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
        return;
    }
    if (!self.viewVisible) return;
    if (self.tabBarController) [self.tabBarController p_automaticallySetStatusBarStyleAnimated:NO];
    else if (self.navigationController) [self.navigationController p_automaticallySetStatusBarStyleAnimated:NO];
    else [self p_automaticallySetStatusBarStyleAnimated:NO];
}

#pragma mark - swizzle

- (UIStatusBarStyle)AGXCore_UIViewController_preferredStatusBarStyle {
    return [self agxStatusBarStyle];
}

- (BOOL)AGXCore_UIViewController_prefersStatusBarHidden {
    return [self agxStatusBarHidden];
}

- (void)AGXCore_UIViewController_setView:(UIView *)view {
    if (self.isViewLoaded) [self.view removeObserver:self forKeyPath:@"backgroundColor"
                                             context:(AGX_BRIDGE void *)agxCoreUIViewControllerKVOContext];
    [view addObserver:self forKeyPath:@"backgroundColor" options:NSKeyValueObservingOptionNew
              context:(AGX_BRIDGE void *)agxCoreUIViewControllerKVOContext];

    [self AGXCore_UIViewController_setView:view];
}

- (void)AGXCore_UIViewController_dealloc {
    if (self.isViewLoaded) [self.view removeObserver:self forKeyPath:@"backgroundColor"
                                             context:(AGX_BRIDGE void *)agxCoreUIViewControllerKVOContext];
    [self setRetainProperty:NULL forAssociateKey:agxAutomaticallyAdjustsStatusBarStyleKey];
    [self setRetainProperty:NULL forAssociateKey:agxStatusBarStyleKey];
    [self setRetainProperty:NULL forAssociateKey:agxStatusBarHiddenKey];
    [self AGXCore_UIViewController_dealloc];
}

- (AGX_INSTANCETYPE)AGXCore_UIViewController_initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    UIViewController *instance = [self AGXCore_UIViewController_initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    instance.automaticallyAdjustsScrollViewInsets = NO; // change Defaults to NO
    instance.automaticallyAdjustsStatusBarStyle = YES;
    return instance;
}

- (void)AGXCore_UIViewController_viewWillAppear:(BOOL)animated {
    [self AGXCore_UIViewController_viewWillAppear:animated];
    if (self.tabBarController) [self.tabBarController p_automaticallySetStatusBarStyleAnimated:NO];
    else if (self.navigationController) [self.navigationController p_automaticallySetStatusBarStyleAnimated:NO];
    else [self p_automaticallySetStatusBarStyleAnimated:NO];
}

+ (void)load {
    static dispatch_once_t once_t;
    dispatch_once(&once_t, ^{
        [self swizzleInstanceOriSelector:@selector(preferredStatusBarStyle)
                         withNewSelector:@selector(AGXCore_UIViewController_preferredStatusBarStyle)];
        [self swizzleInstanceOriSelector:@selector(prefersStatusBarHidden)
                         withNewSelector:@selector(AGXCore_UIViewController_prefersStatusBarHidden)];
        [self swizzleInstanceOriSelector:@selector(setView:)
                         withNewSelector:@selector(AGXCore_UIViewController_setView:)];
        [self swizzleInstanceOriSelector:NSSelectorFromString(@"dealloc")
                         withNewSelector:@selector(AGXCore_UIViewController_dealloc)];
        [self swizzleInstanceOriSelector:@selector(initWithNibName:bundle:)
                         withNewSelector:@selector(AGXCore_UIViewController_initWithNibName:bundle:)];
        [self swizzleInstanceOriSelector:@selector(viewWillAppear:)
                         withNewSelector:@selector(AGXCore_UIViewController_viewWillAppear:)];
    });
}

#pragma mark - private methods

- (UIColor *)p_baseColorForAutoAdjustStatusBarStyle {
    return self.view.backgroundColor;
}

- (UIStatusBarStyle)p_automaticallyMeasuredStatusBarStyle {
    return (self.p_baseColorForAutoAdjustStatusBarStyle.colorShade == AGXColorShadeDark
            ? UIStatusBarStyleLightContent : UIStatusBarStyleDefault);
}

- (void)p_automaticallySetStatusBarStyleAnimated:(BOOL)animated {
    if ([self agxAutomaticallyAdjustsStatusBarStyle]) {
        if ([AGXBundle viewControllerBasedStatusBarAppearance]) {
            if (animated) [UIView animateWithDuration:AGXStatusBarStyleSettingDuration
                                           animations:^{ [self setNeedsStatusBarAppearanceUpdate]; }];
            else agx_async_main([self setNeedsStatusBarAppearanceUpdate];)
        } else {
            AGX_CLANG_Diagnostic
            (-Wdeprecated-declarations,
             [[UIApplication sharedApplication]
              setStatusBarStyle:[self p_automaticallyMeasuredStatusBarStyle] animated:animated];)
        }
    }
}

@end

@category_interface(UITabBarController, AGXCoreStatusBarStyle)
@end
@category_implementation(UITabBarController, AGXCoreStatusBarStyle)

- (UIStatusBarStyle)preferredStatusBarStyle {
    return [self agxStatusBarStyle];
}

- (BOOL)prefersStatusBarHidden {
    return [self agxStatusBarHidden];
}

- (UIViewController *)childViewControllerForStatusBarStyle {
    return ([self agxAutomaticallyAdjustsStatusBarStyle] ||
            [self retainPropertyForAssociateKey:agxStatusBarStyleKey] ? nil : self.selectedViewController);
}

- (UIViewController *)childViewControllerForStatusBarHidden {
    return [self retainPropertyForAssociateKey:agxStatusBarHiddenKey] ? nil : self.selectedViewController;
}

- (UIColor *)p_baseColorForAutoAdjustStatusBarStyle {
    return self.selectedViewController.p_baseColorForAutoAdjustStatusBarStyle;
}

#pragma mark - swizzle

- (void)AGXCore_UITabBarController_setSelectedViewController:(UIViewController *)selectedViewController {
    [self AGXCore_UITabBarController_setSelectedViewController:selectedViewController];
    [self p_automaticallySetStatusBarStyleAnimated:NO];
}

- (void)AGXCore_UITabBarController_setSelectedIndex:(NSUInteger)selectedIndex {
    [self AGXCore_UITabBarController_setSelectedIndex:selectedIndex];
    [self p_automaticallySetStatusBarStyleAnimated:NO];
}

+ (void)load {
    static dispatch_once_t once_t;
    dispatch_once(&once_t, ^{
        [self swizzleInstanceOriSelector:@selector(setSelectedViewController:)
                         withNewSelector:@selector(AGXCore_UITabBarController_setSelectedViewController:)];
        [self swizzleInstanceOriSelector:@selector(setSelectedIndex:)
                         withNewSelector:@selector(AGXCore_UITabBarController_setSelectedIndex:)];
    });
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
    return ([self agxAutomaticallyAdjustsStatusBarStyle] ||
            [self retainPropertyForAssociateKey:agxStatusBarStyleKey] ? nil : self.topViewController);
}

- (UIViewController *)childViewControllerForStatusBarHidden {
    return [self retainPropertyForAssociateKey:agxStatusBarHiddenKey] ? nil : self.topViewController;
}

- (UIColor *)p_baseColorForAutoAdjustStatusBarStyle {
    return (self.navigationBarHidden ? self.topViewController.p_baseColorForAutoAdjustStatusBarStyle
            : (self.navigationBar.currentBackgroundColor ?: self.navigationBar.barTintColor));
}

#pragma mark - swizzle

- (void)AGXCore_UINavigationController_setNavigationBarHidden:(BOOL)hidden animated:(BOOL)animated {
    [self AGXCore_UINavigationController_setNavigationBarHidden:hidden animated:animated];
    [self p_automaticallySetStatusBarStyleAnimated:animated];
}

+ (void)load {
    static dispatch_once_t once_t;
    dispatch_once(&once_t, ^{
        [self swizzleInstanceOriSelector:@selector(setNavigationBarHidden:animated:)
                         withNewSelector:@selector(AGXCore_UINavigationController_setNavigationBarHidden:animated:)];
    });
}

@end

@category_interface(UINavigationBar, AGXCoreStatusBarStyle)
@end
@category_implementation(UINavigationBar, AGXCoreStatusBarStyle)

- (void)AGXCore_UINavigationBar_setBarTintColor:(UIColor *)barTintColor {
    [self AGXCore_UINavigationBar_setBarTintColor:barTintColor];
    [self.navigationController p_automaticallySetStatusBarStyleAnimated:NO];
}

- (void)AGXCore_UINavigationBar_setBackgroundImage:(UIImage *)backgroundImage forBarPosition:(UIBarPosition)barPosition barMetrics:(UIBarMetrics)barMetrics {
    [self AGXCore_UINavigationBar_setBackgroundImage:backgroundImage forBarPosition:barPosition barMetrics:barMetrics];
    [self.navigationController p_automaticallySetStatusBarStyleAnimated:NO];
}

+ (void)load {
    static dispatch_once_t once_t;
    dispatch_once(&once_t, ^{
        [self swizzleInstanceOriSelector:@selector(setBarTintColor:)
                         withNewSelector:@selector(AGXCore_UINavigationBar_setBarTintColor:)];
        [self swizzleInstanceOriSelector:@selector(setBackgroundImage:forBarPosition:barMetrics:)
                         withNewSelector:@selector(AGXCore_UINavigationBar_setBackgroundImage:forBarPosition:barMetrics:)];
    });
}

@end
