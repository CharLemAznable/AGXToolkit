//
//  UIWindow+AGXWidget.h
//  AGXWidget
//
//  Created by Char Aznable on 16/2/29.
//  Copyright © 2016年 AI-CUC-EC. All rights reserved.
//

#ifndef AGXWidget_UIWindow_AGXWidgetAnimation_h
#define AGXWidget_UIWindow_AGXWidgetAnimation_h

#import <UIKit/UIKit.h>
#import <AGXCore/AGXCore/AGXCategory.h>
#import "AGXAnimationTypes.h"

@category_interface(UIWindow, AGXWidgetAnimation)
- (void)showSplashLaunchWithAnimation:(AGXAnimation)animation;
- (void)showSplashImage:(UIImage *)splashImage withAnimation:(AGXAnimation)animation;
- (void)showSplashView:(UIView *)splashView withAnimation:(AGXAnimation)animation;
@end

#endif /* AGXWidget_UIWindow_AGXWidgetAnimation_h */
