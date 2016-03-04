//
//  UIWindow+AGXWidget.m
//  AGXWidget
//
//  Created by Char Aznable on 16/2/29.
//  Copyright © 2016年 AI-CUC-EC. All rights reserved.
//

#import "UIWindow+AGXWidgetAnimation.h"
#import "UIView+AGXWidgetAnimation.h"
#import <AGXCore/AGXCore/AGXAdapt.h>
#import <AGXCore/AGXCore/AGXBundle.h>
#import <AGXCore/AGXCore/UIImage+AGXCore.h>
#import <AGXCore/AGXCore/UIImageView+AGXCore.h>

@category_implementation(UIWindow, AGXWidgetAnimation)

- (void)showSplashLaunchWithAnimation:(AGXAnimation)animation {
    NSString *launchImageName = [[AGXBundle appBundle] infoDictionary][@"UILaunchImageFile"];
    [self showSplashImage:[UIImage imageForCurrentDeviceNamed:launchImageName] withAnimation:animation];
}

- (void)showSplashImage:(UIImage *)splashImage withAnimation:(AGXAnimation)animation {
    if (AGX_EXPECT_F(!splashImage)) return;
    [self showSplashView:[UIImageView imageViewWithImage:splashImage] withAnimation:animation];
}

- (void)showSplashView:(UIView *)splashView withAnimation:(AGXAnimation)animation {
    [self addSubview:splashView];
    splashView.frame = CGRectMake(0, -statusBarFix, self.bounds.size.width,
                                  self.bounds.size.height + statusBarFix);
    [splashView agxAnimate:animation completion:^{ [splashView removeFromSuperview]; }];
}

@end
