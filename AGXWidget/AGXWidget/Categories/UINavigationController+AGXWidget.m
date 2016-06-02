//
//  UINavigationController+AGXWidget.m
//  AGXWidget
//
//  Created by Char Aznable on 16/4/7.
//  Copyright © 2016年 AI-CUC-EC. All rights reserved.
//

#import "UINavigationController+AGXWidget.h"
#import "UIView+AGXWidgetAnimation.h"
#import "AGXAnimationInternal.h"
#import "AGXNavigationControllerInternalDelegate.h"
#import <QuartzCore/CAAnimation.h>
#import <AGXCore/AGXCore/NSObject+AGXCore.h>
#import <AGXCore/AGXCore/UIView+AGXCore.h>
#import <AGXCore/AGXCore/UIColor+AGXCore.h>
#import <AGXCore/AGXCore/UINavigationBar+AGXCore.h>
#import <AGXCore/AGXCore/UIViewController+AGXCore.h>
#import <AGXCore/AGXCore/AGXArc.h>

@category_interface(UINavigationController, AGXWidgetInternal)
@property (nonatomic, AGX_STRONG) AGXNavigationControllerInternalDelegate *internal;
@end
@category_implementation(UINavigationController, AGXWidgetInternal)

NSString *const agxNavigationControllerInternalDelegateKey = @"agxNavigationControllerInternalDelegate";

- (AGXNavigationControllerInternalDelegate *)internal {
    return [self retainPropertyForAssociateKey:agxNavigationControllerInternalDelegateKey];
}

- (void)setInternal:(AGXNavigationControllerInternalDelegate *)internal {
    [self setRetainProperty:internal forAssociateKey:agxNavigationControllerInternalDelegateKey];
}

- (AGX_INSTANCETYPE)AGXWidgetInternal_UINavigationController_initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    UINavigationController *instance = [self AGXWidgetInternal_UINavigationController_initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    instance.internal = AGXNavigationControllerInternalDelegate.instance;
    instance.internal.navigationController = instance;
    [instance AGXWidgetInternal_UINavigationController_setDelegate:instance.internal];
    return instance;
}

- (void)AGXWidgetInternal_UINavigationController_setDelegate:(id<UINavigationControllerDelegate>)delegate {
    if (!delegate || [delegate isKindOfClass:[AGXNavigationControllerInternalDelegate class]]) {
        [self AGXWidgetInternal_UINavigationController_setDelegate:delegate];
        return;
    }
    self.internal.delegate = delegate;
}

- (void)AGXWidgetInternal_UINavigationController_dealloc {
    [self setRetainProperty:NULL forAssociateKey:agxNavigationControllerInternalDelegateKey];
    [self AGXWidgetInternal_UINavigationController_dealloc];
}

+ (void)load {
    static dispatch_once_t once_t;
    dispatch_once(&once_t, ^{
        [self swizzleInstanceOriSelector:@selector(initWithNibName:bundle:)
                         withNewSelector:@selector(AGXWidgetInternal_UINavigationController_initWithNibName:bundle:)];
        [self swizzleInstanceOriSelector:@selector(setDelegate:)
                         withNewSelector:@selector(AGXWidgetInternal_UINavigationController_setDelegate:)];
        [self swizzleInstanceOriSelector:NSSelectorFromString(@"dealloc")
                         withNewSelector:@selector(AGXWidgetInternal_UINavigationController_dealloc)];
    });
}

- (void)setInternalTransited:(AGXTransition)transition started:(AGXTransitionCallback)started finished:(AGXTransitionCallback)finished {
    self.internal.agxTransition = transition;
    self.internal.agxStartTransition = started;
    self.internal.agxFinishTransition = finished;
}

@end

#define defAnimated     animated:(BOOL)animated
#define defTransited    transited:(AGXTransition)transition
#define defCallbacks    started:(AGXTransitionCallback)started finished:(AGXTransitionCallback)finished
#define defWithVC       withViewController:(UIViewController *)viewController
#define callAnimated    animated:animated
#define callTransited   transited:transition
#define callCallbacks   started:started finished:finished
#define callWithVC      withViewController:viewController

@category_implementation(UINavigationController, AGXWidget)

- (CGFloat)gesturePopPercent {
    return self.internal.agxInteractivePopPercent;
}

