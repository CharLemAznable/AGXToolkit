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
#import <AGXCore/AGXCore/AGXObjC.h>
#import <AGXCore/AGXCore/AGXArc.h>

AGX_EXTERN NSString *AGXLocalResourceBundleName;

@interface AGXWebViewController : UIViewController <UIWebViewDelegate>
@property (nonatomic, AGX_STRONG) AGXWebView *view;
@property (nonatomic, assign)     BOOL        useDocumentTitle; // default YES

- (void)registerHandlerName:(NSString *)handlerName handler:(id)handler selector:(SEL)selector;
- (SEL)registerTriggerAt:(Class)triggerClass withBlock:(AGXBridgeTrigger)triggerBlock;
- (SEL)registerTriggerAt:(Class)triggerClass withJavascript:(NSString *)javascript;

- (void)webViewDidFinishLoad:(UIWebView *)webView; // some adjustment in delegate, override with [super webViewDidFinishLoad:] called first.
@end

#endif /* AGXWidget_AGXWebViewController_h */
