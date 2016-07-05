//
//  AGXWebViewJavascriptBridge.m
//  AGXWidget
//
//  Created by Char Aznable on 16/3/4.
//  Copyright © 2016年 AI-CUC-EC. All rights reserved.
//

#import <AGXCore/AGXCore/NSString+AGXCore.h>
#import <AGXRuntime/AGXRuntime/AGXMethod.h>
#import "AGXWebViewJavascriptBridge.h"

typedef NSDictionary AGXBridgeMessage;

@implementation AGXWebViewJavascriptBridge {
    NSMutableDictionary *_handlers;
}

- (AGX_INSTANCETYPE)init {
    if (AGX_EXPECT_T(self = [super init])) {
        _handlers = [[NSMutableDictionary alloc] init];
    }
    return self;
}

- (void)dealloc {
    AGX_RELEASE(_handlers);
    _delegate = nil;
    AGX_SUPER_DEALLOC;
}

- (void)injectBridgeWrapperJavascript {
    [self.delegate evaluateJavascript:AGXWebViewJavascriptBridgeCallersJavascript(_handlers.allKeys)];
}

- (void)registerHandler:(NSString *)handlerName handler:(AGXBridgeHandler)handler {
    _handlers[handlerName] = AGX_AUTORELEASE([handler copy]);
}

- (void)registerHandler:(NSString *)handlerName handler:(id)handler selector:(SEL)selector {
    __AGX_BLOCK id __handler = handler;
    [self registerHandler:handlerName handler:^id(id data) {
        NSString *signature = [[AGXMethod instanceMethodWithName:NSStringFromSelector(selector)
                                                         inClass:[__handler class]].signature
                               stringByReplacingCharactersInSet:[NSCharacterSet decimalDigitCharacterSet]
                               withString:@"" mergeContinuous:YES];

        NSMethodSignature *sig = [__handler methodSignatureForSelector:selector];
        NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:sig];
        [invocation setTarget:__handler];
        [invocation setSelector:selector];

        if (data) {
            if ([signature hasSuffix:@"@"]) [invocation setArgument:&data atIndex:2];
#define setCTypeArgument(type, typeSel) \
if ([signature hasSuffix:@(@encode(type))]) { type value = [data typeSel]; [invocation setArgument:&value atIndex:2]; }
            setCTypeArgument(char, charValue)
            setCTypeArgument(int, intValue)
            setCTypeArgument(short, shortValue)
            setCTypeArgument(long, longValue)
            setCTypeArgument(long long, longLongValue)
            setCTypeArgument(unsigned char, unsignedCharValue)
            setCTypeArgument(unsigned int, unsignedIntValue)
            setCTypeArgument(unsigned short, unsignedShortValue)
            setCTypeArgument(unsigned long, unsignedLongValue)
            setCTypeArgument(unsigned long long, unsignedLongLongValue)
            setCTypeArgument(BOOL, boolValue)
            setCTypeArgument(float, floatValue)
            setCTypeArgument(double, doubleValue)
#undef setCTypeArgument
        }
        [invocation invoke];

        if ([signature hasPrefix:@"v"]) return nil;

        id result = nil;
        if ([signature hasPrefix:@"@"]) [invocation getReturnValue:&result];
#define getCTypeReturnValue(type) \
if ([signature hasPrefix:@(@encode(type))]) { type value; [invocation getReturnValue:&value]; result = @(value); }
        getCTypeReturnValue(char)
        getCTypeReturnValue(int)
        getCTypeReturnValue(short)
        getCTypeReturnValue(long)
        getCTypeReturnValue(long long)
        getCTypeReturnValue(unsigned char)
        getCTypeReturnValue(unsigned int)
        getCTypeReturnValue(unsigned short)
        getCTypeReturnValue(unsigned long)
        getCTypeReturnValue(unsigned long long)
        getCTypeReturnValue(BOOL)
        getCTypeReturnValue(float)
        getCTypeReturnValue(double)
#undef getCTypeReturnValue
        return result;
    }];
}

#pragma mark - AGXWebViewJavascriptBridgeHandler

- (id)callHandler:(NSString *)handlerName withData:(id)data {
    [self p_log:handlerName data:data];
    AGXBridgeHandler handler = _handlers[handlerName];
    if (!handler) {
        AGXLog(@"AGXWebViewJavascriptBridge NoHandlerException, No handler named: %@", handlerName);
        return nil;
    }
    return handler(data);
}

#pragma mark - private methods

- (void)p_log:(NSString *)handlerName data:(id)data {
    AGXLog(@"AGXWebViewJavascriptBridge %@: %@", handlerName, data);
}

NSString *AGXBridgeInjectJSObjectName = @"AGXB";
static NSString *JSStartFormat = @";(function(){window.%@={_p:function(d){if(d){if(typeof d=='function'){d=String(d)}else if(typeof d=='object'){for(k in d){d[k]=arguments.callee(d[k])}}}return d;}};";
static NSString *JSEnd = @"})();";
static NSString *JSFormat = @"%@.%@=function(d){return AGXBridge.callHandlerWithData('%@',this._p(d));};";
NSString *AGXWebViewJavascriptBridgeCallersJavascript(NSArray *handlerNames) {
    NSMutableString *callerJS = [NSMutableString stringWithFormat:JSStartFormat, AGXBridgeInjectJSObjectName];
    [handlerNames enumerateObjectsUsingBlock:
     ^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
         [callerJS appendFormat:JSFormat, AGXBridgeInjectJSObjectName, obj, obj];
     }];
    [callerJS appendString:JSEnd];
    return AGX_AUTORELEASE([callerJS copy]);
}

@end
