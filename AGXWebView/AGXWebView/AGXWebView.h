//
//  AGXWebView.h
//  AGXWebView
//
//  Created by Char Aznable on 16/3/4.
//  Copyright © 2016年 AI-CUC-EC. All rights reserved.
//

#ifndef AGXWebView_AGXWebView_h
#define AGXWebView_AGXWebView_h

#import <UIKit/UIKit.h>
#import <AGXCore/AGXCore/AGXObjC.h>

typedef void (^AGXBridgeTrigger)(id SELF, id sender);

AGX_EXTERN NSString *InjectJSObjectName;
AGX_EXTERN NSString *AutoRegisterMethodNamePrefix;

@interface AGXWebView : UIWebView
- (void)registerHandlerName:(NSString *)handlerName handler:(id)handler selector:(SEL)selector;
- (SEL)registerTriggerWithBlock:(AGXBridgeTrigger)triggerBlock;
- (SEL)registerTriggerWithJavascript:(NSString *)javascript;
@end

#endif /* AGXWebView_AGXWebView_h */
