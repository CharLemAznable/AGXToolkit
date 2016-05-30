//
//  AGXLabel.m
//  AGXWidget
//
//  Created by Char Aznable on 16/2/25.
//  Copyright © 2016年 AI-CUC-EC. All rights reserved.
//

#import "AGXLabel.h"
#import <AGXCore/AGXCore/AGXGeometry.h>
#import <AGXCore/AGXCore/NSObject+AGXCore.h>
#import <AGXCore/AGXCore/NSCoder+AGXCore.h>
#import <AGXCore/AGXCore/UIView+AGXCore.h>
#import <AGXCore/AGXCore/UILabel+AGXCore.h>

@implementation AGXLabel

- (void)agxInitial {
    [super agxInitial];
    self.userInteractionEnabled = YES;
    [self addGestureRecognizer:AGX_AUTORELEASE([[UILongPressGestureRecognizer alloc]
                                                initWithTarget:self action:@selector(longPress:)])];
    self.backgroundColor = [UIColor clearColor];
}

- (void)dealloc {
    [[UIMenuController sharedMenuController] setMenuVisible:NO animated:NO];
    _dataSource = nil;
    AGX_SUPER_DEALLOC;
}

- (AGX_INSTANCETYPE)initWithCoder:(NSCoder *)aDecoder {
    if (AGX_EXPECT_T(self = [super initWithCoder:aDecoder])) {
        _canCopy = [aDecoder decodeBoolForKey:@"canCopy"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [super encodeWithCoder:aCoder];
    [aCoder encodeBool:_canCopy forKey:@"canCopy"];
}

- (void)longPress:(UILongPressGestureRecognizer *)gestureRecognizer  {
    if (gestureRecognizer.state == UIGestureRecognizerStateBegan) {
        [gestureRecognizer.view becomeFirstResponder];

        UIMenuController *menuController = [UIMenuController sharedMenuController];
        NSString *copyTitle = [_dataSource respondsToSelector:@selector(menuTitleStringOfCopyInLabel:)]
        ? [_dataSource menuTitleStringOfCopyInLabel:self] : @"复制";
        menuController.menuItems = @[AGX_AUTORELEASE([[UIMenuItem alloc] initWithTitle:copyTitle
                                                                                action:@selector(agxCopy:)])];

        if ([_dataSource respondsToSelector:@selector(menuLocationPointInLabel:)]) {
            [menuController setTargetRect:AGX_CGRectMake([_dataSource menuLocationPointInLabel:self], CGSizeZero)
                                   inView:gestureRecognizer.view];
        } else {
            [menuController setTargetRect:AGX_CGRectMake([gestureRecognizer locationInView:gestureRecognizer.view], CGSizeZero)
                                   inView:gestureRecognizer.view];
        }
        [menuController setMenuVisible:YES animated:YES];
    }
}

- (BOOL)canBecomeFirstResponder {
    return YES;
}

- (BOOL)canPerformAction:(SEL)action withSender:(id)sender {
    return _canCopy && action == @selector(agxCopy:);
}

- (void)agxCopy:(id)sender {
    [UIPasteboard generalPasteboard].string = self.text;
}

@end
