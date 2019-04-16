//
//  AGXAdapt.h
//  AGXCore
//
//  Created by Char Aznable on 2016/2/4.
//  Copyright © 2016年 AI-CUC-EC. All rights reserved.
//

#ifndef AGXCore_AGXAdapt_h
#define AGXCore_AGXAdapt_h

#import "NSString+AGXCore.h"

#if __IPHONE_OS_VERSION_MIN_REQUIRED < __IPHONE_10_0
# error AGXToolkit is supported only on iOS 10 and above
#endif

#define AGX_CHECK_CURRENT_MODE_SIZE(width, height) \
([UIScreen instancesRespondToSelector:@selector(currentMode)] ? \
CGSizeEqualToSize(CGSizeMake((width), (height)), UIScreen.mainScreen.currentMode.size) : NO)

#define AGX_IS_IPHONE4                  AGX_CHECK_CURRENT_MODE_SIZE(640, 960)
#define AGX_IS_IPHONE5                  AGX_CHECK_CURRENT_MODE_SIZE(640, 1136)
#define AGX_IS_IPHONE6                  AGX_CHECK_CURRENT_MODE_SIZE(750, 1334)
#define AGX_IS_IPHONE6_BIGMODE          AGX_CHECK_CURRENT_MODE_SIZE(640, 1136)
#define AGX_IS_IPHONE6P                 AGX_CHECK_CURRENT_MODE_SIZE(1242, 2208)
#define AGX_IS_IPHONE6P_BIGMODE         AGX_CHECK_CURRENT_MODE_SIZE(1125, 2001)
#define AGX_IS_IPHONEX                  AGX_CHECK_CURRENT_MODE_SIZE(1125, 2436)
#define AGX_IS_IPHONEXR                 AGX_CHECK_CURRENT_MODE_SIZE(828, 1792)
#define AGX_IS_IPHONEXSMAX              AGX_CHECK_CURRENT_MODE_SIZE(1242, 2688)

#define AGX_DeviceScale                                                 \
(AGX_IS_IPHONE6P||AGX_IS_IPHONEXR||AGX_IS_IPHONEXSMAX?1.29375:          \
(AGX_IS_IPHONEX||AGX_IS_IPHONE6||AGX_IS_IPHONE6P_BIGMODE?1.171875:1.0)) // 414/320=1.29375 375/320=1.171875

#define AGX_ScreenSize                  (UIScreen.mainScreen.bounds.size)
#define AGX_ScreenWidth                 (AGX_ScreenSize.width)
#define AGX_ScreenHeight                (AGX_ScreenSize.height)
#define AGX_SinglePixel                 (1/UIScreen.mainScreen.scale)

#define AGX_SYSTEM_VERSION_COMPARE(ver) [UIDevice.currentDevice.systemVersion compareToVersionString:@ver]

#define AGX_BEFORE_IOS10_0              (NSOrderedAscending == AGX_SYSTEM_VERSION_COMPARE("10.0"))
#define AGX_BEFORE_IOS10_1              (NSOrderedAscending == AGX_SYSTEM_VERSION_COMPARE("10.1"))
#define AGX_BEFORE_IOS10_2              (NSOrderedAscending == AGX_SYSTEM_VERSION_COMPARE("10.2"))
#define AGX_BEFORE_IOS10_3              (NSOrderedAscending == AGX_SYSTEM_VERSION_COMPARE("10.3"))
#define AGX_BEFORE_IOS11_0              (NSOrderedAscending == AGX_SYSTEM_VERSION_COMPARE("11.0"))
#define AGX_BEFORE_IOS11_1              (NSOrderedAscending == AGX_SYSTEM_VERSION_COMPARE("11.1"))
#define AGX_BEFORE_IOS11_2              (NSOrderedAscending == AGX_SYSTEM_VERSION_COMPARE("11.2"))
#define AGX_BEFORE_IOS11_3              (NSOrderedAscending == AGX_SYSTEM_VERSION_COMPARE("11.3"))
#define AGX_BEFORE_IOS11_4              (NSOrderedAscending == AGX_SYSTEM_VERSION_COMPARE("11.4"))
#define AGX_BEFORE_IOS12_0              (NSOrderedAscending == AGX_SYSTEM_VERSION_COMPARE("12.0"))
#define AGX_BEFORE_IOS12_1              (NSOrderedAscending == AGX_SYSTEM_VERSION_COMPARE("12.1"))
#define AGX_BEFORE_IOS12_2              (NSOrderedAscending == AGX_SYSTEM_VERSION_COMPARE("12.2"))

#define AGX_IOS10_0_OR_LATER            (!AGX_BEFORE_IOS10_0)
#define AGX_IOS10_1_OR_LATER            (!AGX_BEFORE_IOS10_1)
#define AGX_IOS10_2_OR_LATER            (!AGX_BEFORE_IOS10_2)
#define AGX_IOS10_3_OR_LATER            (!AGX_BEFORE_IOS10_3)
#define AGX_IOS11_0_OR_LATER            (!AGX_BEFORE_IOS11_0)
#define AGX_IOS11_1_OR_LATER            (!AGX_BEFORE_IOS11_1)
#define AGX_IOS11_2_OR_LATER            (!AGX_BEFORE_IOS11_2)
#define AGX_IOS11_3_OR_LATER            (!AGX_BEFORE_IOS11_3)
#define AGX_IOS11_4_OR_LATER            (!AGX_BEFORE_IOS11_4)
#define AGX_IOS12_0_OR_LATER            (!AGX_BEFORE_IOS12_0)
#define AGX_IOS12_1_OR_LATER            (!AGX_BEFORE_IOS12_1)
#define AGX_IOS12_2_OR_LATER            (!AGX_BEFORE_IOS12_2)

#endif /* AGXCore_AGXAdapt_h */
