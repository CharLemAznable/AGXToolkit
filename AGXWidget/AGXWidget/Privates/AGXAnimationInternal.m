//
//  AGXAnimationInternal.m
//  AGXWidget
//
//  Created by Char Aznable on 16/4/15.
//  Copyright © 2016年 AI-CUC-EC. All rights reserved.
//

#import "AGXAnimationInternal.h"

#define hasAGXAnimateType(exp, flag)                (exp & flag)
#define hasAGXAnimateDirection(exp, flag)           (exp & flag)

AGX_STATIC_INLINE void AGXCGAffineTransformTranslate(CGAffineTransform *t, CGVector vector)
{ *t = CGAffineTransformTranslate(*t, vector.dx, vector.dy); }

AGX_STATIC_INLINE void AGXCGAffineTransformScale(CGAffineTransform *t, CGFloat scale)
{ *t = CGAffineTransformScale(*t, scale, scale); }

AGX_STATIC CGVector AGXAnimateTranslateVector(UIView *view, AGXAnimateType type, AGXAnimateDirection direction) {
    CGSize relativeSize = view.frame.size;
    if (hasAGXAnimateType(type, AGXAnimateByWindow))
        relativeSize = [UIScreen mainScreen].bounds.size;
    
    int direct = 1;
    if (hasAGXAnimateType(type, AGXAnimateOut)) direct = -1;
    
    CGVector vector = CGVectorMake(0, 0);
    if (hasAGXAnimateDirection(direction, AGXAnimateUp)) vector.dy += direct * relativeSize.height;
    if (hasAGXAnimateDirection(direction, AGXAnimateLeft)) vector.dx += direct * relativeSize.width;
    if (hasAGXAnimateDirection(direction, AGXAnimateDown)) vector.dy -= direct * relativeSize.height;
    if (hasAGXAnimateDirection(direction, AGXAnimateRight)) vector.dx -= direct * relativeSize.width;
    
    return vector;
}

AGX_STATIC CGFloat AGXAnimateScale(AGXAnimateType type) {
    CGFloat scale = 1;
    if (hasAGXAnimateType(type, AGXAnimateExpand)) { scale /= MAX(AGXAnimateZoomRatio, 1); }
    if (hasAGXAnimateType(type, AGXAnimateShrink)) { scale *= MAX(AGXAnimateZoomRatio, 1); }
    if (hasAGXAnimateType(type, AGXAnimateOut)) { scale = 1 / scale; }
    return scale;
}

AGX_STATIC UIViewAnimationOptions AGXAnimateOptions(AGXAnimateType type) {
    UIViewAnimationOptions options = 0;
    if (hasAGXAnimateType(type, AGXAnimateRepeat)) {
        options |= UIViewAnimationOptionRepeat;
        if (hasAGXAnimateType(type, AGXAnimateReverse))
            options |= UIViewAnimationOptionAutoreverse;
    }
    if (hasAGXAnimateType(type, AGXAnimateNotReset)) {
        options |= UIViewAnimationOptionBeginFromCurrentState;
    }
    return options;
}

AGX_INLINE AGXAnimationAffineTransform AGXAnimationAffineTransformMake(UIView *view) {
    return (AGXAnimationAffineTransform) { .from = view.transform, .to = view.transform, .final = view.transform };
}

AGX_INLINE AGXAnimationAffineTransform AGXAnimationAffineTransformIdentity() {
    return (AGXAnimationAffineTransform) { .from = CGAffineTransformIdentity, .to = CGAffineTransformIdentity, .final = CGAffineTransformIdentity};
}

AGX_INLINE AGXAnimationAlpha AGXAnimationAlphaMake(UIView *view) {
    return (AGXAnimationAlpha) { .from = view.alpha, .to = view.alpha, .final = view.alpha };
}

