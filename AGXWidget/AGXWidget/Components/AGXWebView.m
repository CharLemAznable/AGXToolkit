//
//  AGXWebView.m
//  AGXWidget
//
//  Created by Char Aznable on 16/3/4.
//  Copyright © 2016年 AI-CUC-EC. All rights reserved.
//

#import <AssetsLibrary/AssetsLibrary.h>
#import <AVFoundation/AVCaptureDevice.h>
#import <AVFoundation/AVMediaFormat.h>
#import <CoreLocation/CoreLocation.h>
#import <AGXCore/AGXCore/AGXAdapt.h>
#import <AGXCore/AGXCore/NSObject+AGXCore.h>
#import <AGXCore/AGXCore/NSString+AGXCore.h>
#import <AGXCore/AGXCore/NSData+AGXCore.h>
#import <AGXCore/AGXCore/NSDate+AGXCore.h>
#import <AGXCore/AGXCore/UIDevice+AGXCore.h>
#import <AGXCore/AGXCore/UIApplication+AGXCore.h>
#import <AGXCore/AGXCore/UIView+AGXCore.h>
#import <AGXCore/AGXCore/UIImage+AGXCore.h>
#import <AGXCore/AGXCore/UIActionSheet+AGXCore.h>
#import <AGXCore/AGXCore/UIAlertView+AGXCore.h>
#import <AGXJson/AGXJson.h>
#import "AGXProgressBar.h"
#import "AGXProgressHUD.h"
#import "AGXImagePickerController.h"
#import "AGXWebViewInternalDelegate.h"

static long uniqueId = 0;

@interface AGXWebView () <UIActionSheetDelegate, AGXImagePickerControllerDelegate>
@end

@implementation AGXWebView {
    AGXWebViewInternalDelegate *_webViewInternalDelegate;
    AGXProgressBar *_progressBar;
    CGFloat _progressWidth;
}

static NSHashTable *agxWebViews = nil;
+ (AGX_INSTANCETYPE)allocWithZone:(struct _NSZone *)zone {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        agxWebViews = AGX_RETAIN([NSHashTable weakObjectsHashTable]);
    });
    NSAssert([NSThread isMainThread], @"should on the main thread");
    id alloc = [super allocWithZone:zone];
    [agxWebViews addObject:alloc];
    return alloc;
}

- (void)agxInitial {
    [super agxInitial];

    _webViewInternalDelegate = [[AGXWebViewInternalDelegate alloc] init];
    _webViewInternalDelegate.webView = self;
    agx_async_main(self.delegate = _webViewInternalDelegate;) // accessor thread conflict

    _progressBar = [[AGXProgressBar alloc] init];
    [self addSubview:_progressBar];

    _progressWidth = 2;

    [_webViewInternalDelegate.bridge registerHandler:@"reload" handler:self selector:@selector(reload)];
    [_webViewInternalDelegate.bridge registerHandler:@"stopLoading" handler:self selector:@selector(stopLoading)];
    [_webViewInternalDelegate.bridge registerHandler:@"goBack" handler:self selector:@selector(goBack)];
    [_webViewInternalDelegate.bridge registerHandler:@"goForward" handler:self selector:@selector(goForward)];
    [_webViewInternalDelegate.bridge registerHandler:@"canGoBack" handler:self selector:@selector(canGoBack)];
    [_webViewInternalDelegate.bridge registerHandler:@"canGoForward" handler:self selector:@selector(canGoForward)];
    [_webViewInternalDelegate.bridge registerHandler:@"isLoading" handler:self selector:@selector(isLoading)];

    [_webViewInternalDelegate.bridge registerHandler:@"scaleFit" handler:self selector:@selector(scaleFit)];
    [_webViewInternalDelegate.bridge registerHandler:@"setBounces" handler:self selector:@selector(setBounces:)];
    [_webViewInternalDelegate.bridge registerHandler:@"setBounceHorizontal" handler:self selector:@selector(setBounceHorizontal:)];
    [_webViewInternalDelegate.bridge registerHandler:@"setBounceVertical" handler:self selector:@selector(setBounceVertical:)];
    [_webViewInternalDelegate.bridge registerHandler:@"setShowHorizontalScrollBar" handler:self selector:@selector(setShowHorizontalScrollBar:)];
    [_webViewInternalDelegate.bridge registerHandler:@"setShowVerticalScrollBar" handler:self selector:@selector(setShowVerticalScrollBar:)];

    [_webViewInternalDelegate.bridge registerHandler:@"alert" handler:self selector:@selector(alert:)];
    [_webViewInternalDelegate.bridge registerHandler:@"confirm" handler:self selector:@selector(confirm:)];

    [_webViewInternalDelegate.bridge registerHandler:@"HUDMessage" handler:self selector:@selector(HUDMessage:)];
    [_webViewInternalDelegate.bridge registerHandler:@"HUDLoading" handler:self selector:@selector(HUDLoading:)];
    [_webViewInternalDelegate.bridge registerHandler:@"HUDLoaded" handler:self selector:@selector(HUDLoaded)];

    [_webViewInternalDelegate.bridge registerHandler:@"saveImageToAlbum" handler:self selector:@selector(saveImageToAlbum:)];
    [_webViewInternalDelegate.bridge registerHandler:@"loadImageFromAlbum" handler:self selector:@selector(loadImageFromAlbum:)];
    [_webViewInternalDelegate.bridge registerHandler:@"loadImageFromCamera" handler:self selector:@selector(loadImageFromCamera:)];

    [_webViewInternalDelegate.bridge registerHandler:@"recogniseQRCode" handler:self selector:@selector(recogniseQRCode:)];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    [self bringSubviewToFront:_progressBar];
    _progressBar.frame = CGRectMake(0, 0, self.bounds.size.width, _progressWidth);
}

