//
//  AGXWKWebViewErrorBridge.h
//  AGXWidget
//
//  Created by Char Aznable on 2019/4/21.
//  Copyright © 2019 github.com/CharLemAznable. All rights reserved.
//

#ifndef AGXWidget_AGXWKWebViewErrorBridge_h
#define AGXWidget_AGXWKWebViewErrorBridge_h

#import <WebKit/WKUserScript.h>
#import "AGXWKScriptMessageHandler.h"

@interface AGXWKWebViewErrorBridge : AGXWKScriptMessageHandler
- (void)registerErrorHandlerBlock:(void (^)(NSString *message, NSArray *stack))block;
- (void)registerErrorHandlerTarget:(id)target action:(SEL)action;

- (WKUserScript *)wrapperUserScript;
@end

#endif /* AGXWidget_AGXWKWebViewErrorBridge_h */
