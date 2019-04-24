//
//  AGXWKWebViewConsoleBridge.m
//  AGXWidget
//
//  Created by Char Aznable on 2019/4/21.
//  Copyright © 2019 github.com/CharLemAznable. All rights reserved.
//

#import <WebKit/WKScriptMessage.h>
#import <AGXCore/AGXCore/NSDictionary+AGXCore.h>
#import <AGXCore/AGXCore/NSInvocation+AGXCore.h>
#import <AGXRuntime/AGXRuntime/AGXMethod.h>
#import <AGXJson/AGXJson.h>
#import "AGXWKWebViewConsoleBridge.h"

#define AGXWKConsoleBridgeName          @"AGXWKConsoleBridge"
#define AGXWKConsoleBridgeParamLevel    @"level"
#define AGXWKConsoleBridgeParamContent  @"content"
#define AGXWKConsoleBridgeParamStack    @"stack"

typedef void (^AGXWKConsoleBridgeHandlerBlock) (AGXWKWebViewLogLevel level, NSArray *content, NSArray *stack);

@implementation AGXWKWebViewConsoleBridge {
    NSMutableArray *_handlers;
}

- (AGX_INSTANCETYPE)init {
    if AGX_EXPECT_T(self = [super init]) {
        _handlers = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)setJavascriptLogLevel:(AGXWKWebViewLogLevel)javascriptLogLevel {
    _javascriptLogLevel = BETWEEN(javascriptLogLevel, AGXWKWebViewLogDebug, AGXWKWebViewLogError);
}

- (void)dealloc {
    AGX_RELEASE(_handlers);
    AGX_SUPER_DEALLOC;
}

#pragma mark - AGXWKScriptMessageHandler

- (NSString *)scriptMessageHandlerName {
    return AGXWKConsoleBridgeName;
}

#pragma mark - WKScriptMessageHandler

- (void)userContentController:(WKUserContentController *)userContentController didReceiveScriptMessage:(WKScriptMessage *)message {
    if (![AGXWKConsoleBridgeName isEqualToString:message.name]) return;

    NSDictionary *body = message.body;
    AGXWKWebViewLogLevel level = [[body itemForKey:AGXWKConsoleBridgeParamLevel] unsignedIntegerValue];
    NSArray *content = [body itemForKey:AGXWKConsoleBridgeParamContent];
    NSString *stack = [body itemForKey:AGXWKConsoleBridgeParamStack];
    NSMutableArray *stackArray = [NSMutableArray arrayWithArray:[self stackArrayFromStackString:stack]];
    [stackArray removeObjectAtIndex:0]; [stackArray removeObjectAtIndex:0]; // remove first 2 items
    AGXLog(@"AGXWKWebViewConsoleBridge on %@: %@\nStack:\n%@\n------------",
           NSStringFromWKWebViewLogLevel(level), content.agxJsonString,
           [NSString stringWithArray:stackArray joinedByString:@"\n" usingComparator:NULL filterEmpty:YES]);

    if (_javascriptLogLevel > level) return;
    [_handlers enumerateObjectsUsingBlock:
     ^(AGXWKConsoleBridgeHandlerBlock handler, NSUInteger idx, BOOL *stop) {
         handler(level, content, stackArray);
     }];
}

#pragma mark - handler register

- (void)registerLogHandlerBlock:(AGXWKConsoleBridgeHandlerBlock)block {
    [_handlers addObject:AGX_BLOCK_AUTORELEASE(block)];
}

- (void)registerLogHandlerTarget:(id)target action:(SEL)action {
    __AGX_WEAK_RETAIN id __target = target;
    [self registerLogHandlerBlock:^(AGXWKWebViewLogLevel level, NSArray *content, NSArray *stack) {
        NSString *signature = [AGXMethod instanceMethodWithName:NSStringFromSelector(action)
                                                        inClass:[__target class]].purifiedSignature;
        NSInvocation *invocation = [NSInvocation invocationWithTarget:__target action:action];

        NSString *paramsSignature = [signature substringFromFirstString:@":"];
        if ([paramsSignature hasPrefix:@"Q"]) [invocation setArgument:&level atIndex:2];
        if ([paramsSignature hasPrefix:@"Q@"]) [invocation setArgument:&content atIndex:3];
        if ([paramsSignature hasPrefix:@"Q@@"]) [invocation setArgument:&stack atIndex:4];

        [invocation invoke];
    }];
}

#pragma mark - user script

AGX_STATIC NSString *const JSConsole = @";(function(){window.__agxp=function(d){if(d)if('function'==typeof d)d=String(d);else if('object'==typeof d)for(k in d)d[k]=arguments.callee(d[k]);return d};window.__agxl=function(v,m){try{throw Error()}catch(e){window.webkit.messageHandlers."AGXWKConsoleBridgeName@".postMessage({"AGXWKConsoleBridgeParamLevel@":v,"AGXWKConsoleBridgeParamContent@":__agxp(m),"AGXWKConsoleBridgeParamStack@":e.stack})}};window.__agxa=function(a){return Array.prototype.slice.call(a)};if('undefined'==typeof __agxc){window.__agxc={};window.__agxcf=function(){};window.console=window.console||{};__agxc.log=console.log||__agxcf;__agxc.debug=console.debug||__agxcf;__agxc.info=console.info||__agxcf;__agxc.warn=console.warn||__agxcf;__agxc.error=console.error||__agxcf;console.log=function(){__agxc.log.apply(console,arguments);__agxl(9,__agxa(arguments))};console.debug=function(){__agxc.debug.apply(console,arguments);__agxl(0,__agxa(arguments))};console.info=function(){__agxc.info.apply(console,arguments);__agxl(1,__agxa(arguments))};console.warn=function(){__agxc.warn.apply(console,arguments);__agxl(2,__agxa(arguments))};console.error=function(){__agxc.error.apply(console,arguments);__agxl(3,__agxa(arguments))}}})();";

- (WKUserScript *)wrapperUserScript {
    return AGX_AUTORELEASE([[WKUserScript alloc]
                            initWithSource:AGX_AUTORELEASE([JSConsole copy])
                            injectionTime:WKUserScriptInjectionTimeAtDocumentStart forMainFrameOnly:YES]);
}

#pragma mark - private methods

- (NSArray *)stackArrayFromStackString:(NSString *)stackString {
    return [[stackString stringByReplacingString:@"Error\n" withString:@""]
            arraySeparatedByCharactersInSet:NSCharacterSet.newlineCharacterSet filterEmpty:YES];
}

@end
