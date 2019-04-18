//
//  NSInvocation+AGXCore.m
//  AGXCore
//
//  Created by Char on 2019/4/18.
//  Copyright © 2019 github.com/CharLemAznable. All rights reserved.
//

#import "NSInvocation+AGXCore.h"

@category_implementation(NSInvocation, AGXCore)

+ (NSInvocation *)invocationWithTarget:(id)target action:(SEL)action {
    NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:
                                [target methodSignatureForSelector:action]];
    [invocation setTarget:target];
    [invocation setSelector:action];
    return invocation;
}

@end