- (void)setGesturePopPercent:(CGFloat)gesturePopPercent {
    self.internal.agxInteractivePopPercent = gesturePopPercent;
}

#define pushTransition      animated?AGXNavigationDefaultPushTransition:AGXNavigationNoneTransition
#define popTransition       animated?AGXNavigationDefaultPopTransition:AGXNavigationNoneTransition
#define callNULLCallbacks   started:NULL finished:NULL

- (void)pushViewController:(UIViewController *)viewController defAnimated defCallbacks
{ [self pushViewController:viewController transited:pushTransition callCallbacks]; }
- (void)pushViewController:(UIViewController *)viewController defTransited
{ [self pushViewController:viewController callTransited callNULLCallbacks]; }

- (void)pushViewController:(UIViewController *)viewController defTransited defCallbacks {
    NSAssert([NSThread isMainThread], @"ViewController Transition needs to be called on the main thread.");
    self.topViewController.hideNavigationBar = self.navigationBarHidden;
    if (viewController.backBarButtonTitle) {
        UIBarButtonItem *backBarButtonItem = [[UIBarButtonItem alloc] init];
        backBarButtonItem.title = viewController.backBarButtonTitle;
        self.topViewController.navigationItem.backBarButtonItem = AGX_AUTORELEASE(backBarButtonItem);
    }
    [self p_setPopGestureEdgesByPushTransited:transition];
    [self setInternalTransited:transition callCallbacks];
    [self AGXWidget_UINavigationController_pushViewController:viewController animated:YES];
}

- (UIViewController *)popViewControllerAnimated:(BOOL)animated defCallbacks
{ return [self popViewControllerTransited:popTransition callCallbacks]; }
- (UIViewController *)popViewControllerTransited:(AGXTransition)transition
{ return [self popViewControllerTransited:transition callNULLCallbacks]; }

- (UIViewController *)popViewControllerTransited:(AGXTransition)transition defCallbacks {
    NSAssert([NSThread isMainThread], @"ViewController Transition needs to be called on the main thread.");
    if (self.viewControllers.count == 0) return nil;
    [self setInternalTransited:transition callCallbacks];
    return [self AGXWidget_UINavigationController_popViewControllerAnimated:YES];
}

- (NSArray *)popToViewController:(UIViewController *)viewController defAnimated defCallbacks
{ return [self popToViewController:viewController transited:popTransition callCallbacks]; }
- (NSArray *)popToViewController:(UIViewController *)viewController defTransited
{ return [self popToViewController:viewController callTransited callNULLCallbacks]; }

- (NSArray *)popToViewController:(UIViewController *)viewController defTransited defCallbacks {
    NSAssert([NSThread isMainThread], @"ViewController Transition needs to be called on the main thread.");
    if (![self.viewControllers containsObject:viewController] || self.topViewController == viewController) return @[];
    [self setInternalTransited:transition callCallbacks];
    return [self AGXWidget_UINavigationController_popToViewController:viewController animated:YES];
}

- (NSArray *)popToRootViewControllerAnimated:(BOOL)animated defCallbacks
{ return [self popToRootViewControllerTransited:popTransition callCallbacks]; }
- (NSArray *)popToRootViewControllerTransited:(AGXTransition)transition
{ return [self popToRootViewControllerTransited:transition callNULLCallbacks]; }

- (NSArray *)popToRootViewControllerTransited:(AGXTransition)transition defCallbacks {
    NSAssert([NSThread isMainThread], @"ViewController Transition needs to be called on the main thread.");
    if (self.viewControllers.count < 2) return @[];
    [self setInternalTransited:transition callCallbacks];
    return [self AGXWidget_UINavigationController_popToRootViewControllerAnimated:YES];
}

- (void)setViewControllers:(NSArray *)viewControllers defAnimated defCallbacks
{ [self setViewControllers:viewControllers transited:pushTransition callCallbacks]; }
- (void)setViewControllers:(NSArray *)viewControllers defTransited
{ [self setViewControllers:viewControllers callTransited callNULLCallbacks]; }

- (void)setViewControllers:(NSArray *)viewControllers defTransited defCallbacks {
    NSAssert([NSThread isMainThread], @"ViewController Transition needs to be called on the main thread.");
    if (self.topViewController != viewControllers.lastObject) {
        [self p_setPopGestureEdgesByPushTransited:transition];
        [self setInternalTransited:transition callCallbacks];
    }
    [self AGXWidget_UINavigationController_setViewControllers:viewControllers animated:YES];
}

