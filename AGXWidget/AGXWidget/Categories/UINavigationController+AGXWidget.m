//
//  UINavigationController+AGXWidget.m
//  AGXWidget
//
//  Created by Char Aznable on 16/4/7.
//  Copyright © 2016年 AI-CUC-EC. All rights reserved.
//

#import "UINavigationController+AGXWidget.h"
#import "UIView+AGXWidgetAnimation.h"
#import <QuartzCore/CAAnimation.h>
#import <AGXCore/AGXCore/NSObject+AGXCore.h>
#import <AGXCore/AGXCore/AGXArc.h>

#define defAnimated     animated:(BOOL)animated
#define defTransition   transition:(AGXTransition)transition
#define defCallbacks    started:(AGXTransitionCallback)started finished:(AGXTransitionCallback)finished
#define defWithVC       withViewController:(UIViewController *)viewController
#define callAnimated    animated:animated
#define callTransition  transition:transition
#define callCallbacks   started:started finished:finished
#define callWithVC      withViewController:viewController

AGXTransition AGXNoTransition;

@category_interface(CATransition, AGXWidget)
+ (CATransition *)transitionWithTransition:(AGXTransition)transition delegateFromViewController:(UIViewController *)fromViewController toViewController:(UIViewController *)toViewController started:(AGXTransitionCallback)started finished:(AGXTransitionCallback)finished;
@end

@category_implementation(UINavigationController, AGXWidget)

#define pushTransition      animated?AGXDefaultPushTransition:AGXNoTransition
#define popTransition       animated?AGXDefaultPopTransition:AGXNoTransition
#define callNULLCallbacks   started:NULL finished:NULL
#define LayerAddTransition(fromVC, toVC)                                        \
[self.view.layer addAnimation:[CATransition transitionWithTransition:transition \
delegateFromViewController:fromVC toViewController:toVC callCallbacks] forKey:@"transition"]

- (void)pushViewController:(UIViewController *)viewController defAnimated defCallbacks
{ [self pushViewController:viewController transition:pushTransition callCallbacks]; }
- (void)pushViewController:(UIViewController *)viewController defTransition
{ [self pushViewController:viewController callTransition callNULLCallbacks]; }

- (void)pushViewController:(UIViewController *)viewController defTransition defCallbacks {
    LayerAddTransition(self.topViewController, viewController);
    [self AGXWidget_pushViewController:viewController animated:NO];
}

- (UIViewController *)popViewControllerAnimated:(BOOL)animated defCallbacks
{ return [self popViewControllerTransition:popTransition callCallbacks]; }
- (UIViewController *)popViewControllerTransition:(AGXTransition)transition
{ return [self popViewControllerTransition:transition callNULLCallbacks]; }

- (UIViewController *)popViewControllerTransition:(AGXTransition)transition defCallbacks {
    if (self.viewControllers.count == 0) return nil;
    LayerAddTransition(self.topViewController, self.viewControllers.count < 2 ?
                       nil : self.viewControllers[self.viewControllers.count - 2]);
    return [self AGXWidget_popViewControllerAnimated:NO];
}

- (NSArray *)popToViewController:(UIViewController *)viewController defAnimated defCallbacks
{ return [self popToViewController:viewController transition:popTransition callCallbacks]; }
- (NSArray *)popToViewController:(UIViewController *)viewController defTransition
{ return [self popToViewController:viewController callTransition callNULLCallbacks]; }

- (NSArray *)popToViewController:(UIViewController *)viewController defTransition defCallbacks {
    if (![self.viewControllers containsObject:viewController] || self.topViewController == viewController) return @[];
    NSUInteger index = [self.viewControllers indexOfObject:viewController];
    NSArray *poped = [self p_viewControllersWillPopedFromIndex:index];
    [self setViewControllers:[self p_viewControllersWillReserveToIndex:index] callTransition callCallbacks];
    return poped;
}

- (NSArray *)popToRootViewControllerAnimated:(BOOL)animated defCallbacks
{ return [self popToRootViewControllerTransition:popTransition callCallbacks]; }
- (NSArray *)popToRootViewControllerTransition:(AGXTransition)transition
{ return [self popToRootViewControllerTransition:transition callNULLCallbacks]; }

