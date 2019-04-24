//
//  AGXUPCEANReader.m
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
#import "AGXUPCEANAbstractReader.h"
#import "AGXGcodeError.h"

AGX_STATIC float AGX_UPC_EAN_MAX_AVG_VARIANCE = 0.48f;
AGX_STATIC float AGX_UPC_EAN_MAX_INDIVIDUAL_VARIANCE = 0.7f;

/**
 * Start/end guard pattern.
 */
const int AGX_UPC_EAN_START_END_PATTERN_LEN = 3;
const int AGX_UPC_EAN_START_END_PATTERN[AGX_UPC_EAN_START_END_PATTERN_LEN] = {1, 1, 1};

/**
 * Pattern marking the middle of a UPC/EAN pattern, separating the two halves.
 */
const int AGX_UPC_EAN_MIDDLE_PATTERN_LEN = 5;
const int AGX_UPC_EAN_MIDDLE_PATTERN[AGX_UPC_EAN_MIDDLE_PATTERN_LEN] = {1, 1, 1, 1, 1};

/**
 * "Odd", or "L" patterns used to encode UPC/EAN digits.
 */
const int AGX_UPC_EAN_L_PATTERNS_LEN = 10;
const int AGX_UPC_EAN_L_PATTERNS_SUB_LEN = 4;
const int AGX_UPC_EAN_L_PATTERNS[AGX_UPC_EAN_L_PATTERNS_LEN][AGX_UPC_EAN_L_PATTERNS_SUB_LEN] = {
    {3, 2, 1, 1}, // 0
    {2, 2, 2, 1}, // 1
    {2, 1, 2, 2}, // 2
    {1, 4, 1, 1}, // 3
    {1, 1, 3, 2}, // 4
    {1, 2, 3, 1}, // 5
    {1, 1, 1, 4}, // 6
    {1, 3, 1, 2}, // 7
    {1, 2, 1, 3}, // 8
    {3, 1, 1, 2}  // 9
};

/**
 * As above but also including the "even", or "G" patterns used to encode UPC/EAN digits.
 */
const int AGX_UPC_EAN_L_AND_G_PATTERNS_LEN = 20;
const int AGX_UPC_EAN_L_AND_G_PATTERNS_SUB_LEN = 4;
const int AGX_UPC_EAN_L_AND_G_PATTERNS[AGX_UPC_EAN_L_AND_G_PATTERNS_LEN][AGX_UPC_EAN_L_AND_G_PATTERNS_SUB_LEN] = {
    {3, 2, 1, 1}, // 0
    {2, 2, 2, 1}, // 1
    {2, 1, 2, 2}, // 2
    {1, 4, 1, 1}, // 3
    {1, 1, 3, 2}, // 4
    {1, 2, 3, 1}, // 5
    {1, 1, 1, 4}, // 6
    {1, 3, 1, 2}, // 7
    {1, 2, 1, 3}, // 8
    {3, 1, 1, 2}, // 9
    {1, 1, 2, 3}, // 10 reversed 0
    {1, 2, 2, 2}, // 11 reversed 1
    {2, 2, 1, 2}, // 12 reversed 2
    {1, 1, 4, 1}, // 13 reversed 3
    {2, 3, 1, 1}, // 14 reversed 4
    {1, 3, 2, 1}, // 15 reversed 5
    {4, 1, 1, 1}, // 16 reversed 6
    {2, 1, 3, 1}, // 17 reversed 7
    {3, 1, 2, 1}, // 18 reversed 8
    {2, 1, 1, 3}  // 19 reversed 9
};

@implementation AGXUPCEANAbstractReader {
    NSMutableString *_decodeRowNSMutableString;
}

- (AGX_INSTANCETYPE)init {
    if AGX_EXPECT_T(self = [super init]) {
        _decodeRowNSMutableString = [[NSMutableString alloc] initWithCapacity:20];
    }
    return self;
}

- (void)dealloc {
    AGX_RELEASE(_decodeRowNSMutableString);
    AGX_SUPER_DEALLOC;
}