- (UIViewController *)replaceWithViewController:(UIViewController *)viewController defAnimated
{ return [self replaceWithViewController:viewController transited:pushTransition callNULLCallbacks]; }
- (UIViewController *)replaceWithViewController:(UIViewController *)viewController defAnimated defCallbacks
{ return [self replaceWithViewController:viewController transited:pushTransition callCallbacks]; }
- (UIViewController *)replaceWithViewController:(UIViewController *)viewController defTransited
{ return [self replaceWithViewController:viewController callTransited callNULLCallbacks]; }

- (UIViewController *)replaceWithViewController:(UIViewController *)viewController defTransited defCallbacks {
    NSAssert([NSThread isMainThread], @"ViewController Transition needs to be called on the main thread.");
    NSUInteger count = self.viewControllers.count;
    if (count == 0) {
        [self pushViewController:viewController callTransited callCallbacks];
        return nil;
    }
    UIViewController *poping = AGX_RETAIN(self.viewControllers[count - 1]);
    NSMutableArray *viewControllers = [self.viewControllers mutableCopy];
    [viewControllers removeObject:poping];
    [viewControllers addObject:viewController];
    [self setViewControllers:AGX_AUTORELEASE(viewControllers) callTransited callCallbacks];
    return AGX_AUTORELEASE(poping);
}

- (NSArray *)replaceToViewController:(UIViewController *)toViewController defWithVC defAnimated
{ return [self replaceToViewController:toViewController callWithVC transited:pushTransition callNULLCallbacks]; }
- (NSArray *)replaceToViewController:(UIViewController *)toViewController defWithVC defAnimated defCallbacks
{ return [self replaceToViewController:toViewController callWithVC transited:pushTransition callCallbacks]; }
- (NSArray *)replaceToViewController:(UIViewController *)toViewController defWithVC defTransited
{ return [self replaceToViewController:toViewController callWithVC callTransited callNULLCallbacks]; }

- (NSArray *)replaceToViewController:(UIViewController *)toViewController defWithVC defTransited defCallbacks {
    NSAssert([NSThread isMainThread], @"ViewController Transition needs to be called on the main thread.");
    if (![self.viewControllers containsObject:toViewController]) return @[];
    NSUInteger index = [self.viewControllers indexOfObject:toViewController];
    NSArray *poping = [[self p_viewControllersWillPopedFromIndex:index] copy];
    NSMutableArray *viewControllers = [self.viewControllers mutableCopy];
    [viewControllers removeObjectsInArray:poping];
    [viewControllers addObject:viewController];
    [self setViewControllers:AGX_AUTORELEASE(viewControllers) callTransited callCallbacks];
    return AGX_AUTORELEASE(poping);
}

- (NSArray *)replaceToRootViewControllerWithViewController:(UIViewController *)viewController defAnimated
{ return [self replaceToRootViewControllerWithViewController:viewController transited:pushTransition callNULLCallbacks]; }
- (NSArray *)replaceToRootViewControllerWithViewController:(UIViewController *)viewController defAnimated defCallbacks
{ return [self replaceToRootViewControllerWithViewController:viewController transited:pushTransition callCallbacks]; }
- (NSArray *)replaceToRootViewControllerWithViewController:(UIViewController *)viewController defTransited
{ return [self replaceToRootViewControllerWithViewController:viewController callTransited callNULLCallbacks]; }

- (NSArray *)replaceToRootViewControllerWithViewController:(UIViewController *)viewController defTransited defCallbacks {
    NSAssert([NSThread isMainThread], @"ViewController Transition needs to be called on the main thread.");
    if (self.viewControllers.count == 0) return @[];
    NSArray *poping = [[self p_viewControllersWillPopedFromIndex:0] copy];
    NSMutableArray *viewControllers = [self.viewControllers mutableCopy];
    [viewControllers removeObjectsInArray:poping];
    [viewControllers addObject:viewController];
    [self setViewControllers:AGX_AUTORELEASE(viewControllers) callTransited callCallbacks];
    return AGX_AUTORELEASE(poping);
}

#pragma mark - swizzle methods

