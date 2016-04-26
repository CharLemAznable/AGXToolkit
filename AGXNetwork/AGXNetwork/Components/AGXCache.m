//
//  AGXCache.m
//  AGXNetwork
//
//  Created by Char Aznable on 16/3/3.
//  Copyright © 2016年 AI-CUC-EC. All rights reserved.
//

#import "AGXCache.h"
#import <UIKit/UIKit.h>
#import <AGXCore/AGXCore/AGXArc.h>
#import <AGXCore/AGXCore/AGXDirectory.h>

#define AGXCacheFileName(name) [NSString stringWithFormat:@"%@.agxcache", name]

NSUInteger const kAGXCacheDefaultCost = 10;

@implementation AGXCache {
    NSMutableDictionary *_memoryCache;
    NSMutableArray *_recentlyUsedKeys;
    dispatch_queue_t _queue;
}

+ (AGXCache *)cacheWithDirectoryPath:(NSString *)directoryPath memoryCost:(NSUInteger)memoryCost {
    return AGX_AUTORELEASE([[self alloc] initWithDirectoryPath:directoryPath memoryCost:memoryCost]);
}

- (AGX_INSTANCETYPE)init {
    @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                   reason:@"Please use initializer: -initWithDirectoryPath:memoryCost:"
                                 userInfo:nil];
    return nil;
}

- (AGX_INSTANCETYPE)initWithDirectoryPath:(NSString *)directoryPath memoryCost:(NSUInteger)memoryCost {
    NSParameterAssert(directoryPath != nil);
    if (AGX_EXPECT_T(self = [super init])) {
        _directoryPath = [directoryPath copy];
        _memoryCost = memoryCost ?: kAGXCacheDefaultCost;

        _memoryCache = [[NSMutableDictionary alloc] initWithCapacity:_memoryCost];
        _recentlyUsedKeys = [[NSMutableArray alloc] initWithCapacity:_memoryCost];

        [AGXDirectory createDirectory:directoryPath inDirectory:AGXCaches];

        _queue = dispatch_queue_create("com.agxnetwork.cachequeue", DISPATCH_QUEUE_SERIAL);

        AGXAddNotification(flush, UIApplicationDidReceiveMemoryWarningNotification);
        AGXAddNotification(flush, UIApplicationDidEnterBackgroundNotification);
        AGXAddNotification(flush, UIApplicationWillTerminateNotification);
    }
    return self;
}

- (void)dealloc {
    AGXRemoveNotification(UIApplicationDidReceiveMemoryWarningNotification);
    AGXRemoveNotification(UIApplicationDidEnterBackgroundNotification);
    AGXRemoveNotification(UIApplicationWillTerminateNotification);

    agx_dispatch_release(_queue);
    AGX_RELEASE(_recentlyUsedKeys);
    AGX_RELEASE(_memoryCache);
    AGX_RELEASE(_directoryPath);
    AGX_SUPER_DEALLOC;
}

- (void)flush {
    [_memoryCache enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        saveCacheFileReplaceExists(key, obj, _directoryPath);
    }];

    [_memoryCache removeAllObjects];
    [_recentlyUsedKeys removeAllObjects];
}

- (void)clean {
    dispatch_async(_queue, ^{
        [AGXDirectory deleteDirectory:_directoryPath inDirectory:AGXCaches];
        [_memoryCache removeAllObjects];
        [_recentlyUsedKeys removeAllObjects];
    });
}

- (id)objectForKey:(id)key {
    NSData *cachedData = _memoryCache[key];
    if (cachedData) return cachedData;

    NSString *fileName = AGXCacheFileName(key);
    if ([AGXDirectory fileExists:fileName inDirectory:AGXCaches subpath:_directoryPath]) {
        cachedData = [NSKeyedUnarchiver unarchiveObjectWithData:
                      [NSData dataWithContentsOfFile:
                       [AGXDirectory fullFilePath:fileName inDirectory:AGXCaches subpath:_directoryPath]]];
        _memoryCache[key] = cachedData;
        return cachedData;
    }
    return nil;
}

- (void)setObject:(id)obj forKey:(id<NSCopying>)key {
    dispatch_async(_queue, ^{
        _memoryCache[key] = obj;

        NSUInteger index = [_recentlyUsedKeys indexOfObject:key];
        if (index != NSNotFound) [_recentlyUsedKeys removeObjectAtIndex:index];
        [_recentlyUsedKeys insertObject:key atIndex:0];

        if (_recentlyUsedKeys.count > _memoryCost) {
            id lastUsedKey = _recentlyUsedKeys.lastObject;
            saveCacheFileReplaceExists(lastUsedKey, _memoryCache[lastUsedKey], _directoryPath);

            [_memoryCache removeObjectForKey:lastUsedKey];
            [_recentlyUsedKeys removeLastObject];
        }
    });
}

- (id)objectForKeyedSubscript:(id)key {
    return [self objectForKey:key];
}

- (void)setObject:(id)obj forKeyedSubscript:(id<NSCopying>)key {
    [self setObject:obj forKey:key];
}

#pragma mark - private method

AGX_STATIC_INLINE void saveCacheFileReplaceExists(id key, id obj, NSString *subpath) {
    NSString *fileName = AGXCacheFileName(key);
    if ([AGXDirectory fileExists:fileName inDirectory:AGXCaches subpath:subpath])
        [AGXDirectory deleteFile:fileName inDirectory:AGXCaches subpath:subpath];

    [[NSKeyedArchiver archivedDataWithRootObject:obj] writeToFile:
     [AGXDirectory fullFilePath:fileName inDirectory:AGXCaches subpath:subpath] atomically:YES];
}

@end

#undef AGXCacheFileName
