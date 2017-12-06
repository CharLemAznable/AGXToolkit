//
//  UIScrollView+AGXCore.m
//  AGXCore
//
//  Created by Char Aznable on 2017/11/29.
//  Copyright © 2017年 AI-CUC-EC. All rights reserved.
//

#import "UIScrollView+AGXCore.h"
#import "UIView+AGXCore.h"

@category_implementation(UIScrollView, AGXCore)

- (void)agxInitial {
    [super agxInitial];
    if (@available(iOS 11.0, *)) self.contentInsetAdjustmentBehavior
        = UIScrollViewContentInsetAdjustmentNever;
}

- (void)scrollToTop:(BOOL)animated {
    [self setContentOffset:CGPointMake
     (0, -self.contentInset.top) animated:animated];
}

- (void)scrollToBottom:(BOOL)animated {
    [self setContentOffset:CGPointMake
     (0, MAX(self.contentSize.height + self.contentInset.bottom -
             self.bounds.size.height, 0)) animated:animated];
}

@end
