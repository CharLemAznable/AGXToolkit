//
//  AGXReachability.m
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

#import "AGXReachability.h"
#import <sys/socket.h>
#import <netinet/in.h>
#import <netinet6/in6.h>
#import <arpa/inet.h>
#import <ifaddrs.h>
#import <netdb.h>
#import <AGXCore/AGXCore/AGXArc.h>

NSString *const agxkReachabilityChangedNotification = @"kReachabilityChangedNotification";

@interface AGXReachability ()
@property (nonatomic, assign)       SCNetworkReachabilityRef    reachabilityRef;
@property (nonatomic, AGX_DISPATCH) dispatch_queue_t            reachabilitySerialQueue;
@property (nonatomic, AGX_STRONG)   id                          reachabilityObject;

- (void)reachabilityChanged:(SCNetworkReachabilityFlags)flags;
- (BOOL)isReachableWithFlags:(SCNetworkReachabilityFlags)flags;
@end

static NSString *reachabilityFlags(SCNetworkReachabilityFlags flags) {
    return [NSString stringWithFormat:@"%c%c %c%c%c%c%c%c%c",
#if	TARGET_OS_IPHONE
            (flags & kSCNetworkReachabilityFlagsIsWWAN)               ? 'W' : '-',
#else
            'X',
#endif
            (flags & kSCNetworkReachabilityFlagsReachable)            ? 'R' : '-',
            (flags & kSCNetworkReachabilityFlagsConnectionRequired)   ? 'c' : '-',
            (flags & kSCNetworkReachabilityFlagsTransientConnection)  ? 't' : '-',
            (flags & kSCNetworkReachabilityFlagsInterventionRequired) ? 'i' : '-',
            (flags & kSCNetworkReachabilityFlagsConnectionOnTraffic)  ? 'C' : '-',
            (flags & kSCNetworkReachabilityFlagsConnectionOnDemand)   ? 'D' : '-',
            (flags & kSCNetworkReachabilityFlagsIsLocalAddress)       ? 'l' : '-',
            (flags & kSCNetworkReachabilityFlagsIsDirect)             ? 'd' : '-'];
}

static void TMReachabilityCallback(SCNetworkReachabilityRef target, SCNetworkReachabilityFlags flags, void *info) {
#pragma unused (target)
    AGXReachability *reachability = (AGX_BRIDGE AGXReachability *)info;
    @autoreleasepool { [reachability reachabilityChanged:flags]; }
}

@implementation AGXReachability

+ (AGXReachability *)reachabilityWithHostname:(NSString *)hostname {
    SCNetworkReachabilityRef ref = CFAutorelease(SCNetworkReachabilityCreateWithName(NULL, [hostname UTF8String]));
    return ref ? AGX_AUTORELEASE([[self alloc] initWithReachabilityRef:ref]) : nil;
}

+ (AGXReachability *)reachabilityWithAddress:(void *)hostAddress {
    SCNetworkReachabilityRef ref = CFAutorelease(SCNetworkReachabilityCreateWithAddress(kCFAllocatorDefault, (const struct sockaddr *)hostAddress));
    return ref ? AGX_AUTORELEASE([[self alloc] initWithReachabilityRef:ref]) : nil;
}

+ (AGXReachability *)reachabilityForInternetConnection {
    struct sockaddr_in zeroAddress;
    bzero(&zeroAddress, sizeof(zeroAddress));
    zeroAddress.sin_len     = sizeof(zeroAddress);
    zeroAddress.sin_family  = AF_INET;
    return [self reachabilityWithAddress:&zeroAddress];
}

+ (AGXReachability *)reachabilityForLocalWiFi {
    struct sockaddr_in localWifiAddress;
    bzero(&localWifiAddress, sizeof(localWifiAddress));
    localWifiAddress.sin_len            = sizeof(localWifiAddress);
    localWifiAddress.sin_family         = AF_INET;
    localWifiAddress.sin_addr.s_addr    = htonl(IN_LINKLOCALNETNUM);
    return [self reachabilityWithAddress:&localWifiAddress];
}

