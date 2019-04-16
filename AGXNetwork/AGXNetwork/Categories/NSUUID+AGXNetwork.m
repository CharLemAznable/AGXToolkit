//
//  NSUUID+AGXNetwork.m
//  AGXNetwork
//
//  Created by Char Aznable on 2016/12/9.
//  Copyright © 2016 github.com/CharLemAznable. All rights reserved.
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
