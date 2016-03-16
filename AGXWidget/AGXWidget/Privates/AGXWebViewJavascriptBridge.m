//
//  AGXWebViewJavascriptBridge.m
//  AGXWidget
//
//  Created by Char Aznable on 16/3/4.
//  Copyright © 2016年 AI-CUC-EC. All rights reserved.
//

//
//  Copyright (c) 2011-2015 Marcus Westin, Antoine Lagadec
//
//  Permission is hereby granted, free of charge, to any person
//  obtaining a copy of this software and associated documentation
//  files (the "Software"), to deal in the Software without
//  restriction, including without limitation the rights to use,
//  copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the
//  Software is furnished to do so, subject to the following
//  conditions:
//
//  The above copyright notice and this permission notice shall be
//  included in all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
//  EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
//  OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
//  NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
//  HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
//  WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
//  FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
//  OTHER DEALINGS IN THE SOFTWARE.
//

#import "AGXWebViewJavascriptBridge.h"
#import "AGXWebViewJavascriptBridgeJS.h"
#import <AGXCore/AGXCore/AGXObjC.h>
#import <AGXCore/AGXCore/AGXArc.h>
#import <AGXCore/AGXCore/NSString+AGXCore.h>
#import <AGXRuntime/AGXRuntime/AGXMethod.h>

typedef NSDictionary AGXBridgeMessage;

@implementation AGXWebViewJavascriptBridge {
    NSMutableArray *_startupMessageQueue;
    NSMutableDictionary *_responseCallbacks;
    NSMutableDictionary *_messageHandlers;
    long _uniqueId;
}

- (AGX_INSTANCETYPE)init {
    if (AGX_EXPECT_T(self = [super init])) {
        _autoEmbedJavascript = YES;
        
        _startupMessageQueue = [[NSMutableArray alloc] init];
        _responseCallbacks = [[NSMutableDictionary alloc] init];
        _messageHandlers = [[NSMutableDictionary alloc] init];
        _uniqueId = 0;
    }
    return self;
}

- (void)dealloc {
    AGX_RELEASE(_startupMessageQueue);
    AGX_RELEASE(_responseCallbacks);
    AGX_RELEASE(_messageHandlers);
    _delegate = nil;
    AGX_SUPER_DEALLOC;
}

- (void)registerHandler:(NSString *)handlerName handler:(AGXBridgeHandler)handler {
    _messageHandlers[handlerName] = AGX_AUTORELEASE([handler copy]);
}

- (void)registerHandler:(NSString *)handlerName handler:(id)handler selector:(SEL)selector {
    __AGX_BLOCK id __handler = handler;
    [self registerHandler:handlerName handler:^(id data, AGXBridgeResponseCallback responseCallback) {
        NSString *signature = [[AGXMethod instanceMethodWithName:NSStringFromSelector(selector)
                                                         inClass:[handler class]].signature
                               stringByReplacingCharactersInSet:[NSCharacterSet decimalDigitCharacterSet] withString:@""];
        
        if (data && ![signature hasSuffix:@":"] && ![signature hasSuffix:@"@"]) data = @((NSInteger)data);
        AGX_PerformSelector
        (
         if ([signature hasPrefix:@"v"]) {
             [__handler performSelector:selector withObject:data]; responseCallback(nil);
         } else if ([signature hasPrefix:@"@"]) {
             responseCallback([__handler performSelector:selector withObject:data]);
         } else responseCallback(@((NSInteger)[__handler performSelector:selector withObject:data]));
         )
    }];
}

- (void)callHandler:(NSString *)handlerName {
    [self callHandler:handlerName data:nil];
}

- (void)callHandler:(NSString *)handlerName data:(id)data {
    [self callHandler:handlerName data:data responseCallback:nil];
}

- (void)callHandler:(NSString *)handlerName data:(id)data responseCallback:(AGXBridgeResponseCallback)responseCallback {
    NSMutableDictionary *message = [NSMutableDictionary dictionary];
    
    if (handlerName) message[@"handlerName"] = handlerName;
    if (data) message[@"data"] = data;
    if (responseCallback) {
        NSString* callbackId = [NSString stringWithFormat:@"objc_cb_%ld", ++_uniqueId];
        _responseCallbacks[callbackId] = AGX_AUTORELEASE([responseCallback copy]);
        message[@"callbackId"] = callbackId;
    }
    
    [self p_queueMessage:message];
}

- (void)setupBridge {
    if (_autoEmbedJavascript) [_delegate evaluateJavascript:AGXWebViewJavascriptBridgeSetupJavascript()];
}

- (BOOL)doBridgeWithRequest:(NSURLRequest *)request {
    if (_autoEmbedJavascript) [_delegate evaluateJavascript:
                               AGXWebViewJavascriptBridgeCallersJavascript(_messageHandlers.allKeys)];
    
    NSURL *url = request.URL;
    if (!isJavascriptBridgeScheme(url)) return NO;
    
    if (isJavascriptBridgeLoaded(url) && _autoEmbedJavascript) {
        [_delegate evaluateJavascript:AGXWebViewJavascriptBridgeLoadedJavascript()];
        [self p_flushStartupMessageQueue];
    } else if (isJavascriptBridgeQueueMessage(url)) {
        [self p_flushMessageQueue:[_delegate evaluateJavascript:AGXWebViewJavascriptBridgeFetchQueueCommand()]];
    } else {
        AGXLog(@"AGXWebViewJavascriptBridge: WARNING: Unknown bridge command %@://%@", url.scheme, url.path);
        return NO;
    }
    return YES;
}

