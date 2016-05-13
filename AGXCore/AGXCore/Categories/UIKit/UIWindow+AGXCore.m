//
//  UIWindow+AGXCore.m
//  AGXCore
//
//  Created by Char Aznable on 16/5/10.
//  Copyright © 2016年 AI-CUC-EC. All rights reserved.
//

#import "UIWindow+AGXCore.h"

@category_implementation(UIWindow, AGXCore)

+ (UIWindow *)sharedKeyWindow {
    return [UIApplication sharedApplication].keyWindow;
}

@end
