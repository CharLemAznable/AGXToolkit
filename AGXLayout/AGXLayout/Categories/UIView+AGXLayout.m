//
//  UIView+AGXLayout.m
//  AGXLayout
//
//  Created by Char Aznable on 16/2/21.
//  Copyright © 2016年 AI-CUC-EC. All rights reserved.
//

#import "UIView+AGXLayout.h"
#import "AGXLayoutTransform.h"
#import <AGXCore/AGXCore/NSObject+AGXCore.h>

NSString *const agxLayoutKVOContext           = @"AGXLayoutKVOContext";
NSString *const agxTransformKVOKey            = @"agxTransform";
NSString *const agxTransformLeftKVOKey        = @"left";
NSString *const agxTransformRightKVOKey       = @"right";
NSString *const agxTransformTopKVOKey         = @"top";
NSString *const agxTransformBottomKVOKey      = @"bottom";
NSString *const agxTransformWidthKVOKey       = @"width";
NSString *const agxTransformHeightKVOKey      = @"height";
NSString *const agxTransformCenterXKVOKey     = @"centerX";
NSString *const agxTransformCenterYKVOKey     = @"centerY";
NSString *const agxTransformViewKVOKey        = @"view";
NSString *const agxTransformViewFrameKVOKey   = @"frame";
NSString *const agxTransformViewBoundsKVOKey  = @"bounds";

@category_implementation(UIView, AGXLayout)

- (AGX_INSTANCETYPE)initWithLayoutTransform:(AGXLayoutTransform *)transform {
    if (AGX_EXPECT_T(self = [self init])) {
        [self assignProperty:transform forAssociateKey:agxTransformKVOKey];
        if (transform && !transform.view) transform.view = self.superview; // default transform by superview
        [self p_addObserversToTransform:transform];
        [self p_addFrameAndBoundsObserversToView:transform.view];
    }
    return self;
}

#pragma mark - swizzle

- (void)agx_willMoveToSuperview:(UIView *)newSuperview {
    [self agx_willMoveToSuperview:newSuperview];
    if (self.agxTransform && !self.agxTransform.view) { // default transform by superview
        self.agxTransform.view = newSuperview;
        [self p_addFrameAndBoundsObserversToView:self.agxTransform.view];
    }
}

- (void)agx_dealloc_uiview_agxlayout {
    [self p_removeFrameAndBoundsObserversFromView:self.agxTransform.view];
    [self p_removeObserversFromTransform:self.agxTransform];
    [self assignProperty:nil forAssociateKey:agxTransformKVOKey];
    
    [self agx_dealloc_uiview_agxlayout];
}

+ (void)load {
    static dispatch_once_t once_t;
    dispatch_once(&once_t, ^{
        // observe superview change
        [self swizzleInstanceOriSelector:@selector(willMoveToSuperview:)
                         withNewSelector:@selector(agx_willMoveToSuperview:)];
        // dealloc with removeObserver
        [self swizzleInstanceOriSelector:NSSelectorFromString(@"dealloc")
                         withNewSelector:@selector(agx_dealloc_uiview_agxlayout)];
    });
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if (![agxLayoutKVOContext isEqual:(AGX_BRIDGE id)(context)]) {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
        return;
    }
    
    if (([object isEqual:self.agxTransform.view] &&
         [@[agxTransformViewFrameKVOKey, agxTransformViewBoundsKVOKey] containsObject:keyPath]) ||
        ([object isEqual:self.agxTransform] &&
         [@[agxTransformLeftKVOKey, agxTransformRightKVOKey,
            agxTransformTopKVOKey, agxTransformBottomKVOKey,
            agxTransformWidthKVOKey, agxTransformHeightKVOKey,
            agxTransformCenterXKVOKey, agxTransformCenterYKVOKey,
            agxTransformViewKVOKey] containsObject:keyPath])) {
             if (self.agxTransform) self.frame = [self.agxTransform transformRect];
         }
}

#pragma mark - properties methods

- (AGXLayoutTransform *)agxTransform {
    return [self propertyForAssociateKey:agxTransformKVOKey];
}

- (void)setAgxTransform:(AGXLayoutTransform *)zTransform {
    [self setProperty:zTransform forAssociateKey:agxTransformKVOKey];
}

- (void)willChangeValueForKey:(NSString *)key {
    [super willChangeValueForKey:key];
    if ([key isEqualToString:agxTransformKVOKey]) {
        AGXLayoutTransform *oriTransform = self.agxTransform;
        [self p_removeFrameAndBoundsObserversFromView:oriTransform.view];
        [self p_removeObserversFromTransform:oriTransform];
    }
}

