//
//  AGXImageView.m
//  AGXWidget
//
//  Created by Char Aznable on 16/2/25.
//  Copyright © 2016年 AI-CUC-EC. All rights reserved.
//

#import "AGXImageView.h"
#import <AGXCore/AGXCore/AGXGeometry.h>
#import <AGXCore/AGXCore/UIView+AGXCore.h>

@implementation AGXImageView

- (void)agxInitial {
    [super agxInitial];
    self.userInteractionEnabled = YES;
    [self addGestureRecognizer:AGX_AUTORELEASE([[UILongPressGestureRecognizer alloc]
                                                initWithTarget:self action:@selector(longPress:)])];
}

- (void)dealloc {
    [[UIMenuController sharedMenuController] setMenuVisible:NO animated:NO];
    _dataSource = nil;
    _delegate = nil;
    AGX_SUPER_DEALLOC;
}

- (AGX_INSTANCETYPE)initWithCoder:(NSCoder *)aDecoder {
    if (AGX_EXPECT_T(self = [super initWithCoder:aDecoder])) {
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
        NSString *copyTitle = [_dataSource respondsToSelector:@selector(menuTitleStringOfCopyInImageView:)]
        ? [_dataSource menuTitleStringOfCopyInImageView:self] : @"复制";
        NSString *saveTitle = [_dataSource respondsToSelector:@selector(menuTitleStringOfSaveInImageView:)]
        ? [_dataSource menuTitleStringOfSaveInImageView:self] : @"保存";
        menuController.menuItems = @[AGX_AUTORELEASE([[UIMenuItem alloc] initWithTitle:copyTitle
                                                                                action:@selector(agxCopy:)]),
                                     AGX_AUTORELEASE([[UIMenuItem alloc] initWithTitle:saveTitle
                                                                                action:@selector(agxSave:)])];

        if ([_dataSource respondsToSelector:@selector(menuLocationPointInImageView:)]) {
            [menuController setTargetRect:AGX_CGRectMake([_dataSource menuLocationPointInImageView:self], CGSizeZero)
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
    return ((_canCopy && action == @selector(agxCopy:)) ||
            (_canSave && action == @selector(agxSave:)));
}

- (void)agxCopy:(id)sender {
    if (!self.image) return;
    [UIPasteboard generalPasteboard].image = self.image;
}

- (void)agxSave:(id)sender {
    if (!self.image) return;
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
