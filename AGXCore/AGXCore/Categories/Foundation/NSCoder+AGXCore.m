//
//  NSCoder+AGXCore.m
//  AGXCore
//
//  Created by Char Aznable on 16/2/4.
//  Copyright © 2016年 AI-CUC-EC. All rights reserved.
//

#import "NSCoder+AGXCore.h"

@category_implementation(NSCoder, AGXCore)

#if defined(__LP64__) && __LP64__

- (void)encodeCGFloat:(CGFloat)realv forKey:(NSString *)key {
    [self encodeDouble:realv forKey:key];
}

- (CGFloat)decodeCGFloatForKey:(NSString *)key {
    return [self decodeDoubleForKey:key];
}

#else // defined(__LP64__) && __LP64__

- (void)encodeCGFloat:(CGFloat)realv forKey:(NSString *)key {
    [self encodeFloat:realv forKey:key];
}

- (CGFloat)decodeCGFloatForKey:(NSString *)key {
    return [self decodeFloatForKey:key];
}

#endif // defined(__LP64__) && __LP64__

@end
