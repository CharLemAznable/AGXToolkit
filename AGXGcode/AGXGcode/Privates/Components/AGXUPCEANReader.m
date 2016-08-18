//
//  AGXUPCEANReader.m
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
#import "AGXUPCEANReader.h"
#import "AGXGcodeError.h"
#import "AGXUPCEReader.h"
#import "AGXUPCAReader.h"
#import "AGXEAN13Reader.h"
#import "AGXEAN8Reader.h"

@implementation AGXUPCEANReader {
    NSMutableArray *_readers;
}

- (AGX_INSTANCETYPE)init {
    if (self = [super init]) {
        _readers = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)dealloc {
    AGX_RELEASE(_readers);
    AGX_SUPER_DEALLOC;
}

- (AGXGcodeResult *)decodeRow:(int)rowNumber row:(AGXBitArray *)row startGuardRange:(NSRange)startGuardRange hints:(AGXDecodeHints *)hints error:(NSError **)error {
    [_readers removeAllObjects];
    if (hints != nil) {
        if ([hints containsFormat:kGcodeFormatEan13]) {
            [_readers addObject:AGXEAN13Reader.instance];
        } else if ([hints containsFormat:kGcodeFormatUPCA]) {
            [_readers addObject:AGXUPCAReader.instance];
        }

        if ([hints containsFormat:kGcodeFormatEan8]) {
            [_readers addObject:AGXEAN8Reader.instance];
        }

        if ([hints containsFormat:kGcodeFormatUPCE]) {
            [_readers addObject:AGXUPCEReader.instance];
        }
    }

    if ([_readers count] == 0) {
        [_readers addObject:AGXEAN13Reader.instance];
        [_readers addObject:AGXEAN8Reader.instance];
        [_readers addObject:AGXUPCEReader.instance];
    }

    for (AGXUPCEANAbstractReader *reader in _readers) {
        AGXGcodeResult *result = [reader decodeRow:rowNumber row:row startGuardRange:startGuardRange hints:hints error:error];
        if (!result) continue;

        // Special case: a 12-digit code encoded in UPC-A is identical to a "0"
        // followed by those 12 digits encoded as EAN-13. Each will recognize such a code,
        // UPC-A as a 12-digit string and EAN-13 as a 13-digit string starting with "0".
        // Individually these are correct and their readers will both read such a code
        // and correctly call it EAN-13, or UPC-A, respectively.
        //
        // In this case, if we've been looking for both types, we'd like to call it
        // a UPC-A code. But for efficiency we only run the EAN-13 decoder to also read
        // UPC-A. So we special case it here, and convert an EAN-13 result to a UPC-A
        // result if appropriate.
        //
        // But, don't return UPC-A if UPC-A was not a requested format!
        BOOL ean13MayBeUPCA = kGcodeFormatEan13 == result.format && [result.text characterAtIndex:0] == '0';
        BOOL canReturnUPCA = hints == nil || hints.formats.count == 0 || [hints containsFormat:kGcodeFormatUPCA];
        if (ean13MayBeUPCA && canReturnUPCA) {
            // Transfer the metdata across
            AGXGcodeResult *resultUPCA = [AGXGcodeResult resultWithText:
                                          [result.text substringFromIndex:1] format:kGcodeFormatUPCA];
            return resultUPCA;
        }
        return result;
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
