//
//  AGXWebView.m
//  AGXWidget
//
//  Created by Char Aznable on 2016/3/4.
//  Copyright © 2016年 AI-CUC-EC. All rights reserved.
//

#import <AssetsLibrary/AssetsLibrary.h>
#import <AVFoundation/AVCaptureDevice.h>
#import <AVFoundation/AVMediaFormat.h>
#import <AGXCore/AGXCore/AGXAdapt.h>
#import <AGXCore/AGXCore/NSObject+AGXCore.h>
#import <AGXCore/AGXCore/NSData+AGXCore.h>
#import <AGXCore/AGXCore/NSString+AGXCore.h>
#import <AGXCore/AGXCore/NSArray+AGXCore.h>
#import <AGXCore/AGXCore/NSDate+AGXCore.h>
#import <AGXCore/AGXCore/UIDevice+AGXCore.h>
#import <AGXCore/AGXCore/UIApplication+AGXCore.h>
#import <AGXCore/AGXCore/UIView+AGXCore.h>
#import <AGXCore/AGXCore/UIImage+AGXCore.h>
#import <AGXCore/AGXCore/UIActionSheet+AGXCore.h>
#import <AGXCore/AGXCore/UIAlertView+AGXCore.h>
#import <AGXCore/AGXCore/UIScrollView+AGXCore.h>
#import <AGXJson/AGXJson.h>
#import "AGXWidgetLocalization.h"
#import "AGXProgressBar.h"
#import "AGXProgressHUD.h"
#import "AGXImagePickerController.h"
#import "AGXWebViewInternalDelegate.h"
#import "UIDocumentMenuViewController+AGXWidget.h"
#import "AGXWebViewConsole.h"

static long uniqueId = 0;

@interface AGXWebView () <UIActionSheetDelegate, AGXImagePickerControllerDelegate, AGXWebViewConsoleDelegate>
@end

@implementation AGXWebView {
    AGXWebViewInternalDelegate *_webViewInternalDelegate;

    AGXProgressBar *_progressBar;
    CGFloat _progressWidth;

    AGXWebViewConsole *_console;

    NSString *_captchaCode;
}

static NSHashTable *agxWebViews = nil;
+ (AGX_INSTANCETYPE)allocWithZone:(struct _NSZone *)zone {
    agx_once(agxWebViews = AGX_RETAIN([NSHashTable weakObjectsHashTable]);)
    NSAssert(NSThread.isMainThread, @"should on the main thread");
    id alloc = [super allocWithZone:zone];
    [agxWebViews addObject:alloc];
    return alloc;
}

