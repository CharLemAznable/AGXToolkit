//
//  AGXAnimationInternal.h
//  AGXWidget
//
//  Created by Char Aznable on 16/4/15.
//  Copyright © 2016年 AI-CUC-EC. All rights reserved.
//

#ifndef AGXWidget_AGXAnimationInternal_h
#define AGXWidget_AGXAnimationInternal_h

#import <UIKit/UIKit.h>
#import "AGXAnimation.h"

typedef struct AGXAnimationAffineTransform {
    CGAffineTransform from, to, final;
} AGXAnimationAffineTransform;
AGX_EXTERN AGXAnimationAffineTransform AGXAnimationAffineTransformMake(UIView *view);
AGX_EXTERN AGXAnimationAffineTransform AGXAnimationAffineTransformIdentity();

typedef struct AGXAnimationAlpha {
    CGFloat from, to, final;
} AGXAnimationAlpha;
AGX_EXTERN AGXAnimationAlpha AGXAnimationAlphaMake(UIView *view);

typedef struct AGXAnimationInternal {
    AGXAnimationAffineTransform viewTransform;
    AGXAnimationAlpha viewAlpha;
    BOOL hasMask;
    AGXAnimationAffineTransform maskTransform;
    NSTimeInterval duration, delay;
    UIViewAnimationOptions options;
} AGXAnimationInternal;
AGX_EXTERN AGXAnimationInternal buildInternalAnimation(UIView *view, AGXAnimation animation);

typedef struct AGXTransitionInternal {
    AGXAnimationAffineTransform fromViewTransform;
    AGXAnimationAffineTransform toViewTransform;
    AGXAnimationAlpha fromViewAlpha;
    AGXAnimationAlpha toViewAlpha;
    BOOL hasFromMask;
    AGXAnimationAffineTransform fromMaskTransform;
    BOOL hasToMask;
    AGXAnimationAffineTransform toMaskTransform;
    NSTimeInterval duration;
} AGXTransitionInternal;
AGX_EXTERN AGXTransitionInternal buildInternalTransition(UIView *from, UIView *to, AGXTransition transition);
AGX_EXTERN AGXTransition AGXNavigationNoneTransition;

#endif /* AGXWidget_AGXAnimationInternal_h */