- (void)AGXWidget_UINavigationController_pushViewController:(UIViewController *)viewController defAnimated {
    [self pushViewController:viewController transited:pushTransition callNULLCallbacks];
}

- (UIViewController *)AGXWidget_UINavigationController_popViewControllerAnimated:(BOOL)animated {
    return [self popViewControllerTransited:popTransition callNULLCallbacks];
}

- (NSArray *)AGXWidget_UINavigationController_popToViewController:(UIViewController *)viewController defAnimated {
    return [self popToViewController:viewController transited:popTransition callNULLCallbacks];
}

- (NSArray *)AGXWidget_UINavigationController_popToRootViewControllerAnimated:(BOOL)animated {
    return [self popToRootViewControllerTransited:popTransition callNULLCallbacks];
}

- (void)AGXWidget_UINavigationController_setViewControllers:(NSArray *)viewControllers defAnimated {
    [self setViewControllers:viewControllers transited:pushTransition callNULLCallbacks];
}

- (void)AGXWidget_UINavigationController_setNavigationBarHidden:(BOOL)hidden animated:(BOOL)animated {
    [self AGXWidget_UINavigationController_setNavigationBarHidden:hidden animated:animated];
    [self p_setStatusBarStyleByNavigationBarOrTopView];
}

+ (void)load {
    static dispatch_once_t once_t;
    dispatch_once(&once_t, ^{
        [self swizzleInstanceOriSelector:@selector(pushViewController:animated:)
                         withNewSelector:@selector(AGXWidget_UINavigationController_pushViewController:animated:)];
        [self swizzleInstanceOriSelector:@selector(popViewControllerAnimated:)
                         withNewSelector:@selector(AGXWidget_UINavigationController_popViewControllerAnimated:)];
        [self swizzleInstanceOriSelector:@selector(popToViewController:animated:)
                         withNewSelector:@selector(AGXWidget_UINavigationController_popToViewController:animated:)];
        [self swizzleInstanceOriSelector:@selector(popToRootViewControllerAnimated:)
                         withNewSelector:@selector(AGXWidget_UINavigationController_popToRootViewControllerAnimated:)];
        [self swizzleInstanceOriSelector:@selector(setViewControllers:animated:)
                         withNewSelector:@selector(AGXWidget_UINavigationController_setViewControllers:animated:)];

        [self swizzleInstanceOriSelector:@selector(setNavigationBarHidden:animated:)
                         withNewSelector:@selector(AGXWidget_UINavigationController_setNavigationBarHidden:animated:)];
    });
}

#undef callNULLCallbacks
#undef callPopTransition
#undef callPushTransition

#pragma mark - private methods

- (void)p_setPopGestureEdgesByPushTransited:(AGXTransition)transition {
    switch (transition.directionEntry) {
        case AGXAnimateUp:      self.internal.agxPopGestureEdges = UIRectEdgeTop;break;
        case AGXAnimateLeft:    self.internal.agxPopGestureEdges = UIRectEdgeLeft;break;
        case AGXAnimateDown:    self.internal.agxPopGestureEdges = UIRectEdgeBottom;break;
        case AGXAnimateRight:   self.internal.agxPopGestureEdges = UIRectEdgeRight;break;
        case AGXAnimateStay:    self.internal.agxPopGestureEdges = UIRectEdgeLeft;break; // default
    }
}

- (NSArray *)p_viewControllersWillPopedFromIndex:(NSInteger)index {
    return [self.viewControllers subarrayWithRange:NSMakeRange(index+1, self.viewControllers.count-index-1)];
}

- (void)p_setStatusBarStyleByNavigationBarOrTopView {
    UIColor *statusBarColor = self.navigationBarHidden ? self.topViewController.view.backgroundColor
    : (self.navigationBar.currentBackgroundColor ?: self.navigationBar.barTintColor);
    if (statusBarColor.colorShade == AGXColorShadeUnmeasured) return;
    [self setStatusBarStyle:(statusBarColor.colorShade == AGXColorShadeLight ?
                             UIStatusBarStyleDefault : UIStatusBarStyleLightContent) animated:YES];
}

#pragma mark - private override

