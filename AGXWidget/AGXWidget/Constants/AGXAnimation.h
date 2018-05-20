//
//  AGXAnimation.h
//  AGXWidget
//
//  Created by Char Aznable on 2016/4/15.
//  Copyright © 2016年 AI-CUC-EC. All rights reserved.
//

#ifndef AGXWidget_AGXAnimation_h
#define AGXWidget_AGXAnimation_h

#import <CoreGraphics/CoreGraphics.h>
#import <AGXCore/AGXCore/AGXObjC.h>

typedef NS_OPTIONS(NSUInteger, AGXAnimateType) {
    AGXAnimateNone      =       0, // none animate
    AGXAnimateMove      = 1 <<  0, // animate by adjust self translate-transform
    AGXAnimateFade      = 1 <<  1, // animate by adjust self alpha
    AGXAnimateSlide     = 1 <<  2, // animate by adjust layer mask frame
    AGXAnimateExpand    = 1 <<  3, // animate by adjust self scale-transform
    AGXAnimateShrink    = 1 <<  4, // animate by adjust self scale-transform, expand and shrink at same time effect nothing

    AGXAnimateIn        = 0 <<  8, // animate to current state, default
    AGXAnimateOut       = 1 <<  8, // animate from current state

    // relative setting effective only when AGXAnimateMove.
    AGXAnimateBySelf    = 0 <<  9, // animate relative by self, default
    AGXAnimateByWindow  = 1 <<  9, // animate relative by current window

    AGXAnimateOnce      = 0 << 10, // default
    AGXAnimateRepeat    = 1 << 10, // repeat animation indefinitely

    // if AGXAnimateRepeat
    AGXAnimateForward   = 0 << 11, // default
    AGXAnimateReverse   = 1 << 11, // repeat animation back and forth

    // BeginFromCurrentState
    AGXAnimateNotReset  = 1 << 12, // default start with initial value, if not reset then start from current value

    // Revert On Completion
    AGXAnimateKeepOnCompletion  = 1 << 13, // keep view state on animate completion, effect when AGXAnimateOut
};

// AGXAnimateExpand/AGXAnimateShrink parameter, at least 1
AGX_EXTERN CGFloat AGXAnimateZoomRatio;

// relative setting effective only when AGXAnimateMove/AGXAnimateSlide.
typedef NS_OPTIONS(NSUInteger, AGXAnimateDirection) {
    AGXAnimateStay      =       0, // default
    AGXAnimateUp        = 1 <<  0,
    AGXAnimateLeft      = 1 <<  1,
    AGXAnimateDown      = 1 <<  2,
    AGXAnimateRight     = 1 <<  3,
};

typedef struct AGXAnimation {
    AGXAnimateType type;
    AGXAnimateDirection direction;
    NSTimeInterval duration, delay;
} AGXAnimation;
AGX_EXTERN AGX_OVERLOAD AGXAnimation AGXAnimationMake
(AGXAnimateType type, AGXAnimateDirection direction, NSTimeInterval duration, NSTimeInterval delay);
AGX_EXTERN AGX_OVERLOAD AGXAnimation AGXAnimationMake
(AGXAnimateType type, AGXAnimateDirection direction, NSTimeInterval duration);

typedef struct AGXTransition {
    AGXAnimateType typeEntry;
    AGXAnimateDirection directionEntry;
    CGFloat progressEntry;
    AGXAnimateType typeExit;
    AGXAnimateDirection directionExit;
    CGFloat progressExit;
    NSTimeInterval duration;
} AGXTransition;
AGX_EXTERN AGX_OVERLOAD AGXTransition AGXTransitionMake
(AGXAnimateType typeEntry, AGXAnimateDirection directionEntry, CGFloat progressEntry,
 AGXAnimateType typeExit, AGXAnimateDirection directionExit, CGFloat progressExit, NSTimeInterval duration);
AGX_EXTERN AGX_OVERLOAD AGXTransition AGXTransitionMake
(AGXAnimateType type, AGXAnimateDirection direction, CGFloat progress, NSTimeInterval duration);
AGX_EXTERN AGXTransition AGXNavigationDefaultPushTransition;
AGX_EXTERN AGXTransition AGXNavigationDefaultPopTransition;

#endif /* AGXWidget_AGXAnimation_h */
