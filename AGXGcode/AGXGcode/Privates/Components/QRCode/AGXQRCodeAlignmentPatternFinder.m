//
//  AGXQRCodeAlignmentPatternFinder.m
//  AGXGcode
//
//  Created by Char Aznable on 16/8/5.
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
#import "AGXQRCodeAlignmentPatternFinder.h"
#import "AGXGcodeError.h"

@implementation AGXQRCodeAlignmentPatternFinder {
    AGXBitMatrix *_bits;
    NSMutableArray *_possibleCenters;
    int _startX;
    int _startY;
    int _width;
    int _height;
    float _moduleSize;
    AGXIntArray *_crossCheckStateCount;
}

+ (AGX_INSTANCETYPE)alignmentPatternFinderWithBits:(AGXBitMatrix *)bits startX:(int)startX startY:(int)startY width:(int)width height:(int)height moduleSize:(float)moduleSize {
    return AGX_AUTORELEASE([[self alloc] initWithBits:bits startX:startX startY:startY width:width height:height moduleSize:moduleSize]);
}

- (AGX_INSTANCETYPE)initWithBits:(AGXBitMatrix *)bits startX:(int)startX startY:(int)startY width:(int)width height:(int)height moduleSize:(float)moduleSize {
    if AGX_EXPECT_T(self = [super init]) {
        _bits = AGX_RETAIN(bits);
        _possibleCenters = [[NSMutableArray alloc] initWithCapacity:5];
        _startX = startX;
        _startY = startY;
        _width = width;
        _height = height;
        _moduleSize = moduleSize;
        _crossCheckStateCount = [[AGXIntArray alloc] initWithLength:3];
    }
    return self;
}

- (void)dealloc {
    AGX_RELEASE(_bits);
    AGX_RELEASE(_possibleCenters);
    AGX_RELEASE(_crossCheckStateCount);
    AGX_SUPER_DEALLOC;
}

- (AGXQRCodeAlignmentPattern *)findWithError:(NSError **)error {
    int maxJ = _startX + _width;
    int middleI = _startY + (_height / 2);
    int stateCount[3];

    for (int iGen = 0; iGen < _height; iGen++) {
        int i = middleI + ((iGen & 0x01) == 0 ? (iGen + 1) / 2 : -((iGen + 1) / 2));
        stateCount[0] = 0;
        stateCount[1] = 0;
        stateCount[2] = 0;
        int j = _startX;

        while (j < maxJ && ![_bits getX:j y:i]) {
            j++;
        }

        int currentState = 0;

        while (j < maxJ) {
            if ([_bits getX:j y:i]) {
                if (currentState == 1) {
                    stateCount[currentState]++;
                } else {
                    if (currentState == 2) {
                        if ([self foundPatternCross:stateCount]) {
                            AGXQRCodeAlignmentPattern *confirmed = [self handlePossibleCenter:stateCount i:i j:j];
                            if AGX_EXPECT_T(confirmed != nil) return confirmed;

                        }
                        stateCount[0] = stateCount[2];
                        stateCount[1] = 1;
                        stateCount[2] = 0;
                        currentState = 1;
                    } else {
                        stateCount[++currentState]++;
                    }
                }
            } else {
                if (currentState == 1) {
                    currentState++;
                }
                stateCount[currentState]++;
            }
            j++;
        }
        
        if ([self foundPatternCross:stateCount]) {
            AGXQRCodeAlignmentPattern *confirmed = [self handlePossibleCenter:stateCount i:i j:maxJ];
            if AGX_EXPECT_T(confirmed != nil) return confirmed;
        }
    }
    
    if AGX_EXPECT_T([_possibleCenters count] > 0) {
        return _possibleCenters[0];
    }
    if AGX_EXPECT_T(error) *error = AGXNotFoundErrorInstance();
    return nil;
}

- (BOOL)foundPatternCross:(int *)stateCount {
    float maxVariance = _moduleSize / 2.0f;
    for (int i = 0; i < 3; i++) {
        if (fabsf(_moduleSize - stateCount[i]) >= maxVariance) {
            return NO;
        }
    }
    return YES;
}

- (AGXQRCodeAlignmentPattern *)handlePossibleCenter:(int *)stateCount i:(int)i j:(int)j {
    int stateCountTotal = stateCount[0] + stateCount[1] + stateCount[2];
    float centerJ = [self centerFromEnd:stateCount end:j];
    float centerI = [self crossCheckVertical:i centerJ:(int)centerJ maxCount:2 * stateCount[1] originalStateCountTotal:stateCountTotal];
    if (!isnan(centerI)) {
        float estimatedModuleSize = (float)(stateCount[0] + stateCount[1] + stateCount[2]) / 3.0f;
        int max = (int)_possibleCenters.count;

        for (int index = 0; index < max; index++) {
            AGXQRCodeAlignmentPattern *center = _possibleCenters[index];
            // Look for about the same center and module size:
            if ([center aboutEquals:estimatedModuleSize i:centerI j:centerJ]) {
                return [center combineEstimateI:centerI j:centerJ newModuleSize:estimatedModuleSize];
            }
        }
        // Hadn't found this before; save it
        AGXQRCodeAlignmentPattern *point = [AGXQRCodeAlignmentPattern alignmentPatternWithX:centerJ y:centerI estimatedModuleSize:estimatedModuleSize];
        [_possibleCenters addObject:point];
    }
    return nil;
}

- (float)centerFromEnd:(int *)stateCount end:(int)end {
    return (float)(end - stateCount[2]) - stateCount[1] / 2.0f;
}

- (float)crossCheckVertical:(int)startI centerJ:(int)centerJ maxCount:(int)maxCount originalStateCountTotal:(int)originalStateCountTotal {
    int maxI = _bits.height;
    [_crossCheckStateCount clear];
    int32_t *stateCount = _crossCheckStateCount.array;

    int i = startI;
    while (i >= 0 && [_bits getX:centerJ y:i] && stateCount[1] <= maxCount) {
        stateCount[1]++;
        i--;
    }
    if (i < 0 || stateCount[1] > maxCount) {
        return NAN;
    }
    while (i >= 0 && ![_bits getX:centerJ y:i] && stateCount[0] <= maxCount) {
        stateCount[0]++;
        i--;
    }
    if (stateCount[0] > maxCount) {
        return NAN;
    }
    i = startI + 1;
    while (i < maxI && [_bits getX:centerJ y:i] && stateCount[1] <= maxCount) {
        stateCount[1]++;
        i++;
    }
    if (i == maxI || stateCount[1] > maxCount) {
        return NAN;
    }
    while (i < maxI && ![_bits getX:centerJ y:i] && stateCount[2] <= maxCount) {
        stateCount[2]++;
        i++;
    }
    if (stateCount[2] > maxCount) {
        return NAN;
    }
    int stateCountTotal = stateCount[0] + stateCount[1] + stateCount[2];
    if (5 * abs(stateCountTotal - originalStateCountTotal) >= 2 * originalStateCountTotal) {
        return NAN;
    }
    return [self foundPatternCross:stateCount] ? [self centerFromEnd:stateCount end:i] : NAN;
}

@end
