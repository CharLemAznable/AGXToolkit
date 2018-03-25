//
//  UIGestureRecognizer+AGXCore.m
//  AGXCore
//
//  Created by Char Aznable on 2017/12/14.
//  Copyright © 2017年 AI-CUC-EC. All rights reserved.
//

#import "UIGestureRecognizer+AGXCore.h"
#import "NSObject+AGXCore.h"

NSString *const agxGestureRecognizerTagKey = @"agxGestureRecognizerTag";

@category_implementation(UIGestureRecognizer, AGXCore)

- (NSUInteger)agxTag {
    return [[self retainPropertyForAssociateKey:agxGestureRecognizerTagKey] unsignedIntegerValue];
}

- (void)setAgxTag:(NSUInteger)agxTag {
    [self setKVORetainProperty:@(agxTag) forAssociateKey:agxGestureRecognizerTagKey];
}

- (void)AGXCore_UIGestureRecognizer_dealloc {
    [self setRetainProperty:NULL forAssociateKey:agxGestureRecognizerTagKey];
    [self AGXCore_UIGestureRecognizer_dealloc];
}

+ (void)load {
    agx_once
    ([UIGestureRecognizer swizzleInstanceOriSelector:NSSelectorFromString(@"dealloc")
                                     withNewSelector:@selector(AGXCore_UIGestureRecognizer_dealloc)];);
}

@end
