//
//  AGXImageView.m
//  AGXWidget
//
//  Created by Char Aznable on 2016/2/25.
//  Copyright © 2016 github.com/CharLemAznable. All rights reserved.
//

#import <AGXCore/AGXCore/AGXGeometry.h>
#import <AGXCore/AGXCore/UIView+AGXCore.h>
#import "AGXImageView.h"
#import "AGXWidgetLocalization.h"

@implementation AGXImageView

- (void)agxInitial {
    [super agxInitial];
    self.userInteractionEnabled = YES;
    [self addGestureRecognizer:AGX_AUTORELEASE([[UILongPressGestureRecognizer alloc]
                                                initWithTarget:self action:@selector(longPress:)])];
}

- (void)dealloc {
    [UIMenuController.sharedMenuController setMenuVisible:NO animated:NO];
    _delegate = nil;
    AGX_SUPER_DEALLOC;
}

- (AGX_INSTANCETYPE)initWithCoder:(NSCoder *)aDecoder {
    if AGX_EXPECT_T(self = [super initWithCoder:aDecoder]) {
        _canCopy = [aDecoder decodeBoolForKey:@"canCopy"];
        _canSave = [aDecoder decodeBoolForKey:@"canSave"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [super encodeWithCoder:aCoder];
    [aCoder encodeBool:_canCopy forKey:@"canCopy"];
    [aCoder encodeBool:_canSave forKey:@"canSave"];
}

- (void)longPress:(UILongPressGestureRecognizer *)gestureRecognizer  {
    if (UIGestureRecognizerStateBegan == gestureRecognizer.state) {
        [gestureRecognizer.view becomeFirstResponder];

        UIMenuController *menuController = UIMenuController.sharedMenuController;
        menuController.menuItems = @[AGX_AUTORELEASE([[UIMenuItem alloc] initWithTitle:AGXWidgetLocalizedStringDefault
                                                      (@"AGXImageView.copyTitle", @"Copy") action:@selector(agxCopy:)]),
                                     AGX_AUTORELEASE([[UIMenuItem alloc] initWithTitle:AGXWidgetLocalizedStringDefault
                                                      (@"AGXImageView.saveTitle", @"Save") action:@selector(agxSave:)])];

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
    return((_canCopy && @selector(agxCopy:) == action) ||
           (_canSave && @selector(agxSave:) == action));
}

- (void)agxCopy:(id)sender {
    if AGX_EXPECT_F(!self.image) return;
    UIPasteboard.generalPasteboard.image = self.image;
}

- (void)agxSave:(id)sender {
    if AGX_EXPECT_F(!self.image) return;
    UIImageWriteToSavedPhotosAlbum(self.image, self, @selector(image:didFinishSavingWithError:contextInfo:), nil);
}

- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo {
    if (error && [_delegate respondsToSelector:@selector(saveImageFailedInImageView:withError:)]) {
        [_delegate saveImageFailedInImageView:self withError:error];
    } else if ([_delegate respondsToSelector:@selector(saveImageSuccessInImageView:)]) {
        [_delegate saveImageSuccessInImageView:self];
    }
}

@end
