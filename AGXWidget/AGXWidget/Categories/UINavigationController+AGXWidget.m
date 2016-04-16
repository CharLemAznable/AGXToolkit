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

- (void)AGXWidgetInternal_setDelegate:(id<UINavigationControllerDelegate>)delegate {
    if (!delegate || [delegate isKindOfClass:[AGXNavigationControllerInternalDelegate class]])  {
        [self AGXWidgetInternal_setDelegate:delegate];
        return;
    }
    self.internal.delegate = delegate;
}

- (void)AGXWidgetInternal_viewDidLoad {
    [self AGXWidgetInternal_viewDidLoad];
    
    self.internal = AGX_AUTORELEASE([[AGXNavigationControllerInternalDelegate alloc] init]);
    self.internal.delegate = self.delegate;
    self.internal.navigationController = self;
    [self AGXWidgetInternal_setDelegate:self.internal];
}

- (void)AGXWidgetInternal_UINavigationController_dealloc {
    [self setRetainProperty:NULL forAssociateKey:agxNavigationControllerInternalDelegateKey];
    [self AGXWidgetInternal_UINavigationController_dealloc];
}

+ (void)load {
    static dispatch_once_t once_t;
    dispatch_once(&once_t, ^{
        [self swizzleInstanceOriSelector:@selector(setDelegate:)
                         withNewSelector:@selector(AGXWidgetInternal_setDelegate:)];
        [self swizzleInstanceOriSelector:@selector(viewDidLoad)
                         withNewSelector:@selector(AGXWidgetInternal_viewDidLoad)];
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
    self.topViewController.hideNavigationBar = self.navigationBarHidden;
    [self p_setPopGestureEdgesByPushTransited:transition];
    [self setInternalTransited:transition callCallbacks];
    [self AGXWidget_pushViewController:viewController animated:YES];
}

- (UIViewController *)popViewControllerAnimated:(BOOL)animated defCallbacks
{ return [self popViewControllerTransited:popTransition callCallbacks]; }
- (UIViewController *)popViewControllerTransited:(AGXTransition)transition
{ return [self popViewControllerTransited:transition callNULLCallbacks]; }

- (UIViewController *)popViewControllerTransited:(AGXTransition)transition defCallbacks {
    if (self.viewControllers.count == 0) return nil;
    [self setInternalTransited:transition callCallbacks];
    return [self AGXWidget_popViewControllerAnimated:YES];
}

- (NSArray *)popToViewController:(UIViewController *)viewController defAnimated defCallbacks
{ return [self popToViewController:viewController transited:popTransition callCallbacks]; }
- (NSArray *)popToViewController:(UIViewController *)viewController defTransited
{ return [self popToViewController:viewController callTransited callNULLCallbacks]; }

- (NSArray *)popToViewController:(UIViewController *)viewController defTransited defCallbacks {
    if (![self.viewControllers containsObject:viewController] || self.topViewController == viewController) return @[];
    [self setInternalTransited:transition callCallbacks];
    return [self AGXWidget_popToViewController:viewController animated:YES];
}

- (NSArray *)popToRootViewControllerAnimated:(BOOL)animated defCallbacks
{ return [self popToRootViewControllerTransited:popTransition callCallbacks]; }
- (NSArray *)popToRootViewControllerTransited:(AGXTransition)transition
{ return [self popToRootViewControllerTransited:transition callNULLCallbacks]; }

- (NSArray *)popToRootViewControllerTransited:(AGXTransition)transition defCallbacks {
    if (self.viewControllers.count < 2) return @[];
    [self setInternalTransited:transition callCallbacks];
    return [self AGXWidget_popToRootViewControllerAnimated:YES];
}

- (void)setViewControllers:(NSArray *)viewControllers defAnimated defCallbacks
{ [self setViewControllers:viewControllers transited:pushTransition callCallbacks]; }
- (void)setViewControllers:(NSArray *)viewControllers defTransited
{ [self setViewControllers:viewControllers callTransited callNULLCallbacks]; }

- (void)setViewControllers:(NSArray *)viewControllers defTransited defCallbacks {
    if (self.topViewController != viewControllers.lastObject) {
        [self p_setPopGestureEdgesByPushTransited:transition];
        [self setInternalTransited:transition callCallbacks];
    }
    [self AGXWidget_setViewControllers:viewControllers animated:YES];
}

- (UIViewController *)replaceWithViewController:(UIViewController *)viewController defAnimated
{ return [self replaceWithViewController:viewController transited:pushTransition callNULLCallbacks]; }
- (UIViewController *)replaceWithViewController:(UIViewController *)viewController defAnimated defCallbacks
{ return [self replaceWithViewController:viewController transited:pushTransition callCallbacks]; }
- (UIViewController *)replaceWithViewController:(UIViewController *)viewController defTransited
{ return [self replaceWithViewController:viewController callTransited callNULLCallbacks]; }

- (UIViewController *)replaceWithViewController:(UIViewController *)viewController defTransited defCallbacks {
    UIViewController *poping = AGX_RETAIN(self.viewControllers.lastObject);
    [self pushViewController:viewController callTransited started:started finished:
     ^(UIViewController *fromViewController, UIViewController *toViewController) {
         if (finished) finished(fromViewController, toViewController);
         if (!poping) return;
         NSMutableArray *viewControllers = [toViewController.navigationController.viewControllers mutableCopy];
         [viewControllers removeObject:poping];
         [toViewController.navigationController setViewControllers:AGX_AUTORELEASE(viewControllers)];
     }];
    return AGX_AUTORELEASE(poping);
}

- (NSArray *)replaceToViewController:(UIViewController *)toViewController defWithVC defAnimated
{ return [self replaceToViewController:toViewController callWithVC transited:pushTransition callNULLCallbacks]; }
- (NSArray *)replaceToViewController:(UIViewController *)toViewController defWithVC defAnimated defCallbacks
{ return [self replaceToViewController:toViewController callWithVC transited:pushTransition callCallbacks]; }
- (NSArray *)replaceToViewController:(UIViewController *)toViewController defWithVC defTransited
{ return [self replaceToViewController:toViewController callWithVC callTransited callNULLCallbacks]; }

- (NSArray *)replaceToViewController:(UIViewController *)toViewController defWithVC defTransited defCallbacks {
    if (![self.viewControllers containsObject:toViewController]) return @[];
    NSUInteger index = [self.viewControllers indexOfObject:toViewController];
    NSArray *poping = [[self p_viewControllersWillPopedFromIndex:index] copy];
    [self pushViewController:viewController callTransited started:started finished:
     ^(UIViewController *fromViewController, UIViewController *toViewController) {
         if (finished) finished(fromViewController, toViewController);
         if (poping.count == 0) return;
         NSMutableArray *viewControllers = [toViewController.navigationController.viewControllers mutableCopy];
         [viewControllers removeObjectsInArray:poping];
         [toViewController.navigationController setViewControllers:AGX_AUTORELEASE(viewControllers)];
     }];
    return AGX_AUTORELEASE(poping);
}

- (NSArray *)replaceToRootViewControllerWithViewController:(UIViewController *)viewController defAnimated
{ return [self replaceToRootViewControllerWithViewController:viewController transited:pushTransition callNULLCallbacks]; }
- (NSArray *)replaceToRootViewControllerWithViewController:(UIViewController *)viewController defAnimated defCallbacks
{ return [self replaceToRootViewControllerWithViewController:viewController transited:pushTransition callCallbacks]; }
- (NSArray *)replaceToRootViewControllerWithViewController:(UIViewController *)viewController defTransited
{ return [self replaceToRootViewControllerWithViewController:viewController callTransited callNULLCallbacks]; }

- (NSArray *)replaceToRootViewControllerWithViewController:(UIViewController *)viewController defTransited defCallbacks {
    if (self.viewControllers.count == 0) return @[];
    NSArray *poping = [[self p_viewControllersWillPopedFromIndex:0] copy];
    [self pushViewController:viewController callTransited started:started finished:
     ^(UIViewController *fromViewController, UIViewController *toViewController) {
         if (finished) finished(fromViewController, toViewController);
         if (poping.count == 0) return;
         NSMutableArray *viewControllers = [toViewController.navigationController.viewControllers mutableCopy];
         [viewControllers removeObjectsInArray:poping];
         [toViewController.navigationController setViewControllers:AGX_AUTORELEASE(viewControllers)];
     }];
    return AGX_AUTORELEASE(poping);
}

#pragma mark - swizzle methods

- (void)AGXWidget_pushViewController:(UIViewController *)viewController defAnimated {
    [self pushViewController:viewController transited:pushTransition callNULLCallbacks];
}

- (UIViewController *)AGXWidget_popViewControllerAnimated:(BOOL)animated {
    return [self popViewControllerTransited:popTransition callNULLCallbacks];
}

- (NSArray *)AGXWidget_popToViewController:(UIViewController *)viewController defAnimated {
    return [self popToViewController:viewController transited:popTransition callNULLCallbacks];
}

- (NSArray *)AGXWidget_popToRootViewControllerAnimated:(BOOL)animated {
    return [self popToRootViewControllerTransited:popTransition callNULLCallbacks];
}

- (void)AGXWidget_setViewControllers:(NSArray *)viewControllers defAnimated {
    [self setViewControllers:viewControllers transited:pushTransition callNULLCallbacks];
}

- (void)AGXWidget_setNavigationBarHidden:(BOOL)hidden animated:(BOOL)animated {
    [self AGXWidget_setNavigationBarHidden:hidden animated:animated];
    [self p_setStatusBarStyleByNavigationBarOrTopView];
}

+ (void)load {
    static dispatch_once_t once_t;
    dispatch_once(&once_t, ^{
        [self swizzleInstanceOriSelector:@selector(pushViewController:animated:)
                         withNewSelector:@selector(AGXWidget_pushViewController:animated:)];
        [self swizzleInstanceOriSelector:@selector(popViewControllerAnimated:)
                         withNewSelector:@selector(AGXWidget_popViewControllerAnimated:)];
        [self swizzleInstanceOriSelector:@selector(popToViewController:animated:)
                         withNewSelector:@selector(AGXWidget_popToViewController:animated:)];
        [self swizzleInstanceOriSelector:@selector(popToRootViewControllerAnimated:)
                         withNewSelector:@selector(AGXWidget_popToRootViewControllerAnimated:)];
        [self swizzleInstanceOriSelector:@selector(setViewControllers:animated:)
                         withNewSelector:@selector(AGXWidget_setViewControllers:animated:)];
        
        [self swizzleInstanceOriSelector:@selector(setNavigationBarHidden:animated:)
                         withNewSelector:@selector(AGXWidget_setNavigationBarHidden:animated:)];
    });
}

#undef callNULLCallbacks
#undef callPopTransition
#undef callPushTransition

#pragma mark - private methods

- (void)p_setPopGestureEdgesByPushTransited:(AGXTransition)transition {
    switch (transition.direction) {
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
    if ([statusBarColor colorShade] == AGXColorShadeUnmeasured) return;
    [self setStatusBarStyle:([statusBarColor colorShade] == AGXColorShadeLight ?
                             UIStatusBarStyleDefault : UIStatusBarStyleLightContent) animated:YES];
}

NSString *const agxWidgetKVOContext = @"AGXWidgetKVOContext";

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context {
    if (![agxWidgetKVOContext isEqual:(AGX_BRIDGE id)(context)]) {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
        return;
    }
    [self p_setStatusBarStyleByNavigationBarOrTopView];
}

@end

@category_implementation(UIViewController, AGXWidgetUINavigationController)

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

- (void)AGXWidgetUINavigationController_viewWillAppear:(BOOL)animated {
    [self AGXWidgetUINavigationController_viewWillAppear:animated];
    if ([self valueForAgxHideNavigationBar]) {
        [self setNavigationBarHidden:[self hideNavigationBar] animated:animated];
    }
    if (self.navigationController) {
        [self addObserver:self.navigationController forKeyPath:@"view.backgroundColor"
                  options:NSKeyValueObservingOptionInitial|NSKeyValueObservingOptionNew
                  context:(AGX_BRIDGE void *)agxWidgetKVOContext];
    }
}

- (void)AGXWidgetUINavigationController_viewWillDisappear:(BOOL)animated {
    [self AGXWidgetUINavigationController_viewWillDisappear:animated];
    if (self.navigationController) {
        [self removeObserver:self.navigationController forKeyPath:@"view.backgroundColor"
                     context:(AGX_BRIDGE void *)agxWidgetKVOContext];
    }
}

- (void)AGXWidgetUINavigationController_UIViewController_dealloc {
    [self setRetainProperty:NULL forAssociateKey:agxHideNavigationBarKey];
    [self setRetainProperty:NULL forAssociateKey:agxDisablePopGestureKey];
    [self AGXWidgetUINavigationController_UIViewController_dealloc];
}

+ (void)load {
    static dispatch_once_t once_t;
    dispatch_once(&once_t, ^{
        [self swizzleInstanceOriSelector:@selector(viewWillAppear:)
                         withNewSelector:@selector(AGXWidgetUINavigationController_viewWillAppear:)];
        [self swizzleInstanceOriSelector:@selector(viewWillDisappear:)
                         withNewSelector:@selector(AGXWidgetUINavigationController_viewWillDisappear:)];
        [self swizzleInstanceOriSelector:NSSelectorFromString(@"dealloc")
                         withNewSelector:@selector(AGXWidgetUINavigationController_UIViewController_dealloc)];
    });
}

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

- (void)AGXWidgetInternal_setBarTintColor:(UIColor *)barTintColor {
    [self AGXWidgetInternal_setBarTintColor:barTintColor];
    [self.navigationController p_setStatusBarStyleByNavigationBarOrTopView];
}

- (void)AGXWidgetInternal_setBackgroundImage:(UIImage *)backgroundImage forBarPosition:(UIBarPosition)barPosition barMetrics:(UIBarMetrics)barMetrics {
    [self AGXWidgetInternal_setBackgroundImage:backgroundImage forBarPosition:barPosition barMetrics:barMetrics];
    [self.navigationController p_setStatusBarStyleByNavigationBarOrTopView];
}

+ (void)load {
    static dispatch_once_t once_t;
    dispatch_once(&once_t, ^{
        [self swizzleInstanceOriSelector:@selector(setBarTintColor:)
                         withNewSelector:@selector(AGXWidgetInternal_setBarTintColor:)];
        [self swizzleInstanceOriSelector:@selector(setBackgroundImage:forBarPosition:barMetrics:)
                         withNewSelector:@selector(AGXWidgetInternal_setBackgroundImage:forBarPosition:barMetrics:)];
    });
}

@end
