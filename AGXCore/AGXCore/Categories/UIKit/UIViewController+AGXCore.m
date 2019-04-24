//
//  UIViewController+AGXCore.m
//  AGXCore
//
//  Created by Char Aznable on 2016/2/17.
//  Copyright © 2016 github.com/CharLemAznable. All rights reserved.
//

#import "UIViewController+AGXCore.h"
#import "AGXArc.h"
#import "AGXGeometry.h"
#import "AGXAppInfo.h"
#import "NSObject+AGXCore.h"
#import "UIApplication+AGXCore.h"
#import "UIColor+AGXCore.h"
#import "UINavigationBar+AGXCore.h"
#import "UIScrollView+AGXCore.h"

NSTimeInterval AGXStatusBarStyleSettingDuration = 0.2;

@category_implementation(UIViewController, AGXCore)

- (BOOL)isViewVisible {
    return(self.isViewLoaded && self.view.window);
}

- (BOOL)automaticallyAdjustsStatusBarStyle {
    return self.agxAutomaticallyAdjustsStatusBarStyle;
}

- (void)setAutomaticallyAdjustsStatusBarStyle:(BOOL)automaticallyAdjustsStatusBarStyle {
    [self setAGXAutomaticallyAdjustsStatusBarStyle:automaticallyAdjustsStatusBarStyle];
}

- (UIStatusBarStyle)statusBarStyle {
    return AGXAppInfo.viewControllerBasedStatusBarAppearance ?
    self.agxStatusBarStyle : UIApplication.sharedApplication.statusBarStyle;
}

- (void)setStatusBarStyle:(UIStatusBarStyle)statusBarStyle {
    [self setStatusBarStyle:statusBarStyle animated:NO];
}

- (void)setStatusBarStyle:(UIStatusBarStyle)statusBarStyle animated:(BOOL)animated {
    if (AGXAppInfo.viewControllerBasedStatusBarAppearance) {
        [self setAGXStatusBarStyle:statusBarStyle];
        if (animated) agx_async_main([UIView animateWithDuration:AGXStatusBarStyleSettingDuration
                                                      animations:^{ [self setNeedsStatusBarAppearanceUpdate]; }];);
        else agx_async_main([self setNeedsStatusBarAppearanceUpdate];);
    } else {
        AGX_CLANG_Diagnostic
        (-Wdeprecated-declarations,
         [UIApplication.sharedApplication
          setStatusBarStyle:statusBarStyle animated:animated];)
    }
}

- (BOOL)isStatusBarHidden {
    return AGXAppInfo.viewControllerBasedStatusBarAppearance ?
    self.agxStatusBarHidden : UIApplication.sharedApplication.statusBarHidden;
}

- (void)setStatusBarHidden:(BOOL)statusBarHidden {
    [self setStatusBarHidden:statusBarHidden animated:NO];
}