- (void)agxInitial {
    [super agxInitial];
    self.backgroundColor = UIColor.whiteColor;

    _webViewInternalDelegate = [[AGXWebViewInternalDelegate alloc] init];
    _webViewInternalDelegate.webView = self;
    agx_async_main(self.delegate = _webViewInternalDelegate;) // accessor thread conflict

    _progressBar = [[AGXProgressBar alloc] init];
    [self addSubview:_progressBar];

    _progressWidth = 2;

    _captchaCode = nil;

    super.webViewDidChangeAdjustedContentInset
    = ^(UIWebView *webView) { [webView setNeedsLayout]; };

#define REGISTER(HANDLER, SELECTOR)                     \
[_webViewInternalDelegate.bridge registerHandlerName:   \
@HANDLER target:self action:@selector(SELECTOR)]

    REGISTER("reload", reload);
    REGISTER("stopLoading", stopLoading);
    REGISTER("goBack", goBack);
    REGISTER("goForward", goForward);
    REGISTER("canGoBack", canGoBack);
    REGISTER("canGoForward", canGoForward);
    REGISTER("isLoading", isLoading);

    REGISTER("scaleFit", scaleFit);
    REGISTER("setBounces", setBounces:);
    REGISTER("setBounceHorizontal", setBounceHorizontal:);
    REGISTER("setBounceVertical", setBounceVertical:);
    REGISTER("setShowHorizontalScrollBar", setShowHorizontalScrollBar:);
    REGISTER("setShowVerticalScrollBar", setShowVerticalScrollBar:);
    REGISTER("scrollToTop", scrollToTop:);
    REGISTER("scrollToBottom", scrollToBottom:);

    REGISTER("alert", alert:);
    REGISTER("confirm", confirm:);

    REGISTER("HUDMessage", HUDMessage:);
    REGISTER("HUDLoading", HUDLoading:);
    REGISTER("HUDLoaded", HUDLoaded);

    REGISTER("saveImageToAlbum", saveImageToAlbum:);
    REGISTER("loadImageFromAlbum", loadImageFromAlbum:);
    REGISTER("loadImageFromCamera", loadImageFromCamera:);
    REGISTER("loadImageFromAlbumOrCamera", loadImageFromAlbumOrCamera:);
    REGISTER("setInputFileMenuOptionFilter", setInputFileMenuOptionFilter:);

    REGISTER("captchaImageURLString", captchaImageURLString:);
    REGISTER("verifyCaptchaCode", verifyCaptchaCode:);

    REGISTER("watermarkedImageURLString", watermarkedImageURLString:);

    REGISTER("recogniseQRCode", recogniseQRCode:);

#undef REGISTER

    [_webViewInternalDelegate.bridge registerErrorHandlerTarget:
     self action:@selector(internalHandleErrorMessage:stack:)];
    [_webViewInternalDelegate.bridge registerLogHandlerTarget:
     self action:@selector(internalHandleLogLevel:content:stack:)];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    [self bringSubviewToFront:_progressBar];
    _progressBar.frame = CGRectMake(0, self.scrollView.contentInsetAdjusted.top,
                                    self.bounds.size.width, _progressWidth);
    [self bringSubviewToFront:_console];
    _console.frame = UIEdgeInsetsInsetRect(self.scrollView.frame,
                                           self.scrollView.contentInsetAdjusted);
}

- (void)dealloc {
    AGX_RELEASE(_captchaCode);
    AGX_RELEASE(_console);
    AGX_RELEASE(_progressBar);
    AGX_RELEASE(_webViewInternalDelegate);
    AGX_SUPER_DEALLOC;
}

- (BOOL)autoCoordinateBackgroundColor {
    return _webViewInternalDelegate.extension.autoCoordinateBackgroundColor;
}

- (void)setAutoCoordinateBackgroundColor:(BOOL)autoCoordinateBackgroundColor {
    _webViewInternalDelegate.extension.autoCoordinateBackgroundColor = autoCoordinateBackgroundColor;
}

- (BOOL)autoRevealCurrentLocationHost {
    return _webViewInternalDelegate.extension.autoRevealCurrentLocationHost;
}

- (void)setAutoRevealCurrentLocationHost:(BOOL)autoRevealCurrentLocationHost {
    _webViewInternalDelegate.extension.autoRevealCurrentLocationHost = autoRevealCurrentLocationHost;
}

- (NSString *)currentLocationHostRevealFormat {
    return _webViewInternalDelegate.extension.currentLocationHostRevealFormat;
}

- (void)setCurrentLocationHostRevealFormat:(NSString *)currentLocationHostRevealFormat {
    _webViewInternalDelegate.extension.currentLocationHostRevealFormat = currentLocationHostRevealFormat;
}

- (UIColor *)progressColor {
    return _progressBar.progressColor;
}

- (void)setProgressColor:(UIColor *)progressColor {
    _progressBar.progressColor = progressColor;
}

+ (UIColor *)progressColor {
    return [[self appearance] progressColor];
}

+ (void)setProgressColor:(UIColor *)progressColor {
    [[self appearance] setProgressColor:progressColor];
}

- (CGFloat)progressWidth {
    return _progressWidth;
}

- (void)setProgressWidth:(CGFloat)progressWidth {
    _progressWidth = progressWidth;
    [self setNeedsLayout];
}

+ (CGFloat)progressWidth {
    return [[self appearance] progressWidth];
}

+ (void)setProgressWidth:(CGFloat)progressWidth {
    [[self appearance] setProgressWidth:progressWidth];
}

- (NSURLRequest *)currentRequest {
    return _webViewInternalDelegate.progress.currentRequest;
}

- (void)registerHandlerName:(NSString *)handlerName target:(id)target action:(SEL)action {
    [_webViewInternalDelegate.bridge registerHandlerName:handlerName target:target action:action];
}

