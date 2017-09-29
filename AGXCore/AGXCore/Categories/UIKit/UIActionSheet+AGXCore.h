//
//  UIActionSheet+AGXCore.h
//  AGXCore
//
//  Created by Char Aznable on 16/3/23.
//  Copyright © 2016年 AI-CUC-EC. All rights reserved.
//

#ifndef AGXCore_UIActionSheet_AGXCore_h
#define AGXCore_UIActionSheet_AGXCore_h

#import <UIKit/UIKit.h>
#import "AGXCategory.h"

#if __IPHONE_OS_VERSION_MIN_REQUIRED < __IPHONE_8_3

@category_interface(UIActionSheet, AGXCore)
+ (AGX_INSTANCETYPE)actionSheetWithTitle:(NSString *)title delegate:(id<UIActionSheetDelegate>)delegate cancelButtonTitle:(NSString *)cancelButtonTitle destructiveButtonTitle:(NSString *)destructiveButtonTitle otherButtonTitles:(NSString *)otherButtonTitles, ... NS_REQUIRES_NIL_TERMINATION;
@end

#endif // __IPHONE_OS_VERSION_MIN_REQUIRED < __IPHONE_8_3

#endif /* AGXCore_UIActionSheet_AGXCore_h */
