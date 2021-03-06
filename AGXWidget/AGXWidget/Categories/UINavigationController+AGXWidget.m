//
//  UINavigationController+AGXWidget.m
//  AGXWidget
//
//  Created by Char Aznable on 2016/4/7.
//  Copyright © 2016 github.com/CharLemAznable. All rights reserved.
//

#import <QuartzCore/CAAnimation.h>
#import <AGXCore/AGXCore/NSObject+AGXCore.h>
#import <AGXCore/AGXCore/UIView+AGXCore.h>
#import <AGXCore/AGXCore/UIColor+AGXCore.h>
#import <AGXCore/AGXCore/UINavigationBar+AGXCore.h>
#import <AGXCore/AGXCore/UIViewController+AGXCore.h>
#import "AGXAnimationInternal.h"
#import "AGXNavigationControllerInternalDelegate.h"

@category_interface(UINavigationController, AGXWidgetInternal)
@property (nonatomic, AGX_STRONG) AGXNavigationControllerInternalDelegate *navigationInternalDelegate;
@end
@category_implementation(UINavigationController, AGXWidgetInternal)

NSString *const agxNavigationControllerInternalDelegateKey = @"agxNavigationControllerInternalDelegate";

- (AGXNavigationControllerInternalDelegate *)navigationInternalDelegate {
    return [self retainPropertyForAssociateKey:agxNavigationControllerInternalDelegateKey];
}

- (void)setNavigationInternalDelegate:(AGXNavigationControllerInternalDelegate *)navigationInternalDelegate {
    [self setRetainProperty:navigationInternalDelegate forAssociateKey:agxNavigationControllerInternalDelegateKey];
}

- (AGX_INSTANCETYPE)AGXWidgetInternal_UINavigationController_initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    UINavigationController *instance = [self AGXWidgetInternal_UINavigationController_initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    instance.navigationInternalDelegate = AGXNavigationControllerInternalDelegate.instance;
    instance.navigationInternalDelegate.navigationController = instance;
    [instance AGXWidgetInternal_UINavigationController_setDelegate:instance.navigationInternalDelegate];
    return instance;
}

- (void)AGXWidgetInternal_UINavigationController_setDelegate:(id<UINavigationControllerDelegate>)delegate {
    if (!delegate || [delegate isKindOfClass:AGXNavigationControllerInternalDelegate.class]) {
        [self AGXWidgetInternal_UINavigationController_setDelegate:delegate];
        return;
    }
    self.navigationInternalDelegate.delegate = delegate;
}

- (void)AGXWidgetInternal_UINavigationController_dealloc {
    [self setRetainProperty:NULL forAssociateKey:agxNavigationControllerInternalDelegateKey];
    [self AGXWidgetInternal_UINavigationController_dealloc];
}

+ (void)load {
    agx_once
    ([UINavigationController
      swizzleInstanceOriSelector:@selector(initWithNibName:bundle:)
      withNewSelector:@selector(AGXWidgetInternal_UINavigationController_initWithNibName:bundle:)];
     [UINavigationController
      swizzleInstanceOriSelector:@selector(setDelegate:)
      withNewSelector:@selector(AGXWidgetInternal_UINavigationController_setDelegate:)];
     [UINavigationController
      swizzleInstanceOriSelector:NSSelectorFromString(@"dealloc")
      withNewSelector:@selector(AGXWidgetInternal_UINavigationController_dealloc)];);
}

- (void)setInternalTransited:(AGXTransition)transition started:(AGXTransitionCallback)started finished:(AGXTransitionCallback)finished {
    self.navigationInternalDelegate.agxTransition = transition;
    self.navigationInternalDelegate.agxStartTransition = started;
    self.navigationInternalDelegate.agxFinishTransition = finished;
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
    return self.navigationInternalDelegate.agxInteractivePopPercent;
}

- (void)setGesturePopPercent:(CGFloat)gesturePopPercent {
    self.navigationInternalDelegate.agxInteractivePopPercent = gesturePopPercent;
}

#define pushTransition      animated?AGXNavigationDefaultPushTransition:AGXNavigationNoneTransition
#define popTransition       animated?AGXNavigationDefaultPopTransition:AGXNavigationNoneTransition
#define callNULLCallbacks   started:NULL finished:NULL

- (void)pushViewController:(UIViewController *)viewController defAnimated defCallbacks
{ [self pushViewController:viewController transited:pushTransition callCallbacks]; }
- (void)pushViewController:(UIViewController *)viewController defTransited
{ [self pushViewController:viewController callTransited callNULLCallbacks]; }

- (void)pushViewController:(UIViewController *)viewController defTransited defCallbacks {
    NSAssert(NSThread.isMainThread, @"ViewController Transition needs to be called on the main thread.");
    self.topViewController.navigationBarHiddenFlag = self.navigationBarHidden;
    self.topViewController.hidesBarsOnSwipeFlag = self.hidesBarsOnSwipe;
    self.topViewController.hidesBarsOnTapFlag = self.hidesBarsOnTap;
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
    NSAssert(NSThread.isMainThread, @"ViewController Transition needs to be called on the main thread.");
    if AGX_EXPECT_F(self.viewControllers.count == 0) return nil;
    [self setInternalTransited:transition callCallbacks];
    return [self AGXWidget_UINavigationController_popViewControllerAnimated:YES];
}

