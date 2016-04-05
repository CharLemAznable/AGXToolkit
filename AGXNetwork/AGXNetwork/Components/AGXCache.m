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

@interface AGXCache ()
@property (nonatomic, AGX_STRONG)   NSMutableDictionary *memoryCache;
@property (nonatomic, AGX_STRONG)   NSMutableArray *recentlyUsedKeys;
@property (nonatomic, AGX_DISPATCH) dispatch_queue_t queue;
@end

@implementation AGXCache

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
        _memoryCost = memoryCost ? memoryCost : kAGXCacheDefaultCost;
        
        _memoryCache = [[NSMutableDictionary alloc] initWithCapacity:self.memoryCost];
        _recentlyUsedKeys = [[NSMutableArray alloc] initWithCapacity:self.memoryCost];
        
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
    [self.memoryCache enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        saveCacheFileReplaceExists(key, obj, _directoryPath);
    }];
    
    [self.memoryCache removeAllObjects];
    [self.recentlyUsedKeys removeAllObjects];
}

- (void)clean {
    dispatch_async(self.queue, ^{
        [AGXDirectory deleteDirectory:_directoryPath inDirectory:AGXCaches];
        [self.memoryCache removeAllObjects];
        [self.recentlyUsedKeys removeAllObjects];
    });
}

- (id)objectForKey:(id)key {
    NSData *cachedData = self.memoryCache[key];
    if (cachedData) return cachedData;
    
    NSString *fileName = AGXCacheFileName(key);
    if ([AGXDirectory fileExists:fileName inDirectory:AGXCaches subpath:_directoryPath]) {
        cachedData = [NSKeyedUnarchiver unarchiveObjectWithData:
                      [NSData dataWithContentsOfFile:
                       [AGXDirectory fullFilePath:fileName inDirectory:AGXCaches subpath:_directoryPath]]];
        self.memoryCache[key] = cachedData;
        return cachedData;
    }
    return nil;
}

- (void)setObject:(id)obj forKey:(id<NSCopying>)key {
    dispatch_async(self.queue, ^{
        self.memoryCache[key] = obj;
        
        NSUInteger index = [self.recentlyUsedKeys indexOfObject:key];
        if (index != NSNotFound) [self.recentlyUsedKeys removeObjectAtIndex:index];
        [self.recentlyUsedKeys insertObject:key atIndex:0];
        
        if (self.recentlyUsedKeys.count > self.memoryCost) {
            id lastUsedKey = self.recentlyUsedKeys.lastObject;
            saveCacheFileReplaceExists(lastUsedKey, self.memoryCache[lastUsedKey], _directoryPath);
            
            [self.memoryCache removeObjectForKey:lastUsedKey];
            [self.recentlyUsedKeys removeLastObject];
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
