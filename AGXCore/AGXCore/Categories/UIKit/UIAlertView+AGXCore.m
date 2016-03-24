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

@category_implementation(UIAlertView, AGXCore)

+ (UIAlertView *)alertViewWithTitle:(NSString *)title message:(NSString *)message delegate:(id)delegate cancelButtonTitle:(NSString *)cancelButtonTitle otherButtonTitles:(NSString *)otherButtonTitles, ... {
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:title message:message delegate:delegate
                                              cancelButtonTitle:nil otherButtonTitles:nil];
    if (cancelButtonTitle) {
        [alertView addButtonWithTitle:cancelButtonTitle];
        [alertView setCancelButtonIndex:[alertView numberOfButtons] - 1];
    }
    agx_va_start(otherButtonTitles);
    for (NSString *title = otherButtonTitles; title != nil; title = va_arg(_argvs_, NSString *)) {
        [alertView addButtonWithTitle:title];
    }
    agx_va_end;
    return AGX_AUTORELEASE(alertView);
}

@end
