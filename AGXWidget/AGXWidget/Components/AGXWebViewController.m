//
//  AGXWebViewController.m
//  AGXWidget
//
//  Created by Char Aznable on 2016/3/6.
//  Copyright © 2016年 AI-CUC-EC. All rights reserved.
//

#import <objc/runtime.h>
#import <AGXCore/AGXCore/AGXMath.h>
#import <AGXCore/AGXCore/AGXBundle.h>
#import <AGXCore/AGXCore/NSObject+AGXCore.h>
#import <AGXCore/AGXCore/NSString+AGXCore.h>
#import <AGXCore/AGXCore/NSURLRequest+AGXCore.h>
#import <AGXCore/AGXCore/UIApplication+AGXCore.h>
#import <AGXCore/AGXCore/UIView+AGXCore.h>
#import <AGXCore/AGXCore/UIViewController+AGXCore.h>
#import <AGXCore/AGXCore/UIWebView+AGXCore.h>
#import <AGXCore/AGXCore/UIGestureRecognizer+AGXCore.h>
#import "AGXWebViewController.h"
#import "AGXWidgetLocalization.h"
#import "UINavigationController+AGXWidget.h"
#import "AGXGestureRecognizerTags.h"

@interface AGXWebViewController () <UIGestureRecognizerDelegate>
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
        self.title = AGXWidgetLocalizedStringDefault
        (@"AGXWebViewController.initialTitle", AGXBundle.appBundleName);

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

    REGISTER("setTitle", setTitle:);
    REGISTER("setPrompt", setPrompt:);
    REGISTER("setBackTitle", setBackTitle:);
    REGISTER("setChildBackTitle", setChildBackTitle:);
    REGISTER("setLeftButton", setLeftButton:);
    REGISTER("setRightButton", setRightButton:);
    REGISTER("toggleNavigationBar", toggleNavigationBar:);
    REGISTER("pushIn", pushIn:);
    REGISTER("popOut", popOut:);

#undef REGISTER
}

- (BOOL)navigationShouldPopOnBackBarButton {
    if (_goBackOnBackBarButton && self.view.canGoBack) {
        [self.view goBack];
        return NO;
    }
    return [super navigationShouldPopOnBackBarButton];
}

+ (NSString *)localResourceBundleName {
    return nil;
}

+ (Class)defaultPushViewControllerClass {
    return [AGXWebViewController class];
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

static NSInteger AGXWebViewControllerCloseBarButtonTag = 31215195;

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    if (_useDocumentTitle) self.title
        = [self.view stringByEvaluatingJavaScriptFromString:@"document.title"];

    if (_autoAddCloseBarButton) {
        if (self.navigationController.viewControllers.firstObject == self) return;
        if (!self.view.canGoBack) return;
        for (UIBarButtonItem *leftItem in self.navigationItem.leftBarButtonItems) {
            if (AGXWebViewControllerCloseBarButtonTag == leftItem.tag) return;
        }

        NSMutableArray *leftBarButtonItems = [NSMutableArray arrayWithArray:self.navigationItem.leftBarButtonItems];
        UIBarButtonItem *closeBarButton = [[UIBarButtonItem alloc]
                                           initWithTitle:AGXWidgetLocalizedStringDefault(@"AGXWebViewController.close", @"Close")
                                           style:UIBarButtonItemStylePlain
                                           target:self action:@selector(agxWebViewControllerClose:)];
        closeBarButton.tag = AGXWebViewControllerCloseBarButtonTag;
        [leftBarButtonItems insertObject:AGX_AUTORELEASE(closeBarButton) atIndex:0];
        self.navigationItem.leftBarButtonItems = leftBarButtonItems;
    }
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {}

#pragma mark - UIGestureRecognizerDelegate

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
    return(_goBackOnPopGesture && gestureRecognizer == _goBackPanGestureRecognizer && self.view.canGoBack);
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return(otherGestureRecognizer.agxTag != AGXNavigationControllerInternalPopGestureTag);
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

    if (panGestureRecognizer.state == UIGestureRecognizerStateBegan) {
        // store scrollEnabled state and disabled in gesture progress
        _scrollEnabledTemp = self.view.scrollView.scrollEnabled;
        self.view.scrollView.scrollEnabled = NO;

        _previewImageView.frame = self.view.frame;
        _previewImageView.image = _historyRequestURLAndSnapshotArray.lastObject[@"snapshot"];
        [self.view.superview insertSubview:_previewImageView belowSubview:self.view];

        _previewImageView.transform = CGAffineTransformTranslate
        (CGAffineTransformIdentity, (progress - 1) * previewOffset, 0);
        self.view.transform = CGAffineTransformTranslate(CGAffineTransformIdentity, progress * windowWidth, 0);

    } else if (panGestureRecognizer.state == UIGestureRecognizerStateChanged) {
        _previewImageView.transform = CGAffineTransformTranslate
        (CGAffineTransformIdentity, (progress - 1) * previewOffset, 0);
        self.view.transform = CGAffineTransformTranslate(CGAffineTransformIdentity, progress * windowWidth, 0);
        _panGestureDirection = progress > _lastPercentProgress ? NSOrderedAscending : progress < _lastPercentProgress;
        _lastPercentProgress = progress;

    } else if (panGestureRecognizer.state == UIGestureRecognizerStateEnded ||
               panGestureRecognizer.state == UIGestureRecognizerStateCancelled) {
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

- (void)setTitle:(NSString *)title {
    agx_async_main
    (super.title = title;
     self.navigationItem.title = title;)
}

- (void)setPrompt:(NSString *)prompt {
    agx_async_main
    (self.navigationItem.prompt = prompt;)
}

- (void)setBackTitle:(NSString *)backTitle {
    agx_async_main
    (self.navigationBar.topItem.hidesBackButton = !backTitle;
     self.backBarButtonTitle = backTitle;)
}

- (void)setChildBackTitle:(NSString *)childBackTitle {
    agx_async_main
    (self.navigationItem.backBarButtonItem =
     AGX_AUTORELEASE([[UIBarButtonItem alloc] initWithTitle:childBackTitle?:@"" style:UIBarButtonItemStylePlain
                                                     target:nil action:nil]);)
}

static NSInteger AGXWebViewControllerLeftBarButtonTag = 125620;

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
     self.navigationItem.leftBarButtonItems = leftBarButtonItems;)
}

