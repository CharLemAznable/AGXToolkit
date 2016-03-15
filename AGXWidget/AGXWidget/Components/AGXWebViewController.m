//
//  AGXWebViewController.m
//  AGXWidget
//
//  Created by Char Aznable on 16/3/6.
//  Copyright © 2016年 AI-CUC-EC. All rights reserved.
//

#import "AGXWebViewController.h"
#import "AGXWebViewJavascriptBridgeAuto.h"
#import <AGXCore/AGXCore/AGXAdapt.h>
#import <AGXCore/AGXCore/AGXBundle.h>
#import <AGXCore/AGXCore/NSString+AGXCore.h>
#import <AGXCore/AGXCore/UIColor+AGXCore.h>
#import <AGXCore/AGXCore/UINavigationBar+AGXCore.h>
#import <AGXCore/AGXCore/UIViewController+AGXCore.h>
#import <AGXCore/AGXCore/UINavigationController+AGXCore.h>

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

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    // fix navigation bar height
    if (self.navigationController && !self.navigationController.navigationBarHidden) {
        [self.navigationController setNavigationBarHidden:YES animated:YES];
        [self.navigationController setNavigationBarHidden:NO animated:YES];
    }
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
    [self.navigationController setNavigationBarHidden:YES animated:YES];
    self.navigationItem.prompt = prompt;
    [self.navigationController setNavigationBarHidden:NO animated:YES];
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

- (void)bridge_toggleNavigationBar:(NSDictionary *)setting {
    [self.navigationController setNavigationBarHidden:[setting[@"hide"] boolValue] animated:[setting[@"animate"] boolValue]];
    
    BOOL hidden = self.navigationController ? self.navigationController.navigationBarHidden : YES;
    UIColor *backgroundColor = hidden ? self.view.backgroundColor : (self.navigationBar.currentBackgroundColor ?: self.navigationBar.barTintColor);
    if ([backgroundColor colorShade] == AGXColorShadeUnmeasured) return;
    self.statusBarStyle = [backgroundColor colorShade] == AGXColorShadeLight ?
    AGXStatusBarStyleDefault : AGXStatusBarStyleLightContent;
}

NSString *AGXLocalResourceBundleName = nil;

- (void)bridge_pushWebView:(NSDictionary *)setting {
    if (!setting[@"url"] && !setting[@"file"]) return;
    
    AGXWebViewController *viewController = AGX_AUTORELEASE([[[self class] alloc] init]);
    [self pushViewController:viewController animated:[setting[@"animate"] boolValue]
            initialWithBlock:
     ^(UIViewController *viewController) {
         if (setting[@"url"]) {
             [((AGXWebView *)viewController.view) loadRequest:
              [NSURLRequest requestWithURL:[NSURL URLWithString:setting[@"url"]]]];
         } else if (setting[@"file"]) {
             NSString *bundlePath = [[AGXBundle appBundle] resourcePath];
             if (AGXLocalResourceBundleName)
                 bundlePath = [bundlePath stringByAppendingPathComponent:
                               [NSString stringWithFormat:@"%@.bundle", AGXLocalResourceBundleName]];
             NSString *filePath = [bundlePath stringByAppendingPathComponent:setting[@"file"]];
             NSString *fileString = [NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:nil];
             [((AGXWebView *)viewController.view) loadHTMLString:fileString baseURL:[NSURL fileURLWithPath:filePath]];
         }
     } completionWithBlock:NULL];
}

- (void)bridge_popOut:(NSDictionary *)setting {
    [self popViewControllerAnimated:[setting[@"animate"] boolValue]];
}

#pragma mark - UIWebViewDelegate

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    self.navigationItem.title = [self.view stringByEvaluatingJavaScriptFromString:@"document.title"];
}

@end
