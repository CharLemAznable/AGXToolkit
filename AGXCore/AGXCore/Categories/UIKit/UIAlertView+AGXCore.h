//
//  UIAlertView+AGXCore.h
//  AGXCore
//
//  Created by Char Aznable on 16/3/23.
//  Copyright © 2016年 AI-CUC-EC. All rights reserved.
//

#ifndef AGXCore_UIAlertView_AGXCore_h
#define AGXCore_UIAlertView_AGXCore_h

#import <UIKit/UIKit.h>
#import "AGXCategory.h"

#if __IPHONE_OS_VERSION_MIN_REQUIRED < __IPHONE_9_0

@category_interface(UIAlertView, AGXCore)
+ (UIAlertView *)alertViewWithTitle:(NSString *)title message:(NSString *)message delegate:(id)delegate cancelButtonTitle:(NSString *)cancelButtonTitle otherButtonTitles:(NSString *)otherButtonTitles, ... NS_REQUIRES_NIL_TERMINATION;
@end

#endif // __IPHONE_OS_VERSION_MIN_REQUIRED < __IPHONE_9_0

#endif /* AGXCore_UIAlertView_AGXCore_h */
