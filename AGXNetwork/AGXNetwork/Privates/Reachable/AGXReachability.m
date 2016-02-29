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
@property (nonatomic, assign)       dispatch_queue_t            reachabilitySerialQueue;
@property (nonatomic, AGX_STRONG)   id                          reachabilityObject;

- (void)reachabilityChanged:(SCNetworkReachabilityFlags)flags;
- (BOOL)isReachableWithFlags:(SCNetworkReachabilityFlags)flags;
@end

static NSString *reachabilityFlags(SCNetworkReachabilityFlags flags) {
    return [NSString stringWithFormat:@"%c%c %c%c%c%c%c%c%c",
            (flags & kSCNetworkReachabilityFlagsIsWWAN)               ? 'W' : '-',
            (flags & kSCNetworkReachabilityFlagsReachable)            ? 'R' : '-',
            (flags & kSCNetworkReachabilityFlagsConnectionRequired)   ? 'c' : '-',
            (flags & kSCNetworkReachabilityFlagsTransientConnection)  ? 't' : '-',
            (flags & kSCNetworkReachabilityFlagsInterventionRequired) ? 'i' : '-',
            (flags & kSCNetworkReachabilityFlagsConnectionOnTraffic)  ? 'C' : '-',
            (flags & kSCNetworkReachabilityFlagsConnectionOnDemand)   ? 'D' : '-',
            (flags & kSCNetworkReachabilityFlagsIsLocalAddress)       ? 'l' : '-',
            (flags & kSCNetworkReachabilityFlagsIsDirect)             ? 'd' : '-'];
}

// Start listening for reachability notifications on the current run loop
static void TMReachabilityCallback(SCNetworkReachabilityRef target, SCNetworkReachabilityFlags flags, void *info) {
#pragma unused (target)
    AGXReachability *reachability = (AGX_BRIDGE AGXReachability*)info;
    
    // We probably don't need an autoreleasepool here, as GCD docs state each queue has its own autorelease pool,
    // but what the heck eh?
    @autoreleasepool { [reachability reachabilityChanged:flags]; }
}

@implementation AGXReachability

#pragma mark - Class Constructor Methods

+ (AGXReachability *)reachabilityWithHostName:(NSString *)hostname {
    return [AGXReachability reachabilityWithHostname:hostname];
}

+ (AGXReachability *)reachabilityWithHostname:(NSString *)hostname {
    SCNetworkReachabilityRef ref = SCNetworkReachabilityCreateWithName(NULL, [hostname UTF8String]);
    return ref ? [[self alloc] initWithReachabilityRef:ref] : nil;
}

+ (AGXReachability *)reachabilityWithAddress:(void *)hostAddress {
    SCNetworkReachabilityRef ref = SCNetworkReachabilityCreateWithAddress(kCFAllocatorDefault, (const struct sockaddr *)hostAddress);
    return ref ? [[self alloc] initWithReachabilityRef:ref] : nil;
}

+ (AGXReachability *)reachabilityForInternetConnection {
    struct sockaddr_in zeroAddress;
    bzero(&zeroAddress, sizeof(zeroAddress));
    zeroAddress.sin_len = sizeof(zeroAddress);
    zeroAddress.sin_family = AF_INET;
    
    return [self reachabilityWithAddress:&zeroAddress];
}

+ (AGXReachability *)reachabilityForLocalWiFi {
    struct sockaddr_in localWifiAddress;
    bzero(&localWifiAddress, sizeof(localWifiAddress));
    localWifiAddress.sin_len            = sizeof(localWifiAddress);
    localWifiAddress.sin_family         = AF_INET;
    // IN_LINKLOCALNETNUM is defined in <netinet/in.h> as 169.254.0.0
    localWifiAddress.sin_addr.s_addr    = htonl(IN_LINKLOCALNETNUM);
    
    return [self reachabilityWithAddress:&localWifiAddress];
}

