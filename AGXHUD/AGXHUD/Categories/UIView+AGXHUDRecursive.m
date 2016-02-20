//
//  UIView+AGXHUDRecursive.m
//  AGXHUD
//
//  Created by Char Aznable on 16/2/20.
//  Copyright © 2016年 AI-CUC-EC. All rights reserved.
//

#import "UIView+AGXHUDRecursive.h"
#import "UIView+AGXHUD.h"

@category_implementation(UIView, AGXHUDRecursive)

- (AGXProgressHUD *)recursiveAGXProgressHUD {
    NSEnumerator *subviewsEnum = [self.subviews reverseObjectEnumerator];
    for (UIView *subview in subviewsEnum) {
        if ([subview isKindOfClass:[AGXProgressHUD class]]) {
            return (AGXProgressHUD *)subview;
        } else {
            AGXProgressHUD *hud = [subview recursiveAGXProgressHUD];
            if (hud) return hud;
        }
    }
    return nil;
}

#define SELF_AGXProgressHUD ([self recursiveAGXProgressHUD] ?: [self agxProgressHUD])

- (void)showIndeterminateRecursiveHUDWithText:(NSString *)text {
    AGXProgressHUD *hud = SELF_AGXProgressHUD;
    hud.mode = AGXProgressHUDModeIndeterminate;
    hud.labelText = text;
    hud.detailsLabelText = nil;
    [hud show:YES];
}

- (void)showTextRecursiveHUDWithText:(NSString *)text hideAfterDelay:(NSTimeInterval)delay {
    [self showTextRecursiveHUDWithText:text detailText:nil hideAfterDelay:delay];
}

- (void)showTextRecursiveHUDWithText:(NSString *)text detailText:(NSString *)detailText hideAfterDelay:(NSTimeInterval)delay {
    AGXProgressHUD *hud = SELF_AGXProgressHUD;
    hud.mode = AGXProgressHUDModeText;
    hud.labelText = text;
    hud.detailsLabelText = detailText;
    [hud show:YES];
    [hud hide:YES afterDelay:delay];
}

- (void)hideRecursiveHUD:(BOOL)animated {
    [SELF_AGXProgressHUD hide:animated];
}

- (UIFont *)recursiveHudLabelFont {
    return SELF_AGXProgressHUD.labelFont;
}

- (void)setRecursiveHudLabelFont:(UIFont *)recursiveHudLabelFont {
    SELF_AGXProgressHUD.labelFont = recursiveHudLabelFont;
}

- (UIFont *)recursiveHudDetailsLabelFont {
    return SELF_AGXProgressHUD.detailsLabelFont;
}

- (void)setRecursiveHudDetailsLabelFont:(UIFont *)recursiveHudDetailsLabelFont {
    SELF_AGXProgressHUD.detailsLabelFont = recursiveHudDetailsLabelFont;
}

@end
