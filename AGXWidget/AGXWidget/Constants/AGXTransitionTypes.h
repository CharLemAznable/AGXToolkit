//
//  AGXTransitionTypes.h
//  AGXWidget
//
//  Created by Char Aznable on 16/4/8.
//  Copyright © 2016年 AI-CUC-EC. All rights reserved.
//

#ifndef AGXWidget_AGXTransitionTypes_h
#define AGXWidget_AGXTransitionTypes_h

#import <AGXCore/AGXCore/AGXObjC.h>

typedef NS_ENUM(NSUInteger, AGXTransitionType) {
    AGXTransitionFade,
    AGXTransitionPush,
    AGXTransitionMoveIn,
    AGXTransitionReveal,
    AGXTransitionCube,
    AGXTransitionOglFlip,
    AGXTransitionSuckEffect,
    AGXTransitionRippleEffect,
    AGXTransitionPageCurl,
    AGXTransitionPageUnCurl,
    AGXTransitionCameraIrisHollowOpen,
    AGXTransitionCameraIrisHollowClose,
};

typedef NS_ENUM(NSUInteger, AGXTransitionDirection) {
    AGXTransitionNone,
    AGXTransitionFromRight,
    AGXTransitionFromLeft,
    AGXTransitionFromTop,
    AGXTransitionFromBottom,
};

typedef struct AGXTransition {
    AGXTransitionType type;
    AGXTransitionDirection direction;
    NSTimeInterval duration;
} AGXTransition;

AGX_EXTERN AGXTransition AGXTransitionMake(AGXTransitionType type,
                                           AGXTransitionDirection direction,
                                           NSTimeInterval duration);
AGX_EXTERN AGXTransition AGXDefaultPushTransition;
AGX_EXTERN AGXTransition AGXDefaultPopTransition;

#endif /* AGXWidget_AGXTransitionTypes_h */