- (void)registerHandlerName:(NSString *)handlerName target:(id)target action:(SEL)action scope:(NSString *)scope {
    [_webViewInternalDelegate.bridge registerHandlerName:handlerName target:target action:action scope:scope];
}

- (void)registerErrorHandlerTarget:(id)target action:(SEL)action {
    [_webViewInternalDelegate.bridge registerErrorHandlerTarget:target action:action];
}

- (void)setShowLogConsole:(BOOL)showLogConsole {
    _showLogConsole = showLogConsole;

    if (_showLogConsole) {
        if (!_console) {
            _console = [[AGXWebViewConsole alloc] initWithLogLevel:
                        _webViewInternalDelegate.bridge.javascriptLogLevel];
            _console.delegate = self;
        }
        [self addSubview:_console];
    } else {
        [_console removeFromSuperview];
        if (_console) {
            AGX_RELEASE(_console);
            _console = nil;
        }
    }
    [self setNeedsLayout];
}

+ (BOOL)showLogConsole {
    return [[self appearance] showLogConsole];
}

+ (void)setShowLogConsole:(BOOL)showLogConsole {
    [[self appearance] setShowLogConsole:showLogConsole];
}

// AGXWebViewConsoleDelegate
- (void)webViewConsole:(AGXWebViewConsole *)console didSelectSegmentIndex:(NSInteger)index {
    if AGX_EXPECT_F(console != _console) return;
    _webViewInternalDelegate.bridge.javascriptLogLevel = index;
}

- (AGXWebViewLogLevel)javascriptLogLevel {
    return _webViewInternalDelegate.bridge.javascriptLogLevel;
}

- (void)setJavascriptLogLevel:(AGXWebViewLogLevel)javascriptLogLevel {
    _webViewInternalDelegate.bridge.javascriptLogLevel = javascriptLogLevel;
    _console.javascriptLogLevel = javascriptLogLevel;
}

+ (AGXWebViewLogLevel)javascriptLogLevel {
    return [[self appearance] javascriptLogLevel];
}

+ (void)setJavascriptLogLevel:(AGXWebViewLogLevel)javascriptLogLevel {
    [[self appearance] setJavascriptLogLevel:javascriptLogLevel];
}

- (void)registerLogHandlerTarget:(id)target action:(SEL)action {
    [_webViewInternalDelegate.bridge registerLogHandlerTarget:target action:action];
}

- (SEL)registerTriggerAt:(Class)triggerClass withBlock:(void (^)(id SELF, id sender))triggerBlock {
    SEL selector = NSSelectorFromString([NSString stringWithFormat:@"trigger_%ld:", ++uniqueId]);
    [triggerClass addInstanceMethodWithSelector:selector andBlock:triggerBlock andTypeEncoding:"v@:@"];
    return selector;
}

- (SEL)registerTriggerAt:(Class)triggerClass withJavascript:(NSString *)javascript {
    __AGX_WEAK_RETAIN AGXWebView *__webView = self;
    return [self registerTriggerAt:triggerClass withBlock:^(id SELF, id sender) {
        [__webView stringByEvaluatingJavaScriptFromString:
         [NSString stringWithFormat:@";(%@)();", javascript]];
    }];
}

- (SEL)registerTriggerAt:(Class)triggerClass withJavascript:(NSString *)javascript paramKeyPath:(NSString *)paramKeyPath, ... NS_REQUIRES_NIL_TERMINATION {
    return [self registerTriggerAt:triggerClass withJavascript:javascript paramKeyPaths:agx_va_list(paramKeyPath)];
}

- (SEL)registerTriggerAt:(Class)triggerClass withJavascript:(NSString *)javascript paramKeyPaths:(NSArray *)paramKeyPaths {
    __AGX_WEAK_RETAIN AGXWebView *__webView = self;
    return [self registerTriggerAt:triggerClass withBlock:^(id SELF, id sender) {
        NSMutableArray *paramValues = [NSMutableArray array];
        for (int i = 0; i < paramKeyPaths.count; i++) {
            NSString *keyPath = paramKeyPaths[i];
            if AGX_EXPECT_F(0 == keyPath.length) { [paramValues addObject:@"undefined"]; continue; }
            [paramValues addObject:[[SELF valueForKeyPath:keyPath] agxJsonString] ?: @"undefined"];
        }
        [__webView stringByEvaluatingJavaScriptFromString:
         [NSString stringWithFormat:@";(%@)(%@);", javascript,
          [paramValues stringJoinedByString:@"," usingComparator:NULL filterEmpty:NO]]];
    }];
}

