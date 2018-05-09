//
//  AGXWebViewController.m
//  AGXWidget
//
//  Created by Char Aznable on 2016/3/6.
//  Copyright © 2016年 AI-CUC-EC. All rights reserved.
//

#import <objc/runtime.h>
#import <AGXCore/AGXCore/AGXMath.h>
#import <AGXCore/AGXCore/AGXAppInfo.h>
#import <AGXCore/AGXCore/NSData+AGXCore.h>
#import <AGXCore/AGXCore/NSString+AGXCore.h>
#import <AGXCore/AGXCore/NSDictionary+AGXCore.h>
#import <AGXCore/AGXCore/NSURLRequest+AGXCore.h>
#import <AGXCore/AGXCore/UIApplication+AGXCore.h>
#import <AGXCore/AGXCore/UIView+AGXCore.h>
#import <AGXCore/AGXCore/UIImage+AGXCore.h>
#import <AGXCore/AGXCore/UIViewController+AGXCore.h>
#import <AGXCore/AGXCore/UIScrollView+AGXCore.h>
#import <AGXCore/AGXCore/UIWebView+AGXCore.h>
#import <AGXCore/AGXCore/UIGestureRecognizer+AGXCore.h>
#import "AGXWebViewController.h"
#import "AGXWidgetLocalization.h"
#import "AGXProgressHUD.h"
#import "AGXPhotoPickerController.h"
#import "AGXImagePickerController.h"
#import "UINavigationController+AGXWidget.h"
#import "UIDocumentMenuViewController+AGXWidget.h"
#import "AGXGestureRecognizerTags.h"
#import "AGXPhotoCommon.h"

@interface AGXWebViewControllerURLStringParser ()
- (AGXWebViewController *)webViewControllerWithURLString:(NSString *)URLString defaultClass:(Class)defaultClass;
@end

@interface AGXWebViewController () <UIGestureRecognizerDelegate, AGXPhotoPickerControllerDelegate, AGXImagePickerControllerDelegate>
@end

@implementation AGXWebViewController {
    UIPanGestureRecognizer  *_goBackPanGestureRecognizer;
    CGFloat                 _lastPercentProgress;
    NSComparisonResult      _panGestureDirection;
    NSMutableArray          *_historyRequestURLAndSnapshotArray;
    UIImageView             *_previewImageView;

    BOOL                    _scrollEnabledTemp;
}

@dynamic view;

- (AGX_INSTANCETYPE)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if AGX_EXPECT_T(self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        self.navigationItem.title = AGXWidgetLocalizedStringDefault
        (@"AGXWebViewController.initialTitle", AGXAppInfo.appBundleName);

        _useDocumentTitle = YES;
        _goBackOnBackBarButton = YES;
        _autoAddCloseBarButton = YES;
        _goBackOnPopGesture = YES;
        _goBackPopPercent = 0.5;

        _goBackPanGestureRecognizer = [[UIPanGestureRecognizer alloc]
                                       initWithTarget:self action:@selector(goBackPanGestureAction:)];
        _goBackPanGestureRecognizer.delegate = self;
        _goBackPanGestureRecognizer.agxTag = AGXWebViewControllerGoBackGestureTag;
        _lastPercentProgress = 0;
        _panGestureDirection = NSOrderedSame;
        _historyRequestURLAndSnapshotArray = [[NSMutableArray alloc] init];
        _previewImageView = [[UIImageView alloc] init];
        _previewImageView.userInteractionEnabled = YES;
    }
    return self;
}

- (void)dealloc {
    AGX_RELEASE(_goBackPanGestureRecognizer);
    AGX_RELEASE(_historyRequestURLAndSnapshotArray);
    AGX_RELEASE(_previewImageView);
    AGX_SUPER_DEALLOC;
}

- (void)setGoBackPopPercent:(CGFloat)goBackPopPercent {
    _goBackPopPercent = BETWEEN(goBackPopPercent, 0.1, 0.9);
}

