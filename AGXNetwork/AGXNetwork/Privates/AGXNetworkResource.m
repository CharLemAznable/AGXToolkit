//
//  AGXNetworkResource.m
//  AGXNetwork
//
//  Created by Char Aznable on 16/4/26.
//  Copyright © 2016年 AI-CUC-EC. All rights reserved.
//

#import "AGXNetworkResource.h"
#import <AGXCore/AGXCore/AGXCategory.h>
#import <AGXCore/AGXCore/AGXBundle.h>
#import "AGXNetworkDelegate.h"
#import "AGXRequest+Private.h"

@category_interface(NSURLSessionConfiguration, AGXNetworkAGXSessionPool)
+ (NSURLSessionConfiguration *)backgroundSessionConfiguration;
@end
@category_implementation(NSURLSessionConfiguration, AGXNetworkAGXSessionPool)
+ (NSURLSessionConfiguration *)backgroundSessionConfiguration {
    return [self backgroundSessionConfigurationWithIdentifier:[AGXBundle appIdentifier]];
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
        _syncTasksQueue = dispatch_queue_create("com.agxnetwork.synctasksqueue", DISPATCH_QUEUE_SERIAL);
        dispatch_async(_syncTasksQueue, ^{ _activeTasks = [[NSMutableArray alloc] init]; });
    }
    return self;
}

- (void)dealloc {
    AGX_RELEASE(_activeTasks);
    agx_dispatch_release(_syncTasksQueue);
    AGX_SUPER_DEALLOC;
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
AGXLazySessionCreation(backgroundSession, AGX_AUTORELEASE([[NSOperationQueue alloc] init]))

#undef AGXLazySessionCreation

#pragma mark - Delegate

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error {
    __block AGXRequest *taskRequest = nil;
    [_activeTasks enumerateObjectsUsingBlock:^(AGXRequest *request, NSUInteger idx, BOOL *stop) {
        if([request.sessionTask isEqual:task]) { taskRequest = request; *stop = YES; }
    }];

    if (!taskRequest) return;
    taskRequest.response = (NSHTTPURLResponse *)task.response;
    taskRequest.error = error;
    taskRequest.state = error ? AGXRequestStateError : AGXRequestStateCompleted;
}

@end
