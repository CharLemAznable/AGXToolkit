//
//  AGXRequest+Private.m
//  AGXNetwork
//
//  Created by Char Aznable on 16/4/26.
//  Copyright © 2016年 AI-CUC-EC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AGXCore/AGXCore/NSObject+AGXCore.h>
#import "AGXRequest+Private.h"

static NSInteger numberOfRunningOperations;

@category_implementation(AGXRequest, Private)

- (void)increaseRunningOperations {
    agx_async_main
    (numberOfRunningOperations++;
     [UIApplication sharedApplication].networkActivityIndicatorVisible = numberOfRunningOperations > 0;)
}

- (void)decreaseRunningOperations {
    agx_async_main
    (numberOfRunningOperations--;
     [UIApplication sharedApplication].networkActivityIndicatorVisible = numberOfRunningOperations > 0;
     if (numberOfRunningOperations < 0) AGXLog(@"operation's count below zero. State Changes [%@]", _stateHistory);)
}

@end
