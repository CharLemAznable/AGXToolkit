//
//  AGXNavigationControllerInternalDelegate.m
//  AGXWidget
//
//  Created by Char Aznable on 2016/4/15.
//  Copyright © 2016年 AI-CUC-EC. All rights reserved.
//

#import <AGXCore/AGXCore/AGXMath.h>
#import <AGXCore/AGXCore/NSObject+AGXCore.h>
#import <AGXCore/AGXCore/NSArray+AGXCore.h>
#import <AGXCore/AGXCore/UIApplication+AGXCore.h>
#import <AGXCore/AGXCore/UIView+AGXCore.h>
#import <AGXCore/AGXCore/UIImage+AGXCore.h>
#import <AGXCore/AGXCore/UIImageView+AGXCore.h>
#import <AGXCore/AGXCore/UIViewController+AGXCore.h>
#import <AGXCore/AGXCore/UIGestureRecognizer+AGXCore.h>
#import "AGXNavigationControllerInternalDelegate.h"
#import "AGXAnimationInternal.h"
#import "AGXGestureRecognizerTags.h"

#pragma mark - AGXNavigationTransition

@interface AGXNavigationTransition : NSObject <UIViewControllerAnimatedTransitioning>
@property (nonatomic, assign)       UINavigationControllerOperation agxOperation;
@property (nonatomic, assign)       AGXTransition                   agxTransition;
@property (nonatomic, copy)         AGXTransitionCallback           agxStartTransition;
@property (nonatomic, copy)         AGXTransitionCallback           agxFinishTransition;
@property (nonatomic, AGX_WEAK)     UINavigationController         *navigationController;
@end

@implementation AGXNavigationTransition

- (void)dealloc {
    AGX_BLOCK_RELEASE(_agxStartTransition);
    AGX_BLOCK_RELEASE(_agxFinishTransition);
    _navigationController = nil;
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
    UIView *fromView = fromVC.view;
    UIView *toView = toVC.view;
    BOOL fromViewMasksToBounds = fromView.masksToBounds;
    BOOL toViewMasksToBounds = toView.masksToBounds;

    fromView.masksToBounds = NO;
    toView.masksToBounds = NO;
    UIView *fromSnapshotBar, *toSnapshotBar;
    [self p_fromSnapshotView:&fromSnapshotBar forFromViewController:fromVC
              toSnapshotView:&toSnapshotBar forToViewController:toVC];
    [fromView addSubview:fromSnapshotBar];
    [toView addSubview:toSnapshotBar];

    if (UINavigationControllerOperationPop == _agxOperation) [container addSubview:toView];
    [container addSubview:fromView];
    if (UINavigationControllerOperationPush == _agxOperation) [container addSubview:toView];
    container.subviews.lastObject.shadowOpacity = 1.0;
    container.subviews.lastObject.shadowOffset = CGSizeMake(0, 0);

    fromView.frame = [transitionContext initialFrameForViewController:fromVC];
    toView.frame = [transitionContext finalFrameForViewController:toVC];

    if (_agxStartTransition) _agxStartTransition(fromVC, toVC);

    AGXTransitionInternal internal = buildInternalTransition(fromView, toView, _agxTransition);

    UIView *fromMaskView = nil;
    UIView *toMaskView = nil;
    if (internal.hasFromMask) {
        fromMaskView = [UIView viewWithFrame:fromVC.view.bounds];
        fromMaskView.layer.backgroundColor = [UIColor whiteColor].CGColor;
        fromView.layer.mask = fromMaskView.layer;
    }
    if (internal.hasToMask) {
        toMaskView = [UIView viewWithFrame:toVC.view.bounds];
        toMaskView.layer.backgroundColor = [UIColor whiteColor].CGColor;
        toView.layer.mask = toMaskView.layer;
    }

    if (internal.duration > 0) {
        UIView *barMaskView = [UIView viewWithFrame:_navigationController.navigationBar.bounds];
        barMaskView.layer.backgroundColor = [UIColor clearColor].CGColor;
        _navigationController.navigationBar.layer.mask = barMaskView.layer;
    }

    fromView.transform = internal.fromViewTransform.from;
    fromView.alpha = internal.fromViewAlpha.from;
    fromMaskView.transform = internal.fromMaskTransform.from;
    toView.transform = internal.toViewTransform.from;
    toView.alpha = internal.toViewAlpha.from;
    toMaskView.transform = internal.toMaskTransform.from;
    [UIView animateWithDuration:internal.duration delay:0
                        options:UIViewAnimationOptionCurveLinear
                     animations:^{
                         fromView.transform = internal.fromViewTransform.to;
                         fromView.alpha = internal.fromViewAlpha.to;
                         fromMaskView.transform = internal.fromMaskTransform.to;
                         toView.transform = internal.toViewTransform.to;
                         toView.alpha = internal.toViewAlpha.to;
                         toMaskView.transform = internal.toMaskTransform.to; }

                     completion:^(BOOL finished) {
                         fromView.transform = internal.fromViewTransform.final;
                         fromView.alpha = internal.fromViewAlpha.final;
                         fromMaskView.transform = internal.fromMaskTransform.final;
                         toView.transform = internal.toViewTransform.final;
                         toView.alpha = internal.toViewAlpha.final;
                         toMaskView.transform = internal.toMaskTransform.final;

                         _navigationController.navigationBar.layer.mask = nil;
                         [fromSnapshotBar removeFromSuperview];
                         [toSnapshotBar removeFromSuperview];
                         fromView.masksToBounds = fromViewMasksToBounds;
                         toView.masksToBounds = toViewMasksToBounds;

                         if ([transitionContext transitionWasCancelled]) {
                             [transitionContext completeTransition:NO];
                         } else {
                             if (_agxFinishTransition) _agxFinishTransition(fromVC, toVC);
                             [transitionContext completeTransition:YES];
                         } }];
}

