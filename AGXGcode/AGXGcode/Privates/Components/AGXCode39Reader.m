//
//  AGXCode39Reader.m
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
#import "AGXCode39Reader.h"
#import "AGXGcodeError.h"

unichar AGX_CODE39_ALPHABET[] = {'0', '1', '2', '3', '4', '5', '6', '7', '8', '9', 'A', 'B', 'C', 'D',
    'E', 'F', 'G', 'H', 'I', 'J', 'K', 'L', 'M', 'N', 'O', 'P', 'Q', 'R', 'S', 'T', 'U', 'V', 'W',
    'X', 'Y', 'Z', '-', '.', ' ', '*', '$', '/', '+', '%'};

/**
 * These represent the encodings of characters, as patterns of wide and narrow bars.
 * The 9 least-significant bits of each int correspond to the pattern of wide and narrow,
 * with 1s representing "wide" and 0s representing narrow.
 */
const int AGX_CODE39_CHARACTER_ENCODINGS[] = {
    0x034, 0x121, 0x061, 0x160, 0x031, 0x130, 0x070, 0x025, 0x124, 0x064, // 0-9
    0x109, 0x049, 0x148, 0x019, 0x118, 0x058, 0x00D, 0x10C, 0x04C, 0x01C, // A-J
    0x103, 0x043, 0x142, 0x013, 0x112, 0x052, 0x007, 0x106, 0x046, 0x016, // K-T
    0x181, 0x0C1, 0x1C0, 0x091, 0x190, 0x0D0, 0x085, 0x184, 0x0C4, 0x094, // U-*
    0x0A8, 0x0A2, 0x08A, 0x02A // $-%
};

const int AGX_CODE39_ASTERISK_ENCODING = 0x094;

@implementation AGXCode39Reader {
    AGXIntArray *_counters;
}

- (AGX_INSTANCETYPE)init {
    if (AGX_EXPECT_T(self = [super init])) {
        _counters = [[AGXIntArray alloc] initWithLength:9];
    }
    return self;
}

- (void)dealloc {
    AGX_RELEASE(_counters);
    AGX_SUPER_DEALLOC;
}

- (AGXGcodeResult *)decodeRow:(int)rowNumber row:(AGXBitArray *)row hints:(AGXDecodeHints *)hints error:(NSError **)error {
    [_counters clear];
    NSMutableString *result = [NSMutableString stringWithCapacity:20];

    AGXIntArray *start = [self findAsteriskPattern:row counters:_counters];
    if (AGX_EXPECT_F(!start)) {
        if (AGX_EXPECT_T(error)) *error = AGXNotFoundErrorInstance();
        return nil;
    }
    // Read off white space
    int nextStart = [row nextSet:start.array[1]];
    int end = [row size];

    unichar decodedChar;
    int lastStart;
    do {
        if (AGX_EXPECT_F(!recordPattern(row, nextStart, _counters))) {
            if (AGX_EXPECT_T(error)) *error = AGXNotFoundErrorInstance();
            return nil;
        }
        int pattern = [self toNarrowWidePattern:_counters];
        if (AGX_EXPECT_F(pattern < 0)) {
            if (AGX_EXPECT_T(error)) *error = AGXNotFoundErrorInstance();
            return nil;
        }
        decodedChar = [self patternToChar:pattern];
        if (AGX_EXPECT_F(decodedChar == 0)) {
            if (AGX_EXPECT_T(error)) *error = AGXNotFoundErrorInstance();
            return nil;
        }
        [result appendFormat:@"%C", decodedChar];
        lastStart = nextStart;
        for (int i = 0; i < _counters.length; i++) {
            nextStart += _counters.array[i];
        }
        // Read off white space
        nextStart = [row nextSet:nextStart];
    } while (decodedChar != '*');
    [result deleteCharactersInRange:NSMakeRange([result length] - 1, 1)];

    int lastPatternSize = 0;
    for (int i = 0; i < _counters.length; i++) {
        lastPatternSize += _counters.array[i];
    }
    int whiteSpaceAfterEnd = nextStart - lastStart - lastPatternSize;
    if (AGX_EXPECT_F(nextStart != end && (whiteSpaceAfterEnd * 2) < lastPatternSize)) {
        if (AGX_EXPECT_T(error)) *error = AGXNotFoundErrorInstance();
        return nil;
    }

    if (AGX_EXPECT_F([result length] == 0)) {
        // false positive
        if (AGX_EXPECT_T(error)) *error = AGXNotFoundErrorInstance();
        return nil;
    }

    NSString *resultString = [self decodeExtended:result];
    if (AGX_EXPECT_F(!resultString)) {
        if (AGX_EXPECT_T(error)) *error = AGXFormatErrorInstance();
        return nil;
    }
    return [AGXGcodeResult resultWithText:resultString format:kGcodeFormatCode39];
}

