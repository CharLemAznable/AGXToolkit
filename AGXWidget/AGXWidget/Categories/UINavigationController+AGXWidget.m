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

AGXTransition AGXNoTransition;

@category_interface(CATransition, AGXWidget)
+ (CATransition *)transitionWithTransition:(AGXTransition)transition delegateFromViewController:(UIViewController *)fromViewController toViewController:(UIViewController *)toViewController started:(AGXTransitionCallback)started finished:(AGXTransitionCallback)finished;
@end

@category_implementation(UINavigationController, AGXWidget)

#define PUSH_TRANSITION animated?AGXDefaultPushTransition:AGXNoTransition
#define POP_TRANSITION animated?AGXDefaultPopTransition:AGXNoTransition

#pragma mark - default transition

- (UIViewController *)replaceWithViewController:(UIViewController *)viewController animated:(BOOL)animated {
    return [self replaceWithViewController:viewController transition:PUSH_TRANSITION started:NULL finished:NULL];
}

- (NSArray *)replaceToViewController:(UIViewController *)toViewController withViewController:(UIViewController *)viewController animated:(BOOL)animated {
    return [self replaceToViewController:toViewController withViewController:viewController transition:PUSH_TRANSITION started:NULL finished:NULL];
}

- (NSArray *)replaceToRootViewControllerWithViewController:(UIViewController *)viewController animated:(BOOL)animated {
    return [self replaceToRootViewControllerWithViewController:viewController transition:PUSH_TRANSITION started:NULL finished:NULL];
}

#pragma mark - custom transition

- (void)pushViewController:(UIViewController *)viewController transition:(AGXTransition)transition {
    [self pushViewController:viewController transition:transition started:NULL finished:NULL];
}

- (UIViewController *)popViewControllerTransition:(AGXTransition)transition {
    return [self popViewControllerTransition:transition started:NULL finished:NULL];
}

- (NSArray *)popToViewController:(UIViewController *)viewController transition:(AGXTransition)transition {
    return [self popToViewController:viewController transition:transition started:NULL finished:NULL];
}

- (NSArray *)popToRootViewControllerTransition:(AGXTransition)transition {
    return [self popToRootViewControllerTransition:transition started:NULL finished:NULL];
}

- (void)setViewControllers:(NSArray *)viewControllers transition:(AGXTransition)transition {
    [self setViewControllers:viewControllers transition:transition started:NULL finished:NULL];
}

- (UIViewController *)replaceWithViewController:(UIViewController *)viewController transition:(AGXTransition)transition {
    return [self replaceWithViewController:viewController transition:transition started:NULL finished:NULL];
}

- (NSArray *)replaceToViewController:(UIViewController *)toViewController withViewController:(UIViewController *)viewController transition:(AGXTransition)transition {
    return [self replaceToViewController:toViewController withViewController:viewController transition:transition started:NULL finished:NULL];
}

- (NSArray *)replaceToRootViewControllerWithViewController:(UIViewController *)viewController transition:(AGXTransition)transition {
    return [self replaceToRootViewControllerWithViewController:viewController transition:transition started:NULL finished:NULL];
}

#pragma mark - default transition with blocks

