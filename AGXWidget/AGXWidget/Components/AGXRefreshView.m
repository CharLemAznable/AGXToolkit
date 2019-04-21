//
//  AGXRefreshView.m
//  AGXWidget
//
//  Created by Char Aznable on 2016/2/25.
//  Copyright © 2016 github.com/CharLemAznable. All rights reserved.
//

#import <AGXCore/AGXCore/UIView+AGXCore.h>
#import <AGXCore/AGXCore/UIScrollView+AGXCore.h>
#import "AGXRefreshView.h"

@implementation AGXRefreshView {
    AGXRefreshState _state;
}

- (void)agxInitial {
    [super agxInitial];
    self.backgroundColor = UIColor.clearColor;

    _state = AGXRefreshNormal;
    _direction = AGXRefreshPullDown;
    _defaultPadding = 0;
    _pullingMargin = 66;
    _loadingMargin = 60;
    _insetsUpdateDuration = .5;
}

- (void)dealloc {
    _delegate = nil;
    AGX_SUPER_DEALLOC;
}

- (void)didScrollView:(UIScrollView *)scrollView {
    if (AGXRefreshLoading == _state) {
        [self p_updateInsetsWhenLoadingInScrollView:scrollView];
        return;
    }

    CGFloat pullingOffset = [self p_pullingOffsetInScrollView:scrollView];
    if (scrollView.isDragging) {
        if (AGXRefreshPulling == _state && pullingOffset < _pullingMargin && pullingOffset > 0) {
            _state = AGXRefreshNormal;
        } else if (AGXRefreshNormal == _state && pullingOffset >= _pullingMargin) {
            _state = AGXRefreshPulling;
        }

        [self p_resetInsetsInScrollView:scrollView];
    }
    if ([_delegate respondsToSelector:@selector(refreshView:updateState:pullingOffset:)]) {
        [_delegate refreshView:self updateState:_state pullingOffset:MAX(0, pullingOffset)];
    }
}

- (void)didEndDragging:(UIScrollView *)scrollView {
    CGFloat pullingOffset = [self p_pullingOffsetInScrollView:scrollView];
    if (pullingOffset >= _pullingMargin) {
        [self scrollViewStartLoad:scrollView];
    }
}

- (void)scrollViewStartLoad:(UIScrollView *)scrollView {
    if ([_delegate respondsToSelector:@selector(refreshViewStartLoad:)]) {
        [_delegate refreshViewStartLoad:self];
    }

    _state = AGXRefreshLoading;
    if ([_delegate respondsToSelector:@selector(refreshView:updateState:pullingOffset:)]) {
        [_delegate refreshView:self updateState:_state pullingOffset:_pullingMargin];
    }

    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:_insetsUpdateDuration];
    [self p_updateInsetsWhenLoadingInScrollView:scrollView];
    [UIView commitAnimations];
}

- (void)scrollViewFinishLoad:(UIScrollView *)scrollView {
    _state = AGXRefreshNormal;
    if ([_delegate respondsToSelector:@selector(refreshView:updateState:pullingOffset:)]) {
        [_delegate refreshView:self updateState:_state pullingOffset:0];
    }

    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:_insetsUpdateDuration];
    [self p_resetInsetsInScrollView:scrollView];
    [UIView commitAnimations];
}

#pragma mark - Private Methods -

- (CGFloat)p_pullingOffsetInScrollView:(UIScrollView *)scrollView {
    UIEdgeInsets contentInsetIncorporated = scrollView.contentInsetIncorporated;
    switch (_direction) {
        case AGXRefreshPullDown: return -scrollView.contentOffset.y
            -contentInsetIncorporated.top-_defaultPadding;

        case AGXRefreshPullUp: return scrollView.contentOffset.y+scrollView.frame.size.height
            -MAX(scrollView.contentSize.height+contentInsetIncorporated.top+contentInsetIncorporated.bottom
                 +_defaultPadding, scrollView.frame.size.height)+contentInsetIncorporated.top-_defaultPadding;

        case AGXRefreshPullRight: return -scrollView.contentOffset.x
            -contentInsetIncorporated.left-_defaultPadding;

        case AGXRefreshPullLeft: return scrollView.contentOffset.x+scrollView.frame.size.width
            -MAX(scrollView.contentSize.width+contentInsetIncorporated.left+contentInsetIncorporated.right
                 +_defaultPadding, scrollView.frame.size.width)+contentInsetIncorporated.left-_defaultPadding;

        default: return 0;
    }
}

- (void)p_updateInsetsWhenLoadingInScrollView:(UIScrollView *)scrollView {
    UIEdgeInsets insets = scrollView.contentInset;
    UIEdgeInsets adjustedInset = scrollView.automaticallyAdjustedContentInset;
    CGFloat blank = 0;
    switch (_direction) {
        case AGXRefreshPullDown:
            insets.top = _defaultPadding + _loadingMargin + adjustedInset.top;
            break;
        case AGXRefreshPullUp:
            blank = MAX(scrollView.frame.size.height-scrollView.contentSize.height, 0);
            insets.bottom = _defaultPadding + _loadingMargin + blank + adjustedInset.bottom;
            break;
        case AGXRefreshPullRight:
            insets.left = _defaultPadding + _loadingMargin + adjustedInset.left;
            break;
        case AGXRefreshPullLeft:
            blank = MAX(scrollView.frame.size.width-scrollView.contentSize.width, 0);
            insets.right = _defaultPadding + _loadingMargin + blank + adjustedInset.right;
            break;
        default: break;
    }
    scrollView.contentInset = insets;
}

- (void)p_resetInsetsInScrollView:(UIScrollView *)scrollView {
    UIEdgeInsets insets = scrollView.contentInset;
    UIEdgeInsets adjustedInset = scrollView.automaticallyAdjustedContentInset;
    switch (_direction) {
        case AGXRefreshPullDown:
            if (insets.top != _defaultPadding + adjustedInset.top) {
                insets.top = _defaultPadding + adjustedInset.top;
                scrollView.contentInset = insets;
            }
            break;
        case AGXRefreshPullUp:
            if (insets.bottom != _defaultPadding + adjustedInset.bottom) {
                insets.bottom = _defaultPadding + adjustedInset.bottom;
                scrollView.contentInset = insets;
            }
            break;
        case AGXRefreshPullRight:
            if (insets.left != _defaultPadding + adjustedInset.left) {
                insets.left = _defaultPadding + adjustedInset.left;
                scrollView.contentInset = insets;
            }
            break;
        case AGXRefreshPullLeft:
            if (insets.right != _defaultPadding + adjustedInset.right) {
                insets.right = _defaultPadding + adjustedInset.right;
                scrollView.contentInset = insets;
            }
            break;
        default: return;
    }
}

@end
