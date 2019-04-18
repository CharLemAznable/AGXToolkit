//
//  AGXDelegateForwarder.h
//  AGXCore
//
//  Created by Char on 2019/4/18.
//  Copyright © 2019 github.com/CharLemAznable. All rights reserved.
//

#ifndef AGXCore_AGXDelegateForwarder_h
#define AGXCore_AGXDelegateForwarder_h

#import "AGXArc.h"

// forwarder_interface
#define forwarder_interface(className, targetClassName, protocolName)   \
interface className : NSObject <protocolName>                           \
@property (nonatomic, AGX_WEAK) targetClassName *internalDelegate;      \
@property (nonatomic, AGX_WEAK) id<protocolName> externalDelegate;      \
@end                                                                    \
@interface className ()

// forwarder_implementation
#define forwarder_implementation(className, targetClassName, protocolName)                              \
implementation className                                                                                \
- (AGX_INSTANCETYPE)initWithInternalDelegate:(targetClassName *)internalDelegate                        \
                            externalDelegate:(id<protocolName>)externalDelegate {                       \
    if AGX_EXPECT_T(self = [super init]) {                                                              \
        _internalDelegate = internalDelegate;                                                           \
        _externalDelegate = externalDelegate;                                                           \
    }                                                                                                   \
    return self;                                                                                        \
}                                                                                                       \
- (void)dealloc {                                                                                       \
    _internalDelegate = nil;                                                                            \
    _externalDelegate = nil;                                                                            \
    AGX_SUPER_DEALLOC;                                                                                  \
}                                                                                                       \
- (NSMethodSignature *)methodSignatureForSelector:(SEL)aSelector {                                      \
    return([super methodSignatureForSelector:aSelector] ?:                                              \
           [_internalDelegate methodSignatureForSelector:aSelector] ?:                                  \
           [(NSObject *)_externalDelegate methodSignatureForSelector:aSelector]);                       \
}                                                                                                       \
- (BOOL)respondsToSelector:(SEL)aSelector {                                                             \
    return([super respondsToSelector:aSelector] ||                                                      \
           [_internalDelegate respondsToSelector:aSelector] ||                                          \
           [(NSObject *)_externalDelegate respondsToSelector:aSelector]);                               \
}                                                                                                       \
- (void)forwardInvocation:(NSInvocation *)anInvocation {                                                \
    SEL aSelector = [anInvocation selector];                                                            \
    BOOL internalDelegateWillRespond = [_internalDelegate respondsToSelector:aSelector];                \
    BOOL externalDelegateWillRespond = [(NSObject *)_externalDelegate respondsToSelector:aSelector];    \
    if (internalDelegateWillRespond) [anInvocation invokeWithTarget:_internalDelegate];                 \
    if (externalDelegateWillRespond) [anInvocation invokeWithTarget:_externalDelegate];                 \
    if (!internalDelegateWillRespond && !externalDelegateWillRespond)                                   \
        [super forwardInvocation:anInvocation];                                                         \
}                                                                                                       \
- (id)forwardingTargetForSelector:(SEL)aSelector {                                                      \
    BOOL internalDelegateWillRespond = [_internalDelegate respondsToSelector:aSelector];                \
    BOOL externalDelegateWillRespond = [(NSObject *)_externalDelegate respondsToSelector:aSelector];    \
    if (internalDelegateWillRespond && !externalDelegateWillRespond) return _internalDelegate;          \
    if (externalDelegateWillRespond && !internalDelegateWillRespond) return _externalDelegate;          \
    return nil;                                                                                         \
}

#endif /* AGXCore_AGXDelegateForwarder_h */