- (void)viewDidLoad {
    [super viewDidLoad];

    self.view.delegate = self;
    self.view.shadowOpacity = 1.0;
    self.view.shadowOffset = CGSizeMake(0, 0);
    [self.view addGestureRecognizer:_goBackPanGestureRecognizer];
    self.navigationItem.leftItemsSupplementBackButton = YES;

#define REGISTER(HANDLER, SELECTOR) \
[self.view registerHandlerName:@HANDLER target:self action:@selector(SELECTOR)]

    REGISTER("setNavigationTitle", setNavigationTitle:);
    REGISTER("setPrompt", setPrompt:);
    REGISTER("setBackTitle", setBackTitle:);
    REGISTER("setChildBackTitle", setChildBackTitle:);
    REGISTER("setLeftButton", setLeftButton:);
    REGISTER("setRightButton", setRightButton:);
    REGISTER("toggleNavigationBar", toggleNavigationBar:);
    REGISTER("pushIn", pushIn:);
    REGISTER("popOut", popOut:);

    REGISTER("alert", alert:);
    REGISTER("confirm", confirm:);

    REGISTER("saveImageToAlbum", saveImageToAlbum:);
    REGISTER("loadImageFromAlbum", loadImageFromAlbum:);
    REGISTER("loadImageFromCamera", loadImageFromCamera:);
    REGISTER("loadImageFromAlbumOrCamera", loadImageFromAlbumOrCamera:);
    REGISTER("setInputFileMenuOptionFilter", setInputFileMenuOptionFilter:);

#undef REGISTER
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    AGX_STATIC unsigned long intervalId = 0;
    AGX_STATIC NSString *const AGXDisplayEventJSFormat =
    @"if(window.__agxcd){var v=document.createEvent('HTMLEvents');v.initEvent('AGXBDisplay',!0,!0);window.dispatchEvent(v)}else{var __agxid%lu=setInterval(function(){if(window.__agxcd){__agxid%lu=clearInterval(__agxid%lu);var v=document.createEvent('HTMLEvents');v.initEvent('AGXBDisplay',!0,!0);window.dispatchEvent(v)}},100)}";
    [self.view stringByEvaluatingJavaScriptFromString:
     [NSString stringWithFormat:AGXDisplayEventJSFormat, intervalId, intervalId, intervalId]];
    intervalId++;
}

- (BOOL)navigationShouldPopOnBackBarButton {
    if (_goBackOnBackBarButton && self.view.canGoBack) {
        [self.view goBack];
        return NO;
    }
    return [super navigationShouldPopOnBackBarButton];
}

+ (AGX_INSTANCETYPE)webViewControllerWithURLString:(NSString *)URLString {
    Class parserClass = self.URLStringParserClass;
    if AGX_EXPECT_F(![parserClass isSubclassOfClass:AGXWebViewControllerURLStringParser.class]) {
        parserClass = AGXWebViewControllerURLStringParser.class;
    }
    AGXWebViewControllerURLStringParser *URLStringParser = parserClass.instance;
    return [URLStringParser webViewControllerWithURLString:URLString defaultClass:self];
}

+ (Class)URLStringParserClass {
    return AGXWebViewControllerURLStringParser.class;
}

#pragma mark - UIWebViewDelegate

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    if ([request isNewRequestFromURL:webView.request.URL]) {
        if ((UIWebViewNavigationTypeLinkClicked == navigationType ||
             UIWebViewNavigationTypeOther == navigationType) &&
            AGXIsNotEmpty(webView.request.URL.description)) {
            NSString *requestURL = webView.request.URL.description;
            if (![_historyRequestURLAndSnapshotArray.lastObject[@"url"] isEqualToString:requestURL]) {
                [_historyRequestURLAndSnapshotArray addObject:
                 @{@"snapshot": webView.imageRepresentation, @"url": requestURL}];
            }
        } else if (UIWebViewNavigationTypeBackForward == navigationType) {
            if ([_historyRequestURLAndSnapshotArray.lastObject[@"url"] isEqualToString:request.URL.description])
                [_historyRequestURLAndSnapshotArray removeLastObject];
        }
    }
    return YES;
}

- (void)webViewDidStartLoad:(UIWebView *)webView {}

AGX_STATIC const NSInteger AGXWebViewControllerCloseBarButtonTag = 31215195;

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    if (_useDocumentTitle) self.navigationItem.title
        = [self.view stringByEvaluatingJavaScriptFromString:@"document.title"];

    if (_autoAddCloseBarButton) {
        [self p_addCloseBarButton];
    }
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
    if (_autoAddCloseBarButton) {
        [self p_addCloseBarButton];
    }
}

#pragma mark - UIGestureRecognizerDelegate

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
    return(_goBackOnPopGesture && gestureRecognizer == _goBackPanGestureRecognizer && self.view.canGoBack);
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return NO;
//    return(otherGestureRecognizer.agxTag != AGXNavigationControllerInternalPopGestureTag);
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    return([self gestureRecognizerShouldBegin:gestureRecognizer] &&
           progressOfXPosition([touch locationInView:UIApplication.sharedKeyWindow].x) < 0.1);
}

#pragma mark - gesture action

