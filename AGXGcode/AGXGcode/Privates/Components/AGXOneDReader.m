//
//  AGXOneDReader.m
//  AGXGcode
//
//  Created by Char Aznable on 16/7/28.
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
#import <AGXCore/AGXCore/NSObject+AGXCore.h>
#import "AGXOneDReader.h"
#import "AGXGcodeError.h"
#import "AGXUPCEANReader.h"
#import "AGXCode39Reader.h"
#import "AGXCode93Reader.h"
#import "AGXCode128Reader.h"
#import "AGXITFReader.h"

@implementation AGXOneDReader {
    NSMutableArray *_readers;
}

- (AGX_INSTANCETYPE)init {
    if (AGX_EXPECT_T(self = [super init])) {
        _readers = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)dealloc {
    AGX_RELEASE(_readers);
    AGX_SUPER_DEALLOC;
}

- (AGXGcodeResult *)decodeRow:(int)rowNumber row:(AGXBitArray *)row hints:(AGXDecodeHints *)hints error:(NSError **)error {
    [_readers removeAllObjects];
    if (AGX_EXPECT_T(hints != nil)) {
        if ([hints containsFormat:kGcodeFormatUPCE] ||
            [hints containsFormat:kGcodeFormatUPCA] ||
            [hints containsFormat:kGcodeFormatEan13] ||
            [hints containsFormat:kGcodeFormatEan8]) {
            [_readers addObject:AGXUPCEANReader.instance];
        }

        if ([hints containsFormat:kGcodeFormatCode39]) {
            [_readers addObject:AGXCode39Reader.instance];
        }

        if ([hints containsFormat:kGcodeFormatCode93]) {
            [_readers addObject:AGXCode93Reader.instance];
        }

        if ([hints containsFormat:kGcodeFormatCode128]) {
            [_readers addObject:AGXCode128Reader.instance];
        }

        if ([hints containsFormat:kGcodeFormatITF]) {
            [_readers addObject:AGXITFReader.instance];
        }
    }

    if ([_readers count] == 0) {
        [_readers addObject:AGXUPCEANReader.instance];
        [_readers addObject:AGXCode39Reader.instance];
        [_readers addObject:AGXCode93Reader.instance];
        [_readers addObject:AGXCode128Reader.instance];
        [_readers addObject:AGXITFReader.instance];
    }

    for (AGXOneDAbstractReader *reader in _readers) {
        AGXGcodeResult *result = [reader decodeRow:rowNumber row:row hints:hints error:error];
        if (result) return result;
    }
    if (AGX_EXPECT_T(error)) *error = AGXNotFoundErrorInstance();
    return nil;
}

- (void)reset {
    for (id<AGXGcodeReader> reader in _readers) {
        [reader reset];
    }
}

@end
