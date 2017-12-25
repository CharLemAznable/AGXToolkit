//
//  AGXImageView.m
//  AGXWidget
//
//  Created by Char Aznable on 16/2/25.
//  Copyright © 2016年 AI-CUC-EC. All rights reserved.
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
    [[UIMenuController sharedMenuController] setMenuVisible:NO animated:NO];
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
    if (gestureRecognizer.state == UIGestureRecognizerStateBegan) {
        [gestureRecognizer.view becomeFirstResponder];

        UIMenuController *menuController = [UIMenuController sharedMenuController];
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
    return((_canCopy && action == @selector(agxCopy:)) ||
           (_canSave && action == @selector(agxSave:)));
}

- (void)agxCopy:(id)sender {
    if AGX_EXPECT_F(!self.image) return;
    [UIPasteboard generalPasteboard].image = self.image;
}

- (void)agxSave:(id)sender {
    if AGX_EXPECT_F(!self.image) return;
    UIImageWriteToSavedPhotosAlbum(self.image, self, @selector(image:didFinishSavingWithError:contextInfo:), nil);
}

- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo {
    if (error && [self.delegate respondsToSelector:@selector(saveImageFailedInImageView:withError:)]) {
        [self.delegate saveImageFailedInImageView:self withError:error];
    } else if ([self.delegate respondsToSelector:@selector(saveImageSuccessInImageView:)]) {
        [self.delegate saveImageSuccessInImageView:self];
    }
}

@end
