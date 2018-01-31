//
//  NSNumber+AGXCore.m
//  AGXCore
//
//  Created by Char Aznable on 2016/2/4.
//  Copyright © 2016年 AI-CUC-EC. All rights reserved.
//

#import "NSNumber+AGXCore.h"
#import "AGXArc.h"

@category_implementation(NSNumber, AGXCore)

+ (AGX_INSTANCETYPE)numberWithCGFloat:(CGFloat)value {
    return AGX_AUTORELEASE([[self alloc] initWithCGFloat:value]);
}

#if defined(__LP64__) || defined(NS_BUILD_32_LIKE_64)

- (AGX_INSTANCETYPE)initWithCGFloat:(CGFloat)value {
    return [self initWithDouble:value];
}

- (CGFloat)cgfloatValue {
    return self.doubleValue;
}

#else // defined(__LP64__) || defined(NS_BUILD_32_LIKE_64)

- (AGX_INSTANCETYPE)initWithCGFloat:(CGFloat)value {
    return [self initWithFloat:value];
}

- (CGFloat)cgfloatValue {
    return self.floatValue;
}

#endif // defined(__LP64__) || defined(NS_BUILD_32_LIKE_64)

@end

@category_implementation(NSString, AGXCoreNSNumber)

#if defined(__LP64__) || defined(NS_BUILD_32_LIKE_64)

- (CGFloat)cgfloatValue {
    return self.doubleValue;
}

#else // defined(__LP64__) || defined(NS_BUILD_32_LIKE_64)

- (CGFloat)cgfloatValue {
    return self.floatValue;
}

#endif // defined(__LP64__) || defined(NS_BUILD_32_LIKE_64)

@end
