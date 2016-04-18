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

@interface AGXService ()
@property (nonatomic, AGX_DISPATCH) dispatch_queue_t runningTasksSynchronizingQueue;
@property (nonatomic, AGX_STRONG)   NSMutableArray *activeTasks;

@property (nonatomic, AGX_STRONG)   NSString *hostString;

@property (nonatomic, AGX_STRONG)   AGXCache *reqDataCache;
@property (nonatomic, AGX_STRONG)   AGXCache *rspDataCache;
@end

@implementation AGXService

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
    service.hostString = hostString;
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
