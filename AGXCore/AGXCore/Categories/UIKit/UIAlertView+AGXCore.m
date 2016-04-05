//
//  UIAlertView+AGXCore.m
//  AGXCore
//
//  Created by Char Aznable on 16/3/23.
//  Copyright © 2016年 AI-CUC-EC. All rights reserved.
//

#import "UIAlertView+AGXCore.h"
#import "AGXObjC.h"
#import "AGXArc.h"

#if __IPHONE_OS_VERSION_MIN_REQUIRED < 80000

@category_implementation(UIAlertView, AGXCore)

+ (UIAlertView *)alertViewWithTitle:(NSString *)title message:(NSString *)message delegate:(id)delegate cancelButtonTitle:(NSString *)cancelButtonTitle otherButtonTitles:(NSString *)otherButtonTitles, ... {
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:title message:message delegate:delegate
                                              cancelButtonTitle:nil otherButtonTitles:nil];
    if (cancelButtonTitle) {
        [alertView addButtonWithTitle:cancelButtonTitle];
        [alertView setCancelButtonIndex:[alertView numberOfButtons] - 1];
    }
    if (otherButtonTitles) {
        [alertView setValue:@([alertView numberOfButtons]) forKey:@"firstOtherButtonIndex"];
        agx_va_start(otherButtonTitles);
        for (NSString *title = otherButtonTitles; title != nil; title = va_arg(_argvs_, NSString *)) {
            [alertView addButtonWithTitle:title];
        }
        agx_va_end;
    }
    return AGX_AUTORELEASE(alertView);
}

@end

#endif // __IPHONE_OS_VERSION_MIN_REQUIRED < 80000
