//
//  AGXAnimationInternal.m
//  AGXWidget
//
//  Created by Char Aznable on 16/4/15.
//  Copyright © 2016年 AI-CUC-EC. All rights reserved.
//

#import "AGXAnimationInternal.h"

#define hasAGXAnimateType(exp, flag)        (exp & flag)
#define hasAGXAnimateDirection(exp, flag)   (exp & flag)
#define between(exp, min, max)              MAX(min, MIN(max, (exp)))

AGX_STATIC_INLINE void AGXCGAffineTransformTranslate(CGAffineTransform *t, CGVector vector)
{ *t = CGAffineTransformTranslate(*t, vector.dx, vector.dy); }

AGX_STATIC_INLINE void AGXCGAffineTransformScale(CGAffineTransform *t, CGFloat scale)
{ *t = CGAffineTransformScale(*t, scale, scale); }

AGX_STATIC CGVector AGXAnimateTranslateVector
(UIView *view, AGXAnimateType type, AGXAnimateDirection direction, CGFloat progress) {
    CGSize relativeSize = view.frame.size;
    if (hasAGXAnimateType(type, AGXAnimateByWindow))
        relativeSize = [UIScreen mainScreen].bounds.size;

    CGFloat proportion = between(progress, 0.0, 1.0);
    if (hasAGXAnimateType(type, AGXAnimateOut)) proportion *= -1;

    CGVector vector = CGVectorMake(0, 0);
    if (hasAGXAnimateDirection(direction, AGXAnimateUp)) vector.dy += proportion * relativeSize.height;
    if (hasAGXAnimateDirection(direction, AGXAnimateLeft)) vector.dx += proportion * relativeSize.width;
    if (hasAGXAnimateDirection(direction, AGXAnimateDown)) vector.dy -= proportion * relativeSize.height;
    if (hasAGXAnimateDirection(direction, AGXAnimateRight)) vector.dx -= proportion * relativeSize.width;

    return vector;
}

AGX_STATIC CGFloat AGXAnimateScale(AGXAnimateType type, CGFloat progress) {
    CGFloat scale = 1;
    CGFloat proportion = between(progress, 0.0, 1.0);
    if (hasAGXAnimateType(type, AGXAnimateExpand)) { scale /= MAX(AGXAnimateZoomRatio, 1) * proportion; }
    if (hasAGXAnimateType(type, AGXAnimateShrink)) { scale *= MAX(AGXAnimateZoomRatio, 1) * proportion; }
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

    CGVector vector = AGXAnimateTranslateVector(view, animation.type, animation.direction, 1.0);
    if (hasAGXAnimateType(animation.type, AGXAnimateMove)) {
        AGXCGAffineTransformTranslate(transform, vector);
    }

    if (hasAGXAnimateType(animation.type, AGXAnimateFade)) { *alpha = 0; }

    if (hasAGXAnimateType(animation.type, AGXAnimateSlide)) {
        hasMask = YES;
        AGXCGAffineTransformTranslate(maskTrans, vector);
    }

    CGFloat scale = AGXAnimateScale(animation.type, 1.0);
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
    BOOL hasFromMask = NO;
    AGXAnimationAffineTransform fromMaskTransform = AGXAnimationAffineTransformIdentity();
    BOOL hasToMask = NO;
    AGXAnimationAffineTransform toMaskTransform = AGXAnimationAffineTransformIdentity();

    CGAffineTransform *fromTransform = &fromViewTransform.to;
    CGAffineTransform *toTransform = &toViewTransform.from;
    CGFloat *fromAlpha = &fromViewAlpha.to;
    CGFloat *toAlpha = &toViewAlpha.from;
    CGAffineTransform *fromMaskTrans = &fromMaskTransform.to;
    CGAffineTransform *toMaskTrans = &toMaskTransform.from;

    AGXAnimateType fromType = transition.typeExit|AGXAnimateOut;
    AGXAnimateType toType = transition.typeEntry&(~AGXAnimateOut);
    CGFloat fromProgress = between(transition.progressExit, 0.0, 1.0);
    CGFloat toProgress = between(transition.progressEntry, 0.0, 1.0);

    CGVector fromVector = AGXAnimateTranslateVector(from, fromType, transition.directionExit, fromProgress);
    if (hasAGXAnimateType(fromType, AGXAnimateMove)) AGXCGAffineTransformTranslate(fromTransform, fromVector);

    CGVector toVector = AGXAnimateTranslateVector(to, toType, transition.directionEntry, toProgress);
    if (hasAGXAnimateType(toType, AGXAnimateMove)) AGXCGAffineTransformTranslate(toTransform, toVector);

    if (hasAGXAnimateType(fromType, AGXAnimateFade)) { *fromAlpha = fromProgress; }
    if (hasAGXAnimateType(toType, AGXAnimateFade)) { *toAlpha = toProgress; }

    if (hasAGXAnimateType(fromType, AGXAnimateSlide)) {
        hasFromMask = YES;
        AGXCGAffineTransformTranslate(fromMaskTrans, fromVector);
    }
    if (hasAGXAnimateType(toType, AGXAnimateSlide)) {
        hasToMask = YES;
        AGXCGAffineTransformTranslate(toMaskTrans, toVector);
    }

    CGFloat fromScale = AGXAnimateScale(fromType, fromProgress);
    AGXCGAffineTransformScale(fromTransform, fromScale);
    AGXCGAffineTransformScale(fromMaskTrans, fromScale);

    CGFloat toScale = AGXAnimateScale(toType, toProgress);
    AGXCGAffineTransformScale(toTransform, toScale);
    AGXCGAffineTransformScale(toMaskTrans, toScale);

    return (AGXTransitionInternal) {
        .fromViewTransform = fromViewTransform,
        .toViewTransform = toViewTransform,
        .fromViewAlpha = fromViewAlpha,
        .toViewAlpha = toViewAlpha,
        .hasFromMask = hasFromMask,
        .fromMaskTransform = fromMaskTransform,
        .hasToMask = hasToMask,
        .toMaskTransform = toMaskTransform,
        .duration = transition.duration
    };
}

AGXTransition AGXNavigationNoneTransition =
{ .typeEntry = AGXAnimateNone, .directionEntry = AGXAnimateStay, .progressEntry = 1.0,
    .typeExit = AGXAnimateNone, .directionExit = AGXAnimateStay, .progressExit = 1.0, .duration = 0 };

#undef between
#undef hasAGXAnimateDirection
#undef hasAGXAnimateType
