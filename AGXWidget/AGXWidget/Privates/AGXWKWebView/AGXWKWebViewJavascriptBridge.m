//
//  AGXWKWebViewJavascriptBridge.m
//  AGXWidget
//
//  Created by Char Aznable on 2019/4/17.
//  Copyright © 2019 github.com/CharLemAznable. All rights reserved.
//

#import <WebKit/WKScriptMessage.h>
#import <AGXCore/AGXCore/NSObject+AGXCore.h>
#import <AGXCore/AGXCore/NSDictionary+AGXCore.h>
#import <AGXCore/AGXCore/NSInvocation+AGXCore.h>
#import <AGXRuntime/AGXRuntime/AGXMethod.h>
#import "AGXWKWebViewJavascriptBridge.h"

#define AGXWKBridgeName         @"AGXWKBridge"
#define AGXWKBridgeParamScope   @"scope"
#define AGXWKBridgeParamName    @"name"
#define AGXWKBridgeParamData    @"data"

typedef void (^AGXWKBridgeHandlerBlock) (id data);

NSString *AGXWKBridgeInjectJSObjectName = @"AGXB";

@implementation AGXWKWebViewJavascriptBridge {
    NSMutableDictionary *_handlers;
}

- (AGX_INSTANCETYPE)init {
    if AGX_EXPECT_T(self = [super init]) {
        _handlers = [[NSMutableDictionary alloc] init];
    }
    return self;
}

- (void)dealloc {
    AGX_RELEASE(_handlers);
    AGX_SUPER_DEALLOC;
}

#pragma mark - AGXWKScriptMessageHandler

- (NSString *)scriptMessageHandlerName {
    return AGXWKBridgeName;
}

#pragma mark - WKScriptMessageHandler

- (void)userContentController:(WKUserContentController *)userContentController didReceiveScriptMessage:(WKScriptMessage *)message {
    if (![AGXWKBridgeName isEqualToString:message.name]) return;

    NSDictionary *body = message.body;
    NSString *scope = [body itemForKey:AGXWKBridgeParamScope]?:AGXWKBridgeInjectJSObjectName;
    NSString *handlerName = [body itemForKey:AGXWKBridgeParamName];
    id data = [body itemForKey:AGXWKBridgeParamData];
    AGXLog(@"AGXWKWebViewJavascriptBridge called %@.%@: %@", scope, handlerName, data);

    AGXWKBridgeHandlerBlock handler = _handlers[scope][handlerName];
    if AGX_EXPECT_F(!handler) {
        AGXLog(@"AGXWKWebViewJavascriptBridge NoHandlerException, No handler named: %@.%@", scope, handlerName);
        return;
    }
    handler(data);
    return;
}

#pragma mark - handler register

- (void)registerHandlerName:(NSString *)handlerName block:(AGXWKBridgeHandlerBlock)block {
    [self registerHandlerName:handlerName block:block scope:nil];
}

- (void)registerHandlerName:(NSString *)handlerName target:(id)target action:(SEL)action {
    [self registerHandlerName:handlerName target:target action:action scope:nil];
}

- (void)registerHandlerName:(NSString *)handlerName block:(AGXWKBridgeHandlerBlock)block scope:(NSString *)scope {
    NSString *scopeName = scope ?: AGXWKBridgeInjectJSObjectName;
    if AGX_EXPECT_F(!_handlers[scopeName]) _handlers[scopeName] = [NSMutableDictionary instance];
    _handlers[scopeName][handlerName] = AGX_BLOCK_AUTORELEASE(block);
}

- (void)registerHandlerName:(NSString *)handlerName target:(id)target action:(SEL)action scope:(NSString *)scope {
    __AGX_WEAK_RETAIN id __target = target;
    [self registerHandlerName:handlerName block:^(id data) {
        NSString *signature = [AGXMethod instanceMethodWithName:NSStringFromSelector(action)
                                                        inClass:[__target class]].purifiedSignature;
        NSInvocation *invocation = [NSInvocation invocationWithTarget:__target action:action];

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
    } scope:scope];
}

