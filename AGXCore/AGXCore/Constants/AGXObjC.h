//
//  AGXObjC.h
//  AGXCore
//
//  Created by Char Aznable on 2016/2/4.
//  Copyright © 2016年 AI-CUC-EC. All rights reserved.
//

#ifndef AGXCore_AGXObjC_h
#define AGXCore_AGXObjC_h

#import <Foundation/Foundation.h>
#import "AGXC.h"

#if __has_feature(objc_instancetype)
# define AGX_INSTANCETYPE               instancetype
#else
# define AGX_INSTANCETYPE               id
#endif

#if __has_feature(objc_kindof)
# define AGX_KINDOF(exp)                __kindof exp
#else
# define AGX_KINDOF(exp)                id
#endif
#define AGX_MethodAccess(exp)           AGX_CLANG_Diagnostic(-Wobjc-method-access, exp)

#define agx_va_list(param)                                      \
({  NSMutableArray *temp = [NSMutableArray array];              \
    if AGX_EXPECT_T((param)) {                                  \
        id arg = (param);                                       \
        va_list _argvs_;                                        \
        va_start(_argvs_, (param));                             \
        do {[temp addObject:arg];                               \
        } while ((arg = va_arg(_argvs_, id)));                  \
        va_end(_argvs_);                                        \
    } temp; })

#define agx_async_main(exp)                                     \
dispatch_async(dispatch_get_main_queue(), ^{ exp })

#define agx_delay_main(sec, exp)                                \
dispatch_after(dispatch_time(DISPATCH_TIME_NOW,                 \
                             (sec)*NSEC_PER_SEC),               \
               dispatch_get_main_queue(), ^{ exp })

#define agx_once(exp)                                           \
AGX_STATIC dispatch_once_t once_t;dispatch_once(&once_t, ^{ exp })

#ifdef DEBUG
# define AGXLog(fmt, ...)   NSLog((@"%s [Line %d] " fmt), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__)
#else
# define AGXLog(...)
#endif

#define BETWEEN(exp, min, max) MAX((min), MIN((max), (exp)))

#define AGXAddNotification(sel, notification) AGXAddNotificationWithObject((sel), (notification), nil)
#define AGXAddNotificationWithObject(sel, notification, obj) \
[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(sel) name:(notification) object:(obj)]

#define AGXRemoveNotification(notification) AGXRemoveNotificationWithObject((notification), nil)
#define AGXRemoveNotificationWithObject(notification, obj) \
[[NSNotificationCenter defaultCenter] removeObserver:self name:(notification) object:(obj)]

#define AGXPostNotification(notification) AGXPostNotificationWithObject((notification), nil)
#define AGXPostNotificationWithObject(notification, obj) \
[[NSNotificationCenter defaultCenter] postNotificationName:(notification) object:(obj)]

#endif /* AGXCore_AGXObjC_h */
