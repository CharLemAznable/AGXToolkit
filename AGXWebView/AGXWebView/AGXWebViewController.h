//
//  AGXWebViewController.h
//  AGXWebView
//
//  Created by Char Aznable on 16/3/6.
//  Copyright © 2016年 AI-CUC-EC. All rights reserved.
//

#ifndef AGXWebView_AGXWebViewController_h
#define AGXWebView_AGXWebViewController_h

#import "AGXWebView.h"
#import <AGXCore/AGXCore/AGXArc.h>

@interface AGXWebViewController : UIViewController <UIWebViewDelegate>
@property(nonatomic, AGX_STRONG) AGXWebView *view;

- (void)registerHandlerName:(NSString *)handlerName handler:(id)handler selector:(SEL)selector;
@end

#endif /* AGXWebView_AGXWebViewController_h */
