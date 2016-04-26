//
//  AGXRequest+Private.h
//  AGXNetwork
//
//  Created by Char Aznable on 16/4/26.
//  Copyright © 2016年 AI-CUC-EC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AGXCore/AGXCore/AGXCategory.h>
#import "AGXNetworkTypes.h"
#import "AGXRequest.h"

@interface AGXRequest ()
@property (nonatomic, readwrite) AGXRequestState state;
@end

@category_interface(AGXRequest, Private)
- (void)increaseRunningOperations;
- (void)decreaseRunningOperations;
@end