- (NSArray *)popToViewController:(UIViewController *)viewController defAnimated defCallbacks
{ return [self popToViewController:viewController transited:popTransition callCallbacks]; }
- (NSArray *)popToViewController:(UIViewController *)viewController defTransited
{ return [self popToViewController:viewController callTransited callNULLCallbacks]; }

- (NSArray *)popToViewController:(UIViewController *)viewController defTransited defCallbacks {
    NSAssert(NSThread.isMainThread, @"ViewController Transition needs to be called on the main thread.");
    if AGX_EXPECT_F(![self.viewControllers containsObject:viewController] || self.topViewController == viewController) return @[];
    [self setInternalTransited:transition callCallbacks];
    return [self AGXWidget_UINavigationController_popToViewController:viewController animated:YES];
}

- (NSArray *)popToRootViewControllerAnimated:(BOOL)animated defCallbacks
{ return [self popToRootViewControllerTransited:popTransition callCallbacks]; }
- (NSArray *)popToRootViewControllerTransited:(AGXTransition)transition
{ return [self popToRootViewControllerTransited:transition callNULLCallbacks]; }

- (NSArray *)popToRootViewControllerTransited:(AGXTransition)transition defCallbacks {
    NSAssert(NSThread.isMainThread, @"ViewController Transition needs to be called on the main thread.");
    if AGX_EXPECT_F(self.viewControllers.count < 2) return @[];
    [self setInternalTransited:transition callCallbacks];
    return [self AGXWidget_UINavigationController_popToRootViewControllerAnimated:YES];
}

- (void)setViewControllers:(NSArray *)viewControllers defAnimated defCallbacks
{ [self setViewControllers:viewControllers transited:pushTransition callCallbacks]; }
- (void)setViewControllers:(NSArray *)viewControllers defTransited
{ [self setViewControllers:viewControllers callTransited callNULLCallbacks]; }

