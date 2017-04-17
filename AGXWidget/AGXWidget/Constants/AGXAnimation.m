//
//  AGXAnimation.m
//  AGXWidget
//
//  Created by Char Aznable on 16/4/15.
//  Copyright © 2016年 AI-CUC-EC. All rights reserved.
//

#import "AGXAnimation.h"

CGFloat AGXAnimateZoomRatio = 2;

AGX_INLINE AGX_OVERLOAD AGXAnimation AGXAnimationMake
(AGXAnimateType t, AGXAnimateDirection d, NSTimeInterval r, NSTimeInterval l)
{ return (AGXAnimation) { .type = t, .direction = d, .duration = r, .delay = l }; }

AGX_INLINE AGX_OVERLOAD AGXAnimation AGXAnimationMake
(AGXAnimateType t, AGXAnimateDirection d, NSTimeInterval r)
{ return AGXAnimationMake(t, d, r, 0); }

AGX_INLINE AGX_OVERLOAD AGXTransition AGXTransitionMake
(AGXAnimateType tn, AGXAnimateDirection dn, CGFloat pn,
 AGXAnimateType tx, AGXAnimateDirection dx, CGFloat px, NSTimeInterval r)
{ return (AGXTransition){ .typeEntry = tn, .directionEntry = dn, .progressEntry = pn,
    .typeExit = tx, .directionExit = dx, .progressExit = px, .duration = r }; }

AGX_INLINE AGX_OVERLOAD AGXTransition AGXTransitionMake
(AGXAnimateType t, AGXAnimateDirection d, CGFloat p, NSTimeInterval r)
{ return (AGXTransition){ .typeEntry = t, .directionEntry = d, .progressEntry = p,
    .typeExit = t, .directionExit = d, .progressExit = p, .duration = r }; }

AGXTransition AGXNavigationDefaultPushTransition =
{ .typeEntry = AGXAnimateMove, .directionEntry = AGXAnimateLeft, .progressEntry = 1.0,
    .typeExit = AGXAnimateMove|AGXAnimateFade, .directionExit = AGXAnimateLeft, .progressExit = 0.3, .duration = 0.3 };

AGXTransition AGXNavigationDefaultPopTransition =
{ .typeEntry = AGXAnimateMove|AGXAnimateFade, .directionEntry = AGXAnimateRight, .progressEntry = 0.3,
    .typeExit = AGXAnimateMove, .directionExit = AGXAnimateRight, .progressExit = 1.0, .duration = 0.3 };
