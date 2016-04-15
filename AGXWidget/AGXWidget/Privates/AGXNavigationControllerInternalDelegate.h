//
//  AGXNavigationControllerInternalDelegate.h
//  AGXWidget
//
//  Created by Char Aznable on 16/4/15.
//  Copyright © 2016年 AI-CUC-EC. All rights reserved.
//

#ifndef AGXWidget_AGXNavigationControllerInternalDelegate_h
#define AGXWidget_AGXNavigationControllerInternalDelegate_h

#import <UIKit/UIKit.h>
#import <AGXCore/AGXCore/AGXArc.h>
#import "AGXAnimation.h"
#import "UINavigationController+AGXWidget.h"

@interface AGXNavigationControllerInternalDelegate : NSObject <UINavigationControllerDelegate>
@property (nonatomic, AGX_WEAK) id<UINavigationControllerDelegate>  delegate;

@property (nonatomic, assign)   AGXTransition                       agxTransition;
@property (nonatomic, copy)     AGXTransitionCallback               agxStartTransition;
@property (nonatomic, copy)     AGXTransitionCallback               agxFinishTransition;
@end

@interface AGXNavigationTransition : NSObject <UIViewControllerAnimatedTransitioning>
@end

#endif /* AGXWidget_AGXNavigationControllerInternalDelegate_h */
