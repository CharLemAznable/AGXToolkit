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

typedef NS_OPTIONS(NSUInteger, AGXCachePolicy) {
    AGXCachePolicyDefault       = 0     ,
    AGXCachePolicyDoNotCache    = 1     , // not write to cache
    AGXCachePolicyIgnoreCache   = 1 << 1, // request ignore cache
    AGXCachePolicyUpdateStale   = 1 << 2, // request for update when the cache is stale
    AGXCachePolicyUpdateAlways  = 1 << 3, // always request update, no matter cache is stale or not
    AGXCachePolicyAlwaysCache   = 1 << 4, // use cached data if exists, or request server
    AGXCachePolicyOnlyCache     = 1 << 5, // only use cached data, if no cache, stop without error
};

@class AGXRequest;

typedef void (^AGXHandler)(AGXRequest *request);

#endif /* AGXNetwork_AGXNetworkTypes_h */
