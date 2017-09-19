//
//  AGXCharacterSetECI.m
//  AGXGcode
//
//  Created by Char Aznable on 16/8/3.
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
#import "AGXCharacterSetECI.h"

static NSMutableDictionary *VALUE_TO_ECI = nil;
static NSMutableDictionary *ENCODING_TO_ECI = nil;

@implementation AGXCharacterSetECI

+ (void)load {
    static dispatch_once_t once_t;
    dispatch_once(&once_t, ^{
        VALUE_TO_ECI = [[NSMutableDictionary alloc] initWithCapacity:29];
        ENCODING_TO_ECI = [[NSMutableDictionary alloc] initWithCapacity:29];
        [AGXCharacterSetECI addCharacterSet:0 encoding:(NSStringEncoding) 0x80000400];
        [AGXCharacterSetECI addCharacterSet:1 encoding:NSISOLatin1StringEncoding];
        [AGXCharacterSetECI addCharacterSet:2 encoding:(NSStringEncoding) 0x80000400];
        [AGXCharacterSetECI addCharacterSet:3 encoding:NSISOLatin1StringEncoding];
        [AGXCharacterSetECI addCharacterSet:4 encoding:NSISOLatin2StringEncoding];
        [AGXCharacterSetECI addCharacterSet:5 encoding:(NSStringEncoding) 0x80000203];
        [AGXCharacterSetECI addCharacterSet:6 encoding:(NSStringEncoding) 0x80000204];
        [AGXCharacterSetECI addCharacterSet:7 encoding:(NSStringEncoding) 0x80000205];
        [AGXCharacterSetECI addCharacterSet:8 encoding:(NSStringEncoding) 0x80000206];
        [AGXCharacterSetECI addCharacterSet:9 encoding:(NSStringEncoding) 0x80000207];
        [AGXCharacterSetECI addCharacterSet:10 encoding:(NSStringEncoding) 0x80000208];
        [AGXCharacterSetECI addCharacterSet:11 encoding:(NSStringEncoding) 0x80000209];
        [AGXCharacterSetECI addCharacterSet:12 encoding:(NSStringEncoding) 0x8000020A];
        [AGXCharacterSetECI addCharacterSet:13 encoding:(NSStringEncoding) 0x8000020B];
        [AGXCharacterSetECI addCharacterSet:15 encoding:(NSStringEncoding) 0x8000020D];
        [AGXCharacterSetECI addCharacterSet:16 encoding:(NSStringEncoding) 0x8000020E];
        [AGXCharacterSetECI addCharacterSet:17 encoding:(NSStringEncoding) 0x8000020F];
        [AGXCharacterSetECI addCharacterSet:18 encoding:(NSStringEncoding) 0x80000210];
        [AGXCharacterSetECI addCharacterSet:20 encoding:NSShiftJISStringEncoding];
        [AGXCharacterSetECI addCharacterSet:21 encoding:NSWindowsCP1250StringEncoding];
        [AGXCharacterSetECI addCharacterSet:22 encoding:NSWindowsCP1251StringEncoding];
        [AGXCharacterSetECI addCharacterSet:23 encoding:NSWindowsCP1252StringEncoding];
        [AGXCharacterSetECI addCharacterSet:24 encoding:(NSStringEncoding) 0x80000505];
        [AGXCharacterSetECI addCharacterSet:25 encoding:NSUTF16BigEndianStringEncoding];
        [AGXCharacterSetECI addCharacterSet:26 encoding:NSUTF8StringEncoding];
        [AGXCharacterSetECI addCharacterSet:27 encoding:NSASCIIStringEncoding];
        [AGXCharacterSetECI addCharacterSet:28 encoding:(NSStringEncoding) 0x80000A03];
        [AGXCharacterSetECI addCharacterSet:29 encoding:(NSStringEncoding) 0x80000632];
        [AGXCharacterSetECI addCharacterSet:30 encoding:(NSStringEncoding) 0x80000940];
        [AGXCharacterSetECI addCharacterSet:170 encoding:NSASCIIStringEncoding];
    });
}

- (AGX_INSTANCETYPE)initWithValue:(int)value encoding:(NSStringEncoding)encoding {
    if (AGX_EXPECT_T(self = [super init])) {
        _value = value;
        _encoding = encoding;
    }
    return self;
}

+ (void)addCharacterSet:(int)value encoding:(NSStringEncoding)encoding {
    AGXCharacterSetECI *eci = AGX_AUTORELEASE([[AGXCharacterSetECI alloc] initWithValue:value encoding:encoding]);
    VALUE_TO_ECI[@(value)] = eci;
    ENCODING_TO_ECI[@(encoding)] = eci;
}

+ (AGXCharacterSetECI *)characterSetECIByValue:(int)value {
    return VALUE_TO_ECI[@(value)];
}

+ (AGXCharacterSetECI *)characterSetECIByEncoding:(NSStringEncoding)encoding {
    return ENCODING_TO_ECI[@(encoding)];
}

@end
