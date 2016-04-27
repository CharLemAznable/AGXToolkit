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

- (void)addTask:(AGXRequest *)request {
    dispatch_sync(_syncTasksQueue, ^{ [_activeTasks addObject:request]; });
}

- (void)removeTask:(AGXRequest *)request {
    dispatch_sync(_syncTasksQueue, ^{ [_activeTasks removeObject:request]; });
}

+ (void)addTask:(AGXRequest *)request {
    [[AGXNetworkResource shareInstance] addTask:request];
}

+ (void)removeTask:(AGXRequest *)request {
    [[AGXNetworkResource shareInstance] removeTask:request];
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

@end
