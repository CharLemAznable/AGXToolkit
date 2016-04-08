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

typedef void (^AGXTransitionCallback)(UIViewController *fromViewController, UIViewController *toViewController);

@category_interface(UINavigationController, AGXWidget)
// stack operation default transition (additional)
- (UIViewController *)replaceWithViewController:(UIViewController *)viewController animated:(BOOL)animated;
- (NSArray AGX_GENERIC(AGX_KINDOF(UIViewController *)) *)replaceToViewController:(UIViewController *)toViewController withViewController:(UIViewController *)viewController animated:(BOOL)animated;
- (NSArray AGX_GENERIC(AGX_KINDOF(UIViewController *)) *)replaceToRootViewControllerWithViewController:(UIViewController *)viewController animated:(BOOL)animated;

// stack operation custom transition
- (void)pushViewController:(UIViewController *)viewController transition:(AGXTransition)transition;
- (UIViewController *)popViewControllerTransition:(AGXTransition)transition;
- (NSArray AGX_GENERIC(AGX_KINDOF(UIViewController *)) *)popToViewController:(UIViewController *)viewController transition:(AGXTransition)transition;
- (NSArray AGX_GENERIC(AGX_KINDOF(UIViewController *)) *)popToRootViewControllerTransition:(AGXTransition)transition;
- (void)setViewControllers:(NSArray AGX_GENERIC(AGX_KINDOF(UIViewController *)) *)viewControllers transition:(AGXTransition)transition;
- (UIViewController *)replaceWithViewController:(UIViewController *)viewController transition:(AGXTransition)transition;
- (NSArray AGX_GENERIC(AGX_KINDOF(UIViewController *)) *)replaceToViewController:(UIViewController *)toViewController withViewController:(UIViewController *)viewController transition:(AGXTransition)transition;
- (NSArray AGX_GENERIC(AGX_KINDOF(UIViewController *)) *)replaceToRootViewControllerWithViewController:(UIViewController *)viewController transition:(AGXTransition)transition;