- (void)goBackPanGestureAction:(UIPanGestureRecognizer *)panGestureRecognizer {
    CGFloat progress = progressOfXPosition
    ([panGestureRecognizer locationInView:UIApplication.sharedKeyWindow].x);
    CGFloat windowWidth = UIApplication.sharedKeyWindow.bounds.size.width;
    CGFloat previewOffset = windowWidth * 0.3;

    if (UIGestureRecognizerStateBegan == panGestureRecognizer.state) {
        // store scrollEnabled state and disabled in gesture progress
        _scrollEnabledTemp = self.view.scrollView.scrollEnabled;
        self.view.scrollView.scrollEnabled = NO;

        _previewImageView.frame = self.view.frame;
        _previewImageView.image = _historyRequestURLAndSnapshotArray.lastObject[@"snapshot"];
        [self.view.superview insertSubview:_previewImageView belowSubview:self.view];

        _previewImageView.transform = CGAffineTransformTranslate
        (CGAffineTransformIdentity, (progress - 1) * previewOffset, 0);
        self.view.transform = CGAffineTransformTranslate(CGAffineTransformIdentity, progress * windowWidth, 0);

    } else if (UIGestureRecognizerStateChanged == panGestureRecognizer.state) {
        _previewImageView.transform = CGAffineTransformTranslate
        (CGAffineTransformIdentity, (progress - 1) * previewOffset, 0);
        self.view.transform = CGAffineTransformTranslate(CGAffineTransformIdentity, progress * windowWidth, 0);
        _panGestureDirection = progress > _lastPercentProgress ? NSOrderedAscending : progress < _lastPercentProgress;
        _lastPercentProgress = progress;

    } else if (UIGestureRecognizerStateEnded == panGestureRecognizer.state ||
               UIGestureRecognizerStateCancelled == panGestureRecognizer.state) {
        if (NSOrderedAscending == _panGestureDirection) {
            [self p_finishGoBack:progress previewTransformX:windowWidth];
        } else if (NSOrderedDescending == _panGestureDirection) {
            [self p_cancelGoBack:progress previewTransformX:-previewOffset];
        } else if (progress > _goBackPopPercent) {
            [self p_finishGoBack:progress previewTransformX:windowWidth];
        } else {
            [self p_cancelGoBack:progress previewTransformX:-previewOffset];
        }
        _lastPercentProgress = 0;
        _panGestureDirection = NSOrderedSame;

        // restore scrollEnabled state when gesture ended
        self.view.scrollView.scrollEnabled = _scrollEnabledTemp;
    }
}

AGX_STATIC CGFloat progressOfXPosition(CGFloat xPosition) {
    return cgfabs(xPosition) / UIApplication.sharedKeyWindow.bounds.size.width;
}

#pragma mark - user event

- (void)agxWebViewControllerClose:(id)sender {
    [self popViewControllerAnimated:YES];
}

#pragma mark - UINavigationController bridge handler

- (void)setNavigationTitle:(NSString *)title {
    agx_async_main
    (self.navigationItem.title = AGXIsNil(title)?nil:title;);
}

- (void)setPrompt:(NSString *)prompt {
    agx_async_main
    (self.navigationItem.prompt = AGXIsNil(prompt)?nil:prompt;
     [self.view setNeedsLayout];);
}

- (void)setBackTitle:(NSString *)backTitle {
    agx_async_main
    (self.navigationBar.topItem.hidesBackButton = AGXIsNil(backTitle);
     self.backBarButtonTitle = AGXIsNil(backTitle)?nil:backTitle;);
}

- (void)setChildBackTitle:(NSString *)childBackTitle {
    agx_async_main
    (self.navigationItem.backBarButtonItem =
     AGX_AUTORELEASE([[UIBarButtonItem alloc] initWithTitle:AGXIsNil(childBackTitle)?@"":childBackTitle style:
                      UIBarButtonItemStylePlain target:nil action:nil]););
}

AGX_STATIC const NSInteger AGXWebViewControllerLeftBarButtonTag = 125620;

- (void)setLeftButton:(NSDictionary *)setting {
    agx_async_main
    (NSMutableArray *leftBarButtonItems = [NSMutableArray arrayWithArray:self.navigationItem.leftBarButtonItems];
     for (UIBarButtonItem *leftItem in leftBarButtonItems) {
         if (AGXWebViewControllerLeftBarButtonTag == leftItem.tag) {
             [leftBarButtonItems removeObject:leftItem];
             break;
         }
     }
     UIBarButtonItem *leftBarButton = [self p_createBarButtonItem:setting];
     leftBarButton.tag = AGXWebViewControllerLeftBarButtonTag;
     [leftBarButtonItems addObject:leftBarButton];
     self.navigationItem.leftBarButtonItems = leftBarButtonItems;);
}

