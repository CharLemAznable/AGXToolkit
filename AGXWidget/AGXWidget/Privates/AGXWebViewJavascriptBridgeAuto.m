//
//  AGXWebViewJavascriptBridgeAuto.m
//  AGXWidget
//
//  Created by Char Aznable on 16/3/6.
//  Copyright © 2016年 AI-CUC-EC. All rights reserved.
//

#import "AGXWebViewJavascriptBridgeAuto.h"
#import <AGXCore/AGXCore/NSString+AGXCore.h>
#import <AGXRuntime/AGXRuntime.h>

NSString *AutoRegisterMethodNamePrefix = @"bridge_";

void AutoRegisterBridgeHandler(id obj, Class rootClass, AGXHandlerRegisterBlock block) {
    Class currentClass = [obj class];
    while (true) {
        [currentClass enumerateAGXInstanceMethodsWithBlock:^(AGXMethod *method) {
            if (![method.selectorName hasPrefix:AutoRegisterMethodNamePrefix]) return;
            block(obj, method.selector, [[method.selectorName substringFromIndex:AutoRegisterMethodNamePrefix.length]
                                         stringByReplacingString:@":" withString:@""]);
        }];
        if (![currentClass isSubclassOfClass:rootClass]) break;
        currentClass = [currentClass superclass];
    }
}
