//
//  AGXWebViewController.h
//  AGXWebView
//
//  Created by Char Aznable on 16/3/6.
//  Copyright © 2016年 AI-CUC-EC. All rights reserved.
//

#import "AGXWebView.h"
#import <AGXCore/AGXCore/AGXArc.h>

@interface AGXWebViewController : UIViewController <UIWebViewDelegate>
@property(nonatomic, AGX_STRONG) AGXWebView *view;

- (void)registerHandlerName:(NSString *)handlerName withSelector:(SEL)selector;
@end
