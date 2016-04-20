//
//  AGXNetworkTypes.h
//  AGXNetwork
//
//  Created by Char Aznable on 16/3/2.
//  Copyright © 2016年 AI-CUC-EC. All rights reserved.
//

#ifndef AGXNetwork_AGXNetworkTypes_h
#define AGXNetwork_AGXNetworkTypes_h

typedef NS_ENUM(NSUInteger, AGXDataEncoding) {
    AGXDataEncodingURL      = 0 , // default
    AGXDataEncodingJSON         ,
    AGXDataEncodingPlist        ,
    AGXDataEncodingCustom       ,
};

typedef NS_ENUM(NSUInteger, AGXRequestState) {
    AGXRequestStateReady                        = 0 ,
    AGXRequestStateStarted                          ,
    AGXRequestStateResponseAvailableFromCache       ,
    AGXRequestStateStaleResponseAvailableFromCache  ,
    AGXRequestStateCancelled                        ,
    AGXRequestStateCompleted                        ,
    AGXRequestStateError                            ,
};

@class AGXRequest;

typedef void (^AGXHandler)(AGXRequest *request);

#endif /* AGXNetwork_AGXNetworkTypes_h */
