//
//  AGXCache.m
//  AGXNetwork
//
//  Created by Char Aznable on 16/3/3.
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

#import <UIKit/UIKit.h>
#import <AGXCore/AGXCore/AGXArc.h>
#import <AGXCore/AGXCore/AGXDirectory.h>
#import "AGXCache.h"

#define AGXCacheFileName(name) [NSString stringWithFormat:@"%@.agxcache", name]

NSUInteger const agxCacheDefaultCost = 10;

@implementation AGXCache {
    NSMutableDictionary *_memoryCache;
    NSMutableArray *_recentlyUsedKeys;
    dispatch_queue_t _queue;
}

+ (AGX_INSTANCETYPE)cacheWithDirectoryPath:(NSString *)directoryPath memoryCost:(NSUInteger)memoryCost {
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
        _memoryCost = memoryCost ?: agxCacheDefaultCost;

        _memoryCache = [[NSMutableDictionary alloc] initWithCapacity:_memoryCost];
        _recentlyUsedKeys = [[NSMutableArray alloc] initWithCapacity:_memoryCost];

        AGXDirectory.caches.createDirectory(directoryPath);

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

    [self flush];
    agx_dispatch_release(_queue);
    AGX_RELEASE(_recentlyUsedKeys);
    AGX_RELEASE(_memoryCache);
    AGX_RELEASE(_directoryPath);
    AGX_SUPER_DEALLOC;
}

- (void)flush {
    [_memoryCache enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        AGXDirectory.caches.subpathAs(_directoryPath).writeToFileWithContent(AGXCacheFileName(key), obj);
    }];

    [_memoryCache removeAllObjects];
    [_recentlyUsedKeys removeAllObjects];
}

- (void)clean {
    dispatch_async(_queue, ^{
        AGXDirectory.caches.deleteDirectory(_directoryPath);
        [_memoryCache removeAllObjects];
        [_recentlyUsedKeys removeAllObjects];
    });
}

- (id)objectForKey:(id)key {
    id cachedData = _memoryCache[key];
    if (cachedData) return cachedData;

    cachedData = AGXDirectory.caches.subpathAs(_directoryPath).contentWithFile(AGXCacheFileName(key));
    _memoryCache[key] = cachedData;
    return cachedData;
}

- (void)setObject:(id)obj forKey:(id<NSCopying>)key {
    dispatch_async(_queue, ^{
        _memoryCache[key] = obj;

        NSUInteger index = [_recentlyUsedKeys indexOfObject:key];
        if (index != NSNotFound) [_recentlyUsedKeys removeObjectAtIndex:index];
        [_recentlyUsedKeys insertObject:key atIndex:0];

        if (_recentlyUsedKeys.count > _memoryCost) {
            id lastUsedKey = _recentlyUsedKeys.lastObject;
            AGXDirectory.caches.subpathAs(_directoryPath)
            .writeToFileWithContent(AGXCacheFileName(lastUsedKey), _memoryCache[lastUsedKey]);

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

@end

#undef AGXCacheFileName