#pragma mark - UIWebView bridge handler

- (void)scaleFit {
    self.scalesPageToFit = YES;
}

- (void)setBounces:(BOOL)bounces {
    agx_async_main(self.scrollView.bounces = bounces;)
}

- (void)setBounceHorizontal:(BOOL)bounceHorizontal {
    agx_async_main
    (if (bounceHorizontal) self.scrollView.bounces = YES;
     self.scrollView.alwaysBounceHorizontal = bounceHorizontal;)
}

- (void)setBounceVertical:(BOOL)bounceVertical {
    agx_async_main
    (if (bounceVertical) self.scrollView.bounces = YES;
     self.scrollView.alwaysBounceHorizontal = bounceVertical;)
}

- (void)setShowHorizontalScrollBar:(BOOL)showHorizontalScrollBar {
    agx_async_main
    (self.scrollView.showsHorizontalScrollIndicator = showHorizontalScrollBar;)
}

- (void)setShowVerticalScrollBar:(BOOL)showVerticalScrollBar {
    agx_async_main
    (self.scrollView.showsVerticalScrollIndicator = showVerticalScrollBar;)
}

- (void)scrollToTop:(BOOL)animated {
    agx_async_main([self.scrollView scrollToTop:animated];)
}

- (void)scrollToBottom:(BOOL)animated {
    agx_async_main([self.scrollView scrollToBottom:animated];)
}

#pragma mark - UIAlertController bridge handler

- (void)alert:(NSDictionary *)setting {
    SEL callback = [self registerTriggerAt:self.class withJavascript:setting[@"callback"]?:@"function(){}"];

    agx_async_main
    (UIAlertController *controller = [self p_alertControllerWithTitle:
                                      setting[@"title"] message:setting[@"message"] style:setting[@"style"]];
     [self p_alertController:controller addActionWithTitle:
      setting[@"button"]?:AGXWidgetLocalizedStringDefault(@"AGXWebView.alert.cancel", @"Cancel")
                       style:UIAlertActionStyleCancel selector:callback];
     [UIApplication.sharedRootViewController presentViewController:controller animated:YES completion:NULL];)
}

- (void)confirm:(NSDictionary *)setting {
    SEL cancel = [self registerTriggerAt:self.class withJavascript:setting[@"cancelCallback"]?:@"function(){}"];
    SEL confirm = [self registerTriggerAt:self.class withJavascript:setting[@"confirmCallback"]?:@"function(){}"];

    agx_async_main
    (UIAlertController *controller = [self p_alertControllerWithTitle:
                                      setting[@"title"] message:setting[@"message"] style:setting[@"style"]];
     [self p_alertController:controller addActionWithTitle:
      setting[@"cancelButton"]?:AGXWidgetLocalizedStringDefault(@"AGXWebView.confirm.cancel", @"Cancel")
                       style:UIAlertActionStyleCancel selector:cancel];
     [self p_alertController:controller addActionWithTitle:
      setting[@"confirmButton"]?:AGXWidgetLocalizedStringDefault(@"AGXWebView.confirm.ok", @"OK")
                       style:UIAlertActionStyleDefault selector:confirm];
     [UIApplication.sharedRootViewController presentViewController:controller animated:YES completion:NULL];)
}

#pragma mark - private methods: UIAlertController

- (UIAlertController *)p_alertControllerWithTitle:(NSString *)title message:(NSString *)message style:(NSString *)style {
    return [UIAlertController alertControllerWithTitle:title message:message
                                        preferredStyle:[style isCaseInsensitiveEqualToString:@"sheet"] ?
                     UIAlertControllerStyleActionSheet:UIAlertControllerStyleAlert];
}

- (void)p_alertController:(UIAlertController *)controller addActionWithTitle:(NSString *)title style:(UIAlertActionStyle)style selector:(SEL)selector {
    [controller addAction:[UIAlertAction actionWithTitle:title style:style handler:^(UIAlertAction *alertAction)
                           { [self performAGXSelector:selector withObject:nil]; }]];
}