// Initialization methods
- (AGX_INSTANCETYPE)initWithReachabilityRef:(SCNetworkReachabilityRef)ref {
    if (self = [super init]) {
        self.reachableOnWWAN = YES;
        self.reachabilityRef = ref;
        
        // We need to create a serial queue.
        // We allocate this once for the lifetime of the notifier.
        self.reachabilitySerialQueue = dispatch_queue_create("com.tonymillion.reachability", NULL);
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
    self.reachabilityBlock       = nil;
    self.reachabilitySerialQueue = nil;
    AGX_SUPER_DEALLOC;
}

#pragma mark - Notifier Methods

// Notifier
// NOTE: This uses GCD to trigger the blocks - they *WILL NOT* be called on THE MAIN THREAD
// - In other words DO NOT DO ANY UI UPDATES IN THE BLOCKS.
//   INSTEAD USE dispatch_async(dispatch_get_main_queue(), ^{UISTUFF}) (or dispatch_sync if you want)

- (BOOL)startNotifier {
    // allow start notifier to be called multiple times
    if (self.reachabilityObject && self.reachabilityObject == self) return YES;
    
    SCNetworkReachabilityContext context = { 0, NULL, NULL, NULL, NULL };
    context.info = (AGX_BRIDGE void *)self;
    
    if (SCNetworkReachabilitySetCallback(self.reachabilityRef, TMReachabilityCallback, &context)) {
        // Set it as our reachability queue, which will retain the queue
        if (SCNetworkReachabilitySetDispatchQueue(self.reachabilityRef, self.reachabilitySerialQueue)) {
            // this should do a retain on ourself, so as long as we're in notifier mode we shouldn't disappear out from under ourselves
            // woah
            self.reachabilityObject = self;
            return YES;
        } else {
            AGXLog(@"SCNetworkReachabilitySetDispatchQueue() failed: %s", SCErrorString(SCError()));
            
            // UH OH - FAILURE - stop any callbacks!
            SCNetworkReachabilitySetCallback(self.reachabilityRef, NULL, NULL);
        }
    } else AGXLog(@"SCNetworkReachabilitySetCallback() failed: %s", SCErrorString(SCError()));
    
    // if we get here we fail at the internet
    self.reachabilityObject = nil;
    return NO;
}

- (void)stopNotifier {
    // First stop, any callbacks!
    SCNetworkReachabilitySetCallback(self.reachabilityRef, NULL, NULL);
    
    // Unregister target from the GCD serial dispatch queue.
    SCNetworkReachabilitySetDispatchQueue(self.reachabilityRef, NULL);
    
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
    
    if (flags & kSCNetworkReachabilityFlagsIsWWAN) {
        // We're on 3G.
        if (!self.reachableOnWWAN) {
            // We don't want to connect when on 3G.
            connectionUP = NO;
        }
    }
    
    return connectionUP;
}

- (BOOL)isReachable {
    SCNetworkReachabilityFlags flags;
    
    if (!SCNetworkReachabilityGetFlags(self.reachabilityRef, &flags)) return NO;
    return [self isReachableWithFlags:flags];
}

- (BOOL)isReachableViaWWAN {
    SCNetworkReachabilityFlags flags = 0;
    
    if (SCNetworkReachabilityGetFlags(self.reachabilityRef, &flags)) {
        // Check we're REACHABLE
        if (flags & kSCNetworkReachabilityFlagsReachable) {
            // Now, check we're on WWAN
            if (flags & kSCNetworkReachabilityFlagsIsWWAN) return YES;
        }
    }
    
    return NO;
}

- (BOOL)isReachableViaWiFi {
    SCNetworkReachabilityFlags flags = 0;
    
    if (SCNetworkReachabilityGetFlags(self.reachabilityRef, &flags)) {
        // Check we're reachable
        if ((flags & kSCNetworkReachabilityFlagsReachable)) {
            // Check we're NOT on WWAN
            return (flags & kSCNetworkReachabilityFlagsIsWWAN);
        }
    }
    
    return NO;
}


// WWAN may be available, but not active until a connection has been established.
// WiFi may require a connection for VPN on Demand.
- (BOOL)isConnectionRequired {
    return [self connectionRequired];
}

- (BOOL)connectionRequired {
    SCNetworkReachabilityFlags flags;
    
    if (SCNetworkReachabilityGetFlags(self.reachabilityRef, &flags)) {
        return (flags & kSCNetworkReachabilityFlagsConnectionRequired);
    }
    
    return NO;
}

// Dynamic, on demand connection?
- (BOOL)isConnectionOnDemand {
    SCNetworkReachabilityFlags flags;
    
    if (SCNetworkReachabilityGetFlags(self.reachabilityRef, &flags)) {
        return ((flags & kSCNetworkReachabilityFlagsConnectionRequired) &&
                (flags & (kSCNetworkReachabilityFlagsConnectionOnTraffic | kSCNetworkReachabilityFlagsConnectionOnDemand)));
    }
    
    return NO;
}

// Is user intervention required?
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
    if (![self isReachable]) return AGXNotReachable;
    return [self isReachableViaWiFi] ? AGXReachableViaWiFi : AGXReachableViaWWAN;
}

- (SCNetworkReachabilityFlags)reachabilityFlags {
    SCNetworkReachabilityFlags flags = 0;
    
    if (SCNetworkReachabilityGetFlags(self.reachabilityRef, &flags)) {
        return flags;
    }
    
    return 0;
}

- (NSString*)currentReachabilityString {
    AGXNetworkStatus temp = [self currentReachabilityStatus];
    
    // Updated for the fact that we have CDMA phones now!
    if (temp == AGXReachableViaWWAN) return NSLocalizedString(@"Cellular", @"");
    if (temp == AGXReachableViaWiFi) return NSLocalizedString(@"WiFi", @"");
    return NSLocalizedString(@"No Connection", @"");
}

- (NSString*)currentReachabilityFlags {
    return reachabilityFlags([self reachabilityFlags]);
}

#pragma mark - Callback function calls this method

- (void)reachabilityChanged:(SCNetworkReachabilityFlags)flags {
    if ([self isReachableWithFlags:flags]) {
        if (self.reachableBlock) self.reachableBlock(self);
    } else {
        if(self.unreachableBlock) self.unreachableBlock(self);
    }
    
    if(self.reachabilityBlock) self.reachabilityBlock(self, flags);
    
    // this makes sure the change notification happens on the MAIN THREAD
    dispatch_async(dispatch_get_main_queue(), ^{
        [[NSNotificationCenter defaultCenter] postNotificationName:agxkReachabilityChangedNotification
                                                            object:self];
    });
}

#pragma mark - Debug Description

- (NSString *)description {
    NSString *description = [NSString stringWithFormat:@"<%@: %#x (%@)>",
                             NSStringFromClass([self class]), (unsigned int) self, [self currentReachabilityFlags]];
    return description;
}

@end
