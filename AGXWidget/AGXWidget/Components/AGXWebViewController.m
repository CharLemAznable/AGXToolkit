//
//  AGXWebViewController.m
//  AGXWidget
//
//  Created by Char Aznable on 16/3/6.
//  Copyright © 2016年 AI-CUC-EC. All rights reserved.
//

#import "AGXWebViewController.h"
#import "AGXWebViewJavascriptBridgeAuto.h"
#import <objc/runtime.h>
#import <AGXCore/AGXCore/AGXAdapt.h>
#import <AGXCore/AGXCore/AGXBundle.h>
#import <AGXCore/AGXCore/NSString+AGXCore.h>
#import <AGXCore/AGXCore/UIColor+AGXCore.h>
#import <AGXCore/AGXCore/UINavigationBar+AGXCore.h>
#import <AGXCore/AGXCore/UIViewController+AGXCore.h>
#import <AGXCore/AGXCore/UINavigationController+AGXCore.h>

@implementation AGXWebViewController

@dynamic view;

- (AGX_INSTANCETYPE)init {
    if (self = [super init]) {
        _useDocumentTitle = YES;
    }
    return self;
}

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
    
    [self p_fixNavigationBarHeight];
    [self p_fixStatusBarStyle];
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
    [self p_fixNavigationBarHeight];
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
    BOOL hidden = setting[@"hide"] ? [setting[@"hide"] boolValue] : !self.navigationBarHidden;
    BOOL animate = setting[@"animate"] ? [setting[@"animate"] boolValue] : YES;
    [self setNavigationBarHidden:hidden animated:animate];
    [self p_fixStatusBarStyle];
}

NSString *AGXLocalResourceBundleName = nil;

- (void)bridge_pushWebView:(NSDictionary *)setting {
    if (!setting[@"url"] && !setting[@"file"]) return;
    BOOL animate = setting[@"animate"] ? [setting[@"animate"] boolValue] : YES;
    
    AGXWebViewController *viewController;
    if (setting[@"type"]) {
        Class clz = objc_getClass([setting[@"type"] UTF8String]);
        if (AGX_EXPECT_F(![clz isSubclassOfClass:[AGXWebViewController class]])) return;
        viewController = AGX_AUTORELEASE([[clz alloc] init]);
    } else viewController = AGX_AUTORELEASE([[[self class] alloc] init]);
    
    [self pushViewController:viewController animated:animate
            initialWithBlock:
     ^(UIViewController *viewController) {
         if (setting[@"hideNav"]) viewController.navigationBarHidden = [setting[@"hideNav"] boolValue];
         
         if (![viewController.view isKindOfClass:[AGXWebView class]]) return;
         AGXWebView *view = (AGXWebView *)viewController.view;
         if (setting[@"url"]) {
             [view loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:setting[@"url"]]]];
             
         } else if (setting[@"file"]) {
             NSString *bundlePath = [[AGXBundle appBundle] resourcePath];
             if (AGXLocalResourceBundleName)
                 bundlePath = [bundlePath stringByAppendingPathComponent:
                               [NSString stringWithFormat:@"%@.bundle", AGXLocalResourceBundleName]];
             NSString *filePath = [bundlePath stringByAppendingPathComponent:setting[@"file"]];
             
             [view loadHTMLString:[NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:nil]
                          baseURL:[NSURL fileURLWithPath:filePath]];
         }
     } completionWithBlock:NULL];
}

- (void)bridge_popOut:(NSDictionary *)setting {
    BOOL animate = setting[@"animate"] ? [setting[@"animate"] boolValue] : YES;
    [self popViewControllerAnimated:animate];
}

#pragma mark - UIWebViewDelegate

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    if (_useDocumentTitle) self.navigationItem.title
        = [self.view stringByEvaluatingJavaScriptFromString:@"document.title"];
    
    [self p_fixNavigationBarHeight];
    [self p_fixStatusBarStyle];
}

#pragma mark - private methods

- (void)p_fixNavigationBarHeight {
    // fix navigation bar height
    if (self.navigationBarHidden) return;
    [self setNavigationBarHidden:YES animated:YES];
    [self setNavigationBarHidden:NO animated:YES];
}

- (void)p_fixStatusBarStyle {
    UIColor *backgroundColor = self.navigationBarHidden ? self.view.backgroundColor
    : (self.navigationBar.currentBackgroundColor ?: self.navigationBar.barTintColor);
    if ([backgroundColor colorShade] == AGXColorShadeUnmeasured) return;
    self.statusBarStyle = [backgroundColor colorShade] == AGXColorShadeLight ?
    AGXStatusBarStyleDefault : AGXStatusBarStyleLightContent;
}

@end
