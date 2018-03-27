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

@protocol UIScrollViewDelegate_AGXCore <NSObject>
- (void)scrollViewDidChangeAutomaticallyAdjustedContentInset:(UIScrollView *)scrollView API_DEPRECATED("No longer supported", ios(8.0, 11.0));
@end

@category_interface(UIScrollView, AGXCore)
@property (nonatomic, assign)   BOOL automaticallyAdjustsContentInsetByBars API_DEPRECATED_WITH_REPLACEMENT("Use UIScrollView's contentInsetAdjustmentBehavior instead", ios(8.0, 11.0));
@property (nonatomic, assign)   UIEdgeInsets automaticallyAdjustedContentInset API_DEPRECATED("No longer supported", ios(8.0, 11.0));
@property (nonatomic, readonly) UIEdgeInsets contentInsetIncorporated;
@property (nonatomic, readonly) UIEdgeInsets contentInsetAdjusted;
- (void)scrollToTop:(BOOL)animated;
- (void)scrollToBottom:(BOOL)animated;
@end

#endif /* AGXCore_UIScrollView_AGXCore_h */
