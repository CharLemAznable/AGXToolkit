//
//  AGXCache.h
//  AGXNetwork
//
//  Created by Char Aznable on 16/3/3.
//  Copyright © 2016年 AI-CUC-EC. All rights reserved.
//

#ifndef AGXNetwork_AGXCache_h
#define AGXNetwork_AGXCache_h

#import <Foundation/Foundation.h>
#import <AGXCore/AGXCore/AGXObjC.h>

@interface AGXCache : NSObject
@property (nonatomic, readonly) NSString *directoryPath;
@property (nonatomic, readonly) NSUInteger memoryCost;

+ (AGXCache *)cacheWithDirectoryPath:(NSString *)directoryPath memoryCost:(NSUInteger)memoryCost;
- (AGX_INSTANCETYPE)initWithDirectoryPath:(NSString *)directoryPath memoryCost:(NSUInteger)memoryCost;
- (void)clean;

- (id)objectForKey:(id)key;
- (void)setObject:(id)obj forKey:(id<NSCopying>)key;
- (id)objectForKeyedSubscript:(id)key;
- (void)setObject:(id)obj forKeyedSubscript:(id<NSCopying>)key;
@end

#endif /* AGXNetwork_AGXCache_h */
