//
//  UIView+AGXHUD.m
//  AGXHUD
//
//  Created by Char Aznable on 16/2/20.
//  Copyright © 2016年 AI-CUC-EC. All rights reserved.
//

#import "UIView+AGXHUD.h"
#import <AGXCore/AGXCore/AGXArc.h>

@category_implementation(UIView, AGXHUD)

- (AGXProgressHUD *)agxProgressHUD {
    AGXProgressHUD *hud = [AGXProgressHUD HUDForView:self];
    if (!hud) {
        hud = AGX_AUTORELEASE([[AGXProgressHUD alloc] initWithView:self]);
        hud.square = YES;
        hud.animationType = AGXProgressHUDAnimationFade;
        hud.removeFromSuperViewOnHide = YES;
        [self addSubview:hud];
    }
    return hud;
}

- (void)showIndeterminateHUDWithText:(NSString *)text {
    AGXProgressHUD *hud = [self agxProgressHUD];
    hud.mode = AGXProgressHUDModeIndeterminate;
    hud.labelText = text;
    hud.detailsLabelText = nil;
    [hud show:YES];
}

- (void)showTextHUDWithText:(NSString *)text hideAfterDelay:(NSTimeInterval)delay {
    [self showTextHUDWithText:text detailText:nil hideAfterDelay:delay];
}

- (void)showTextHUDWithText:(NSString *)text detailText:(NSString *)detailText hideAfterDelay:(NSTimeInterval)delay {
    AGXProgressHUD *hud = [self agxProgressHUD];
    hud.mode = AGXProgressHUDModeText;
    hud.labelText = text;
    hud.detailsLabelText = detailText;
    [hud show:YES];
    [hud hide:YES afterDelay:delay];
}

- (void)hideHUD:(BOOL)animated {
    [[self agxProgressHUD] hide:animated];
}

- (UIFont *)hudLabelFont {
    return [self agxProgressHUD].labelFont;
}

- (void)setHudLabelFont:(UIFont *)hudLabelFont {
    [self agxProgressHUD].labelFont = hudLabelFont;
}

- (UIFont *)hudDetailsLabelFont {
    return [self agxProgressHUD].detailsLabelFont;
}

- (void)setHudDetailsLabelFont:(UIFont *)hudDetailsLabelFont {
    [self agxProgressHUD].detailsLabelFont = hudDetailsLabelFont;
}

@end