- (AGXGcodeResult *)decodeRow:(int)rowNumber row:(AGXBitArray *)row hints:(AGXDecodeHints *)hints error:(NSError **)error {
    NSRange startGuardPattern = findStartGuardPattern(row, error);
    if AGX_EXPECT_F(startGuardPattern.location == NSNotFound) return nil;

    return [self decodeRow:rowNumber row:row startGuardRange:startGuardPattern hints:hints error:error];
}

- (AGXGcodeResult *)decodeRow:(int)rowNumber row:(AGXBitArray *)row startGuardRange:(NSRange)startGuardRange hints:(AGXDecodeHints *)hints error:(NSError **)error {
    NSMutableString *result = [NSMutableString string];
    int endStart = [self decodeMiddle:row startRange:startGuardRange result:result error:error];
    if AGX_EXPECT_F(endStart == -1) return nil;

    NSRange endRange = [self decodeEnd:row endStart:endStart error:error];
    if AGX_EXPECT_F(endRange.location == NSNotFound) return nil;

    // Make sure there is a quiet zone at least as big as the end pattern after the barcode. The
    // spec might want more whitespace, but in practice this is the maximum we can count on.
    int end = (int)NSMaxRange(endRange);
    int quietEnd = end + (end - (int)endRange.location);
    if AGX_EXPECT_F(quietEnd >= row.size || ![row isRange:end end:quietEnd value:NO]) {
        if AGX_EXPECT_T(error) *error = AGXNotFoundErrorInstance();
        return nil;
    }

    NSString *resultString = [result description];
    // UPC/EAN should never be less than 8 chars anyway
    if AGX_EXPECT_F(resultString.length < 8) {
        if AGX_EXPECT_T(error) *error = AGXFormatErrorInstance();
        return nil;
    }
    if AGX_EXPECT_F(![self checkChecksum:resultString error:error]) {
        if AGX_EXPECT_T(error) *error = AGXChecksumErrorInstance();
        return nil;
    }
    return [AGXGcodeResult gcodeResultWithText:resultString format:[self gcodeFormat]];
}

- (BOOL)checkChecksum:(NSString *)sumString error:(NSError **)error {
    if AGX_EXPECT_T(checkStandardUPCEANChecksum(sumString)) {
        return YES;
    } else {
        if AGX_EXPECT_T(error) *error = AGXFormatErrorInstance();
        return NO;
    }
}

- (NSRange)decodeEnd:(AGXBitArray *)row endStart:(int)endStart error:(NSError **)error {
    return findGuardPattern(row, endStart, NO, AGX_UPC_EAN_START_END_PATTERN, AGX_UPC_EAN_START_END_PATTERN_LEN, [AGXIntArray intArrayWithLength:AGX_UPC_EAN_START_END_PATTERN_LEN], error);
}

- (AGXGcodeFormat)gcodeFormat {
    @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                   reason:[NSString stringWithFormat:@"You must override %@ in a subclass", NSStringFromSelector(_cmd)]
                                 userInfo:nil];
}

- (int)decodeMiddle:(AGXBitArray *)row startRange:(NSRange)startRange result:(NSMutableString *)result error:(NSError **)error {
    @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                   reason:[NSString stringWithFormat:@"You must override %@ in a subclass", NSStringFromSelector(_cmd)]
                                 userInfo:nil];
}

@end

NSRange findStartGuardPattern(AGXBitArray *row, NSError **error) {
    BOOL foundStart = NO;
    NSRange startRange = NSMakeRange(NSNotFound, 0);
    int nextStart = 0;
    AGXIntArray *counters = [AGXIntArray intArrayWithLength:AGX_UPC_EAN_START_END_PATTERN_LEN];
    while (!foundStart) {
        [counters clear];
        startRange = findGuardPattern(row, nextStart, NO, AGX_UPC_EAN_START_END_PATTERN,
                                      AGX_UPC_EAN_START_END_PATTERN_LEN, counters, error);
        if AGX_EXPECT_F(startRange.location == NSNotFound) return startRange;

        int start = (int)startRange.location;
        nextStart = (int)NSMaxRange(startRange);
        // Make sure there is a quiet zone at least as big as the start pattern before the barcode.
        // If this check would run off the left edge of the image, do not accept this barcode,
        // as it is very likely to be a false positive.
        int quietStart = start - (nextStart - start);
        if (quietStart >= 0) {
            foundStart = [row isRange:quietStart end:start value:NO];
        }
    }
    return startRange;
}

