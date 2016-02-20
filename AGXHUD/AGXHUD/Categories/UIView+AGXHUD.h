//
//  UIView+AGXHUD.h
//  AGXHUD
//
//  Created by Char Aznable on 16/2/20.
//  Copyright © 2016年 AI-CUC-EC. All rights reserved.
//

#ifndef AGXHUD_UIView_AGXHUD_h
#define AGXHUD_UIView_AGXHUD_h

#import "AGXProgressHUD.h"
#import <AGXCore/AGXCore/AGXCategory.h>

/**
 * AGXProgressHUD for CURRENT view.
 */
@category_interface(UIView, AGXHUD)
@property (AGX_STRONG) UIFont *hudLabelFont;
@property (AGX_STRONG) UIFont *hudDetailsLabelFont;

/**
 * Finds the top-most HUD subview and returns it.
 * If there is no HUD subview, add one and returns it.
 * Created invisible HUD with:
 *   square:YES
 *   animationType:AGXProgressHUDAnimationFade
 *   removeFromSuperViewOnHide:YES
 */
- (AGXProgressHUD *)agxProgressHUD;

- (void)showIndeterminateHUDWithText:(NSString *)text;
- (void)showTextHUDWithText:(NSString *)text hideAfterDelay:(NSTimeInterval)delay;
- (void)showTextHUDWithText:(NSString *)text detailText:(NSString *)detailText hideAfterDelay:(NSTimeInterval)delay;
- (void)hideHUD:(BOOL)animated;
@end

#endif /* AGXHUD_UIView_AGXHUD_h */
