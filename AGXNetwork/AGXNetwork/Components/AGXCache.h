//
//  AGXCache.h
//  AGXNetwork
//
//  Created by Char Aznable on 2016/3/3.
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

#ifndef AGXNetwork_AGXCache_h
#define AGXNetwork_AGXCache_h

#import <AGXCore/AGXCore/AGXObjC.h>

@interface AGXCache : NSObject
@property (nonatomic, readonly) NSString *directoryPath;
@property (nonatomic, readonly) NSUInteger memoryCost;

+ (AGX_INSTANCETYPE)cacheWithDirectoryPath:(NSString *)directoryPath memoryCost:(NSUInteger)memoryCost;
- (AGX_INSTANCETYPE)initWithDirectoryPath:(NSString *)directoryPath memoryCost:(NSUInteger)memoryCost;
- (void)clean;

- (id)objectForKey:(id)key;
- (void)setObject:(id)obj forKey:(id<NSCopying>)key;
- (id)objectForKeyedSubscript:(id)key;
- (void)setObject:(id)obj forKeyedSubscript:(id<NSCopying>)key;
@end

#endif /* AGXNetwork_AGXCache_h */
