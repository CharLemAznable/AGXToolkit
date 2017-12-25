//
//  AGXCode128Reader.m
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
#import "AGXCode128Reader.h"
#import "AGXGcodeError.h"

const int AGX_CODE128_CODE_PATTERNS_LEN = 107;
const int AGX_CODE128_CODE_PATTERNS[AGX_CODE128_CODE_PATTERNS_LEN][7] = {
    {2, 1, 2, 2, 2, 2}, // 0
    {2, 2, 2, 1, 2, 2},
    {2, 2, 2, 2, 2, 1},
    {1, 2, 1, 2, 2, 3},
    {1, 2, 1, 3, 2, 2},
    {1, 3, 1, 2, 2, 2}, // 5
    {1, 2, 2, 2, 1, 3},
    {1, 2, 2, 3, 1, 2},
    {1, 3, 2, 2, 1, 2},
    {2, 2, 1, 2, 1, 3},
    {2, 2, 1, 3, 1, 2}, // 10
    {2, 3, 1, 2, 1, 2},
    {1, 1, 2, 2, 3, 2},
    {1, 2, 2, 1, 3, 2},
    {1, 2, 2, 2, 3, 1},
    {1, 1, 3, 2, 2, 2}, // 15
    {1, 2, 3, 1, 2, 2},
    {1, 2, 3, 2, 2, 1},
    {2, 2, 3, 2, 1, 1},
    {2, 2, 1, 1, 3, 2},
    {2, 2, 1, 2, 3, 1}, // 20
    {2, 1, 3, 2, 1, 2},
    {2, 2, 3, 1, 1, 2},
    {3, 1, 2, 1, 3, 1},
    {3, 1, 1, 2, 2, 2},
    {3, 2, 1, 1, 2, 2}, // 25
    {3, 2, 1, 2, 2, 1},
    {3, 1, 2, 2, 1, 2},
    {3, 2, 2, 1, 1, 2},
    {3, 2, 2, 2, 1, 1},
    {2, 1, 2, 1, 2, 3}, // 30
    {2, 1, 2, 3, 2, 1},
    {2, 3, 2, 1, 2, 1},
    {1, 1, 1, 3, 2, 3},
    {1, 3, 1, 1, 2, 3},
    {1, 3, 1, 3, 2, 1}, // 35
    {1, 1, 2, 3, 1, 3},
    {1, 3, 2, 1, 1, 3},
    {1, 3, 2, 3, 1, 1},
    {2, 1, 1, 3, 1, 3},
    {2, 3, 1, 1, 1, 3}, // 40
    {2, 3, 1, 3, 1, 1},
    {1, 1, 2, 1, 3, 3},
    {1, 1, 2, 3, 3, 1},
    {1, 3, 2, 1, 3, 1},
    {1, 1, 3, 1, 2, 3}, // 45
    {1, 1, 3, 3, 2, 1},
    {1, 3, 3, 1, 2, 1},
    {3, 1, 3, 1, 2, 1},
    {2, 1, 1, 3, 3, 1},
    {2, 3, 1, 1, 3, 1}, // 50
    {2, 1, 3, 1, 1, 3},
    {2, 1, 3, 3, 1, 1},
    {2, 1, 3, 1, 3, 1},
    {3, 1, 1, 1, 2, 3},
    {3, 1, 1, 3, 2, 1}, // 55
    {3, 3, 1, 1, 2, 1},
    {3, 1, 2, 1, 1, 3},
    {3, 1, 2, 3, 1, 1},
    {3, 3, 2, 1, 1, 1},
    {3, 1, 4, 1, 1, 1}, // 60
    {2, 2, 1, 4, 1, 1},
    {4, 3, 1, 1, 1, 1},
    {1, 1, 1, 2, 2, 4},
    {1, 1, 1, 4, 2, 2},
    {1, 2, 1, 1, 2, 4}, // 65
    {1, 2, 1, 4, 2, 1},
    {1, 4, 1, 1, 2, 2},
    {1, 4, 1, 2, 2, 1},
    {1, 1, 2, 2, 1, 4},
    {1, 1, 2, 4, 1, 2}, // 70
    {1, 2, 2, 1, 1, 4},
    {1, 2, 2, 4, 1, 1},
    {1, 4, 2, 1, 1, 2},
    {1, 4, 2, 2, 1, 1},
    {2, 4, 1, 2, 1, 1}, // 75
    {2, 2, 1, 1, 1, 4},
    {4, 1, 3, 1, 1, 1},
    {2, 4, 1, 1, 1, 2},
    {1, 3, 4, 1, 1, 1},
    {1, 1, 1, 2, 4, 2}, // 80
    {1, 2, 1, 1, 4, 2},
    {1, 2, 1, 2, 4, 1},
    {1, 1, 4, 2, 1, 2},
    {1, 2, 4, 1, 1, 2},
    {1, 2, 4, 2, 1, 1}, // 85
    {4, 1, 1, 2, 1, 2},
    {4, 2, 1, 1, 1, 2},
    {4, 2, 1, 2, 1, 1},
    {2, 1, 2, 1, 4, 1},
    {2, 1, 4, 1, 2, 1}, // 90
    {4, 1, 2, 1, 2, 1},
    {1, 1, 1, 1, 4, 3},
    {1, 1, 1, 3, 4, 1},
    {1, 3, 1, 1, 4, 1},
    {1, 1, 4, 1, 1, 3}, // 95
    {1, 1, 4, 3, 1, 1},
    {4, 1, 1, 1, 1, 3},
    {4, 1, 1, 3, 1, 1},
    {1, 1, 3, 1, 4, 1},
    {1, 1, 4, 1, 3, 1}, // 100
    {3, 1, 1, 1, 4, 1},
    {4, 1, 1, 1, 3, 1},
    {2, 1, 1, 4, 1, 2},
    {2, 1, 1, 2, 1, 4},
    {2, 1, 1, 2, 3, 2}, // 105
    {2, 3, 3, 1, 1, 1, 2}
};

