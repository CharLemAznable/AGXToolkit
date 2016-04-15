//
//  AGXNavigationControllerInternalDelegate.m
//  AGXWidget
//
//  Created by Char Aznable on 16/4/15.
//  Copyright © 2016年 AI-CUC-EC. All rights reserved.
//

#import "AGXNavigationControllerInternalDelegate.h"
#import "AGXAnimationInternal.h"

@interface AGXNavigationTransition ()
@property (nonatomic, assign)   UINavigationControllerOperation agxOperation;
@property (nonatomic, assign)   AGXTransition                   agxTransition;
@property (nonatomic, copy)     AGXTransitionCallback           agxStartTransition;
@property (nonatomic, copy)     AGXTransitionCallback           agxFinishTransition;
@end

#pragma mark - AGXNavigationControllerInternalDelegate

@implementation AGXNavigationControllerInternalDelegate {
    AGXNavigationTransition *_navigationTransition;
}

- (AGX_INSTANCETYPE)init {
    if (AGX_EXPECT_T(self = [super init])) {
        _navigationTransition = [[AGXNavigationTransition alloc] init];
    }
    return self;
}

- (void)dealloc {
    AGX_RELEASE(_navigationTransition);
    AGX_SUPER_DEALLOC;
}

- (AGXTransition)agxTransition {
    return _navigationTransition.agxTransition;
}

- (void)setAgxTransition:(AGXTransition)agxTransition {
    _navigationTransition.agxTransition = agxTransition;
}

- (AGXTransitionCallback)agxStartTransition {
    return _navigationTransition.agxStartTransition;
}

- (void)setAgxStartTransition:(AGXTransitionCallback)agxStartTransition {
    _navigationTransition.agxStartTransition = agxStartTransition;
}

- (AGXTransitionCallback)agxFinishTransition {
    return _navigationTransition.agxFinishTransition;
}

- (void)setAgxFinishTransition:(AGXTransitionCallback)agxFinishTransition {
    _navigationTransition.agxFinishTransition = agxFinishTransition;
}

#pragma mark - UINavigationControllerDelegate

- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated {
    if ([_delegate respondsToSelector:@selector(navigationController:willShowViewController:animated:)]) {
        [_delegate navigationController:navigationController willShowViewController:viewController animated:animated];
    }
}

- (void)navigationController:(UINavigationController *)navigationController didShowViewController:(UIViewController *)viewController animated:(BOOL)animated {
    if ([_delegate respondsToSelector:@selector(navigationController:didShowViewController:animated:)]) {
        [_delegate navigationController:navigationController didShowViewController:viewController animated:animated];
    }
}

- (UIInterfaceOrientationMask)navigationControllerSupportedInterfaceOrientations:(UINavigationController *)navigationController {
    if ([_delegate respondsToSelector:@selector(navigationControllerSupportedInterfaceOrientations:)]) {
        return [_delegate navigationControllerSupportedInterfaceOrientations:navigationController];
    }
    return UIInterfaceOrientationMaskAll;
}

- (UIInterfaceOrientation)navigationControllerPreferredInterfaceOrientationForPresentation:(UINavigationController *)navigationController {
    if ([_delegate respondsToSelector:@selector(navigationControllerPreferredInterfaceOrientationForPresentation:)]) {
        return [_delegate navigationControllerPreferredInterfaceOrientationForPresentation:navigationController];
    }
    return UIInterfaceOrientationUnknown;
}

- (id<UIViewControllerInteractiveTransitioning>)navigationController:(UINavigationController *)navigationController interactionControllerForAnimationController:(id<UIViewControllerAnimatedTransitioning>)animationController {
    if ([_delegate respondsToSelector:@selector(navigationController:interactionControllerForAnimationController:)]) {
        return [_delegate navigationController:navigationController interactionControllerForAnimationController:animationController];
    }
    return nil;
}

- (id<UIViewControllerAnimatedTransitioning>)navigationController:(UINavigationController *)navigationController animationControllerForOperation:(UINavigationControllerOperation)operation fromViewController:(UIViewController *)fromVC toViewController:(UIViewController *)toVC {
    if ([_delegate respondsToSelector:@selector(navigationController:animationControllerForOperation:fromViewController:toViewController:)]) {
        return [_delegate navigationController:navigationController animationControllerForOperation:operation fromViewController:fromVC toViewController:toVC];
    }
    _navigationTransition.agxOperation = operation;
    return _navigationTransition;
}

