//
//  AGXWebViewJavascriptBridge.m
//  AGXWidget
//
//  Created by Char Aznable on 2016/3/4.
//  Copyright © 2016 github.com/CharLemAznable. All rights reserved.
//

#import <AGXCore/AGXCore/NSObject+AGXCore.h>
#import <AGXCore/AGXCore/NSString+AGXCore.h>
#import <AGXRuntime/AGXRuntime/AGXMethod.h>
#import <AGXJson/AGXJson.h>
#import "AGXWebViewJavascriptBridge.h"

typedef id      (^AGXBridgeHandlerBlock)        (id data);
typedef void    (^AGXBridgeErrorHandlerBlock)   (NSString *message, NSArray *stack);
typedef void    (^AGXBridgeLogHandlerBlock)     (AGXWebViewLogLevel level, NSArray *content, NSArray *stack);

@implementation AGXWebViewJavascriptBridge {
    NSMutableDictionary *_handlers;
    NSMutableArray *_errorHandlers;
    NSMutableArray *_logHandlers;
}

- (AGX_INSTANCETYPE)init {
    if AGX_EXPECT_T(self = [super init]) {
        _javascriptLogLevel = AGXWebViewLogInfo;

        _handlers = [[NSMutableDictionary alloc] init];
        _errorHandlers = [[NSMutableArray alloc] init];
        _logHandlers = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)dealloc {
    _delegate = nil;
    AGX_RELEASE(_handlers);
    AGX_RELEASE(_errorHandlers);
    AGX_RELEASE(_logHandlers);
    AGX_SUPER_DEALLOC;
}

- (void)injectBridgeWrapperJavascript {
    if ([self.delegate respondsToSelector:@selector(evaluateJavascript:)])
        [self.delegate evaluateJavascript:AGXWebViewJavascriptBridgeCallersJavascript(_handlers)];
}

NSString *AGXBridgeInjectJSObjectName = @"AGXB";

- (void)registerHandlerName:(NSString *)handlerName block:(AGXBridgeHandlerBlock)block {
    [self registerHandlerName:handlerName block:block scope:nil];
}

- (void)registerHandlerName:(NSString *)handlerName target:(id)target action:(SEL)action {
    [self registerHandlerName:handlerName target:target action:action scope:nil];
}

- (void)registerHandlerName:(NSString *)handlerName block:(AGXBridgeHandlerBlock)block scope:(NSString *)scope {
    NSString *scopeName = scope ?: AGXBridgeInjectJSObjectName;
    if AGX_EXPECT_F(!_handlers[scopeName]) _handlers[scopeName] = [NSMutableDictionary instance];
    _handlers[scopeName][handlerName] = AGX_BLOCK_AUTORELEASE(block);
}

- (void)registerHandlerName:(NSString *)handlerName target:(id)target action:(SEL)action scope:(NSString *)scope {
    AGX_WEAKIFY(weakTarget, target);
    [self registerHandlerName:handlerName block:^id(id data) {
        AGX_STRONGIFY(strongTarget, weakTarget);
        if (!strongTarget) return nil;
        NSString *signature = [AGXMethod instanceMethodWithName:NSStringFromSelector(action)
                                                        inClass:[strongTarget class]].purifiedSignature;
        NSInvocation *invocation = invocationWithTargetAndAction(strongTarget, action);

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
        AGX_UNSTRONGIFY(strongTarget);
        return result;
    } scope:scope];
}

- (void)registerErrorHandlerBlock:(AGXBridgeErrorHandlerBlock)block {
    [_errorHandlers addObject:AGX_BLOCK_AUTORELEASE(block)];
}

- (void)registerErrorHandlerTarget:(id)target action:(SEL)action {
    AGX_WEAKIFY(weakTarget, target);
    [self registerErrorHandlerBlock:^(NSString *message, NSArray *stack) {
        AGX_STRONGIFY(strongTarget, weakTarget);
        if (!strongTarget) return;
        NSString *signature = [AGXMethod instanceMethodWithName:NSStringFromSelector(action)
                                                        inClass:[strongTarget class]].purifiedSignature;
        NSInvocation *invocation = invocationWithTargetAndAction(strongTarget, action);

        NSString *paramsSignature = [signature substringFromFirstString:@":"];
        if ([paramsSignature hasPrefix:@"@"]) [invocation setArgument:&message atIndex:2];
        if ([paramsSignature hasPrefix:@"@@"]) [invocation setArgument:&stack atIndex:3];

        [invocation invoke];
        AGX_UNSTRONGIFY(strongTarget);
    }];
}

- (void)setJavascriptLogLevel:(AGXWebViewLogLevel)javascriptLogLevel {
    _javascriptLogLevel = BETWEEN(javascriptLogLevel, AGXWebViewLogDebug, AGXWebViewLogError);
}

- (void)registerLogHandlerBlock:(AGXBridgeLogHandlerBlock)block {
    [_logHandlers addObject:AGX_BLOCK_AUTORELEASE(block)];
}

- (void)registerLogHandlerTarget:(id)target action:(SEL)action {
    AGX_WEAKIFY(weakTarget, target);
    [self registerLogHandlerBlock:^(AGXWebViewLogLevel level, NSArray *content, NSArray *stack) {
        AGX_STRONGIFY(strongTarget, weakTarget);
        if (!strongTarget) return;
        NSString *signature = [AGXMethod instanceMethodWithName:NSStringFromSelector(action)
                                                        inClass:[strongTarget class]].purifiedSignature;
        NSInvocation *invocation = invocationWithTargetAndAction(strongTarget, action);

        NSString *paramsSignature = [signature substringFromFirstString:@":"];
        if ([paramsSignature hasPrefix:@"Q"]) [invocation setArgument:&level atIndex:2];
        if ([paramsSignature hasPrefix:@"Q@"]) [invocation setArgument:&content atIndex:3];
        if ([paramsSignature hasPrefix:@"Q@@"]) [invocation setArgument:&stack atIndex:4];

        [invocation invoke];
        AGX_UNSTRONGIFY(strongTarget);
    }];
}

#pragma mark - AGXWebViewJavascriptBridgeHandler

- (id)callHandler:(NSString *)handlerName withData:(id)data inScope:(NSString *)scope {
    NSString *scopeName = scope ?: AGXBridgeInjectJSObjectName;
    AGXLog(@"AGXWebViewJavascriptBridge called %@.%@: %@", scopeName, handlerName, data);

    AGXBridgeHandlerBlock handler = _handlers[scopeName][handlerName];
    if AGX_EXPECT_F(!handler) {
        AGXLog(@"AGXWebViewJavascriptBridge NoHandlerException, No handler named: %@", handlerName);
        return nil;
    }
    id result = handler(data);

    AGXLog(@"AGXWebViewJavascriptBridge result %@.%@: %@", scopeName, handlerName, result);
    return result;
}

- (void)onErrorWithMessage:(NSString *)message atStack:(NSString *)stack {
    NSArray *stackArray = stackArrayFromStackString(stack);
    AGXLog(@"AGXWebViewJavascriptBridge onerror: %@\nStack:\n%@\n------------", message, stack);

    agx_async_main
    (([_errorHandlers enumerateObjectsUsingBlock:
       ^(AGXBridgeErrorHandlerBlock handler, NSUInteger idx, BOOL *stop) {
           handler(message, stackArray);
       }]););
}

- (void)onLogLevel:(AGXWebViewLogLevel)level withContent:(NSArray *)content atStack:(NSString *)stack {
    NSMutableArray *stackArray = [NSMutableArray arrayWithArray:stackArrayFromStackString(stack)];
    [stackArray removeObjectAtIndex:0]; [stackArray removeObjectAtIndex:0]; // remove first 2 items
    AGXLog(@"AGXWebViewJavascriptBridge on %@: %@\nStack:\n%@\n------------",
           NSStringFromWebViewLogLevel(level), content.agxJsonString,
           [NSString stringWithArray:stackArray joinedByString:@"\n" usingComparator:NULL filterEmpty:YES]);

    if (_javascriptLogLevel > level) return;
    agx_async_main
    (([_logHandlers enumerateObjectsUsingBlock:
       ^(AGXBridgeLogHandlerBlock handler, NSUInteger idx, BOOL *stop) {
           handler(level, content, stackArray);
       }]););
}

#pragma mark - private methods

NSInvocation *invocationWithTargetAndAction(id target, SEL action) {
    NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:
                                [target methodSignatureForSelector:action]];
    [invocation setTarget:target];
    [invocation setSelector:action];
    return invocation;
}

