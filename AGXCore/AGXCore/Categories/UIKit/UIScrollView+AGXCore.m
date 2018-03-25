//
//  UIScrollView+AGXCore.m
//  AGXCore
//
//  Created by Char Aznable on 2017/11/29.
//  Copyright © 2017年 AI-CUC-EC. All rights reserved.
//

#import "AGXGeometry.h"
#import "UIScrollView+AGXCore.h"
#import "NSObject+AGXCore.h"
#import "UIView+AGXCore.h"

@category_implementation(UIScrollView, AGXCore)

- (void)agxInitial {
    [super agxInitial];
    self.automaticallyAdjustsContentInsetByBars = YES;
    self.automaticallyAdjustedContentInset = UIEdgeInsetsMake(0, 0, 0, 0);
}

NSString *const agxAutomaticallyAdjustsContentInsetByBarsKey = @"agxAutomaticallyAdjustsContentInsetByBars";

- (BOOL)automaticallyAdjustsContentInsetByBars {
    return [[self retainPropertyForAssociateKey:agxAutomaticallyAdjustsContentInsetByBarsKey] boolValue];
}

- (void)setAutomaticallyAdjustsContentInsetByBars:(BOOL)automaticallyAdjustsContentInsetByBars {
    if (@available(iOS 11.0, *)) { return; }
    [self setKVORetainProperty:@(automaticallyAdjustsContentInsetByBars)
               forAssociateKey:agxAutomaticallyAdjustsContentInsetByBarsKey];
}

NSString *const agxAutomaticallyAdjustedContentInsetKey = @"agxAutomaticallyAdjustedContentInset";

- (UIEdgeInsets)automaticallyAdjustedContentInset {
    return [[self retainPropertyForAssociateKey:agxAutomaticallyAdjustedContentInsetKey] UIEdgeInsetsValue];
}

- (void)setAutomaticallyAdjustedContentInset:(UIEdgeInsets)automaticallyAdjustedContentInset {
    if (@available(iOS 11.0, *)) { return; }
    [self setKVORetainProperty:[NSValue valueWithUIEdgeInsets:automaticallyAdjustedContentInset]
               forAssociateKey:agxAutomaticallyAdjustedContentInsetKey];
}

- (UIEdgeInsets)contentInsetIncorporated {
    if (@available(iOS 11.0, *)) {
        return AGX_UIEdgeInsetsSubtractUIEdgeInsets(self.adjustedContentInset, self.contentInset);
    } else return self.automaticallyAdjustedContentInset;
}

- (UIEdgeInsets)contentInsetAdjusted {
    UIEdgeInsets contentInsetAdjusted = self.contentInset;
    if (@available(iOS 11.0, *)) {
        contentInsetAdjusted = self.adjustedContentInset;
    }
    return contentInsetAdjusted;
}

- (void)scrollToTop:(BOOL)animated {
    [self setContentOffset:CGPointMake(0, -self.contentInsetAdjusted.top) animated:animated];
}

- (void)scrollToBottom:(BOOL)animated {
    [self setContentOffset:CGPointMake
     (0, MAX(self.contentSize.height + self.contentInsetAdjusted.bottom -
             self.bounds.size.height, -self.contentInsetAdjusted.top)) animated:animated];
}

- (void)AGXCore_UIScrollView_dealloc {
    [self setRetainProperty:NULL forAssociateKey:agxAutomaticallyAdjustsContentInsetByBarsKey];
    [self setRetainProperty:NULL forAssociateKey:agxAutomaticallyAdjustedContentInsetKey];
    [self AGXCore_UIScrollView_dealloc];
}

+ (void)load {
    agx_once
    ([UIScrollView swizzleInstanceOriSelector:NSSelectorFromString(@"dealloc")
                              withNewSelector:@selector(AGXCore_UIScrollView_dealloc)];);
}

@end
