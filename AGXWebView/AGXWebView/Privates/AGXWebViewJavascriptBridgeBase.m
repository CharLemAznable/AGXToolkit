//
//  AGXWebViewJavascriptBridgeBase.m
//  AGXWebView
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

#import "AGXWebViewJavascriptBridgeBase.h"
#import "AGXWebViewJavascriptBridgeJS.h"
#import <AGXCore/AGXCore/AGXObjC.h>

#define agxkCustomProtocolScheme    @"agxscheme"
#define agxkQueueHasMessage         @"__AGX_QUEUE_MESSAGE__"
#define agxkBridgeLoaded            @"__BRIDGE_LOADED__"

typedef NSDictionary AGXBridgeMessage;

@implementation AGXWebViewJavascriptBridgeBase {
    long _uniqueId;
}

- (AGX_INSTANCETYPE)init {
    if (AGX_EXPECT_T(self = [super init])) {
        _startupMessageQueue = [[NSMutableArray alloc] init];
        _responseCallbacks = [[NSMutableDictionary alloc] init];
        _messageHandlers = [[NSMutableDictionary alloc] init];
        _uniqueId = 0;
    }
    return self;
}

- (void)dealloc {
    AGX_RELEASE(_startupMessageQueue);
    _startupMessageQueue = nil;
    AGX_RELEASE(_responseCallbacks);
    _responseCallbacks = nil;
    AGX_RELEASE(_messageHandlers);
    _messageHandlers = nil;
    _delegate = nil;
    AGX_SUPER_DEALLOC;
}

static bool logging = false;
static int logMaxLength = 500;
+ (void)enableLogging { logging = true; }
+ (void)setLogMaxLength:(int)length { logMaxLength = length;}

- (void)reset {
    self.startupMessageQueue = [NSMutableArray array];
    self.responseCallbacks = [NSMutableDictionary dictionary];
    _uniqueId = 0;
}

- (void)sendData:(id)data responseCallback:(AGXBridgeResponseCallback)responseCallback handlerName:(NSString *)handlerName {
    NSMutableDictionary *message = [NSMutableDictionary dictionary];
    
    if (data) message[@"data"] = data;
    if (responseCallback) {
        NSString* callbackId = [NSString stringWithFormat:@"objc_cb_%ld", ++_uniqueId];
        _responseCallbacks[callbackId] = AGX_AUTORELEASE([responseCallback copy]);
        message[@"callbackId"] = callbackId;
    }
    if (handlerName) message[@"handlerName"] = handlerName;
    
    [self _queueMessage:message];
}

