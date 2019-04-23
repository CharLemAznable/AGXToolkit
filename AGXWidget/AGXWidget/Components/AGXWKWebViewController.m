//
//  AGXWKWebViewController.m
//  AGXWidget
//
//  Created by Char on 2019/4/17.
//  Copyright © 2019 github.com/CharLemAznable. All rights reserved.
//

#import <AGXCore/AGXCore/AGXDelegateForwarder.h>
#import <AGXCore/AGXCore/AGXMath.h>
#import <AGXCore/AGXCore/AGXAppInfo.h>
#import <AGXCore/AGXCore/NSData+AGXCore.h>
#import <AGXCore/AGXCore/NSNumber+AGXCore.h>
#import <AGXCore/AGXCore/NSString+AGXCore.h>
#import <AGXCore/AGXCore/NSDictionary+AGXCore.h>
#import <AGXCore/AGXCore/NSURLRequest+AGXCore.h>
#import <AGXCore/AGXCore/UIApplication+AGXCore.h>
#import <AGXCore/AGXCore/UIView+AGXCore.h>
#import <AGXCore/AGXCore/UIImage+AGXCore.h>
#import <AGXCore/AGXCore/UIViewController+AGXCore.h>
#import <AGXCore/AGXCore/UIScrollView+AGXCore.h>
#import <AGXCore/AGXCore/UIGestureRecognizer+AGXCore.h>
#import <AGXRuntime/AGXRuntime.h>
#import "AGXWKWebViewController.h"
#import "AGXWidgetLocalization.h"
#import "AGXProgressHUD.h"
#import "AGXPhotoPickerController.h"
#import "AGXImagePickerController.h"
#import "UINavigationController+AGXWidget.h"
#import "UIDocumentMenuViewController+AGXWidget.h"
#import "AGXGestureRecognizerTags.h"
#import "AGXPhotoCommon.h"

@forwarder_interface(AGXWKWebViewControllerInternalWebViewDegelageForwarder, AGXWKWebViewController, WKNavigationDelegate)
@forwarder_implementation(AGXWKWebViewControllerInternalWebViewDegelageForwarder, AGXWKWebViewController, WKNavigationDelegate)

@interface AGXWKWebViewControllerInternalWebView : AGXWKWebView
@property (nonatomic, AGX_WEAK) AGXWKWebViewController *internalDelegate;
@end
@implementation AGXWKWebViewControllerInternalWebView {
    AGXWKWebViewControllerInternalWebViewDegelageForwarder *_delegateForwarder;
}

- (AGX_INSTANCETYPE)initWithFrame:(CGRect)frame configuration:(WKWebViewConfiguration *)configuration {
    if AGX_EXPECT_T(self = [super initWithFrame:frame configuration:configuration]) {
        _delegateForwarder = [[AGXWKWebViewControllerInternalWebViewDegelageForwarder alloc] init];
        super.navigationDelegate = _delegateForwarder;
    }
    return self;
}

- (void)setInternalDelegate:(AGXWKWebViewController *)internalDelegate {
    _delegateForwarder.internalDelegate = internalDelegate;
}

- (AGXWKWebViewController *)internalDelegate {
    return _delegateForwarder.internalDelegate;
}

- (void)setNavigationDelegate:(id<WKNavigationDelegate>)delegate {
    _delegateForwarder.externalDelegate = delegate;
}

- (id<WKNavigationDelegate>)navigationDelegate {
    return _delegateForwarder.externalDelegate;
}

- (void)dealloc {
    super.navigationDelegate = nil;
    _delegateForwarder.internalDelegate = nil;
    _delegateForwarder.externalDelegate = nil;
    AGX_RELEASE(_delegateForwarder);
    AGX_SUPER_DEALLOC;
}

@end

@interface AGXWKWebViewControllerURLStringParser ()
- (AGXWKWebViewController *)webViewControllerWithURLString:(NSString *)URLString defaultClass:(Class)defaultClass;
@end

@interface AGXWKWebViewController () <UIGestureRecognizerDelegate, AGXPhotoPickerControllerDelegate, AGXImagePickerControllerDelegate>
@end

