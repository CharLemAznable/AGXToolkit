//
//  UIAlertView+AGXCore.m
//  AGXCore
//
//  Created by Char Aznable on 16/3/23.
//  Copyright © 2016年 AI-CUC-EC. All rights reserved.
//

#import "UIAlertView+AGXCore.h"
#import "AGXArc.h"

#if __IPHONE_OS_VERSION_MIN_REQUIRED < __IPHONE_9_0

@category_implementation(UIAlertView, AGXCore)

+ (AGX_INSTANCETYPE)alertViewWithTitle:(NSString *)title message:(NSString *)message delegate:(id)delegate cancelButtonTitle:(NSString *)cancelButtonTitle otherButtonTitles:(NSString *)otherButtonTitles, ... {
    UIAlertView *alertView = [[self alloc] initWithTitle:title message:message delegate:delegate
                                       cancelButtonTitle:nil otherButtonTitles:nil];
    if (cancelButtonTitle) {
        [alertView addButtonWithTitle:cancelButtonTitle];
        [alertView setCancelButtonIndex:[alertView numberOfButtons] - 1];
    }
    if (otherButtonTitles) {
        [alertView setValue:@([alertView numberOfButtons]) forKey:@"firstOtherButtonIndex"];
        NSArray *buttonTitles = agx_va_list(otherButtonTitles);
        [buttonTitles enumerateObjectsUsingBlock:
         ^(NSString *title, NSUInteger idx, BOOL *stop) {
             [alertView addButtonWithTitle:title]; }];
    }
    return AGX_AUTORELEASE(alertView);
}

@end

#endif // __IPHONE_OS_VERSION_MIN_REQUIRED < __IPHONE_9_0
