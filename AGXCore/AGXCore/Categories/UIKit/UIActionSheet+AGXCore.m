//
//  UIActionSheet+AGXCore.m
//  AGXCore
//
//  Created by Char Aznable on 16/3/23.
//  Copyright © 2016年 AI-CUC-EC. All rights reserved.
//

#import "UIActionSheet+AGXCore.h"
#import "AGXObjC.h"
#import "AGXArc.h"

@category_implementation(UIActionSheet, AGXCore)

+ (UIActionSheet *)actionSheetWithTitle:(NSString *)title delegate:(id<UIActionSheetDelegate>)delegate cancelButtonTitle:(NSString *)cancelButtonTitle destructiveButtonTitle:(NSString *)destructiveButtonTitle otherButtonTitles:(NSString *)otherButtonTitles, ... {
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:title delegate:delegate cancelButtonTitle:nil
                                               destructiveButtonTitle:nil otherButtonTitles:nil];
    if (destructiveButtonTitle) {
        [actionSheet addButtonWithTitle:destructiveButtonTitle];
        [actionSheet setDestructiveButtonIndex:[actionSheet numberOfButtons] - 1];
    }
    agx_va_start(otherButtonTitles);
    for (NSString *title = otherButtonTitles; title != nil; title = va_arg(_argvs_, NSString *)) {
        [actionSheet addButtonWithTitle:title];
    }
    agx_va_end;
    if (cancelButtonTitle) {
        [actionSheet addButtonWithTitle:cancelButtonTitle];
        [actionSheet setCancelButtonIndex:[actionSheet numberOfButtons] - 1];
    }
    return AGX_AUTORELEASE(actionSheet);
}

@end
