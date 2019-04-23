//
//  AGXWKWebViewController.h
//  AGXWidget
//
//  Created by Char on 2019/4/17.
//  Copyright © 2019 github.com/CharLemAznable. All rights reserved.
//

#ifndef AGXWidget_AGXWKWebViewController_h
#define AGXWidget_AGXWKWebViewController_h

#import "AGXWKWebView.h"

@interface AGXWKWebViewController : UIViewController <WKNavigationDelegate>
@property (nonatomic, AGX_STRONG)   AGXWKWebView   *view;
@property (nonatomic, assign)       BOOL            useDocumentTitle; // default YES
@property (nonatomic, assign)       BOOL            goBackOnBackBarButton; // default YES
@property (nonatomic, assign)       BOOL            autoAddCloseBarButton; // default YES
@property (nonatomic, assign)       BOOL            goBackOnPopGesture; // default YES
@property (nonatomic, assign)       CGFloat         goBackPopPercent; // [0.1, 0.9] default 0.5

// initialize a AGXWKWebViewController by parse-able URLString
+ (AGX_INSTANCETYPE)webViewControllerWithURLString:(NSString *)URLString;
+ (Class)URLStringParserClass; // kind of AGXWKWebViewControllerURLStringParser

#pragma mark - UINavigationController bridge handler
- (void)setNavigationTitle:(NSString *)title;
- (void)setPrompt:(NSString *)prompt;
- (void)setBackTitle:(NSString *)backTitle;
- (void)setChildBackTitle:(NSString *)childBackTitle;
- (void)setLeftButton:(NSDictionary *)setting; // { "title/system":string, "callback":jsfunction } re.:README
- (void)setRightButton:(NSDictionary *)setting; // { "title/system":string, "callback":jsfunction } re.:README
- (void)toggleNavigationBar:(NSDictionary *)setting; // { "hide":bool, "animate":bool }
- (void)pushIn:(NSDictionary *)setting; // { "class":native UIViewController class name string, "url":url string, "animate":bool, "type":native AGXWebViewController class name string }
- (void)popOut:(NSDictionary *)setting; //{ "count":int, "animate":bool }

#pragma mark - UIAlertController bridge handler
- (void)alert:(NSDictionary *)setting; // { "style":string, "title":string, "message":string, "button":string, "callback":jsfunction }
- (void)confirm:(NSDictionary *)setting; // { "style":string, "title":string, "message":string, "cancelButton":string, "cancelCallback":jsfunction, "confirmButton":string, "confirmCallback":jsfunction }

#pragma mark - PhotosAlbum bridge handler
- (void)saveImageToAlbum:(NSDictionary *)params; // { "url":string, "savingTitle":string, "successTitle":string, "failedTitle":string, "savingCallback":jsfunction, "failedCallback":jsfunction('reason'), "successCallback":jsfunction }
- (void)loadImageFromAlbum:(NSDictionary *)params; // { "editable":bool, "callback":jsfunction, "title":string, "message":string, "button":string }
- (void)loadImageFromCamera:(NSDictionary *)params; // { "editable":bool, "callback":jsfunction, "title":string, "message":string, "button":string }
- (void)loadImageFromAlbumOrCamera:(NSDictionary *)params; // { "editable":bool, "callback":jsfunction, "title":string, "message":string, "button":string, "cancelButton":string, "albumButton":string, "cameraButton":string }
- (void)setInputFileMenuOptionFilter:(NSString *)inputFileMenuOptionFilter; // filter <input type="file"> presenting UIDocumentMenuViewController menu options by title, seperate by "|"
@end

@interface AGXWKWebViewControllerURLStringParser : NSObject
- (id)parametricObjectWithURLString:(NSString *)URLString;
- (Class)webViewControllerClassWithURLString:(NSString *)URLString;
- (void)webViewController:(AGXWKWebViewController *)webViewController settingWithURLString:(NSString *)URLString;
- (NSURLRequestCachePolicy)requestCachePolicyWithURLString:(NSString *)URLString;
- (NSArray *)requestAttachedCookieNamesWithURLString:(NSString *)URLString;
- (NSDictionary *)requestAttachedHTTPHeaderFieldsWithURLString:(NSString *)URLString;
- (NSString *)localResourceBundleNameWithURLString:(NSString *)URLString;
- (void)webViewController:(AGXWKWebViewController *)webViewController loadRequestWithURLString:(NSString *)URLString;
@end

#endif /* AGXWidget_AGXWKWebViewController_h */
