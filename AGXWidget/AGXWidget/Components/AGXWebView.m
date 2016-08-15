//
//  AGXWebView.m
//  AGXWidget
//
//  Created by Char Aznable on 16/3/4.
//  Copyright © 2016年 AI-CUC-EC. All rights reserved.
//

#import <CoreLocation/CoreLocation.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import <AVFoundation/AVCaptureDevice.h>
#import <AVFoundation/AVMediaFormat.h>
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

- (void)registerHandlerName:(NSString *)handlerName handler:(id)handler selector:(SEL)selector; {
    [_webViewInternalDelegate.bridge registerHandler:handlerName handler:handler selector:selector];
}

- (SEL)registerTriggerAt:(Class)triggerClass withBlock:(AGXBridgeTrigger)triggerBlock {
    SEL selector = NSSelectorFromString([NSString stringWithFormat:@"trigger_%ld:", ++uniqueId]);
    [triggerClass addInstanceMethodWithSelector:selector andBlock:triggerBlock andTypeEncoding:"v@:@"];
    return selector;
}

- (SEL)registerTriggerAt:(Class)triggerClass withJavascript:(NSString *)javascript {
    __AGX_BLOCK AGXWebView *__webView = self;
    return [self registerTriggerAt:triggerClass withBlock:^(id SELF, id sender)
            { [__webView stringByEvaluatingJavaScriptFromString:javascript]; }];
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
    SEL callback = [self registerTriggerAt:[self class] withJavascript:
                    [NSString stringWithFormat:@";(%@)();", setting[@"callback"]?:@"function(){}"]];

#if __IPHONE_OS_VERSION_MIN_REQUIRED < __IPHONE_8_0
    if (AGX_BEFORE_IOS8_0) {
        [self p_alertAddCallbackWithStyle:setting[@"style"] callbackSelector:callback];
        [self p_alertShowWithStyle:setting[@"style"] title:setting[@"title"] message:setting[@"message"] buttonTitle:setting[@"button"]?:@"Cancel"];
        return;
    }
#endif
    UIAlertController *controller = [self p_alertControllerWithTitle:
                                     setting[@"title"] message:setting[@"message"] style:setting[@"style"]];
    [self p_alertController:controller addActionWithTitle:setting[@"button"]?:@"Cancel"
                      style:UIAlertActionStyleCancel selector:callback];
    agx_async_main
    ([UIApplication.sharedRootViewController presentViewController:controller animated:YES completion:NULL];)
}

- (void)confirm:(NSDictionary *)setting {
    SEL cancel = [self registerTriggerAt:[self class] withJavascript:
                  [NSString stringWithFormat:@";(%@)();", setting[@"cancelCallback"]?:@"function(){}"]];
    SEL confirm = [self registerTriggerAt:[self class] withJavascript:
                   [NSString stringWithFormat:@";(%@)();", setting[@"confirmCallback"]?:@"function(){}"]];

#if __IPHONE_OS_VERSION_MIN_REQUIRED < __IPHONE_8_0
    if (AGX_BEFORE_IOS8_0) {
        [self p_confirmAddCallbackWithStyle:setting[@"style"] cancelSelector:cancel confirmSelector:confirm];
        [self p_confirmShowWithStyle:setting[@"style"] title:setting[@"title"] message:setting[@"message"] cancelTitle:setting[@"cancelButton"]?:@"Cancel" confirmTitle:setting[@"confirmButton"]?:@"OK"];
        return;
    }
#endif
    UIAlertController *controller = [self p_alertControllerWithTitle:
                                     setting[@"title"] message:setting[@"message"] style:setting[@"style"]];
    [self p_alertController:controller addActionWithTitle:setting[@"cancelButton"]?:@"Cancel"
                      style:UIAlertActionStyleCancel selector:cancel];
    [self p_alertController:controller addActionWithTitle:setting[@"confirmButton"]?:@"OK"
                      style:UIAlertActionStyleDefault selector:confirm];
    agx_async_main
    ([UIApplication.sharedRootViewController presentViewController:controller animated:YES completion:NULL];)
}

#pragma mark - private methods: UIActionSheet/UIAlertView

#if __IPHONE_OS_VERSION_MIN_REQUIRED < __IPHONE_8_0

- (void)p_addCallbackMethodWithStyle:(NSString *)style block:(id)block {
    SEL selector = [style isCaseInsensitiveEqualToString:@"sheet"] ?
    @selector(actionSheet:clickedButtonAtIndex:) : @selector(alertView:clickedButtonAtIndex:);
    [[self class] addOrReplaceInstanceMethodWithSelector:selector andBlock:block andTypeEncoding:"v@:@q"];
}

- (void)p_alertAddCallbackWithStyle:(NSString *)style callbackSelector:(SEL)callback {
    [self p_addCallbackMethodWithStyle:style block:^(id SELF, id confirmView, NSInteger index) {
        AGX_PerformSelector([SELF performSelector:callback withObject:nil];) }];
}