- (NSArray *)popToRootViewControllerTransition:(AGXTransition)transition defCallbacks {
    if (self.viewControllers.count < 2) return @[];
    NSArray *poped = [self p_viewControllersWillPopedFromIndex:0];
    [self setViewControllers:[self p_viewControllersWillReserveToIndex:0] callTransition callCallbacks];
    return poped;
}

- (void)setViewControllers:(NSArray *)viewControllers defAnimated defCallbacks
{ [self setViewControllers:viewControllers transition:pushTransition callCallbacks]; }
- (void)setViewControllers:(NSArray *)viewControllers defTransition
{ [self setViewControllers:viewControllers callTransition callNULLCallbacks]; }

- (void)setViewControllers:(NSArray *)viewControllers defTransition defCallbacks {
    if (self.topViewController != viewControllers.lastObject)
        LayerAddTransition(self.topViewController, viewControllers.lastObject);
    [self AGXWidget_setViewControllers:viewControllers animated:NO];
}

- (UIViewController *)replaceWithViewController:(UIViewController *)viewController defAnimated
{ return [self replaceWithViewController:viewController transition:pushTransition callNULLCallbacks]; }
- (UIViewController *)replaceWithViewController:(UIViewController *)viewController defAnimated defCallbacks
{ return [self replaceWithViewController:viewController transition:pushTransition callCallbacks]; }
- (UIViewController *)replaceWithViewController:(UIViewController *)viewController defTransition
{ return [self replaceWithViewController:viewController callTransition callNULLCallbacks]; }

- (UIViewController *)replaceWithViewController:(UIViewController *)viewController defTransition defCallbacks {
    if (self.viewControllers.count == 0) return nil;
    NSInteger index = self.viewControllers.count - 2;
    NSArray *replaced = [self p_viewControllersWillPopedFromIndex:index];
    NSMutableArray *stack = [self p_viewControllersWillReserveToIndex:index];
    [stack addObject:viewController];
    [self setViewControllers:stack callTransition callCallbacks];
    return replaced.firstObject;
}

- (NSArray *)replaceToViewController:(UIViewController *)toViewController defWithVC defAnimated
{ return [self replaceToViewController:toViewController callWithVC transition:pushTransition callNULLCallbacks]; }
- (NSArray *)replaceToViewController:(UIViewController *)toViewController defWithVC defAnimated defCallbacks
{ return [self replaceToViewController:toViewController callWithVC transition:pushTransition callCallbacks]; }
- (NSArray *)replaceToViewController:(UIViewController *)toViewController defWithVC defTransition
{ return [self replaceToViewController:toViewController callWithVC callTransition callNULLCallbacks]; }

- (NSArray *)replaceToViewController:(UIViewController *)toViewController defWithVC defTransition defCallbacks {
    if (![self.viewControllers containsObject:toViewController]) return @[];
    NSUInteger index = [self.viewControllers indexOfObject:toViewController];
    NSArray *replaced = [self p_viewControllersWillPopedFromIndex:index];
    NSMutableArray *stack = [self p_viewControllersWillReserveToIndex:index];
    [stack addObject:viewController];
    [self setViewControllers:stack callTransition callCallbacks];
    return replaced;
}

- (NSArray *)replaceToRootViewControllerWithViewController:(UIViewController *)viewController defAnimated
{ return [self replaceToRootViewControllerWithViewController:viewController transition:pushTransition callNULLCallbacks]; }
- (NSArray *)replaceToRootViewControllerWithViewController:(UIViewController *)viewController defAnimated defCallbacks
{ return [self replaceToRootViewControllerWithViewController:viewController transition:pushTransition callCallbacks]; }
- (NSArray *)replaceToRootViewControllerWithViewController:(UIViewController *)viewController defTransition
{ return [self replaceToRootViewControllerWithViewController:viewController callTransition callNULLCallbacks]; }