- (void)reset {
    AGX_RELEASE(_startupMessageQueue);
    _startupMessageQueue = [[NSMutableArray alloc] init];
    AGX_RELEASE(_responseCallbacks);
    _responseCallbacks = [[NSMutableDictionary alloc] init];
    _uniqueId = 0;
}

#pragma mark - Private Methods

- (void)p_flushStartupMessageQueue {
    if (_startupMessageQueue) {
        NSArray* queue = AGX_RETAIN(_startupMessageQueue);
        AGX_RELEASE(_startupMessageQueue);
        _startupMessageQueue = nil;
        for (id queuedMessage in queue) {
            [self p_dispatchMessage:queuedMessage];
        }
        AGX_RELEASE(queue);
    }
}

- (void)p_flushMessageQueue:(NSString *)messageQueueString{
    if (messageQueueString == nil || messageQueueString.length == 0) {
        AGXLog(@"AGXWebViewJavascriptBridge: WARNING: ObjC got nil while fetching the message queue JSON from webview. This can happen if the AGXWebViewJavascriptBridge JS is not currently present in the webview, e.g if the webview just loaded a new page.");
        return;
    }
    
    id messages = [self p_deserializeMessageJSON:messageQueueString];
    for (AGXBridgeMessage* message in messages) {
        if (![message isKindOfClass:[AGXBridgeMessage class]]) {
            AGXLog(@"AGXWebViewJavascriptBridge: WARNING: Invalid %@ received: %@", [message class], message);
            continue;
        }
        [self p_log:@"RCVD" json:message];
        
        NSString* responseId = message[@"responseId"];
        if (responseId) {
            AGXBridgeResponseCallback responseCallback = _responseCallbacks[responseId];
            responseCallback(message[@"responseData"]);
            [_responseCallbacks removeObjectForKey:responseId];
        } else {
            AGXBridgeResponseCallback responseCallback = NULL;
            NSString* callbackId = message[@"callbackId"];
            if (callbackId) {
                responseCallback = ^(id responseData) {
                    if (responseData == nil) responseData = [NSNull null];
                    AGXBridgeMessage* msg = @{ @"responseId":callbackId, @"responseData":responseData };
                    [self p_queueMessage:msg];
                };
            } else {
                responseCallback = ^(id ignoreResponseData) { /* Do nothing */ };
            }
            
            AGXBridgeHandler handler = _messageHandlers[message[@"handlerName"]];
            if (!handler) {
                AGXLog(@"AGXWebViewJavascriptBridge NoHandlerException, No handler for message from JS: %@", message);
                continue;
            }
            
            handler(message[@"data"], responseCallback);
        }
    }
}

- (void)p_queueMessage:(AGXBridgeMessage *)message {
    if (_startupMessageQueue) [_startupMessageQueue addObject:message];
    else [self p_dispatchMessage:message];
}

- (void)p_dispatchMessage:(AGXBridgeMessage *)message {
    NSString *messageJSON = [self p_serializeMessage:message pretty:NO];
    [self p_log:@"SEND" json:messageJSON];
    messageJSON = [messageJSON stringByReplacingOccurrencesOfString:@"\\" withString:@"\\\\"];
    messageJSON = [messageJSON stringByReplacingOccurrencesOfString:@"\"" withString:@"\\\""];
    messageJSON = [messageJSON stringByReplacingOccurrencesOfString:@"\'" withString:@"\\\'"];
    messageJSON = [messageJSON stringByReplacingOccurrencesOfString:@"\n" withString:@"\\n"];
    messageJSON = [messageJSON stringByReplacingOccurrencesOfString:@"\r" withString:@"\\r"];
    messageJSON = [messageJSON stringByReplacingOccurrencesOfString:@"\f" withString:@"\\f"];
    messageJSON = [messageJSON stringByReplacingOccurrencesOfString:@"\u2028" withString:@"\\u2028"];
    messageJSON = [messageJSON stringByReplacingOccurrencesOfString:@"\u2029" withString:@"\\u2029"];
    
    NSString *javascriptCommand = [NSString stringWithFormat:@"AGXBridge._handleMessageFromObjC('%@');", messageJSON];
    if ([[NSThread currentThread] isMainThread]) [_delegate evaluateJavascript:javascriptCommand];
    else agx_async_main([_delegate evaluateJavascript:javascriptCommand];);
}

- (NSString *)p_serializeMessage:(id)message pretty:(BOOL)pretty{
    return AGX_AUTORELEASE([[NSString alloc] initWithData:[NSJSONSerialization dataWithJSONObject:message options:(NSJSONWritingOptions)(pretty ? NSJSONWritingPrettyPrinted : 0) error:nil] encoding:NSUTF8StringEncoding]);
}

- (NSArray *)p_deserializeMessageJSON:(NSString *)messageJSON {
    return [NSJSONSerialization JSONObjectWithData:[messageJSON dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingAllowFragments error:nil];
}

- (void)p_log:(NSString *)action json:(id)json {
    if (!logging) return;
    if (![json isKindOfClass:[NSString class]]) {
        json = [self p_serializeMessage:json pretty:YES];
    }
    if ([json length] > logMaxLength) {
        AGXLog(@"AGXWebViewJavascriptBridge %@: %@ [...]", action, [json substringToIndex:logMaxLength]);
    } else {
        AGXLog(@"AGXWebViewJavascriptBridge %@: %@", action, json);
    }
}

#pragma mark - logging setting

static bool logging = false;
static int logMaxLength = 500;
+ (void)enableLogging { logging = true; }
+ (void)setLogMaxLength:(int)length { logMaxLength = length;}

@end
