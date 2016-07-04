//
//  AGXNetworkResource.m
//  AGXNetwork
//
//  Created by Char Aznable on 16/4/26.
//  Copyright © 2016年 AI-CUC-EC. All rights reserved.
//

#import <AGXCore/AGXCore/AGXDirectory.h>
#import <AGXCore/AGXCore/AGXBundle.h>
#import <AGXCore/AGXCore/NSObject+AGXCore.h>
#import "AGXNetworkResource.h"
#import "AGXNetworkDelegate.h"
#import "AGXRequest+Private.h"

@category_interface(NSURLSessionConfiguration, AGXNetworkAGXSessionPool)
+ (NSURLSessionConfiguration *)backgroundSessionConfiguration;
@end
@category_implementation(NSURLSessionConfiguration, AGXNetworkAGXSessionPool)
+ (NSURLSessionConfiguration *)backgroundSessionConfiguration {
    return [self backgroundSessionConfigurationWithIdentifier:AGXBundle.appIdentifier];
}
@end

@interface AGXApplicationDelegateAGXNetworkDummy : NSObject
- (void)application:(UIApplication *)application handleEventsForBackgroundURLSession:(NSString *)identifier completionHandler:(void (^)())completionHandler;
- (void)AGXNetwork_UIApplicationDelegate_application:(UIApplication *)application handleEventsForBackgroundURLSession:(NSString *)identifier completionHandler:(void (^)())completionHandler;
@end
@implementation AGXApplicationDelegateAGXNetworkDummy
- (void)application:(UIApplication *)application handleEventsForBackgroundURLSession:(NSString *)identifier completionHandler:(void (^)())completionHandler {}
- (void)AGXNetwork_UIApplicationDelegate_application:(UIApplication *)application handleEventsForBackgroundURLSession:(NSString *)identifier completionHandler:(void (^)())completionHandler {
    [self AGXNetwork_UIApplicationDelegate_application:application handleEventsForBackgroundURLSession:identifier completionHandler:completionHandler];
    if ([AGXBundle.appIdentifier isEqualToString:identifier])
        [AGXNetworkResource setBackgroundSessionCompletionHandler:completionHandler];
}
@end

@interface AGXNetworkResource () {
    dispatch_queue_t _syncTasksQueue;
    NSMutableArray *_activeTasks;
}
@end

@singleton_implementation(AGXNetworkResource)

- (AGX_INSTANCETYPE)init {
    if (AGX_EXPECT_T(self = [super init])) {
        _backgroundSessionCompletionHandler = nil;
        _syncTasksQueue = dispatch_queue_create("com.agxnetwork.synctasksqueue", DISPATCH_QUEUE_SERIAL);
        dispatch_async(_syncTasksQueue, ^{ _activeTasks = [[NSMutableArray alloc] init]; });

        static dispatch_once_t once_t;
        dispatch_once(&once_t, ^{
            [[[UIApplication sharedApplication].delegate class]
             swizzleInstanceOriSelector:@selector(application:handleEventsForBackgroundURLSession:completionHandler:)
             withNewSelector:@selector(AGXNetwork_UIApplicationDelegate_application:handleEventsForBackgroundURLSession:completionHandler:)
             fromClass:[AGXApplicationDelegateAGXNetworkDummy class]];
        });
    }
    return self;
}

- (void)dealloc {
    AGX_BLOCK_RELEASE(_backgroundSessionCompletionHandler);
    AGX_RELEASE(_activeTasks);
    agx_dispatch_release(_syncTasksQueue);
    AGX_SUPER_DEALLOC;
}

#pragma mark - session lazy creation