@implementation AGXWKWebViewController {
    UIPanGestureRecognizer  *_goBackPanGestureRecognizer;
    CGFloat                 _lastPercentProgress;
    NSComparisonResult      _panGestureDirection;
    NSMutableArray          *_historyRequestURLAndSnapshotArray;
    UIImageView             *_previewImageView;

    BOOL                    _scrollEnabledTemp;

    NSTimer                 *_agxbWKDisplayEventTimer;
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
        _goBackPanGestureRecognizer.agxTag = AGXWKWebViewControllerGoBackGestureTag;
        _lastPercentProgress = 0;
        _panGestureDirection = NSOrderedSame;
        _historyRequestURLAndSnapshotArray = [[NSMutableArray alloc] init];
        _previewImageView = [[UIImageView alloc] init];
        _previewImageView.userInteractionEnabled = YES;
    }
    return self;
}

- (void)dealloc {
    ((AGXWKWebViewControllerInternalWebView *)self.view).internalDelegate = nil;
    AGX_RELEASE(_goBackPanGestureRecognizer);
    AGX_RELEASE(_historyRequestURLAndSnapshotArray);
    AGX_RELEASE(_previewImageView);
    [self cleanAGXBWKDisplayEventTimer];
    AGX_SUPER_DEALLOC;
}

+ (AGXProperty *)agxPropertyForName:(NSString *)name {
    if ([self isSubclassOfClass:AGXWKWebViewController.class] && [@"view" isEqualToString:name]) {
        AGXProperty *viewProperty = [super agxPropertyForName:name];
        if (viewProperty.objectClass != AGXWKWebView.class) return viewProperty;
        else return [AGXProperty propertyWithName:@"view" attributes:
                     @{AGXPropertyTypeEncodingAttribute:@"@\"AGXWKWebViewControllerInternalWebView\""}];
    } else return [super agxPropertyForName:name];
}

- (void)setGoBackPopPercent:(CGFloat)goBackPopPercent {
    _goBackPopPercent = BETWEEN(goBackPopPercent, 0.1, 0.9);
}

- (void)viewDidLoad {
    [super viewDidLoad];

    ((AGXWKWebViewControllerInternalWebView *)self.view).internalDelegate = self;
    self.view.shadowOpacity = 1.0;
    self.view.shadowOffset = CGSizeMake(0, 0);
    [self.view addGestureRecognizer:_goBackPanGestureRecognizer];
    self.navigationItem.leftItemsSupplementBackButton = YES;

#define REGISTER(HANDLER, SELECTOR) \
[self.view registerHandlerName:@HANDLER target:self action:SELECTOR]

    REGISTER("setNavigationTitle", @selector(setNavigationTitle:));
    REGISTER("setPrompt", @selector(setPrompt:));
    REGISTER("setBackTitle", @selector(setBackTitle:));
    REGISTER("setChildBackTitle", @selector(setChildBackTitle:));
    REGISTER("setLeftButton", @selector(setLeftButton:));
    REGISTER("setRightButton", @selector(setRightButton:));
    REGISTER("toggleNavigationBar", @selector(toggleNavigationBar:));
    REGISTER("pushIn", @selector(pushIn:));
    REGISTER("popOut", @selector(popOut:));

    REGISTER("alert", @selector(alert:));
    REGISTER("confirm", @selector(confirm:));

    REGISTER("saveImageToAlbum", @selector(saveImageToAlbum:));
    REGISTER("loadImageFromAlbum", @selector(loadImageFromAlbum:));
    REGISTER("loadImageFromCamera", @selector(loadImageFromCamera:));
    REGISTER("loadImageFromAlbumOrCamera", @selector(loadImageFromAlbumOrCamera:));
    REGISTER("setInputFileMenuOptionFilter", @selector(setInputFileMenuOptionFilter:));

#undef REGISTER
    [self.view reloadJavascriptBridgeUserScript];
}

AGX_STATIC NSString *const agxbWKCompletedJS =
@"'boolean'==typeof __agxcd";
AGX_STATIC NSString *const agxbWKDisplayEventJS =
@"var v=document.createEvent('HTMLEvents');v.initEvent('AGXBWKDisplay',!0,!0);window.dispatchEvent(v)";

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self dispatchAGXBWKDisplayEvent];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    AGXAddNotification(agxWKWebViewControllerWillEnterForeground:, UIApplicationWillEnterForegroundNotification);
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    AGXRemoveNotification(UIApplicationWillEnterForegroundNotification);
}