- (void)setRightButton:(NSDictionary *)setting {
    agx_async_main(self.navigationItem.rightBarButtonItem = [self p_createBarButtonItem:setting];);
}

- (void)toggleNavigationBar:(NSDictionary *)setting {
    BOOL hidden = [([setting itemForKey:@"hide"]?:@(!self.navigationBarHidden)) boolValue];
    BOOL animate = [([setting itemForKey:@"animate"]?:@YES) boolValue];
    agx_async_main([self setNavigationBarHidden:hidden animated:animate];
                   [self.view setNeedsLayout];);
}

- (void)pushIn:(NSDictionary *)setting {
    BOOL animate = [([setting itemForKey:@"animate"]?:@YES) boolValue];

    NSString *clazz = [setting itemForKey:@"class"];
    NSString *url = [setting itemForKey:@"url"];
    if (clazz) {
        Class clz = NSClassFromString(clazz);
        if (![clz isSubclassOfClass:UIViewController.class] ||
            [clz isSubclassOfClass:[UINavigationController class]]) return;
        agx_async_main([self pushViewController:clz.instance animated:animate];);

    } else if (url) {
        NSString *type = [setting itemForKey:@"type"];
        Class clz = type ? NSClassFromString(type) : self.class;
        if (![clz isSubclassOfClass:AGXWebViewController.class]) return;
        agx_async_main([self pushViewController:[clz webViewControllerWithURLString:url] animated:animate];);
    }
}

- (void)popOut:(NSDictionary *)setting {
    NSArray *viewControllers = self.navigationController.viewControllers;
    if (viewControllers.count <= 1) return;

    BOOL animate = [([setting itemForKey:@"animate"]?:@YES) boolValue];
    NSInteger count = MAX([[setting itemForKey:@"count"] integerValue], 1);
    NSUInteger index = viewControllers.count < count + 1 ? 0 : viewControllers.count - count - 1;
    agx_async_main([self popToViewController:viewControllers[index] animated:animate];);
}

#pragma mark - UIAlertController bridge handler

- (void)alert:(NSDictionary *)setting {
    SEL callback = [self.view registerTriggerAt:self.class withJavascript:
                    [setting itemForKey:@"callback"]?:@"function(){}"];

    agx_async_main
    (UIAlertController *controller = [self p_alertControllerWithTitle:[setting itemForKey:@"title"]
                                                              message:[setting itemForKey:@"message"]
                                                                style:[setting itemForKey:@"style"]];
     [self p_alertController:controller addActionWithTitle:[setting itemForKey:@"button"]?:
      AGXWidgetLocalizedStringDefault(@"AGXWebView.alert.cancel", @"Cancel")
                       style:UIAlertActionStyleCancel selector:callback];
     [self presentViewController:controller animated:YES completion:NULL];);
}

- (void)confirm:(NSDictionary *)setting {
    SEL cancel = [self.view registerTriggerAt:self.class withJavascript:
                  [setting itemForKey:@"cancelCallback"]?:@"function(){}"];
    SEL confirm = [self.view registerTriggerAt:self.class withJavascript:
                   [setting itemForKey:@"confirmCallback"]?:@"function(){}"];

    agx_async_main
    (UIAlertController *controller = [self p_alertControllerWithTitle:[setting itemForKey:@"title"]
                                                              message:[setting itemForKey:@"message"]
                                                                style:[setting itemForKey:@"style"]];
     [self p_alertController:controller addActionWithTitle:[setting itemForKey:@"cancelButton"]?:
      AGXWidgetLocalizedStringDefault(@"AGXWebView.confirm.cancel", @"Cancel")
                       style:UIAlertActionStyleCancel selector:cancel];
     [self p_alertController:controller addActionWithTitle:[setting itemForKey:@"confirmButton"]?:
      AGXWidgetLocalizedStringDefault(@"AGXWebView.confirm.ok", @"OK")
                       style:UIAlertActionStyleDefault selector:confirm];
     [self presentViewController:controller animated:YES completion:NULL];);
}

#pragma mark - PhotosAlbum bridge handler

NSString *const AGXSaveImageToAlbumParamsKey = @"AGXSaveImageToAlbumParams";

