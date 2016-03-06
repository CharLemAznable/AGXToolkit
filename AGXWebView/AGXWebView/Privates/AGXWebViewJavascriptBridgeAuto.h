//
//  AGXWebViewJavascriptBridgeAutoRegister.h
//  AGXWebView
//
//  Created by Char Aznable on 16/3/6.
//  Copyright © 2016年 AI-CUC-EC. All rights reserved.
//

#ifndef AGXWebView_AGXWebViewJavascriptBridgeAuto_h
#define AGXWebView_AGXWebViewJavascriptBridgeAuto_h

#import <Foundation/Foundation.h>

typedef void (^AGXHandlerRegisterBlock)(id handler, SEL selector, NSString *handlerName);

void AutoRegisterBridgeHandler(id obj, Class rootClass, AGXHandlerRegisterBlock block);
NSString *HandlerMethodSignature(id handler, SEL selector);

#endif /* AGXWebView_AGXWebViewJavascriptBridgeAuto_h */
