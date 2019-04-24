//
//  UIWindow+AGXWidget.m
//  AGXWidget
//
//  Created by Char Aznable on 2016/2/29.
//  Copyright © 2016 github.com/CharLemAznable. All rights reserved.
//

#import <AGXCore/AGXCore/AGXAppInfo.h>
#import <AGXCore/AGXCore/UIImageView+AGXCore.h>
#import "UIWindow+AGXWidgetAnimation.h"
#import "UIView+AGXWidgetAnimation.h"

@category_implementation(UIWindow, AGXWidgetAnimation)

- (void)showSplashLaunchWithAnimation:(AGXAnimation)animation {
    [self showSplashLaunchWithAnimation:animation processingHandler:NULL];
}

- (void)showSplashImage:(UIImage *)splashImage withAnimation:(AGXAnimation)animation {
    [self showSplashImage:splashImage withAnimation:animation processingHandler:NULL];
}

- (void)showSplashView:(UIView *)splashView withAnimation:(AGXAnimation)animation {
    [self showSplashView:splashView withAnimation:animation processingHandler:NULL];
}

- (void)showSplashLaunchWithAnimation:(AGXAnimation)animation processingHandler:(void (^)(void (^completionHandler)(void)))processingHandler {
    [self showSplashImage:AGXAppInfo.launchImage withAnimation:animation processingHandler:processingHandler];
}

- (void)showSplashImage:(UIImage *)splashImage withAnimation:(AGXAnimation)animation processingHandler:(void (^)(void (^completionHandler)(void)))processingHandler {
    if AGX_EXPECT_F(!splashImage) return;
    [self showSplashView:[UIImageView imageViewWithImage:splashImage] withAnimation:animation processingHandler:processingHandler];
}

- (void)showSplashView:(UIView *)splashView withAnimation:(AGXAnimation)animation processingHandler:(void (^)(void (^completionHandler)(void)))processingHandler {
    [self addSubview:splashView];
    splashView.frame = CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.height);
    void (^completionHandler)(void) = ^{
        [splashView agxAnimate:animation completion:^{ [splashView removeFromSuperview]; }];
    };
    agx_async_main(processingHandler?processingHandler(completionHandler):completionHandler(););
}

@end