- (void)saveImageToAlbum:(NSDictionary *)params {
    NSString *savingCallback = [params itemForKey:@"savingCallback"];
    if (savingCallback) {
        agx_async_main(([self.view stringByEvaluatingJavaScriptFromString:
                         [NSString stringWithFormat:@";(%@)();", savingCallback]]););
    } else {
        agx_async_main([self.view showLoadingHUD:YES title:[params itemForKey:@"savingTitle"]?:
                        AGXWidgetLocalizedStringDefault(@"AGXWebView.saveImage.saving", @"Saving")];);
    }

    NSString *url = [params itemForKey:@"url"];
    if AGX_EXPECT_T(AGXIsNotEmpty(url)) {
        UIImage *image = [UIImage imageWithURLString:url];
        if AGX_EXPECT_T(image) {
            [image setRetainProperty:params forAssociateKey:AGXSaveImageToAlbumParamsKey];
            UIImageWriteToSavedPhotosAlbum(image, self, @selector(image:didFinishSavingWithError:contextInfo:), nil);
            return;
        }
    }

    NSString *failedCallback = [params itemForKey:@"failedCallback"];
    if (failedCallback) {
        agx_async_main(([self.view stringByEvaluatingJavaScriptFromString:
                         [NSString stringWithFormat:@";(%@)('Can not fetch image DATA');", failedCallback]]););
    } else {
        agx_async_main([self.view showMessageHUD:YES title:[params itemForKey:@"failedTitle"]?:
                        AGXWidgetLocalizedStringDefault(@"AGXWebView.saveImage.failed", @"Failed") duration:2];);
    }
}

// UIImageWriteToSavedPhotosAlbum completionSelector
- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo {
    NSDictionary *params = [image retainPropertyForAssociateKey:AGXSaveImageToAlbumParamsKey];
    if (error) {
        NSString *failedCallback = [params itemForKey:@"failedCallback"];
        if (failedCallback) {
            agx_async_main(([self.view stringByEvaluatingJavaScriptFromString:
                             [NSString stringWithFormat:@";(%@)('%@');", failedCallback, error.localizedDescription]]););
        } else {
            agx_async_main([self.view showMessageHUD:YES title:[params itemForKey:@"failedTitle"]?:
                            AGXWidgetLocalizedStringDefault(@"AGXWebView.saveImage.failed", @"Failed")
                                         detail:error.localizedDescription duration:2];);
        }
    } else {
        NSString *successCallback = [params itemForKey:@"successCallback"];
        if (successCallback) {
            agx_async_main(([self.view stringByEvaluatingJavaScriptFromString:
                             [NSString stringWithFormat:@";(%@)();", successCallback]]););
        } else {
            agx_async_main([self.view showMessageHUD:YES title:[params itemForKey:@"successTitle"]?:
                            AGXWidgetLocalizedStringDefault(@"AGXWebView.saveImage.success", @"Success") duration:2];);
        }
    }
    [image setRetainProperty:NULL forAssociateKey:AGXSaveImageToAlbumParamsKey];
}

NSString *const AGXLoadImageCallbackKey = @"AGXLoadImageCallback";

- (void)loadImageFromAlbum:(NSDictionary *)params {
    if (!AGXPhotoUtils.authorized) {
        [self p_alertNoneAuthorizationTitle:[params itemForKey:@"title"]?:
         AGXWidgetLocalizedStringDefault(@"AGXWebView.loadImage.failed", @"Failed")
                                    message:[params itemForKey:@"message"]?:
         AGXWidgetLocalizedStringDefault(@"AGXWebView.loadImage.unauthorizedPhotoLibrary", @"No permission to access Photo Library")
                               settingTitle:[params itemForKey:@"setting"]?:
         AGXWidgetLocalizedStringDefault(@"AGXWebView.loadImage.setting", @"Setting")
                                cancelTitle:[params itemForKey:@"button"]?:
         AGXWidgetLocalizedStringDefault(@"AGXWebView.loadImage.fine", @"OK")];
        return;
    }
    agx_async_main
    (AGXPhotoPickerController *photoPicker = AGXPhotoPickerController.instance;
     NSString *callback = [params itemForKey:@"callback"];
     if (callback) {
         photoPicker.photoPickerDelegate = self;
         [photoPicker setRetainProperty:callback forAssociateKey:AGXLoadImageCallbackKey];
     }
     [self presentViewController:photoPicker animated:YES completion:NULL];);
}

