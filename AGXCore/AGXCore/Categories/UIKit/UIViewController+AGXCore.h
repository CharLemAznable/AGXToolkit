//
//  UIViewController+AGXCore.h
//  AGXCore
//
//  Created by Char Aznable on 16/2/17.
//  Copyright © 2016年 AI-CUC-EC. All rights reserved.
//

#ifndef AGXCore_UIViewController_AGXCore_h
#define AGXCore_UIViewController_AGXCore_h

#import <UIKit/UIKit.h>
#import "AGXCategory.h"

AGX_EXTERN NSTimeInterval AGXStatusBarStyleSettingDuration; // effect when UIViewControllerBasedStatusBarAppearance

@category_interface(UIViewController, AGXCore)
@property (nonatomic) UIStatusBarStyle statusBarStyle;
- (void)setStatusBarStyle:(UIStatusBarStyle)statusBarStyle animated:(BOOL)animated;

@property (nonatomic, readonly) UINavigationBar *navigationBar;
@property (nonatomic, getter=isNavigationBarHidden) BOOL navigationBarHidden;
- (void)setNavigationBarHidden:(BOOL)hidden animated:(BOOL)animated;
@end

#endif /* AGXCore_UIViewController_AGXCore_h */
