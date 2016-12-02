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

AGX_EXTERN NSString *AGXLocalResourceBundleName;

@interface AGXWebViewController : UIViewController <UIWebViewDelegate>
@property (nonatomic, AGX_STRONG) AGXWebView *view;
@property (nonatomic, assign)     BOOL        useDocumentTitle; // default YES
@property (nonatomic, assign)     BOOL        goBackOnBackBarButton; // default YES
@property (nonatomic, assign)     BOOL        autoAddCloseBarButton; // default YES
@property (nonatomic, AGX_STRONG) NSString   *closeBarButtonTitle; // default @"关闭"
@property (nonatomic, assign)     BOOL        goBackOnPopGesture; // default YES
@property (nonatomic, assign)     CGFloat     goBackPopPercent; // [0.1, 0.9] default 0.5

- (void)registerHandlerName:(NSString *)handlerName handler:(id)handler selector:(SEL)selector;
- (SEL)registerTriggerAt:(Class)triggerClass withBlock:(AGXBridgeTrigger)triggerBlock;
- (SEL)registerTriggerAt:(Class)triggerClass withJavascript:(NSString *)javascript;
- (SEL)registerTriggerAt:(Class)triggerClass withJavascript:(NSString *)javascript javascriptParamKey:(NSString *)key;

- (Class)defaultPushViewControllerClass; // used when bridge-pushing view controller.
// some adjustment in delegate, override with super called first.
- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType;
- (void)webViewDidFinishLoad:(UIWebView *)webView;

#pragma mark - UINavigationController bridge handler
- (void)setTitle:(NSString *)title;
- (void)setPrompt:(NSString *)prompt;
- (void)setBackTitle:(NSString *)backTitle;
- (void)setChildBackTitle:(NSString *)childBackTitle;
- (void)setLeftButton:(NSDictionary *)setting; // { "title/system":string, "callback":jsfunction } re.:README
- (void)setRightButton:(NSDictionary *)setting; // { "title/system":string, "callback":jsfunction } re.:README
- (void)toggleNavigationBar:(NSDictionary *)setting; // { "hide":bool, "animate":bool }
- (void)pushIn:(NSDictionary *)setting; // { "url/file":url string, "animate":bool, "hideNav":bool, "type":ClassName string }
- (void)popOut:(NSDictionary *)setting; //{ "count":int, "animate":bool }
@end

#endif /* AGXWidget_AGXWebViewController_h */
