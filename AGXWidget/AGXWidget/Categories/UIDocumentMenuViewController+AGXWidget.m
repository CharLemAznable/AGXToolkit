//
//  UIDocumentMenuViewController+AGXWidget.m
//  AGXWidget
//
//  Created by Char Aznable on 17/7/27.
//  Copyright © 2017 github.com/CharLemAznable. All rights reserved.
//

#import <AGXCore/AGXCore/AGXArc.h>
#import <AGXCore/AGXCore/NSObject+AGXCore.h>
#import <AGXCore/AGXCore/NSString+AGXCore.h>
#import "UIDocumentMenuViewController+AGXWidget.h"

@implementation UIDocumentMenuViewController (AGXWidget)

AGX_STATIC NSString *AGX_static_menuOptionFilter = nil;

+ (NSString *)menuOptionFilter {
    return AGX_static_menuOptionFilter;
}

+ (void)setMenuOptionFilter:(NSString *)menuOptionFilter {
    NSString *temp = [menuOptionFilter copy];
    AGX_RELEASE(AGX_static_menuOptionFilter);
    AGX_static_menuOptionFilter = temp;
}

- (void)AGXWidget_UIDocumentMenuViewController_addOptionWithTitle:(NSString *)title image:(UIImage *)image order:(UIDocumentMenuOrder)order handler:(void (^)(void))handler {
    if ((AGX_static_menuOptionFilter.length == 0) ||
        [title containsAnyOfStringInArray:[AGX_static_menuOptionFilter arraySeparatedByString:@"|" filterEmpty:YES]])
        [self AGXWidget_UIDocumentMenuViewController_addOptionWithTitle:title image:image order:order handler:handler];
}

- (void)AGXWidget_UIDocumentMenuViewController_viewDidLayoutSubviews {
    [self AGXWidget_UIDocumentMenuViewController_viewDidLayoutSubviews];
    [UIDocumentMenuViewController setMenuOptionFilter:@""];
}

+ (void)load {
    agx_once
    ([UIDocumentMenuViewController
      swizzleInstanceOriSelector:@selector(addOptionWithTitle:image:order:handler:)
      withNewSelector:@selector(AGXWidget_UIDocumentMenuViewController_addOptionWithTitle:image:order:handler:)];
     [UIDocumentMenuViewController
      swizzleInstanceOriSelector:@selector(viewDidLayoutSubviews)
      withNewSelector:@selector(AGXWidget_UIDocumentMenuViewController_viewDidLayoutSubviews)];);
}

@end
