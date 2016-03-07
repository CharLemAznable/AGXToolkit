//
//  AGXWebViewController.m
//  AGXWebView
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
                                  [handler registerHandlerName:handlerName withSelector:selector];
                              });
    self.navigationItem.leftItemsSupplementBackButton = YES;
}

- (void)registerHandlerName:(NSString *)handlerName withSelector:(SEL)selector {
    [self.view registerHandlerName:handlerName withSelector:selector];
}

- (void)bridge_setTitle:(NSString *)title {
    self.navigationItem.title = title;
}

- (void)bridge_setLeftTitle:(NSString *)leftTitle {
    self.navigationItem.leftBarButtonItem =
    [[UIBarButtonItem alloc] initWithTitle:leftTitle?:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
}

- (void)bridge_setRightTitle:(NSString *)rightTitle {
    self.navigationItem.rightBarButtonItem =
    [[UIBarButtonItem alloc] initWithTitle:rightTitle?:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
}

- (void)bridge_setBackTitle:(NSString *)backTitle {
    self.navigationItem.backBarButtonItem =
    [[UIBarButtonItem alloc] initWithTitle:backTitle?:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
}

#pragma mark - UIWebViewDelegate

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    self.navigationItem.title = [self.view stringByEvaluatingJavaScriptFromString:@"document.title"];
}

@end