#pragma mark - private methods

- (void)p_fromSnapshotView:(UIView **)fromSnapshotView forFromViewController:(UIViewController *)fromViewController toSnapshotView:(UIView **)toSnapshotView forToViewController:(UIViewController *)toViewController {
    UINavigationBar *copyBar = [[UINavigationBar alloc] initWithFrame:_navigationController.navigationBar.frame];
    copyBar.items = AGX_AUTORELEASE([_navigationController.navigationBar.items deepCopy]);
    [_navigationController.navigationBar.superview insertSubview:copyBar atIndex:0];

    *fromSnapshotView = [self p_navigationBarSnapshotViewWithImage:copyBar.imageRepresentation
                                                   statusBarHidden:fromViewController.statusBarHidden];

    if (UINavigationControllerOperationPop == _agxOperation &&
        copyBar.items.count > _navigationController.viewControllers.count)
        [copyBar popNavigationItemAnimated:NO];
    if (UINavigationControllerOperationPush == _agxOperation &&
        copyBar.items.count < _navigationController.viewControllers.count) {
        [copyBar pushNavigationItem:toViewController.navigationItem.duplicate animated:NO];
    }

    *toSnapshotView = [self p_navigationBarSnapshotViewWithImage:copyBar.imageRepresentation
                                                 statusBarHidden:toViewController.statusBarHidden];

    [copyBar removeFromSuperview];
    AGX_RELEASE(copyBar);
}

