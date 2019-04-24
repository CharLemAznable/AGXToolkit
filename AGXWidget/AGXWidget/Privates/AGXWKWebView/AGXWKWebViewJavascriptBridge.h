//
//  AGXWKWebViewJavascriptBridge.h
//  AGXWidget
//
//  Created by Char Aznable on 2019/4/17.
//  Copyright © 2019 github.com/CharLemAznable. All rights reserved.
//

#ifndef AGXWidget_AGXWKWebViewJavascriptBridge_h
#define AGXWidget_AGXWKWebViewJavascriptBridge_h

#import <WebKit/WKUserScript.h>
#import "AGXWKScriptMessageHandler.h"

@interface AGXWKWebViewJavascriptBridge : AGXWKScriptMessageHandler
- (void)registerHandlerName:(NSString *)handlerName block:(void (^)(id data))block;
- (void)registerHandlerName:(NSString *)handlerName target:(id)target action:(SEL)action;
- (void)registerHandlerName:(NSString *)handlerName block:(void (^)(id data))block scope:(NSString *)scope;
- (void)registerHandlerName:(NSString *)handlerName target:(id)target action:(SEL)action scope:(NSString *)scope;

- (WKUserScript *)wrapperUserScript;
@end

#endif /* AGXWidget_AGXWKWebViewJavascriptBridge_h */
