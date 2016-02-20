//
//  UIViewController+AGXRuntime.m
//  AGXRuntime
//
//  Created by Char Aznable on 16/2/20.
//  Copyright © 2016年 AI-CUC-EC. All rights reserved.
//

#import "UIViewController+AGXRuntime.h"
#import "AGXProperty.h"
#import "NSObject+AGXRuntime.h"
#import <AGXCore/AGXCore/AGXArc.h>
#import <AGXCore/AGXCore/NSObject+AGXCore.h>

@category_implementation(UIViewController, AGXRuntime)

- (void)agxLoadView {
    [self agxLoadView];
    
    Class viewClass = [[[self class] agxPropertyForName:@"view"] objectClass];
    if (![viewClass isSubclassOfClass:[UIView class]]) return;
    self.view = AGX_AUTORELEASE([[viewClass alloc] initWithFrame:self.view.frame]);
}

+ (void)load {
    static dispatch_once_t once_t;
    dispatch_once(&once_t, ^{
        // swizzle loadView
        [self swizzleInstanceOriSelector:@selector(loadView)
                         withNewSelector:@selector(agxLoadView)];
    });
}

@end