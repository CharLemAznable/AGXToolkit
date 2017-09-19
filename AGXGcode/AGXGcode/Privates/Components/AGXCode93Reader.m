//
//  AGXCode93Reader.m
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
#import "AGXCode93Reader.h"
#import "AGXGcodeError.h"

NSString *AGX_CODE93_ALPHABET_STRING = nil;
const unichar AGX_CODE93_ALPHABET[] = {'0', '1', '2', '3', '4', '5', '6', '7', '8', '9', 'A', 'B', 'C', 'D',
    'E', 'F', 'G', 'H', 'I', 'J', 'K', 'L', 'M', 'N', 'O', 'P', 'Q', 'R', 'S', 'T', 'U', 'V', 'W',
    'X', 'Y', 'Z', '-', '.', ' ', '$', '/', '+', '%', 'a', 'b', 'c', 'd', '*'};

/**
 * These represent the encodings of characters, as patterns of wide and narrow bars.
 * The 9 least-significant bits of each int correspond to the pattern of wide and narrow.
 */
const int AGX_CODE93_CHARACTER_ENCODINGS[] = {
    0x114, 0x148, 0x144, 0x142, 0x128, 0x124, 0x122, 0x150, 0x112, 0x10A, // 0-9
    0x1A8, 0x1A4, 0x1A2, 0x194, 0x192, 0x18A, 0x168, 0x164, 0x162, 0x134, // A-J
    0x11A, 0x158, 0x14C, 0x146, 0x12C, 0x116, 0x1B4, 0x1B2, 0x1AC, 0x1A6, // K-T
    0x196, 0x19A, 0x16C, 0x166, 0x136, 0x13A, // U-Z
    0x12E, 0x1D4, 0x1D2, 0x1CA, 0x16E, 0x176, 0x1AE, // - - %
    0x126, 0x1DA, 0x1D6, 0x132, 0x15E, // Control chars? $-*
};

const int AGX_CODE93_ASTERISK_ENCODING = 0x15E;

@implementation AGXCode93Reader {
    AGXIntArray *_counters;
}

+ (void)load {
    static dispatch_once_t once_t;
    dispatch_once(&once_t, ^{
        AGX_CODE93_ALPHABET_STRING = [[NSString alloc] initWithCharacters:AGX_CODE93_ALPHABET
                                                                   length:sizeof(AGX_CODE93_ALPHABET) / sizeof(unichar)];
    });
}

- (AGX_INSTANCETYPE)init {
    if (AGX_EXPECT_T(self = [super init])) {
        _counters = [[AGXIntArray alloc] initWithLength:6];
    }
    return self;
}

- (void)dealloc {
    AGX_RELEASE(_counters);
    AGX_SUPER_DEALLOC;
}

- (AGXGcodeResult *)decodeRow:(int)rowNumber row:(AGXBitArray *)row hints:(AGXDecodeHints *)hints error:(NSError **)error {
    AGXIntArray *start = [self findAsteriskPattern:row];
    if (!start) {
        if (error) *error = AGXNotFoundErrorInstance();
        return nil;
    }
    // Read off white space
    int nextStart = [row nextSet:start.array[1]];
    int end = row.size;

    memset(_counters.array, 0, _counters.length * sizeof(int32_t));
    NSMutableString *result = [NSMutableString string];

    unichar decodedChar;
    do {
        if (!recordPattern(row, nextStart, _counters)) {
            if (error) *error = AGXNotFoundErrorInstance();
            return nil;
        }
        int pattern = [self toPattern:_counters];
        if (pattern < 0) {
            if (error) *error = AGXNotFoundErrorInstance();
            return nil;
        }
        decodedChar = [self patternToChar:pattern];
        if (decodedChar == 0) {
            if (error) *error = AGXNotFoundErrorInstance();
            return nil;
        }
        [result appendFormat:@"%C", decodedChar];
        for (int i = 0; i < _counters.length; i++) {
            nextStart += _counters.array[i];
        }
        // Read off white space
        nextStart = [row nextSet:nextStart];
    } while (decodedChar != '*');
    [result deleteCharactersInRange:NSMakeRange([result length] - 1, 1)]; // remove asterisk

    // Should be at least one more black module
    if (nextStart == end || ![row get:nextStart]) {
        if (error) *error = AGXNotFoundErrorInstance();
        return nil;
    }

    if ([result length] < 2) {
        // false positive -- need at least 2 checksum digits
        if (error) *error = AGXNotFoundErrorInstance();
        return nil;
    }

    if (![self checkChecksums:result error:error]) {
        return nil;
    }
    [result deleteCharactersInRange:NSMakeRange([result length] - 2, 2)];

    NSString *resultString = [self decodeExtended:result];
    if (!resultString) {
        if (error) *error = AGXFormatErrorInstance();
        return nil;
    }
    return [AGXGcodeResult resultWithText:resultString format:kGcodeFormatCode93];
}

