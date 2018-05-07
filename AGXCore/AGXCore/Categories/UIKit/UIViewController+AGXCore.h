//
//  UIViewController+AGXCore.h
//  AGXCore
//
//  Created by Char Aznable on 2016/2/17.
//  Copyright © 2016年 AI-CUC-EC. All rights reserved.
//

#ifndef AGXCore_UIViewController_AGXCore_h
#define AGXCore_UIViewController_AGXCore_h

#import <UIKit/UIKit.h>
#import "AGXCategory.h"

AGX_EXTERN NSTimeInterval AGXStatusBarStyleSettingDuration; // effect when UIViewControllerBasedStatusBarAppearance

@category_interface(UIViewController, AGXCore)
@property (nonatomic, readonly, getter=isViewVisible) BOOL viewVisible;
@property (nonatomic) BOOL automaticallyAdjustsStatusBarStyle; // Defaults to YES

@property (nonatomic) UIStatusBarStyle statusBarStyle;
- (void)setStatusBarStyle:(UIStatusBarStyle)statusBarStyle animated:(BOOL)animated;

@property (nonatomic, getter=isStatusBarHidden) BOOL statusBarHidden;
- (void)setStatusBarHidden:(BOOL)statusBarHidden animated:(BOOL)animated;

@property (nonatomic, readonly) UINavigationBar *navigationBar;
@property (nonatomic, getter=isNavigationBarHidden) BOOL navigationBarHidden;
- (void)setNavigationBarHidden:(BOOL)hidden animated:(BOOL)animated;

@property (nonatomic, readonly) UIToolbar *toolbar;
@property (nonatomic, getter=isToolbarHidden) BOOL toolbarHidden;
- (void)setToolbarHidden:(BOOL)hidden animated:(BOOL)animated;

@property (nonatomic, readwrite, assign) BOOL hidesBarsOnSwipe;
@property (nonatomic, readwrite, assign) BOOL hidesBarsOnTap;

@property (nonatomic, readonly) UITabBar *tabBar;

- (void)presentStackViewController:(UIViewController *)viewController animated:(BOOL)animated completion:(void (^)(void))completion;
- (void)dismissStackViewControllerAnimated:(BOOL)animated completion:(void (^)(void))completion;
@end

#endif /* AGXCore_UIViewController_AGXCore_h */
