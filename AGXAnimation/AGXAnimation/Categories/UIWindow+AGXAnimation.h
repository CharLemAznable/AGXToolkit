//
//  UIWindow+AGXAnimation.h
//  AGXAnimation
//
//  Created by Char Aznable on 16/2/23.
//  Copyright © 2016年 AI-CUC-EC. All rights reserved.
//

#ifndef AGXAnimation_UIWindow_AGXAnimation_h
#define AGXAnimation_UIWindow_AGXAnimation_h

#import <UIKit/UIKit.h>
#import <AGXCore/AGXCore/AGXCategory.h>
#import "AGXAnimationTypes.h"

@category_interface(UIWindow, AGXAnimation)
- (void)showSplashLaunchWithAnimation:(AGXAnimation)animation;
- (void)showSplashImage:(UIImage *)splashImage withAnimation:(AGXAnimation)animation;
- (void)showSplashView:(UIView *)splashView withAnimation:(AGXAnimation)animation;
@end

#endif /* AGXAnimation_UIWindow_AGXAnimation_h */