- (UIView *)p_navigationBarSnapshotViewWithImage:(UIImage *)navigationBarImage statusBarHidden:(BOOL)statusBarHidden {
    CGFloat navigationBarWidth = navigationBarImage.size.width;
    CGFloat navigationBarHeight = navigationBarImage.size.height;
    UIImageView *navigationBarImageView = [UIImageView imageViewWithImage:navigationBarImage];
    navigationBarImageView.frame = CGRectMake(0, -navigationBarHeight, navigationBarWidth, navigationBarHeight);

    UIColor *navigationBarColor = navigationBarImage.dominantColor;
    CGFloat statusBarHeight = statusBarHidden ? 0 : 20;
    UIImageView *statusBarImageView = [UIImageView imageViewWithImage:
                                       [UIImage imageRectWithColor:navigationBarColor size:CGSizeMake
                                        (navigationBarWidth, statusBarHeight)]];
    statusBarImageView.frame = CGRectMake(0, -statusBarHeight, navigationBarWidth, statusBarHeight);
    [navigationBarImageView addSubview:statusBarImageView];

    return navigationBarImageView;
}

@end

#pragma mark - AGXNavigationControllerInternalDelegate

@implementation AGXNavigationControllerInternalDelegate {
    UIPanGestureRecognizer                  *_panGestureRecognizer;
    UIPercentDrivenInteractiveTransition    *_percentDrivenTransition;
    CGFloat                                  _lastPercentProgress;
    NSComparisonResult                       _panGestureDirection;
    AGXNavigationTransition                 *_navigationTransition;
}

- (AGX_INSTANCETYPE)init {
    if AGX_EXPECT_T(self = [super init]) {
        _panGestureRecognizer = [[UIPanGestureRecognizer alloc]
                                 initWithTarget:self action:@selector(agxPanGestureAction:)];
        _panGestureRecognizer.delegate = self;
        _panGestureRecognizer.agxTag = AGXNavigationControllerInternalPopGestureTag;
        _agxInteractivePopPercent = 0.5;
        _navigationTransition = [[AGXNavigationTransition alloc] init];
        _lastPercentProgress = 0;
        _panGestureDirection = NSOrderedSame;
    }
    return self;
}

- (void)dealloc {
    AGX_RELEASE(_panGestureRecognizer);
    AGX_RELEASE(_percentDrivenTransition);
    AGX_RELEASE(_navigationTransition);
    _delegate = nil;
    _navigationController = nil;
    AGX_SUPER_DEALLOC;
}

- (BOOL)respondsToSelector:(SEL)aSelector {
    return [super respondsToSelector:aSelector]
    || [self.delegate respondsToSelector:aSelector];
}

- (id)forwardingTargetForSelector:(SEL)aSelector {
    return self.delegate;
}

- (void)setAgxInteractivePopPercent:(CGFloat)agxInteractivePopPercent {
    _agxInteractivePopPercent = BETWEEN(agxInteractivePopPercent, 0.1, 0.9);
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

#pragma mark - UIScreenEdgePanGestureRecognizer action

- (void)agxPanGestureAction:(UIPanGestureRecognizer *)panGestureRecognizer {
    CGFloat progress = progressOfUIPanGesture
    ([panGestureRecognizer locationInView:UIApplication.sharedKeyWindow], _agxPopGestureEdges);

    if (panGestureRecognizer.state == UIGestureRecognizerStateBegan) {
        _percentDrivenTransition = [[UIPercentDrivenInteractiveTransition alloc] init];
        [_navigationController popViewControllerAnimated:YES];
    } else if (panGestureRecognizer.state == UIGestureRecognizerStateChanged) {
        [_percentDrivenTransition updateInteractiveTransition:progress];
        _panGestureDirection = progress > _lastPercentProgress ? NSOrderedAscending : progress < _lastPercentProgress;
        _lastPercentProgress = progress;
    } else if (panGestureRecognizer.state == UIGestureRecognizerStateEnded ||
               panGestureRecognizer.state == UIGestureRecognizerStateCancelled) {
        if (NSOrderedAscending == _panGestureDirection) {
            [_percentDrivenTransition finishInteractiveTransition];
        } else if (NSOrderedDescending == _panGestureDirection) {
            [_percentDrivenTransition cancelInteractiveTransition];
        } else if (progress > _agxInteractivePopPercent) {
            [_percentDrivenTransition finishInteractiveTransition];
        } else {
            [_percentDrivenTransition cancelInteractiveTransition];
        }
        _lastPercentProgress = 0;
        _panGestureDirection = NSOrderedSame;
        AGX_RELEASE(_percentDrivenTransition);
        _percentDrivenTransition = nil;
    }
}

AGX_STATIC CGFloat progressOfUIPanGesture(CGPoint locationInWindow, UIRectEdge edge) {
    CGSize windowSize = UIApplication.sharedKeyWindow.bounds.size;

    CGFloat progress;
    switch (edge) {
        case UIRectEdgeTop:     progress = cgfabs(locationInWindow.y) / windowSize.height; break;
        case UIRectEdgeBottom:  progress = (windowSize.height - cgfabs(locationInWindow.y)) / windowSize.height; break;
        case UIRectEdgeLeft:    progress = cgfabs(locationInWindow.x) / windowSize.width; break;
        case UIRectEdgeRight:   progress = (windowSize.width - cgfabs(locationInWindow.x)) / windowSize.width; break;
        default:                progress = 0;
    }
    return progress;
}

#pragma mark - UIGestureRecognizerDelegate

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
    return(gestureRecognizer == _panGestureRecognizer &&
           _navigationController.viewControllers.count > 1 &&
           !_navigationController.topViewController.disablePopGesture);
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return(otherGestureRecognizer.agxTag != AGXWebViewControllerGoBackGestureTag);
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    return([self gestureRecognizerShouldBegin:gestureRecognizer] &&
           progressOfUIPanGesture([touch locationInView:UIApplication.sharedKeyWindow], _agxPopGestureEdges) < 0.1);
}

