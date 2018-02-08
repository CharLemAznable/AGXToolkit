//
//  AGXRefreshView.m
//  AGXWidget
//
//  Created by Char Aznable on 2016/2/25.
//  Copyright © 2016年 AI-CUC-EC. All rights reserved.
//

#import <AGXCore/AGXCore/UIView+AGXCore.h>
#import <AGXCore/AGXCore/UIScrollView+AGXCore.h>
#import "AGXRefreshView.h"

@implementation AGXRefreshView

- (void)agxInitial {
    [super agxInitial];
    self.state = AGXRefreshNormal;
    self.direction = AGXRefreshPullDown;
    self.defaultPadding = 0;
    self.pullingMargin = 66;
    self.loadingMargin = 60;
}

- (void)dealloc {
    _delegate = nil;
    AGX_SUPER_DEALLOC;
}

- (void)setState:(AGXRefreshState)state {
    [self setRefreshState:state];
    _state = state;
}

- (void)setRefreshState:(AGXRefreshState)state {
    // default do NOTHING, overrides
}

- (void)didScrollView:(UIScrollView *)scrollView {
    if (AGXRefreshLoading == _state) {
        [self p_updateInsetsWhenLoadingInScrollView:scrollView];

    } else if (scrollView.isDragging) {
        BOOL _loading = NO;
        if ([self.delegate respondsToSelector:@selector(refreshViewIsLoading:)]) {
            _loading = [self.delegate refreshViewIsLoading:self];
        }

        CGFloat pullingOffset = [self p_pullingOffsetInScrollView:scrollView];
        if (AGXRefreshPulling == _state && !_loading && pullingOffset < _pullingMargin && pullingOffset > 0) {
            self.state = AGXRefreshNormal;
        } else if (AGXRefreshNormal == _state && !_loading && pullingOffset >= _pullingMargin) {
            self.state = AGXRefreshPulling;
        }

        [self p_resetInsetsInScrollView:scrollView];
    }
}

- (void)didEndDragging:(UIScrollView *)scrollView {
    BOOL _loading = NO;
    if ([self.delegate respondsToSelector:@selector(refreshViewIsLoading:)]) {
        _loading = [self.delegate refreshViewIsLoading:self];
    }

    CGFloat pullingOffset = [self p_pullingOffsetInScrollView:scrollView];
    if (pullingOffset >= _pullingMargin && !_loading) {
        if ([self.delegate respondsToSelector:@selector(refreshViewStartLoad:)]) {
            [self.delegate refreshViewStartLoad:self];
        }

        self.state = AGXRefreshLoading;
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationDuration:0.5];
        [self p_updateInsetsWhenLoadingInScrollView:scrollView];
        [UIView commitAnimations];
    }
}

- (void)didFinishedLoading:(UIScrollView *)scrollView {
    self.state = AGXRefreshNormal;
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.5];
    [self p_resetInsetsInScrollView:scrollView];
    [UIView commitAnimations];
}

#pragma mark - Private Methods -

- (CGFloat)p_pullingOffsetInScrollView:(UIScrollView *)scrollView {
    switch (_direction) {
        case AGXRefreshPullDown: return -scrollView.contentOffset.y-_defaultPadding;
        case AGXRefreshPullUp: return scrollView.contentOffset.y+scrollView.frame.size.height
            -MAX(scrollView.contentSize.height+scrollView.contentInset.top+_defaultPadding,
                 scrollView.frame.size.height)
            +scrollView.contentInset.top-_defaultPadding;
        case AGXRefreshPullRight: return -scrollView.contentOffset.x-_defaultPadding;
        case AGXRefreshPullLeft: return scrollView.contentOffset.x+scrollView.frame.size.width
            -MAX(scrollView.contentSize.width+scrollView.contentInset.left+_defaultPadding,
                 scrollView.frame.size.width)
            +scrollView.contentInset.left-_defaultPadding;
        default: return 0;
    }
}

- (void)p_updateInsetsWhenLoadingInScrollView:(UIScrollView *)scrollView {
    CGFloat offset = BETWEEN([self p_pullingOffsetInScrollView:scrollView], 0, _loadingMargin);
    UIEdgeInsets insets = scrollView.contentInset;
    UIEdgeInsets adjustedInset = scrollView.automaticallyAdjustedContentInset;
    CGFloat blank = 0;
    switch (_direction) {
        case AGXRefreshPullDown:
            insets.top = _defaultPadding + offset + adjustedInset.top;
            break;
        case AGXRefreshPullUp:
            blank = MAX(scrollView.frame.size.height-scrollView.contentSize.height, 0);
            insets.bottom = _defaultPadding + offset + blank + adjustedInset.bottom;
            break;
        case AGXRefreshPullRight:
            insets.left = _defaultPadding + offset + adjustedInset.left;
            break;
        case AGXRefreshPullLeft:
            blank = MAX(scrollView.frame.size.width-scrollView.contentSize.width, 0);
            insets.right = _defaultPadding + offset + blank + adjustedInset.right;
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
