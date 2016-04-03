//
//  AGXMath.m
//  AGXCore
//
//  Created by Char Aznable on 16/4/2.
//  Copyright © 2016年 AI-CUC-EC. All rights reserved.
//

#import "AGXMath.h"
#import <math.h>

#if defined(__LP64__) && __LP64__

AGX_INLINE CGFloat cgfabs(CGFloat v) {
    return fabs(v);
}

AGX_INLINE CGFloat cgceil(CGFloat v) {
    return ceil(v);
}

AGX_INLINE CGFloat cgfloor(CGFloat v) {
    return floor(v);
}

AGX_INLINE CGFloat cground(CGFloat v) {
    return round(v);
}

AGX_INLINE long int cglround(CGFloat v) {
    return lround(v);
}

#else // defined(__LP64__) && __LP64__

AGX_INLINE CGFloat cgfabs(CGFloat v) {
    return fabsf(v);
}

AGX_INLINE CGFloat cgceil(CGFloat v) {
    return ceilf(v);
}

AGX_INLINE CGFloat cgfloor(CGFloat v) {
    return floorf(v);
}

AGX_INLINE CGFloat cground(CGFloat v) {
    return roundf(v);
}

AGX_INLINE long int cglround(CGFloat v) {
    return lroundf(v);
}

#endif // defined(__LP64__) && __LP64__