- (void)p_confirmAddCallbackWithStyle:(NSString *)style cancelSelector:(SEL)cancel confirmSelector:(SEL)confirm {
    [self p_addCallbackMethodWithStyle:style block:^(id SELF, id confirmView, NSInteger index) {
        if (index == [confirmView cancelButtonIndex])
        { AGX_PerformSelector([SELF performSelector:cancel withObject:nil];) }
        if (index == [confirmView firstOtherButtonIndex])
        { AGX_PerformSelector([SELF performSelector:confirm withObject:nil];) } }];
}

- (void)p_alertShowWithStyle:(NSString *)style title:(NSString *)title message:(NSString *)message buttonTitle:(NSString *)buttonTitle  {
    if ([style isCaseInsensitiveEqualToString:@"sheet"]) {
        agx_async_main([[UIActionSheet actionSheetWithTitle:title?:message delegate:self cancelButtonTitle:buttonTitle
                                     destructiveButtonTitle:nil otherButtonTitles:nil]
                        showInView:UIApplication.sharedKeyWindow];)
    } else {
        agx_async_main([[UIAlertView alertViewWithTitle:title message:message delegate:self
                                      cancelButtonTitle:buttonTitle otherButtonTitles:nil] show];)
    }
}

- (void)p_confirmShowWithStyle:(NSString *)style title:(NSString *)title message:(NSString *)message cancelTitle:(NSString *)cancelTitle confirmTitle:(NSString *)confirmTitle {
    if ([style isCaseInsensitiveEqualToString:@"sheet"]) {
        agx_async_main(([[UIActionSheet actionSheetWithTitle:title?:message delegate:self cancelButtonTitle:cancelTitle
                                      destructiveButtonTitle:nil otherButtonTitles:confirmTitle, nil]
                         showInView:UIApplication.sharedKeyWindow]);)
    } else {
        agx_async_main(([[UIAlertView alertViewWithTitle:title message:message delegate:self
                                       cancelButtonTitle:cancelTitle otherButtonTitles:confirmTitle, nil] show]);)
    }
}

#endif // __IPHONE_OS_VERSION_MIN_REQUIRED < __IPHONE_8_0

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
    agx_async_main([UIApplication showLoadingHUD:YES title:params[@"savingTitle"]?:@""];)

    UIImage *image = [UIImage imageWithURLString:imageURLString];
    if (!image) {
        agx_async_main
        ([UIApplication showMessageHUD:YES title:params[@"failedTitle"]?:@"Failed" duration:2];)
        return;
    }

    [image setRetainProperty:params forAssociateKey:AGXSaveImageToAlbumParamsKey];
    UIImageWriteToSavedPhotosAlbum(image, self, @selector(image:didFinishSavingWithError:contextInfo:), nil);
}

// UIImageWriteToSavedPhotosAlbum completionSelector
- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo {
    NSDictionary *params = [image retainPropertyForAssociateKey:AGXSaveImageToAlbumParamsKey];
    NSString *title = error ? (params[@"failedTitle"]?:@"Failed") : (params[@"successTitle"]?:@"Success");
    NSString *detail = error ? error.localizedDescription : nil;
    agx_async_main([UIApplication showMessageHUD:YES title:title detail:detail duration:2];)
    [image setRetainProperty:NULL forAssociateKey:AGXSaveImageToAlbumParamsKey];
}

NSString *const AGXLoadImageCallbackKey = @"AGXLoadImageCallback";

- (void)loadImageFromAlbum:(NSDictionary *)params {
    ALAuthorizationStatus status = [ALAssetsLibrary authorizationStatus];
    if (status == kCLAuthorizationStatusRestricted || status == kCLAuthorizationStatusDenied) {
        [self p_alertNoneAuthorizationTitle:@"失败" message:@"没有访问相册的权限" cancelTitle:@"我知道了"];
        return;
    }
    [self p_showImagePickerController:AGXImagePickerController.instance withParams:params];
}

- (void)loadImageFromCamera:(NSDictionary *)params {
    AVAuthorizationStatus status = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    if (status == AVAuthorizationStatusRestricted || status == AVAuthorizationStatusDenied) {
        [self p_alertNoneAuthorizationTitle:@"失败" message:@"没有访问相机的权限" cancelTitle:@"我知道了"];
        return;
    }
    AGXImagePickerController *imagePicker = AGXImagePickerController.instance;
    imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
    [self p_showImagePickerController:imagePicker withParams:params];
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
#if __IPHONE_OS_VERSION_MIN_REQUIRED < __IPHONE_8_0
    if (AGX_BEFORE_IOS8_0) {
        agx_async_main([[UIAlertView alertViewWithTitle:title message:message delegate:self
                                      cancelButtonTitle:cancelTitle otherButtonTitles:nil] show];)
        return;
    }
#endif
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
