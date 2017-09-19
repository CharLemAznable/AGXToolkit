//
//  AGXGcodeReader.m
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
#import "AGXGcodeReader.h"
#import "AGXGcodeError.h"
#import "AGXOneDReader.h"
#import "AGXPDF417Reader.h"
#import "AGXQRCodeReader.h"
#import "AGXAztecReader.h"
#import "AGXDataMatrixReader.h"

@implementation AGXGcodeReader {
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

- (AGXGcodeResult *)decode:(UIImage *)image hints:(AGXDecodeHints *)hints error:(NSError **)error {
    [_readers removeAllObjects];
    if (hints != nil) {
        if ([hints containsFormat:kGcodeFormatUPCE] ||
            [hints containsFormat:kGcodeFormatUPCA] ||
            [hints containsFormat:kGcodeFormatEan13] ||
            [hints containsFormat:kGcodeFormatEan8] ||
            [hints containsFormat:kGcodeFormatCode39] ||
            [hints containsFormat:kGcodeFormatCode93] ||
            [hints containsFormat:kGcodeFormatCode128] ||
            [hints containsFormat:kGcodeFormatITF]) {
            [_readers addObject:AGXOneDReader.instance];
        }

        if ([hints containsFormat:kGcodeFormatPDF417]) {
            [_readers addObject:AGXPDF417Reader.instance];
        }

        if ([hints containsFormat:kGcodeFormatQRCode]) {
            [_readers addObject:AGXQRCodeReader.instance];
        }

        if ([hints containsFormat:kGcodeFormatAztec]) {
            [_readers addObject:AGXAztecReader.instance];
        }

        if ([hints containsFormat:kGcodeFormatDataMatrix]) {
            [_readers addObject:AGXDataMatrixReader.instance];
        }
    }
    if ([_readers count] == 0) {
        [_readers addObject:AGXOneDReader.instance];
        [_readers addObject:AGXPDF417Reader.instance];
        [_readers addObject:AGXQRCodeReader.instance];
        [_readers addObject:AGXAztecReader.instance];
        [_readers addObject:AGXDataMatrixReader.instance];
    }

    for (id<AGXGcodeReader> reader in _readers) {
        AGXGcodeResult *result = [reader decode:image hints:hints error:nil];
        if (result) return result;
    }

    if (error) *error = AGXNotFoundErrorInstance();
    return nil;
}

- (void)reset {
    for (id<AGXGcodeReader> reader in _readers) {
        [reader reset];
    }
}

@end
