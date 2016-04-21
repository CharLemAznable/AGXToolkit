//
//  AGXAnimation.m
//  AGXWidget
//
//  Created by Char Aznable on 16/4/15.
//  Copyright © 2016年 AI-CUC-EC. All rights reserved.
//

#import "AGXAnimation.h"

CGFloat AGXAnimateZoomRatio = 2;

AGX_INLINE AGXAnimation AGXAnimationMake(AGXAnimateType t, AGXAnimateDirection d, NSTimeInterval r, NSTimeInterval l)
{ return (AGXAnimation) { .type = t, .direction = d, .duration = r, .delay = l }; }

AGX_INLINE AGXAnimation AGXImmediateAnimationMake(AGXAnimateType t, AGXAnimateDirection d, NSTimeInterval r)
{ return AGXAnimationMake(t, d, r, 0); }

AGX_INLINE AGXTransition AGXTransitionMake(AGXAnimateType t, AGXAnimateDirection d, NSTimeInterval r)
{ return (AGXTransition){ .type = t, .direction = d, .duration = r }; }

AGXTransition AGXNavigationDefaultPushTransition =
{ .type = AGXAnimateMove|AGXAnimateFade, .direction = AGXAnimateLeft, .duration = 0.3 };

AGXTransition AGXNavigationDefaultPopTransition =
{ .type = AGXAnimateMove|AGXAnimateFade, .direction = AGXAnimateRight, .duration = 0.3 };
