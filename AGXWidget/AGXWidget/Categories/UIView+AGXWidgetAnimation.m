//
//  UIView+AGXWidgetAnimation.m
//  AGXWidget
//
//  Created by Char Aznable on 16/2/29.
//  Copyright © 2016年 AI-CUC-EC. All rights reserved.
//

#import "UIView+AGXWidgetAnimation.h"
#import <AGXCore/AGXCore/AGXArc.h>

CGFloat AGXAnimateZoomRatio = 2;

@category_implementation(UIView, AGXWidgetAnimation)

- (void)agxAnimate:(AGXAnimation)animation {
    [self agxAnimate:animation completion:^{}];
}

- (void)agxAnimate:(AGXAnimation)animation completion:(void (^)())completion {
    if (!hasAGXAnimateType(animation, AGXAnimateMove|AGXAnimateFade|
                           AGXAnimateSlide|AGXAnimateExpand|AGXAnimateShrink)) {
        if (!hasAGXAnimateType(animation, AGXAnimateRepeat)) completion();
        return;
    } // none animation specify, return directly; if repeat, no completion.
    
    CGAffineTransform selfStartTrans = self.transform;
    CGAffineTransform selfFinalTrans = self.transform;
    CGAffineTransform *selfTrans = &selfStartTrans;
    
    CGFloat selfStartAlpha = self.alpha;
    CGFloat selfFinalAlpha = self.alpha;
    CGFloat *selfAlpha = &selfStartAlpha;
    
    UIView *maskView = nil;
    CGAffineTransform maskStartTrans = CGAffineTransformIdentity;
    CGAffineTransform maskFinalTrans = CGAffineTransformIdentity;
    CGAffineTransform *maskTrans = &maskStartTrans;
    
    if (hasAGXAnimateType(animation, AGXAnimateOut)) {
        selfTrans = &selfFinalTrans;
        selfAlpha = &selfFinalAlpha;
        maskTrans = &maskFinalTrans;
    }
    
    if (hasAGXAnimateType(animation, AGXAnimateMove)) {
        AGXCGAffineTransformTranslate(selfTrans, AGXAnimateTranslateVector(self, animation));
    }
    
    if (hasAGXAnimateType(animation, AGXAnimateFade)) { *selfAlpha = 0; }
    
    if (hasAGXAnimateType(animation, AGXAnimateSlide)) {
        maskView = AGX_AUTORELEASE([[UIView alloc] initWithFrame:self.bounds]);
        maskView.layer.backgroundColor = [UIColor whiteColor].CGColor;
        self.layer.mask = maskView.layer;
        AGXCGAffineTransformTranslate(maskTrans, AGXAnimateTranslateVector(self, animation));
    }
    
    CGFloat scale = 1;
    if (hasAGXAnimateType(animation, AGXAnimateExpand)) { scale /= MAX(AGXAnimateZoomRatio, 1); }
    if (hasAGXAnimateType(animation, AGXAnimateShrink)) { scale *= MAX(AGXAnimateZoomRatio, 1); }
    if (hasAGXAnimateType(animation, AGXAnimateOut)) { scale = 1 / scale; }
    AGXCGAffineTransformScale(selfTrans, scale);
    AGXCGAffineTransformScale(maskTrans, scale);
    
    UIViewAnimationOptions options = 0;
    if (hasAGXAnimateType(animation, AGXAnimateRepeat)) {
        options |= UIViewAnimationOptionRepeat;
        if (hasAGXAnimateType(animation, AGXAnimateReverse))
            options |= UIViewAnimationOptionAutoreverse;
    }
    if (hasAGXAnimateType(animation, AGXAnimateNotReset)) {
        options |= UIViewAnimationOptionBeginFromCurrentState;
    }
    
    self.transform = selfStartTrans;
    self.alpha = selfStartAlpha;
    maskView.transform = maskStartTrans;
    [UIView animateWithDuration:animation.duration delay:animation.delay options:options
                     animations:^{
                         self.transform = selfFinalTrans;
                         self.alpha = selfFinalAlpha;
                         maskView.transform = maskFinalTrans;
                     } completion:^(BOOL finished) {
                         if (hasAGXAnimateType(animation, AGXAnimateOut)) {
                             self.transform = selfStartTrans;
                             self.alpha = selfStartAlpha;
                             maskView.transform = maskStartTrans;
                         }
                         completion();
                     }];
}

#pragma mark - AGXAnimate Implement Methods

AGX_STATIC_INLINE bool hasAGXAnimateType(AGXAnimation animation, AGXAnimateType type)
{ return animation.type & type; }

AGX_STATIC_INLINE bool hasAGXAnimateDirection(AGXAnimation animation, AGXAnimateDirection type)
{ return animation.direction & type; }

AGX_STATIC_INLINE void AGXCGAffineTransformTranslate(CGAffineTransform *t, CGVector vector)
{ *t = CGAffineTransformTranslate(*t, vector.dx, vector.dy); }

AGX_STATIC_INLINE void AGXCGAffineTransformScale(CGAffineTransform *t, CGFloat scale)
{ *t = CGAffineTransformScale(*t, scale, scale); }

AGX_STATIC CGVector AGXAnimateTranslateVector(UIView *view, AGXAnimation animation) {
    CGSize relativeSize = view.frame.size;
    if (hasAGXAnimateType(animation, AGXAnimateByWindow))
        relativeSize = [UIScreen mainScreen].bounds.size;
    
    int direction = 1;
    if (hasAGXAnimateType(animation, AGXAnimateOut)) direction = -1;
    
    CGVector vector = CGVectorMake(0, 0);
    if (hasAGXAnimateDirection(animation, AGXAnimateUp)) vector.dy += direction * relativeSize.height;
    if (hasAGXAnimateDirection(animation, AGXAnimateLeft)) vector.dx += direction * relativeSize.width;
    if (hasAGXAnimateDirection(animation, AGXAnimateDown)) vector.dy -= direction * relativeSize.height;
    if (hasAGXAnimateDirection(animation, AGXAnimateRight)) vector.dx -= direction * relativeSize.width;
    
    return vector;
}

@end

AGX_INLINE AGXAnimation AGXAnimationMake(AGXAnimateType t, AGXAnimateDirection d, NSTimeInterval r, NSTimeInterval l)
{ return (AGXAnimation) { .type = t, .direction = d, .duration = r, .delay = l }; }

AGX_INLINE AGXAnimation AGXImmediateAnimationMake(AGXAnimateType t, AGXAnimateDirection d, NSTimeInterval r)
{ return AGXAnimationMake(t, d, r, 0); }
