//
//  AGXNetworkResource.m
//  AGXNetwork
//
//  Created by Char Aznable on 2016/4/26.
//  Copyright © 2016年 AI-CUC-EC. All rights reserved.
//

//
//  Modify from:
//  MugunthKumar/MKNetworkKit
//

//  MKNetworkKit is licensed under MIT License Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

#import <AGXCore/AGXCore/AGXResources.h>
#import <AGXCore/AGXCore/AGXAppInfo.h>
#import <AGXCore/AGXCore/NSObject+AGXCore.h>
#import "AGXNetworkResource.h"
#import "AGXNetworkDelegate.h"
#import "AGXRequest+Private.h"

@category_interface(NSURLSessionConfiguration, AGXNetworkAGXSessionPool)
+ (NSURLSessionConfiguration *)backgroundSessionConfiguration;
@end
@category_implementation(NSURLSessionConfiguration, AGXNetworkAGXSessionPool)
+ (NSURLSessionConfiguration *)backgroundSessionConfiguration {
    return [self backgroundSessionConfigurationWithIdentifier:AGXAppInfo.appIdentifier];
}
@end

@interface AGXApplicationDelegateAGXNetworkDummy : NSObject
- (void)application:(UIApplication *)application handleEventsForBackgroundURLSession:(NSString *)identifier completionHandler:(void (^)(void))completionHandler;
- (void)AGXNetwork_UIApplicationDelegate_application:(UIApplication *)application handleEventsForBackgroundURLSession:(NSString *)identifier completionHandler:(void (^)(void))completionHandler;
@end
@implementation AGXApplicationDelegateAGXNetworkDummy
- (void)application:(UIApplication *)application handleEventsForBackgroundURLSession:(NSString *)identifier completionHandler:(void (^)(void))completionHandler {}
- (void)AGXNetwork_UIApplicationDelegate_application:(UIApplication *)application handleEventsForBackgroundURLSession:(NSString *)identifier completionHandler:(void (^)(void))completionHandler {
    [self AGXNetwork_UIApplicationDelegate_application:application handleEventsForBackgroundURLSession:identifier completionHandler:completionHandler];
    if ([AGXAppInfo.appIdentifier isEqualToString:identifier])
        [AGXNetworkResource setBackgroundSessionCompletionHandler:completionHandler];
}
@end

@interface AGXNetworkResource () {
    dispatch_queue_t _syncTasksQueue;
    NSMutableArray *_activeTasks;
}
@end

@singleton_implementation(AGXNetworkResource, shareNetwork)

- (AGX_INSTANCETYPE)init {
    if AGX_EXPECT_T(self = [super init]) {
        _backgroundSessionCompletionHandler = nil;
        _syncTasksQueue = dispatch_queue_create("com.agxnetwork.synctasksqueue", DISPATCH_QUEUE_SERIAL);
        dispatch_async(_syncTasksQueue, ^{ _activeTasks = [[NSMutableArray alloc] init]; });

        agx_once
        ([UIApplication.sharedApplication.delegate.class
          swizzleInstanceOriSelector:@selector(application:handleEventsForBackgroundURLSession:completionHandler:)
          withNewSelector:@selector(AGXNetwork_UIApplicationDelegate_application:handleEventsForBackgroundURLSession:completionHandler:)
          fromClass:AGXApplicationDelegateAGXNetworkDummy.class];);
    }
    return self;
}

- (void)dealloc {
    AGX_BLOCK_RELEASE(_backgroundSessionCompletionHandler);
    AGX_RELEASE(_activeTasks);
    agx_dispatch_release(_syncTasksQueue);
    AGX_SUPER_DEALLOC;
}

- (void)setBackgroundSessionCompletionHandler:(void (^)(void))backgroundSessionCompletionHandler {
    void (^temp)(void) = AGX_BLOCK_COPY(backgroundSessionCompletionHandler);
    AGX_BLOCK_RELEASE(_backgroundSessionCompletionHandler);
    _backgroundSessionCompletionHandler = temp;
}