- (void)loadImageFromCamera:(NSDictionary *)params {
    AVAuthorizationStatus status = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    if (AVAuthorizationStatusRestricted == status || AVAuthorizationStatusDenied == status) {
        [self p_alertNoneAuthorizationTitle:[params itemForKey:@"title"]?:
         AGXWidgetLocalizedStringDefault(@"AGXWebView.loadImage.failed", @"Failed")
                                    message:[params itemForKey:@"message"]?:
         AGXWidgetLocalizedStringDefault(@"AGXWebView.loadImage.unauthorizedCamera", @"No permission to access Camera")
                               settingTitle:[params itemForKey:@"setting"]?:
         AGXWidgetLocalizedStringDefault(@"AGXWebView.loadImage.setting", @"Setting")
                                cancelTitle:[params itemForKey:@"button"]?:
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
      [UIAlertAction actionWithTitle:[params itemForKey:@"cancelButton"]?:
       AGXWidgetLocalizedStringDefault(@"AGXWebView.loadImage.cancel", @"Cancel")
                               style:UIAlertActionStyleCancel handler:^(UIAlertAction *alertAction) {}]];
     [controller addAction:
      [UIAlertAction actionWithTitle:[params itemForKey:@"albumButton"]?:
       AGXWidgetLocalizedStringDefault(@"AGXWebView.loadImage.album", @"Album")
                               style:UIAlertActionStyleDefault handler:^(UIAlertAction *alertAction) { [self loadImageFromAlbum:params]; }]];
     [controller addAction:
      [UIAlertAction actionWithTitle:[params itemForKey:@"cameraButton"]?:
       AGXWidgetLocalizedStringDefault(@"AGXWebView.loadImage.camera", @"Camera")
                               style:UIAlertActionStyleDefault handler:^(UIAlertAction *alertAction) { [self loadImageFromCamera:params]; }]];
     [self presentViewController:controller animated:YES completion:NULL];);
}

// AGXPhotoPickerControllerDelegate

