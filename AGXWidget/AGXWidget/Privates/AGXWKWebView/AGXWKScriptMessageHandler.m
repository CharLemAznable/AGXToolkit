//
//  AGXWKScriptMessageHandler.m
//  AGXWidget
//
//  Created by Char on 2019/4/17.
//  Copyright © 2019 github.com/CharLemAznable. All rights reserved.
//

#import "AGXWKScriptMessageHandler.h"

@interface AGXWKScriptMessageHandlerProxy : NSObject <WKScriptMessageHandler>
@property (nonatomic, AGX_WEAK) id<WKScriptMessageHandler> target;

+ (AGX_INSTANCETYPE)proxyWithTarget:(id<WKScriptMessageHandler>)target;
- (AGX_INSTANCETYPE)initWithTarget:(id<WKScriptMessageHandler>)target;
@end

@implementation AGXWKScriptMessageHandlerProxy

+ (AGX_INSTANCETYPE)proxyWithTarget:(id<WKScriptMessageHandler>)target {
    return AGX_AUTORELEASE([[self alloc] initWithTarget:target]);
}

- (AGX_INSTANCETYPE)initWithTarget:(id<WKScriptMessageHandler>)target {
    if AGX_EXPECT_T(self = [super init]) {
        _target = target;
    }
    return self;
}

- (void)dealloc {
    _target = nil;
    AGX_SUPER_DEALLOC;
}

#pragma mark - WKScriptMessageHandler

- (void)userContentController:(WKUserContentController *)userContentController didReceiveScriptMessage:(WKScriptMessage *)message {
    if ([self.target respondsToSelector:@selector(userContentController:didReceiveScriptMessage:)])
        [self.target userContentController:userContentController didReceiveScriptMessage:message];
}

@end

@implementation AGXWKScriptMessageHandler

- (id<WKScriptMessageHandler>)scriptMessageHandlerProxy {
    return [AGXWKScriptMessageHandlerProxy proxyWithTarget:self];
}

#pragma mark - AGXWKScriptMessageHandler

- (NSString *)scriptMessageHandlerName {
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

#pragma mark - WKScriptMessageHandler

- (void)userContentController:(WKUserContentController *)userContentController didReceiveScriptMessage:(WKScriptMessage *)message {
    [self doesNotRecognizeSelector:_cmd];
}

@end
