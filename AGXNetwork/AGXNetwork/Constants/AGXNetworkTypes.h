//
//  AGXNetworkTypes.h
//  AGXNetwork
//
//  Created by Char Aznable on 16/3/2.
//  Copyright © 2016年 AI-CUC-EC. All rights reserved.
//

//
//  Modify from:
//  MugunthKumar/MKNetworkKit
//

//  MKNetworkKit is licensed under MIT License Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

#ifndef AGXNetwork_AGXNetworkTypes_h
#define AGXNetwork_AGXNetworkTypes_h

#import <Foundation/NSObjCRuntime.h>

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
    AGXCachePolicyAlwaysUpdate  = 1 << 2, // always request update, no matter cache is stale or not
    AGXCachePolicyAlwaysCache   = 1 << 3, // use cached data if exists, or request server
    AGXCachePolicyOnlyCache     = 1 << 4, // only use cached data, if no cache, stop without error
};

#endif /* AGXNetwork_AGXNetworkTypes_h */
