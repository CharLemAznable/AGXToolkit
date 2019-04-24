//
//  AGXWKWebViewRefreshView.m
//  AGXWidget
//
//  Created by Char Aznable on 2019/4/17.
//  Copyright © 2019 github.com/CharLemAznable. All rights reserved.
//

#import <AGXCore/AGXCore/AGXDelegateForwarder.h>
#import "AGXWKWebViewRefreshView.h"
#import "AGXWKWebView.h"

@forwarder_interface(AGXWKWebViewRefreshViewDegelageForwarder, AGXWKWebView, AGXRefreshViewDelegate)
@forwarder_implementation(AGXWKWebViewRefreshViewDegelageForwarder, AGXWKWebView, AGXRefreshViewDelegate)

@implementation AGXWKWebViewRefreshView {
    AGXWKWebViewRefreshViewDegelageForwarder *_delegateForwarder;
}

- (AGX_INSTANCETYPE)initWithFrame:(CGRect)frame {
    if AGX_EXPECT_T(self = [super initWithFrame:frame]) {
        _delegateForwarder = [[AGXWKWebViewRefreshViewDegelageForwarder alloc] init];
        super.delegate = _delegateForwarder;
    }
    return self;
}

- (void)setInternalDelegate:(AGXWKWebView *)internalDelegate {
    _delegateForwarder.internalDelegate = internalDelegate;
}

- (AGXWKWebView *)internalDelegate {
    return _delegateForwarder.internalDelegate;
}

- (void)setDelegate:(id<AGXRefreshViewDelegate>)delegate {
    _delegateForwarder.externalDelegate = delegate;
}

- (id<AGXRefreshViewDelegate>)delegate {
    return _delegateForwarder.externalDelegate;
}

- (void)dealloc {
    super.delegate = nil;
    _delegateForwarder.internalDelegate = nil;
    _delegateForwarder.externalDelegate = nil;
    AGX_RELEASE(_delegateForwarder);
    AGX_SUPER_DEALLOC;
}

@end