// stack operation default transition with blocks
- (void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated started:(AGXTransitionCallback)started finished:(AGXTransitionCallback)finished;
- (UIViewController *)popViewControllerAnimated:(BOOL)animated started:(AGXTransitionCallback)started finished:(AGXTransitionCallback)finished;
- (NSArray AGX_GENERIC(AGX_KINDOF(UIViewController *)) *)popToViewController:(UIViewController *)viewController animated:(BOOL)animated started:(AGXTransitionCallback)started finished:(AGXTransitionCallback)finished;
- (NSArray AGX_GENERIC(AGX_KINDOF(UIViewController *)) *)popToRootViewControllerAnimated:(BOOL)animated started:(AGXTransitionCallback)started finished:(AGXTransitionCallback)finished;
- (void)setViewControllers:(NSArray AGX_GENERIC(AGX_KINDOF(UIViewController *)) *)viewControllers animated:(BOOL)animated started:(AGXTransitionCallback)started finished:(AGXTransitionCallback)finished;
- (UIViewController *)replaceWithViewController:(UIViewController *)viewController animated:(BOOL)animated started:(AGXTransitionCallback)started finished:(AGXTransitionCallback)finished;
- (NSArray AGX_GENERIC(AGX_KINDOF(UIViewController *)) *)replaceToViewController:(UIViewController *)toViewController withViewController:(UIViewController *)viewController animated:(BOOL)animated started:(AGXTransitionCallback)started finished:(AGXTransitionCallback)finished;
- (NSArray AGX_GENERIC(AGX_KINDOF(UIViewController *)) *)replaceToRootViewControllerWithViewController:(UIViewController *)viewController animated:(BOOL)animated started:(AGXTransitionCallback)started finished:(AGXTransitionCallback)finished;

// stack operation custom transition with blocks
- (void)pushViewController:(UIViewController *)viewController transition:(AGXTransition)transition started:(AGXTransitionCallback)started finished:(AGXTransitionCallback)finished;
- (UIViewController *)popViewControllerTransition:(AGXTransition)transition started:(AGXTransitionCallback)started finished:(AGXTransitionCallback)finished;
- (NSArray AGX_GENERIC(AGX_KINDOF(UIViewController *)) *)popToViewController:(UIViewController *)viewController transition:(AGXTransition)transition started:(AGXTransitionCallback)started finished:(AGXTransitionCallback)finished;
- (NSArray AGX_GENERIC(AGX_KINDOF(UIViewController *)) *)popToRootViewControllerTransition:(AGXTransition)transition started:(AGXTransitionCallback)started finished:(AGXTransitionCallback)finished;
- (void)setViewControllers:(NSArray AGX_GENERIC(AGX_KINDOF(UIViewController *)) *)viewControllers transition:(AGXTransition)transition started:(AGXTransitionCallback)started finished:(AGXTransitionCallback)finished;
- (UIViewController *)replaceWithViewController:(UIViewController *)viewController transition:(AGXTransition)transition started:(AGXTransitionCallback)started finished:(AGXTransitionCallback)finished;
- (NSArray AGX_GENERIC(AGX_KINDOF(UIViewController *)) *)replaceToViewController:(UIViewController *)toViewController withViewController:(UIViewController *)viewController transition:(AGXTransition)transition started:(AGXTransitionCallback)started finished:(AGXTransitionCallback)finished;
- (NSArray AGX_GENERIC(AGX_KINDOF(UIViewController *)) *)replaceToRootViewControllerWithViewController:(UIViewController *)viewController transition:(AGXTransition)transition started:(AGXTransitionCallback)started finished:(AGXTransitionCallback)finished;
@end

// proxy self.navigationController if exists
@category_interface(UIViewController, AGXWidgetUINavigationController)
- (void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated;
- (UIViewController *)popViewControllerAnimated:(BOOL)animated;
- (NSArray AGX_GENERIC(AGX_KINDOF(UIViewController *)) *)popToViewController:(UIViewController *)viewController animated:(BOOL)animated;
- (NSArray AGX_GENERIC(AGX_KINDOF(UIViewController *)) *)popToRootViewControllerAnimated:(BOOL)animated;
- (void)setViewControllers:(NSArray AGX_GENERIC(AGX_KINDOF(UIViewController *)) *)viewControllers animated:(BOOL)animated;
- (UIViewController *)replaceWithViewController:(UIViewController *)viewController animated:(BOOL)animated;
- (NSArray AGX_GENERIC(AGX_KINDOF(UIViewController *)) *)replaceToViewController:(UIViewController *)toViewController withViewController:(UIViewController *)viewController animated:(BOOL)animated;
- (NSArray AGX_GENERIC(AGX_KINDOF(UIViewController *)) *)replaceToRootViewControllerWithViewController:(UIViewController *)viewController animated:(BOOL)animated;

- (void)pushViewController:(UIViewController *)viewController transition:(AGXTransition)transition;
- (UIViewController *)popViewControllerTransition:(AGXTransition)transition;
- (NSArray AGX_GENERIC(AGX_KINDOF(UIViewController *)) *)popToViewController:(UIViewController *)viewController transition:(AGXTransition)transition;
- (NSArray AGX_GENERIC(AGX_KINDOF(UIViewController *)) *)popToRootViewControllerTransition:(AGXTransition)transition;
- (void)setViewControllers:(NSArray AGX_GENERIC(AGX_KINDOF(UIViewController *)) *)viewControllers transition:(AGXTransition)transition;
- (UIViewController *)replaceWithViewController:(UIViewController *)viewController transition:(AGXTransition)transition;
- (NSArray AGX_GENERIC(AGX_KINDOF(UIViewController *)) *)replaceToViewController:(UIViewController *)toViewController withViewController:(UIViewController *)viewController transition:(AGXTransition)transition;
- (NSArray AGX_GENERIC(AGX_KINDOF(UIViewController *)) *)replaceToRootViewControllerWithViewController:(UIViewController *)viewController transition:(AGXTransition)transition;

- (void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated started:(AGXTransitionCallback)started finished:(AGXTransitionCallback)finished;
- (UIViewController *)popViewControllerAnimated:(BOOL)animated started:(AGXTransitionCallback)started finished:(AGXTransitionCallback)finished;
- (NSArray AGX_GENERIC(AGX_KINDOF(UIViewController *)) *)popToViewController:(UIViewController *)viewController animated:(BOOL)animated started:(AGXTransitionCallback)started finished:(AGXTransitionCallback)finished;
- (NSArray AGX_GENERIC(AGX_KINDOF(UIViewController *)) *)popToRootViewControllerAnimated:(BOOL)animated started:(AGXTransitionCallback)started finished:(AGXTransitionCallback)finished;
- (void)setViewControllers:(NSArray AGX_GENERIC(AGX_KINDOF(UIViewController *)) *)viewControllers animated:(BOOL)animated started:(AGXTransitionCallback)started finished:(AGXTransitionCallback)finished;
- (UIViewController *)replaceWithViewController:(UIViewController *)viewController animated:(BOOL)animated started:(AGXTransitionCallback)started finished:(AGXTransitionCallback)finished;
- (NSArray AGX_GENERIC(AGX_KINDOF(UIViewController *)) *)replaceToViewController:(UIViewController *)toViewController withViewController:(UIViewController *)viewController animated:(BOOL)animated started:(AGXTransitionCallback)started finished:(AGXTransitionCallback)finished;
- (NSArray AGX_GENERIC(AGX_KINDOF(UIViewController *)) *)replaceToRootViewControllerWithViewController:(UIViewController *)viewController animated:(BOOL)animated started:(AGXTransitionCallback)started finished:(AGXTransitionCallback)finished;

- (void)pushViewController:(UIViewController *)viewController transition:(AGXTransition)transition started:(AGXTransitionCallback)started finished:(AGXTransitionCallback)finished;
- (UIViewController *)popViewControllerTransition:(AGXTransition)transition started:(AGXTransitionCallback)started finished:(AGXTransitionCallback)finished;
- (NSArray AGX_GENERIC(AGX_KINDOF(UIViewController *)) *)popToViewController:(UIViewController *)viewController transition:(AGXTransition)transition started:(AGXTransitionCallback)started finished:(AGXTransitionCallback)finished;
- (NSArray AGX_GENERIC(AGX_KINDOF(UIViewController *)) *)popToRootViewControllerTransition:(AGXTransition)transition started:(AGXTransitionCallback)started finished:(AGXTransitionCallback)finished;
- (void)setViewControllers:(NSArray AGX_GENERIC(AGX_KINDOF(UIViewController *)) *)viewControllers transition:(AGXTransition)transition started:(AGXTransitionCallback)started finished:(AGXTransitionCallback)finished;
- (UIViewController *)replaceWithViewController:(UIViewController *)viewController transition:(AGXTransition)transition started:(AGXTransitionCallback)started finished:(AGXTransitionCallback)finished;
- (NSArray AGX_GENERIC(AGX_KINDOF(UIViewController *)) *)replaceToViewController:(UIViewController *)toViewController withViewController:(UIViewController *)viewController transition:(AGXTransition)transition started:(AGXTransitionCallback)started finished:(AGXTransitionCallback)finished;
- (NSArray AGX_GENERIC(AGX_KINDOF(UIViewController *)) *)replaceToRootViewControllerWithViewController:(UIViewController *)viewController transition:(AGXTransition)transition started:(AGXTransitionCallback)started finished:(AGXTransitionCallback)finished;
@end

#endif /* AGXCore_UINavigationController_AGXWidget_h */
