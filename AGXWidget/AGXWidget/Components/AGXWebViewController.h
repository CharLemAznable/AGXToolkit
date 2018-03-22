//
//  AGXWebViewController.h
//  AGXWidget
//
//  Created by Char Aznable on 2016/3/6.
//  Copyright © 2016年 AI-CUC-EC. All rights reserved.
//

#ifndef AGXWidget_AGXWebViewController_h
#define AGXWidget_AGXWebViewController_h

#import "AGXWebView.h"

@interface AGXWebViewController : UIViewController <UIWebViewDelegate>
@property (nonatomic, AGX_STRONG) AGXWebView *view;
@property (nonatomic, assign)     BOOL        useDocumentTitle; // default YES
@property (nonatomic, assign)     BOOL        goBackOnBackBarButton; // default YES
@property (nonatomic, assign)     BOOL        autoAddCloseBarButton; // default YES
@property (nonatomic, assign)     BOOL        goBackOnPopGesture; // default YES
@property (nonatomic, assign)     CGFloat     goBackPopPercent; // [0.1, 0.9] default 0.5

// initialize a AGXWebViewController by parse-able URLString
+ (AGX_INSTANCETYPE)webViewControllerWithURLString:(NSString *)URLString;
+ (Class)URLStringParserClass; // kind of AGXWebViewControllerURLStringParser

// some adjustment in delegate, override with super called first.
- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType;
- (void)webViewDidStartLoad:(UIWebView *)webView;
- (void)webViewDidFinishLoad:(UIWebView *)webView;
- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error;

#pragma mark - UINavigationController bridge handler
/* declaration&implementation in super class
- (void)setTitle:(NSString *)title;*/
- (void)setPrompt:(NSString *)prompt;
- (void)setBackTitle:(NSString *)backTitle;
- (void)setChildBackTitle:(NSString *)childBackTitle;
- (void)setLeftButton:(NSDictionary *)setting; // { "title/system":string, "callback":jsfunction } re.:README
- (void)setRightButton:(NSDictionary *)setting; // { "title/system":string, "callback":jsfunction } re.:README
- (void)toggleNavigationBar:(NSDictionary *)setting; // { "hide":bool, "animate":bool }
- (void)pushIn:(NSDictionary *)setting; // { "class":native UIViewController class name string, "url":url string, "animate":bool, "type":native AGXWebViewController class name string }
- (void)popOut:(NSDictionary *)setting; //{ "count":int, "animate":bool }
@end

@interface AGXWebViewControllerURLStringParser : NSObject
- (Class)webViewControllerClassWithURLString:(NSString *)URLString;
- (void)webViewController:(AGXWebViewController *)webViewController settingWithURLString:(NSString *)URLString;
- (NSArray *)requestAttachedCookieNamesWithURLString:(NSString *)URLString;
- (NSString *)localResourceBundleNameWithURLString:(NSString *)URLString;
- (void)webViewController:(AGXWebViewController *)webViewController loadRequestWithURLString:(NSString *)URLString;
@end

#endif /* AGXWidget_AGXWebViewController_h */