- (BOOL)navigationBar:(UINavigationBar *)navigationBar shouldPopItem:(UINavigationItem *)item {
    if ([self.viewControllers count] < [navigationBar.items count]) return YES;

    BOOL shouldPopItem = YES;
    UIViewController *topViewController = [self topViewController];
    if ([topViewController respondsToSelector:@selector(navigationShouldPopOnBackBarButton)]) {
        shouldPopItem = [topViewController navigationShouldPopOnBackBarButton];
    }

    if (shouldPopItem) {
        agx_async_main([self popViewControllerAnimated:YES];)
    } else {
        // Workaround for iOS7.1. Thanks to @boliva - http://stackoverflow.com/posts/comments/34452906
        [[navigationBar subviews] enumerateObjectsUsingBlock:
         ^(UIView *subview, NSUInteger idx, BOOL *stop) {
             if(subview.alpha > 0 && subview.alpha < 1) {
                 [UIView animateWithDuration:.25 animations:^{ subview.alpha = 1; }];
             }
         }];
    }
    return NO;
}

@end

@category_implementation(UIViewController, AGXWidgetUINavigationController)

#pragma mark - properties

NSString *const agxDisablePopGestureKey = @"agxDisablePopGesture";

- (BOOL)disablePopGesture {
    id value = [self retainPropertyForAssociateKey:agxDisablePopGestureKey];
    return [self isKindOfClass:[UINavigationController class]] ? [value boolValue]
    : (value ? [value boolValue] : self.navigationController.disablePopGesture);
}

- (void)setDisablePopGesture:(BOOL)disablePopGesture {
    [self setRetainProperty:@(disablePopGesture) forAssociateKey:agxDisablePopGestureKey];
}

NSString *const agxHideNavigationBarKey = @"agxHideNavigationBar";

- (id)valueForAgxHideNavigationBar {
    return [self retainPropertyForAssociateKey:agxHideNavigationBarKey];
}

- (BOOL)hideNavigationBar {
    return [[self valueForAgxHideNavigationBar] boolValue];
}

- (void)setHideNavigationBar:(BOOL)hideNavigationBar {
    [self setRetainProperty:@(hideNavigationBar) forAssociateKey:agxHideNavigationBarKey];
}

NSString *const agxBackBarButtonTitleKey = @"agxBackBarButtonTitle";

- (NSString *)backBarButtonTitle {
    return [self retainPropertyForAssociateKey:agxBackBarButtonTitleKey];
}

- (void)setBackBarButtonTitle:(NSString *)backBarButtonTitle {
    [self setRetainProperty:backBarButtonTitle forAssociateKey:agxBackBarButtonTitleKey];

    if (backBarButtonTitle) {
        UIBarButtonItem *backBarButtonItem = [[UIBarButtonItem alloc] init];
        backBarButtonItem.title = backBarButtonTitle;
        self.navigationBar.backItem.backBarButtonItem = AGX_AUTORELEASE(backBarButtonItem);
    }
}

#pragma mark - callback methods

- (BOOL)navigationShouldPopOnBackBarButton {
    return YES;
}

#pragma mark - KVO

NSString *const agxWidgetKVOContext = @"AGXWidgetKVOContext";

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context {
    if (![agxWidgetKVOContext isEqual:(AGX_BRIDGE id)(context)]) {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
        return;
    }
    if (self.navigationController.topViewController == self) {
        [self.navigationController p_setStatusBarStyleByNavigationBarOrTopView];
    }
}

#pragma mark - swizzle

- (void)AGXWidgetUINavigationController_UIViewController_viewWillAppear:(BOOL)animated {
    [self AGXWidgetUINavigationController_UIViewController_viewWillAppear:animated];
    if ([self valueForAgxHideNavigationBar]) {
        [self setNavigationBarHidden:[self hideNavigationBar] animated:animated];
    }
}

- (void)AGXWidgetUINavigationController_UIViewController_setView:(UIView *)view {
    if (self.isViewLoaded) [self.view removeObserver:self forKeyPath:@"backgroundColor"
                                             context:(AGX_BRIDGE void *)agxWidgetKVOContext];
    [view addObserver:self forKeyPath:@"backgroundColor" options:NSKeyValueObservingOptionNew
              context:(AGX_BRIDGE void *)agxWidgetKVOContext];

    [self AGXWidgetUINavigationController_UIViewController_setView:view];
}

