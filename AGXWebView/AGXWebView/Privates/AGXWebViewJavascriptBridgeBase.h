//
//  AGXWebViewJavascriptBridgeBase.h
//  AGXWebView
//
//  Created by Char Aznable on 16/3/4.
//  Copyright © 2016年 AI-CUC-EC. All rights reserved.
//

//
//  Copyright (c) 2011-2015 Marcus Westin, Antoine Lagadec
//
//  Permission is hereby granted, free of charge, to any person
//  obtaining a copy of this software and associated documentation
//  files (the "Software"), to deal in the Software without
//  restriction, including without limitation the rights to use,
//  copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the
//  Software is furnished to do so, subject to the following
//  conditions:
//
//  The above copyright notice and this permission notice shall be
//  included in all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
//  EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
//  OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
//  NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
//  HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
//  WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
//  FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
//  OTHER DEALINGS IN THE SOFTWARE.
//

#ifndef AGXWebView_AGXWebViewJavascriptBridgeBase_h
#define AGXWebView_AGXWebViewJavascriptBridgeBase_h

#import <Foundation/Foundation.h>
#import <AGXCore/AGXCore/AGXArc.h>

typedef void (^AGXBridgeResponseCallback)(id responseData);
typedef void (^AGXBridgeHandler)(id data, AGXBridgeResponseCallback responseCallback);

@protocol AGXWebViewJavascriptBridgeBaseDelegate <NSObject>
- (NSString *)_evaluateJavascript:(NSString *)javascriptCommand;
@end

@interface AGXWebViewJavascriptBridgeBase : NSObject
@property (nonatomic, assign)       id<AGXWebViewJavascriptBridgeBaseDelegate> delegate;
@property (nonatomic, AGX_STRONG)   NSMutableArray *startupMessageQueue;
@property (nonatomic, AGX_STRONG)   NSMutableDictionary *responseCallbacks;
@property (nonatomic, AGX_STRONG)   NSMutableDictionary *messageHandlers;
@property (nonatomic, copy)         AGXBridgeHandler messageHandler;

+ (void)enableLogging;
+ (void)setLogMaxLength:(int)length;

- (void)reset;
- (void)sendData:(id)data responseCallback:(AGXBridgeResponseCallback)responseCallback handlerName:(NSString *)handlerName;
- (void)flushMessageQueue:(NSString *)messageQueueString;
- (void)injectSetupJavascript;
- (void)injectLoadedJavascript;
- (void)injectCallersJavascript;
- (BOOL)isCorrectProcotocolScheme:(NSURL *)url;
- (BOOL)isQueueMessageURL:(NSURL *)urll;
- (BOOL)isBridgeLoadedURL:(NSURL *)urll;
- (void)logUnkownMessage:(NSURL *)url;

- (NSString *)agxWebViewJavascriptCheckCommand;
- (NSString *)agxWebViewJavascriptFetchQueueCommand;
@end

#endif /* AGXWebView_AGXWebViewJavascriptBridgeBase_h */
