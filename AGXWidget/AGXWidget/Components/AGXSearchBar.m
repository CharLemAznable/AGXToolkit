//
//  AGXSearchBar.m
//  AGXWidget
//
//  Created by Char Aznable on 2016/2/25.
//  Copyright © 2016 github.com/CharLemAznable. All rights reserved.
//

#import <AGXCore/AGXCore/UIApplication+AGXCore.h>
#import <AGXCore/AGXCore/UIView+AGXCore.h>
#import "AGXSearchBar.h"
#import "AGXWidgetLocalization.h"
#import "UIView+AGXWidgetAnimation.h"

CGSize searchBarTextFieldDefaultSize = {300, 30};

@interface AGXSearchBar () <UITextFieldDelegate> {
    UIControl *_mask;
}
@end

@implementation AGXSearchBar

@dynamic maskBackgroundColor;
@dynamic searchText;

- (void)agxInitial {
    [super agxInitial];
    self.backgroundColor = UIColor.lightGrayColor;

    _searchTextField = [[UITextField alloc] initWithFrame:
                        CGRectMake(0, 0, searchBarTextFieldDefaultSize.width,
                                   searchBarTextFieldDefaultSize.height)];
    _searchTextField.font = [UIFont systemFontOfSize:searchBarTextFieldDefaultSize.height / 2];
    _searchTextField.textColor = UIColor.blackColor;
    [_searchTextField setValue:UIColor.grayColor forKeyPath:@"_placeholderLabel.textColor"];
    _searchTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
    _searchTextField.returnKeyType = UIReturnKeySearch;
    _searchTextField.delegate = self;
    [self addSubview:_searchTextField];

    _mask = [[UIControl alloc] initWithFrame:UIScreen.mainScreen.bounds];
    [_mask addTarget:self action:@selector(maskTouched:) forControlEvents:UIControlEventTouchUpInside];

    AGXAddNotificationWithObject(searchTextFieldTextDidChange:, UITextFieldTextDidChangeNotification, _searchTextField);
}

- (void)layoutSubviews {
    [super layoutSubviews];
    _searchTextField.placeholder = AGXWidgetLocalizedStringDefault(@"AGXSearchBar.placeholder", @"Search");
    if ([self isEqual:_searchTextField.superview]) {
        _searchTextField.center = CGPointMake(self.bounds.size.width / 2,
                                              self.bounds.size.height / 2);
    }
}

- (void)dealloc {
    AGXRemoveNotificationWithObject(UITextFieldTextDidChangeNotification, _searchTextField);
    _delegate = nil;

    AGX_RELEASE(_searchTextField);
    AGX_RELEASE(_mask);
    AGX_SUPER_DEALLOC;
}

- (void)setSearchTextField:(UITextField *)searchTextField {
    if AGX_EXPECT_F([_searchTextField isEqual:searchTextField]) return;

    [_searchTextField.superview addSubview:searchTextField];
    [_searchTextField removeFromSuperview];

    AGXRemoveNotificationWithObject(UITextFieldTextDidChangeNotification, _searchTextField);
    AGX_RELEASE(_searchTextField);
    _searchTextField = AGX_RETAIN(searchTextField);
    _searchTextField.delegate = self;
    AGXAddNotificationWithObject(searchTextFieldTextDidChange:, UITextFieldTextDidChangeNotification, _searchTextField);
}

- (UIColor *)maskBackgroundColor {
    return _mask.backgroundColor;
}

- (void)setMaskBackgroundColor:(UIColor *)maskBackgroundColor {
    _mask.backgroundColor = maskBackgroundColor;
}

- (NSString *)searchText {
    return _searchTextField.text;
}

- (void)setSearchText:(NSString *)searchText {
    _searchTextField.text = searchText;
}

#pragma mark - User Event

- (void)maskTouched:(id)sender {
    if AGX_EXPECT_F(![sender isEqual:_mask]) return;

    [_searchTextField resignFirstResponder];
    [self addSubview:_searchTextField];
    _searchTextField.center = [_mask convertPoint:_searchTextField.center toView:self];
    [_mask agxAnimate:AGXAnimationMake(AGXAnimateOut|AGXAnimateFade, AGXAnimateStay, 0.1, 0)
           completion:^{ [_mask removeFromSuperview]; }];
}

#pragma mark - UITextFieldDelegate

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    [UIApplication.sharedKeyWindow addSubview:_mask];
    [_mask addSubview:_searchTextField];
    _searchTextField.center = [self convertPoint:_searchTextField.center toView:_mask];

    if (![_delegate respondsToSelector:@selector(searchBarDidBeginInput:)]) return;
    [_delegate searchBarDidBeginInput:self];
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    if (![_delegate respondsToSelector:@selector(searchBarDidEndInput:)]) return;
    [_delegate searchBarDidEndInput:self];
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    if (![_delegate respondsToSelector:@selector(searchBar:searchWithText:editEnded:)]) return YES;

    if ([string isEqualToString:@"\n"]) {
        [_delegate searchBar:self searchWithText:_searchTextField.text editEnded:YES];
        [self maskTouched:_searchTextField.superview];
        return NO;
    }
    return YES;
}

#pragma mark - UITextFieldTextDidChangeNotification

- (void)searchTextFieldTextDidChange:(NSNotification *)notification {
    UITextField *textField = (UITextField *)notification.object;
    if (textField.markedTextRange) return;
    if (![_delegate respondsToSelector:@selector(searchBar:searchWithText:editEnded:)]) return;
    [_delegate searchBar:self searchWithText:textField.text editEnded:NO];
}

@end
