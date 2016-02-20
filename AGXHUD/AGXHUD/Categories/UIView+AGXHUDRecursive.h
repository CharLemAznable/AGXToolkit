//
//  UIView+AGXHUDRecursive.h
//  AGXHUD
//
//  Created by Char Aznable on 16/2/20.
//  Copyright © 2016年 AI-CUC-EC. All rights reserved.
//

#ifndef AGXHUD_UIView_AGXHUDRecursive_h
#define AGXHUD_UIView_AGXHUDRecursive_h

#import "AGXProgressHUD.h"
#import <AGXCore/AGXCore/AGXCategory.h>

/**
 * AGXProgressHUD RECURSIVE in current view and its subviews.
 */
@category_interface(UIView, AGXHUDRecursive)
@property (AGX_STRONG) UIFont *recursiveHudLabelFont;
@property (AGX_STRONG) UIFont *recursiveHudDetailsLabelFont;

/**
 * Finds the top-most HUD subview RECURSIVE in subviews and returns it.
 * If there is no HUD subview, return nil.
 */
- (AGXProgressHUD *)recursiveAGXProgressHUD;

- (void)showIndeterminateRecursiveHUDWithText:(NSString *)text;
- (void)showTextRecursiveHUDWithText:(NSString *)text hideAfterDelay:(NSTimeInterval)delay;
- (void)showTextRecursiveHUDWithText:(NSString *)text detailText:(NSString *)detailText hideAfterDelay:(NSTimeInterval)delay;
- (void)hideRecursiveHUD:(BOOL)animated;
@end

#endif /* AGXHUD_UIView_AGXHUDRecursive_h */
