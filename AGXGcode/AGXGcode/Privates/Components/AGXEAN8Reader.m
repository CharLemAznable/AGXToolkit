//
//  AGXEAN8Reader.m
//  AGXGcode
//
//  Created by Char Aznable on 16/7/26.
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
#import "AGXEAN8Reader.h"

@implementation AGXEAN8Reader {
    AGXIntArray *_decodeMiddleCounters;
}

- (AGX_INSTANCETYPE)init {
    if AGX_EXPECT_T(self = [super init]) {
        _decodeMiddleCounters = [[AGXIntArray alloc] initWithLength:4];
    }
    return self;
}

- (void)dealloc {
    AGX_RELEASE(_decodeMiddleCounters);
    AGX_SUPER_DEALLOC;
}

- (int)decodeMiddle:(AGXBitArray *)row startRange:(NSRange)startRange result:(NSMutableString *)result error:(NSError **)error {
    AGXIntArray *counters = _decodeMiddleCounters;
    [counters clear];
    int end = row.size;
    int rowOffset = (int)NSMaxRange(startRange);

    for (int x = 0; x < 4 && rowOffset < end; x++) {
        int bestMatch = decodeDigit(row, counters, rowOffset, AGX_UPC_EAN_PATTERNS_L_PATTERNS, error);
        if AGX_EXPECT_F(bestMatch == -1) return -1;
        [result appendFormat:@"%C", (unichar)('0' + bestMatch)];
        rowOffset += [counters sum];
    }

    NSRange middleRange = findGuardPattern(row, rowOffset, YES, AGX_UPC_EAN_MIDDLE_PATTERN, AGX_UPC_EAN_MIDDLE_PATTERN_LEN, [AGXIntArray intArrayWithLength:AGX_UPC_EAN_MIDDLE_PATTERN_LEN], error);
    if AGX_EXPECT_F(middleRange.location == NSNotFound) return -1;
    rowOffset = (int)NSMaxRange(middleRange);

    for (int x = 0; x < 4 && rowOffset < end; x++) {
        int bestMatch = decodeDigit(row, counters, rowOffset, AGX_UPC_EAN_PATTERNS_L_PATTERNS, error);
        if AGX_EXPECT_F(bestMatch == -1) return -1;
        [result appendFormat:@"%C", (unichar)('0' + bestMatch)];
        rowOffset += [counters sum];
    }
    
    return rowOffset;
}

- (AGXGcodeFormat)gcodeFormat {
    return kGcodeFormatEan8;
}

@end
