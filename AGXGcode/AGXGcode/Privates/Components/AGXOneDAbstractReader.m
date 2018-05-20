//
//  AGXOneDAbstractReader.m
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

#import "AGXOneDAbstractReader.h"
#import "AGXGcodeError.h"
#import "UIImage+AGXGcode.h"

@implementation AGXOneDAbstractReader

- (AGXGcodeResult *)decode:(UIImage *)image hints:(AGXDecodeHints *)hints error:(NSError **)error {
    NSError *decodeError = nil;
    AGXBinaryBitmap *bitmap = image.AGXBinaryBitmap;
    AGXGcodeResult *result = [self doDecode:bitmap hints:hints error:&decodeError];
    if (result) {
        return result;
    } else if (decodeError.code == AGXNotFoundError) {
        AGXBinaryBitmap *rotatedImage = bitmap.rotateCounterClockwise;
        result = [self doDecode:rotatedImage hints:hints error:error];
        if AGX_EXPECT_T(result) return result;
    }
    
    if AGX_EXPECT_T(error) *error = decodeError;
    return nil;
}

- (void)reset {}

- (AGXGcodeResult *)doDecode:(AGXBinaryBitmap *)bitmap hints:(AGXDecodeHints *)hints error:(NSError **)error {
    int width = bitmap.width;
    int height = bitmap.height;
    AGXBitArray *row = [AGXBitArray bitArrayWithSize:width];
    int middle = height >> 1;
    int rowStep = MAX(1, height >> 5);
    int maxLines = 15;

    for (int x = 0; x < maxLines; x++) {
        int rowStepsAboveOrBelow = (x + 1) / 2;
        BOOL isAbove = (x & 0x01) == 0;
        int rowNumber = middle + rowStep * (isAbove ? rowStepsAboveOrBelow : -rowStepsAboveOrBelow);
        if (rowNumber < 0 || rowNumber >= height) break;

        NSError *rowError = nil;
        row = [bitmap blackRow:rowNumber row:row error:&rowError];
        if (!row && rowError.code == AGXNotFoundError) {
            continue;
        } else if (!row) {
            if AGX_EXPECT_T(error) *error = rowError;
            return nil;
        }

        AGXGcodeResult *result = [self decodeRow:rowNumber row:row hints:hints error:nil];
        if (result) return result;

        [row reverse];
        result = [self decodeRow:rowNumber row:row hints:hints error:nil];
        if AGX_EXPECT_T(result) return result;
    }
    
    if AGX_EXPECT_T(error) *error = AGXNotFoundErrorInstance();
    return nil;
}

- (AGXGcodeResult *)decodeRow:(int)rowNumber row:(AGXBitArray *)row hints:(AGXDecodeHints *)hints error:(NSError **)error {
    @throw [NSException exceptionWithName:NSInternalInconsistencyException reason:[NSString stringWithFormat:@"You must override %@ in a subclass", NSStringFromSelector(_cmd)] userInfo:nil];
}

@end

BOOL recordPattern(AGXBitArray *row, int start, AGXIntArray *counters) {
    int numCounters = counters.length;
    [counters clear];
    int32_t *array = counters.array;
    int end = row.size;
    if AGX_EXPECT_F(start >= end) return NO;

    BOOL isWhite = ![row get:start];
    int counterPosition = 0;
    int i = start;

    while (i < end) {
        if ([row get:i] ^ isWhite) {
            array[counterPosition]++;
        } else {
            counterPosition++;
            if (counterPosition == numCounters) {
                break;
            } else {
                array[counterPosition] = 1;
                isWhite = !isWhite;
            }
        }
        i++;
    }

    return(counterPosition == numCounters || (counterPosition == numCounters - 1 && i == end));
}

BOOL recordPatternInReverse(AGXBitArray *row, int start, AGXIntArray *counters) {
    int numTransitionsLeft = counters.length;
    BOOL last = [row get:start];
    while (start > 0 && numTransitionsLeft >= 0) {
        if ([row get:--start] != last) {
            numTransitionsLeft--;
            last = !last;
        }
    }

    return(!(numTransitionsLeft >= 0 || !recordPattern(row, start + 1, counters)));
}

float patternMatchVariance(AGXIntArray *counters, const int pattern[], float maxIndividualVariance) {
    int numCounters = counters.length;
    int total = 0;
    int patternLength = 0;

    int32_t *array = counters.array;
    for (int i = 0; i < numCounters; i++) {
        total += array[i];
        patternLength += pattern[i];
    }
    if (total < patternLength || patternLength == 0) return FLT_MAX;

    float unitBarWidth = (float) total / patternLength;
    maxIndividualVariance *= unitBarWidth;

    float totalVariance = 0.0f;
    for (int x = 0; x < numCounters; x++) {
        int counter = array[x];
        float scaledPattern = pattern[x] * unitBarWidth;
        float variance = counter > scaledPattern ? counter - scaledPattern : scaledPattern - counter;
        if (variance > maxIndividualVariance) return FLT_MAX;
        totalVariance += variance;
    }

    return totalVariance / total;
}
