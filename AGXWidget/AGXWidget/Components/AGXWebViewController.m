//
//  AGXWebViewController.m
//  AGXWidget
//
//  Created by Char Aznable on 16/3/6.
//  Copyright © 2016年 AI-CUC-EC. All rights reserved.
//

#import "AGXWebViewController.h"
#import "AGXProgressHUD.h"
#import "UINavigationController+AGXWidget.h"
#import <objc/runtime.h>
#import <AGXCore/AGXCore/AGXAdapt.h>
#import <AGXCore/AGXCore/AGXBundle.h>
#import <AGXCore/AGXCore/NSObject+AGXCore.h>
#import <AGXCore/AGXCore/NSString+AGXCore.h>
#import <AGXCore/AGXCore/NSDate+AGXCore.h>
#import <AGXCore/AGXCore/UIView+AGXCore.h>
#import <AGXCore/AGXCore/UIWindow+AGXCore.h>
#import <AGXCore/AGXCore/UIColor+AGXCore.h>
#import <AGXCore/AGXCore/UINavigationBar+AGXCore.h>
#import <AGXCore/AGXCore/UIActionSheet+AGXCore.h>
#import <AGXCore/AGXCore/UIAlertView+AGXCore.h>
#import <AGXCore/AGXCore/UIViewController+AGXCore.h>

@interface AGXWebViewController () <UIActionSheetDelegate>
@end

@implementation AGXWebViewController

@dynamic view;

- (AGX_INSTANCETYPE)init {
    if (self = [super init]) {
        _useDocumentTitle = YES;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    self.navigationItem.leftItemsSupplementBackButton = YES;
    self.view.delegate = self;

    [self.view registerHandlerName:@"setTitle" handler:self selector:@selector(setTitle:)];
    [self.view registerHandlerName:@"setPrompt" handler:self selector:@selector(setPrompt:)];
    [self.view registerHandlerName:@"setBackTitle" handler:self selector:@selector(setBackTitle:)];
    [self.view registerHandlerName:@"setChildBackTitle" handler:self selector:@selector(setChildBackTitle:)];
    [self.view registerHandlerName:@"setLeftButton" handler:self selector:@selector(setLeftButton:)];
    [self.view registerHandlerName:@"setRightButton" handler:self selector:@selector(setRightButton:)];
    [self.view registerHandlerName:@"toggleNavigationBar" handler:self selector:@selector(toggleNavigationBar:)];
    [self.view registerHandlerName:@"pushIn" handler:self selector:@selector(pushIn:)];
    [self.view registerHandlerName:@"popOut" handler:self selector:@selector(popOut:)];

    [self.view registerHandlerName:@"alert" handler:self selector:@selector(alert:)];
    [self.view registerHandlerName:@"confirm" handler:self selector:@selector(confirm:)];

    [self.view registerHandlerName:@"HUDMessage" handler:self selector:@selector(HUDMessage:)];
    [self.view registerHandlerName:@"HUDLoading" handler:self selector:@selector(HUDLoading:)];
    [self.view registerHandlerName:@"HUDLoaded" handler:self selector:@selector(HUDLoaded)];
}

- (void)registerHandlerName:(NSString *)handlerName handler:(id)handler selector:(SEL)selector {
    [self.view registerHandlerName:handlerName handler:handler selector:selector];
}

- (SEL)registerTriggerAt:(Class)triggerClass withBlock:(AGXBridgeTrigger)triggerBlock {
    return [self.view registerTriggerAt:triggerClass withBlock:triggerBlock];
}

- (SEL)registerTriggerAt:(Class)triggerClass withJavascript:(NSString *)javascript {
    return [self.view registerTriggerAt:triggerClass withJavascript:javascript];
}

- (Class)defaultPushViewControllerClass {
    return [AGXWebViewController class];
}

#pragma mark - UIWebViewDelegate

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    if (_useDocumentTitle) self.navigationItem.title
        = [self.view stringByEvaluatingJavaScriptFromString:@"document.title"];
}

#pragma mark - UINavigationController bridge handler

- (void)setTitle:(NSString *)title {
    self.navigationItem.title = title;
}

- (void)setPrompt:(NSString *)prompt {
    self.navigationItem.prompt = prompt;
}

- (void)setBackTitle:(NSString *)backTitle {
    self.navigationBar.topItem.hidesBackButton = !backTitle;
    self.navigationBar.backItem.backBarButtonItem = AGX_AUTORELEASE
    ([[UIBarButtonItem alloc] initWithTitle:backTitle?:@"" style:UIBarButtonItemStylePlain target:nil action:nil]);
}

- (void)setChildBackTitle:(NSString *)childBackTitle {
    self.navigationItem.backBarButtonItem =
    AGX_AUTORELEASE([[UIBarButtonItem alloc] initWithTitle:childBackTitle?:@"" style:UIBarButtonItemStylePlain
                                                    target:nil action:nil]);
}

- (void)setLeftButton:(NSDictionary *)setting {
    agx_async_main(self.navigationItem.leftBarButtonItem = [self p_createBarButtonItem:setting];)
}