- (void)agxWKWebViewControllerWillEnterForeground:(NSNotification *)notification {
    if (self.viewVisible) [self dispatchAGXBWKDisplayEvent];
}

- (void)dispatchAGXBWKDisplayEvent {
    [self.view evaluateJavaScript:agxbWKCompletedJS completionHandler:
     ^(id result, NSError *error) {
         if ([result boolValue]) {
             [self.view evaluateJavaScript:agxbWKDisplayEventJS completionHandler:NULL];
         } else {
             @synchronized(self) {
                 if (_agxbWKDisplayEventTimer) [self cleanAGXBWKDisplayEventTimer];
                 _agxbWKDisplayEventTimer = AGX_RETAIN([NSTimer scheduledTimerWithTimeInterval:.1 target:self selector:
                                                        @selector(agxbDisplayEventTimeout:) userInfo:nil repeats:YES]);
             }
         }
     }];
}

- (void)agxbDisplayEventTimeout:(NSTimer *)timer {
    [self.view evaluateJavaScript:agxbWKCompletedJS completionHandler:
     ^(id result, NSError *error) {
         if ([result boolValue]) {
             [self cleanAGXBWKDisplayEventTimer];
             [self.view evaluateJavaScript:agxbWKDisplayEventJS completionHandler:NULL];
         }
     }];
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
    if AGX_EXPECT_F(![parserClass isSubclassOfClass:AGXWKWebViewControllerURLStringParser.class]) {
        parserClass = AGXWKWebViewControllerURLStringParser.class;
    }
    AGXWKWebViewControllerURLStringParser *URLStringParser = parserClass.instance;
    return [URLStringParser webViewControllerWithURLString:URLString defaultClass:self];
}

+ (Class)URLStringParserClass {
    return AGXWKWebViewControllerURLStringParser.class;
}

#pragma mark - WKNavigationDelegate

- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler {
    if (webView == self.view) {
        NSURLRequest *request = navigationAction.request;
        WKNavigationType navigationType = navigationAction.navigationType;
        if ([request isNewRequestFromURL:webView.URL]) {
            if ((WKNavigationTypeLinkActivated == navigationType ||
                 WKNavigationTypeOther == navigationType) &&
                AGXIsNotEmpty(webView.URL.description)) {
                NSString *requestURL = webView.URL.description;
                if (![_historyRequestURLAndSnapshotArray.lastObject[@"url"] isEqualToString:requestURL]) {
                    [_historyRequestURLAndSnapshotArray addObject:
                     @{@"snapshot": webView.imageRepresentation, @"url": requestURL}];
                }
            } else if (WKNavigationTypeBackForward == navigationType) {
                if ([_historyRequestURLAndSnapshotArray.lastObject[@"url"] isEqualToString:request.URL.description])
                    [_historyRequestURLAndSnapshotArray removeLastObject];
            }
        }
    }

    if (![self.view.navigationDelegate respondsToSelector:
          @selector(webView:decidePolicyForNavigationAction:decisionHandler:)]) {
        !decisionHandler?:decisionHandler(WKNavigationActionPolicyAllow);
    }
}

- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation {
    if (webView == self.view) {
        if (_useDocumentTitle) {
            [self.view evaluateJavaScript:@"document.title" completionHandler:
             ^(id result, NSError *error) {
                 self.navigationItem.title = result;
             }];
        }
        if (_autoAddCloseBarButton) {
            [self p_addCloseBarButton];
        }
    }
}

- (void)webView:(WKWebView *)webView didFailNavigation:(WKNavigation *)navigation withError:(NSError *)error {
    if (webView == self.view) {
        if (_autoAddCloseBarButton) {
            [self p_addCloseBarButton];
        }
    }
}

#pragma mark - UIGestureRecognizerDelegate

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
    return(_goBackOnPopGesture && gestureRecognizer == _goBackPanGestureRecognizer && self.view.canGoBack);
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return NO;
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

- (void)agxWKWebViewControllerClose:(id)sender {
    [self popViewControllerAnimated:YES];
}

#pragma mark - UINavigationController bridge handler