- (void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated started:(AGXTransitionCallback)started finished:(AGXTransitionCallback)finished {
    [self pushViewController:viewController transition:PUSH_TRANSITION started:started finished:finished];
}

- (UIViewController *)popViewControllerAnimated:(BOOL)animated started:(AGXTransitionCallback)started finished:(AGXTransitionCallback)finished {
    return [self popViewControllerTransition:POP_TRANSITION started:started finished:started];
}

- (NSArray *)popToViewController:(UIViewController *)viewController animated:(BOOL)animated started:(AGXTransitionCallback)started finished:(AGXTransitionCallback)finished {
    return [self popToViewController:viewController transition:POP_TRANSITION started:started finished:finished];
}

- (NSArray *)popToRootViewControllerAnimated:(BOOL)animated started:(AGXTransitionCallback)started finished:(AGXTransitionCallback)finished {
    return [self popToRootViewControllerTransition:POP_TRANSITION started:started finished:finished];
}

- (void)setViewControllers:(NSArray *)viewControllers animated:(BOOL)animated started:(AGXTransitionCallback)started finished:(AGXTransitionCallback)finished {
    [self setViewControllers:viewControllers transition:PUSH_TRANSITION started:started finished:finished];
}

- (UIViewController *)replaceWithViewController:(UIViewController *)viewController animated:(BOOL)animated started:(AGXTransitionCallback)started finished:(AGXTransitionCallback)finished {
    return [self replaceWithViewController:viewController transition:PUSH_TRANSITION started:started finished:finished];
}

- (NSArray *)replaceToViewController:(UIViewController *)toViewController withViewController:(UIViewController *)viewController animated:(BOOL)animated started:(AGXTransitionCallback)started finished:(AGXTransitionCallback)finished {
    return [self replaceToViewController:toViewController withViewController:viewController transition:PUSH_TRANSITION started:started finished:finished];
}

- (NSArray *)replaceToRootViewControllerWithViewController:(UIViewController *)viewController animated:(BOOL)animated started:(AGXTransitionCallback)started finished:(AGXTransitionCallback)finished {
    return [self replaceToRootViewControllerWithViewController:viewController transition:PUSH_TRANSITION started:started finished:finished];
}

#pragma mark - custom transition with blocks

- (void)pushViewController:(UIViewController *)viewController transition:(AGXTransition)transition started:(AGXTransitionCallback)started finished:(AGXTransitionCallback)finished {
    CATransition *animation = [CATransition transitionWithTransition:transition delegateFromViewController:
                               self.topViewController toViewController:viewController started:started finished:finished];
    [self.view.layer addAnimation:animation forKey:@"transition"];
    [self AGXWidget_pushViewController:viewController animated:NO];
}

- (UIViewController *)popViewControllerTransition:(AGXTransition)transition started:(AGXTransitionCallback)started finished:(AGXTransitionCallback)finished {
    if (self.viewControllers.count <= 1) return nil;
    CATransition *animation = [CATransition transitionWithTransition:transition delegateFromViewController:
                               self.topViewController toViewController:
                               self.viewControllers[self.viewControllers.count - 2] started:started finished:finished];
    [self.view.layer addAnimation:animation forKey:@"transition"];
    return [self AGXWidget_popViewControllerAnimated:NO];
}

- (NSArray *)popToViewController:(UIViewController *)viewController transition:(AGXTransition)transition started:(AGXTransitionCallback)started finished:(AGXTransitionCallback)finished {
    if (![self.viewControllers containsObject:viewController] || self.topViewController == viewController) return nil;
    NSUInteger index = [self.viewControllers indexOfObject:viewController];
    NSArray *poped = [[self.viewControllers subarrayWithRange:NSMakeRange
                       (index + 1, self.viewControllers.count - index - 1)] copy];
    NSMutableArray *stack = [[self.viewControllers subarrayWithRange:NSMakeRange(0, index + 1)] mutableCopy];
    
    [self setViewControllers:AGX_AUTORELEASE(stack) transition:transition started:started finished:finished];
    return AGX_AUTORELEASE(poped);
}

- (NSArray *)popToRootViewControllerTransition:(AGXTransition)transition started:(AGXTransitionCallback)started finished:(AGXTransitionCallback)finished {
    if (self.viewControllers.count <= 1) return nil;
    NSArray *poped = [[self.viewControllers subarrayWithRange:NSMakeRange(1, self.viewControllers.count - 1)] copy];
    
    [self setViewControllers:@[self.viewControllers.firstObject] transition:transition started:started finished:finished];
    return AGX_AUTORELEASE(poped);
}

- (void)setViewControllers:(NSArray *)viewControllers transition:(AGXTransition)transition started:(AGXTransitionCallback)started finished:(AGXTransitionCallback)finished {
    if (self.topViewController != viewControllers.lastObject) {
        CATransition *animation = [CATransition transitionWithTransition:transition delegateFromViewController:
                                   self.topViewController toViewController:
                                   viewControllers.lastObject started:started finished:finished];
        [self.view.layer addAnimation:animation forKey:@"transition"];
    }
    [self AGXWidget_setViewControllers:viewControllers animated:NO];
}

- (UIViewController *)replaceWithViewController:(UIViewController *)viewController transition:(AGXTransition)transition started:(AGXTransitionCallback)started finished:(AGXTransitionCallback)finished {
    if (self.viewControllers.count == 0) return nil;
    UIViewController *replaced = self.viewControllers.count != 1 ? AGX_RETAIN(self.topViewController) : nil;
    NSMutableArray *stack = [self.viewControllers mutableCopy];
    if (self.viewControllers.count != 1) [stack removeObject:replaced];
    [stack addObject:viewController];
    
    [self setViewControllers:AGX_AUTORELEASE(stack) transition:transition started:started finished:finished];
    return AGX_AUTORELEASE(replaced);
}

- (NSArray *)replaceToViewController:(UIViewController *)toViewController withViewController:(UIViewController *)viewController transition:(AGXTransition)transition started:(AGXTransitionCallback)started finished:(AGXTransitionCallback)finished {
    if (![self.viewControllers containsObject:toViewController]) return nil;
    NSUInteger index = [self.viewControllers indexOfObject:toViewController];
    NSArray *replaced = [[self.viewControllers subarrayWithRange:NSMakeRange
                          (index + 1, self.viewControllers.count - index - 1)] copy];
    NSMutableArray *stack = [[self.viewControllers subarrayWithRange:NSMakeRange(0, index + 1)] mutableCopy];
    [stack addObject:viewController];
    
    [self setViewControllers:AGX_AUTORELEASE(stack) transition:transition started:started finished:finished];
    return AGX_AUTORELEASE(replaced);
}

- (NSArray *)replaceToRootViewControllerWithViewController:(UIViewController *)viewController transition:(AGXTransition)transition started:(AGXTransitionCallback)started finished:(AGXTransitionCallback)finished {
    if (self.viewControllers.count == 0) return nil;
    NSArray *replaced = [[self.viewControllers subarrayWithRange:NSMakeRange(1, self.viewControllers.count - 1)] copy];
    
    [self setViewControllers:@[self.viewControllers.firstObject, viewController]
                  transition:transition started:started finished:finished];
    return AGX_AUTORELEASE(replaced);
}

#pragma mark - swizzle methods

- (void)AGXWidget_pushViewController:(UIViewController *)viewController animated:(BOOL)animated {
    [self pushViewController:viewController transition:PUSH_TRANSITION started:NULL finished:NULL];
}

- (UIViewController *)AGXWidget_popViewControllerAnimated:(BOOL)animated {
    return [self popViewControllerTransition:POP_TRANSITION started:NULL finished:NULL];
}

- (NSArray *)AGXWidget_popToViewController:(UIViewController *)viewController animated:(BOOL)animated {
    return [self popToViewController:viewController transition:POP_TRANSITION started:NULL finished:NULL];
}

- (NSArray *)AGXWidget_popToRootViewControllerAnimated:(BOOL)animated {
    return [self popToRootViewControllerTransition:POP_TRANSITION started:NULL finished:NULL];
}

- (void)AGXWidget_setViewControllers:(NSArray *)viewControllers animated:(BOOL)animated {
    [self setViewControllers:viewControllers transition:PUSH_TRANSITION started:NULL finished:NULL];
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

#undef ANIMATE_TRANSITION

@end

@category_implementation(UIViewController, AGXWidgetUINavigationController)

#define NAVIGATION self.navigationController

#pragma mark - proxy default transition

- (void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated {
    [NAVIGATION pushViewController:viewController animated:animated];
}

- (UIViewController *)popViewControllerAnimated:(BOOL)animated {
    return [NAVIGATION popViewControllerAnimated:animated];
}

- (NSArray *)popToViewController:(UIViewController *)viewController animated:(BOOL)animated {
    return [NAVIGATION popToViewController:viewController animated:animated];
}

- (NSArray *)popToRootViewControllerAnimated:(BOOL)animated {
    return [NAVIGATION popToRootViewControllerAnimated:animated];
}

- (void)setViewControllers:(NSArray *)viewControllers animated:(BOOL)animated {
    [NAVIGATION setViewControllers:viewControllers animated:animated];
}

- (UIViewController *)replaceWithViewController:(UIViewController *)viewController animated:(BOOL)animated {
    return [NAVIGATION replaceWithViewController:viewController animated:animated];
}

- (NSArray *)replaceToViewController:(UIViewController *)toViewController withViewController:(UIViewController *)viewController animated:(BOOL)animated {
    return [NAVIGATION replaceToViewController:toViewController withViewController:viewController animated:animated];
}

- (NSArray *)replaceToRootViewControllerWithViewController:(UIViewController *)viewController animated:(BOOL)animated {
    return [NAVIGATION replaceToRootViewControllerWithViewController:viewController animated:animated];
}

#pragma mark - proxy custom transition

- (void)pushViewController:(UIViewController *)viewController transition:(AGXTransition)transition {
    [NAVIGATION pushViewController:viewController transition:transition];
}

- (UIViewController *)popViewControllerTransition:(AGXTransition)transition {
    return [NAVIGATION popViewControllerTransition:transition];
}

- (NSArray *)popToViewController:(UIViewController *)viewController transition:(AGXTransition)transition {
    return [NAVIGATION popToViewController:viewController transition:transition];
}

- (NSArray *)popToRootViewControllerTransition:(AGXTransition)transition {
    return [NAVIGATION popToRootViewControllerTransition:transition];
}

- (void)setViewControllers:(NSArray *)viewControllers transition:(AGXTransition)transition {
    [NAVIGATION setViewControllers:viewControllers transition:transition];
}

- (UIViewController *)replaceWithViewController:(UIViewController *)viewController transition:(AGXTransition)transition {
    return [NAVIGATION replaceWithViewController:viewController transition:transition];
}

- (NSArray *)replaceToViewController:(UIViewController *)toViewController withViewController:(UIViewController *)viewController transition:(AGXTransition)transition {
    return [NAVIGATION replaceToViewController:toViewController withViewController:viewController transition:transition];
}

- (NSArray *)replaceToRootViewControllerWithViewController:(UIViewController *)viewController transition:(AGXTransition)transition {
    return [NAVIGATION replaceToRootViewControllerWithViewController:viewController transition:transition];
}

#pragma mark - proxy default transition with blocks

- (void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated started:(AGXTransitionCallback)started finished:(AGXTransitionCallback)finished {
    [NAVIGATION pushViewController:viewController animated:animated started:started finished:started];
}

- (UIViewController *)popViewControllerAnimated:(BOOL)animated started:(AGXTransitionCallback)started finished:(AGXTransitionCallback)finished {
    return [NAVIGATION popViewControllerAnimated:animated started:started finished:finished];
}

- (NSArray *)popToViewController:(UIViewController *)viewController animated:(BOOL)animated started:(AGXTransitionCallback)started finished:(AGXTransitionCallback)finished {
    return [NAVIGATION popToViewController:viewController animated:animated started:started finished:finished];
}

- (NSArray *)popToRootViewControllerAnimated:(BOOL)animated started:(AGXTransitionCallback)started finished:(AGXTransitionCallback)finished {
    return [NAVIGATION popToRootViewControllerAnimated:animated started:started finished:finished];
}

- (void)setViewControllers:(NSArray *)viewControllers animated:(BOOL)animated started:(AGXTransitionCallback)started finished:(AGXTransitionCallback)finished {
    [NAVIGATION setViewControllers:viewControllers animated:animated started:started finished:started];
}

- (UIViewController *)replaceWithViewController:(UIViewController *)viewController animated:(BOOL)animated started:(AGXTransitionCallback)started finished:(AGXTransitionCallback)finished {
    return [NAVIGATION replaceWithViewController:viewController animated:animated started:started finished:finished];
}

- (NSArray *)replaceToViewController:(UIViewController *)toViewController withViewController:(UIViewController *)viewController animated:(BOOL)animated started:(AGXTransitionCallback)started finished:(AGXTransitionCallback)finished {
    return [NAVIGATION replaceToViewController:toViewController withViewController:viewController animated:animated started:started finished:finished];
}

- (NSArray *)replaceToRootViewControllerWithViewController:(UIViewController *)viewController animated:(BOOL)animated started:(AGXTransitionCallback)started finished:(AGXTransitionCallback)finished {
    return [NAVIGATION replaceToRootViewControllerWithViewController:viewController animated:animated started:started finished:finished];
}

#pragma mark - proxy custom transition with blocks

- (void)pushViewController:(UIViewController *)viewController transition:(AGXTransition)transition started:(AGXTransitionCallback)started finished:(AGXTransitionCallback)finished {
    [NAVIGATION pushViewController:viewController transition:transition started:started finished:started];
}

- (UIViewController *)popViewControllerTransition:(AGXTransition)transition started:(AGXTransitionCallback)started finished:(AGXTransitionCallback)finished {
    return [NAVIGATION popViewControllerTransition:transition started:started finished:finished];
}

- (NSArray *)popToViewController:(UIViewController *)viewController transition:(AGXTransition)transition started:(AGXTransitionCallback)started finished:(AGXTransitionCallback)finished {
    return [NAVIGATION popToViewController:viewController transition:transition started:started finished:finished];
}

- (NSArray *)popToRootViewControllerTransition:(AGXTransition)transition started:(AGXTransitionCallback)started finished:(AGXTransitionCallback)finished {
    return [NAVIGATION popToRootViewControllerTransition:transition started:started finished:finished];
}

- (void)setViewControllers:(NSArray *)viewControllers transition:(AGXTransition)transition started:(AGXTransitionCallback)started finished:(AGXTransitionCallback)finished {
    [NAVIGATION setViewControllers:viewControllers transition:transition started:started finished:finished];
}

- (UIViewController *)replaceWithViewController:(UIViewController *)viewController transition:(AGXTransition)transition started:(AGXTransitionCallback)started finished:(AGXTransitionCallback)finished {
    return [NAVIGATION replaceWithViewController:viewController transition:transition started:started finished:finished];
}

- (NSArray *)replaceToViewController:(UIViewController *)toViewController withViewController:(UIViewController *)viewController transition:(AGXTransition)transition started:(AGXTransitionCallback)started finished:(AGXTransitionCallback)finished {
    return [NAVIGATION replaceToViewController:toViewController withViewController:viewController transition:transition started:started finished:finished];
}

- (NSArray *)replaceToRootViewControllerWithViewController:(UIViewController *)viewController transition:(AGXTransition)transition started:(AGXTransitionCallback)started finished:(AGXTransitionCallback)finished {
    return [NAVIGATION replaceToRootViewControllerWithViewController:viewController transition:transition started:started finished:finished];
}

#undef NAVIGATION

@end

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

AGX_INLINE AGXTransition AGXTransitionMake(AGXTransitionType t, AGXTransitionDirection d, NSTimeInterval r)
{ return (AGXTransition){ .type = t, .direction = d, .duration = r }; }

AGXTransition AGXDefaultPushTransition = { .type = AGXTransitionPush, .direction = AGXTransitionFromRight, .duration = 0.3 };
AGXTransition AGXDefaultPopTransition = { .type = AGXTransitionPush, .direction = AGXTransitionFromLeft, .duration = 0.3 };
AGXTransition AGXNoTransition = { .type = AGXTransitionFade, .direction = AGXTransitionNone, .duration = 0 };