#pragma mark - UINavigationControllerDelegate

- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated {
    if ([self.delegate respondsToSelector:@selector(navigationController:willShowViewController:animated:)]) {
        [self.delegate navigationController:navigationController willShowViewController:viewController animated:animated];
    }
    navigationController.interactivePopGestureRecognizer.enabled = NO;
    navigationController.interactivePopGestureRecognizer.delegate = self;
}

- (void)navigationController:(UINavigationController *)navigationController didShowViewController:(UIViewController *)viewController animated:(BOOL)animated {
    if ([self.delegate respondsToSelector:@selector(navigationController:didShowViewController:animated:)]) {
        [self.delegate navigationController:navigationController didShowViewController:viewController animated:animated];
    }
    if (viewController != navigationController.viewControllers.firstObject && !viewController.disablePopGesture) {
        if (![navigationController.view.gestureRecognizers containsObject:_panGestureRecognizer])
            [navigationController.view addGestureRecognizer:_panGestureRecognizer];
    } else if ([navigationController.view.gestureRecognizers containsObject:_panGestureRecognizer]) {
        [navigationController.view removeGestureRecognizer:_panGestureRecognizer];
    }
}

- (id<UIViewControllerInteractiveTransitioning>)navigationController:(UINavigationController *)navigationController interactionControllerForAnimationController:(id<UIViewControllerAnimatedTransitioning>)animationController {
    if ([self.delegate respondsToSelector:@selector(navigationController:interactionControllerForAnimationController:)]) {
        return [self.delegate navigationController:navigationController interactionControllerForAnimationController:animationController];
    }
    return _percentDrivenTransition;
}

- (id<UIViewControllerAnimatedTransitioning>)navigationController:(UINavigationController *)navigationController animationControllerForOperation:(UINavigationControllerOperation)operation fromViewController:(UIViewController *)fromVC toViewController:(UIViewController *)toVC {
    if ([self.delegate respondsToSelector:@selector(navigationController:animationControllerForOperation:fromViewController:toViewController:)]) {
        return [self.delegate navigationController:navigationController animationControllerForOperation:operation fromViewController:fromVC toViewController:toVC];
    }
    _navigationTransition.agxOperation = operation;
    _navigationTransition.navigationController = navigationController;
    return UINavigationControllerOperationNone == operation ? nil : _navigationTransition;
}

@end
