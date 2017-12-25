//
//  AGXC.h
//  AGXCore
//
//  Created by Char Aznable on 17/9/27.
//  Copyright © 2017年 AI-CUC-EC. All rights reserved.
//

#ifndef AGXCore_AGXC_h
#define AGXCore_AGXC_h

#ifdef __cplusplus
# define AGX_EXTERN                     extern "C" __attribute__((visibility ("default")))
#else
# define AGX_EXTERN                     extern __attribute__((visibility ("default")))
#endif

#define AGX_CONSTRUCTOR                 __attribute__((constructor)) static

#define AGX_OVERLOAD                    __attribute__((overloadable))

#define AGX_STATIC                      static

#if defined(__STDC_VERSION__) && __STDC_VERSION__ >= 199901L
# define AGX_INLINE                     inline
# define AGX_STATIC_INLINE              static inline
#elif defined(__cplusplus)
# define AGX_INLINE                     inline
# define AGX_STATIC_INLINE              static inline
#elif defined(__GNUC__)
# define AGX_INLINE                     __inline__
# define AGX_STATIC_INLINE              static __inline__
#else
# define AGX_INLINE
# define AGX_STATIC_INLINE              static
#endif

#if defined (__GNUC__) && (__GNUC__ >= 4)
# define AGX_EXPECTED(cond, expect)     (__builtin_expect((long)(cond), (expect)))
# define AGX_EXPECT_T(cond)             AGX_EXPECTED((cond), 1U)
# define AGX_EXPECT_F(cond)             AGX_EXPECTED((cond), 0U)
#else
# define AGX_EXPECTED(cond, expect)     (cond)
# define AGX_EXPECT_T(cond)             (cond)
# define AGX_EXPECT_F(cond)             (cond)
#endif

#define AGX_Pragma(x)                   _Pragma(#x)
#define AGX_CLANG_Diagnostic(x, exp)    \
AGX_Pragma(clang diagnostic push)       \
AGX_Pragma(clang diagnostic ignored #x) \
exp                                     \
AGX_Pragma(clang diagnostic pop)

#endif /* AGXCore_AGXC_h */
