//
//  AGXService.m
//  AGXNetwork
//
//  Created by Char Aznable on 16/3/2.
//  Copyright © 2016年 AI-CUC-EC. All rights reserved.
//

#import "AGXService.h"
#import "AGXCache.h"
#import <AGXCore/AGXCore/AGXArc.h>

static NSString *const kAGXServiceDefaultCacheDirectory = @"com.agxnetwork.servicecache";

@interface AGXService () <NSURLSessionDelegate>
@property (nonatomic, readonly)     NSURLSession *defaultSession;
@property (nonatomic, readonly)     NSURLSession *ephemeralSession;
@property (nonatomic, readonly)     NSURLSession *backgroundSession;

@property (nonatomic, AGX_DISPATCH) dispatch_queue_t runningTasksSynchronizingQueue;
@property (nonatomic, AGX_STRONG)   NSMutableArray *activeTasks;

@property (nonatomic, AGX_STRONG)   AGXCache *reqDataCache;
@property (nonatomic, AGX_STRONG)   AGXCache *rspDataCache;
@end

@implementation AGXService

- (NSURLSession *)defaultSession {
    static NSURLSessionConfiguration *defaultSessionConfiguration;
    static NSURLSession *defaultSession;
    static dispatch_once_t once_t;
    dispatch_once(&once_t, ^{
        defaultSessionConfiguration = [NSURLSessionConfiguration defaultSessionConfiguration];
        if ([self.delegate respondsToSelector:@selector(service:didCreateDefaultSessionConfiguration:)]) {
            [self.delegate service:self didCreateDefaultSessionConfiguration:defaultSessionConfiguration];
        }
        defaultSession = [NSURLSession sessionWithConfiguration:defaultSessionConfiguration delegate:self
                                                  delegateQueue:[NSOperationQueue mainQueue]];
    });
    return defaultSession;
}

- (NSURLSession *)ephemeralSession {
    static NSURLSessionConfiguration *ephemeralSessionConfiguration;
    static NSURLSession *ephemeralSession;
    static dispatch_once_t once_t;
    dispatch_once(&once_t, ^{
        ephemeralSessionConfiguration = [NSURLSessionConfiguration ephemeralSessionConfiguration];
        if([self.delegate respondsToSelector:@selector(service:didCreateEphemeralSessionConfiguration:)]) {
            [self.delegate service:self didCreateEphemeralSessionConfiguration:ephemeralSessionConfiguration];
        }
        ephemeralSession = [NSURLSession sessionWithConfiguration:ephemeralSessionConfiguration delegate:self
                                                    delegateQueue:[NSOperationQueue mainQueue]];
    });
    return ephemeralSession;
}

- (NSURLSession *)backgroundSession {
    static NSURLSessionConfiguration *backgroundSessionConfiguration;
    static NSURLSession *backgroundSession;
    static dispatch_once_t once_t;
    dispatch_once(&once_t, ^{
        backgroundSessionConfiguration =
        [NSURLSessionConfiguration backgroundSessionConfigurationWithIdentifier:
         [[NSBundle mainBundle] bundleIdentifier]];
        if([self.delegate respondsToSelector:@selector(service:didCreateBackgroundSessionConfiguration:)]) {
            [self.delegate service:self didCreateBackgroundSessionConfiguration:backgroundSessionConfiguration];
        }
        backgroundSession = [NSURLSession sessionWithConfiguration:backgroundSessionConfiguration delegate:self
                                                     delegateQueue:[[NSOperationQueue alloc] init]];
    });
    return backgroundSession;
}

- (AGX_INSTANCETYPE)init {
    if (AGX_EXPECT_T(self = [super init])) {
        _runningTasksSynchronizingQueue = dispatch_queue_create("com.agxnetwork.cachequeue", DISPATCH_QUEUE_SERIAL);
        dispatch_async(_runningTasksSynchronizingQueue, ^{ _activeTasks = [NSMutableArray array]; });
    }
    return self;
}

- (void)dealloc {
    agx_dispatch_release(_runningTasksSynchronizingQueue);
    AGX_SUPER_DEALLOC;
}

- (AGX_INSTANCETYPE)initWithHost:(NSString *)hostString {
    AGXService *service = [[AGXService alloc] init];
    _hostString = hostString;
    return service;
}

- (void)enableCache {
    [self enableCacheWithDirectoryPath:kAGXServiceDefaultCacheDirectory inMemoryCost:0];
}

- (void)enableCacheWithDirectoryPath:(NSString *)directoryPath inMemoryCost:(NSUInteger)memoryCost {
    NSString *reqdataPath = [NSString stringWithFormat:@"%@/reqdata", directoryPath];
    _reqDataCache = [AGXCache cacheWithDirectoryPath:reqdataPath memoryCost:memoryCost];
    NSString *rspdataPath = [NSString stringWithFormat:@"%@/rspdata", directoryPath];
    _rspDataCache = [AGXCache cacheWithDirectoryPath:rspdataPath memoryCost:memoryCost];
}

@end