- (void)setNavigationTitle:(NSString *)title {
    self.navigationItem.title = AGXIsNil(title)?nil:title;
}

- (void)setPrompt:(NSString *)prompt {
    self.navigationItem.prompt = AGXIsNil(prompt)?nil:prompt;
    [self.view setNeedsLayout];
}

- (void)setBackTitle:(NSString *)backTitle {
    self.navigationBar.topItem.hidesBackButton = AGXIsNil(backTitle);
    self.backBarButtonTitle = AGXIsNil(backTitle)?nil:backTitle;
}

- (void)setChildBackTitle:(NSString *)childBackTitle {
    self.navigationItem.backBarButtonItem =
    AGX_AUTORELEASE([[UIBarButtonItem alloc] initWithTitle:AGXIsNil(childBackTitle)?@"":childBackTitle style:
                     UIBarButtonItemStylePlain target:nil action:nil]);
}

AGX_STATIC const NSInteger AGXWebViewControllerLeftBarButtonTag = 125620;

- (void)setLeftButton:(NSDictionary *)setting {
    NSMutableArray *leftBarButtonItems = [NSMutableArray arrayWithArray:self.navigationItem.leftBarButtonItems];
    for (UIBarButtonItem *leftItem in leftBarButtonItems) {
        if (AGXWebViewControllerLeftBarButtonTag == leftItem.tag) {
            [leftBarButtonItems removeObject:leftItem];
            break;
        }
    }
    UIBarButtonItem *leftBarButton = [self p_createBarButtonItem:setting];
    leftBarButton.tag = AGXWebViewControllerLeftBarButtonTag;
    [leftBarButtonItems addObject:leftBarButton];
    self.navigationItem.leftBarButtonItems = leftBarButtonItems;
}

- (void)setRightButton:(NSDictionary *)setting {
    self.navigationItem.rightBarButtonItem = [self p_createBarButtonItem:setting];
}

- (void)toggleNavigationBar:(NSDictionary *)setting {
    BOOL hidden = [([setting itemForKey:@"hide"]?:@(!self.navigationBarHidden)) boolValue];
    BOOL animate = [([setting itemForKey:@"animate"]?:@YES) boolValue];
    [self setNavigationBarHidden:hidden animated:animate];
    [self.view setNeedsLayout];
}

- (void)pushIn:(NSDictionary *)setting {
    BOOL animate = [([setting itemForKey:@"animate"]?:@YES) boolValue];

    NSString *clazz = [setting itemForKey:@"class"];
    NSString *url = [setting itemForKey:@"url"];
    if (clazz) {
        Class clz = NSClassFromString(clazz);
        if (![clz isSubclassOfClass:UIViewController.class] ||
            [clz isSubclassOfClass:[UINavigationController class]]) return;
        [self pushViewController:clz.instance animated:animate];

    } else if (url) {
        NSString *type = [setting itemForKey:@"type"];
        Class clz = type ? NSClassFromString(type) : self.class;
        if (![clz isSubclassOfClass:AGXWKWebViewController.class]) return;
        [self pushViewController:[clz webViewControllerWithURLString:url] animated:animate];
    }
}

- (void)popOut:(NSDictionary *)setting {
    NSArray *viewControllers = self.navigationController.viewControllers;
    if (viewControllers.count <= 1) return;

    BOOL animate = [([setting itemForKey:@"animate"]?:@YES) boolValue];
    NSInteger count = MAX([[setting itemForKey:@"count"] integerValue], 1);
    NSUInteger index = viewControllers.count < count + 1 ? 0 : viewControllers.count - count - 1;
    [self popToViewController:viewControllers[index] animated:animate];
}

#pragma mark - UIAlertController bridge handler

- (void)alert:(NSDictionary *)setting {
    SEL callback = [self.view registerTriggerAt:self.class withJavascript:
                    [setting itemForKey:@"callback"]?:@"function(){}"];

    UIAlertController *controller = [self p_alertControllerWithTitle:[setting itemForKey:@"title"]
                                                             message:[setting itemForKey:@"message"]
                                                               style:[setting itemForKey:@"style"]];
    [self p_alertController:controller addActionWithTitle:[setting itemForKey:@"button"]?:
     AGXWidgetLocalizedStringDefault(@"AGXWebView.alert.cancel", @"Cancel")
                      style:UIAlertActionStyleCancel selector:callback];
    [self presentViewController:controller animated:YES completion:NULL];
}

