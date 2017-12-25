//
//  AGXQRCodeErrorCorrectionLevel.m
//  AGXGcode
//
//  Created by Char Aznable on 2016/8/5.
//  Copyright © 2016年 AI-CUC-EC. All rights reserved.
//

//
//  Modify from:
//  TheLevelUp/ZXingObjC
//

//
//  Copyright 2014 ZXing authors
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//      http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//

#import <AGXCore/AGXCore/AGXArc.h>
#import "AGXQRCodeErrorCorrectionLevel.h"

@implementation AGXQRCodeErrorCorrectionLevel

- (AGX_INSTANCETYPE)initWithOrdinal:(int)ordinal bits:(int)bits name:(NSString *)name {
    if AGX_EXPECT_T(self = [super init]) {
        _ordinal = ordinal;
        _bits = bits;
        _name = [name copy];
    }
    return self;
}

- (void)dealloc {
    AGX_RELEASE(_name);
    AGX_SUPER_DEALLOC;
}

- (NSString *)description {
    return _name;
}

static NSArray *FOR_BITS = nil;

+ (AGX_INSTANCETYPE)forBits:(int)bits {
    if (!FOR_BITS) {
        FOR_BITS = [[NSArray alloc] initWithObjects:
                    [AGXQRCodeErrorCorrectionLevel errorCorrectionLevelM],
                    [AGXQRCodeErrorCorrectionLevel errorCorrectionLevelL],
                    [AGXQRCodeErrorCorrectionLevel errorCorrectionLevelH],
                    [AGXQRCodeErrorCorrectionLevel errorCorrectionLevelQ], nil];
    }

    if AGX_EXPECT_F(bits < 0 || bits >= [FOR_BITS count])
        @throw [NSException exceptionWithName:NSInvalidArgumentException reason:
                @"Invalid bits" userInfo:nil];
    return FOR_BITS[bits];
}

+ (AGX_INSTANCETYPE)errorCorrectionLevelL {
    static AGXQRCodeErrorCorrectionLevel *thisLevel = nil;
    agx_once(thisLevel = [[self alloc] initWithOrdinal:0 bits:0x01 name:@"L"];)
    return thisLevel;
}

+ (AGX_INSTANCETYPE)errorCorrectionLevelM {
    static AGXQRCodeErrorCorrectionLevel *thisLevel = nil;
    agx_once(thisLevel = [[self alloc] initWithOrdinal:1 bits:0x00 name:@"M"];)
    return thisLevel;
}

+ (AGX_INSTANCETYPE)errorCorrectionLevelQ {
    static AGXQRCodeErrorCorrectionLevel *thisLevel = nil;
    agx_once(thisLevel = [[self alloc] initWithOrdinal:2 bits:0x03 name:@"Q"];)
    return thisLevel;
}

+ (AGX_INSTANCETYPE)errorCorrectionLevelH {
    static AGXQRCodeErrorCorrectionLevel *thisLevel = nil;
    agx_once(thisLevel = [[self alloc] initWithOrdinal:3 bits:0x02 name:@"H"];)
    return thisLevel;
}

@end
