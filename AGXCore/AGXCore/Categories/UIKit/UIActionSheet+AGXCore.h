//
//  UIActionSheet+AGXCore.h
//  AGXCore
//
//  Created by Char Aznable on 16/3/23.
//  Copyright © 2016年 AI-CUC-EC. All rights reserved.
//

#ifndef AGXCore_UIActionSheet_AGXCore_h
#define AGXCore_UIActionSheet_AGXCore_h

#if __IPHONE_OS_VERSION_MIN_REQUIRED < 80000

#import <UIKit/UIKit.h>
#import "AGXCategory.h"

@category_interface(UIActionSheet, AGXCore)
+ (UIActionSheet *)actionSheetWithTitle:(NSString *)title delegate:(id<UIActionSheetDelegate>)delegate cancelButtonTitle:(NSString *)cancelButtonTitle destructiveButtonTitle:(NSString *)destructiveButtonTitle otherButtonTitles:(NSString *)otherButtonTitles, ... NS_REQUIRES_NIL_TERMINATION;
@end

#endif // __IPHONE_OS_VERSION_MIN_REQUIRED < 80000

#endif /* AGXCore_UIActionSheet_AGXCore_h */