- (void)confirm:(NSDictionary *)setting {
    SEL cancel = [self.view registerTriggerAt:self.class withJavascript:
                  [setting itemForKey:@"cancelCallback"]?:@"function(){}"];
    SEL confirm = [self.view registerTriggerAt:self.class withJavascript:
                   [setting itemForKey:@"confirmCallback"]?:@"function(){}"];

    UIAlertController *controller = [self p_alertControllerWithTitle:[setting itemForKey:@"title"]
                                                             message:[setting itemForKey:@"message"]
                                                               style:[setting itemForKey:@"style"]];
    [self p_alertController:controller addActionWithTitle:[setting itemForKey:@"cancelButton"]?:
     AGXWidgetLocalizedStringDefault(@"AGXWebView.confirm.cancel", @"Cancel")
                      style:UIAlertActionStyleCancel selector:cancel];
    [self p_alertController:controller addActionWithTitle:[setting itemForKey:@"confirmButton"]?:
     AGXWidgetLocalizedStringDefault(@"AGXWebView.confirm.ok", @"OK")
                      style:UIAlertActionStyleDefault selector:confirm];
    [self presentViewController:controller animated:YES completion:NULL];
}

#pragma mark - PhotosAlbum bridge handler

AGX_STATIC NSString *const AGXSaveImageToAlbumParamsKey = @"AGXSaveImageToAlbumParams";

- (void)saveImageToAlbum:(NSDictionary *)params {
    NSString *savingCallback = [params itemForKey:@"savingCallback"];
    if (savingCallback) {
        [self.view evaluateJavaScript:
         [NSString stringWithFormat:@";(%@)();",
          savingCallback] completionHandler:NULL];
    } else {
        [self.view showLoadingHUD:YES title:[params itemForKey:@"savingTitle"]?:
         AGXWidgetLocalizedStringDefault(@"AGXWebView.saveImage.saving", @"Saving")];
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
        [self.view evaluateJavaScript:
         [NSString stringWithFormat:@";(%@)('Can not fetch image DATA');",
          failedCallback] completionHandler:NULL];
    } else {
        [self.view showMessageHUD:YES title:[params itemForKey:@"failedTitle"]?:
         AGXWidgetLocalizedStringDefault(@"AGXWebView.saveImage.failed", @"Failed") duration:2];
    }
}

// UIImageWriteToSavedPhotosAlbum completionSelector
- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo {
    NSDictionary *params = [image retainPropertyForAssociateKey:AGXSaveImageToAlbumParamsKey];
    if (error) {
        NSString *failedCallback = [params itemForKey:@"failedCallback"];
        if (failedCallback) {
            [self.view evaluateJavaScript:
             [NSString stringWithFormat:@";(%@)('%@');",
              failedCallback, error.localizedDescription] completionHandler:NULL];
        } else {
            [self.view showMessageHUD:YES title:[params itemForKey:@"failedTitle"]?:
             AGXWidgetLocalizedStringDefault(@"AGXWebView.saveImage.failed", @"Failed")
                               detail:error.localizedDescription duration:2];
        }
    } else {
        NSString *successCallback = [params itemForKey:@"successCallback"];
        if (successCallback) {
            [self.view evaluateJavaScript:
             [NSString stringWithFormat:@";(%@)();", successCallback] completionHandler:NULL];
        } else {
            [self.view showMessageHUD:YES title:[params itemForKey:@"successTitle"]?:
             AGXWidgetLocalizedStringDefault(@"AGXWebView.saveImage.success", @"Success") duration:2];
        }
    }
    [image setRetainProperty:NULL forAssociateKey:AGXSaveImageToAlbumParamsKey];
}