#pragma mark - ProgressHUD bridge handler

- (void)HUDMessage:(NSDictionary *)setting {
    NSString *title = setting[@"title"], *message = setting[@"message"];
    if AGX_EXPECT_F(AGXIsNilOrEmpty(title) && AGXIsNilOrEmpty(message)) return;
    NSTimeInterval delay = setting[@"delay"] ? [setting[@"delay"] timeIntervalValue] : 2;
    BOOL fullScreen = setting[@"fullScreen"] ? [setting[@"fullScreen"] boolValue] : NO;
    BOOL opaque = setting[@"opaque"] ? [setting[@"opaque"] boolValue] : YES;
    UIView *view = fullScreen ? UIApplication.sharedKeyWindow : self;
    agx_async_main([view showMessageHUD:opaque title:title detail:message duration:delay];)
}

- (void)HUDLoading:(NSDictionary *)setting {
    NSString *title = setting[@"title"], *message = setting[@"message"];
    BOOL fullScreen = setting[@"fullScreen"] ? [setting[@"fullScreen"] boolValue] : NO;
    BOOL opaque = setting[@"opaque"] ? [setting[@"opaque"] boolValue] : YES;
    UIView *view = fullScreen ? UIApplication.sharedKeyWindow : self;
    agx_async_main([view showLoadingHUD:opaque title:title detail:message];)
}

- (void)HUDLoaded {
    agx_async_main([UIApplication.sharedKeyWindow hideRecursiveHUD];)
}

#pragma mark - PhotosAlbum bridge handler

NSString *const AGXSaveImageToAlbumParamsKey = @"AGXSaveImageToAlbumParams";

- (void)saveImageToAlbum:(NSDictionary *)params {
    if (params[@"savingCallback"]) {
        agx_async_main(([self stringByEvaluatingJavaScriptFromString:
                         [NSString stringWithFormat:@";(%@)();",
                          params[@"savingCallback"]]]);)
    } else {
        agx_async_main([self showLoadingHUD:YES title:
                        params[@"savingTitle"]?:AGXWidgetLocalizedStringDefault
                        (@"AGXWebView.saveImage.saving", @"Saving")];)
    }

    UIImage *image = [UIImage imageWithURLString:params[@"url"]];
    if AGX_EXPECT_F(!image) {
        if (params[@"failedCallback"]) {
            agx_async_main(([self stringByEvaluatingJavaScriptFromString:
                             [NSString stringWithFormat:@";(%@)('Can not fetch image DATA');",
                              params[@"failedCallback"]]]);)
        } else {
            agx_async_main([self showMessageHUD:YES title:
                            params[@"failedTitle"]?:AGXWidgetLocalizedStringDefault
                            (@"AGXWebView.saveImage.failed", @"Failed") duration:2];)
        }
        return;
    }

    [image setRetainProperty:params forAssociateKey:AGXSaveImageToAlbumParamsKey];
    UIImageWriteToSavedPhotosAlbum(image, self, @selector(image:didFinishSavingWithError:contextInfo:), nil);
}

// UIImageWriteToSavedPhotosAlbum completionSelector
- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo {
    NSDictionary *params = [image retainPropertyForAssociateKey:AGXSaveImageToAlbumParamsKey];
    if (error) {
        if (params[@"failedCallback"]) {
            agx_async_main(([self stringByEvaluatingJavaScriptFromString:
                             [NSString stringWithFormat:@";(%@)('%@');",
                              params[@"failedCallback"], error.localizedDescription]]);)
        } else {
            agx_async_main([self showMessageHUD:YES title:params[@"failedTitle"]?:AGXWidgetLocalizedStringDefault
                            (@"AGXWebView.saveImage.failed", @"Failed") detail:error.localizedDescription duration:2];)
        }
    } else {
        if (params[@"successCallback"]) {
            agx_async_main(([self stringByEvaluatingJavaScriptFromString:
                             [NSString stringWithFormat:@";(%@)();",
                              params[@"successCallback"]]]);)
        } else {
            agx_async_main([self showMessageHUD:YES title:params[@"successTitle"]?:AGXWidgetLocalizedStringDefault
                            (@"AGXWebView.saveImage.success", @"Success") duration:2];)
        }
    }
    [image setRetainProperty:NULL forAssociateKey:AGXSaveImageToAlbumParamsKey];
}