NSArray *stackArrayFromStackString(NSString *stackString) {
    return [[stackString stringByReplacingString:@"Error\n" withString:@""]
            arraySeparatedByCharactersInSet:NSCharacterSet.newlineCharacterSet filterEmpty:YES];
}

AGX_STATIC NSString *const JSStart = @";(function(){window.__agxp=function(d){if(d)if('function'==typeof d)d=String(d);else if('object'==typeof d)for(k in d)d[k]=arguments.callee(d[k]);return d};window.__agxh=function(a,b,c){return AGXBridge.callHandlerWithDataInScope(a,b,c)};";

AGX_STATIC NSString *const JSScopeFormat = @"window.%@={};";

AGX_STATIC NSString *const JSHandlerFormat = @"%@.%@=function(d){return __agxh('%@',__agxp(d),'%@')};";

AGX_STATIC NSString *const JSOnError = @"window.__agxe=function(e){var n=e.target.tagName,o=e.target.outerHTML,r=e.error;AGXBridge.onErrorWithMessageAtStack(n&&n.toLowerCase()==='img'?'Image Load Error:'+o:n&&n.toLowerCase()==='script'?'Script Error:'+o:e.message||'Unknown Error',r&&r.stack||'')};'undefined'==typeof __agxed&&(window.addEventListener?window.addEventListener('error',__agxe,!0):window.attachEvent&&window.attachEvent('onerror',__agxe));window.__agxed=!0;";