- (void)flushMessageQueue:(NSString *)messageQueueString{
    if (messageQueueString == nil || messageQueueString.length == 0) {
        AGXLog(@"AGXWebViewJavascriptBridge: WARNING: ObjC got nil while fetching the message queue JSON from webview. This can happen if the AGXWebViewJavascriptBridge JS is not currently present in the webview, e.g if the webview just loaded a new page.");
        return;
    }
    
    id messages = [self _deserializeMessageJSON:messageQueueString];
    for (AGXBridgeMessage* message in messages) {
        if (![message isKindOfClass:[AGXBridgeMessage class]]) {
            AGXLog(@"AGXWebViewJavascriptBridge: WARNING: Invalid %@ received: %@", [message class], message);
            continue;
        }
        [self _log:@"RCVD" json:message];
        
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
                    [self _queueMessage:msg];
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

- (void)injectSetupJavascript {
    NSString *js = AGXWebViewJavascriptBridgeSetupJavascript();
    [self _evaluateJavascript:js];
}

- (void)injectLoadedJavascript {
    NSString *js = AGXWebViewJavascriptBridgeLoadedJavascript();
    [self _evaluateJavascript:js];
    if (_startupMessageQueue) {
        NSArray* queue = AGX_RETAIN(_startupMessageQueue);
        self.startupMessageQueue = nil;
        for (id queuedMessage in queue) {
            [self _dispatchMessage:queuedMessage];
        }
        AGX_RELEASE(queue);
    }
}

- (void)injectCallersJavascript {
    NSString *js = AGXWebViewJavascriptBridgeCallersJavascript(_messageHandlers.allKeys);
    [self _evaluateJavascript:js];
}

- (BOOL)isCorrectProcotocolScheme:(NSURL *)url {
    return [[url scheme] isEqualToString:agxkCustomProtocolScheme];
}

- (BOOL)isQueueMessageURL:(NSURL *)url {
    return [[url host] isEqualToString:agxkQueueHasMessage];
}

- (BOOL)isBridgeLoadedURL:(NSURL *)url {
    return [[url scheme] isEqualToString:agxkCustomProtocolScheme] && [[url host] isEqualToString:agxkBridgeLoaded];
}

- (void)logUnkownMessage:(NSURL *)url {
    AGXLog(@"AGXWebViewJavascriptBridge: WARNING: Received unknown AGXWebViewJavascriptBridge command %@://%@",
           agxkCustomProtocolScheme, [url path]);
}

- (NSString *)agxWebViewJavascriptCheckCommand {
    return @"typeof AGXBridge == \'object\';";
}

- (NSString *)agxWebViewJavascriptFetchQueueCommand {
    return @"AGXBridge._fetchQueue();";
}

#pragma mark - Private methods

- (void)_evaluateJavascript:(NSString *)javascriptCommand {
    [_delegate _evaluateJavascript:javascriptCommand];
}

- (void)_queueMessage:(AGXBridgeMessage *)message {
    if (_startupMessageQueue) [_startupMessageQueue addObject:message];
    else [self _dispatchMessage:message];
}

- (void)_dispatchMessage:(AGXBridgeMessage *)message {
    NSString *messageJSON = [self _serializeMessage:message pretty:NO];
    [self _log:@"SEND" json:messageJSON];
    messageJSON = [messageJSON stringByReplacingOccurrencesOfString:@"\\" withString:@"\\\\"];
    messageJSON = [messageJSON stringByReplacingOccurrencesOfString:@"\"" withString:@"\\\""];
    messageJSON = [messageJSON stringByReplacingOccurrencesOfString:@"\'" withString:@"\\\'"];
    messageJSON = [messageJSON stringByReplacingOccurrencesOfString:@"\n" withString:@"\\n"];
    messageJSON = [messageJSON stringByReplacingOccurrencesOfString:@"\r" withString:@"\\r"];
    messageJSON = [messageJSON stringByReplacingOccurrencesOfString:@"\f" withString:@"\\f"];
    messageJSON = [messageJSON stringByReplacingOccurrencesOfString:@"\u2028" withString:@"\\u2028"];
    messageJSON = [messageJSON stringByReplacingOccurrencesOfString:@"\u2029" withString:@"\\u2029"];
    
    NSString *javascriptCommand = [NSString stringWithFormat:@"AGXBridge._handleMessageFromObjC('%@');", messageJSON];
    if ([[NSThread currentThread] isMainThread]) [self _evaluateJavascript:javascriptCommand];
    else dispatch_sync(dispatch_get_main_queue(), ^{ [self _evaluateJavascript:javascriptCommand]; });
}

- (NSString *)_serializeMessage:(id)message pretty:(BOOL)pretty{
    return AGX_AUTORELEASE([[NSString alloc] initWithData:[NSJSONSerialization dataWithJSONObject:message options:(NSJSONWritingOptions)(pretty ? NSJSONWritingPrettyPrinted : 0) error:nil] encoding:NSUTF8StringEncoding]);
}

- (NSArray *)_deserializeMessageJSON:(NSString *)messageJSON {
    return [NSJSONSerialization JSONObjectWithData:[messageJSON dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingAllowFragments error:nil];
}

- (void)_log:(NSString *)action json:(id)json {
    if (!logging) return;
    if (![json isKindOfClass:[NSString class]]) {
        json = [self _serializeMessage:json pretty:YES];
    }
    if ([json length] > logMaxLength) {
        AGXLog(@"AGXWebViewJavascriptBridge %@: %@ [...]", action, [json substringToIndex:logMaxLength]);
    } else {
        AGXLog(@"AGXWebViewJavascriptBridge %@: %@", action, json);
    }
}

@end