#pragma mark - user script

AGX_STATIC NSString *const JSStart = @";(function(){\"function\"!==typeof JSON.decycle&&(JSON.decycle=function(b,f){var g=new WeakMap;return function e(a,d){void 0!==f&&(a=f(a));if(!(\"object\"!==typeof a||null===a||a instanceof Boolean||a instanceof Date||a instanceof Number||a instanceof RegExp||a instanceof String)){var c=g.get(a);if(void 0!==c)return{$ref:c};g.set(a,d);if(Array.isArray(a)){var b=[];a.forEach(function(a,c){b[c]=e(a,d+\"[\"+c+\"]\")})}else b={},Object.keys(a).forEach(function(c){b[c]=e(a[c],d+\"[\"+JSON.stringify(c)+\"]\")});return b}return a}(b,\"$\")});\"function\"!==typeof JSON.retrocycle&&(JSON.retrocycle=function(b){var f=/^\\$(?:\\[(?:\\d+|\"(?:[^\\\\\"\\u0000-\\u001f]|\\\\(?:[\\\\\"\\/bfnrt]|u[0-9a-zA-Z]{4}))*\")\\])*$/;(function a(b){b&&\"object\"===typeof b&&(Array.isArray(b)?b.forEach(function(d,e){if(\"object\"===typeof d&&null!==d){var c=d.$ref;\"string\"===typeof c&&f.test(c)?b[e]=eval(c):a(d)}}):Object.keys(b).forEach(function(d){var e=b[d];if(\"object\"===typeof e&&null!==e){var c=e.$ref;\"string\"===typeof c&&f.test(c)?b[d]=eval(c):a(e)}}))})(b);return b});window.__agxp=function(d){if(d)if('function'==typeof d)d=String(d);else if('object'==typeof d)for(k in d)d[k]=arguments.callee(d[k]);return d};window.__agxh=function(a,b,c){return window.webkit.messageHandlers."AGXWKBridgeName@".postMessage({"AGXWKBridgeParamName@":a,"AGXWKBridgeParamData@":b,"AGXWKBridgeParamScope@":c})};";

AGX_STATIC NSString *const JSScopeFormat = @"window.%@={};";

AGX_STATIC NSString *const JSHandlerFormat = @"%@.%@=function(d){return __agxh('%@',__agxp(JSON.decycle(d)),'%@')};";

AGX_STATIC NSString *const JSCompleteEvent = @"var v=document.createEvent('HTMLEvents');v.initEvent('AGXBComplete',!0,!0);window.dispatchEvent(v);window.__agxcd=!0;";

AGX_STATIC NSString *const JSEnd = @"})();";

- (WKUserScript *)wrapperUserScript {
    NSMutableString *callerJS = [NSMutableString stringWithString:JSStart];
    [_handlers.allKeys enumerateObjectsUsingBlock:
     ^(NSString *scope, NSUInteger idx, BOOL *stop) {
         [callerJS appendFormat:JSScopeFormat, scope];

         NSDictionary *scopeHandlers = _handlers[scope];
         [scopeHandlers.allKeys enumerateObjectsUsingBlock:
          ^(NSString *handlerName, NSUInteger idx, BOOL *stop) {
              [callerJS appendFormat:JSHandlerFormat, scope, handlerName, handlerName, scope];
          }];
     }];
    [callerJS appendString:JSCompleteEvent];
    [callerJS appendString:JSEnd];
    return AGX_AUTORELEASE([[WKUserScript alloc]
                            initWithSource:AGX_AUTORELEASE([callerJS copy])
                            injectionTime:WKUserScriptInjectionTimeAtDocumentStart forMainFrameOnly:YES]);
}

@end

#undef AGXWKBridgeName
#undef AGXWKBridgeParamScope
#undef AGXWKBridgeParamName
#undef AGXWKBridgeParamData