- (void)photoPickerController:(AGXPhotoPickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info {
    NSString *callbackJSString = [picker retainPropertyForAssociateKey:AGXLoadImageCallbackKey];
    if (!callbackJSString) return;
    [self.view stringByEvaluatingJavaScriptFromString:
     [NSString stringWithFormat:@";(%@)('data:image/png;base64,%@');",
      callbackJSString, UIImagePNGRepresentation(info[AGXAlbumControllerPickedImage]).base64EncodedString]];
    [picker setRetainProperty:NULL forAssociateKey:AGXLoadImageCallbackKey];
}

// AGXImagePickerControllerDelegate
- (void)imagePickerController:(AGXImagePickerController *)picker didFinishPickingImage:(UIImage *)image {
    NSString *callbackJSString = [picker retainPropertyForAssociateKey:AGXLoadImageCallbackKey];
    if (!callbackJSString) return;
    [self.view stringByEvaluatingJavaScriptFromString:
     [NSString stringWithFormat:@";(%@)('data:image/png;base64,%@');",
      callbackJSString, UIImagePNGRepresentation(image).base64EncodedString]];
    [picker setRetainProperty:NULL forAssociateKey:AGXLoadImageCallbackKey];
}

- (void)setInputFileMenuOptionFilter:(NSString *)inputFileMenuOptionFilter {
    if (AGXIsNilOrEmpty(inputFileMenuOptionFilter)) return;
    [UIDocumentMenuViewController setMenuOptionFilter:inputFileMenuOptionFilter];
}

#pragma mark - private methods: gesture finish

- (void)p_finishGoBack:(CGFloat)progress previewTransformX:(CGFloat)previewTransformX {
    [UIView animateWithDuration:(1.0 - progress) * 0.25 animations:^{
        _previewImageView.transform = CGAffineTransformIdentity;
        self.view.transform = CGAffineTransformTranslate(CGAffineTransformIdentity, previewTransformX, 0);
    } completion:^(BOOL finished) {
        [self.view goBack];
        [self.view.superview bringSubviewToFront:_previewImageView];
        self.view.transform = CGAffineTransformIdentity;
        [UIView animateWithDuration:0.5 animations:^{
            _previewImageView.alpha = 0;
        } completion:^(BOOL finished) {
            [_previewImageView removeFromSuperview];
            _previewImageView.alpha = 1;
        }];
    }];
}

- (void)p_cancelGoBack:(CGFloat)progress previewTransformX:(CGFloat)previewTransformX {
    [UIView animateWithDuration:progress * 0.25 animations:^{
        _previewImageView.transform = CGAffineTransformTranslate(CGAffineTransformIdentity, previewTransformX, 0);
        self.view.transform = CGAffineTransformIdentity;
    } completion:^(BOOL finished) {
        [_previewImageView removeFromSuperview];
        _previewImageView.transform = CGAffineTransformIdentity;
    }];
}

#pragma mark - private methods: UIBarButtonItem

- (void)p_addCloseBarButton {
    if (self.navigationController.viewControllers.firstObject == self) return;
    if (!self.view.canGoBack) return;
    NSMutableArray *leftBarButtonItems = [NSMutableArray arrayWithArray:
                                          self.navigationItem.leftBarButtonItems];
    for (UIBarButtonItem *leftItem in leftBarButtonItems) {
        if (AGXWebViewControllerCloseBarButtonTag == leftItem.tag) return;
    }
    UIBarButtonItem *closeBarButton = [[UIBarButtonItem alloc]
                                       initWithTitle:AGXWidgetLocalizedStringDefault
                                       (@"AGXWebViewController.close", @"Close")
                                       style:UIBarButtonItemStylePlain
                                       target:self action:@selector(agxWebViewControllerClose:)];
    closeBarButton.tag = AGXWebViewControllerCloseBarButtonTag;
    [leftBarButtonItems insertObject:AGX_AUTORELEASE(closeBarButton) atIndex:0];
    self.navigationItem.leftBarButtonItems = leftBarButtonItems;
}

- (UIBarButtonItem *)p_createBarButtonItem:(NSDictionary *)barButtonSetting {
    NSString *title = [barButtonSetting itemForKey:@"title"];
    UIBarButtonSystemItem system = barButtonSystemItem([barButtonSetting itemForKey:@"system"]);
    if AGX_EXPECT_F(!title && system < 0) return nil;

    NSString *callback = [barButtonSetting itemForKey:@"callback"];
    id target = callback ? self : nil;
    SEL action = callback ? [self.view registerTriggerAt:self.class withJavascript:callback] : nil;

    UIBarButtonItem *barButtonItem = nil;
    if (title) barButtonItem = [[UIBarButtonItem alloc]
                                initWithTitle:title style:UIBarButtonItemStylePlain target:target action:action];
    else barButtonItem = [[UIBarButtonItem alloc]
                          initWithBarButtonSystemItem:system target:target action:action];
    return AGX_AUTORELEASE(barButtonItem);
}

AGX_STATIC_INLINE UIBarButtonSystemItem barButtonSystemItem(NSString *systemStyle) {
#define MATCH(STYLE, ITEM) \
if ([systemStyle isCaseInsensitiveEqual:@STYLE]) return ITEM;

    MATCH("done",           UIBarButtonSystemItemDone)
    MATCH("cancel",         UIBarButtonSystemItemCancel)
    MATCH("edit",           UIBarButtonSystemItemEdit)
    MATCH("save",           UIBarButtonSystemItemSave)
    MATCH("add",            UIBarButtonSystemItemAdd)
    MATCH("flexiblespace",  UIBarButtonSystemItemFlexibleSpace)
    MATCH("fixedspace",     UIBarButtonSystemItemFixedSpace)
    MATCH("compose",        UIBarButtonSystemItemCompose)
    MATCH("reply",          UIBarButtonSystemItemReply)
    MATCH("action",         UIBarButtonSystemItemAction)
    MATCH("organize",       UIBarButtonSystemItemOrganize)
    MATCH("bookmarks",      UIBarButtonSystemItemBookmarks)
    MATCH("search",         UIBarButtonSystemItemSearch)
    MATCH("refresh",        UIBarButtonSystemItemRefresh)
    MATCH("stop",           UIBarButtonSystemItemStop)
    MATCH("camera",         UIBarButtonSystemItemCamera)
    MATCH("trash",          UIBarButtonSystemItemTrash)
    MATCH("play",           UIBarButtonSystemItemPlay)
    MATCH("pause",          UIBarButtonSystemItemPause)
    MATCH("rewind",         UIBarButtonSystemItemRewind)
    MATCH("fastforward",    UIBarButtonSystemItemFastForward)
    MATCH("undo",           UIBarButtonSystemItemUndo)
    MATCH("redo",           UIBarButtonSystemItemRedo)
    MATCH("pagecurl",       UIBarButtonSystemItemPageCurl)

#undef MATCH
    return -1;
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

#pragma mark - private methods: PhotosAlbum

- (void)p_alertNoneAuthorizationTitle:(NSString *)title message:(NSString *)message settingTitle:(NSString *)settingTitle cancelTitle:(NSString *)cancelTitle {
    agx_async_main
    (UIAlertController *controller = [UIAlertController alertControllerWithTitle:title message:message
                                                                  preferredStyle:UIAlertControllerStyleAlert];
     [controller addAction:[UIAlertAction actionWithTitle:cancelTitle style:UIAlertActionStyleCancel handler:NULL]];
     if (UIApplication.canOpenApplicationSetting) {
         [controller addAction:[UIAlertAction actionWithTitle:settingTitle style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) { [UIApplication openApplicationSetting]; }]];
     }
     [self presentViewController:controller animated:YES completion:NULL];);
}

- (void)p_showImagePickerController:(AGXImagePickerController *)imagePicker withParams:(NSDictionary *)params {
    NSNumber *editable = [params itemForKey:@"editable"];
    if (editable) imagePicker.allowsEditing = [editable boolValue];
    NSString *callback = [params itemForKey:@"callback"];
    if (callback) {
        imagePicker.imagePickerDelegate = self;
        [imagePicker setRetainProperty:callback forAssociateKey:AGXLoadImageCallbackKey];
    }
    agx_async_main([self presentViewController:imagePicker animated:YES completion:NULL];);
}

@end

@implementation AGXWebViewControllerURLStringParser

- (Class)webViewControllerClassWithURLString:(NSString *)URLString {
    return nil;
}

- (void)webViewController:(AGXWebViewController *)webViewController settingWithURLString:(NSString *)URLString {
    NSDictionary *settings = [[URLString arraySeparatedByString:@"??" filterEmpty:YES][1]?:@""
                              dictionarySeparatedByString:@"&" keyValueSeparatedByString:@"=" filterEmpty:YES];
    if (settings[@"autoStatusBarStyle"])
        webViewController.automaticallyAdjustsStatusBarStyle = [settings[@"autoStatusBarStyle"] boolValue];
    if (settings[@"statusBarStyle"])
        webViewController.statusBarStyle = [settings[@"statusBarStyle"] integerValue];
    if (settings[@"statusBarHidden"])
        webViewController.statusBarHidden = [settings[@"statusBarHidden"] boolValue];

    if (settings[@"navigationBarHidden"])
        webViewController.navigationBarHiddenFlag = [settings[@"navigationBarHidden"] boolValue];
    if (settings[@"hidesBarsOnSwipe"])
        webViewController.hidesBarsOnSwipeFlag = [settings[@"hidesBarsOnSwipe"] boolValue];
    if (settings[@"hidesBarsOnTap"])
        webViewController.hidesBarsOnTapFlag = [settings[@"hidesBarsOnTap"] boolValue];

    BOOL autoAdjustsInset = (settings[@"autoAdjustsInset"] ? [settings[@"autoAdjustsInset"] boolValue] :
                             !webViewController.navigationBarHiddenFlag);
    if (@available(iOS 11.0, *)) {
        webViewController.view.scrollView.contentInsetAdjustmentBehavior =
        autoAdjustsInset ? UIScrollViewContentInsetAdjustmentAutomatic : UIScrollViewContentInsetAdjustmentNever;
    } else {
        webViewController.view.scrollView.automaticallyAdjustsContentInsetByBars = autoAdjustsInset;
    }

    if (settings[@"navigationTitle"]) {
        webViewController.useDocumentTitle = NO;
        webViewController.navigationItem.title = [settings[@"navigationTitle"] stringByUnescapingFromURLQuery];
    }
    if (settings[@"addCloseButton"]) {
        webViewController.autoAddCloseBarButton = [settings[@"addCloseButton"] boolValue];
    }
    if (settings[@"pullDownRefresh"]) {
        webViewController.view.pullDownRefreshEnabled = [settings[@"pullDownRefresh"] boolValue];
    }
}

- (NSArray *)requestAttachedCookieNamesWithURLString:(NSString *)URLString {
    return nil;
}

- (NSString *)localResourceBundleNameWithURLString:(NSString *)URLString {
    return nil;
}

- (void)webViewController:(AGXWebViewController *)webViewController loadRequestWithURLString:(NSString *)URLString {
    NSString *requestURLString = [URLString arraySeparatedByString:@"??" filterEmpty:YES][0];
    NSURL *requestURL = [NSURL URLWithString:requestURLString];

    if ([@"http" isEqualToString:requestURL.scheme] || [@"https" isEqualToString:requestURL.scheme]) {
        [webViewController.view loadRequestWithURLString:
         requestURLString addCookieFieldWithNames:
         [self requestAttachedCookieNamesWithURLString:URLString]];

    } else if ([@"resources" isEqualToString:requestURL.scheme]) {
        [webViewController.view loadRequestWithResourcesFilePathString:
         requestURL.resourceSpecifier resourcesPattern:
         AGXResources.pattern.subpathAppendBundleNamed
         ([self localResourceBundleNameWithURLString:URLString])];
    }
}

- (AGXWebViewController *)webViewControllerWithURLString:(NSString *)URLString defaultClass:(Class)defaultClass {
    Class controllerClass = [self webViewControllerClassWithURLString:URLString]?:defaultClass;
    if AGX_EXPECT_F(![controllerClass isSubclassOfClass:AGXWebViewController.class]) {
        controllerClass = AGXWebViewController.class;
    }
    AGXWebViewController *webViewController = controllerClass.instance;
    [self webViewController:webViewController settingWithURLString:URLString];
    [self webViewController:webViewController loadRequestWithURLString:URLString];
    return webViewController;
}

@end
