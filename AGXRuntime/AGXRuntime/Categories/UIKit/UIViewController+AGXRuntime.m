//
//  UIViewController+AGXRuntime.m
//  AGXRuntime
//
//  Created by Char Aznable on 16/2/20.
//  Copyright © 2016年 AI-CUC-EC. All rights reserved.
//

#import <AGXCore/AGXCore/AGXArc.h>
#import <AGXCore/AGXCore/NSObject+AGXCore.h>
#import "UIViewController+AGXRuntime.h"
#import "AGXProperty.h"
#import "NSObject+AGXRuntime.h"

@category_implementation(UIViewController, AGXRuntime)

- (void)AGXRuntime_UIViewController_loadView {
    [self AGXRuntime_UIViewController_loadView];

    Class viewClass = [[[self class] agxPropertyForName:@"view"] objectClass];
    if AGX_EXPECT_F(![viewClass isProperSubclassOfClass:[UIView class]]) return;
    AGXLog(@"AGXRuntime Autowired view of: %@", [self class]);
    self.view = AGX_AUTORELEASE([[viewClass alloc] initWithFrame:self.view.frame]);
}

+ (void)load {
    agx_once
    ([UIViewController swizzleInstanceOriSelector:@selector(loadView)
                                  withNewSelector:@selector(AGXRuntime_UIViewController_loadView)];)
}

@end
