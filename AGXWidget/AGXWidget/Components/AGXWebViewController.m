//
//  AGXWebViewController.m
//  AGXWidget
//
//  Created by Char Aznable on 16/3/6.
//  Copyright © 2016年 AI-CUC-EC. All rights reserved.
//

#import "AGXWebViewController.h"
#import "AGXWebViewJavascriptBridgeAuto.h"
#import <AGXCore/AGXCore/NSString+AGXCore.h>
#import <AGXCore/AGXCore/UIViewController+AGXCore.h>

@implementation AGXWebViewController

@dynamic view;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.delegate = self;
    AutoRegisterBridgeHandler(self, [AGXWebViewController class],
                              ^(id handler, SEL selector, NSString *handlerName) {
                                  [handler registerHandlerName:handlerName handler:handler selector:selector];
                              });
    self.navigationItem.leftItemsSupplementBackButton = YES;
}

- (void)registerHandlerName:(NSString *)handlerName handler:(id)handler selector:(SEL)selector {
    [self.view registerHandlerName:handlerName handler:handler selector:selector];
}

- (SEL)registerTriggerAt:(Class)triggerClass withBlock:(AGXBridgeTrigger)triggerBlock {
    return [self.view registerTriggerAt:triggerClass withBlock:triggerBlock];
}

- (SEL)registerTriggerAt:(Class)triggerClass withJavascript:(NSString *)javascript {
    return [self.view registerTriggerAt:triggerClass withJavascript:javascript];
}

#pragma mark - UINavigationController bridge handler

- (void)bridge_setTitle:(NSString *)title {
    self.navigationItem.title = title;
}

- (void)bridge_setPrompt:(NSString *)prompt {
    self.navigationItem.prompt = prompt;
}

- (void)bridge_setBackTitle:(NSString *)backTitle {
    self.navigationItem.backBarButtonItem =
    AGX_AUTORELEASE([[UIBarButtonItem alloc] initWithTitle:backTitle?:@"" style:UIBarButtonItemStylePlain
                                                    target:nil action:nil]);
}

- (void)bridge_setLeftButton:(NSDictionary *)leftButtonSetting {
    NSString *title = leftButtonSetting[@"title"];
    if (!title) { self.navigationItem.leftBarButtonItem = nil; return; }
    
    NSString *callback = leftButtonSetting[@"callback"];
    id target = callback ? self : nil;
    SEL action = callback ? [self registerTriggerAt:[self class] withJavascript:
                             [NSString stringWithFormat:@";(%@)();", callback]] : nil;
    
    self.navigationItem.leftBarButtonItem =
    AGX_AUTORELEASE([[UIBarButtonItem alloc] initWithTitle:title style:UIBarButtonItemStylePlain
                                                    target:target action:action]);
}

- (void)bridge_setRightButton:(NSDictionary *)rightButtonSetting {
    NSString *title = rightButtonSetting[@"title"];
    if (!title) { self.navigationItem.rightBarButtonItem = nil; return; }
    
    NSString *callback = rightButtonSetting[@"callback"];
    id target = callback ? self : nil;
    SEL action = callback ? [self registerTriggerAt:[self class] withJavascript:
                             [NSString stringWithFormat:@";(%@)();", callback]] : nil;
    
    self.navigationItem.rightBarButtonItem =
    AGX_AUTORELEASE([[UIBarButtonItem alloc] initWithTitle:title style:UIBarButtonItemStylePlain
                                                    target:target action:action]);
}

#pragma mark - UIWebViewDelegate

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    self.navigationItem.title = [self.view stringByEvaluatingJavaScriptFromString:@"document.title"];
}

@end