static float AGX_CODE128_MAX_AVG_VARIANCE = 0.25f;
static float AGX_CODE128_MAX_INDIVIDUAL_VARIANCE = 0.7f;

const int AGX_CODE128_CODE_SHIFT = 98;
const int AGX_CODE128_CODE_CODE_C = 99;
const int AGX_CODE128_CODE_CODE_B = 100;
const int AGX_CODE128_CODE_CODE_A = 101;
const int AGX_CODE128_CODE_FNC_1 = 102;
const int AGX_CODE128_CODE_FNC_2 = 97;
const int AGX_CODE128_CODE_FNC_3 = 96;
const int AGX_CODE128_CODE_FNC_4_A = 101;
const int AGX_CODE128_CODE_FNC_4_B = 100;
const int AGX_CODE128_CODE_START_A = 103;
const int AGX_CODE128_CODE_START_B = 104;
const int AGX_CODE128_CODE_START_C = 105;
const int AGX_CODE128_CODE_STOP = 106;

@implementation AGXCode128Reader

- (AGXGcodeResult *)decodeRow:(int)rowNumber row:(AGXBitArray *)row hints:(AGXDecodeHints *)hints error:(NSError **)error {
    BOOL convertFNC1 = NO;//hints && hints.assumeGS1;

    AGXIntArray *startPatternInfo = [self findStartPattern:row];
    if AGX_EXPECT_F(!startPatternInfo) {
        if AGX_EXPECT_T(error) *error = AGXNotFoundErrorInstance();
        return nil;
    }

    int startCode = startPatternInfo.array[2];
    int codeSet;

    NSMutableArray *rawCodes = [NSMutableArray arrayWithObject:@(startCode)];

    switch (startCode) {
        case AGX_CODE128_CODE_START_A:
            codeSet = AGX_CODE128_CODE_CODE_A;
            break;
        case AGX_CODE128_CODE_START_B:
            codeSet = AGX_CODE128_CODE_CODE_B;
            break;
        case AGX_CODE128_CODE_START_C:
            codeSet = AGX_CODE128_CODE_CODE_C;
            break;
        default:
            if AGX_EXPECT_T(error) *error = AGXFormatErrorInstance();
            return nil;
    }

    BOOL done = NO;
    BOOL isNextShifted = NO;

    NSMutableString *result = [NSMutableString stringWithCapacity:20];

    int lastStart = startPatternInfo.array[0];
    int nextStart = startPatternInfo.array[1];
    AGXIntArray *counters = [AGXIntArray intArrayWithLength:6];

    int lastCode = 0;
    int code = 0;
    int checksumTotal = startCode;
    int multiplier = 0;
    BOOL lastCharacterWasPrintable = YES;
    BOOL upperMode = NO;
    BOOL shiftUpperMode = NO;

    while (!done) {
        BOOL unshift = isNextShifted;
        isNextShifted = NO;

        // Save off last code
        lastCode = code;

        // Decode another code from image
        code = [self decodeCode:row counters:counters rowOffset:nextStart];
        if AGX_EXPECT_F(code == -1) {
            if AGX_EXPECT_T(error) *error = AGXNotFoundErrorInstance();
            return nil;
        }

        [rawCodes addObject:@(code)];

        // Remember whether the last code was printable or not (excluding AGX_CODE128_CODE_STOP)
        if (code != AGX_CODE128_CODE_STOP) {
            lastCharacterWasPrintable = YES;
        }

        // Add to checksum computation (if not AGX_CODE128_CODE_STOP of course)
        if (code != AGX_CODE128_CODE_STOP) {
            multiplier++;
            checksumTotal += multiplier * code;
        }

        // Advance to where the next code will to start
        lastStart = nextStart;
        nextStart += [counters sum];

        // Take care of illegal start codes
        switch (code) {
            case AGX_CODE128_CODE_START_A:
            case AGX_CODE128_CODE_START_B:
            case AGX_CODE128_CODE_START_C:
                if AGX_EXPECT_T(error) *error = AGXFormatErrorInstance();
                return nil;
        }

        switch (codeSet) {
            case AGX_CODE128_CODE_CODE_A:
                if (code < 64) {
                    if (shiftUpperMode == upperMode) {
                        [result appendFormat:@"%C", (unichar)(' ' + code)];
                    } else {
                        [result appendFormat:@"%C", (unichar)(' ' + code + 128)];
                    }
                    shiftUpperMode = NO;
                } else if (code < 96) {
                    if (shiftUpperMode == upperMode) {
                        [result appendFormat:@"%C", (unichar)(code - 64)];
                    } else {
                        [result appendFormat:@"%C", (unichar)(code + 64)];
                    }
                    shiftUpperMode = NO;
                } else {
                    // Don't let CODE_STOP, which always appears, affect whether whether we think the last
                    // code was printable or not.
                    if (code != AGX_CODE128_CODE_STOP) {
                        lastCharacterWasPrintable = NO;
                    }

                    switch (code) {
                        case AGX_CODE128_CODE_FNC_1:
                            if (convertFNC1) {
                                if (result.length == 0) {
                                    // GS1 specification 5.4.3.7. and 5.4.6.4. If the first char after the start code
                                    // is FNC1 then this is GS1-128. We add the symbology identifier.
                                    [result appendString:@"]C1"];
                                } else {
                                    // GS1 specification 5.4.7.5. Every subsequent FNC1 is returned as ASCII 29 (GS)
                                    [result appendFormat:@"%C", (unichar) 29];
                                }
                            }
                            break;
                        case AGX_CODE128_CODE_FNC_2:
                        case AGX_CODE128_CODE_FNC_3:
                            // do nothing?
                            break;
                        case AGX_CODE128_CODE_FNC_4_A:
                            if (!upperMode && shiftUpperMode) {
                                upperMode = YES;
                                shiftUpperMode = NO;
                            } else if (upperMode && shiftUpperMode) {
                                upperMode = NO;
                                shiftUpperMode = NO;
                            } else {
                                shiftUpperMode = YES;
                            }
                            break;
                        case AGX_CODE128_CODE_SHIFT:
                            isNextShifted = YES;
                            codeSet = AGX_CODE128_CODE_CODE_B;
                            break;
                        case AGX_CODE128_CODE_CODE_B:
                            codeSet = AGX_CODE128_CODE_CODE_B;
                            break;
                        case AGX_CODE128_CODE_CODE_C:
                            codeSet = AGX_CODE128_CODE_CODE_C;
                            break;
                        case AGX_CODE128_CODE_STOP:
                            done = YES;
                            break;
                    }
                }
                break;
            case AGX_CODE128_CODE_CODE_B:
                if (code < 96) {
                    if (shiftUpperMode == upperMode) {
                        [result appendFormat:@"%C", (unichar)(' ' + code)];
                    } else {
                        [result appendFormat:@"%C", (unichar)(' ' + code + 128)];
                    }
                    shiftUpperMode = NO;
                } else {
                    if (code != AGX_CODE128_CODE_STOP) {
                        lastCharacterWasPrintable = NO;
                    }

                    switch (code) {
                        case AGX_CODE128_CODE_FNC_1:
                            if (convertFNC1) {
                                if (result.length == 0) {
                                    // GS1 specification 5.4.3.7. and 5.4.6.4. If the first char after the start code
                                    // is FNC1 then this is GS1-128. We add the symbology identifier.
                                    [result appendString:@"]C1"];
                                } else {
                                    // GS1 specification 5.4.7.5. Every subsequent FNC1 is returned as ASCII 29 (GS)
                                    [result appendFormat:@"%C", (unichar) 29];
                                }
                            }
                            break;
                        case AGX_CODE128_CODE_FNC_2:
                        case AGX_CODE128_CODE_FNC_3:
                            // do nothing?
                            break;
                        case AGX_CODE128_CODE_FNC_4_B:
                            if (!upperMode && shiftUpperMode) {
                                upperMode = YES;
                                shiftUpperMode = NO;
                            } else if (upperMode && shiftUpperMode) {
                                upperMode = NO;
                                shiftUpperMode = NO;
                            } else {
                                shiftUpperMode = YES;
                            }
                            break;
                        case AGX_CODE128_CODE_SHIFT:
                            isNextShifted = YES;
                            codeSet = AGX_CODE128_CODE_CODE_A;
                            break;
                        case AGX_CODE128_CODE_CODE_A:
                            codeSet = AGX_CODE128_CODE_CODE_A;
                            break;
                        case AGX_CODE128_CODE_CODE_C:
                            codeSet = AGX_CODE128_CODE_CODE_C;
                            break;
                        case AGX_CODE128_CODE_STOP:
                            done = YES;
                            break;
                    }
                }
                break;
            case AGX_CODE128_CODE_CODE_C:
                if (code < 100) {
                    if (code < 10) {
                        [result appendString:@"0"];
                    }
                    [result appendFormat:@"%d", code];
                } else {
                    if (code != AGX_CODE128_CODE_STOP) {
                        lastCharacterWasPrintable = NO;
                    }

                    switch (code) {
                        case AGX_CODE128_CODE_FNC_1:
                            if (convertFNC1) {
                                if (result.length == 0) {
                                    // GS1 specification 5.4.3.7. and 5.4.6.4. If the first char after the start code
                                    // is FNC1 then this is GS1-128. We add the symbology identifier.
                                    [result appendString:@"]C1"];
                                } else {
                                    // GS1 specification 5.4.7.5. Every subsequent FNC1 is returned as ASCII 29 (GS)
                                    [result appendFormat:@"%C", (unichar) 29];
                                }
                            }
                            break;
                        case AGX_CODE128_CODE_CODE_A:
                            codeSet = AGX_CODE128_CODE_CODE_A;
                            break;
                        case AGX_CODE128_CODE_CODE_B:
                            codeSet = AGX_CODE128_CODE_CODE_B;
                            break;
                        case AGX_CODE128_CODE_STOP:
                            done = YES;
                            break;
                    }
                }
                break;
        }
        
        // Unshift back to another code set if we were shifted
        if (unshift) {
            codeSet = codeSet == AGX_CODE128_CODE_CODE_A ? AGX_CODE128_CODE_CODE_B : AGX_CODE128_CODE_CODE_A;
        }
    }

    // Check for ample whitespace following pattern, but, to do this we first need to remember that
    // we fudged decoding CODE_STOP since it actually has 7 bars, not 6. There is a black bar left
    // to read off. Would be slightly better to properly read. Here we just skip it:
    nextStart = [row nextUnset:nextStart];
    if AGX_EXPECT_F(![row isRange:nextStart end:MIN(row.size, nextStart + (nextStart - lastStart) / 2) value:NO]) {
        if AGX_EXPECT_T(error) *error = AGXNotFoundErrorInstance();
        return nil;
    }
    
    // Pull out from sum the value of the penultimate check code
    checksumTotal -= multiplier * lastCode;
    // lastCode is the checksum then:
    if AGX_EXPECT_F(checksumTotal % 103 != lastCode) {
        if AGX_EXPECT_T(error) *error = AGXChecksumErrorInstance();
        return nil;
    }
    
    // Need to pull out the check digits from string
    NSUInteger resultLength = [result length];
    if AGX_EXPECT_F(resultLength == 0) {
        // false positive
        if AGX_EXPECT_T(error) *error = AGXNotFoundErrorInstance();
        return nil;
    }
    
    // Only bother if the result had at least one character, and if the checksum digit happened to
    // be a printable character. If it was just interpreted as a control code, nothing to remove.
    if (resultLength > 0 && lastCharacterWasPrintable) {
        if (codeSet == AGX_CODE128_CODE_CODE_C) {
            [result deleteCharactersInRange:NSMakeRange(resultLength - 2, 2)];
        } else {
            [result deleteCharactersInRange:NSMakeRange(resultLength - 1, 1)];
        }
    }
    
    return [AGXGcodeResult gcodeResultWithText:result format:kGcodeFormatCode128];
}