- (AGXIntArray *)findAsteriskPattern:(AGXBitArray *)row {
    int width = row.size;
    int rowOffset = [row nextSet:0];

    [_counters clear];
    int patternStart = rowOffset;
    BOOL isWhite = NO;
    int patternLength = _counters.length;

    int counterPosition = 0;
    for (int i = rowOffset; i < width; i++) {
        if ([row get:i] ^ isWhite) {
            _counters.array[counterPosition]++;
        } else {
            if (counterPosition == patternLength - 1) {
                if ([self toPattern:_counters] == AGX_CODE93_ASTERISK_ENCODING) {
                    return [AGXIntArray intArrayWithInts:patternStart, i, -1];
                }
                patternStart += _counters.array[0] + _counters.array[1];
                for (int y = 2; y < patternLength; y++) {
                    _counters.array[y - 2] = _counters.array[y];
                }
                _counters.array[patternLength - 2] = 0;
                _counters.array[patternLength - 1] = 0;
                counterPosition--;
            } else {
                counterPosition++;
            }
            _counters.array[counterPosition] = 1;
            isWhite = !isWhite;
        }
    }

    return nil;
}

- (int)toPattern:(AGXIntArray *)counters {
    int max = counters.length;
    int sum = [counters sum];
    int32_t *array = counters.array;
    int pattern = 0;
    for (int i = 0; i < max; i++) {
        int scaled = round(array[i] * 9.0f / sum);
        if (scaled < 1 || scaled > 4) {
            return -1;
        }
        if ((i & 0x01) == 0) {
            for (int j = 0; j < scaled; j++) {
                pattern = (pattern << 1) | 0x01;
            }
        } else {
            pattern <<= scaled;
        }
    }
    return pattern;
}

- (unichar)patternToChar:(int)pattern {
    for (int i = 0; i < sizeof(AGX_CODE93_CHARACTER_ENCODINGS) / sizeof(int); i++) {
        if (AGX_CODE93_CHARACTER_ENCODINGS[i] == pattern) {
            return AGX_CODE93_ALPHABET[i];
        }
    }

    return -1;
}

- (NSString *)decodeExtended:(NSMutableString *)encoded {
    NSUInteger length = [encoded length];
    NSMutableString *decoded = [NSMutableString stringWithCapacity:length];
    for (int i = 0; i < length; i++) {
        unichar c = [encoded characterAtIndex:i];
        if (c >= 'a' && c <= 'd') {
            if (i >= length - 1) {
                return nil;
            }
            unichar next = [encoded characterAtIndex:i + 1];
            unichar decodedChar = '\0';
            switch (c) {
                case 'd':
                    if (next >= 'A' && next <= 'Z') {
                        decodedChar = (unichar)(next + 32);
                    } else {
                        return nil;
                    }
                    break;
                case 'a':
                    if (next >= 'A' && next <= 'Z') {
                        decodedChar = (unichar)(next - 64);
                    } else {
                        return nil;
                    }
                    break;
                case 'b':
                    if (next >= 'A' && next <= 'E') {
                        decodedChar = (unichar)(next - 38);
                    } else if (next >= 'F' && next <= 'W') {
                        decodedChar = (unichar)(next - 11);
                    } else {
                        return nil;
                    }
                    break;
                case 'c':
                    if (next >= 'A' && next <= 'O') {
                        decodedChar = (unichar)(next - 32);
                    } else if (next == 'Z') {
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

- (BOOL)checkChecksums:(NSMutableString *)result error:(NSError **)error {
    NSUInteger length = [result length];
    if (![self checkOneChecksum:result checkPosition:(int)length - 2 weightMax:20 error:error]) {
        return NO;
    }
    return [self checkOneChecksum:result checkPosition:(int)length - 1 weightMax:15 error:error];
}

- (BOOL)checkOneChecksum:(NSMutableString *)result checkPosition:(int)checkPosition weightMax:(int)weightMax error:(NSError **)error {
    int weight = 1;
    int total = 0;
    
    for (int i = checkPosition - 1; i >= 0; i--) {
        total += weight * [AGX_CODE93_ALPHABET_STRING rangeOfString:[NSString stringWithFormat:@"%C", [result characterAtIndex:i]]].location;
        if (++weight > weightMax) {
            weight = 1;
        }
    }
    
    if ([result characterAtIndex:checkPosition] != AGX_CODE93_ALPHABET[total % 47]) {
        if (error) *error = AGXChecksumErrorInstance();
        return NO;
    }
    return YES;
}

@end
