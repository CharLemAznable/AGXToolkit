//
//  UIView+AGXLayout.m
//  AGXLayout
//
//  Created by Char Aznable on 16/2/21.
//  Copyright © 2016年 AI-CUC-EC. All rights reserved.
//

#import <AGXCore/AGXCore/AGXArc.h>
#import <AGXCore/AGXCore/NSObject+AGXCore.h>
#import <AGXCore/AGXCore/NSNull+AGXCore.h>
#import "UIView+AGXLayout.h"
#import "AGXLayoutTransform.h"

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
NSString *const agxTransformViewCenterKVOKey  = @"center";

@category_implementation(UIView, AGXLayout)

#define BlockSetterImp(type, name)                      \
- (UIView *(^)(type))name##As                           \
{ return AGX_BLOCK_AUTORELEASE(^UIView *(type name)     \
{ [self p_agxTransform].name = name; return self; });}

BlockSetterImp(UIView *, view)
BlockSetterImp(id, left)
BlockSetterImp(id, right)
BlockSetterImp(id, top)
BlockSetterImp(id, bottom)
BlockSetterImp(id, width)
BlockSetterImp(id, height)
BlockSetterImp(id, centerX)
BlockSetterImp(id, centerY)

#undef BlockSetterImp

#pragma mark - swizzle

- (void)AGXLayout_UIView_willMoveToSuperview:(UIView *)newSuperview {
    [self AGXLayout_UIView_willMoveToSuperview:newSuperview];
    if (self.agxTransform && !self.agxTransform.view) {
        // default transform by superview
        self.agxTransform.view = newSuperview;
        [self p_addFrameAndBoundsObserversToView:self.agxTransform.view];
    }
}

- (void)AGXLayout_UIView_dealloc {
    [self p_removeFrameAndBoundsObserversFromView:self.agxTransform.view];
    [self p_removeObserversFromTransform:self.agxTransform];
    [self setRetainProperty:NULL forAssociateKey:agxTransformKVOKey];
    [self AGXLayout_UIView_dealloc];
}

+ (void)load {
    agx_once
    (// observe superview change
     [UIView swizzleInstanceOriSelector:@selector(willMoveToSuperview:)
                        withNewSelector:@selector(AGXLayout_UIView_willMoveToSuperview:)];
     // dealloc with removeObserver
     [UIView swizzleInstanceOriSelector:NSSelectorFromString(@"dealloc")
                        withNewSelector:@selector(AGXLayout_UIView_dealloc)];)
}

#pragma mark - properties methods

- (AGXLayoutTransform *)agxTransform {
    return [self retainPropertyForAssociateKey:agxTransformKVOKey];
}

- (void)setAgxTransform:(AGXLayoutTransform *)zTransform {
    [self setKVORetainProperty:zTransform forAssociateKey:agxTransformKVOKey];
}

- (AGXLayoutTransform *)p_agxTransform {
    if AGX_EXPECT_T(self.agxTransform) return self.agxTransform;
    // default transform by superview
    self.agxTransform = AGXLayoutTransform.instance;
    self.agxTransform.view = self.superview;
    return self.agxTransform;
}

- (void)resizeByTransform {
    if AGX_EXPECT_F(!self.agxTransform) return;
    CGRect rect = [self.agxTransform transformRect];
    self.bounds = CGRectMake(0, 0, rect.size.width, rect.size.height);
    self.center = CGPointMake(rect.origin.x+rect.size.width/2, rect.origin.y+rect.size.height/2);
}

#pragma mark - KVO methods

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
             if ([agxTransformViewKVOKey isEqualToString:keyPath]) {
                 [self p_removeFrameAndBoundsObserversFromView:change[NSKeyValueChangeOldKey]];
                 [self p_addFrameAndBoundsObserversToView:change[NSKeyValueChangeNewKey]];
             }
             [self resizeByTransform];
         }
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
        [self p_addObserversToTransform:newTransform];
        [self p_addFrameAndBoundsObserversToView:newTransform.view];

        [self resizeByTransform];
    }
}

- (void)p_addFrameAndBoundsObserversToView:(UIView *)view {
    if AGX_EXPECT_F([NSNull isNull:view]) return;
    [view addObserver:self forKeyPaths:@[agxTransformViewFrameKVOKey,
                                         agxTransformViewBoundsKVOKey,
                                         agxTransformViewCenterKVOKey]
              options:NSKeyValueObservingOptionNew
              context:(AGX_BRIDGE void *)(agxLayoutKVOContext)];
}

- (void)p_removeFrameAndBoundsObserversFromView:(UIView *)view {
    if AGX_EXPECT_F([NSNull isNull:view]) return;
    [view removeObserver:self forKeyPaths:@[agxTransformViewFrameKVOKey,
                                            agxTransformViewBoundsKVOKey,
                                            agxTransformViewCenterKVOKey]
                 context:(AGX_BRIDGE void *)(agxLayoutKVOContext)];
}

- (void)p_addObserversToTransform:(AGXLayoutTransform *)transform {
    if AGX_EXPECT_F([NSNull isNull:transform]) return;
    [transform addObserver:self forKeyPaths:@[agxTransformLeftKVOKey, agxTransformRightKVOKey,
                                              agxTransformTopKVOKey, agxTransformBottomKVOKey,
                                              agxTransformWidthKVOKey, agxTransformHeightKVOKey,
                                              agxTransformCenterXKVOKey, agxTransformCenterYKVOKey,
                                              agxTransformViewKVOKey]
                   options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld
                   context:(AGX_BRIDGE void *)(agxLayoutKVOContext)];
}

- (void)p_removeObserversFromTransform:(AGXLayoutTransform *)transform {
    if AGX_EXPECT_F([NSNull isNull:transform]) return;
    [transform removeObserver:self forKeyPaths:@[agxTransformLeftKVOKey, agxTransformRightKVOKey,
                                                 agxTransformTopKVOKey, agxTransformBottomKVOKey,
                                                 agxTransformWidthKVOKey, agxTransformHeightKVOKey,
                                                 agxTransformCenterXKVOKey, agxTransformCenterYKVOKey,
                                                 agxTransformViewKVOKey]
                      context:(AGX_BRIDGE void *)(agxLayoutKVOContext)];
}

@end
