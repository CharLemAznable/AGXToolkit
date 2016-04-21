//
//  UIView+AGXWidgetAnimation.m
//  AGXWidget
//
//  Created by Char Aznable on 16/2/29.
//  Copyright © 2016年 AI-CUC-EC. All rights reserved.
//

#import "UIView+AGXWidgetAnimation.h"
#import <AGXCore/AGXCore/AGXArc.h>
#import "AGXAnimationInternal.h"

@category_implementation(UIView, AGXWidgetAnimation)

- (void)agxAnimate:(AGXAnimation)animation {
    [self agxAnimate:animation completion:^{}];
}

- (void)agxAnimate:(AGXAnimation)animation completion:(void (^)())completion {
    if (!(animation.type & (AGXAnimateMove|AGXAnimateFade|AGXAnimateSlide|AGXAnimateExpand|AGXAnimateShrink))) {
        if (!(animation.type & AGXAnimateRepeat)) completion();
        return;
    } // none animation specify, return directly; if repeat, no completion.

    AGXAnimationInternal internal = buildInternalAnimation(self, animation);

    UIView *maskView = nil;
    if (internal.hasMask) {
        maskView = AGX_AUTORELEASE([[UIView alloc] initWithFrame:self.bounds]);
        maskView.layer.backgroundColor = [UIColor whiteColor].CGColor;
        self.layer.mask = maskView.layer;
    }

    self.transform = internal.viewTransform.from;
    self.alpha = internal.viewAlpha.from;
    maskView.transform = internal.maskTransform.from;
    [UIView animateWithDuration:internal.duration delay:internal.delay options:internal.options
                     animations:^{
                         self.transform = internal.viewTransform.to;
                         self.alpha = internal.viewAlpha.to;
                         maskView.transform = internal.maskTransform.to;
                     } completion:^(BOOL finished) {
                         self.transform = internal.viewTransform.final;
                         self.alpha = internal.viewAlpha.final;
                         maskView.transform = internal.maskTransform.final;
                         completion();
                     }];
}

@end