- (void)didChangeValueForKey:(NSString *)key {
    [super didChangeValueForKey:key];
    if ([key isEqualToString:agxTransformKVOKey]) {
        AGXLayoutTransform *newTransform = self.agxTransform;
        // default transform by superview
        if (newTransform && !newTransform.view) newTransform.view = self.superview;
        [self p_addObserversToTransform:newTransform];
        [self p_addFrameAndBoundsObserversToView:newTransform.view];
        if (newTransform) self.frame = [newTransform transformRect];
    }
}

- (id)agxLeft {
    return self.agxTransform.left;
}

- (void)setAgxLeft:(id)zLeft {
    [self p_agxTransform].left = zLeft;
}

- (id)agxRight {
    return self.agxTransform.right;
}

- (void)setAgxRight:(id)zRight {
    [self p_agxTransform].right = zRight;
}

- (id)agxTop {
    return self.agxTransform.top;
}

- (void)setAgxTop:(id)zTop {
    [self p_agxTransform].top = zTop;
}

- (id)agxBottom {
    return self.agxTransform.bottom;
}

- (void)setAgxBottom:(id)zBottom {
    [self p_agxTransform].bottom = zBottom;
}

- (id)agxWidth {
    return self.agxTransform.width;
}

- (void)setAgxWidth:(id)zWidth {
    [self p_agxTransform].width = zWidth;
}

- (id)agxHeight {
    return self.agxTransform.height;
}

- (void)setAgxHeight:(id)zHeight {
    [self p_agxTransform].height = zHeight;
}

- (id)agxCenterX {
    return self.agxTransform.centerX;
}

- (void)setAgxCenterX:(id)zCenterX {
    [self p_agxTransform].centerX = zCenterX;
}

- (id)agxCenterY {
    return self.agxTransform.centerY;
}

- (void)setAgxCenterY:(id)zCenterY {
    [self p_agxTransform].centerY = zCenterY;
}

- (UIView *)agxLayoutView {
    return self.agxTransform.view;
}

- (void)setAgxLayoutView:(UIView *)zView {
    [self p_agxTransform].view = zView;
}

#pragma mark - private methods

- (AGXLayoutTransform *)p_agxTransform {
    if (AGX_EXPECT_T(self.agxTransform)) return self.agxTransform;
    AGXLayoutTransform *transform = [[AGXLayoutTransform alloc] init];
    [self setAgxTransform:transform];
    return AGX_AUTORELEASE(transform);
}

- (void)p_addFrameAndBoundsObserversToView:(UIView *)view {
    [view addObserver:self forKeyPaths:@[agxTransformViewFrameKVOKey, agxTransformViewBoundsKVOKey]
              options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionInitial
              context:(AGX_BRIDGE void *)(agxLayoutKVOContext)];
}

- (void)p_removeFrameAndBoundsObserversFromView:(UIView *)view {
    [view removeObserver:self forKeyPaths:@[agxTransformViewFrameKVOKey, agxTransformViewBoundsKVOKey]
                 context:(AGX_BRIDGE void *)(agxLayoutKVOContext)];
}

- (void)p_addObserversToTransform:(AGXLayoutTransform *)transform {
    [transform addObserver:self forKeyPaths:@[agxTransformLeftKVOKey, agxTransformRightKVOKey,
                                              agxTransformTopKVOKey, agxTransformBottomKVOKey,
                                              agxTransformWidthKVOKey, agxTransformHeightKVOKey,
                                              agxTransformCenterXKVOKey, agxTransformCenterYKVOKey,
                                              agxTransformViewKVOKey]
                   options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionInitial
                   context:(AGX_BRIDGE void *)(agxLayoutKVOContext)];
}

- (void)p_removeObserversFromTransform:(AGXLayoutTransform *)transform {
    [transform removeObserver:self forKeyPaths:@[agxTransformLeftKVOKey, agxTransformRightKVOKey,
                                                 agxTransformTopKVOKey, agxTransformBottomKVOKey,
                                                 agxTransformWidthKVOKey, agxTransformHeightKVOKey,
                                                 agxTransformCenterXKVOKey, agxTransformCenterYKVOKey,
                                                 agxTransformViewKVOKey]
                      context:(AGX_BRIDGE void *)(agxLayoutKVOContext)];
}

@end