#pragma mark - session lazy creation

#define AGXLazySessionCreation(sessionName, sessionQueue)                               \
- (NSURLSession *)sessionName {                                                         \
    AGX_STATIC NSURLSessionConfiguration *sessionName##Configuration;                   \
    AGX_STATIC NSURLSession *sessionName;                                               \
    agx_once                                                                            \
    (sessionName##Configuration = AGX_RETAIN([NSURLSessionConfiguration                 \
                                              sessionName##Configuration]);             \
     if ([UIApplication.sharedApplication.delegate                                      \
          respondsToSelector:@selector(application:sessionName##Configuration:)]) {     \
         [(id<AGXNetworkDelegate>)UIApplication.sharedApplication.delegate              \
          application:UIApplication.sharedApplication                                   \
          sessionName##Configuration:sessionName##Configuration];                       \
     }                                                                                  \
     sessionName = AGX_RETAIN([NSURLSession sessionWithConfiguration:                   \
                               sessionName##Configuration delegate:self                 \
                                delegateQueue:sessionQueue]););                         \
    return sessionName;                                                                 \
}                                                                                       \
+ (NSURLSession *)sessionName {                                                         \
    return AGXNetworkResource.shareNetwork.sessionName;                                 \
}

AGXLazySessionCreation(defaultSession, [NSOperationQueue mainQueue])
AGXLazySessionCreation(ephemeralSession, [NSOperationQueue mainQueue])
AGXLazySessionCreation(backgroundSession, [NSOperationQueue instance])

#undef AGXLazySessionCreation

+ (void (^)(void))backgroundSessionCompletionHandler {
    return AGXNetworkResource.shareNetwork.backgroundSessionCompletionHandler;
}

+ (void)setBackgroundSessionCompletionHandler:(void (^)(void))backgroundSessionCompletionHandler {
    AGXNetworkResource.shareNetwork.backgroundSessionCompletionHandler = backgroundSessionCompletionHandler;
}

- (void)addNetworkRequest:(AGXRequest *)request {
    dispatch_sync(_syncTasksQueue, ^{ [_activeTasks addObject:request]; });
}

- (void)removeNetworkRequest:(AGXRequest *)request {
    dispatch_sync(_syncTasksQueue, ^{ [_activeTasks removeObject:request]; });
}

+ (void)addNetworkRequest:(AGXRequest *)request {
    [AGXNetworkResource.shareNetwork addNetworkRequest:request];
}

+ (void)removeNetworkRequest:(AGXRequest *)request {
    [AGXNetworkResource.shareNetwork removeNetworkRequest:request];
}

#pragma mark - NSURLSessionDelegate

- (void)URLSession:(NSURLSession *)session didBecomeInvalidWithError:(NSError *)error {
    if (self.backgroundSession == session) AGXLog(@"Session became invalid with error: %@", error);
}

- (void)URLSessionDidFinishEventsForBackgroundURLSession:(NSURLSession *)session {
    if (self.backgroundSession == session) {
        if (self.backgroundSessionCompletionHandler) {
            void (^completionHandler)(void) = AGX_BLOCK_COPY(self.backgroundSessionCompletionHandler);
            self.backgroundSessionCompletionHandler = nil;
            completionHandler();
            AGX_BLOCK_RELEASE(completionHandler);
        }
    }
}

#pragma mark - NSURLSessionTaskDelegate

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didReceiveChallenge:(NSURLAuthenticationChallenge *)challenge completionHandler:(void (^)(NSURLSessionAuthChallengeDisposition disposition, NSURLCredential *credential))completionHandler {
    if ([challenge.protectionSpace.authenticationMethod isEqualToString:NSURLAuthenticationMethodServerTrust]) {
        NSURLCredential *credential = [NSURLCredential credentialForTrust:challenge.protectionSpace.serverTrust];
        completionHandler(NSURLSessionAuthChallengeUseCredential, credential);
    }

    AGXRequest *request = [self requestMatchingSessionTask:task];
    if AGX_EXPECT_F(!request) return; // AGXRequestStateCancelled

    AGXRequest *temp = AGX_RETAIN(request);
    if ([challenge.protectionSpace.authenticationMethod isEqualToString:NSURLAuthenticationMethodHTTPBasic] ||
        [challenge.protectionSpace.authenticationMethod isEqualToString:NSURLAuthenticationMethodHTTPDigest]) {

        if ([challenge previousFailureCount] == 3) {
            completionHandler(NSURLSessionAuthChallengeRejectProtectionSpace, nil);
        } else {
            NSURLCredential *credential = [NSURLCredential credentialWithUser:temp.username password:temp.password
                                                                  persistence:NSURLCredentialPersistenceNone];
            completionHandler(credential ? NSURLSessionAuthChallengeUseCredential :
                              NSURLSessionAuthChallengeCancelAuthenticationChallenge, credential);
        }
    }
    AGX_RELEASE(temp);
}

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didSendBodyData:(int64_t)bytesSent totalBytesSent:(int64_t)totalBytesSent totalBytesExpectedToSend:(int64_t)totalBytesExpectedToSend {
    AGXRequest *request = [self requestMatchingSessionTask:task];
    if AGX_EXPECT_F(!request) return; // AGXRequestStateCancelled

    AGXRequest *temp = AGX_RETAIN(request);
    temp.progress = NSURLSessionTransferSizeUnknown == totalBytesExpectedToSend
    ? 0.0 : (1.0 * totalBytesSent / totalBytesExpectedToSend);
    [temp doUploadProgressHandler];
    AGX_RELEASE(temp);
}

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error {
    AGXRequest *request = [self requestMatchingSessionTask:task];
    if AGX_EXPECT_F(!request) return; // AGXRequestStateCancelled

    AGXRequest *temp = AGX_RETAIN(request);
    temp.response = (NSHTTPURLResponse *)task.response;
    temp.error = error;
    temp.state = error ? AGXRequestStateError : AGXRequestStateCompleted;
    AGX_RELEASE(temp);
}

#pragma mark - NSURLSessionDownloadDelegate

- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didFinishDownloadingToURL:(NSURL *)location {
    AGXRequest *request = [self requestMatchingSessionTask:downloadTask];
    if AGX_EXPECT_F(!request) return; // AGXRequestStateCancelled

    AGXRequest *temp = AGX_RETAIN(request);
    temp.downloadDestination.writeDataWithFileNamed
    (temp.downloadFileName, [NSData dataWithContentsOfURL:location]);
    temp.progress = 1.0;
    [temp doDownloadProgressHandler];
    AGX_RELEASE(temp);
}

- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didWriteData:(int64_t)bytesWritten totalBytesWritten:(int64_t)totalBytesWritten totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite {
    AGXRequest *request = [self requestMatchingSessionTask:downloadTask];
    if AGX_EXPECT_F(!request) return; // AGXRequestStateCancelled

    AGXRequest *temp = AGX_RETAIN(request);
    temp.progress = NSURLSessionTransferSizeUnknown == totalBytesExpectedToWrite
    ? 0.0 : (1.0 * totalBytesWritten / totalBytesExpectedToWrite);
    [temp doDownloadProgressHandler];
    AGX_RELEASE(temp);
}

#pragma mark - private methods

- (AGXRequest *)requestMatchingSessionTask:(NSURLSessionTask *)task {
    __block AGXRequest *matchingRequest = nil;
    [_activeTasks enumerateObjectsUsingBlock:^(AGXRequest *request, NSUInteger idx, BOOL *stop) {
        if ([request.sessionTask isEqual:task]) { matchingRequest = request; *stop = YES; }
    }];
    return matchingRequest;
}

@end
