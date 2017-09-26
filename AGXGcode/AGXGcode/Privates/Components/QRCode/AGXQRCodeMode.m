//
//  AGXQRCodeMode.m
//  AGXGcode
//
//  Created by Char Aznable on 16/8/8.
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
#import "AGXQRCodeMode.h"

@implementation AGXQRCodeMode {
    NSArray *_characterCountBitsForVersions;
}

+ (AGX_INSTANCETYPE)forBits:(int)bits {
    switch (bits) {
        case 0x0: return [self terminatorMode];
        case 0x1: return [self numericMode];
        case 0x2: return [self alphanumericMode];
        case 0x3: return [self structuredAppendMode];
        case 0x4: return [self byteMode];
        case 0x5: return [self fnc1FirstPositionMode];
        case 0x7: return [self eciMode];
        case 0x8: return [self kanjiMode];
        case 0x9: return [self fnc1SecondPositionMode];
        case 0xD: return [self hanziMode];
        default : return nil;
    }
}

- (AGX_INSTANCETYPE)initWithCharacterCountBitsForVersions:(NSArray *)characterCountBitsForVersions bits:(int)bits name:(NSString *)name {
    if AGX_EXPECT_T(self = [super init]) {
        _characterCountBitsForVersions = AGX_RETAIN(characterCountBitsForVersions);
        _bits = bits;
        _name = [name copy];
    }
    return self;
}

- (void)dealloc {
    AGX_RELEASE(_characterCountBitsForVersions);
    AGX_RELEASE(_name);
    AGX_SUPER_DEALLOC;
}

- (int)characterCountBits:(AGXQRCodeVersion *)version {
    int number = version.versionNumber;
    int offset;
    if (number <= 9) {
        offset = 0;
    } else if (number <= 26) {
        offset = 1;
    } else {
        offset = 2;
    }
    return [_characterCountBitsForVersions[offset] intValue];
}

- (NSString *)description {
    return _name;
}

+ (AGX_INSTANCETYPE)terminatorMode {
    static AGXQRCodeMode *thisMode = nil;
    static dispatch_once_t once_t;
    dispatch_once(&once_t, ^{
        thisMode = [[AGXQRCodeMode alloc] initWithCharacterCountBitsForVersions:@[@0, @0, @0] bits:0x00 name:@"TERMINATOR"];
    });
    return thisMode;
}

+ (AGX_INSTANCETYPE)numericMode {
    static AGXQRCodeMode *thisMode = nil;
    static dispatch_once_t once_t;
    dispatch_once(&once_t, ^{
        thisMode = [[AGXQRCodeMode alloc] initWithCharacterCountBitsForVersions:@[@10, @12, @14] bits:0x01 name:@"NUMERIC"];
    });
    return thisMode;
}

+ (AGX_INSTANCETYPE)alphanumericMode {
    static AGXQRCodeMode *thisMode = nil;
    static dispatch_once_t once_t;
    dispatch_once(&once_t, ^{
        thisMode = [[AGXQRCodeMode alloc] initWithCharacterCountBitsForVersions:@[@9, @11, @13] bits:0x02 name:@"ALPHANUMERIC"];
    });
    return thisMode;
}

+ (AGX_INSTANCETYPE)structuredAppendMode {
    static AGXQRCodeMode *thisMode = nil;
    static dispatch_once_t once_t;
    dispatch_once(&once_t, ^{
        thisMode = [[AGXQRCodeMode alloc] initWithCharacterCountBitsForVersions:@[@0, @0, @0] bits:0x03 name:@"STRUCTURED_APPEND"];
    });
    return thisMode;
}

+ (AGX_INSTANCETYPE)byteMode {
    static AGXQRCodeMode *thisMode = nil;
    static dispatch_once_t once_t;
    dispatch_once(&once_t, ^{
        thisMode = [[AGXQRCodeMode alloc] initWithCharacterCountBitsForVersions:@[@8, @16, @16] bits:0x04 name:@"BYTE"];
    });
    return thisMode;
}

+ (AGX_INSTANCETYPE)eciMode {
    static AGXQRCodeMode *thisMode = nil;
    static dispatch_once_t once_t;
    dispatch_once(&once_t, ^{
        thisMode = [[AGXQRCodeMode alloc] initWithCharacterCountBitsForVersions:@[@0, @0, @0] bits:0x07 name:@"ECI"];
    });
    return thisMode;
}

+ (AGX_INSTANCETYPE)kanjiMode {
    static AGXQRCodeMode *thisMode = nil;
    static dispatch_once_t once_t;
    dispatch_once(&once_t, ^{
        thisMode = [[AGXQRCodeMode alloc] initWithCharacterCountBitsForVersions:@[@8, @10, @12] bits:0x08 name:@"KANJI"];
    });
    return thisMode;
}

+ (AGX_INSTANCETYPE)fnc1FirstPositionMode {
    static AGXQRCodeMode *thisMode = nil;
    static dispatch_once_t once_t;
    dispatch_once(&once_t, ^{
        thisMode = [[AGXQRCodeMode alloc] initWithCharacterCountBitsForVersions:@[@0, @0, @0] bits:0x05 name:@"FNC1_FIRST_POSITION"];
    });
    return thisMode;
}

+ (AGX_INSTANCETYPE)fnc1SecondPositionMode {
    static AGXQRCodeMode *thisMode = nil;
    static dispatch_once_t once_t;
    dispatch_once(&once_t, ^{
        thisMode = [[AGXQRCodeMode alloc] initWithCharacterCountBitsForVersions:@[@0, @0, @0] bits:0x09 name:@"FNC1_SECOND_POSITION"];
    });
    return thisMode;
}

+ (AGX_INSTANCETYPE)hanziMode {
    static AGXQRCodeMode *thisMode = nil;
    static dispatch_once_t once_t;
    dispatch_once(&once_t, ^{
        thisMode = [[AGXQRCodeMode alloc] initWithCharacterCountBitsForVersions:@[@8, @10, @12] bits:0x0D name:@"HANZI"];
    });
    return thisMode;
}

@end
