//
//  AGXReachabilityTest.m
//  AGXNetwork
//
//  Created by Char Aznable on 16/2/29.
//  Copyright © 2016年 AI-CUC-EC. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "AGXReachability.h"

@interface AGXReachabilityTest : XCTestCase {
    AGXReachability *reachability;
    BOOL reachabilityChanged;
}
@end

@implementation AGXReachabilityTest

- (void)testAGXReachability {
    AGXAddNotification(reachabilityChanged:, agxkReachabilityChangedNotification);
    reachability = [AGXReachability reachabilityWithHostname:@"https://github.com/"];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [reachability startNotifier];
    });
    while (!reachabilityChanged) {
        CFRunLoopRunInMode(kCFRunLoopDefaultMode, 1, YES);
    }
}

- (void)reachabilityChanged:(NSNotification*)notification {
    if ([reachability currentReachabilityStatus] == AGXReachableViaWiFi) {
        XCTAssertTrue(YES, @"Internet Connection is reachable via Wifi");
    } else if ([reachability currentReachabilityStatus] == AGXReachableViaWWAN) {
        XCTAssertTrue(YES, @"Internet Connection is reachable only via cellular data");
    } else if([reachability currentReachabilityStatus] == AGXNotReachable) {
        XCTFail(@"Internet Connection is not reachable");
    } else XCTFail(@"Internet Connection Reachability Failed");
    reachabilityChanged = YES;
}

@end
