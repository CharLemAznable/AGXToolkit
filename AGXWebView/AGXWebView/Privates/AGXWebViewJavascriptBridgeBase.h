//
//  AGXWebViewJavascriptBridgeBase.h
//  AGXWebView
//
//  Created by Char Aznable on 16/3/4.
//  Copyright © 2016年 AI-CUC-EC. All rights reserved.
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
- (void)injectJavascriptFile;
- (BOOL)isCorrectProcotocolScheme:(NSURL *)url;
- (BOOL)isQueueMessageURL:(NSURL *)urll;
- (BOOL)isBridgeLoadedURL:(NSURL *)urll;
- (void)logUnkownMessage:(NSURL *)url;

- (NSString *)agxWebViewJavascriptCheckCommand;
- (NSString *)agxWebViewJavascriptFetchQueueCommand;
@end

#endif /* AGXWebView_AGXWebViewJavascriptBridgeBase_h */
