//
//  UINavigationController+AGXCore.m
//  AGXCore
//
//  Created by Char Aznable on 16/2/17.
//  Copyright © 2016年 AI-CUC-EC. All rights reserved.
//

#import "UINavigationController+AGXCore.h"
#import "NSObject+AGXCore.h"
#import "AGXArc.h"

@category_implementation(UIViewController, AGXCoreUINavigationController)

- (UINavigationBar *)navigationBar {
    return self.navigationController.navigationBar;
}

- (void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated {
    [self.navigationController pushViewController:viewController animated:animated];
}

- (UIViewController *)popViewControllerAnimated:(BOOL)animated {
    return [self.navigationController popViewControllerAnimated:animated];
}

- (NSArray *)popToViewController:(UIViewController *)viewController animated:(BOOL)animated {
    return [self.navigationController popToViewController:viewController animated:animated];
}

- (NSArray *)popToRootViewControllerAnimated:(BOOL)animated {
    return [self.navigationController popToRootViewControllerAnimated:animated];
}

- (void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated initialWithBlock:(AGXNavigationCallbackBlock)initial completionWithBlock:(AGXNavigationCallbackBlock)completion {
    [self.navigationController pushViewController:viewController animated:animated
                                 initialWithBlock:initial completionWithBlock:completion];
}

- (UIViewController *)popViewControllerAnimated:(BOOL)animated cleanupWithBlock:(AGXNavigationCallbackBlock)cleanup completionWithBlock:(AGXNavigationCallbackBlock)completion {
    return [self.navigationController popViewControllerAnimated:animated
                                               cleanupWithBlock:cleanup completionWithBlock:completion];
}

- (void)willNavigatePush:(BOOL)animated {}
- (void)didNavigatePush:(BOOL)animated {}
- (void)willNavigatePop:(BOOL)animated {}
- (void)didNavigatePop:(BOOL)animated {}

#pragma mark - Navigate callback implementation -

- (void)agxViewWillAppear:(BOOL)animated {
    [[self class] swizzleAgxViewDidAppearSwizzled:NO];
    
    [self agxViewWillAppearCallback];
    [self willNavigatePush:animated];
    [self agxViewWillAppear:animated];
}

- (void)agxViewDidAppear:(BOOL)animated {
    [self agxViewDidAppear:animated];
    [self didNavigatePush:animated];
    [self agxViewDidAppearCallback];
    
    [self setAgxViewWillAppearCallbackBlock:NULL];
    [self setAgxViewDidAppearCallbackBlock:NULL];
    [[self class] swizzleAgxViewWillAppearSwizzled:YES];
    [[self class] swizzleAgxViewDidAppearSwizzled:YES];
}

- (void)agxViewWillDisappear:(BOOL)animated {
    [[self class] swizzleAgxViewDidDisappearSwizzled:NO];
    
    [self agxViewWillDisappearCallback];
    [self willNavigatePop:animated];
    [self agxViewWillDisappear:animated];
}

- (void)agxViewDidDisappear:(BOOL)animated {
    [self agxViewDidDisappear:animated];
    [self didNavigatePop:animated];
    [self agxViewDidDisappearCallback];
    
    [self setAgxViewWillDisappearCallbackBlock:NULL];
    [self setAgxViewDidDisappearCallbackBlock:NULL];
    [[self class] swizzleAgxViewWillDisappearSwizzled:YES];
    [[self class] swizzleAgxViewDidDisappearSwizzled:YES];
}

#define AGXCallbackBlockImplementation(blockKey)                                                            \
static NSString *const AGXView##blockKey##CallbackBlockKey = @"agxView" @#blockKey @"CallbackBlockKey";     \
- (AGXNavigationCallbackBlock)agxView##blockKey##CallbackBlock {                                            \
    return (AGXNavigationCallbackBlock)[self propertyForAssociateKey:AGXView##blockKey##CallbackBlockKey];  \
}                                                                                                           \
- (void)setAgxView##blockKey##CallbackBlock:(AGXNavigationCallbackBlock)block {                             \
    [self setProperty:(id)block forAssociateKey:AGXView##blockKey##CallbackBlockKey];                       \
}                                                                                                           \
- (void)agxView##blockKey##Callback {                                                                       \
    AGXNavigationCallbackBlock block = [self agxView##blockKey##CallbackBlock];                             \
    if (block) block(self);                                                                                 \
}

AGXCallbackBlockImplementation(WillAppear);
AGXCallbackBlockImplementation(DidAppear);
AGXCallbackBlockImplementation(WillDisappear);
AGXCallbackBlockImplementation(DidDisappear);

- (void)agx_dealloc_uinavigationcontroller_agxcore {
    [self setProperty:NULL forAssociateKey:AGXViewWillAppearCallbackBlockKey];
    [self setProperty:NULL forAssociateKey:AGXViewDidAppearCallbackBlockKey];
    [self setProperty:NULL forAssociateKey:AGXViewWillDisappearCallbackBlockKey];
    [self setProperty:NULL forAssociateKey:AGXViewDidDisappearCallbackBlockKey];
    [self agx_dealloc_uinavigationcontroller_agxcore];
}

+ (void)load {
    static dispatch_once_t once_t;
    dispatch_once(&once_t, ^{
#if !IS_ARC
        [self swizzleInstanceOriSelector:@selector(dealloc)
                         withNewSelector:@selector(agx_dealloc_uinavigationcontroller_agxcore)];
#endif
    });
}

#define AGXCallbackSwizzleImplementation(swizzleKey)                                                \
static NSString *const AGXView##swizzleKey##SwizzledKey = @"agxView" @#swizzleKey @"SwizzledKey";   \
+ (BOOL)agxView##swizzleKey##Swizzled {                                                             \
    return [[self propertyForAssociateKey:AGXView##swizzleKey##SwizzledKey] boolValue];             \
}                                                                                                   \
+ (void)setAgxView##swizzleKey##Swizzled:(BOOL)swizzled {                                           \
    [self setProperty:@(swizzled) forAssociateKey:AGXView##swizzleKey##SwizzledKey];                \
}                                                                                                   \
+ (void)swizzleAgxView##swizzleKey##Swizzled:(BOOL)swizzled {                                       \
    @synchronized(self) {                                                                           \
        if ([self agxView##swizzleKey##Swizzled] == swizzled) {                                     \
            [self swizzleInstanceOriSelector:@selector(view##swizzleKey:)                           \
                             withNewSelector:@selector(agxView##swizzleKey:)];                      \
            [self setAgxView##swizzleKey##Swizzled:!swizzled];                                      \
        }                                                                                           \
    }                                                                                               \
}

AGXCallbackSwizzleImplementation(WillAppear);
AGXCallbackSwizzleImplementation(DidAppear);
AGXCallbackSwizzleImplementation(WillDisappear);
AGXCallbackSwizzleImplementation(DidDisappear);

@end

@category_implementation(UINavigationController, AGXCore)

- (void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated
          initialWithBlock:(AGXNavigationCallbackBlock)initial
       completionWithBlock:(AGXNavigationCallbackBlock)completion {
    [viewController setAgxViewWillAppearCallbackBlock:initial];
    [viewController setAgxViewDidAppearCallbackBlock:completion];
    [self pushViewController:viewController animated:animated];
}

- (UIViewController *)popViewControllerAnimated:(BOOL)animated
                               cleanupWithBlock:(AGXNavigationCallbackBlock)cleanup
                            completionWithBlock:(AGXNavigationCallbackBlock)completion {
    [self.topViewController setAgxViewWillDisappearCallbackBlock:cleanup];
    [self.topViewController setAgxViewDidDisappearCallbackBlock:completion];
    return [self popViewControllerAnimated:animated];
                            }

- (void)agx_pushViewController:(UIViewController *)viewController animated:(BOOL)animated {
    [[viewController class] swizzleAgxViewWillAppearSwizzled:NO];
    [self agx_pushViewController:viewController animated:animated];
}

- (UIViewController *)agx_popViewControllerAnimated:(BOOL)animated {
    [[self.topViewController class] swizzleAgxViewWillDisappearSwizzled:NO];
    return [self agx_popViewControllerAnimated:animated];
}

+ (void)load {
    static dispatch_once_t once_t;
    dispatch_once(&once_t, ^{
        [self swizzleInstanceOriSelector:@selector(pushViewController:animated:)
                         withNewSelector:@selector(agx_pushViewController:animated:)];
        [self swizzleInstanceOriSelector:@selector(popViewControllerAnimated:)
                         withNewSelector:@selector(agx_popViewControllerAnimated:)];
    });
}

@end
