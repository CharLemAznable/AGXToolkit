//
//  AGXObjC.h
//  AGXCore
//
//  Created by Char Aznable on 16/2/4.
//  Copyright © 2016年 AI-CUC-EC. All rights reserved.
//

#ifndef AGXCore_AGXObjC_h
#define AGXCore_AGXObjC_h

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

#if __has_feature(objc_generics)
# define AGX_KEY_TYPE                   KeyType
# define AGX_OBJECT_TYPE                ObjectType
# define AGX_GENERIC(a)                 <a>
# define AGX_COVARIANT_GENERIC(a)       <__covariant a>
# define AGX_GENERIC2(a, b)             <a, b>
# define AGX_COVARIANT_GENERIC2(a, b)   <__covariant a, __covariant b>
#else
# define AGX_KEY_TYPE                   id
# define AGX_OBJECT_TYPE                id
# define AGX_GENERIC(a)
# define AGX_COVARIANT_GENERIC(a)
# define AGX_GENERIC2(a, b)
# define AGX_COVARIANT_GENERIC2(a, b)
#endif

#ifdef DEBUG
# define AGXLog(fmt, ...)   NSLog((@"%s [Line %d] " fmt), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__);
#else
# define AGXLog(...)
#endif

#define AGXAddNotification(sel, notification) AGXAddNotificationWithObject(sel, notification, nil)
#define AGXAddNotificationWithObject(sel, notification, obj) \
[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(sel) name:notification object:obj]

#define AGXRemoveNotification(notification) AGXRemoveNotificationWithObject(notification, nil)
#define AGXRemoveNotificationWithObject(notification, obj) \
[[NSNotificationCenter defaultCenter] removeObserver:self name:notification object:obj]

#endif /* AGXCore_AGXObjC_h */
