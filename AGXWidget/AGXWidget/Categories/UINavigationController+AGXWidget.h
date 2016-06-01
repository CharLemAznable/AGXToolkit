//
//  UINavigationController+AGXWidget.h
//  AGXWidget
//
//  Created by Char Aznable on 16/4/7.
//  Copyright © 2016年 AI-CUC-EC. All rights reserved.
//

#ifndef AGXWidget_UINavigationController_AGXWidget_h
#define AGXWidget_UINavigationController_AGXWidget_h

#import <UIKit/UIKit.h>
#import <AGXCore/AGXCore/AGXArc.h>
#import <AGXCore/AGXCore/AGXCategory.h>
#import "AGXAnimation.h"

typedef void (^AGXTransitionCallback)(UIViewController *fromViewController, UIViewController *toViewController);

@category_interface(UINavigationController, AGXWidget)
@property (nonatomic, assign) CGFloat gesturePopPercent; // [0.1, 0.9] default 0.5

- (void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated started:(AGXTransitionCallback)started finished:(AGXTransitionCallback)finished;
- (void)pushViewController:(UIViewController *)viewController transited:(AGXTransition)transition;
- (void)pushViewController:(UIViewController *)viewController transited:(AGXTransition)transition started:(AGXTransitionCallback)started finished:(AGXTransitionCallback)finished;

- (UIViewController *)popViewControllerAnimated:(BOOL)animated started:(AGXTransitionCallback)started finished:(AGXTransitionCallback)finished;
- (UIViewController *)popViewControllerTransited:(AGXTransition)transition;
- (UIViewController *)popViewControllerTransited:(AGXTransition)transition started:(AGXTransitionCallback)started finished:(AGXTransitionCallback)finished;

- (NSArray *)popToViewController:(UIViewController *)viewController animated:(BOOL)animated started:(AGXTransitionCallback)started finished:(AGXTransitionCallback)finished;
- (NSArray *)popToViewController:(UIViewController *)viewController transited:(AGXTransition)transition;
- (NSArray *)popToViewController:(UIViewController *)viewController transited:(AGXTransition)transition started:(AGXTransitionCallback)started finished:(AGXTransitionCallback)finished;

- (NSArray *)popToRootViewControllerAnimated:(BOOL)animated started:(AGXTransitionCallback)started finished:(AGXTransitionCallback)finished;
- (NSArray *)popToRootViewControllerTransited:(AGXTransition)transition;
- (NSArray *)popToRootViewControllerTransited:(AGXTransition)transition started:(AGXTransitionCallback)started finished:(AGXTransitionCallback)finished;

- (void)setViewControllers:(NSArray *)viewControllers animated:(BOOL)animated started:(AGXTransitionCallback)started finished:(AGXTransitionCallback)finished;
- (void)setViewControllers:(NSArray *)viewControllers transited:(AGXTransition)transition;
- (void)setViewControllers:(NSArray *)viewControllers transited:(AGXTransition)transition started:(AGXTransitionCallback)started finished:(AGXTransitionCallback)finished;

- (UIViewController *)replaceWithViewController:(UIViewController *)viewController animated:(BOOL)animated;
- (UIViewController *)replaceWithViewController:(UIViewController *)viewController animated:(BOOL)animated started:(AGXTransitionCallback)started finished:(AGXTransitionCallback)finished;
- (UIViewController *)replaceWithViewController:(UIViewController *)viewController transited:(AGXTransition)transition;
- (UIViewController *)replaceWithViewController:(UIViewController *)viewController transited:(AGXTransition)transition started:(AGXTransitionCallback)started finished:(AGXTransitionCallback)finished;

- (NSArray *)replaceToViewController:(UIViewController *)toViewController withViewController:(UIViewController *)viewController animated:(BOOL)animated;
- (NSArray *)replaceToViewController:(UIViewController *)toViewController withViewController:(UIViewController *)viewController animated:(BOOL)animated started:(AGXTransitionCallback)started finished:(AGXTransitionCallback)finished;
- (NSArray *)replaceToViewController:(UIViewController *)toViewController withViewController:(UIViewController *)viewController transited:(AGXTransition)transition;
- (NSArray *)replaceToViewController:(UIViewController *)toViewController withViewController:(UIViewController *)viewController transited:(AGXTransition)transition started:(AGXTransitionCallback)started finished:(AGXTransitionCallback)finished;

- (NSArray *)replaceToRootViewControllerWithViewController:(UIViewController *)viewController animated:(BOOL)animated;
- (NSArray *)replaceToRootViewControllerWithViewController:(UIViewController *)viewController animated:(BOOL)animated started:(AGXTransitionCallback)started finished:(AGXTransitionCallback)finished;
- (NSArray *)replaceToRootViewControllerWithViewController:(UIViewController *)viewController transited:(AGXTransition)transition;
- (NSArray *)replaceToRootViewControllerWithViewController:(UIViewController *)viewController transited:(AGXTransition)transition started:(AGXTransitionCallback)started finished:(AGXTransitionCallback)finished;
@end

// proxy self.navigationController if exists
@category_interface(UIViewController, AGXWidgetUINavigationController)
@property (nonatomic) BOOL disablePopGesture;
@property (nonatomic) BOOL hideNavigationBar;
@property (nonatomic, AGX_STRONG) NSString *backBarButtonTitle;
- (BOOL)navigationShouldPopOnBackBarButton; // default YES

- (void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated;
- (void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated started:(AGXTransitionCallback)started finished:(AGXTransitionCallback)finished;
- (void)pushViewController:(UIViewController *)viewController transited:(AGXTransition)transition;
- (void)pushViewController:(UIViewController *)viewController transited:(AGXTransition)transition started:(AGXTransitionCallback)started finished:(AGXTransitionCallback)finished;

- (UIViewController *)popViewControllerAnimated:(BOOL)animated;
- (UIViewController *)popViewControllerAnimated:(BOOL)animated started:(AGXTransitionCallback)started finished:(AGXTransitionCallback)finished;
- (UIViewController *)popViewControllerTransited:(AGXTransition)transition;
- (UIViewController *)popViewControllerTransited:(AGXTransition)transition started:(AGXTransitionCallback)started finished:(AGXTransitionCallback)finished;

- (NSArray *)popToViewController:(UIViewController *)viewController animated:(BOOL)animated;
- (NSArray *)popToViewController:(UIViewController *)viewController animated:(BOOL)animated started:(AGXTransitionCallback)started finished:(AGXTransitionCallback)finished;
- (NSArray *)popToViewController:(UIViewController *)viewController transited:(AGXTransition)transition;
- (NSArray *)popToViewController:(UIViewController *)viewController transited:(AGXTransition)transition started:(AGXTransitionCallback)started finished:(AGXTransitionCallback)finished;

- (NSArray *)popToRootViewControllerAnimated:(BOOL)animated;
- (NSArray *)popToRootViewControllerAnimated:(BOOL)animated started:(AGXTransitionCallback)started finished:(AGXTransitionCallback)finished;
- (NSArray *)popToRootViewControllerTransited:(AGXTransition)transition;
- (NSArray *)popToRootViewControllerTransited:(AGXTransition)transition started:(AGXTransitionCallback)started finished:(AGXTransitionCallback)finished;

- (void)setViewControllers:(NSArray *)viewControllers animated:(BOOL)animated;
- (void)setViewControllers:(NSArray *)viewControllers animated:(BOOL)animated started:(AGXTransitionCallback)started finished:(AGXTransitionCallback)finished;
- (void)setViewControllers:(NSArray *)viewControllers transited:(AGXTransition)transition;
- (void)setViewControllers:(NSArray *)viewControllers transited:(AGXTransition)transition started:(AGXTransitionCallback)started finished:(AGXTransitionCallback)finished;

- (UIViewController *)replaceWithViewController:(UIViewController *)viewController animated:(BOOL)animated;
- (UIViewController *)replaceWithViewController:(UIViewController *)viewController animated:(BOOL)animated started:(AGXTransitionCallback)started finished:(AGXTransitionCallback)finished;
- (UIViewController *)replaceWithViewController:(UIViewController *)viewController transited:(AGXTransition)transition;
- (UIViewController *)replaceWithViewController:(UIViewController *)viewController transited:(AGXTransition)transition started:(AGXTransitionCallback)started finished:(AGXTransitionCallback)finished;

- (NSArray *)replaceToViewController:(UIViewController *)toViewController withViewController:(UIViewController *)viewController animated:(BOOL)animated;
- (NSArray *)replaceToViewController:(UIViewController *)toViewController withViewController:(UIViewController *)viewController animated:(BOOL)animated started:(AGXTransitionCallback)started finished:(AGXTransitionCallback)finished;
- (NSArray *)replaceToViewController:(UIViewController *)toViewController withViewController:(UIViewController *)viewController transited:(AGXTransition)transition;
- (NSArray *)replaceToViewController:(UIViewController *)toViewController withViewController:(UIViewController *)viewController transited:(AGXTransition)transition started:(AGXTransitionCallback)started finished:(AGXTransitionCallback)finished;

- (NSArray *)replaceToRootViewControllerWithViewController:(UIViewController *)viewController animated:(BOOL)animated;
- (NSArray *)replaceToRootViewControllerWithViewController:(UIViewController *)viewController animated:(BOOL)animated started:(AGXTransitionCallback)started finished:(AGXTransitionCallback)finished;
- (NSArray *)replaceToRootViewControllerWithViewController:(UIViewController *)viewController transited:(AGXTransition)transition;
- (NSArray *)replaceToRootViewControllerWithViewController:(UIViewController *)viewController transited:(AGXTransition)transition started:(AGXTransitionCallback)started finished:(AGXTransitionCallback)finished;
@end

#endif /* AGXWidget_UINavigationController_AGXWidget_h */
