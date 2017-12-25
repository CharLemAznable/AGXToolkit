//
//  AGXMath.m
//  AGXCore
//
//  Created by Char Aznable on 2016/4/2.
//  Copyright © 2016年 AI-CUC-EC. All rights reserved.
//

#import <math.h>
#import "AGXMath.h"

#if defined(__LP64__) || defined(NS_BUILD_32_LIKE_64)

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

AGX_EXTERN CGFloat cgsin(CGFloat a) {
    return sin(a);
}

AGX_EXTERN CGFloat cgcos(CGFloat a) {
    return cos(a);
}

AGX_EXTERN CGFloat cgtan(CGFloat a) {
    return tan(a);
}

AGX_EXTERN CGFloat cgasin(CGFloat a) {
    return asin(a);
}

AGX_EXTERN CGFloat cgacos(CGFloat a) {
    return acos(a);
}

AGX_EXTERN CGFloat cgatan(CGFloat a)  {
    return atan(a);
}

AGX_EXTERN CGFloat cgpow(CGFloat a, CGFloat b) {
    return pow(a, b);
}

AGX_EXTERN CGFloat cgsqrt(CGFloat a) {
    return sqrt(a);
}

#else // defined(__LP64__) || defined(NS_BUILD_32_LIKE_64)

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

AGX_EXTERN CGFloat cgsin(CGFloat a) {
    return sinf(a);
}

AGX_EXTERN CGFloat cgcos(CGFloat a) {
    return cosf(a);
}

AGX_EXTERN CGFloat cgtan(CGFloat a) {
    return tanf(a);
}

AGX_EXTERN CGFloat cgasin(CGFloat a) {
    return asinf(a);
}

AGX_EXTERN CGFloat cgacos(CGFloat a) {
    return acosf(a);
}

AGX_EXTERN CGFloat cgatan(CGFloat a)  {
    return atanf(a);
}

AGX_EXTERN CGFloat cgpow(CGFloat a, CGFloat b) {
    return powf(a, b);
}

AGX_EXTERN CGFloat cgsqrt(CGFloat a) {
    return sqrtf(a);
}

#endif // defined(__LP64__) || defined(NS_BUILD_32_LIKE_64)