@end

#pragma mark - AGXNavigationTransition

@implementation AGXNavigationTransition

- (void)dealloc {
    AGX_BLOCK_RELEASE(_agxStartTransition);
    AGX_BLOCK_RELEASE(_agxFinishTransition);
    AGX_SUPER_DEALLOC;
}

- (void)setAgxStartTransition:(AGXTransitionCallback)agxStartTransition {
    AGXTransitionCallback temp = AGX_BLOCK_COPY(agxStartTransition);
    AGX_BLOCK_RELEASE(_agxStartTransition);
    _agxStartTransition = temp;
}

- (void)setAgxFinishTransition:(AGXTransitionCallback)agxFinishTransition {
    AGXTransitionCallback temp = AGX_BLOCK_COPY(agxFinishTransition);
    AGX_BLOCK_RELEASE(_agxFinishTransition);
    _agxFinishTransition = temp;
}

- (NSTimeInterval)transitionDuration:(id<UIViewControllerContextTransitioning>)transitionContext {
    return _agxTransition.duration;
}

- (void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext {
    UIViewController *fromVC = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    UIViewController *toVC = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    UIView *container = [transitionContext containerView];
    
    if (_agxOperation == UINavigationControllerOperationPop) [container addSubview:toVC.view];
    [container addSubview:fromVC.view];
    if (_agxOperation == UINavigationControllerOperationPush) [container addSubview:toVC.view];
    
    fromVC.view.frame = [transitionContext initialFrameForViewController:fromVC];
    toVC.view.frame = [transitionContext finalFrameForViewController:toVC];
    
    if (_agxStartTransition) _agxStartTransition(fromVC, toVC);
    
    AGXTransitionInternal internal = buildInternalTransition(fromVC.view, toVC.view, _agxTransition);
    
    UIView *fromMaskView = nil;
    UIView *toMaskView = nil;
    if (internal.hasMask) {
        fromMaskView = AGX_AUTORELEASE([[UIView alloc] initWithFrame:fromVC.view.bounds]);
        fromMaskView.layer.backgroundColor = [UIColor whiteColor].CGColor;
        fromVC.view.layer.mask = fromMaskView.layer;
        
        toMaskView = AGX_AUTORELEASE([[UIView alloc] initWithFrame:toVC.view.bounds]);
        toMaskView.layer.backgroundColor = [UIColor whiteColor].CGColor;
        toVC.view.layer.mask = toMaskView.layer;
    }
    
    fromVC.view.transform = internal.fromViewTransform.from;
    fromVC.view.alpha = internal.fromViewAlpha.from;
    fromMaskView.transform = internal.fromMaskTransform.from;
    toVC.view.transform = internal.toViewTransform.from;
    toVC.view.alpha = internal.toViewAlpha.from;
    toMaskView.transform = internal.toMaskTransform.from;
    [UIView animateWithDuration:internal.duration
                     animations:^{
                         fromVC.view.transform = internal.fromViewTransform.to;
                         fromVC.view.alpha = internal.fromViewAlpha.to;
                         fromMaskView.transform = internal.fromMaskTransform.to;
                         toVC.view.transform = internal.toViewTransform.to;
                         toVC.view.alpha = internal.toViewAlpha.to;
                         toMaskView.transform = internal.toMaskTransform.to; }
     
                     completion:^(BOOL finished) {
                         fromVC.view.transform = internal.fromViewTransform.final;
                         fromVC.view.alpha = internal.fromViewAlpha.final;
                         fromMaskView.transform = internal.fromMaskTransform.final;
                         toVC.view.transform = internal.toViewTransform.final;
                         toVC.view.alpha = internal.toViewAlpha.final;
                         toMaskView.transform = internal.toMaskTransform.final;
                         
                         if (_agxFinishTransition) _agxFinishTransition(fromVC, toVC);
                         [transitionContext completeTransition:YES]; }];
}

@end