- (AGXIntArray *)findStartPattern:(AGXBitArray *)row {
    int width = row.size;
    int rowOffset = [row nextSet:0];

    int counterPosition = 0;
    AGXIntArray *counters = [AGXIntArray intArrayWithLength:6];
    int32_t *array = counters.array;
    int patternStart = rowOffset;
    BOOL isWhite = NO;
    int patternLength = (int)counters.length;

    for (int i = rowOffset; i < width; i++) {
        if ([row get:i] ^ isWhite) {
            array[counterPosition]++;
        } else {
            if (counterPosition == patternLength - 1) {
                float bestVariance = AGX_CODE128_MAX_AVG_VARIANCE;
                int bestMatch = -1;
                for (int startCode = AGX_CODE128_CODE_START_A; startCode <= AGX_CODE128_CODE_START_C; startCode++) {
                    float variance = patternMatchVariance(counters, AGX_CODE128_CODE_PATTERNS[startCode], AGX_CODE128_MAX_INDIVIDUAL_VARIANCE);
                    if (variance < bestVariance) {
                        bestVariance = variance;
                        bestMatch = startCode;
                    }
                }
                // Look for whitespace before start pattern, >= 50% of width of start pattern
                if (bestMatch >= 0 &&
                    [row isRange:MAX(0, patternStart - (i - patternStart) / 2) end:patternStart value:NO]) {
                    return [AGXIntArray intArrayWithInts:patternStart, i, bestMatch, -1];
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

    return nil;
}

- (int)decodeCode:(AGXBitArray *)row counters:(AGXIntArray *)counters rowOffset:(int)rowOffset {
    if AGX_EXPECT_F(!recordPattern(row, rowOffset, counters)) return -1;

    float bestVariance = AGX_CODE128_MAX_AVG_VARIANCE;
    int bestMatch = -1;

    for (int d = 0; d < AGX_CODE128_CODE_PATTERNS_LEN; d++) {
        float variance = patternMatchVariance(counters, AGX_CODE128_CODE_PATTERNS[d], AGX_CODE128_MAX_INDIVIDUAL_VARIANCE);
        if (variance < bestVariance) {
            bestVariance = variance;
            bestMatch = d;
        }
    }

    return bestMatch >= 0 ? bestMatch : -1;
}

@end
