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
#define defTransition   transition:(AGXTransition)transition
#define defCallbacks    started:(AGXTransitionCallback)started finished:(AGXTransitionCallback)finished
#define defWithVC       withViewController:(UIViewController *)viewController
#define VCsType         NSArray AGX_GENERIC(AGX_KINDOF(UIViewController *)) *

typedef void (^AGXTransitionCallback)(UIViewController *fromViewController, UIViewController *toViewController);

@category_interface(UINavigationController, AGXWidget)
- (void)pushViewController:(UIViewController *)viewController defAnimated defCallbacks;
- (void)pushViewController:(UIViewController *)viewController defTransition;
- (void)pushViewController:(UIViewController *)viewController defTransition defCallbacks;

- (UIViewController *)popViewControllerAnimated:(BOOL)animated defCallbacks;
- (UIViewController *)popViewControllerTransition:(AGXTransition)transition;
- (UIViewController *)popViewControllerTransition:(AGXTransition)transition defCallbacks;

- (VCsType)popToViewController:(UIViewController *)viewController defAnimated defCallbacks;
- (VCsType)popToViewController:(UIViewController *)viewController defTransition;
- (VCsType)popToViewController:(UIViewController *)viewController defTransition defCallbacks;

- (VCsType)popToRootViewControllerAnimated:(BOOL)animated defCallbacks;
- (VCsType)popToRootViewControllerTransition:(AGXTransition)transition;
- (VCsType)popToRootViewControllerTransition:(AGXTransition)transition defCallbacks;

- (void)setViewControllers:(VCsType)viewControllers defAnimated defCallbacks;
- (void)setViewControllers:(VCsType)viewControllers defTransition;
- (void)setViewControllers:(VCsType)viewControllers defTransition defCallbacks;

- (UIViewController *)replaceWithViewController:(UIViewController *)viewController defAnimated;
- (UIViewController *)replaceWithViewController:(UIViewController *)viewController defAnimated defCallbacks;
- (UIViewController *)replaceWithViewController:(UIViewController *)viewController defTransition;
- (UIViewController *)replaceWithViewController:(UIViewController *)viewController defTransition defCallbacks;

- (VCsType)replaceToViewController:(UIViewController *)toViewController defWithVC defAnimated;
- (VCsType)replaceToViewController:(UIViewController *)toViewController defWithVC defAnimated defCallbacks;
- (VCsType)replaceToViewController:(UIViewController *)toViewController defWithVC defTransition;
- (VCsType)replaceToViewController:(UIViewController *)toViewController defWithVC defTransition defCallbacks;

- (VCsType)replaceToRootViewControllerWithViewController:(UIViewController *)viewController defAnimated;
- (VCsType)replaceToRootViewControllerWithViewController:(UIViewController *)viewController defAnimated defCallbacks;
- (VCsType)replaceToRootViewControllerWithViewController:(UIViewController *)viewController defTransition;
- (VCsType)replaceToRootViewControllerWithViewController:(UIViewController *)viewController defTransition defCallbacks;
@end

// proxy self.navigationController if exists
@category_interface(UIViewController, AGXWidgetUINavigationController)
- (void)pushViewController:(UIViewController *)viewController defAnimated;
- (void)pushViewController:(UIViewController *)viewController defAnimated defCallbacks;
- (void)pushViewController:(UIViewController *)viewController defTransition;
- (void)pushViewController:(UIViewController *)viewController defTransition defCallbacks;

- (UIViewController *)popViewControllerAnimated:(BOOL)animated;
- (UIViewController *)popViewControllerAnimated:(BOOL)animated defCallbacks;
- (UIViewController *)popViewControllerTransition:(AGXTransition)transition;
- (UIViewController *)popViewControllerTransition:(AGXTransition)transition defCallbacks;

- (VCsType)popToViewController:(UIViewController *)viewController defAnimated;
- (VCsType)popToViewController:(UIViewController *)viewController defAnimated defCallbacks;
- (VCsType)popToViewController:(UIViewController *)viewController defTransition;
- (VCsType)popToViewController:(UIViewController *)viewController defTransition defCallbacks;

- (VCsType)popToRootViewControllerAnimated:(BOOL)animated;
- (VCsType)popToRootViewControllerAnimated:(BOOL)animated defCallbacks;
- (VCsType)popToRootViewControllerTransition:(AGXTransition)transition;
- (VCsType)popToRootViewControllerTransition:(AGXTransition)transition defCallbacks;

- (void)setViewControllers:(VCsType)viewControllers defAnimated;
- (void)setViewControllers:(VCsType)viewControllers defAnimated defCallbacks;
- (void)setViewControllers:(VCsType)viewControllers defTransition;
- (void)setViewControllers:(VCsType)viewControllers defTransition defCallbacks;

- (UIViewController *)replaceWithViewController:(UIViewController *)viewController defAnimated;
- (UIViewController *)replaceWithViewController:(UIViewController *)viewController defAnimated defCallbacks;
- (UIViewController *)replaceWithViewController:(UIViewController *)viewController defTransition;
- (UIViewController *)replaceWithViewController:(UIViewController *)viewController defTransition defCallbacks;

- (VCsType)replaceToViewController:(UIViewController *)toViewController defWithVC defAnimated;
- (VCsType)replaceToViewController:(UIViewController *)toViewController defWithVC defAnimated defCallbacks;
- (VCsType)replaceToViewController:(UIViewController *)toViewController defWithVC defTransition;
- (VCsType)replaceToViewController:(UIViewController *)toViewController defWithVC defTransition defCallbacks;

- (VCsType)replaceToRootViewControllerWithViewController:(UIViewController *)viewController defAnimated;
- (VCsType)replaceToRootViewControllerWithViewController:(UIViewController *)viewController defAnimated defCallbacks;
- (VCsType)replaceToRootViewControllerWithViewController:(UIViewController *)viewController defTransition;
- (VCsType)replaceToRootViewControllerWithViewController:(UIViewController *)viewController defTransition defCallbacks;
@end

#undef VCsType
#undef defWithVC
#undef defCallbacks
#undef defTransition
#undef defAnimated

#endif /* AGXCore_UINavigationController_AGXWidget_h */