- (void)AGXWidgetUINavigationController_UIViewController_dealloc {
    if (self.isViewLoaded) [self.view removeObserver:self forKeyPath:@"backgroundColor"
                                             context:(AGX_BRIDGE void *)agxWidgetKVOContext];
    [self setRetainProperty:NULL forAssociateKey:agxHideNavigationBarKey];
    [self setRetainProperty:NULL forAssociateKey:agxDisablePopGestureKey];
    [self setRetainProperty:NULL forAssociateKey:agxBackBarButtonTitleKey];
    [self AGXWidgetUINavigationController_UIViewController_dealloc];
}

+ (void)load {
    static dispatch_once_t once_t;
    dispatch_once(&once_t, ^{
        [self swizzleInstanceOriSelector:@selector(viewWillAppear:)
                         withNewSelector:@selector(AGXWidgetUINavigationController_UIViewController_viewWillAppear:)];
        [self swizzleInstanceOriSelector:@selector(setView:)
                         withNewSelector:@selector(AGXWidgetUINavigationController_UIViewController_setView:)];
        [self swizzleInstanceOriSelector:NSSelectorFromString(@"dealloc")
                         withNewSelector:@selector(AGXWidgetUINavigationController_UIViewController_dealloc)];
    });
}

#pragma mark - navigation

#define NAVIGATION self.navigationController

- (void)pushViewController:(UIViewController *)viewController defAnimated
{ [NAVIGATION pushViewController:viewController callAnimated]; }
- (void)pushViewController:(UIViewController *)viewController defAnimated defCallbacks
{ [NAVIGATION pushViewController:viewController callAnimated callCallbacks]; }
- (void)pushViewController:(UIViewController *)viewController defTransited
{ [NAVIGATION pushViewController:viewController callTransited]; }
- (void)pushViewController:(UIViewController *)viewController defTransited defCallbacks
{ [NAVIGATION pushViewController:viewController callTransited callCallbacks]; }

- (UIViewController *)popViewControllerAnimated:(BOOL)animated
{ return [NAVIGATION popViewControllerAnimated:animated]; }
- (UIViewController *)popViewControllerAnimated:(BOOL)animated defCallbacks
{ return [NAVIGATION popViewControllerAnimated:animated callCallbacks]; }
- (UIViewController *)popViewControllerTransited:(AGXTransition)transition
{ return [NAVIGATION popViewControllerTransited:transition]; }
- (UIViewController *)popViewControllerTransited:(AGXTransition)transition defCallbacks
{ return [NAVIGATION popViewControllerTransited:transition callCallbacks]; }

- (NSArray *)popToViewController:(UIViewController *)viewController defAnimated
{ return [NAVIGATION popToViewController:viewController callAnimated]; }
- (NSArray *)popToViewController:(UIViewController *)viewController defAnimated defCallbacks
{ return [NAVIGATION popToViewController:viewController callAnimated callCallbacks]; }
- (NSArray *)popToViewController:(UIViewController *)viewController defTransited
{ return [NAVIGATION popToViewController:viewController callTransited]; }
- (NSArray *)popToViewController:(UIViewController *)viewController defTransited defCallbacks
{ return [NAVIGATION popToViewController:viewController callTransited callCallbacks]; }

- (NSArray *)popToRootViewControllerAnimated:(BOOL)animated
{ return [NAVIGATION popToRootViewControllerAnimated:animated]; }
- (NSArray *)popToRootViewControllerAnimated:(BOOL)animated defCallbacks
{ return [NAVIGATION popToRootViewControllerAnimated:animated callCallbacks]; }
- (NSArray *)popToRootViewControllerTransited:(AGXTransition)transition
{ return [NAVIGATION popToRootViewControllerTransited:transition]; }
- (NSArray *)popToRootViewControllerTransited:(AGXTransition)transition defCallbacks
{ return [NAVIGATION popToRootViewControllerTransited:transition callCallbacks]; }

- (void)setViewControllers:(NSArray *)viewControllers defAnimated
{ [NAVIGATION setViewControllers:viewControllers callAnimated]; }
- (void)setViewControllers:(NSArray *)viewControllers defAnimated defCallbacks
{ [NAVIGATION setViewControllers:viewControllers callAnimated callCallbacks]; }
- (void)setViewControllers:(NSArray *)viewControllers defTransited
{ [NAVIGATION setViewControllers:viewControllers callTransited]; }
- (void)setViewControllers:(NSArray *)viewControllers defTransited defCallbacks
{ [NAVIGATION setViewControllers:viewControllers callTransited callCallbacks]; }

