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
        self.runningTasksSynchronizingQueue = dispatch_queue_create("com.agxnetwork.cachequeue", DISPATCH_QUEUE_SERIAL);
        dispatch_async(self.runningTasksSynchronizingQueue, ^{ self.activeTasks = [NSMutableArray array]; });
    }
    return self;
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
    self.reqDataCache = [AGXCache cacheWithDirectoryPath:[NSString stringWithFormat:@"%@/reqdata", directoryPath]
                                              memoryCost:memoryCost];
    self.rspDataCache = [AGXCache cacheWithDirectoryPath:[NSString stringWithFormat:@"%@/rspdata", directoryPath]
                                              memoryCost:memoryCost];
}

@end