- (AGXIntArray *)findAsteriskPattern:(AGXBitArray *)row counters:(AGXIntArray *)counters {
    int width = row.size;
    int rowOffset = [row nextSet:0];

    int counterPosition = 0;
    int patternStart = rowOffset;
    BOOL isWhite = NO;
    int patternLength = counters.length;
    int32_t *array = counters.array;

    for (int i = rowOffset; i < width; i++) {
        if ([row get:i] ^ isWhite) {
            array[counterPosition]++;
        } else {
            if (counterPosition == patternLength - 1) {
                if ([self toNarrowWidePattern:counters] == AGX_CODE39_ASTERISK_ENCODING &&
                    [row isRange:MAX(0, patternStart - ((i - patternStart) / 2)) end:patternStart value:NO]) {
                    return [AGXIntArray intArrayWithInts:patternLength, i, -1];
                }
                patternStart += array[0] + array[1];
                for (int y = 2; y < counters.length; y++) {
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

- (int)toNarrowWidePattern:(AGXIntArray *)counters {
    int numCounters = counters.length;
    int maxNarrowCounter = 0;
    int wideCounters;
    do {
        int minCounter = INT_MAX;
        int32_t *array = counters.array;
        for (int i = 0; i < numCounters; i++) {
            int counter = array[i];
            if (counter < minCounter && counter > maxNarrowCounter) {
                minCounter = counter;
            }
        }
        maxNarrowCounter = minCounter;
        wideCounters = 0;
        int totalWideCountersWidth = 0;
        int pattern = 0;
        for (int i = 0; i < numCounters; i++) {
            int counter = array[i];
            if (array[i] > maxNarrowCounter) {
                pattern |= 1 << (numCounters - 1 - i);
                wideCounters++;
                totalWideCountersWidth += counter;
            }
        }
        if (wideCounters == 3) {
            for (int i = 0; i < numCounters && wideCounters > 0; i++) {
                int counter = array[i];
                if (array[i] > maxNarrowCounter) {
                    wideCounters--;
                    if (AGX_EXPECT_F((counter * 2) >= totalWideCountersWidth)) {
                        return -1;
                    }
                }
            }
            return pattern;
        }
    } while (wideCounters > 3);
    return -1;
}

- (unichar)patternToChar:(int)pattern {
    for (int i = 0; i < sizeof(AGX_CODE39_CHARACTER_ENCODINGS) / sizeof(int); i++) {
        if (AGX_CODE39_CHARACTER_ENCODINGS[i] == pattern) {
            return AGX_CODE39_ALPHABET[i];
        }
    }
    return 0;
}

- (NSString *)decodeExtended:(NSMutableString *)encoded {
    NSUInteger length = [encoded length];
    NSMutableString *decoded = [NSMutableString stringWithCapacity:length];

    for (int i = 0; i < length; i++) {
        unichar c = [encoded characterAtIndex:i];
        if (c == '+' || c == '$' || c == '%' || c == '/') {
            unichar next = [encoded characterAtIndex:i + 1];
            unichar decodedChar = '\0';

            switch (c) {
                case '+':
                    if (AGX_EXPECT_T(next >= 'A' && next <= 'Z')) {
                        decodedChar = (unichar)(next + 32);
                    } else {
                        return nil;
                    }
                    break;
                case '$':
                    if (AGX_EXPECT_T(next >= 'A' && next <= 'Z')) {
                        decodedChar = (unichar)(next - 64);
                    } else {
                        return nil;
                    }
                    break;
                case '%':
                    if (AGX_EXPECT_T(next >= 'A' && next <= 'E')) {
                        decodedChar = (unichar)(next - 38);
                    } else if (AGX_EXPECT_T(next >= 'F' && next <= 'W')) {
                        decodedChar = (unichar)(next - 11);
                    } else {
                        return nil;
                    }
                    break;
                case '/':
                    if (AGX_EXPECT_T(next >= 'A' && next <= 'O')) {
                        decodedChar = (unichar)(next - 32);
                    } else if (AGX_EXPECT_T(next == 'Z')) {
                        decodedChar = ':';
                    } else {
                        return nil;
                    }
                    break;
            }
            [decoded appendFormat:@"%C", decodedChar];
            i++;
        } else {
            [decoded appendFormat:@"%C", c];
        }
    }
    return decoded;
}

@end