NSString *const AGXLoadImageCallbackKey = @"AGXLoadImageCallback";

- (void)loadImageFromAlbum:(NSDictionary *)params {
    ALAuthorizationStatus status = [ALAssetsLibrary authorizationStatus];
    if (ALAuthorizationStatusRestricted == status || ALAuthorizationStatusDenied == status) {
        [self p_alertNoneAuthorizationTitle:params[@"title"]?:
         AGXWidgetLocalizedStringDefault(@"AGXWebView.loadImage.failed", @"Failed")
                                    message:params[@"message"]?:
         AGXWidgetLocalizedStringDefault(@"AGXWebView.loadImage.unauthorizedPhotoLibrary", @"No permission to access Photo Library")
                               settingTitle:params[@"setting"]?:
         AGXWidgetLocalizedStringDefault(@"AGXWebView.loadImage.setting", @"Setting")
                                cancelTitle:params[@"button"]?:
         AGXWidgetLocalizedStringDefault(@"AGXWebView.loadImage.fine", @"OK")];
        return;
    }
    [self p_showImagePickerController:AGXImagePickerController.album withParams:params];
}

- (void)loadImageFromCamera:(NSDictionary *)params {
    AVAuthorizationStatus status = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    if (AVAuthorizationStatusRestricted == status || AVAuthorizationStatusDenied == status) {
        [self p_alertNoneAuthorizationTitle:params[@"title"]?:
         AGXWidgetLocalizedStringDefault(@"AGXWebView.loadImage.failed", @"Failed")
                                    message:params[@"message"]?:
         AGXWidgetLocalizedStringDefault(@"AGXWebView.loadImage.unauthorizedCamera", @"No permission to access Camera")
                               settingTitle:params[@"setting"]?:
         AGXWidgetLocalizedStringDefault(@"AGXWebView.loadImage.setting", @"Setting")
                                cancelTitle:params[@"button"]?:
         AGXWidgetLocalizedStringDefault(@"AGXWebView.loadImage.fine", @"OK")];
        return;
    }
    [self p_showImagePickerController:AGXImagePickerController.camera withParams:params];
}

- (void)loadImageFromAlbumOrCamera:(NSDictionary *)params {
    agx_async_main
    (UIAlertController *controller = [UIAlertController alertControllerWithTitle:nil message:nil
                                                                  preferredStyle:UIAlertControllerStyleActionSheet];
     [controller addAction:
      [UIAlertAction actionWithTitle:params[@"cancelButton"]?:
       AGXWidgetLocalizedStringDefault(@"AGXWebView.loadImage.cancel", @"Cancel")
                               style:UIAlertActionStyleCancel handler:^(UIAlertAction *alertAction) {}]];
     [controller addAction:
      [UIAlertAction actionWithTitle:params[@"albumButton"]?:
       AGXWidgetLocalizedStringDefault(@"AGXWebView.loadImage.album", @"Album")
                               style:UIAlertActionStyleDefault handler:^(UIAlertAction *alertAction) { [self loadImageFromAlbum:params]; }]];
     [controller addAction:
      [UIAlertAction actionWithTitle:params[@"cameraButton"]?:
       AGXWidgetLocalizedStringDefault(@"AGXWebView.loadImage.camera", @"Camera")
                               style:UIAlertActionStyleDefault handler:^(UIAlertAction *alertAction) { [self loadImageFromCamera:params]; }]];
     [UIApplication.sharedRootViewController presentViewController:controller animated:YES completion:NULL];)
}

// AGXImagePickerControllerDelegate
- (void)imagePickerController:(AGXImagePickerController *)picker didFinishPickingImage:(UIImage *)image {
    NSString *callbackJSString = [picker retainPropertyForAssociateKey:AGXLoadImageCallbackKey];
    if (!callbackJSString) return;
    [self stringByEvaluatingJavaScriptFromString:
     [NSString stringWithFormat:@";(%@)('data:image/png;base64,%@');",
      callbackJSString, UIImagePNGRepresentation(image).base64EncodedString]];
    [picker setRetainProperty:NULL forAssociateKey:AGXLoadImageCallbackKey];
}