- (void)setViewControllers:(NSArray *)viewControllers defTransited defCallbacks {
    NSAssert(NSThread.isMainThread, @"ViewController Transition needs to be called on the main thread.");
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
    NSAssert(NSThread.isMainThread, @"ViewController Transition needs to be called on the main thread.");
    NSUInteger count = self.viewControllers.count;
    if AGX_EXPECT_F(0 == count) {
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
    NSAssert(NSThread.isMainThread, @"ViewController Transition needs to be called on the main thread.");
    if AGX_EXPECT_F(![self.viewControllers containsObject:toViewController]) return @[];
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
    NSAssert(NSThread.isMainThread, @"ViewController Transition needs to be called on the main thread.");
    if AGX_EXPECT_F(self.viewControllers.count == 0) return @[];
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

+ (void)load {
    agx_once
    ([UINavigationController
      swizzleInstanceOriSelector:@selector(pushViewController:animated:)
      withNewSelector:@selector(AGXWidget_UINavigationController_pushViewController:animated:)];
     [UINavigationController
      swizzleInstanceOriSelector:@selector(popViewControllerAnimated:)
      withNewSelector:@selector(AGXWidget_UINavigationController_popViewControllerAnimated:)];
     [UINavigationController
      swizzleInstanceOriSelector:@selector(popToViewController:animated:)
      withNewSelector:@selector(AGXWidget_UINavigationController_popToViewController:animated:)];
     [UINavigationController
      swizzleInstanceOriSelector:@selector(popToRootViewControllerAnimated:)
      withNewSelector:@selector(AGXWidget_UINavigationController_popToRootViewControllerAnimated:)];
     [UINavigationController
      swizzleInstanceOriSelector:@selector(setViewControllers:animated:)
      withNewSelector:@selector(AGXWidget_UINavigationController_setViewControllers:animated:)];);
}

#undef callNULLCallbacks
#undef callPopTransition
#undef callPushTransition

#pragma mark - private methods

- (void)p_setPopGestureEdgesByPushTransited:(AGXTransition)transition {
    switch (transition.directionEntry) {
        case AGXAnimateUp:      self.navigationInternalDelegate.agxPopGestureEdges = UIRectEdgeTop;break;
        case AGXAnimateLeft:    self.navigationInternalDelegate.agxPopGestureEdges = UIRectEdgeLeft;break;
        case AGXAnimateDown:    self.navigationInternalDelegate.agxPopGestureEdges = UIRectEdgeBottom;break;
        case AGXAnimateRight:   self.navigationInternalDelegate.agxPopGestureEdges = UIRectEdgeRight;break;
        case AGXAnimateStay:    self.navigationInternalDelegate.agxPopGestureEdges = UIRectEdgeLeft;break; // default
    }
}

- (NSArray *)p_viewControllersWillPopedFromIndex:(NSInteger)index {
    return [self.viewControllers subarrayWithRange:NSMakeRange(index+1, self.viewControllers.count-index-1)];
}

#pragma mark - private override

- (BOOL)navigationBar:(UINavigationBar *)navigationBar shouldPopItem:(UINavigationItem *)item {
    if (self.viewControllers.count < navigationBar.items.count) return YES;

    BOOL shouldPopItem = YES;
    UIViewController *topViewController = self.topViewController;
    if ([topViewController respondsToSelector:@selector(navigationShouldPopOnBackBarButton)]) {
        shouldPopItem = [topViewController navigationShouldPopOnBackBarButton];
    }

    if (shouldPopItem) {
        agx_async_main([self popViewControllerAnimated:YES];);
    } else {
        // Workaround for iOS7.1. Thanks to @boliva - http://stackoverflow.com/posts/comments/34452906
        [navigationBar.subviews enumerateObjectsUsingBlock:
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
    return(value ? [value boolValue] : ([self isKindOfClass:UINavigationController.class]
                                        ? NO : self.navigationController.disablePopGesture));
}

- (void)setDisablePopGesture:(BOOL)disablePopGesture {
    [self setRetainProperty:@(disablePopGesture) forAssociateKey:agxDisablePopGestureKey];
}

NSString *const agxNavigationBarHiddenFlagKey = @"agxNavigationBarHiddenFlag";

- (BOOL)navigationBarHiddenFlag {
    id value = [self retainPropertyForAssociateKey:agxNavigationBarHiddenFlagKey];
    return(value ? [value boolValue] : ([self isKindOfClass:UINavigationController.class]
                                        ? NO : self.navigationController.navigationBarHiddenFlag));
}

- (void)setNavigationBarHiddenFlag:(BOOL)navigationBarHiddenFlag {
    [self setRetainProperty:@(navigationBarHiddenFlag) forAssociateKey:agxNavigationBarHiddenFlagKey];
}

NSString *const agxHidesBarsOnSwipeFlagKey = @"agxHidesBarsOnSwipeFlag";

- (BOOL)hidesBarsOnSwipeFlag {
    id value = [self retainPropertyForAssociateKey:agxHidesBarsOnSwipeFlagKey];
    return(value ? [value boolValue] : ([self isKindOfClass:UINavigationController.class]
                                        ? NO : self.navigationController.hidesBarsOnSwipeFlag));
}

- (void)setHidesBarsOnSwipeFlag:(BOOL)hidesBarsOnSwipeFlag {
    [self setRetainProperty:@(hidesBarsOnSwipeFlag) forAssociateKey:agxHidesBarsOnSwipeFlagKey];
}

NSString *const agxHidesBarsOnTapFlagKey = @"agxHidesBarsOnTapFlag";

- (BOOL)hidesBarsOnTapFlag {
    id value = [self retainPropertyForAssociateKey:agxHidesBarsOnTapFlagKey];
    return(value ? [value boolValue] : ([self isKindOfClass:UINavigationController.class]
                                        ? NO : self.navigationController.hidesBarsOnTapFlag));
}

- (void)setHidesBarsOnTapFlag:(BOOL)hidesBarsOnTapFlag {
    [self setRetainProperty:@(hidesBarsOnTapFlag) forAssociateKey:agxHidesBarsOnTapFlagKey];
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

#pragma mark - swizzle

- (void)AGXWidgetUINavigationController_UIViewController_viewWillAppear:(BOOL)animated {
    [self setNavigationBarHidden:self.navigationBarHiddenFlag animated:animated];
    self.hidesBarsOnSwipe = self.hidesBarsOnSwipeFlag;
    self.hidesBarsOnTap = self.hidesBarsOnTapFlag;
    [self AGXWidgetUINavigationController_UIViewController_viewWillAppear:animated];
}

- (void)AGXWidgetUINavigationController_UIViewController_dealloc {
    [self setRetainProperty:NULL forAssociateKey:agxDisablePopGestureKey];
    [self setRetainProperty:NULL forAssociateKey:agxNavigationBarHiddenFlagKey];
    [self setRetainProperty:NULL forAssociateKey:agxHidesBarsOnSwipeFlagKey];
    [self setRetainProperty:NULL forAssociateKey:agxHidesBarsOnTapFlagKey];
    [self setRetainProperty:NULL forAssociateKey:agxBackBarButtonTitleKey];
    [self AGXWidgetUINavigationController_UIViewController_dealloc];
}

+ (void)load {
    agx_once
    ([UIViewController
      swizzleInstanceOriSelector:@selector(viewWillAppear:)
      withNewSelector:@selector(AGXWidgetUINavigationController_UIViewController_viewWillAppear:)];
     [UIViewController
      swizzleInstanceOriSelector:NSSelectorFromString(@"dealloc")
      withNewSelector:@selector(AGXWidgetUINavigationController_UIViewController_dealloc)];);
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
