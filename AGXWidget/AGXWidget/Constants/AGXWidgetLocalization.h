//
//  AGXWidgetLocalization.h
//  AGXWidget
//
//  Created by Char Aznable on 2017/12/25.
//  Copyright © 2017 github.com/CharLemAznable. All rights reserved.
//

#ifndef AGXWidget_AGXWidgetLocalization_h
#define AGXWidget_AGXWidgetLocalization_h

#import <AGXCore/AGXCore/AGXLocalization.h>

#define AGXWidgetLocalizedStringDefault(key, val)   \
AGXLocalizedStringDefault((key), @"AGXWidget", (val))

#define AGXWidgetLocalizedString(key)               \
AGXWidgetLocalizedStringDefault((key), nil)

#endif /* AGXWidget_AGXWidgetLocalization_h */
