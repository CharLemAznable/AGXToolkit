//
//  AGXObjC.h
//  AGXCore
//
//  Created by Char Aznable on 16/2/4.
//  Copyright © 2016年 AI-CUC-EC. All rights reserved.
//

#ifndef AGXCore_AGXObjC_h
#define AGXCore_AGXObjC_h

#import <Foundation/Foundation.h>

#ifdef __cplusplus
# define AGX_EXTERN                     extern "C" __attribute__((visibility ("default")))
#else
# define AGX_EXTERN                     extern __attribute__((visibility ("default")))
#endif

#define AGX_CONSTRUCTOR                 __attribute__((constructor)) static

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

#if __has_feature(objc_instancetype)
# define AGX_INSTANCETYPE               instancetype
#else
# define AGX_INSTANCETYPE               id
#endif

#if defined (__GNUC__) && (__GNUC__ >= 4)
# define AGX_EXPECTED(cond, expect)     __builtin_expect((long)(cond), (expect))
# define AGX_EXPECT_T(cond)             AGX_EXPECTED(cond, 1U)
# define AGX_EXPECT_F(cond)             AGX_EXPECTED(cond, 0U)
#else
# define AGX_EXPECTED(cond, expect)     (cond)
# define AGX_EXPECT_T(cond)             (cond)
# define AGX_EXPECT_F(cond)             (cond)
#endif

#if __has_feature(objc_kindof)
# define AGX_KINDOF(exp)                __kindof exp
#else
# define AGX_KINDOF(exp)                id
#endif

#define AGX_Pragma(x)                   _Pragma(#x)
#define AGX_CLANG_Diagnostic(x, exp)    \
AGX_Pragma(clang diagnostic push)       \
AGX_Pragma(clang diagnostic ignored #x) \
exp                                     \
AGX_Pragma(clang diagnostic pop)
#define AGX_MethodAccess(exp)           AGX_CLANG_Diagnostic(-Wobjc-method-access, exp)

#define agx_va_list(param)                          \
({  NSMutableArray *temp = [NSMutableArray array];  \
    if (param) {                                    \
        id arg = param;                             \
        va_list _argvs_;                            \
        va_start(_argvs_, param);                   \
        do {[temp addObject:arg];                   \
        } while ((arg = va_arg(_argvs_, id)));      \
        va_end(_argvs_);                            \
    } temp; })

#define agx_async_main(exp)             \
dispatch_async(dispatch_get_main_queue(), ^{ exp });

#define agx_delay_main(sec, exp)        \
dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (sec)*NSEC_PER_SEC), dispatch_get_main_queue(), ^{ exp });

#ifdef DEBUG
# define AGXLog(fmt, ...)   NSLog((@"%s [Line %d] " fmt), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__)
#else
# define AGXLog(...)
#endif

#define AGXAddNotification(sel, notification) AGXAddNotificationWithObject(sel, notification, nil)
#define AGXAddNotificationWithObject(sel, notification, obj) \
[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(sel) name:notification object:obj]

#define AGXRemoveNotification(notification) AGXRemoveNotificationWithObject(notification, nil)
#define AGXRemoveNotificationWithObject(notification, obj) \
[[NSNotificationCenter defaultCenter] removeObserver:self name:notification object:obj]

#define AGXPostNotification(notification) AGXPostNotificationWithObject(notification, nil)
#define AGXPostNotificationWithObject(notification, obj) \
[[NSNotificationCenter defaultCenter] postNotificationName:notification object:obj]

#endif /* AGXCore_AGXObjC_h */
