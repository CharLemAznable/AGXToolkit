//
//  AGXLabel.m
//  AGXWidget
//
//  Created by Char Aznable on 2016/2/25.
//  Copyright © 2016 github.com/CharLemAznable. All rights reserved.
//

#import <AGXCore/AGXCore/AGXGeometry.h>
#import <AGXCore/AGXCore/NSObject+AGXCore.h>
#import <AGXCore/AGXCore/NSCoder+AGXCore.h>
#import <AGXCore/AGXCore/UIView+AGXCore.h>
#import <AGXCore/AGXCore/UILabel+AGXCore.h>
#import "AGXLabel.h"
#import "AGXWidgetLocalization.h"

@implementation AGXLabel

- (void)agxInitial {
    [super agxInitial];
    self.userInteractionEnabled = YES;
    [self addGestureRecognizer:AGX_AUTORELEASE([[UILongPressGestureRecognizer alloc]
                                                initWithTarget:self action:@selector(longPress:)])];
    self.backgroundColor = UIColor.clearColor;
}

- (void)dealloc {
    [UIMenuController.sharedMenuController setMenuVisible:NO animated:NO];
    AGX_SUPER_DEALLOC;
}

- (AGX_INSTANCETYPE)initWithCoder:(NSCoder *)aDecoder {
    if AGX_EXPECT_T(self = [super initWithCoder:aDecoder]) {
        _canCopy = [aDecoder decodeBoolForKey:@"canCopy"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [super encodeWithCoder:aCoder];
    [aCoder encodeBool:_canCopy forKey:@"canCopy"];
}

- (void)longPress:(UILongPressGestureRecognizer *)gestureRecognizer  {
    if (UIGestureRecognizerStateBegan == gestureRecognizer.state) {
        [gestureRecognizer.view becomeFirstResponder];

        UIMenuController *menuController = UIMenuController.sharedMenuController;
        menuController.menuItems = @[AGX_AUTORELEASE([[UIMenuItem alloc] initWithTitle:AGXWidgetLocalizedStringDefault
                                                      (@"AGXLabel.copyTitle", @"Copy") action:@selector(agxCopy:)])];

        [menuController setTargetRect:AGX_CGRectMake([gestureRecognizer locationInView:
                                                      gestureRecognizer.view], CGSizeZero)
                               inView:gestureRecognizer.view];
        [menuController setMenuVisible:YES animated:YES];
    }
}

- (BOOL)canBecomeFirstResponder {
    return YES;
}

- (BOOL)canPerformAction:(SEL)action withSender:(id)sender {
    return _canCopy && @selector(agxCopy:) == action;
}

- (void)agxCopy:(id)sender {
    UIPasteboard.generalPasteboard.string = self.text;
}

@end