- (void)setInputFileMenuOptionFilter:(NSString *)inputFileMenuOptionFilter {
    [UIDocumentMenuViewController setMenuOptionFilter:inputFileMenuOptionFilter];
}

#pragma mark - private methods: PhotosAlbum

- (void)p_alertNoneAuthorizationTitle:(NSString *)title message:(NSString *)message settingTitle:(NSString *)settingTitle cancelTitle:(NSString *)cancelTitle {
    agx_async_main
    (UIAlertController *controller = [UIAlertController alertControllerWithTitle:title message:message
                                                                  preferredStyle:UIAlertControllerStyleAlert];
     [controller addAction:[UIAlertAction actionWithTitle:cancelTitle style:UIAlertActionStyleCancel handler:NULL]];
     if (UIApplication.canOpenApplicationSetting) {
         [controller addAction:[UIAlertAction actionWithTitle:settingTitle style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) { [UIApplication openApplicationSetting]; }]];
     }
     [UIApplication.sharedRootViewController presentViewController:controller animated:YES completion:NULL];)
}

- (void)p_showImagePickerController:(AGXImagePickerController *)imagePicker withParams:(NSDictionary *)params {
    if (params[@"editable"]) imagePicker.allowsEditing = [params[@"editable"] boolValue];
    if (params[@"callback"]) {
        imagePicker.imagePickerDelegate = self;
        [imagePicker setRetainProperty:params[@"callback"] forAssociateKey:AGXLoadImageCallbackKey];
    }
    agx_async_main([imagePicker presentAnimated:YES completion:NULL];)
}

#pragma mark - Captcha image handler

- (NSString *)captchaImageURLString:(NSDictionary *)params {
    if (!params[@"width"] || !params[@"height"]) return nil;

    NSString *type = params[@"type"]?:@"default";
    NSString *(^randomBlock)(int count) = [type isCaseInsensitiveEqualToString:@"digit"] ? AGXRandom.NUM :
    ([type isCaseInsensitiveEqualToString:@"letter"] ? AGXRandom.LETTERS : AGXRandom.ALPHANUMERIC);
    NSString *temp = AGX_RETAIN(randomBlock([params[@"length"] intValue]?:4));
    AGX_RELEASE(_captchaCode);
    _captchaCode = temp;

    UIImage *image = [UIImage captchaImageWithCaptchaCode:_captchaCode size:
                      CGSizeMake([params[@"width"] cgfloatValue], [params[@"height"] cgfloatValue])];
    return [NSString stringWithFormat:@"data:image/png;base64,%@",
            UIImagePNGRepresentation(image).base64EncodedString];
}

- (BOOL)verifyCaptchaCode:(NSString *)inputCode {
    return [_captchaCode isCaseInsensitiveEqualToString:inputCode];
}

#pragma mark - Watermarked image handler

- (NSString *)watermarkedImageURLString:(NSDictionary *)params {
    UIImage *image = [UIImage imageWithURLString:
                      params[@"url"] scale:UIScreen.mainScreen.scale];
    if AGX_EXPECT_F(!image) return nil;

    UIImage *watermarkImage = [UIImage imageWithURLString:
                               params[@"image"] scale:UIScreen.mainScreen.scale];
    NSString *watermarkText = params[@"text"];
    if AGX_EXPECT_F(!watermarkImage && AGXIsNilOrEmpty(watermarkText)) return nil;

    AGXDirection direction = params[@"direction"] ?
    [params[@"direction"] unsignedIntegerValue] : AGXDirectionSouthEast;
    CGVector offset = CGVectorMake([params[@"offsetX"] cgfloatValue],
                                   [params[@"offsetY"] cgfloatValue]);

    UIImage *resultImage = nil;
    if (watermarkImage) {
        resultImage = [UIImage imageBaseOnImage:image watermarkedWithImage:watermarkImage
                                    inDirection:direction withOffset:offset];
    } else {
        NSMutableDictionary *attrs = NSMutableDictionary.instance;
        attrs[NSForegroundColorAttributeName] = AGXColor(params[@"color"]);
        NSString *fontName = AGXIsNotEmpty(params[@"fontName"]) ? params[@"fontName"] : @"HelveticaNeue";
        CGFloat fontSize = params[@"fontSize"] ? [params[@"fontSize"] cgfloatValue] : 12;
        attrs[NSFontAttributeName] = [UIFont fontWithName:fontName size:fontSize];

        resultImage = [UIImage imageBaseOnImage:image watermarkedWithText:watermarkText
                                 withAttributes:attrs inDirection:direction withOffset:offset];
    }

    return [NSString stringWithFormat:@"data:image/png;base64,%@",
            UIImagePNGRepresentation(resultImage).base64EncodedString];
}

