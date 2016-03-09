//
//  AGXWebViewController.h
//  AGXWidget
//
//  Created by Char Aznable on 16/3/6.
//  Copyright © 2016年 AI-CUC-EC. All rights reserved.
//

#ifndef AGXWidget_AGXWebViewController_h
#define AGXWidget_AGXWebViewController_h

#import "AGXWebView.h"
#import <AGXCore/AGXCore/AGXArc.h>

@interface AGXWebViewController : UIViewController <UIWebViewDelegate>
@property(nonatomic, AGX_STRONG) AGXWebView *view;

- (void)registerHandlerName:(NSString *)handlerName handler:(id)handler selector:(SEL)selector;
- (SEL)registerTriggerAt:(Class)triggerClass withBlock:(AGXBridgeTrigger)triggerBlock;
- (SEL)registerTriggerAt:(Class)triggerClass withJavascript:(NSString *)javascript;
@end

#endif /* AGXWidget_AGXWebViewController_h */
