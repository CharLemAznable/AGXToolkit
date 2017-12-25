//
//  AGXUPCEReader.m
//  AGXGcode
//
//  Created by Char Aznable on 2016/7/26.
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
#import "AGXUPCEReader.h"
#import "AGXGcodeError.h"

/**
 * The pattern that marks the middle, and end, of a UPC-E pattern.
 * There is no "second half" to a UPC-E barcode.
 */
const int AGX_UCPE_MIDDLE_END_PATTERN[] = {1, 1, 1, 1, 1, 1};

/**
 * See AGX_UCPE_L_AND_G_PATTERNS; these values similarly represent patterns of
 * even-odd parity encodings of digits that imply both the number system (0 or 1)
 * used, and the check digit.
 */
const int AGX_UCPE_NUMSYS_AND_CHECK_DIGIT_PATTERNS[][10] = {
    {0x38, 0x34, 0x32, 0x31, 0x2C, 0x26, 0x23, 0x2A, 0x29, 0x25},
    {0x07, 0x0B, 0x0D, 0x0E, 0x13, 0x19, 0x1C, 0x15, 0x16, 0x1A}
};

@implementation AGXUPCEReader {
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

- (AGXGcodeResult *)decodeRow:(int)rowNumber row:(AGXBitArray *)row startGuardRange:(NSRange)startGuardRange hints:(AGXDecodeHints *)hints error:(NSError **)error {
    AGXGcodeResult *result = [super decodeRow:rowNumber row:row startGuardRange:startGuardRange hints:hints error:error];
    if AGX_EXPECT_F([result.text characterAtIndex:0] != '0') return nil;
    return result;
}

- (int)decodeMiddle:(AGXBitArray *)row startRange:(NSRange)startRange result:(NSMutableString *)result error:(NSError **)error {
    AGXIntArray *counters = _decodeMiddleCounters;
    [counters clear];

    int end = [row size];
    int rowOffset = (int)NSMaxRange(startRange);
    int lgPatternFound = 0;

    for (int x = 0; x < 6 && rowOffset < end; x++) {
        int bestMatch = decodeDigit(row, counters, rowOffset, AGX_UPC_EAN_PATTERNS_L_AND_G_PATTERNS, error);
        if AGX_EXPECT_F(bestMatch == -1) return -1;

        [result appendFormat:@"%C", (unichar)('0' + bestMatch % 10)];
        rowOffset += [counters sum];

        if (bestMatch >= 10) {
            lgPatternFound |= 1 << (5 - x);
        }
    }

    if AGX_EXPECT_F(![self determineNumSysAndCheckDigit:result lgPatternFound:lgPatternFound]) {
        if AGX_EXPECT_T(error) *error = AGXNotFoundErrorInstance();
        return -1;
    }
    return rowOffset;
}

- (NSRange)decodeEnd:(AGXBitArray *)row endStart:(int)endStart error:(NSError **)error {
    int patternLen = sizeof(AGX_UCPE_MIDDLE_END_PATTERN) / sizeof(int);
    return findGuardPattern(row, endStart, YES, AGX_UCPE_MIDDLE_END_PATTERN, patternLen,
                            [AGXIntArray intArrayWithLength:patternLen], error);
}

- (BOOL)checkChecksum:(NSString *)s error:(NSError **)error {
    return [super checkChecksum:[AGXUPCEReader convertUPCEtoUPCA:s] error:error];
}

- (BOOL)determineNumSysAndCheckDigit:(NSMutableString *)resultString lgPatternFound:(int)lgPatternFound {
    for (int numSys = 0; numSys <= 1; numSys++) {
        for (int d = 0; d < 10; d++) {
            if (lgPatternFound == AGX_UCPE_NUMSYS_AND_CHECK_DIGIT_PATTERNS[numSys][d]) {
                [resultString insertString:[NSString stringWithFormat:@"%C", (unichar)('0' + numSys)] atIndex:0];
                [resultString appendFormat:@"%C", (unichar)('0' + d)];
                return YES;
            }
        }
    }
    return NO;
}

- (AGXGcodeFormat)gcodeFormat {
    return kGcodeFormatUPCE;
}

/**
 * Expands a UPC-E value back into its full, equivalent UPC-A code value.
 *
 * @param upce UPC-E code as string of digits
 * @return equivalent UPC-A code as string of digits
 */
+ (NSString *)convertUPCEtoUPCA:(NSString *)upce {
    NSString *upceChars = [upce substringWithRange:NSMakeRange(1, 6)];
    NSMutableString *result = [NSMutableString stringWithCapacity:12];
    [result appendFormat:@"%C", [upce characterAtIndex:0]];
    unichar lastChar = [upceChars characterAtIndex:5];
    switch (lastChar) {
        case '0':
        case '1':
        case '2':
            [result appendString:[upceChars substringToIndex:2]];
            [result appendFormat:@"%C", lastChar];
            [result appendString:@"0000"];
            [result appendString:[upceChars substringWithRange:NSMakeRange(2, 3)]];
            break;
        case '3':
            [result appendString:[upceChars substringToIndex:3]];
            [result appendString:@"00000"];
            [result appendString:[upceChars substringWithRange:NSMakeRange(3, 2)]];
            break;
        case '4':
            [result appendString:[upceChars substringToIndex:4]];
            [result appendString:@"00000"];
            [result appendString:[upceChars substringWithRange:NSMakeRange(4, 1)]];
            break;
        default:
            [result appendString:[upceChars substringToIndex:5]];
            [result appendString:@"0000"];
            [result appendFormat:@"%C", lastChar];
            break;
    }
    [result appendFormat:@"%C", [upce characterAtIndex:7]];
    return result;
}

@end