AGX_STATIC NSString *const AGXLoadImageCallbackKey = @"AGXLoadImageCallback";

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
    AGXPhotoPickerController *photoPicker = AGXPhotoPickerController.instance;
    photoPicker.allowPickingVideo = [[params itemForKey:@"allowPickingVideo"]?:@NO boolValue];
    photoPicker.allowPickingGif = [[params itemForKey:@"allowPickingGif"]?:@NO boolValue];
    photoPicker.allowPickingLivePhoto = [[params itemForKey:@"allowPickingLivePhoto"]?:@NO boolValue];
    photoPicker.sortByCreateDateDescending = [[params itemForKey:@"sortByCreateDateDescending"]?:@NO boolValue];
    photoPicker.allowAssetPreviewing = [[params itemForKey:@"allowAssetPreviewing"]?:@YES boolValue];
    photoPicker.allowPickingOriginal = [[params itemForKey:@"allowPickingOriginal"]?:@NO boolValue];
    photoPicker.pickingImageScale = [[params itemForKey:@"pickingImageScale"]?:@(UIScreen.mainScreen.scale) cgfloatValue];
    CGFloat pickingImageWidth = [[params itemForKey:@"pickingImageWidth"]?:@0 cgfloatValue];
    CGFloat pickingImageHeight = [[params itemForKey:@"pickingImageHeight"]?:@0 cgfloatValue];
    if (pickingImageWidth > 0 && pickingImageHeight > 0) {
        photoPicker.pickingImageSize = CGSizeMake(pickingImageWidth, pickingImageHeight);
    }
    NSString *callback = [params itemForKey:@"callback"];
    if (callback) {
        photoPicker.photoPickerDelegate = self;
        [photoPicker setRetainProperty:callback forAssociateKey:AGXLoadImageCallbackKey];
    }
    [self presentViewController:photoPicker animated:YES completion:NULL];
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
    AGXImagePickerController *camera = AGXImagePickerController.camera;
    camera.pickingImageScale = [[params itemForKey:@"pickingImageScale"]?:@(UIScreen.mainScreen.scale) cgfloatValue];
    CGFloat pickingImageWidth = [[params itemForKey:@"pickingImageWidth"]?:@0 cgfloatValue];
    CGFloat pickingImageHeight = [[params itemForKey:@"pickingImageHeight"]?:@0 cgfloatValue];
    if (pickingImageWidth > 0 && pickingImageHeight > 0) {
        camera.pickingImageSize = CGSizeMake(pickingImageWidth, pickingImageHeight);
    }
    NSNumber *editable = [params itemForKey:@"editable"];
    if (editable) camera.allowsEditing = [editable boolValue];
    NSString *callback = [params itemForKey:@"callback"];
    if (callback) {
        camera.imagePickerDelegate = self;
        [camera setRetainProperty:callback forAssociateKey:AGXLoadImageCallbackKey];
    }
    [self presentViewController:camera animated:YES completion:NULL];
}

