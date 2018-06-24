//
//  AGXGcodeLocalization.h
//  AGXGcode
//
//  Created by Char Aznable on 2018/6/24.
//  Copyright © 2018年 AI-CUC-EC. All rights reserved.
//

#ifndef AGXGcode_AGXGcodeLocalization_h
#define AGXGcode_AGXGcodeLocalization_h

#import <AGXCore/AGXCore/AGXLocalization.h>

#define AGXGcodeLocalizedStringDefault(key, val)    \
AGXLocalizedStringDefault((key), @"AGXGcode", (val))

#define AGXGcodeLocalizedString(key)                \
AGXGcodeLocalizedStringDefault((key), nil)

#endif /* AGXGcode_AGXGcodeLocalization_h */
