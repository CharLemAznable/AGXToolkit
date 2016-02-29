//
//  AGXReachability.h
//  AGXNetwork
//
//  Created by Char Aznable on 16/2/29.
//  Copyright © 2016年 AI-CUC-EC. All rights reserved.
//

/*
 Copyright (c) 2011, Tony Million.
 All rights reserved.
 
 Redistribution and use in source and binary forms, with or without
 modification, are permitted provided that the following conditions are met:
 
 1. Redistributions of source code must retain the above copyright notice, this
 list of conditions and the following disclaimer.
 
 2. Redistributions in binary form must reproduce the above copyright notice,
 this list of conditions and the following disclaimer in the documentation
 and/or other materials provided with the distribution.
 
 THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
 AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
 IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
 ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE
 LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
 CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
 SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
 INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
 CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
 ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
 POSSIBILITY OF SUCH DAMAGE.
 */

#ifndef AGXNetwork_AGXReachability_h
#define AGXNetwork_AGXReachability_h

#import <Foundation/Foundation.h>
#import <SystemConfiguration/SystemConfiguration.h>
#import <AGXCore/AGXCore/AGXObjC.h>

extern NSString *const agxkReachabilityChangedNotification;

typedef NS_ENUM(NSInteger, AGXNetworkStatus) {
    // Apple NetworkStatus Compatible Names.
    AGXNotReachable     = 0,
    AGXReachableViaWWAN = 1,
    AGXReachableViaWiFi = 2,
};

@class AGXReachability;

typedef void (^AGXNetworkReachable)(AGXReachability *reachability);
typedef void (^AGXNetworkUnreachable)(AGXReachability *reachability);
typedef void (^AGXNetworkReachability)(AGXReachability *reachability, SCNetworkConnectionFlags flags);

@interface AGXReachability : NSObject
@property (nonatomic, copy)     AGXNetworkReachable     reachableBlock;
@property (nonatomic, copy)     AGXNetworkUnreachable   unreachableBlock;
@property (nonatomic, copy)     AGXNetworkReachability  reachabilityBlock;
@property (nonatomic, assign)   BOOL reachableOnWWAN;

+ (AGXReachability *)reachabilityWithHostname:(NSString *)hostname;
// This is identical to the function above, but is here to maintain
//compatibility with Apples original code. (see .m)
+ (AGXReachability *)reachabilityWithHostName:(NSString *)hostname;
+ (AGXReachability *)reachabilityForInternetConnection;
+ (AGXReachability *)reachabilityWithAddress:(void *)hostAddress;
+ (AGXReachability *)reachabilityForLocalWiFi;
- (AGX_INSTANCETYPE)initWithReachabilityRef:(SCNetworkReachabilityRef)ref;

- (BOOL)startNotifier;
- (void)stopNotifier;

- (BOOL)isReachable;
- (BOOL)isReachableViaWWAN;
- (BOOL)isReachableViaWiFi;

// WWAN may be available, but not active until a connection has been established.
// WiFi may require a connection for VPN on Demand.
- (BOOL)isConnectionRequired; // Identical DDG variant.
- (BOOL)connectionRequired; // Apple's routine.
// Dynamic, on demand connection?
- (BOOL)isConnectionOnDemand;
// Is user intervention required?
- (BOOL)isInterventionRequired;

- (AGXNetworkStatus)currentReachabilityStatus;
- (SCNetworkReachabilityFlags)reachabilityFlags;
- (NSString *)currentReachabilityString;
- (NSString *)currentReachabilityFlags;
@end

#endif /* AGXNetwork_AGXReachability_h */
