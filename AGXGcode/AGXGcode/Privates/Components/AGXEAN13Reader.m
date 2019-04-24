//
//  AGXEAN13Reader.m
//  AGXGcode
//
//  Created by Char Aznable on 2016/7/26.
//  Copyright © 2016 github.com/CharLemAznable. All rights reserved.
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
#import "AGXEAN13Reader.h"
#import "AGXGcodeError.h"

// For an EAN-13 barcode, the first digit is represented by the parities used
// to encode the next six digits, according to the table below. For example,
// if the barcode is 5 123456 789012 then the value of the first digit is
// signified by using odd for '1', even for '2', even for '3', odd for '4',
// odd for '5', and even for '6'. See http://en.wikipedia.org/wiki/EAN-13
//
//                Parity of next 6 digits
//    Digit   0     1     2     3     4     5
//       0    Odd   Odd   Odd   Odd   Odd   Odd
//       1    Odd   Odd   Even  Odd   Even  Even
//       2    Odd   Odd   Even  Even  Odd   Even
//       3    Odd   Odd   Even  Even  Even  Odd
//       4    Odd   Even  Odd   Odd   Even  Even
//       5    Odd   Even  Even  Odd   Odd   Even
//       6    Odd   Even  Even  Even  Odd   Odd
//       7    Odd   Even  Odd   Even  Odd   Even
//       8    Odd   Even  Odd   Even  Even  Odd
//       9    Odd   Even  Even  Odd   Even  Odd
//
// Note that the encoding for '0' uses the same parity as a UPC barcode. Hence
// a UPC barcode can be converted to an EAN-13 barcode by prepending a 0.
//
// The encoding is represented by the following array, which is a bit pattern
// using Odd = 0 and Even = 1. For example, 5 is represented by:
//
//              Odd Even Even Odd Odd Even
// in binary:
//                0    1    1   0   0    1   == 0x19
//
const int AGX_EAN13_FIRST_DIGIT_ENCODINGS[] = {
    0x00, 0x0B, 0x0D, 0xE, 0x13, 0x19, 0x1C, 0x15, 0x16, 0x1A
};

@implementation AGXEAN13Reader {
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

    int lgPatternFound = 0;

    for (int x = 0; x < 6 && rowOffset < end; x++) {
        int bestMatch = decodeDigit(row, counters, rowOffset, AGX_UPC_EAN_PATTERNS_L_AND_G_PATTERNS, error);
        if AGX_EXPECT_F(bestMatch == -1) return -1;

        [result appendFormat:@"%C", (unichar)('0' + bestMatch % 10)];
        rowOffset += counters.sum;
        if (bestMatch >= 10) {
            lgPatternFound |= 1 << (5 - x);
        }
    }

    if AGX_EXPECT_F(![self determineFirstDigit:result lgPatternFound:lgPatternFound]) {
        if AGX_EXPECT_T(error) *error = AGXNotFoundErrorInstance();
        return -1;
    }

    NSRange middleRange = findGuardPattern(row, rowOffset, YES, AGX_UPC_EAN_MIDDLE_PATTERN, AGX_UPC_EAN_MIDDLE_PATTERN_LEN, [AGXIntArray intArrayWithLength:AGX_UPC_EAN_MIDDLE_PATTERN_LEN], error);
    if AGX_EXPECT_F(middleRange.location == NSNotFound) return -1;

    rowOffset = (int)NSMaxRange(middleRange);
    for (int x = 0; x < 6 && rowOffset < end; x++) {
        int bestMatch = decodeDigit(row, counters, rowOffset, AGX_UPC_EAN_PATTERNS_L_PATTERNS, error);
        if AGX_EXPECT_F(bestMatch == -1) return -1;
        [result appendFormat:@"%C", (unichar)('0' + bestMatch)];
        rowOffset += counters.sum;
    }

    return rowOffset;
}

- (AGXGcodeFormat)gcodeFormat {
    return kGcodeFormatEan13;
}

/**
 * Based on pattern of odd-even ('L' and 'G') patterns used to encoded the explicitly-encoded
 * digits in a barcode, determines the implicitly encoded first digit and adds it to the
 * result string.
 *
 * @param resultString string to insert decoded first digit into
 * @param lgPatternFound int whose bits indicates the pattern of odd/even L/G patterns used to
 *  encode digits
 * @return NO if first digit cannot be determined
 */
- (BOOL)determineFirstDigit:(NSMutableString *)resultString lgPatternFound:(int)lgPatternFound {
    for (int d = 0; d < 10; d++) {
        if (lgPatternFound == AGX_EAN13_FIRST_DIGIT_ENCODINGS[d]) {
            [resultString insertString:[NSString stringWithFormat:@"%C", (unichar)('0' + d)] atIndex:0];
            return YES;
        }
    }
    return NO;
}

@end
