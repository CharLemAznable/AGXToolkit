//
//  UINavigationController+AGXWidget.h
//  AGXWidget
//
//  Created by Char Aznable on 16/4/7.
//  Copyright © 2016年 AI-CUC-EC. All rights reserved.
//

#ifndef AGXCore_UINavigationController_AGXWidget_h
#define AGXCore_UINavigationController_AGXWidget_h

#import <UIKit/UIKit.h>
#import <AGXCore/AGXCore/AGXCategory.h>
#import "AGXTransitionTypes.h"

#define defAnimated     animated:(BOOL)animated
#define defTransited    transited:(AGXTransition)transition
#define defCallbacks    started:(AGXTransitionCallback)started finished:(AGXTransitionCallback)finished
#define defWithVC       withViewController:(UIViewController *)viewController
#define VCsType         NSArray AGX_GENERIC(AGX_KINDOF(UIViewController *)) *

typedef void (^AGXTransitionCallback)(UIViewController *fromViewController, UIViewController *toViewController);

@category_interface(UINavigationController, AGXWidget)
- (void)pushViewController:(UIViewController *)viewController defAnimated defCallbacks;
- (void)pushViewController:(UIViewController *)viewController defTransited;
- (void)pushViewController:(UIViewController *)viewController defTransited defCallbacks;

- (UIViewController *)popViewControllerAnimated:(BOOL)animated defCallbacks;
- (UIViewController *)popViewControllerTransited:(AGXTransition)transition;
- (UIViewController *)popViewControllerTransited:(AGXTransition)transition defCallbacks;

- (VCsType)popToViewController:(UIViewController *)viewController defAnimated defCallbacks;
- (VCsType)popToViewController:(UIViewController *)viewController defTransited;
- (VCsType)popToViewController:(UIViewController *)viewController defTransited defCallbacks;

- (VCsType)popToRootViewControllerAnimated:(BOOL)animated defCallbacks;
- (VCsType)popToRootViewControllerTransited:(AGXTransition)transition;
- (VCsType)popToRootViewControllerTransited:(AGXTransition)transition defCallbacks;

- (void)setViewControllers:(VCsType)viewControllers defAnimated defCallbacks;
- (void)setViewControllers:(VCsType)viewControllers defTransited;
- (void)setViewControllers:(VCsType)viewControllers defTransited defCallbacks;

- (UIViewController *)replaceWithViewController:(UIViewController *)viewController defAnimated;
- (UIViewController *)replaceWithViewController:(UIViewController *)viewController defAnimated defCallbacks;
- (UIViewController *)replaceWithViewController:(UIViewController *)viewController defTransited;
- (UIViewController *)replaceWithViewController:(UIViewController *)viewController defTransited defCallbacks;

- (VCsType)replaceToViewController:(UIViewController *)toViewController defWithVC defAnimated;
- (VCsType)replaceToViewController:(UIViewController *)toViewController defWithVC defAnimated defCallbacks;
- (VCsType)replaceToViewController:(UIViewController *)toViewController defWithVC defTransited;
- (VCsType)replaceToViewController:(UIViewController *)toViewController defWithVC defTransited defCallbacks;

- (VCsType)replaceToRootViewControllerWithViewController:(UIViewController *)viewController defAnimated;
- (VCsType)replaceToRootViewControllerWithViewController:(UIViewController *)viewController defAnimated defCallbacks;
- (VCsType)replaceToRootViewControllerWithViewController:(UIViewController *)viewController defTransited;
- (VCsType)replaceToRootViewControllerWithViewController:(UIViewController *)viewController defTransited defCallbacks;
@end

// proxy self.navigationController if exists
@category_interface(UIViewController, AGXWidgetUINavigationController)
@property (nonatomic) BOOL disablePopGesture;

- (void)pushViewController:(UIViewController *)viewController defAnimated;
- (void)pushViewController:(UIViewController *)viewController defAnimated defCallbacks;
- (void)pushViewController:(UIViewController *)viewController defTransited;
- (void)pushViewController:(UIViewController *)viewController defTransited defCallbacks;

- (UIViewController *)popViewControllerAnimated:(BOOL)animated;
- (UIViewController *)popViewControllerAnimated:(BOOL)animated defCallbacks;
- (UIViewController *)popViewControllerTransited:(AGXTransition)transition;
- (UIViewController *)popViewControllerTransited:(AGXTransition)transition defCallbacks;

- (VCsType)popToViewController:(UIViewController *)viewController defAnimated;
- (VCsType)popToViewController:(UIViewController *)viewController defAnimated defCallbacks;
- (VCsType)popToViewController:(UIViewController *)viewController defTransited;
- (VCsType)popToViewController:(UIViewController *)viewController defTransited defCallbacks;

- (VCsType)popToRootViewControllerAnimated:(BOOL)animated;
- (VCsType)popToRootViewControllerAnimated:(BOOL)animated defCallbacks;
- (VCsType)popToRootViewControllerTransited:(AGXTransition)transition;
- (VCsType)popToRootViewControllerTransited:(AGXTransition)transition defCallbacks;

- (void)setViewControllers:(VCsType)viewControllers defAnimated;
- (void)setViewControllers:(VCsType)viewControllers defAnimated defCallbacks;
- (void)setViewControllers:(VCsType)viewControllers defTransited;
- (void)setViewControllers:(VCsType)viewControllers defTransited defCallbacks;

- (UIViewController *)replaceWithViewController:(UIViewController *)viewController defAnimated;
- (UIViewController *)replaceWithViewController:(UIViewController *)viewController defAnimated defCallbacks;
- (UIViewController *)replaceWithViewController:(UIViewController *)viewController defTransited;
- (UIViewController *)replaceWithViewController:(UIViewController *)viewController defTransited defCallbacks;

- (VCsType)replaceToViewController:(UIViewController *)toViewController defWithVC defAnimated;
- (VCsType)replaceToViewController:(UIViewController *)toViewController defWithVC defAnimated defCallbacks;
- (VCsType)replaceToViewController:(UIViewController *)toViewController defWithVC defTransited;
- (VCsType)replaceToViewController:(UIViewController *)toViewController defWithVC defTransited defCallbacks;

- (VCsType)replaceToRootViewControllerWithViewController:(UIViewController *)viewController defAnimated;
- (VCsType)replaceToRootViewControllerWithViewController:(UIViewController *)viewController defAnimated defCallbacks;
- (VCsType)replaceToRootViewControllerWithViewController:(UIViewController *)viewController defTransited;
- (VCsType)replaceToRootViewControllerWithViewController:(UIViewController *)viewController defTransited defCallbacks;
@end

#undef VCsType
#undef defWithVC
#undef defCallbacks
#undef defTransited
#undef defAnimated

#endif /* AGXCore_UINavigationController_AGXWidget_h */