#pragma mark - QRCode reader bridge handler

- (NSString *)recogniseQRCode:(NSString *)imageURLString {
    Class hintsClass = NSClassFromString(@"AGXDecodeHints");
    if AGX_EXPECT_F(!hintsClass) { AGXLog(@"recogniseQRCode need include <AGXGcode.framework>"); return nil; }

    Class readerClass = NSClassFromString(@"AGXGcodeReader");
    if AGX_EXPECT_F(!readerClass) { AGXLog(@"recogniseQRCode need include <AGXGcode.framework>"); return nil; }

    UIImage *image = [UIImage imageWithURLString:imageURLString];
    if AGX_EXPECT_F(!image) return nil;

    id hints = hintsClass.instance;
    [hints performAGXSelector:NSSelectorFromString(@"setFormats:") withObject:@[@(9)]]; // kGcodeFormatQRCode = 9

    id reader = readerClass.instance;
    SEL decodeSel = NSSelectorFromString(@"decode:hints:error:");
    NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:[reader methodSignatureForSelector:decodeSel]];
    [invocation setTarget:reader];
    [invocation setSelector:decodeSel];
    [invocation setArgument:&image atIndex:2];
    [invocation setArgument:&hints atIndex:3];
    [invocation invoke];
    id result = nil;
    [invocation getReturnValue:&result];
    return [result text];
}

#pragma mark - bridge error handler

- (void)internalHandleErrorMessage:(NSString *)message stack:(NSArray *)stack {
    [_console addLogLevel:AGXWebViewLogError message:message stack:stack];
}

#pragma mark - bridge log handler

- (void)internalHandleLogLevel:(AGXWebViewLogLevel)level content:(NSArray *)content stack:(NSArray *)stack {
    [_console addLogLevel:level message:content.agxJsonString stack:stack];
}

#pragma mark - override

- (void)setDelegate:(id<UIWebViewDelegate>)delegate {
    if (!delegate || [delegate isKindOfClass:AGXWebViewInternalDelegate.class])  {
        [super setDelegate:delegate];
        return;
    }
    _webViewInternalDelegate.delegate = delegate;
}

- (void)setWebViewDidChangeAdjustedContentInset:(void (^)(UIWebView *))webViewDidChangeAdjustedContentInset {
    super.webViewDidChangeAdjustedContentInset
    = ^(UIWebView *webView) {
        !webViewDidChangeAdjustedContentInset ?: webViewDidChangeAdjustedContentInset(webView);
        [webView setNeedsLayout];
    };
}

#pragma mark - private methods

- (AGXWebViewInternalDelegate *)internal {
    return _webViewInternalDelegate;
}

- (void)setProgress:(float)progress {
    [_progressBar setProgress:progress animated:YES];
}

@end

@category_interface(NSObject, AGXWidgetAGXWebView)
@end
@category_implementation(NSObject, AGXWidgetAGXWebView)
- (void)webView:(id)webView didCreateJavaScriptContext:(JSContext *)ctx forFrame:(id)frame {
    void (^JavaScriptContextBridgeInjection)(void) = ^{
        for (AGXWebView *agxWebView in agxWebViews) {
            NSString *hash = [NSString stringWithFormat:@"agx_jscWebView_%lud", (unsigned long)agxWebView.hash];
            [agxWebView stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"var %@='%@'", hash, hash]];
            if ([ctx[hash].toString isEqualToString:hash]) {
                ctx[@"AGXBridge"] = [agxWebView valueForKeyPath:@"internal.bridge"];
                return;
            }
        }
    };

    if (NSThread.isMainThread) JavaScriptContextBridgeInjection();
    else dispatch_async(dispatch_get_main_queue(), JavaScriptContextBridgeInjection);
}
@end