- (NSArray *)replaceToRootViewControllerWithViewController:(UIViewController *)viewController defTransition defCallbacks {
    if (self.viewControllers.count == 0) return @[];
    NSArray *replaced = [self p_viewControllersWillPopedFromIndex:0];
    NSMutableArray *stack = [self p_viewControllersWillReserveToIndex:0];
    [stack addObject:viewController];
    [self setViewControllers:stack callTransition callCallbacks];
    return replaced;
}

#pragma mark - swizzle methods

- (void)AGXWidget_pushViewController:(UIViewController *)viewController defAnimated {
    [self pushViewController:viewController transition:pushTransition callNULLCallbacks];
}

- (UIViewController *)AGXWidget_popViewControllerAnimated:(BOOL)animated {
    return [self popViewControllerTransition:popTransition callNULLCallbacks];
}

- (NSArray *)AGXWidget_popToViewController:(UIViewController *)viewController defAnimated {
    return [self popToViewController:viewController transition:popTransition callNULLCallbacks];
}

- (NSArray *)AGXWidget_popToRootViewControllerAnimated:(BOOL)animated {
    return [self popToRootViewControllerTransition:popTransition callNULLCallbacks];
}

- (void)AGXWidget_setViewControllers:(NSArray *)viewControllers defAnimated {
    [self setViewControllers:viewControllers transition:pushTransition callNULLCallbacks];
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
    });
}

#undef LayerAddTransition
#undef callNULLCallbacks
#undef callPopTransition
#undef callPushTransition

#pragma mark - private methods

- (NSArray *)p_viewControllersWillPopedFromIndex:(NSInteger)index {
    return AGX_AUTORELEASE([[self.viewControllers subarrayWithRange:NSMakeRange
                             (index+1, self.viewControllers.count-index-1)] copy]);
}

- (NSMutableArray *)p_viewControllersWillReserveToIndex:(NSInteger)index {
    return AGX_AUTORELEASE([[self.viewControllers subarrayWithRange:NSMakeRange
                             (0, index+1)] mutableCopy]);
}

@end

@category_implementation(UIViewController, AGXWidgetUINavigationController)

#define NAVIGATION self.navigationController

- (void)pushViewController:(UIViewController *)viewController defAnimated
{ [NAVIGATION pushViewController:viewController callAnimated]; }
- (void)pushViewController:(UIViewController *)viewController defAnimated defCallbacks
{ [NAVIGATION pushViewController:viewController callAnimated callCallbacks]; }
- (void)pushViewController:(UIViewController *)viewController defTransition
{ [NAVIGATION pushViewController:viewController callTransition]; }
- (void)pushViewController:(UIViewController *)viewController defTransition defCallbacks
{ [NAVIGATION pushViewController:viewController callTransition callCallbacks]; }

- (UIViewController *)popViewControllerAnimated:(BOOL)animated
{ return [NAVIGATION popViewControllerAnimated:animated]; }
- (UIViewController *)popViewControllerAnimated:(BOOL)animated defCallbacks
{ return [NAVIGATION popViewControllerAnimated:animated callCallbacks]; }
- (UIViewController *)popViewControllerTransition:(AGXTransition)transition
{ return [NAVIGATION popViewControllerTransition:transition]; }
- (UIViewController *)popViewControllerTransition:(AGXTransition)transition defCallbacks
{ return [NAVIGATION popViewControllerTransition:transition callCallbacks]; }

- (NSArray *)popToViewController:(UIViewController *)viewController defAnimated
{ return [NAVIGATION popToViewController:viewController callAnimated]; }
- (NSArray *)popToViewController:(UIViewController *)viewController defAnimated defCallbacks
{ return [NAVIGATION popToViewController:viewController callAnimated callCallbacks]; }
- (NSArray *)popToViewController:(UIViewController *)viewController defTransition
{ return [NAVIGATION popToViewController:viewController callTransition]; }
- (NSArray *)popToViewController:(UIViewController *)viewController defTransition defCallbacks
{ return [NAVIGATION popToViewController:viewController callTransition callCallbacks]; }