- (void)setStatusBarHidden:(BOOL)statusBarHidden animated:(BOOL)animated {
    if (AGXAppInfo.viewControllerBasedStatusBarAppearance) {
        [self setAGXStatusBarHidden:statusBarHidden];
        if (animated) agx_async_main([UIView animateWithDuration:AGXStatusBarStyleSettingDuration
                                                      animations:^{ [self setNeedsStatusBarAppearanceUpdate]; }];);
        else agx_async_main([self setNeedsStatusBarAppearanceUpdate];);
    } else {
        AGX_CLANG_Diagnostic
        (-Wdeprecated-declarations,
         [UIApplication.sharedApplication
          setStatusBarHidden:statusBarHidden withAnimation:
          animated?UIStatusBarAnimationFade:UIStatusBarAnimationNone];)
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

- (UIToolbar *)toolbar {
    return self.navigationController.toolbar;
}

- (BOOL)isToolbarHidden {
    return self.navigationController ? self.navigationController.toolbarHidden : YES;
}

- (void)setToolbarHidden:(BOOL)toolbarHidden {
    self.navigationController.toolbarHidden = toolbarHidden;
}

- (void)setToolbarHidden:(BOOL)hidden animated:(BOOL)animated {
    [self.navigationController setToolbarHidden:hidden animated:animated];
}

- (BOOL)hidesBarsOnSwipe {
    return self.navigationController ? self.navigationController.hidesBarsOnSwipe : YES;
}

- (void)setHidesBarsOnSwipe:(BOOL)hidesBarsOnSwipe {
    self.navigationController.hidesBarsOnSwipe = hidesBarsOnSwipe;
}

- (BOOL)hidesBarsOnTap {
    return self.navigationController ? self.navigationController.hidesBarsOnTap : YES;
}

- (void)setHidesBarsOnTap:(BOOL)hidesBarsOnTap {
    self.navigationController.hidesBarsOnTap = hidesBarsOnTap;
}

- (UITabBar *)tabBar {
    return self.tabBarController.tabBar;
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
    return(self.agxAutomaticallyAdjustsStatusBarStyle ? self.p_automaticallyMeasuredStatusBarStyle
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
    if (self.p_isInputController) return;
    if (self.tabBarController) [self.tabBarController p_automaticallySetStatusBarStyleAnimated:NO];
    else if (self.navigationController) [self.navigationController p_automaticallySetStatusBarStyleAnimated:NO];
    else [self p_automaticallySetStatusBarStyleAnimated:NO];
}

#pragma mark - swizzle

+ (BOOL)AGXCore_UIViewController_doesOverrideViewControllerMethod:(SEL)selector {
    // fix status bar hidden bug in iOS11
    if (@selector(preferredStatusBarStyle) == selector ||
        @selector(prefersStatusBarHidden) == selector) {
        return YES;
    }
    return [self AGXCore_UIViewController_doesOverrideViewControllerMethod:selector];
}

- (UIStatusBarStyle)AGXCore_UIViewController_preferredStatusBarStyle {
    return self.agxStatusBarStyle;
}

- (BOOL)AGXCore_UIViewController_prefersStatusBarHidden {
    return self.agxStatusBarHidden;
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
    [instance AGXCore_UIViewController_setAutomaticallyAdjustsScrollViewInsets:NO]; // change Defaults to NO
    instance.automaticallyAdjustsStatusBarStyle = YES;
    return instance;
}

- (BOOL)AGXCore_UIViewController_automaticallyAdjustsScrollViewInsets {
    return NO;
}

- (void)AGXCore_UIViewController_setAutomaticallyAdjustsScrollViewInsets:(BOOL)automaticallyAdjustsScrollViewInsets {}

- (void)AGXCore_UIViewController_viewWillAppear:(BOOL)animated {
    [self AGXCore_UIViewController_viewWillAppear:animated];
    if (self.p_isInputController) return;
    if (self.tabBarController) [self.tabBarController p_automaticallySetStatusBarStyleAnimated:NO];
    else if (self.navigationController) [self.navigationController p_automaticallySetStatusBarStyleAnimated:NO];
    else [self p_automaticallySetStatusBarStyleAnimated:NO];
}

- (void)AGXCore_UIViewController_viewDidLayoutSubviews {
    [self AGXCore_UIViewController_viewDidLayoutSubviews];
    [self p_adjustsScrollViewContentInsetByBars];
}

- (void)AGXCore_UIViewController_presentViewController:(UIViewController *)viewControllerToPresent animated:(BOOL)flag completion:(void (^)(void))completion {
    if (!viewControllerToPresent) {
        AGXLog(@"[%@ %@] attempt to present nil view controller",
               NSStringFromClass(self.class), NSStringFromSelector(_cmd));
        return;
    }
    [self AGXCore_UIViewController_presentViewController:viewControllerToPresent
                                                animated:flag completion:completion];
}

+ (void)load {
    agx_once
    ([UIViewController swizzleClassOriSelector:NSSelectorFromString(@"doesOverrideViewControllerMethod:")
                               withNewSelector:@selector(AGXCore_UIViewController_doesOverrideViewControllerMethod:)];
     [UIViewController swizzleInstanceOriSelector:@selector(preferredStatusBarStyle)
                                  withNewSelector:@selector(AGXCore_UIViewController_preferredStatusBarStyle)];
     [UIViewController swizzleInstanceOriSelector:@selector(prefersStatusBarHidden)
                                  withNewSelector:@selector(AGXCore_UIViewController_prefersStatusBarHidden)];
     [UIViewController swizzleInstanceOriSelector:@selector(setView:)
                                  withNewSelector:@selector(AGXCore_UIViewController_setView:)];
     [UIViewController swizzleInstanceOriSelector:NSSelectorFromString(@"dealloc")
                                  withNewSelector:@selector(AGXCore_UIViewController_dealloc)];
     [UIViewController swizzleInstanceOriSelector:@selector(initWithNibName:bundle:)
                                  withNewSelector:@selector(AGXCore_UIViewController_initWithNibName:bundle:)];
     [UIViewController swizzleInstanceOriSelector:@selector(automaticallyAdjustsScrollViewInsets)
                                  withNewSelector:@selector(AGXCore_UIViewController_automaticallyAdjustsScrollViewInsets)];
     [UIViewController swizzleInstanceOriSelector:@selector(setAutomaticallyAdjustsScrollViewInsets:)
                                  withNewSelector:@selector(AGXCore_UIViewController_setAutomaticallyAdjustsScrollViewInsets:)];
     [UIViewController swizzleInstanceOriSelector:@selector(viewWillAppear:)
                                  withNewSelector:@selector(AGXCore_UIViewController_viewWillAppear:)];
     [UIViewController swizzleInstanceOriSelector:@selector(viewDidLayoutSubviews)
                                  withNewSelector:@selector(AGXCore_UIViewController_viewDidLayoutSubviews)];
     [UIViewController swizzleInstanceOriSelector:@selector(presentViewController:animated:completion:)
                                  withNewSelector:@selector(AGXCore_UIViewController_presentViewController:animated:completion:)];);
}

#pragma mark - private methods

- (UIColor *)p_baseColorForAutoAdjustStatusBarStyle {
    return(self.navigationBarHidden ? self.view.backgroundColor
           : (self.navigationBar.currentBackgroundColor ?: self.navigationBar.barTintColor));
}

- (UIStatusBarStyle)p_automaticallyMeasuredStatusBarStyle {
    return(AGXColorShadeDark == self.p_baseColorForAutoAdjustStatusBarStyle.colorShade
           ? UIStatusBarStyleLightContent : UIStatusBarStyleDefault);
}

- (void)p_automaticallySetStatusBarStyleAnimated:(BOOL)animated {
    if (self.agxAutomaticallyAdjustsStatusBarStyle) {
        if (AGXAppInfo.viewControllerBasedStatusBarAppearance) {
            if (animated) agx_async_main([UIView animateWithDuration:AGXStatusBarStyleSettingDuration
                                                          animations:^{ [self setNeedsStatusBarAppearanceUpdate]; }];);
            else agx_async_main([self setNeedsStatusBarAppearanceUpdate];);
        } else {
            AGX_CLANG_Diagnostic
            (-Wdeprecated-declarations,
             [[UIApplication sharedApplication]
              setStatusBarStyle:self.p_automaticallyMeasuredStatusBarStyle animated:animated]);
        }
    }
}

- (BOOL)p_isInputController {
    return([self isKindOfClass:UIInputViewController.class] ||
           [self isKindOfClass:NSClassFromString(@"UIInputWindowController")]);
}

- (void)p_adjustsScrollViewContentInsetByBars {
    if (@available(iOS 11.0, *)) { return; } // use contentInsetAdjustmentBehavior after iOS11, return directly

    CGRect statusBarFrame = [self.view convertRect:UIApplication.sharedApplication.statusBarFrame fromView:nil];
    CGRect navigationBarFrame = [self.view convertRect:self.navigationBarHidden
                                 ? AGX_CGRectMake(AGX_CGRectGetBottomLeft(statusBarFrame), CGSizeZero)
                                                      : self.navigationBar.frame fromView:self.navigationBarHidden?nil:self.navigationBar.superview];
    CGRect toolbarFrame = [self.view convertRect:self.toolbarHidden
                           ? AGX_CGRectMake(AGX_CGRectGetBottomLeft(UIApplication.sharedKeyWindow.frame), CGSizeZero)
                                                : self.toolbar.frame fromView:self.toolbarHidden?nil:self.toolbar.superview];
    CGRect tabBarFrame = [self.view convertRect:(self.tabBar?self.tabBar.hidden:YES)
                          ? AGX_CGRectMake(AGX_CGRectGetBottomLeft(UIApplication.sharedKeyWindow.frame), CGSizeZero)
                                               : self.tabBar.frame fromView:(self.tabBar?self.tabBar.hidden:YES)?nil:self.tabBar.superview];

    [self.view.subviews enumerateObjectsUsingBlock:
     ^(UIView *subview, NSUInteger idx, BOOL *stop) {
         if (![subview isKindOfClass:UIScrollView.class]) return;
         UIScrollView *scrollView = (UIScrollView *)subview;
         if (!scrollView.automaticallyAdjustsContentInsetByBars) return;

         UIEdgeInsets originalInsets = scrollView.automaticallyAdjustedContentInset;
         UIEdgeInsets contentInset = AGX_UIEdgeInsetsSubtractUIEdgeInsets
         (scrollView.contentInset, originalInsets);
         UIEdgeInsets indicatorInsets = AGX_UIEdgeInsetsSubtractUIEdgeInsets
         (scrollView.scrollIndicatorInsets, originalInsets);
         CGPoint contentOffset = CGPointMake
         (scrollView.contentOffset.x, scrollView.contentOffset.y+originalInsets.top);

         CGRect scrollViewFrame = scrollView.frame;
         CGFloat contentInsetTop = 0;
         if (statusBarFrame.size.height > 0) {
             contentInsetTop = MAX(CGRectGetMaxY(statusBarFrame)
                                   - CGRectGetMinY(scrollViewFrame), contentInsetTop);
         }
         if (navigationBarFrame.size.height > 0) {
             contentInsetTop = MAX(CGRectGetMaxY(navigationBarFrame)
                                   - CGRectGetMinY(scrollViewFrame), contentInsetTop);
         }
         CGFloat contentInsetBottom = 0;
         if (toolbarFrame.size.height > 0) {
             contentInsetBottom = MAX(CGRectGetMaxY(scrollViewFrame)
                                      - CGRectGetMinY(toolbarFrame), contentInsetBottom);
         }
         if (tabBarFrame.size.height > 0) {
             contentInsetBottom = MAX(CGRectGetMaxY(scrollViewFrame)
                                      - CGRectGetMinY(tabBarFrame), contentInsetBottom);
         }
         scrollView.automaticallyAdjustedContentInset
         = UIEdgeInsetsMake(contentInsetTop, 0, contentInsetBottom, 0);

         scrollView.contentInset = AGX_UIEdgeInsetsAddUIEdgeInsets
         (contentInset, scrollView.automaticallyAdjustedContentInset);
         scrollView.scrollIndicatorInsets = AGX_UIEdgeInsetsAddUIEdgeInsets
         (indicatorInsets, scrollView.automaticallyAdjustedContentInset);
         scrollView.contentOffset = CGPointMake
         (contentOffset.x, contentOffset.y-scrollView.automaticallyAdjustedContentInset.top);
         if (!UIEdgeInsetsEqualToEdgeInsets(scrollView.automaticallyAdjustedContentInset,
                                            originalInsets)) [self.view setNeedsLayout];
     }];
}

@end

@category_interface(UITabBarController, AGXCoreStatusBarStyle)
@end
@category_implementation(UITabBarController, AGXCoreStatusBarStyle)

- (UIStatusBarStyle)preferredStatusBarStyle {
    return self.agxStatusBarStyle;
}

- (BOOL)prefersStatusBarHidden {
    return self.agxStatusBarHidden;
}

- (UIViewController *)childViewControllerForStatusBarStyle {
    return(self.selectedViewController.agxAutomaticallyAdjustsStatusBarStyle ||
           [self.selectedViewController retainPropertyForAssociateKey:agxStatusBarStyleKey] ?
           self.selectedViewController : nil);
}

- (UIViewController *)childViewControllerForStatusBarHidden {
    return([self.selectedViewController retainPropertyForAssociateKey:agxStatusBarHiddenKey] ?
           self.selectedViewController : nil);
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
    agx_once
    ([UITabBarController swizzleInstanceOriSelector:@selector(setSelectedViewController:)
                                    withNewSelector:@selector(AGXCore_UITabBarController_setSelectedViewController:)];
     [UITabBarController swizzleInstanceOriSelector:@selector(setSelectedIndex:)
                                    withNewSelector:@selector(AGXCore_UITabBarController_setSelectedIndex:)];);
}

@end

@category_interface(UINavigationController, AGXCoreStatusBarStyle)
@end
@category_implementation(UINavigationController, AGXCoreStatusBarStyle)

- (UIStatusBarStyle)preferredStatusBarStyle {
    return self.agxStatusBarStyle;
}

- (BOOL)prefersStatusBarHidden {
    return self.agxStatusBarHidden;
}

- (UIViewController *)childViewControllerForStatusBarStyle {
    return(self.topViewController.agxAutomaticallyAdjustsStatusBarStyle ||
           [self.topViewController retainPropertyForAssociateKey:agxStatusBarStyleKey] ?
           self.topViewController : nil);
}

- (UIViewController *)childViewControllerForStatusBarHidden {
    return([self.topViewController retainPropertyForAssociateKey:agxStatusBarHiddenKey] ?
           self.topViewController : nil);
}

- (UIColor *)p_baseColorForAutoAdjustStatusBarStyle {
    return(self.navigationBarHidden ? self.topViewController.p_baseColorForAutoAdjustStatusBarStyle
           : (self.navigationBar.currentBackgroundColor ?: self.navigationBar.barTintColor));
}

#pragma mark - swizzle

- (void)AGXCore_UINavigationController_setNavigationBarHidden:(BOOL)hidden animated:(BOOL)animated {
    [self AGXCore_UINavigationController_setNavigationBarHidden:hidden animated:animated];
    [self p_automaticallySetStatusBarStyleAnimated:animated];
}

+ (void)load {
    agx_once
    ([UINavigationController
      swizzleInstanceOriSelector:@selector(setNavigationBarHidden:animated:)
      withNewSelector:@selector(AGXCore_UINavigationController_setNavigationBarHidden:animated:)];);
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
    agx_once
    ([UINavigationBar
      swizzleInstanceOriSelector:@selector(setBarTintColor:)
      withNewSelector:@selector(AGXCore_UINavigationBar_setBarTintColor:)];
     [UINavigationBar
      swizzleInstanceOriSelector:@selector(setBackgroundImage:forBarPosition:barMetrics:)
      withNewSelector:@selector(AGXCore_UINavigationBar_setBackgroundImage:forBarPosition:barMetrics:)];);
}

@end
