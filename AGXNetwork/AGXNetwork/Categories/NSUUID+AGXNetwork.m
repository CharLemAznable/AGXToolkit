//
//  NSUUID+AGXNetwork.m
//  AGXNetwork
//
//  Created by Char Aznable on 16/12/9.
//  Copyright © 2016年 AI-CUC-EC. All rights reserved.
//

#import "NSUUID+AGXNetwork.h"
#import <AGXCore/AGXCore/AGXArc.h>

@category_implementation(NSUUID, AGXNetwork)

+ (AGX_INSTANCETYPE)UUIDWithUUIDString:(NSString *)string {
    return AGX_AUTORELEASE([[self alloc] initWithUUIDString:string]);
}

+ (AGX_INSTANCETYPE)UUIDWithUUIDBytes:(const uuid_t)bytes {
    return AGX_AUTORELEASE([[self alloc] initWithUUIDBytes:bytes]);
}

@end