- (AGX_INSTANCETYPE)initWithReachabilityRef:(SCNetworkReachabilityRef)ref {
    if (AGX_EXPECT_T(self = [super init])) {
        self.reachableOnWWAN = YES;
        self.reachabilityRef = ref;
    }
    return self;
}

- (void)dealloc {
    [self stopNotifier];
    
    if (self.reachabilityRef) {
        CFRelease(self.reachabilityRef);
        self.reachabilityRef = nil;
    }
    self.reachableBlock          = nil;
    self.unreachableBlock        = nil;
    self.reachabilitySerialQueue = nil;
    AGX_SUPER_DEALLOC;
}

#pragma mark - Notifier Methods

- (BOOL)startNotifier {
    SCNetworkReachabilityContext context = { 0, NULL, NULL, NULL, NULL };
    self.reachabilityObject = self;
    self.reachabilitySerialQueue = dispatch_queue_create("com.tonymillion.reachability", NULL);
    if (AGX_EXPECT_F(!self.reachabilitySerialQueue)) return NO;
    
    context.info = (AGX_BRIDGE void *)self;
    if (!SCNetworkReachabilitySetCallback(self.reachabilityRef, TMReachabilityCallback, &context)) {
        AGXLog(@"SCNetworkReachabilitySetCallback() failed: %s", SCErrorString(SCError()));
        
        if (self.reachabilitySerialQueue) {
            agx_dispatch_release(self.reachabilitySerialQueue);
            self.reachabilitySerialQueue = nil;
        }
        self.reachabilityObject = nil;
        return NO;
    }
    
    if (!SCNetworkReachabilitySetDispatchQueue(self.reachabilityRef, self.reachabilitySerialQueue)) {
        AGXLog(@"SCNetworkReachabilitySetDispatchQueue() failed: %s", SCErrorString(SCError()));
        
        SCNetworkReachabilitySetCallback(self.reachabilityRef, NULL, NULL);
        if (self.reachabilitySerialQueue) {
            agx_dispatch_release(self.reachabilitySerialQueue);
            self.reachabilitySerialQueue = nil;
        }
        self.reachabilityObject = nil;
        return NO;
    }
    
    return YES;
}

- (void)stopNotifier {
    SCNetworkReachabilitySetCallback(self.reachabilityRef, NULL, NULL);
    SCNetworkReachabilitySetDispatchQueue(self.reachabilityRef, NULL);
    
    if (self.reachabilitySerialQueue) {
        agx_dispatch_release(self.reachabilitySerialQueue);
        self.reachabilitySerialQueue = nil;
    }
    self.reachabilityObject = nil;
}

#pragma mark - reachability tests

// This is for the case where you flick the airplane mode;
// you end up getting something like this:
//Reachability: WR ct-----
//Reachability: -- -------
//Reachability: WR ct-----
//Reachability: -- -------
// We treat this as 4 UNREACHABLE triggers - really apple should do better than this

#define testcase (kSCNetworkReachabilityFlagsConnectionRequired | kSCNetworkReachabilityFlagsTransientConnection)

- (BOOL)isReachableWithFlags:(SCNetworkReachabilityFlags)flags {
    BOOL connectionUP = YES;
    if (!(flags & kSCNetworkReachabilityFlagsReachable)) connectionUP = NO;
    if ((flags & testcase) == testcase) connectionUP = NO;
    
#if	TARGET_OS_IPHONE
    if (flags & kSCNetworkReachabilityFlagsIsWWAN) {
        if (!self.reachableOnWWAN) connectionUP = NO;
    }
#endif
    
    return connectionUP;
}

- (BOOL)isReachable {
    SCNetworkReachabilityFlags flags;
    if (!SCNetworkReachabilityGetFlags(self.reachabilityRef, &flags)) return NO;
    return [self isReachableWithFlags:flags];
}