- (NSArray *)popToRootViewControllerAnimated:(BOOL)animated
{ return [NAVIGATION popToRootViewControllerAnimated:animated]; }
- (NSArray *)popToRootViewControllerAnimated:(BOOL)animated defCallbacks
{ return [NAVIGATION popToRootViewControllerAnimated:animated callCallbacks]; }
- (NSArray *)popToRootViewControllerTransition:(AGXTransition)transition
{ return [NAVIGATION popToRootViewControllerTransition:transition]; }
- (NSArray *)popToRootViewControllerTransition:(AGXTransition)transition defCallbacks
{ return [NAVIGATION popToRootViewControllerTransition:transition callCallbacks]; }

- (void)setViewControllers:(NSArray *)viewControllers defAnimated
{ [NAVIGATION setViewControllers:viewControllers callAnimated]; }
- (void)setViewControllers:(NSArray *)viewControllers defAnimated defCallbacks
{ [NAVIGATION setViewControllers:viewControllers callAnimated callCallbacks]; }
- (void)setViewControllers:(NSArray *)viewControllers defTransition
{ [NAVIGATION setViewControllers:viewControllers callTransition]; }
- (void)setViewControllers:(NSArray *)viewControllers defTransition defCallbacks
{ [NAVIGATION setViewControllers:viewControllers callTransition callCallbacks]; }

- (UIViewController *)replaceWithViewController:(UIViewController *)viewController defAnimated
{ return [NAVIGATION replaceWithViewController:viewController callAnimated]; }
- (UIViewController *)replaceWithViewController:(UIViewController *)viewController defAnimated defCallbacks
{ return [NAVIGATION replaceWithViewController:viewController callAnimated callCallbacks]; }
- (UIViewController *)replaceWithViewController:(UIViewController *)viewController defTransition
{ return [NAVIGATION replaceWithViewController:viewController callTransition]; }
- (UIViewController *)replaceWithViewController:(UIViewController *)viewController defTransition defCallbacks
{ return [NAVIGATION replaceWithViewController:viewController callTransition callCallbacks]; }

- (NSArray *)replaceToViewController:(UIViewController *)toViewController defWithVC defAnimated
{ return [NAVIGATION replaceToViewController:toViewController callWithVC callAnimated]; }
- (NSArray *)replaceToViewController:(UIViewController *)toViewController defWithVC defAnimated defCallbacks
{ return [NAVIGATION replaceToViewController:toViewController callWithVC callAnimated callCallbacks]; }
- (NSArray *)replaceToViewController:(UIViewController *)toViewController defWithVC defTransition
{ return [NAVIGATION replaceToViewController:toViewController callWithVC callTransition]; }
- (NSArray *)replaceToViewController:(UIViewController *)toViewController defWithVC defTransition defCallbacks
{ return [NAVIGATION replaceToViewController:toViewController callWithVC callTransition callCallbacks]; }

- (NSArray *)replaceToRootViewControllerWithViewController:(UIViewController *)viewController defAnimated
{ return [NAVIGATION replaceToRootViewControllerWithViewController:viewController callAnimated]; }
- (NSArray *)replaceToRootViewControllerWithViewController:(UIViewController *)viewController defAnimated defCallbacks
{ return [NAVIGATION replaceToRootViewControllerWithViewController:viewController callAnimated callCallbacks]; }
- (NSArray *)replaceToRootViewControllerWithViewController:(UIViewController *)viewController defTransition
{ return [NAVIGATION replaceToRootViewControllerWithViewController:viewController callTransition]; }
- (NSArray *)replaceToRootViewControllerWithViewController:(UIViewController *)viewController defTransition defCallbacks
{ return [NAVIGATION replaceToRootViewControllerWithViewController:viewController callTransition callCallbacks]; }

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

#pragma mark - private implementations

AGX_STATIC NSString *CATransitionType(AGXTransitionType type);
AGX_STATIC NSString *CATransitionSubType(AGXTransitionDirection direction);