AGX_STATIC NSString *const JSConsole = @"window.__agxl=function(v,m){try{throw Error()}catch(e){AGXBridge.onLogLevelWithContentAtStack(v,__agxp(m),e.stack)}};window.__agxa=function(a){return Array.prototype.slice.call(a)};if('undefined'==typeof __agxc){window.__agxc={};window.__agxcf=function(){};window.console=window.console||{};__agxc.log=console.log||__agxcf;__agxc.debug=console.debug||__agxcf;__agxc.info=console.info||__agxcf;__agxc.warn=console.warn||__agxcf;__agxc.error=console.error||__agxcf;console.log=function(){__agxc.log.apply(console,arguments);__agxl(9,__agxa(arguments))};console.debug=function(){__agxc.debug.apply(console,arguments);__agxl(0,__agxa(arguments))};console.info=function(){__agxc.info.apply(console,arguments);__agxl(1,__agxa(arguments))};console.warn=function(){__agxc.warn.apply(console,arguments);__agxl(2,__agxa(arguments))};console.error=function(){__agxc.error.apply(console,arguments);__agxl(3,__agxa(arguments))}}";

AGX_STATIC NSString *const JSCompleteEvent = @"var v=document.createEvent('HTMLEvents');v.initEvent('AGXBComplete',!0,!0);window.dispatchEvent(v);window.__agxcd=!0;";

AGX_STATIC NSString *const JSEnd = @"})();";

NSString *AGXWebViewJavascriptBridgeCallersJavascript(NSDictionary *handlers) {
    NSMutableString *callerJS = [NSMutableString stringWithString:JSStart];
    [handlers.allKeys enumerateObjectsUsingBlock:
     ^(NSString *scope, NSUInteger idx, BOOL *stop) {
         [callerJS appendFormat:JSScopeFormat, scope];

         NSDictionary *scopeHandlers = handlers[scope];
         [scopeHandlers.allKeys enumerateObjectsUsingBlock:
          ^(NSString *handlerName, NSUInteger idx, BOOL *stop) {
              [callerJS appendFormat:JSHandlerFormat, scope, handlerName, handlerName, scope];
          }];
     }];
    [callerJS appendString:JSOnError];
    [callerJS appendString:JSConsole];
    [callerJS appendString:JSCompleteEvent];
    [callerJS appendString:JSEnd];
    return AGX_AUTORELEASE([callerJS copy]);
}

@end
