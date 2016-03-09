//
//  AGXWebViewJavascriptBridgeAuto.h
//  AGXWidget
//
//  Created by Char Aznable on 16/3/6.
//  Copyright © 2016年 AI-CUC-EC. All rights reserved.
//

#ifndef AGXWidget_AGXWebViewJavascriptBridgeAuto_h
#define AGXWidget_AGXWebViewJavascriptBridgeAuto_h

#import <Foundation/Foundation.h>

typedef void (^AGXHandlerRegisterBlock)(id handler, SEL selector, NSString *handlerName);

void AutoRegisterBridgeHandler(id obj, Class rootClass, AGXHandlerRegisterBlock block);

#endif /* AGXWidget_AGXWebViewJavascriptBridgeAuto_h */
