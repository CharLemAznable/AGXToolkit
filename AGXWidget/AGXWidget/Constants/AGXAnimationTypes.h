//
//  AGXAnimationTypes.h
//  AGXWidget
//
//  Created by Char Aznable on 16/2/29.
//  Copyright © 2016年 AI-CUC-EC. All rights reserved.
//

#ifndef AGXWidget_AGXAnimationTypes_h
#define AGXWidget_AGXAnimationTypes_h

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
    AGXAnimateNotReset  = 1 << 12, // default start with initial value, if reset then start from current value
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

AGX_EXTERN AGXAnimation AGXAnimationMake(AGXAnimateType type,
                                         AGXAnimateDirection direction,
                                         NSTimeInterval duration,
                                         NSTimeInterval delay);
AGX_EXTERN AGXAnimation AGXImmediateAnimationMake(AGXAnimateType type,
                                                  AGXAnimateDirection direction,
                                                  NSTimeInterval duration);

#endif /* AGXWidget_AGXAnimationTypes_h */
