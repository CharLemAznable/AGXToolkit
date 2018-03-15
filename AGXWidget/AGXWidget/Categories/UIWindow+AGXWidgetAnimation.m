//
//  UIWindow+AGXWidget.m
//  AGXWidget
//
//  Created by Char Aznable on 2016/2/29.
//  Copyright © 2016年 AI-CUC-EC. All rights reserved.
//

#import <AGXCore/AGXCore/AGXBundle.h>
#import <AGXCore/AGXCore/UIImage+AGXCore.h>
#import <AGXCore/AGXCore/UIImageView+AGXCore.h>
#import "UIWindow+AGXWidgetAnimation.h"
#import "UIView+AGXWidgetAnimation.h"

@category_implementation(UIWindow, AGXWidgetAnimation)

- (void)showSplashLaunchWithAnimation:(AGXAnimation)animation {
    NSString *launchImageName = AGXBundle.appInfoDictionary[@"UILaunchImageFile"];
    [self showSplashImage:[UIImage imageForCurrentDeviceNamed:launchImageName] withAnimation:animation];
}

- (void)showSplashImage:(UIImage *)splashImage withAnimation:(AGXAnimation)animation {
    if AGX_EXPECT_F(!splashImage) return;
    [self showSplashView:[UIImageView imageViewWithImage:splashImage] withAnimation:animation];
}

- (void)showSplashView:(UIView *)splashView withAnimation:(AGXAnimation)animation {
    [self addSubview:splashView];
    splashView.frame = CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.height);
    [splashView agxAnimate:animation completion:^{ [splashView removeFromSuperview]; }];
}

- (void)showSplashLaunchWithAnimation:(AGXAnimation)animation processingHandler:(void (^)(void (^completionHandler)(void)))processingHandler {
    NSString *launchImageName = AGXBundle.appInfoDictionary[@"UILaunchImageFile"];
    [self showSplashImage:[UIImage imageForCurrentDeviceNamed:launchImageName] withAnimation:animation processingHandler:processingHandler];
}

- (void)showSplashImage:(UIImage *)splashImage withAnimation:(AGXAnimation)animation processingHandler:(void (^)(void (^completionHandler)(void)))processingHandler {
    if AGX_EXPECT_F(!splashImage) return;
    [self showSplashView:[UIImageView imageViewWithImage:splashImage] withAnimation:animation processingHandler:processingHandler];
}

- (void)showSplashView:(UIView *)splashView withAnimation:(AGXAnimation)animation processingHandler:(void (^)(void (^completionHandler)(void)))processingHandler {
    [self addSubview:splashView];
    splashView.frame = CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.height);
    void (^completionHandler)(void) = ^{
        agx_async_main([splashView agxAnimate:animation completion:^{ [splashView removeFromSuperview]; }];)
    };
    processingHandler?processingHandler(completionHandler):completionHandler();
}

@end
