//
//  AGXSearchBar.m
//  AGXWidget
//
//  Created by Char Aznable on 16/2/25.
//  Copyright © 2016年 AI-CUC-EC. All rights reserved.
//

#import "AGXSearchBar.h"
#import "UIView+AGXWidgetAnimation.h"
#import <AGXCore/AGXCore/UIApplication+AGXCore.h>
#import <AGXCore/AGXCore/UIView+AGXCore.h>

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
    self.backgroundColor = [UIColor lightGrayColor];

    _searchTextField = [[UITextField alloc] initWithFrame:
                        CGRectMake(0, 0, searchBarTextFieldDefaultSize.width,
                                   searchBarTextFieldDefaultSize.height)];
    _searchTextField.font = [UIFont systemFontOfSize:searchBarTextFieldDefaultSize.height / 2];
    _searchTextField.textColor = [UIColor blackColor];
    [_searchTextField setValue:[UIColor grayColor] forKeyPath:@"_placeholderLabel.textColor"];
    _searchTextField.placeholder = @"请输入搜索内容";
    _searchTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
    _searchTextField.returnKeyType = UIReturnKeySearch;
    _searchTextField.delegate = self;
    [self addSubview:_searchTextField];

    _mask = [[UIControl alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    [_mask addTarget:self action:@selector(maskTouched:) forControlEvents:UIControlEventTouchUpInside];

    AGXAddNotificationWithObject(searchTextFieldTextDidChange:, UITextFieldTextDidChangeNotification, _searchTextField);
}

- (void)layoutSubviews {
    [super layoutSubviews];
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
    if (AGX_EXPECT_F([_searchTextField isEqual:searchTextField])) return;

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
    if (AGX_EXPECT_F(![sender isEqual:_mask])) return;

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

    if (![self.delegate respondsToSelector:@selector(searchBarDidBeginInput:)]) return;
    [self.delegate searchBarDidBeginInput:self];
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    if (![self.delegate respondsToSelector:@selector(searchBarDidEndInput:)]) return;
    [self.delegate searchBarDidEndInput:self];
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    if (![self.delegate respondsToSelector:@selector(searchBar:searchWithText:editEnded:)]) return YES;

    if ([string isEqualToString:@"\n"]) {
        [self.delegate searchBar:self searchWithText:_searchTextField.text editEnded:YES];
        [self maskTouched:_searchTextField.superview];
        return NO;
    }
    return YES;
}

#pragma mark - UITextFieldTextDidChangeNotification

- (void)searchTextFieldTextDidChange:(NSNotification *)notification {
    UITextField *textField = (UITextField *)notification.object;
    if (textField.markedTextRange) return;
    if (![self.delegate respondsToSelector:@selector(searchBar:searchWithText:editEnded:)]) return;
    [self.delegate searchBar:self searchWithText:textField.text editEnded:NO];
}

@end