- (void)loadImageFromAlbumOrCamera:(NSDictionary *)params {
    UIAlertController *controller = [UIAlertController alertControllerWithTitle:nil message:nil
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
    [self presentViewController:controller animated:YES completion:NULL];
}

// AGXPhotoPickerControllerDelegate

- (void)photoPickerController:(AGXPhotoPickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info {
    NSString *callbackJSString = [picker retainPropertyForAssociateKey:AGXLoadImageCallbackKey];
    if (!callbackJSString) return;
    [self.view evaluateJavaScript:
     [NSString stringWithFormat:@";(%@)('data:image/png;base64,%@');", callbackJSString,
      UIImagePNGRepresentation(info[AGXAlbumControllerPickedImage]).base64EncodedString] completionHandler:NULL];
    [picker setRetainProperty:NULL forAssociateKey:AGXLoadImageCallbackKey];
}

// AGXImagePickerControllerDelegate
- (void)imagePickerController:(AGXImagePickerController *)picker didFinishPickingImage:(UIImage *)image {
    NSString *callbackJSString = [picker retainPropertyForAssociateKey:AGXLoadImageCallbackKey];
    if (!callbackJSString) return;
    [self.view evaluateJavaScript:
     [NSString stringWithFormat:@";(%@)('data:image/png;base64,%@');",
      callbackJSString, UIImagePNGRepresentation(image).base64EncodedString] completionHandler:NULL];
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

AGX_STATIC const NSInteger AGXWKWebViewControllerCloseBarButtonTag = 131215195;

- (void)p_addCloseBarButton {
    if (self.navigationController.viewControllers.firstObject == self) return;
    if (!self.view.canGoBack) return;
    NSMutableArray *leftBarButtonItems = [NSMutableArray arrayWithArray:
                                          self.navigationItem.leftBarButtonItems];
    for (UIBarButtonItem *leftItem in leftBarButtonItems) {
        if (AGXWKWebViewControllerCloseBarButtonTag == leftItem.tag) return;
    }
    UIBarButtonItem *closeBarButton = [[UIBarButtonItem alloc]
                                       initWithTitle:AGXWidgetLocalizedStringDefault
                                       (@"AGXWebViewController.close", @"Close")
                                       style:UIBarButtonItemStylePlain
                                       target:self action:@selector(agxWKWebViewControllerClose:)];
    closeBarButton.tag = AGXWKWebViewControllerCloseBarButtonTag;
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

#pragma mark - private methods

- (void)cleanAGXBWKDisplayEventTimer {
    if ([_agxbWKDisplayEventTimer isValid])
        [_agxbWKDisplayEventTimer invalidate];
    AGX_RELEASE(_agxbWKDisplayEventTimer);
    _agxbWKDisplayEventTimer = nil;
}

@end

@implementation AGXWKWebViewControllerURLStringParser

- (id)parametricObjectWithURLString:(NSString *)URLString {
    return nil;
}

- (Class)webViewControllerClassWithURLString:(NSString *)URLString {
    return nil;
}

- (void)webViewController:(AGXWKWebViewController *)webViewController settingWithURLString:(NSString *)URLString {
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
        webViewController.navigationItem.title = [settings[@"navigationTitle"] stringDecodedForURL];
    }
    if (settings[@"addCloseButton"]) {
        webViewController.autoAddCloseBarButton = [settings[@"addCloseButton"] boolValue];
    }
    if (settings[@"pullDownRefresh"]) {
        webViewController.view.pullDownRefreshEnabled = [settings[@"pullDownRefresh"] boolValue];
    }
}

- (NSURLRequestCachePolicy)requestCachePolicyWithURLString:(NSString *)URLString {
    return NSURLRequestUseProtocolCachePolicy;
}

- (NSArray *)requestAttachedCookieNamesWithURLString:(NSString *)URLString {
    return nil;
}

- (NSDictionary *)requestAttachedHTTPHeaderFieldsWithURLString:(NSString *)URLString {
    return nil;
}

- (NSString *)localResourceBundleNameWithURLString:(NSString *)URLString {
    return nil;
}

- (void)webViewController:(AGXWKWebViewController *)webViewController loadRequestWithURLString:(NSString *)URLString {
    NSString *requestURLString = [URLString arraySeparatedByString:@"??" filterEmpty:YES][0];
    NSURL *requestURL = [NSURL URLWithString:requestURLString];

    if ([@"http" isEqualToString:requestURL.scheme] || [@"https" isEqualToString:requestURL.scheme]) {
        [webViewController.view loadRequestWithURLString:requestURLString cachePolicy:
         [self requestCachePolicyWithURLString:URLString] addCookieFieldWithNames:
         [self requestAttachedCookieNamesWithURLString:URLString] addHTTPHeaderFields:
         [self requestAttachedHTTPHeaderFieldsWithURLString:URLString]];

    } else if ([@"resources" isEqualToString:requestURL.scheme]) {
        [webViewController.view loadRequestWithResourcesFilePathString:requestURL.resourceSpecifier resourcesPattern:
         AGXResources.pattern.subpathAppendBundleNamed([self localResourceBundleNameWithURLString:URLString])];
    }
}

- (AGXWKWebViewController *)webViewControllerWithURLString:(NSString *)URLString defaultClass:(Class)defaultClass {
    NSString *encodedURLString = [URLString parametricStringWithObject:
                                  [self parametricObjectWithURLString:URLString]].stringEncodedForURL;
    Class controllerClass = [self webViewControllerClassWithURLString:encodedURLString]?:defaultClass;
    if AGX_EXPECT_F(![controllerClass isSubclassOfClass:AGXWKWebViewController.class]) {
        controllerClass = AGXWKWebViewController.class;
    }
    AGXWKWebViewController *webViewController = controllerClass.instance;
    [self webViewController:webViewController settingWithURLString:encodedURLString];
    [self webViewController:webViewController loadRequestWithURLString:encodedURLString];
    return webViewController;
}

@end