NSRange findGuardPattern(AGXBitArray *row, int rowOffset, BOOL whiteFirst, const int pattern[], int patternLen, AGXIntArray *counters, NSError **error) {
    int patternLength = patternLen;
    int width = row.size;
    BOOL isWhite = whiteFirst;
    rowOffset = whiteFirst ? [row nextUnset:rowOffset] : [row nextSet:rowOffset];
    int counterPosition = 0;
    int patternStart = rowOffset;
    int32_t *array = counters.array;
    for (int x = rowOffset; x < width; x++) {
        if ([row get:x] ^ isWhite) {
            array[counterPosition]++;
        } else {
            if (counterPosition == patternLength - 1) {
                if (patternMatchVariance(counters, pattern, AGX_UPC_EAN_MAX_INDIVIDUAL_VARIANCE) < AGX_UPC_EAN_MAX_AVG_VARIANCE) {
                    return NSMakeRange(patternStart, x - patternStart);
                }
                patternStart += array[0] + array[1];

                for (int y = 2; y < patternLength; y++) {
                    array[y - 2] = array[y];
                }

                array[patternLength - 2] = 0;
                array[patternLength - 1] = 0;
                counterPosition--;
            } else {
                counterPosition++;
            }
            array[counterPosition] = 1;
            isWhite = !isWhite;
        }
    }

    if AGX_EXPECT_T(error) *error = AGXNotFoundErrorInstance();
    return NSMakeRange(NSNotFound, 0);
}

BOOL checkStandardUPCEANChecksum(NSString *sumString) {
    int length = (int)sumString.length;
    if AGX_EXPECT_F(length == 0) return NO;

    int sum = 0;
    for (int i = length - 2; i >= 0; i -= 2) {
        int digit = (int)[sumString characterAtIndex:i] - (int)'0';
        if (digit < 0 || digit > 9) return NO;
        sum += digit;
    }

    sum *= 3;

    for (int i = length - 1; i >= 0; i -= 2) {
        int digit = (int)[sumString characterAtIndex:i] - (int)'0';
        if (digit < 0 || digit > 9) return NO;
        sum += digit;
    }
    return sum % 10 == 0;
}

int decodeDigit(AGXBitArray *row, AGXIntArray *counters, int rowOffset, AGX_UPC_EAN_PATTERNS patternType, NSError **error) {
    if AGX_EXPECT_F(!recordPattern(row, rowOffset, counters)) {
        if AGX_EXPECT_T(error) *error = AGXNotFoundErrorInstance();
        return -1;
    }
    float bestVariance = AGX_UPC_EAN_MAX_AVG_VARIANCE;
    int bestMatch = -1;
    int max = 0;
    switch (patternType) {
        case AGX_UPC_EAN_PATTERNS_L_PATTERNS:
            max = AGX_UPC_EAN_L_PATTERNS_LEN;
            for (int i = 0; i < max; i++) {
                int pattern[counters.length];
                for (int j = 0; j < counters.length; j++){
                    pattern[j] = AGX_UPC_EAN_L_PATTERNS[i][j];
                }

                float variance = patternMatchVariance(counters, pattern, AGX_UPC_EAN_MAX_INDIVIDUAL_VARIANCE);
                if (variance < bestVariance) {
                    bestVariance = variance;
                    bestMatch = i;
                }
            }
            break;
        case AGX_UPC_EAN_PATTERNS_L_AND_G_PATTERNS:
            max = AGX_UPC_EAN_L_AND_G_PATTERNS_LEN;
            for (int i = 0; i < max; i++) {
                int pattern[counters.length];
                for (int j = 0; j< counters.length; j++){
                    pattern[j] = AGX_UPC_EAN_L_AND_G_PATTERNS[i][j];
                }

                float variance = patternMatchVariance(counters, pattern, AGX_UPC_EAN_MAX_INDIVIDUAL_VARIANCE);
                if (variance < bestVariance) {
                    bestVariance = variance;
                    bestMatch = i;
                }
            }
            break;
        default:
            break;
    }

    if AGX_EXPECT_T(bestMatch >= 0) {
        return bestMatch;
    } else {
        if AGX_EXPECT_T(error) *error = AGXNotFoundErrorInstance();
        return -1;
    }
}