@interface AGXTransitionDelegate : NSObject
@property (nonatomic, AGX_STRONG)   UIViewController        *fromViewController;
@property (nonatomic, AGX_STRONG)   UIViewController        *toViewController;
@property (nonatomic, copy)         AGXTransitionCallback    started;
@property (nonatomic, copy)         AGXTransitionCallback    finished;
@end

@implementation AGXTransitionDelegate

- (void)dealloc {
    AGX_RELEASE(_fromViewController);
    AGX_RELEASE(_toViewController);
    AGX_BLOCK_RELEASE(_started);
    AGX_BLOCK_RELEASE(_finished);
    AGX_SUPER_DEALLOC;
}

- (void)setStarted:(AGXTransitionCallback)started {
    AGXTransitionCallback temp = AGX_BLOCK_COPY(started);
    AGX_BLOCK_RELEASE(_started);
    _started = temp;
}

- (void)setFinished:(AGXTransitionCallback)finished {
    AGXTransitionCallback temp = AGX_BLOCK_COPY(finished);
    AGX_BLOCK_RELEASE(_finished);
    _finished = temp;
}

- (void)animationDidStart:(CAAnimation *)anim {
    if (_started) _started(_fromViewController, _toViewController);
}

- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag {
    if (_finished) _finished(_fromViewController, _toViewController);
}

@end

@category_implementation(CATransition, AGXWidget)

+ (CATransition *)transitionWithTransition:(AGXTransition)transition delegateFromViewController:(UIViewController *)fromViewController toViewController:(UIViewController *)toViewController started:(AGXTransitionCallback)started finished:(AGXTransitionCallback)finished {
    CATransition *trans = [CATransition animation];
    trans.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
    trans.type = CATransitionType(transition.type);
    trans.subtype = CATransitionSubType(transition.direction);
    trans.duration = transition.duration;
    
    AGXTransitionDelegate *delegate = [[AGXTransitionDelegate alloc] init];
    delegate.fromViewController = fromViewController;
    delegate.toViewController = toViewController;
    delegate.started = started;
    delegate.finished = finished;
    trans.delegate = AGX_AUTORELEASE(delegate);
    
    return trans;
}

@end

AGX_INLINE AGXTransition AGXTransitionMake(AGXTransitionType t, AGXTransitionDirection d, NSTimeInterval r)
{ return (AGXTransition){ .type = t, .direction = d, .duration = r }; }

AGXTransition AGXDefaultPushTransition = { .type = AGXTransitionPush, .direction = AGXTransitionFromRight, .duration = 0.3 };
AGXTransition AGXDefaultPopTransition = { .type = AGXTransitionPush, .direction = AGXTransitionFromLeft, .duration = 0.3 };
AGXTransition AGXNoTransition = { .type = AGXTransitionFade, .direction = AGXTransitionNone, .duration = 0 };

AGX_STATIC NSString *CATransitionType(AGXTransitionType type) {
    switch(type) {
        case AGXTransitionFade: return kCATransitionFade;
        case AGXTransitionPush: return kCATransitionPush;
        case AGXTransitionMoveIn: return kCATransitionMoveIn;
        case AGXTransitionReveal: return kCATransitionReveal;
        case AGXTransitionCube: return @"cube";
        case AGXTransitionOglFlip: return @"oglFlip";
        case AGXTransitionSuckEffect: return @"suckEffect";
        case AGXTransitionRippleEffect: return @"rippleEffect";
        case AGXTransitionPageCurl: return @"pageCurl";
        case AGXTransitionPageUnCurl: return @"pageUnCurl";
        case AGXTransitionCameraIrisHollowOpen: return @"cameraIrisHollowOpen";
        case AGXTransitionCameraIrisHollowClose: return @"cameraIrisHollowClose";
    }
}

AGX_STATIC NSString *CATransitionSubType(AGXTransitionDirection direction) {
    switch(direction) {
        case AGXTransitionNone: return nil;
        case AGXTransitionFromRight: return kCATransitionFromRight;
        case AGXTransitionFromLeft: return kCATransitionFromLeft;
        case AGXTransitionFromTop: return kCATransitionFromTop;
        case AGXTransitionFromBottom: return kCATransitionFromBottom;
    }
}
