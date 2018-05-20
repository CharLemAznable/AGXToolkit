//
//  AGXWebViewLogLevel.h
//  AGXWidget
//
//  Created by Char Aznable on 2017/11/27.
//  Copyright © 2017年 AI-CUC-EC. All rights reserved.
//

#ifndef AGXWidget_AGXWebViewLogLevel_h
#define AGXWidget_AGXWebViewLogLevel_h

#import <Foundation/NSObjCRuntime.h>
#import <AGXCore/AGXCore/AGXObjC.h>

typedef NS_ENUM (NSUInteger, AGXWebViewLogLevel) {
    AGXWebViewLogDebug      ,
    AGXWebViewLogInfo       ,
    AGXWebViewLogWarn       ,
    AGXWebViewLogError      ,
};

AGX_EXTERN NSString *NSStringFromWebViewLogLevel(AGXWebViewLogLevel level);

#endif /* AGXWidget_AGXWebViewLogLevel_h */
