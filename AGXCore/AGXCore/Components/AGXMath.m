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

#else // defined(__LP64__) && __LP64__

AGX_INLINE CGFloat cgfabs(CGFloat v) {
    return fabsf(v);
}

#endif // defined(__LP64__) && __LP64__
