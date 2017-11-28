//
//  AGXWebView.h
//  AGXWidget
//
//  Created by Char Aznable on 16/3/4.
//  Copyright © 2016年 AI-CUC-EC. All rights reserved.
//

#ifndef AGXWidget_AGXWebView_h
#define AGXWidget_AGXWebView_h

#import <UIKit/UIKit.h>
#import <AGXCore/AGXCore/AGXArc.h>
#import "AGXWebViewLogLevel.h"

AGX_EXTERN NSString *AGXBridgeInjectJSObjectName;   // AGXB

@interface AGXWebView : UIWebView
@property (nonatomic, assign)       BOOL        coordinateBackgroundColor; // default YES

@property (nonatomic, AGX_STRONG)   UIColor     *progressColor UI_APPEARANCE_SELECTOR; // default (22, 126, 251, 255)
+ (UIColor *)progressColor;
+ (void)setProgressColor:(UIColor *)progressColor;

@property (nonatomic, assign)       CGFloat     progressWidth UI_APPEARANCE_SELECTOR; // default 2
+ (CGFloat)progressWidth;
+ (void)setProgressWidth:(CGFloat)progressWidth;

@property (nonatomic, readonly)     NSURLRequest*currentRequest;

// called in sub Thread
- (void)registerHandlerName:(NSString *)handlerName target:(id)target action:(SEL)action;
- (void)registerHandlerName:(NSString *)handlerName target:(id)target action:(SEL)action scope:(NSString *)scope;

// called in main Thread
// handler selector should have the form:
// - (void)xxx:(NSString *)message xxx:(NSArray *)stack
- (void)registerErrorHandlerTarget:(id)target action:(SEL)action;

@property (nonatomic, assign) AGXWebViewLogLevel javascriptLogLevel;
// called in main Thread
// handler selector should have the form:
// - (void)xxx:(AGXWebViewLogLevel)level xxx:(NSArray *)content xxx:(NSArray *)stack
- (void)registerLogHandlerTarget:(id)target action:(SEL)action;

- (SEL)registerTriggerAt:(Class)triggerClass withBlock:(void (^)(id SELF, id sender))triggerBlock;
- (SEL)registerTriggerAt:(Class)triggerClass withJavascript:(NSString *)javascript;
- (SEL)registerTriggerAt:(Class)triggerClass withJavascript:(NSString *)javascript paramKeyPath:(NSString *)paramKeyPath, ... NS_REQUIRES_NIL_TERMINATION;
- (SEL)registerTriggerAt:(Class)triggerClass withJavascript:(NSString *)javascript paramKeyPaths:(NSArray *)paramKeyPaths;

#pragma mark - UIWebView bridge handler
/* declaration&implementation in super class
- (void)reload;
- (void)stopLoading;
- (void)goBack;
- (void)goForward;
- (BOOL)canGoBack;
- (BOOL)canGoForward;
- (BOOL)isLoading; */
- (void)scaleFit;
- (void)setBounces:(BOOL)bounces;
- (void)setBounceHorizontal:(BOOL)bounceHorizontal;
- (void)setBounceVertical:(BOOL)bounceVertical;
- (void)setShowHorizontalScrollBar:(BOOL)showHorizontalScrollBar;
- (void)setShowVerticalScrollBar:(BOOL)showVerticalScrollBar;
- (void)scrollToTop:(BOOL)animated;
- (void)scrollToBottom:(BOOL)animated;

#pragma mark - UIAlertController bridge handler
- (void)alert:(NSDictionary *)setting; // { "style":string, "title":string, "message":string, "button":string, "callback":jsfunction }
- (void)confirm:(NSDictionary *)setting; // { "style":string, "title":string, "message":string, "cancelButton":string, "cancelCallback":jsfunction, "confirmButton":string, "confirmCallback":jsfunction }

#pragma mark - ProgressHUD bridge handler
- (void)HUDMessage:(NSDictionary *)setting; // { "title":string, "message":string, "delay":float, "fullScreen":bool, "opaque":bool }
- (void)HUDLoading:(NSDictionary *)setting; // { "title":string, "message":string, "fullScreen":bool, "opaque":bool }
- (void)HUDLoaded;

#pragma mark - PhotosAlbum bridge handler
- (void)saveImageToAlbum:(NSDictionary *)params; // { "url":string, "savingTitle":string, "successTitle":string, "failedTitle":string, "savingCallback":jsfunction, "failedCallback":jsfunction('reason'), "successCallback":jsfunction }
- (void)loadImageFromAlbum:(NSDictionary *)params; // { "editable":bool, "callback":jsfunction, "title":string, "message":string, "button":string }
- (void)loadImageFromCamera:(NSDictionary *)params; // { "editable":bool, "callback":jsfunction, "title":string, "message":string, "button":string }
- (void)loadImageFromAlbumOrCamera:(NSDictionary *)params; // { "editable":bool, "callback":jsfunction, "title":string, "message":string, "button":string, "cancelButton":string, "albumButton":string, "cameraButton":string }
- (void)setInputFileMenuOptionFilter:(NSString *)inputFileMenuOptionFilter; // filter <input type="file"> presenting UIDocumentMenuViewController menu options by title, seperate by "|"

#pragma mark - Captcha image handler
- (NSString *)captchaImageURLString:(NSDictionary *)params; // { "width":int, "height":float, "length":float, "type":string }
- (BOOL)verifyCaptchaCode:(NSString *)inputCode;

#pragma mark - Watermarked image handler
- (NSString *)watermarkedImageURLString:(NSDictionary *)params; // { "url":string, "image":string, "text":string, "direction":int(0..7), "offsetX":float, "offsetY":float, "color":hexString, "fontName":string, "fontSize":float }

#pragma mark - QRCode reader bridge handler (need include <AGXGcode/AGXGcode/AGXGcodeReader.h>)
- (NSString *)recogniseQRCode:(NSString *)imageURLString;
@end

#endif /* AGXWidget_AGXWebView_h */
