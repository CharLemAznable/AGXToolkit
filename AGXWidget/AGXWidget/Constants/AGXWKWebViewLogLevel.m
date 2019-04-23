//
//  AGXWKWebViewLogLevel.m
//  AGXWidget
//
//  Created by Char on 2019/4/17.
//  Copyright © 2019 github.com/CharLemAznable. All rights reserved.
//

#import "AGXWKWebViewLogLevel.h"

AGX_INLINE NSString *NSStringFromWKWebViewLogLevel(AGXWKWebViewLogLevel level) {
    switch (level) {
        case AGXWKWebViewLogDebug:
            return @"DEBUG";
        case AGXWKWebViewLogInfo:
            return @"INFO";
        case AGXWKWebViewLogWarn:
            return @"WARN";
        case AGXWKWebViewLogError:
            return @"ERROR";
        default:
            return @"LOG";
    }
}
