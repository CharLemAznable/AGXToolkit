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
#define defTransited    transited:(AGXTransition)transition
#define defCallbacks    started:(AGXTransitionCallback)started finished:(AGXTransitionCallback)finished
#define defWithVC       withViewController:(UIViewController *)viewController
#define callAnimated    animated:animated
#define callTransited   transited:transition
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
{ [self pushViewController:viewController transited:pushTransition callCallbacks]; }
- (void)pushViewController:(UIViewController *)viewController defTransited
{ [self pushViewController:viewController callTransited callNULLCallbacks]; }

- (void)pushViewController:(UIViewController *)viewController defTransited defCallbacks {
    LayerAddTransition(self.topViewController, viewController);
    [self AGXWidget_pushViewController:viewController animated:NO];
}

- (UIViewController *)popViewControllerAnimated:(BOOL)animated defCallbacks
{ return [self popViewControllerTransited:popTransition callCallbacks]; }
- (UIViewController *)popViewControllerTransited:(AGXTransition)transition
{ return [self popViewControllerTransited:transition callNULLCallbacks]; }

- (UIViewController *)popViewControllerTransited:(AGXTransition)transition defCallbacks {
    if (self.viewControllers.count == 0) return nil;
    LayerAddTransition(self.topViewController, self.viewControllers.count < 2 ?
                       nil : self.viewControllers[self.viewControllers.count - 2]);
    return [self AGXWidget_popViewControllerAnimated:NO];
}

- (NSArray *)popToViewController:(UIViewController *)viewController defAnimated defCallbacks
{ return [self popToViewController:viewController transited:popTransition callCallbacks]; }
- (NSArray *)popToViewController:(UIViewController *)viewController defTransited
{ return [self popToViewController:viewController callTransited callNULLCallbacks]; }

- (NSArray *)popToViewController:(UIViewController *)viewController defTransited defCallbacks {
    if (![self.viewControllers containsObject:viewController] || self.topViewController == viewController) return @[];
    LayerAddTransition(self.topViewController, viewController);
    return [self AGXWidget_popToViewController:viewController animated:NO];
}

- (NSArray *)popToRootViewControllerAnimated:(BOOL)animated defCallbacks
{ return [self popToRootViewControllerTransited:popTransition callCallbacks]; }
- (NSArray *)popToRootViewControllerTransited:(AGXTransition)transition
{ return [self popToRootViewControllerTransited:transition callNULLCallbacks]; }

- (NSArray *)popToRootViewControllerTransited:(AGXTransition)transition defCallbacks {
    if (self.viewControllers.count < 2) return @[];
    LayerAddTransition(self.topViewController, self.viewControllers.firstObject);
    return [self AGXWidget_popToRootViewControllerAnimated:NO];
}

- (void)setViewControllers:(NSArray *)viewControllers defAnimated defCallbacks
{ [self setViewControllers:viewControllers transited:pushTransition callCallbacks]; }
- (void)setViewControllers:(NSArray *)viewControllers defTransited
{ [self setViewControllers:viewControllers callTransited callNULLCallbacks]; }

- (void)setViewControllers:(NSArray *)viewControllers defTransited defCallbacks {
    if (self.topViewController != viewControllers.lastObject)
        LayerAddTransition(self.topViewController, viewControllers.lastObject);
    [self AGXWidget_setViewControllers:viewControllers animated:NO];
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
    NSArray *poping = [self p_viewControllersWillPopedFromIndex:index];
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
    NSArray *poping = [self p_viewControllersWillPopedFromIndex:0];
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

@end

@category_implementation(UIViewController, AGXWidgetUINavigationController)

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