- (UIViewController *)replaceWithViewController:(UIViewController *)viewController defAnimated
{ return [NAVIGATION replaceWithViewController:viewController callAnimated]; }
- (UIViewController *)replaceWithViewController:(UIViewController *)viewController defAnimated defCallbacks
{ return [NAVIGATION replaceWithViewController:viewController callAnimated callCallbacks]; }
- (UIViewController *)replaceWithViewController:(UIViewController *)viewController defTransited
{ return [NAVIGATION replaceWithViewController:viewController callTransited]; }
- (UIViewController *)replaceWithViewController:(UIViewController *)viewController defTransited defCallbacks
{ return [NAVIGATION replaceWithViewController:viewController callTransited callCallbacks]; }

- (NSArray *)replaceToViewController:(UIViewController *)toViewController defWithVC defAnimated
{ return [NAVIGATION replaceToViewController:toViewController callWithVC callAnimated]; }
- (NSArray *)replaceToViewController:(UIViewController *)toViewController defWithVC defAnimated defCallbacks
{ return [NAVIGATION replaceToViewController:toViewController callWithVC callAnimated callCallbacks]; }
- (NSArray *)replaceToViewController:(UIViewController *)toViewController defWithVC defTransited
{ return [NAVIGATION replaceToViewController:toViewController callWithVC callTransited]; }
- (NSArray *)replaceToViewController:(UIViewController *)toViewController defWithVC defTransited defCallbacks
{ return [NAVIGATION replaceToViewController:toViewController callWithVC callTransited callCallbacks]; }

- (NSArray *)replaceToRootViewControllerWithViewController:(UIViewController *)viewController defAnimated
{ return [NAVIGATION replaceToRootViewControllerWithViewController:viewController callAnimated]; }
- (NSArray *)replaceToRootViewControllerWithViewController:(UIViewController *)viewController defAnimated defCallbacks
{ return [NAVIGATION replaceToRootViewControllerWithViewController:viewController callAnimated callCallbacks]; }
- (NSArray *)replaceToRootViewControllerWithViewController:(UIViewController *)viewController defTransited
{ return [NAVIGATION replaceToRootViewControllerWithViewController:viewController callTransited]; }
- (NSArray *)replaceToRootViewControllerWithViewController:(UIViewController *)viewController defTransited defCallbacks
{ return [NAVIGATION replaceToRootViewControllerWithViewController:viewController callTransited callCallbacks]; }

#undef NAVIGATION

@end

#undef callWithVC
#undef callCallbacks
#undef callTransition
#undef callAnimated
#undef defWithVC
#undef defCallbacks
#undef defTransition
#undef defAnimated

@category_interface(UINavigationBar, AGXWidgetInternal)
@end
@category_implementation(UINavigationBar, AGXWidgetInternal)

- (void)AGXWidgetInternal_UINavigationBar_setBarTintColor:(UIColor *)barTintColor {
    [self AGXWidgetInternal_UINavigationBar_setBarTintColor:barTintColor];
    [self.navigationController p_setStatusBarStyleByNavigationBarOrTopView];
}

- (void)AGXWidgetInternal_UINavigationBar_setBackgroundImage:(UIImage *)backgroundImage forBarPosition:(UIBarPosition)barPosition barMetrics:(UIBarMetrics)barMetrics {
    [self AGXWidgetInternal_UINavigationBar_setBackgroundImage:backgroundImage forBarPosition:barPosition barMetrics:barMetrics];
    [self.navigationController p_setStatusBarStyleByNavigationBarOrTopView];
}

+ (void)load {
    static dispatch_once_t once_t;
    dispatch_once(&once_t, ^{
        [self swizzleInstanceOriSelector:@selector(setBarTintColor:)
                         withNewSelector:@selector(AGXWidgetInternal_UINavigationBar_setBarTintColor:)];
        [self swizzleInstanceOriSelector:@selector(setBackgroundImage:forBarPosition:barMetrics:)
                         withNewSelector:@selector(AGXWidgetInternal_UINavigationBar_setBackgroundImage:forBarPosition:barMetrics:)];
    });
}

@end