#define AGXLazySessionCreation(sessionName, sessionQueue)                               \
- (NSURLSession *)sessionName {                                                         \
    static NSURLSessionConfiguration *sessionName##Configuration;                       \
    static NSURLSession *sessionName;                                                   \
    static dispatch_once_t once_t;                                                      \
    dispatch_once(&once_t, ^{                                                           \
        sessionName##Configuration = AGX_RETAIN([NSURLSessionConfiguration              \
                                                 sessionName##Configuration]);          \
        if ([[UIApplication sharedApplication].delegate                                 \
             respondsToSelector:@selector(application:sessionName##Configuration:)]) {  \
            [(id<AGXNetworkDelegate>)[UIApplication sharedApplication].delegate         \
             application:[UIApplication sharedApplication]                              \
             sessionName##Configuration:sessionName##Configuration];                    \
        }                                                                               \
        sessionName = AGX_RETAIN([NSURLSession sessionWithConfiguration:                \
                                  sessionName##Configuration delegate:self              \
                                  delegateQueue:sessionQueue]);                         \
    });                                                                                 \
    return sessionName;                                                                 \
}                                                                                       \
+ (NSURLSession *)sessionName {                                                         \
    return [AGXNetworkResource shareInstance].sessionName;                              \
}

AGXLazySessionCreation(defaultSession, [NSOperationQueue mainQueue])
AGXLazySessionCreation(ephemeralSession, [NSOperationQueue mainQueue])
AGXLazySessionCreation(backgroundSession, [NSOperationQueue instance])

#undef AGXLazySessionCreation

+ (void (^)())backgroundSessionCompletionHandler {
    return [AGXNetworkResource shareInstance].backgroundSessionCompletionHandler;
}

+ (void)setBackgroundSessionCompletionHandler:(void (^)())backgroundSessionCompletionHandler {
    [AGXNetworkResource shareInstance].backgroundSessionCompletionHandler = backgroundSessionCompletionHandler;
}

- (void)addNetworkRequest:(AGXRequest *)request {
    dispatch_sync(_syncTasksQueue, ^{ [_activeTasks addObject:request]; });
}

- (void)removeNetworkRequest:(AGXRequest *)request {
    dispatch_sync(_syncTasksQueue, ^{ [_activeTasks removeObject:request]; });
}

+ (void)addNetworkRequest:(AGXRequest *)request {
    [[AGXNetworkResource shareInstance] addNetworkRequest:request];
}

+ (void)removeNetworkRequest:(AGXRequest *)request {
    [[AGXNetworkResource shareInstance] removeNetworkRequest:request];
}

#pragma mark - NSURLSessionDelegate

- (void)URLSession:(NSURLSession *)session didBecomeInvalidWithError:(NSError *)error {
    if (session == self.backgroundSession) AGXLog(@"Session became invalid with error: %@", error);
}

- (void)URLSessionDidFinishEventsForBackgroundURLSession:(NSURLSession *)session {
    if (session == self.backgroundSession) {
        if (self.backgroundSessionCompletionHandler) {
            void (^completionHandler)() = AGX_BLOCK_COPY(self.backgroundSessionCompletionHandler);
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
    if (!request) return; // AGXRequestStateCancelled

    AGX_RETAIN(request);
    if ([challenge.protectionSpace.authenticationMethod isEqualToString:NSURLAuthenticationMethodHTTPBasic] ||
        [challenge.protectionSpace.authenticationMethod isEqualToString:NSURLAuthenticationMethodHTTPDigest]) {

        if ([challenge previousFailureCount] == 3) {
            completionHandler(NSURLSessionAuthChallengeRejectProtectionSpace, nil);
        } else {
            NSURLCredential *credential = [NSURLCredential credentialWithUser:request.username password:request.password
                                                                  persistence:NSURLCredentialPersistenceNone];
            completionHandler(credential ? NSURLSessionAuthChallengeUseCredential :
                              NSURLSessionAuthChallengeCancelAuthenticationChallenge, credential);
        }
    }
    AGX_RELEASE(request);
}

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didSendBodyData:(int64_t)bytesSent totalBytesSent:(int64_t)totalBytesSent totalBytesExpectedToSend:(int64_t)totalBytesExpectedToSend {
    AGXRequest *request = [self requestMatchingSessionTask:task];
    if (!request) return; // AGXRequestStateCancelled

    AGX_RETAIN(request);
    request.progress = NSURLSessionTransferSizeUnknown == totalBytesExpectedToSend
    ? 0.0 : (1.0 * totalBytesSent / totalBytesExpectedToSend);
    [request doUploadProgressHandler];
    AGX_RELEASE(request);
}

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error {
    AGXRequest *request = [self requestMatchingSessionTask:task];
    if (!request) return; // AGXRequestStateCancelled

    AGX_RETAIN(request);
    request.response = (NSHTTPURLResponse *)task.response;
    request.error = error;
    request.state = error ? AGXRequestStateError : AGXRequestStateCompleted;
    AGX_RELEASE(request);
}

#pragma mark - NSURLSessionDownloadDelegate

- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didFinishDownloadingToURL:(NSURL *)location {
    AGXRequest *request = [self requestMatchingSessionTask:downloadTask];
    if (!request) return; // AGXRequestStateCancelled

    AGX_RETAIN(request);
    AGXDirectory.writeToFileWithData(request.downloadPath, [NSData dataWithContentsOfURL:location]);

    request.progress = 1.0;
    [request doDownloadProgressHandler];
    AGX_RELEASE(request);
}

- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didWriteData:(int64_t)bytesWritten totalBytesWritten:(int64_t)totalBytesWritten totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite {
    AGXRequest *request = [self requestMatchingSessionTask:downloadTask];
    if (!request) return; // AGXRequestStateCancelled

    AGX_RETAIN(request);
    request.progress = NSURLSessionTransferSizeUnknown == totalBytesExpectedToWrite
    ? 0.0 : (1.0 * totalBytesWritten / totalBytesExpectedToWrite);
    [request doDownloadProgressHandler];
    AGX_RELEASE(request);
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
