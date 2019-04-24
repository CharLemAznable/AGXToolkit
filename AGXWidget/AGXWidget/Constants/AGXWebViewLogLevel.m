//
//  AGXWebViewLogLevel.m
//  AGXWidget
//
//  Created by Char Aznable on 2017/11/27.
//  Copyright © 2017 github.com/CharLemAznable. All rights reserved.
//

#import "AGXWebViewLogLevel.h"

AGX_INLINE NSString *NSStringFromWebViewLogLevel(AGXWebViewLogLevel level) {
    switch (level) {
        case AGXWebViewLogDebug:
            return @"DEBUG";
        case AGXWebViewLogInfo:
            return @"INFO";
        case AGXWebViewLogWarn:
            return @"WARN";
        case AGXWebViewLogError:
            return @"ERROR";
        default:
            return @"LOG";
    }
}
