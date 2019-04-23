//
//  AGXWKWebViewLogLevel.h
//  AGXWidget
//
//  Created by Char on 2019/4/17.
//  Copyright © 2019 github.com/CharLemAznable. All rights reserved.
//

#ifndef AGXWidget_AGXWKWebViewLogLevel_h
#define AGXWidget_AGXWKWebViewLogLevel_h

#import <Foundation/NSObjCRuntime.h>
#import <AGXCore/AGXCore/AGXObjC.h>

typedef NS_ENUM (NSUInteger, AGXWKWebViewLogLevel) {
    AGXWKWebViewLogDebug    ,
    AGXWKWebViewLogInfo     ,
    AGXWKWebViewLogWarn     ,
    AGXWKWebViewLogError    ,
};

AGX_EXTERN NSString *NSStringFromWKWebViewLogLevel(AGXWKWebViewLogLevel level);

#endif /* AGXWidget_AGXWKWebViewLogLevel_h */
