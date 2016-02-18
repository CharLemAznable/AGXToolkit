//
//  AGXArc.h
//  AGXCore
//
//  Created by Char Aznable on 16/2/4.
//  Copyright © 2016年 AI-CUC-EC. All rights reserved.
//

#ifndef AGXCore_AGXArc_h
#define AGXCore_AGXArc_h

#define IS_ARC                          __has_feature(objc_arc)

#if IS_ARC
# define AGX_STRONG                     strong
# define __AGX_STRONG                   __strong
#else
# define AGX_STRONG                     retain
# define __AGX_STRONG
#endif

#if __has_feature(objc_arc_weak)
# define AGX_WEAK                       weak
# define __AGX_WEAK                     __weak
#elif IS_ARC
# define AGX_WEAK                       unsafe_unretained
# define __AGX_WEAK                     __unsafe_unretained
#else
# define AGX_WEAK                       assign
# define __AGX_WEAK
#endif

#if IS_ARC
# define __AGX_AUTORELEASE              __autoreleasing
#else
# define __AGX_AUTORELEASE
#endif

#if IS_ARC
# define AGX_JUST_AUTORELEASE(exp)
# define AGX_AUTORELEASE(exp)           exp
# define AGX_RELEASE(exp)
# define AGX_RETAIN(exp)                exp
# define AGX_SUPER_DEALLOC
#else
# define AGX_JUST_AUTORELEASE(exp)      [exp autorelease]
# define AGX_AUTORELEASE(exp)           [exp autorelease]
# define AGX_RELEASE(exp)               [exp release]
# define AGX_RETAIN(exp)                [exp retain]
# define AGX_SUPER_DEALLOC              [super dealloc]
#endif

#if IS_ARC
# define AGX_BRIDGE                     __bridge
# define AGX_BRIDGE_TRANSFER            __bridge_transfer
# define AGX_BRIDGE_RETAIN              __bridge_retained
# define AGX_CFRelease(exp)             CFRelease(exp)
#else
# define AGX_BRIDGE
# define AGX_BRIDGE_TRANSFER
# define AGX_BRIDGE_RETAIN
# define AGX_CFRelease(exp)
#endif

#if IS_ARC
# define AGX_BLOCK_COPY(exp)            exp
# define AGX_BLOCK_RELEASE(exp)
#else
# define AGX_BLOCK_COPY(exp)            _Block_copy(exp)
# define AGX_BLOCK_RELEASE(exp)         _Block_release(exp)
#endif

#endif /* AGXCore_AGXArc_h */