- (void)dealloc {
    AGX_RELEASE(_progressBar);
    AGX_RELEASE(_webViewInternalDelegate);
    AGX_SUPER_DEALLOC;
}

- (BOOL)coordinateBackgroundColor {
    return _webViewInternalDelegate.extension.coordinateBackgroundColor;
}

- (void)setCoordinateBackgroundColor:(BOOL)coordinateBackgroundColor {
    _webViewInternalDelegate.extension.coordinateBackgroundColor = coordinateBackgroundColor;
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

- (void)registerHandlerName:(NSString *)handlerName handler:(id)handler selector:(SEL)selector {
    [_webViewInternalDelegate.bridge registerHandler:handlerName handler:handler selector:selector];
}

- (void)registerHandlerName:(NSString *)handlerName handler:(id)handler selector:(SEL)selector inScope:(NSString *)scope {
    [_webViewInternalDelegate.bridge registerHandler:handlerName handler:handler selector:selector inScope:scope];
}

- (SEL)registerTriggerAt:(Class)triggerClass withBlock:(AGXBridgeTrigger)triggerBlock {
    SEL selector = NSSelectorFromString([NSString stringWithFormat:@"trigger_%ld:", ++uniqueId]);
    [triggerClass addInstanceMethodWithSelector:selector andBlock:triggerBlock andTypeEncoding:"v@:@"];
    return selector;
}

- (SEL)registerTriggerAt:(Class)triggerClass withJavascript:(NSString *)javascript {
    __AGX_BLOCK AGXWebView *__webView = self;
    return [self registerTriggerAt:triggerClass withBlock:^(id SELF, id sender) {
        [__webView stringByEvaluatingJavaScriptFromString:
         [NSString stringWithFormat:@";(%@)();", javascript]];
    }];
}

- (SEL)registerTriggerAt:(Class)triggerClass withJavascript:(NSString *)javascript paramKeyPath:(NSString *)keyPath {
    __AGX_BLOCK AGXWebView *__webView = self;
    return [self registerTriggerAt:triggerClass withBlock:^(id SELF, id sender) {
        id param = [SELF valueForKeyPath:keyPath];
        if (param) {
            AGX_USE_JSONKIT = YES;
            [__webView stringByEvaluatingJavaScriptFromString:
             [NSString stringWithFormat:@";(%@)(%@);", javascript, [param agxJsonString]]];
            AGX_USE_JSONKIT = NO;
        } else {
            [__webView stringByEvaluatingJavaScriptFromString:
             [NSString stringWithFormat:@";(%@)();", javascript]];
        }
    }];
}

#pragma mark - UIWebView bridge handler

- (void)scaleFit {
    self.scalesPageToFit = YES;
}

- (void)setBounces:(BOOL)bounces {
    self.scrollView.bounces = bounces;
}

- (void)setBounceHorizontal:(BOOL)bounceHorizontal {
    if (bounceHorizontal) self.scrollView.bounces = YES;
    self.scrollView.alwaysBounceHorizontal = bounceHorizontal;
}

- (void)setBounceVertical:(BOOL)bounceVertical {
    if (bounceVertical) self.scrollView.bounces = YES;
    self.scrollView.alwaysBounceHorizontal = bounceVertical;
}

- (void)setShowHorizontalScrollBar:(BOOL)showHorizontalScrollBar {
    self.scrollView.showsHorizontalScrollIndicator = showHorizontalScrollBar;
}

- (void)setShowVerticalScrollBar:(BOOL)showVerticalScrollBar {
    self.scrollView.showsVerticalScrollIndicator = showVerticalScrollBar;
}

#pragma mark - UIAlertController bridge handler

- (void)alert:(NSDictionary *)setting {
    SEL callback = [self registerTriggerAt:[self class] withJavascript:setting[@"callback"]?:@"function(){}"];

    UIAlertController *controller = [self p_alertControllerWithTitle:
                                     setting[@"title"] message:setting[@"message"] style:setting[@"style"]];
    [self p_alertController:controller addActionWithTitle:setting[@"button"]?:@"Cancel"
                      style:UIAlertActionStyleCancel selector:callback];
    agx_async_main
    ([UIApplication.sharedRootViewController presentViewController:controller animated:YES completion:NULL];)
}

- (void)confirm:(NSDictionary *)setting {
    SEL cancel = [self registerTriggerAt:[self class] withJavascript:setting[@"cancelCallback"]?:@"function(){}"];
    SEL confirm = [self registerTriggerAt:[self class] withJavascript:setting[@"confirmCallback"]?:@"function(){}"];

    UIAlertController *controller = [self p_alertControllerWithTitle:
                                     setting[@"title"] message:setting[@"message"] style:setting[@"style"]];
    [self p_alertController:controller addActionWithTitle:setting[@"cancelButton"]?:@"Cancel"
                      style:UIAlertActionStyleCancel selector:cancel];
    [self p_alertController:controller addActionWithTitle:setting[@"confirmButton"]?:@"OK"
                      style:UIAlertActionStyleDefault selector:confirm];
    agx_async_main
    ([UIApplication.sharedRootViewController presentViewController:controller animated:YES completion:NULL];)
}

#pragma mark - private methods: UIAlertController

- (UIAlertController *)p_alertControllerWithTitle:(NSString *)title message:(NSString *)message style:(NSString *)style {
    return [UIAlertController alertControllerWithTitle:title message:message
                                        preferredStyle:[style isCaseInsensitiveEqualToString:@"sheet"] ?
                     UIAlertControllerStyleActionSheet:UIAlertControllerStyleAlert];
}

- (void)p_alertController:(UIAlertController *)controller addActionWithTitle:(NSString *)title style:(UIAlertActionStyle)style selector:(SEL)selector {
    [controller addAction:[UIAlertAction actionWithTitle:title style:style handler:^(UIAlertAction *alertAction)
                           { AGX_PerformSelector([self performSelector:selector withObject:nil];) }]];
}

#pragma mark - ProgressHUD bridge handler

- (void)HUDMessage:(NSDictionary *)setting {
    NSString *title = setting[@"title"], *message = setting[@"message"];
    if ((!title || [title isEmpty]) && (!message || [message isEmpty])) return;
    NSTimeInterval delay = setting[@"delay"] ? [setting[@"delay"] timeIntervalValue] : 2;
    BOOL fullScreen = setting[@"fullScreen"] ? [setting[@"fullScreen"] boolValue] : NO;
    BOOL opaque = setting[@"opaque"] ? [setting[@"opaque"] boolValue] : YES;
    UIView *view = fullScreen ? UIApplication.sharedKeyWindow : self;
    agx_async_main([view showMessageHUD:opaque title:title detail:message duration:delay];)
}

- (void)HUDLoading:(NSDictionary *)setting {
    NSString *message = setting[@"message"];
    BOOL fullScreen = setting[@"fullScreen"] ? [setting[@"fullScreen"] boolValue] : NO;
    BOOL opaque = setting[@"opaque"] ? [setting[@"opaque"] boolValue] : YES;
    UIView *view = fullScreen ? UIApplication.sharedKeyWindow : self;
    agx_async_main([view showLoadingHUD:opaque title:message];)
}

- (void)HUDLoaded {
    agx_async_main([UIApplication.sharedKeyWindow hideRecursiveHUD];)
}

#pragma mark - PhotosAlbum bridge handler

NSString *const AGXSaveImageToAlbumParamsKey = @"AGXSaveImageToAlbumParams";

- (void)saveImageToAlbum:(NSDictionary *)params {
    NSString *imageURLString = params[@"url"];
    if (!imageURLString || [imageURLString isEmpty]) return;
    if (params[@"savingCallback"]) {
        [self stringByEvaluatingJavaScriptFromString:
         [NSString stringWithFormat:@";(%@)();", params[@"savingCallback"]]];
    } else {
        agx_async_main([self showLoadingHUD:YES title:params[@"savingTitle"]?:@""];)
    }

    UIImage *image = [UIImage imageWithURLString:imageURLString];
    if (!image) {
        if (params[@"failedCallback"]) {
            [self stringByEvaluatingJavaScriptFromString:
             [NSString stringWithFormat:@";(%@)('Can not fetch image DATA');", params[@"failedCallback"]]];
        } else {
            agx_async_main([self showMessageHUD:YES title:params[@"failedTitle"]?:@"Failed" duration:2];)
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
            [self stringByEvaluatingJavaScriptFromString:
             [NSString stringWithFormat:@";(%@)('%@');", params[@"failedCallback"], error.localizedDescription]];
        } else {
            agx_async_main([self showMessageHUD:YES title:params[@"failedTitle"]?:@"Failed" detail:error.localizedDescription duration:2];)
        }
    } else {
        if (params[@"successCallback"]) {
            [self stringByEvaluatingJavaScriptFromString:
             [NSString stringWithFormat:@";(%@)();", params[@"successCallback"]]];
        } else {
            agx_async_main([self showMessageHUD:YES title:params[@"successTitle"]?:@"Success" duration:2];)
        }
    }
    [image setRetainProperty:NULL forAssociateKey:AGXSaveImageToAlbumParamsKey];
}

NSString *const AGXLoadImageCallbackKey = @"AGXLoadImageCallback";

- (void)loadImageFromAlbum:(NSDictionary *)params {
    ALAuthorizationStatus status = [ALAssetsLibrary authorizationStatus];
    if (status == ALAuthorizationStatusRestricted || status == ALAuthorizationStatusDenied) {
        [self p_alertNoneAuthorizationTitle:params[@"title"]?:@"失败"
                                    message:params[@"message"]?:@"没有访问相册的权限"
                                cancelTitle:params[@"button"]?:@"我知道了"];
        return;
    }
    [self p_showImagePickerController:AGXImagePickerController.instance withParams:params];
}

- (void)loadImageFromCamera:(NSDictionary *)params {
    AVAuthorizationStatus status = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    if (status == AVAuthorizationStatusRestricted || status == AVAuthorizationStatusDenied) {
        [self p_alertNoneAuthorizationTitle:params[@"title"]?:@"失败"
                                    message:params[@"message"]?:@"没有访问相机的权限"
                                cancelTitle:params[@"button"]?:@"我知道了"];
        return;
    }
    [self p_showImagePickerController:AGXImagePickerController.camera withParams:params];
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

#pragma mark - private methods: PhotosAlbum

- (void)p_alertNoneAuthorizationTitle:(NSString *)title message:(NSString *)message cancelTitle:(NSString *)cancelTitle {
    UIAlertController *controller = [UIAlertController alertControllerWithTitle:title message:message
                                                                 preferredStyle:UIAlertControllerStyleAlert];
    [controller addAction:[UIAlertAction actionWithTitle:cancelTitle style:UIAlertActionStyleCancel handler:NULL]];
    agx_async_main
    ([UIApplication.sharedRootViewController presentViewController:controller animated:YES completion:NULL];)
}

- (void)p_showImagePickerController:(AGXImagePickerController *)imagePicker withParams:(NSDictionary *)params {
    if (params[@"editable"]) imagePicker.allowsEditing = [params[@"editable"] boolValue];
    if (params[@"callback"]) {
        imagePicker.imagePickerDelegate = self;
        [imagePicker setRetainProperty:params[@"callback"] forAssociateKey:AGXLoadImageCallbackKey];
    }
    agx_async_main([imagePicker presentAnimated:YES completion:NULL];)
}

#pragma mark - QRCode reader bridge handler

- (NSString *)recogniseQRCode:(NSString *)imageURLString {
    Class hintsClass = NSClassFromString(@"AGXDecodeHints");
    if (!hintsClass) { AGXLog(@"recogniseQRCode need include <AGXGcode.framework>"); return nil; }

    Class readerClass = NSClassFromString(@"AGXGcodeReader");
    if (!readerClass) { AGXLog(@"recogniseQRCode need include <AGXGcode.framework>"); return nil; }

    if (!imageURLString || [imageURLString isEmpty]) return nil;

    UIImage *image = [UIImage imageWithURLString:imageURLString];
    if (!image) return nil;

    id hints = hintsClass.instance;
    AGX_PerformSelector([hints performSelector:NSSelectorFromString(@"setFormats:") withObject:@[@(9)]];) // kGcodeFormatQRCode = 9

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

#pragma mark - override

- (void)setDelegate:(id<UIWebViewDelegate>)delegate {
    if (!delegate || [delegate isKindOfClass:[AGXWebViewInternalDelegate class]])  {
        [super setDelegate:delegate];
        return;
    }
    _webViewInternalDelegate.delegate = delegate;
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
    void (^JavaScriptContextBridgeInjection)() = ^{
        for (AGXWebView *agxWebView in agxWebViews) {
            NSString *hash = [NSString stringWithFormat:@"agx_jscWebView_%lud", (unsigned long)agxWebView.hash];
            [agxWebView stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"var %@='%@'", hash, hash]];
            if ([ctx[hash].toString isEqualToString:hash]) {
                ctx[@"AGXBridge"] = [agxWebView valueForKeyPath:@"internal.bridge"];
                return;
            }
        }
    };

    if ([NSThread isMainThread]) JavaScriptContextBridgeInjection();
    else dispatch_async(dispatch_get_main_queue(), JavaScriptContextBridgeInjection);
}
@end
