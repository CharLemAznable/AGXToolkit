//
//  UIScrollView+AGXCore.h
//  AGXCore
//
//  Created by Char Aznable on 2017/11/29.
//  Copyright © 2017年 AI-CUC-EC. All rights reserved.
//

#ifndef AGXCore_UIScrollView_AGXCore_h
#define AGXCore_UIScrollView_AGXCore_h

#import <UIKit/UIKit.h>
#import "AGXCategory.h"

@category_interface(UIScrollView, AGXCore)
- (void)scrollToTop:(BOOL)animated;
- (void)scrollToBottom:(BOOL)animated;
@end

#endif /* AGXCore_UIScrollView_AGXCore_h */