- (void)setRightButton:(NSDictionary *)setting {
    agx_async_main(self.navigationItem.rightBarButtonItem = [self p_createBarButtonItem:setting];)
}

- (void)toggleNavigationBar:(NSDictionary *)setting {
    BOOL hidden = setting[@"hide"] ? [setting[@"hide"] boolValue] : !self.navigationBarHidden;
    BOOL animate = setting[@"animate"] ? [setting[@"animate"] boolValue] : YES;
    [self setNavigationBarHidden:hidden animated:animate];
}

NSString *AGXLocalResourceBundleName = nil;

- (void)pushIn:(NSDictionary *)setting {
    if (!setting[@"url"] && !setting[@"file"]) return;
    BOOL animate = setting[@"animate"] ? [setting[@"animate"] boolValue] : YES;

    AGXWebViewController *viewController;
    Class clz = setting[@"type"] ? objc_getClass([setting[@"type"] UTF8String]) : [self defaultPushViewControllerClass];
    if (AGX_EXPECT_F(![clz isSubclassOfClass:[AGXWebViewController class]])) return;
    viewController = clz.instance;

    viewController.hideNavigationBar = [setting[@"hideNav"] boolValue];
    agx_async_main(([self pushViewController:viewController animated:animate started:
                     ^(UIViewController *fromViewController, UIViewController *toViewController) {
                         if (![toViewController.view isKindOfClass:[AGXWebView class]]) return;
                         AGXWebView *view = (AGXWebView *)toViewController.view;
                         if (setting[@"url"]) {
                             [view loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:setting[@"url"]]]];
                             
                         } else if (setting[@"file"]) {
                             NSString *filePath = AGXBundle.bundleNameAs(AGXLocalResourceBundleName).filePath(setting[@"file"]);
                             NSString *strictPath = [[filePath substringToFirstString:@"?"] substringToFirstString:@"#"];
                             
                             [view loadHTMLString:[NSString stringWithContentsOfFile:strictPath encoding:NSUTF8StringEncoding error:nil]
                                          baseURL:[NSURL URLWithString:filePath]];
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

- (void)alert:(NSDictionary *)setting {
    SEL callback = [self registerTriggerAt:[self class] withJavascript:
                    [NSString stringWithFormat:@";(%@)();", setting[@"callback"]?:@"function(){}"]];

#if __IPHONE_OS_VERSION_MIN_REQUIRED < 80000
    if (AGX_BEFORE_IOS8) {
        [self p_alertAddCallbackWithStyle:setting[@"style"] callbackSelector:callback];
        [self p_alertShowWithStyle:setting[@"style"] title:setting[@"title"] message:setting[@"message"] buttonTitle:setting[@"button"]?:@"Cancel"];
        return;
    }
#endif
    UIAlertController *controller = [self p_alertControllerWithTitle:
                                     setting[@"title"] message:setting[@"message"] style:setting[@"style"]];
    [self p_alertController:controller addActionWithTitle:setting[@"button"]?:@"Cancel"
                      style:UIAlertActionStyleCancel selector:callback];
    agx_async_main([self presentViewController:controller animated:YES completion:NULL];)
}

- (void)confirm:(NSDictionary *)setting {
    SEL cancel = [self registerTriggerAt:[self class] withJavascript:
                  [NSString stringWithFormat:@";(%@)();", setting[@"cancelCallback"]?:@"function(){}"]];
    SEL confirm = [self registerTriggerAt:[self class] withJavascript:
                   [NSString stringWithFormat:@";(%@)();", setting[@"confirmCallback"]?:@"function(){}"]];

#if __IPHONE_OS_VERSION_MIN_REQUIRED < 80000
    if (AGX_BEFORE_IOS8) {
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
    agx_async_main([self presentViewController:controller animated:YES completion:NULL];)
}

- (void)HUDMessage:(NSDictionary *)setting {
    NSString *title = setting[@"title"], *message = setting[@"message"];
    if ((!title || [title isEmpty]) && (!message || [message isEmpty])) return;
    NSTimeInterval delay = setting[@"delay"] ? [setting[@"delay"] timeIntervalValue] : 2;
    BOOL fullScreen = setting[@"fullScreen"] ? [setting[@"fullScreen"] boolValue] : NO;
    UIView *view = fullScreen ? [UIWindow sharedKeyWindow] : self.view;
    agx_async_main([view showTextHUDWithText:title detailText:message hideAfterDelay:delay];)
}

- (void)HUDLoading:(NSDictionary *)setting {
    NSString *message = setting[@"message"];
    BOOL fullScreen = setting[@"fullScreen"] ? [setting[@"fullScreen"] boolValue] : NO;
    UIView *view = fullScreen ? [UIWindow sharedKeyWindow] : self.view;
    agx_async_main([view showIndeterminateHUDWithText:message];)
}

- (void)HUDLoaded {
    agx_async_main([[UIWindow sharedKeyWindow] hideRecursiveHUD:YES];);
}

#pragma mark - private methods: UIBarButtonItem

- (UIBarButtonItem *)p_createBarButtonItem:(NSDictionary *)barButtonSetting {
    NSString *title = barButtonSetting[@"title"];
    UIBarButtonSystemItem system = barButtonSystemItem(barButtonSetting[@"system"]);
    if (!title && system < 0) return nil;

    NSString *callback = barButtonSetting[@"callback"];
    id target = callback ? self : nil;
    SEL action = callback ? [self registerTriggerAt:[self class] withJavascript:
                             [NSString stringWithFormat:@";(%@)();", callback]] : nil;

    UIBarButtonItem *barButtonItem = nil;
    if (title) barButtonItem = [[UIBarButtonItem alloc]
                                initWithTitle:title style:UIBarButtonItemStylePlain target:target action:action];
    else barButtonItem = [[UIBarButtonItem alloc]
                          initWithBarButtonSystemItem:system target:target action:action];
    return AGX_AUTORELEASE(barButtonItem);
}

AGX_STATIC_INLINE UIBarButtonSystemItem barButtonSystemItem(NSString *systemStyle) {
    if ([systemStyle isCaseInsensitiveEqual:@"done"])           return UIBarButtonSystemItemDone;
    if ([systemStyle isCaseInsensitiveEqual:@"cancel"])         return UIBarButtonSystemItemCancel;
    if ([systemStyle isCaseInsensitiveEqual:@"edit"])           return UIBarButtonSystemItemEdit;
    if ([systemStyle isCaseInsensitiveEqual:@"save"])           return UIBarButtonSystemItemSave;
    if ([systemStyle isCaseInsensitiveEqual:@"add"])            return UIBarButtonSystemItemAdd;
    if ([systemStyle isCaseInsensitiveEqual:@"flexiblespace"])  return UIBarButtonSystemItemFlexibleSpace;
    if ([systemStyle isCaseInsensitiveEqual:@"fixedspace"])     return UIBarButtonSystemItemFixedSpace;
    if ([systemStyle isCaseInsensitiveEqual:@"compose"])        return UIBarButtonSystemItemCompose;
    if ([systemStyle isCaseInsensitiveEqual:@"reply"])          return UIBarButtonSystemItemReply;
    if ([systemStyle isCaseInsensitiveEqual:@"action"])         return UIBarButtonSystemItemAction;
    if ([systemStyle isCaseInsensitiveEqual:@"organize"])       return UIBarButtonSystemItemOrganize;
    if ([systemStyle isCaseInsensitiveEqual:@"bookmarks"])      return UIBarButtonSystemItemBookmarks;
    if ([systemStyle isCaseInsensitiveEqual:@"search"])         return UIBarButtonSystemItemSearch;
    if ([systemStyle isCaseInsensitiveEqual:@"refresh"])        return UIBarButtonSystemItemRefresh;
    if ([systemStyle isCaseInsensitiveEqual:@"stop"])           return UIBarButtonSystemItemStop;
    if ([systemStyle isCaseInsensitiveEqual:@"camera"])         return UIBarButtonSystemItemCamera;
    if ([systemStyle isCaseInsensitiveEqual:@"trash"])          return UIBarButtonSystemItemTrash;
    if ([systemStyle isCaseInsensitiveEqual:@"play"])           return UIBarButtonSystemItemPlay;
    if ([systemStyle isCaseInsensitiveEqual:@"pause"])          return UIBarButtonSystemItemPause;
    if ([systemStyle isCaseInsensitiveEqual:@"rewind"])         return UIBarButtonSystemItemRewind;
    if ([systemStyle isCaseInsensitiveEqual:@"fastforward"])    return UIBarButtonSystemItemFastForward;
    if ([systemStyle isCaseInsensitiveEqual:@"undo"])           return UIBarButtonSystemItemUndo;
    if ([systemStyle isCaseInsensitiveEqual:@"redo"])           return UIBarButtonSystemItemRedo;
    if ([systemStyle isCaseInsensitiveEqual:@"pagecurl"])       return UIBarButtonSystemItemPageCurl;
    return -1;
}

#pragma mark - private methods: UIActionSheet/UIAlertView

#if __IPHONE_OS_VERSION_MIN_REQUIRED < 80000

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
                        showInView:[UIWindow sharedKeyWindow]];)
    } else agx_async_main([[UIAlertView alertViewWithTitle:title message:message delegate:self
                                         cancelButtonTitle:buttonTitle otherButtonTitles:nil] show];)
}

- (void)p_confirmShowWithStyle:(NSString *)style title:(NSString *)title message:(NSString *)message cancelTitle:(NSString *)cancelTitle confirmTitle:(NSString *)confirmTitle {
    if ([style isCaseInsensitiveEqualToString:@"sheet"]) {
        agx_async_main(([[UIActionSheet actionSheetWithTitle:title?:message delegate:self cancelButtonTitle:cancelTitle
                                      destructiveButtonTitle:nil otherButtonTitles:confirmTitle, nil]
                         showInView:[UIWindow sharedKeyWindow]]);)
    } else agx_async_main(([[UIAlertView alertViewWithTitle:title message:message delegate:self
                                          cancelButtonTitle:cancelTitle otherButtonTitles:confirmTitle, nil] show]);)
}

#endif // __IPHONE_OS_VERSION_MIN_REQUIRED < 80000

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

@end