AGXAnimationInternal buildInternalAnimation(UIView *view, AGXAnimation animation) {
    AGXAnimationAffineTransform viewTransform = AGXAnimationAffineTransformMake(view);
    AGXAnimationAlpha viewAlpha = AGXAnimationAlphaMake(view);
    BOOL hasMask = NO;
    AGXAnimationAffineTransform maskTransform = AGXAnimationAffineTransformIdentity();
    
    CGAffineTransform *transform = &viewTransform.from;
    CGFloat *alpha = &viewAlpha.from;
    CGAffineTransform *maskTrans = &maskTransform.from;
    
    if (hasAGXAnimateType(animation.type, AGXAnimateOut)) {
        transform = &viewTransform.to;
        alpha = &viewAlpha.to;
        maskTrans = &maskTransform.to;
    }
    
    CGVector vector = AGXAnimateTranslateVector(view, animation.type, animation.direction);
    if (hasAGXAnimateType(animation.type, AGXAnimateMove)) {
        AGXCGAffineTransformTranslate(transform, vector);
    }
    
    if (hasAGXAnimateType(animation.type, AGXAnimateFade)) { *alpha = 0; }
    
    if (hasAGXAnimateType(animation.type, AGXAnimateSlide)) {
        hasMask = YES;
        AGXCGAffineTransformTranslate(maskTrans, vector);
    }
    
    CGFloat scale = AGXAnimateScale(animation.type);
    AGXCGAffineTransformScale(transform, scale);
    AGXCGAffineTransformScale(maskTrans, scale);
    
    UIViewAnimationOptions options = AGXAnimateOptions(animation.type);
    
    if (hasAGXAnimateType(animation.type, AGXAnimateOut) &&
        hasAGXAnimateType(animation.type, AGXAnimateKeepOnCompletion)) {
        viewTransform.final = viewTransform.to;
        viewAlpha.final = viewAlpha.to;
        maskTransform.final = maskTransform.to;
    }
    
    return (AGXAnimationInternal) {
        .viewTransform = viewTransform,
        .viewAlpha = viewAlpha,
        .hasMask = hasMask,
        .maskTransform = maskTransform,
        .duration = animation.duration,
        .delay = animation.delay,
        .options = options
    };
}

AGXTransitionInternal buildInternalTransition(UIView *from, UIView *to, AGXTransition transition) {
    AGXAnimationAffineTransform fromViewTransform = AGXAnimationAffineTransformMake(from);
    AGXAnimationAffineTransform toViewTransform = AGXAnimationAffineTransformMake(to);
    AGXAnimationAlpha fromViewAlpha = AGXAnimationAlphaMake(from);
    AGXAnimationAlpha toViewAlpha = AGXAnimationAlphaMake(to);
    BOOL hasMask = NO;
    AGXAnimationAffineTransform fromMaskTransform = AGXAnimationAffineTransformIdentity();
    AGXAnimationAffineTransform toMaskTransform = AGXAnimationAffineTransformIdentity();
    
    CGAffineTransform *fromTransform = &fromViewTransform.to;
    CGAffineTransform *toTransform = &toViewTransform.from;
    CGFloat *fromAlpha = &fromViewAlpha.to;
    CGFloat *toAlpha = &toViewAlpha.from;
    CGAffineTransform *fromMaskTrans = &fromMaskTransform.to;
    CGAffineTransform *toMaskTrans = &toMaskTransform.from;
    
    AGXAnimateType fromType = transition.type|AGXAnimateOut;
    AGXAnimateType toType = transition.type&(~AGXAnimateOut);
    
    CGVector fromVector = AGXAnimateTranslateVector(from, fromType, transition.direction);
    CGVector toVector = AGXAnimateTranslateVector(to, toType, transition.direction);
    if (hasAGXAnimateType(transition.type, AGXAnimateMove)) {
        AGXCGAffineTransformTranslate(fromTransform, fromVector);
        AGXCGAffineTransformTranslate(toTransform, toVector);
    }
    
    if (hasAGXAnimateType(transition.type, AGXAnimateFade)) { *fromAlpha = 0; *toAlpha = 0; }
    
    if (hasAGXAnimateType(transition.type, AGXAnimateSlide)) {
        hasMask = YES;
        AGXCGAffineTransformTranslate(fromMaskTrans, fromVector);
        AGXCGAffineTransformTranslate(toMaskTrans, toVector);
    }
    
    CGFloat fromScale = AGXAnimateScale(fromType);
    AGXCGAffineTransformScale(fromTransform, fromScale);
    AGXCGAffineTransformScale(fromMaskTrans, fromScale);
    
    CGFloat toScale = AGXAnimateScale(toType);
    AGXCGAffineTransformScale(toTransform, toScale);
    AGXCGAffineTransformScale(toMaskTrans, toScale);
    
    return (AGXTransitionInternal) {
        .fromViewTransform = fromViewTransform,
        .toViewTransform = toViewTransform,
        .fromViewAlpha = fromViewAlpha,
        .toViewAlpha = toViewAlpha,
        .hasMask = hasMask,
        .fromMaskTransform = fromMaskTransform,
        .toMaskTransform = toMaskTransform,
        .duration = transition.duration
    };
}

AGXTransition AGXNavigationNoneTransition =
{ .type = AGXAnimateNone, .direction = AGXAnimateStay, .duration = 0 };
