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
#import <AGXCore/AGXCore/AGXObjC.h>
#import <AGXCore/AGXCore/AGXArc.h>
#import <AGXCore/AGXCore/NSString+AGXCore.h>
#import <AGXRuntime/AGXRuntime.h>

@implementation AGXWebViewJavascriptBridge {
    AGXWebViewJavascriptBridgeBase *_base;
}

+ (void)enableLogging { [AGXWebViewJavascriptBridgeBase enableLogging]; }
+ (void)setLogMaxLength:(int)length { [AGXWebViewJavascriptBridgeBase setLogMaxLength:length]; }

- (AGX_INSTANCETYPE)init {
    if (AGX_EXPECT_T(self = [super init])) {
        _base = [[AGXWebViewJavascriptBridgeBase alloc] init];
        _base.delegate = self;
        _embedJavascript = YES;
    }
    return self;
}

- (void)setWebView:(UIWebView *)webView {
    _webView = webView;
    _webView.delegate = self;
}

- (void)dealloc {
    AGX_RELEASE(_base);
    _base = nil;
    _webView.delegate = nil;
    _webView = nil;
    _delegate = nil;
    AGX_SUPER_DEALLOC;
}

- (void)registerHandler:(NSString *)handlerName handler:(AGXBridgeHandler)handler {
    _base.messageHandlers[handlerName] = AGX_AUTORELEASE([handler copy]);
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
    [_base sendData:data responseCallback:responseCallback handlerName:handlerName];
}

#pragma mark - AGXWebViewJavascriptBridgeBaseDelegate

- (NSString *)_evaluateJavascript:(NSString *)javascriptCommand {
    return [_webView stringByEvaluatingJavaScriptFromString:javascriptCommand];
}

#pragma mark - UIWebViewDelegate

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    if (webView != _webView) return YES;
    
    if (_embedJavascript) [_base injectCallersJavascript];
    NSURL *url = [request URL];
    if ([_base isCorrectProcotocolScheme:url]) {
        if ([_base isBridgeLoadedURL:url]) {
            if (_embedJavascript) [_base injectLoadedJavascript];
        } else if ([_base isQueueMessageURL:url]) {
            NSString *messageQueueString = [self _evaluateJavascript:[_base agxWebViewJavascriptFetchQueueCommand]];
            [_base flushMessageQueue:messageQueueString];
        } else {
            [_base logUnkownMessage:url];
        }
        return NO;
    } else if ([_delegate respondsToSelector:@selector(webView:shouldStartLoadWithRequest:navigationType:)]) {
        return [_delegate webView:webView shouldStartLoadWithRequest:request navigationType:navigationType];
    }
    return YES;
}

- (void)webViewDidStartLoad:(UIWebView *)webView {
    if (webView != _webView) return;
    if ([_delegate respondsToSelector:@selector(webViewDidStartLoad:)])
        [_delegate webViewDidStartLoad:webView];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    if (webView != _webView) return;
    if (_embedJavascript) [_base injectSetupJavascript];
    if ([_delegate respondsToSelector:@selector(webViewDidFinishLoad:)])
        [_delegate webViewDidFinishLoad:webView];
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
    if (webView != _webView) return;
    if ([_delegate respondsToSelector:@selector(webView:didFailLoadWithError:)])
        [_delegate webView:webView didFailLoadWithError:error];
}

@end