- (BOOL)isReachableViaWWAN {
#if	TARGET_OS_IPHONE
    SCNetworkReachabilityFlags flags = 0;
    if (SCNetworkReachabilityGetFlags(self.reachabilityRef, &flags)) {
        if ((flags & kSCNetworkReachabilityFlagsReachable) &&
            (flags & kSCNetworkReachabilityFlagsIsWWAN)) return YES;
    }
#endif
    return NO;
}

- (BOOL)isReachableViaWiFi {
    SCNetworkReachabilityFlags flags = 0;
    if (SCNetworkReachabilityGetFlags(self.reachabilityRef, &flags)) {
        if ((flags & kSCNetworkReachabilityFlagsReachable)) {
#if	TARGET_OS_IPHONE
            if (flags & kSCNetworkReachabilityFlagsIsWWAN) return NO;
#endif
            return YES;
        }
    }
    return NO;
}

- (BOOL)isConnectionRequired {
    return [self connectionRequired];
}

- (BOOL)connectionRequired {
    SCNetworkReachabilityFlags flags;
    if (SCNetworkReachabilityGetFlags(self.reachabilityRef, &flags))
        return (flags & kSCNetworkReachabilityFlagsConnectionRequired);
    return NO;
}

- (BOOL)isConnectionOnDemand {
    SCNetworkReachabilityFlags flags;
    if (SCNetworkReachabilityGetFlags(self.reachabilityRef, &flags)) {
        return ((flags & kSCNetworkReachabilityFlagsConnectionRequired) &&
                (flags & (kSCNetworkReachabilityFlagsConnectionOnTraffic | kSCNetworkReachabilityFlagsConnectionOnDemand)));
    }
    return NO;
}

- (BOOL)isInterventionRequired {
    SCNetworkReachabilityFlags flags;
    if (SCNetworkReachabilityGetFlags(self.reachabilityRef, &flags)) {
        return ((flags & kSCNetworkReachabilityFlagsConnectionRequired) &&
                (flags & kSCNetworkReachabilityFlagsInterventionRequired));
    }
    return NO;
}

#pragma mark - reachability status stuff

- (AGXNetworkStatus)currentReachabilityStatus {
    if ([self isReachable]) {
        if([self isReachableViaWiFi])
            return AGXReachableViaWiFi;
#if	TARGET_OS_IPHONE
        return AGXReachableViaWWAN;
#endif
    }
    return AGXNotReachable;
}

- (SCNetworkReachabilityFlags)reachabilityFlags {
    SCNetworkReachabilityFlags flags = 0;
    if (SCNetworkReachabilityGetFlags(self.reachabilityRef, &flags)) return flags;
    return 0;
}

- (NSString *)currentReachabilityString {
    AGXNetworkStatus status = [self currentReachabilityStatus];
    if (status == AGXReachableViaWWAN) return NSLocalizedString(@"Cellular", @"");
    if (status == AGXReachableViaWiFi) return NSLocalizedString(@"WiFi", @"");
    return NSLocalizedString(@"No Connection", @"");
}

- (NSString *)currentReachabilityFlags {
    return reachabilityFlags([self reachabilityFlags]);
}

#pragma mark - Callback function calls this method

- (void)reachabilityChanged:(SCNetworkReachabilityFlags)flags {
    if ([self isReachableWithFlags:flags]) {
        if (self.reachableBlock) self.reachableBlock(self);
    } else {
        if (self.unreachableBlock) self.unreachableBlock(self);
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [[NSNotificationCenter defaultCenter]
         postNotificationName:agxkReachabilityChangedNotification
         object:self];
    });
}

#pragma mark - Debug Description

- (NSString *)description {
    return [NSString stringWithFormat:@"<%@: %#x (%@)>",
            NSStringFromClass([self class]), (unsigned int)self, [self currentReachabilityFlags]];
}

@end
