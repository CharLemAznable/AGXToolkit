//
//  AGXWKWebViewErrorBridge.m
//  AGXWidget
//
//  Created by Char on 2019/4/21.
//  Copyright © 2019 github.com/CharLemAznable. All rights reserved.
//

#import <WebKit/WKScriptMessage.h>
#import <AGXCore/AGXCore/NSString+AGXCore.h>
#import <AGXCore/AGXCore/NSDictionary+AGXCore.h>
#import <AGXCore/AGXCore/NSInvocation+AGXCore.h>
#import <AGXRuntime/AGXRuntime/AGXMethod.h>
#import "AGXWKWebViewErrorBridge.h"

#define AGXWKErrorBridgeName            @"AGXWKErrorBridge"
#define AGXWKErrorBridgeParamMessage    @"message"
#define AGXWKErrorBridgeParamStack      @"stack"

typedef void (^AGXWKErrorBridgeHandlerBlock) (NSString *message, NSArray *stack);

@implementation AGXWKWebViewErrorBridge {
    NSMutableArray *_handlers;
}

- (AGX_INSTANCETYPE)init {
    if AGX_EXPECT_T(self = [super init]) {
        _handlers = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)dealloc {
    AGX_RELEASE(_handlers);
    AGX_SUPER_DEALLOC;
}

#pragma mark - AGXWKScriptMessageHandler

- (NSString *)scriptMessageHandlerName {
    return AGXWKErrorBridgeName;
}

#pragma mark - WKScriptMessageHandler

- (void)userContentController:(WKUserContentController *)userContentController didReceiveScriptMessage:(WKScriptMessage *)message {
    if (![AGXWKErrorBridgeName isEqualToString:message.name]) return;

    NSDictionary *body = message.body;
    NSString *msg = [body itemForKey:AGXWKErrorBridgeParamMessage];
    NSString *stack = [body itemForKey:AGXWKErrorBridgeParamStack];
    NSArray *stackArray = [self stackArrayFromStackString:stack];
    AGXLog(@"AGXWKWebViewErrorBridge onerror: %@\nStack:\n%@\n------------", msg, stack);

    [_handlers enumerateObjectsUsingBlock:
     ^(AGXWKErrorBridgeHandlerBlock handler, NSUInteger idx, BOOL *stop) {
         handler(msg, stackArray);
     }];
}

#pragma mark - handler register

- (void)registerErrorHandlerBlock:(AGXWKErrorBridgeHandlerBlock)block {
    [_handlers addObject:AGX_BLOCK_AUTORELEASE(block)];
}

- (void)registerErrorHandlerTarget:(id)target action:(SEL)action {
    __AGX_WEAK_RETAIN id __target = target;
    [self registerErrorHandlerBlock:^(NSString *message, NSArray *stack) {
        NSString *signature = [AGXMethod instanceMethodWithName:NSStringFromSelector(action)
                                                        inClass:[__target class]].purifiedSignature;
        NSInvocation *invocation = [NSInvocation invocationWithTarget:__target action:action];

        NSString *paramsSignature = [signature substringFromFirstString:@":"];
        if ([paramsSignature hasPrefix:@"@"]) [invocation setArgument:&message atIndex:2];
        if ([paramsSignature hasPrefix:@"@@"]) [invocation setArgument:&stack atIndex:3];

        [invocation invoke];
    }];
}

#pragma mark - user script

AGX_STATIC NSString *const JSOnError = @";(function(){window.__agxe=function(e){var n=e.target.tagName,o=e.target.outerHTML,r=e.error;window.webkit.messageHandlers."AGXWKErrorBridgeName@".postMessage({"AGXWKErrorBridgeParamMessage@":n&&n.toLowerCase()==='img'?'Image Load Error:'+o:n&&n.toLowerCase()==='script'?'Script Error:'+o:e.message||'Unknown Error',"AGXWKErrorBridgeParamStack@":r&&r.stack||''})};'undefined'==typeof __agxed&&(window.addEventListener?window.addEventListener('error',__agxe,!0):window.attachEvent&&window.attachEvent('onerror',__agxe));window.__agxed=!0;})();";

- (WKUserScript *)wrapperUserScript {
    return AGX_AUTORELEASE([[WKUserScript alloc]
                            initWithSource:AGX_AUTORELEASE([JSOnError copy])
                            injectionTime:WKUserScriptInjectionTimeAtDocumentStart forMainFrameOnly:YES]);
}

#pragma mark - private methods

- (NSArray *)stackArrayFromStackString:(NSString *)stackString {
    return [[stackString stringByReplacingString:@"Error\n" withString:@""]
            arraySeparatedByCharactersInSet:NSCharacterSet.newlineCharacterSet filterEmpty:YES];
}

@end

#undef AGXWKErrorBridgeName
#undef AGXWKErrorBridgeParamMessage
#undef AGXWKErrorBridgeParamStack
