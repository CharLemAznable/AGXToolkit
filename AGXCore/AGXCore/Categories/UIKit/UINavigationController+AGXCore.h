//
//  UINavigationController+AGXCore.h
//  AGXCore
//
//  Created by Char Aznable on 16/2/17.
//  Copyright © 2016年 AI-CUC-EC. All rights reserved.
//

#ifndef AGXCore_UINavigationController_AGXCore_h
#define AGXCore_UINavigationController_AGXCore_h

#import <UIKit/UIKit.h>
#import "AGXCategory.h"

typedef void (^AGXNavigationCallbackBlock)(UIViewController *viewController);

@category_interface(UINavigationController, AGXCore)
- (void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated
          initialWithBlock:(AGXNavigationCallbackBlock)initial
       completionWithBlock:(AGXNavigationCallbackBlock)completion;
- (UIViewController *)popViewControllerAnimated:(BOOL)animated
                               cleanupWithBlock:(AGXNavigationCallbackBlock)cleanup
                            completionWithBlock:(AGXNavigationCallbackBlock)completion;
@end

@category_interface(UIViewController, AGXCoreUINavigationController)
@property (nonatomic, readonly) UINavigationBar *navigationBar;
@property (nonatomic, getter=isNavigationBarHidden) BOOL navigationBarHidden;
- (void)setNavigationBarHidden:(BOOL)hidden animated:(BOOL)animated;

- (void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated;
- (UIViewController *)popViewControllerAnimated:(BOOL)animated;
- (NSArray AGX_GENERIC(AGX_KINDOF(UIViewController *)) *)popToViewController:(UIViewController *)viewController animated:(BOOL)animated;
- (NSArray AGX_GENERIC(AGX_KINDOF(UIViewController *)) *)popToRootViewControllerAnimated:(BOOL)animated;

- (void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated
          initialWithBlock:(AGXNavigationCallbackBlock)initial
       completionWithBlock:(AGXNavigationCallbackBlock)completion;
- (UIViewController *)popViewControllerAnimated:(BOOL)animated
                               cleanupWithBlock:(AGXNavigationCallbackBlock)cleanup
                            completionWithBlock:(AGXNavigationCallbackBlock)completion;

- (void)willNavigatePush:(BOOL)animated; // Called when NavigationController push. Default does nothing
- (void)didNavigatePush:(BOOL)animated; // Called when NavigationController push. Default does nothing
- (void)willNavigatePop:(BOOL)animated; // Called when NavigationController pop. Default does nothing
- (void)didNavigatePop:(BOOL)animated; // Called when NavigationController pop. Default does nothing
@end

#endif /* AGXCore_UINavigationController_AGXCore_h */
