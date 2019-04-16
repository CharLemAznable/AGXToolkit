//
//  UIWindow+AGXWidget.h
//  AGXWidget
//
//  Created by Char Aznable on 2016/2/29.
//  Copyright © 2016 github.com/CharLemAznable. All rights reserved.
//

#ifndef AGXWidget_UIWindow_AGXWidgetAnimation_h
#define AGXWidget_UIWindow_AGXWidgetAnimation_h

#import <UIKit/UIKit.h>
#import <AGXCore/AGXCore/AGXCategory.h>
#import "AGXAnimation.h"

@category_interface(UIWindow, AGXWidgetAnimation)
- (void)showSplashLaunchWithAnimation:(AGXAnimation)animation;
- (void)showSplashImage:(UIImage *)splashImage withAnimation:(AGXAnimation)animation;
- (void)showSplashView:(UIView *)splashView withAnimation:(AGXAnimation)animation;

- (void)showSplashLaunchWithAnimation:(AGXAnimation)animation processingHandler:(void (^)(void (^completionHandler)(void)))processingHandler;
- (void)showSplashImage:(UIImage *)splashImage withAnimation:(AGXAnimation)animation processingHandler:(void (^)(void (^completionHandler)(void)))processingHandler;
- (void)showSplashView:(UIView *)splashView withAnimation:(AGXAnimation)animation processingHandler:(void (^)(void (^completionHandler)(void)))processingHandler;
@end

#endif /* AGXWidget_UIWindow_AGXWidgetAnimation_h */