- (void)setRightButton:(NSDictionary *)setting {
    agx_async_main(self.navigationItem.rightBarButtonItem = [self p_createBarButtonItem:setting];)
}

- (void)toggleNavigationBar:(NSDictionary *)setting {
    BOOL hidden = setting[@"hide"] ? [setting[@"hide"] boolValue] : !self.navigationBarHidden;
    BOOL animate = setting[@"animate"] ? [setting[@"animate"] boolValue] : YES;
    agx_async_main([self setNavigationBarHidden:hidden animated:animate];)
}

- (void)pushIn:(NSDictionary *)setting {
    if AGX_EXPECT_F(!setting[@"url"] && !setting[@"file"]) return;
    BOOL animate = setting[@"animate"] ? [setting[@"animate"] boolValue] : YES;

    Class clz = setting[@"type"] ? objc_getClass([setting[@"type"] UTF8String])
    : self.class.defaultPushViewControllerClass;
    if AGX_EXPECT_F(![clz isSubclassOfClass:[AGXWebViewController class]]) return;
    agx_async_main(AGXWebViewController *viewController = clz.instance;

                   viewController.navigationBarHiddenFlag = [setting[@"hideNav"] boolValue];
                   viewController.hidesBarsOnSwipeFlag = [setting[@"hideNavOnSwipe"] boolValue];
                   viewController.hidesBarsOnTapFlag = [setting[@"hideNavOnTap"] boolValue];
                   ([self pushViewController:viewController animated:animate started:
                     ^(UIViewController *fromViewController, UIViewController *toViewController) {
                         if (![toViewController.view isKindOfClass:[AGXWebView class]]) return;
                         AGXWebView *view = (AGXWebView *)toViewController.view;
                         if (setting[@"url"]) {
                             [view loadRequestWithURLString:setting[@"url"]];

                         } else if (setting[@"file"]) {
                             NSString *filePath = AGXBundle
                             .bundleNameAs(self.class.localResourceBundleName)
                             .filePath(setting[@"file"]);

                             [view loadRequestWithURLString:filePath];
                         }
                     } finished:NULL]);)
}

- (void)popOut:(NSDictionary *)setting {
    NSArray *viewControllers = self.navigationController.viewControllers;
    if (viewControllers.count <= 1) return;

    BOOL animate = setting[@"animate"] ? [setting[@"animate"] boolValue] : YES;
    NSInteger count = MAX([setting[@"count"] integerValue], 1);
    NSUInteger index = viewControllers.count < count + 1 ? 0 : viewControllers.count - count - 1;
    agx_async_main([self popToViewController:viewControllers[index] animated:animate];)
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

- (UIBarButtonItem *)p_createBarButtonItem:(NSDictionary *)barButtonSetting {
    NSString *title = barButtonSetting[@"title"];
    UIBarButtonSystemItem system = barButtonSystemItem(barButtonSetting[@"system"]);
    if AGX_EXPECT_F(!title && system < 0) return nil;

    NSString *callback = barButtonSetting[@"callback"];
    id target = callback ? self : nil;
    SEL action = callback ? [self.view registerTriggerAt:[self class] withJavascript:callback] : nil;

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

@end
