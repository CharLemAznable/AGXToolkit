//
//  AGXWKWebViewConsoleBridge.h
//  AGXWidget
//
//  Created by Char on 2019/4/21.
//  Copyright © 2019 github.com/CharLemAznable. All rights reserved.
//

#ifndef AGXWidget_AGXWKWebViewConsoleBridge_h
#define AGXWidget_AGXWKWebViewConsoleBridge_h

#import <WebKit/WKUserScript.h>
#import "AGXWKScriptMessageHandler.h"
#import "AGXWKWebViewLogLevel.h"

@interface AGXWKWebViewConsoleBridge : AGXWKScriptMessageHandler
@property (nonatomic, assign) AGXWKWebViewLogLevel javascriptLogLevel;
- (void)registerLogHandlerBlock:(void (^)(AGXWKWebViewLogLevel level, NSArray *content, NSArray *stack))block;
- (void)registerLogHandlerTarget:(id)target action:(SEL)action;

- (WKUserScript *)wrapperUserScript;
@end

#endif /* AGXWidget_AGXWKWebViewConsoleBridge_h */
