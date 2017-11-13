//
//  AGXQRCodeFinderPatternFinder.m
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
#import <AGXCore/AGXCore/AGXMath.h>
#import "AGXQRCodeFinderPatternFinder.h"
#import "AGXGcodeError.h"

const int AGX_CENTER_QUORUM = 2;
const int AGX_FINDER_PATTERN_MIN_SKIP = 3;
const int AGX_FINDER_PATTERN_MAX_MODULES = 57;

@implementation AGXQRCodeFinderPatternFinder {
    BOOL _hasSkipped;
    NSMutableArray *_possibleCenters;
}

+ (AGX_INSTANCETYPE)finderPatternFinderWithBits:(AGXBitMatrix *)bits {
    return AGX_AUTORELEASE([[AGXQRCodeFinderPatternFinder alloc] initWithBits:bits]);
}

- (AGX_INSTANCETYPE)initWithBits:(AGXBitMatrix *)bits {
    if AGX_EXPECT_T(self = [super init]) {
        _bits = AGX_RETAIN(bits);
        _possibleCenters = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)dealloc {
    AGX_RELEASE(_bits);
    AGX_RELEASE(_possibleCenters);
    AGX_SUPER_DEALLOC;
}

- (AGXQRCodeFinderPatternInfo *)find:(AGXDecodeHints *)hints error:(NSError **)error {
    int maxI = _bits.height;
    int maxJ = _bits.width;
    int iSkip = MAX((3 * maxI) / (4 * AGX_FINDER_PATTERN_MAX_MODULES), AGX_FINDER_PATTERN_MIN_SKIP);

    BOOL done = NO;
    int stateCount[5];
    for (int i = iSkip - 1; i < maxI && !done; i += iSkip) {
        stateCount[0] = 0;
        stateCount[1] = 0;
        stateCount[2] = 0;
        stateCount[3] = 0;
        stateCount[4] = 0;
        int currentState = 0;

        for (int j = 0; j < maxJ; j++) {
            if ([_bits getX:j y:i]) {
                if ((currentState & 1) == 1) {
                    currentState++;
                }
                stateCount[currentState]++;
            } else {
                if ((currentState & 1) == 0) {
                    if (currentState == 4) {
                        if (foundPatternCross(stateCount)) {
                            BOOL confirmed = [self handlePossibleCenter:stateCount i:i j:j];
                            if (confirmed) {
                                iSkip = 2;
                                if (_hasSkipped) {
                                    done = [self haveMultiplyConfirmedCenters];
                                } else {
                                    int rowSkip = [self findRowSkip];
                                    if (rowSkip > stateCount[2]) {
                                        i += rowSkip - stateCount[2] - iSkip;
                                        j = maxJ - 1;
                                    }
                                }
                            } else {
                                stateCount[0] = stateCount[2];
                                stateCount[1] = stateCount[3];
                                stateCount[2] = stateCount[4];
                                stateCount[3] = 1;
                                stateCount[4] = 0;
                                currentState = 3;
                                continue;
                            }
                            currentState = 0;
                            stateCount[0] = 0;
                            stateCount[1] = 0;
                            stateCount[2] = 0;
                            stateCount[3] = 0;
                            stateCount[4] = 0;
                        } else {
                            stateCount[0] = stateCount[2];
                            stateCount[1] = stateCount[3];
                            stateCount[2] = stateCount[4];
                            stateCount[3] = 1;
                            stateCount[4] = 0;
                            currentState = 3;
                        }
                    } else {
                        stateCount[++currentState]++;
                    }
                } else {
                    stateCount[currentState]++;
                }
            }
        }
        
        if (foundPatternCross(stateCount)) {
            BOOL confirmed = [self handlePossibleCenter:stateCount i:i j:maxJ];
            if (confirmed) {
                iSkip = stateCount[0];
                if (_hasSkipped) {
                    done = [self haveMultiplyConfirmedCenters];
                }
            }
        }
    }

    NSMutableArray *patternInfo = [self selectBestPatterns];
    if AGX_EXPECT_F(!patternInfo) {
        if AGX_EXPECT_T(error) *error = AGXNotFoundErrorInstance();
        return nil;
    }
    orderBestPatterns(patternInfo);
    return [AGXQRCodeFinderPatternInfo finderPatternInfoWithPatternCenters:patternInfo];
}

- (BOOL)handlePossibleCenter:(const int[])stateCount i:(int)i j:(int)j {
    int stateCountTotal = stateCount[0] + stateCount[1] + stateCount[2] + stateCount[3] + stateCount[4];
    float centerJ = [self centerFromEnd:stateCount end:j];
    float centerI = [self crossCheckVertical:i centerJ:(int)centerJ maxCount:stateCount[2] originalStateCountTotal:stateCountTotal];
    if (!isnan(centerI)) {
        centerJ = [self crossCheckHorizontal:(int)centerJ centerI:(int)centerI maxCount:stateCount[2] originalStateCountTotal:stateCountTotal];
        if (!isnan(centerJ) &&
            ([self crossCheckDiagonal:(int)centerI centerJ:(int) centerJ maxCount:stateCount[2] originalStateCountTotal:stateCountTotal])) {
            float estimatedModuleSize = (float)stateCountTotal / 7.0f;
            BOOL found = NO;
            int max = (int)[_possibleCenters count];
            for (int index = 0; index < max; index++) {
                AGXQRCodeFinderPattern *center = _possibleCenters[index];
                if ([center aboutEquals:estimatedModuleSize i:centerI j:centerJ]) {
                    _possibleCenters[index] = [center combineEstimateI:centerI j:centerJ newModuleSize:estimatedModuleSize];
                    found = YES;
                    break;
                }
            }

            if (!found) {
                [_possibleCenters addObject:[AGXQRCodeFinderPattern finderPatternWithX:centerJ y:centerI
                                                                   estimatedModuleSize:estimatedModuleSize]];
            }
            return YES;
        }
    }
    return NO;
}

- (float)centerFromEnd:(const int[])stateCount end:(int)end {
    return (float)(end - stateCount[4] - stateCount[3]) - stateCount[2] / 2.0f;
}

- (float)crossCheckVertical:(int)startI centerJ:(int)centerJ maxCount:(int)maxCount originalStateCountTotal:(int)originalStateCountTotal {
    int maxI = _bits.height;
    int stateCount[5] = {0, 0, 0, 0, 0};

    int i = startI;
    while (i >= 0 && [_bits getX:centerJ y:i]) {
        stateCount[2]++;
        i--;
    }
    if (i < 0) {
        return NAN;
    }
    while (i >= 0 && ![_bits getX:centerJ y:i] && stateCount[1] <= maxCount) {
        stateCount[1]++;
        i--;
    }
    if (i < 0 || stateCount[1] > maxCount) {
        return NAN;
    }
    while (i >= 0 && [_bits getX:centerJ y:i] && stateCount[0] <= maxCount) {
        stateCount[0]++;
        i--;
    }
    if (stateCount[0] > maxCount) {
        return NAN;
    }

    i = startI + 1;
    while (i < maxI && [_bits getX:centerJ y:i]) {
        stateCount[2]++;
        i++;
    }
    if (i == maxI) {
        return NAN;
    }
    while (i < maxI && ![_bits getX:centerJ y:i] && stateCount[3] < maxCount) {
        stateCount[3]++;
        i++;
    }
    if (i == maxI || stateCount[3] >= maxCount) {
        return NAN;
    }
    while (i < maxI && [_bits getX:centerJ y:i] && stateCount[4] < maxCount) {
        stateCount[4]++;
        i++;
    }
    if (stateCount[4] >= maxCount) {
        return NAN;
    }

    int stateCountTotal = stateCount[0] + stateCount[1] + stateCount[2] + stateCount[3] + stateCount[4];
    if (5 * abs(stateCountTotal - originalStateCountTotal) >= 2 * originalStateCountTotal) {
        return NAN;
    }
    return foundPatternCross(stateCount) ? [self centerFromEnd:stateCount end:i] : NAN;
}

- (float)crossCheckHorizontal:(int)startJ centerI:(int)centerI maxCount:(int)maxCount originalStateCountTotal:(int)originalStateCountTotal {
    int maxJ = _bits.width;
    int stateCount[5] = {0, 0, 0, 0, 0};

    int j = startJ;
    while (j >= 0 && [_bits getX:j y:centerI]) {
        stateCount[2]++;
        j--;
    }
    if (j < 0) {
        return NAN;
    }
    while (j >= 0 && ![_bits getX:j y:centerI] && stateCount[1] <= maxCount) {
        stateCount[1]++;
        j--;
    }
    if (j < 0 || stateCount[1] > maxCount) {
        return NAN;
    }
    while (j >= 0 && [_bits getX:j y:centerI] && stateCount[0] <= maxCount) {
        stateCount[0]++;
        j--;
    }
    if (stateCount[0] > maxCount) {
        return NAN;
    }

    j = startJ + 1;
    while (j < maxJ && [_bits getX:j y:centerI]) {
        stateCount[2]++;
        j++;
    }
    if (j == maxJ) {
        return NAN;
    }
    while (j < maxJ && ![_bits getX:j y:centerI] && stateCount[3] < maxCount) {
        stateCount[3]++;
        j++;
    }
    if (j == maxJ || stateCount[3] >= maxCount) {
        return NAN;
    }
    while (j < maxJ && [_bits getX:j y:centerI] && stateCount[4] < maxCount) {
        stateCount[4]++;
        j++;
    }
    if (stateCount[4] >= maxCount) {
        return NAN;
    }

    int stateCountTotal = stateCount[0] + stateCount[1] + stateCount[2] + stateCount[3] + stateCount[4];
    if (5 * abs(stateCountTotal - originalStateCountTotal) >= originalStateCountTotal) {
        return NAN;
    }
    return foundPatternCross(stateCount) ? [self centerFromEnd:stateCount end:j] : NAN;
}

- (BOOL)crossCheckDiagonal:(int)startI centerJ:(int)centerJ maxCount:(int)maxCount originalStateCountTotal:(int)originalStateCountTotal {
    int stateCount[5] = {0, 0, 0, 0, 0};

    // Start counting up, left from center finding black center mass
    int i = 0;
    while (startI >= i && centerJ >= i && [_bits getX:centerJ - i y:startI - i]) {
        stateCount[2]++;
        i++;
    }
    if (startI < i || centerJ < i) {
        return NO;
    }
    // Continue up, left finding white space
    while (startI >= i && centerJ >= i && ![_bits getX:centerJ - i y:startI - i] &&
           stateCount[1] <= maxCount) {
        stateCount[1]++;
        i++;
    }
    // If already too many modules in this state or ran off the edge:
    if (startI < i || centerJ < i || stateCount[1] > maxCount) {
        return NO;
    }
    // Continue up, left finding black border
    while (startI >= i && centerJ >= i && [_bits getX:centerJ - i y:startI - i] &&
           stateCount[0] <= maxCount) {
        stateCount[0]++;
        i++;
    }
    if (stateCount[0] > maxCount) {
        return NO;
    }
    int maxI = _bits.height;
    int maxJ = _bits.width;
    // Now also count down, right from center
    i = 1;
    while (startI + i < maxI && centerJ + i < maxJ && [_bits getX:centerJ + i y:startI + i]) {
        stateCount[2]++;
        i++;
    }
    // Ran off the edge?
    if (startI + i >= maxI || centerJ + i >= maxJ) {
        return NO;
    }
    while (startI + i < maxI && centerJ + i < maxJ && ![_bits getX:centerJ + i y:startI + i] &&
           stateCount[3] < maxCount) {
        stateCount[3]++;
        i++;
    }
    if (startI + i >= maxI || centerJ + i >= maxJ || stateCount[3] >= maxCount) {
        return NO;
    }
    while (startI + i < maxI && centerJ + i < maxJ && [_bits getX:centerJ + i y:startI + i] &&
           stateCount[4] < maxCount) {
        stateCount[4]++;
        i++;
    }
    if (stateCount[4] >= maxCount) {
        return NO;
    }

    // If we found a finder-pattern-like section, but its size is more than 100% different than
    // the original, assume it's a false positive
    int stateCountTotal = stateCount[0] + stateCount[1] + stateCount[2] + stateCount[3] + stateCount[4];
    return abs(stateCountTotal - originalStateCountTotal) < 2 * originalStateCountTotal && foundPatternCross(stateCount);
}

- (BOOL)haveMultiplyConfirmedCenters {
    int confirmedCount = 0;
    float totalModuleSize = 0.0f;
    int max = (int)[_possibleCenters count];
    for (int i = 0; i < max; i++) {
        AGXQRCodeFinderPattern *pattern = _possibleCenters[i];
        if ([pattern count] >= AGX_CENTER_QUORUM) {
            confirmedCount++;
            totalModuleSize += [pattern estimatedModuleSize];
        }
    }
    if (confirmedCount < 3) return NO;

    float average = totalModuleSize / (float)max;
    float totalDeviation = 0.0f;
    for (int i = 0; i < max; i++) {
        AGXQRCodeFinderPattern *pattern = _possibleCenters[i];
        totalDeviation += fabsf([pattern estimatedModuleSize] - average);
    }
    return totalDeviation <= 0.05f * totalModuleSize;
}

- (int)findRowSkip {
    int max = (int)[_possibleCenters count];
    if (max <= 1) return 0;

    AGXQRCodeFinderPattern *firstConfirmedCenter = nil;
    for (int i = 0; i < max; i++) {
        AGXQRCodeFinderPattern *center = _possibleCenters[i];
        if ([center count] >= AGX_CENTER_QUORUM) {
            if (firstConfirmedCenter == nil) {
                firstConfirmedCenter = center;
            } else {
                _hasSkipped = YES;
                return (int)(cgfabs(firstConfirmedCenter.point.x - center.point.x) - cgfabs(firstConfirmedCenter.point.y - center.point.y)) / 2;
            }
        }
    }
    return 0;
}

- (NSMutableArray *)selectBestPatterns {
    int startSize = (int)[_possibleCenters count];
    if (startSize < 3) return nil;

    if (startSize > 3) {
        float totalModuleSize = 0.0f;
        float square = 0.0f;
        for (int i = 0; i < startSize; i++) {
            float size = [_possibleCenters[i] estimatedModuleSize];
            totalModuleSize += size;
            square += size * size;
        }
        float average = totalModuleSize / (float)startSize;
        float stdDev = (float)sqrt(square / startSize - average * average);

        [_possibleCenters sortUsingFunction:furthestFromAverageCompare context:(AGX_BRIDGE void *)@(average)];

        float limit = MAX(0.2f * average, stdDev);

        for (int i = 0; i < [_possibleCenters count] && [_possibleCenters count] > 3; i++) {
            AGXQRCodeFinderPattern *pattern = _possibleCenters[i];
            if (fabsf([pattern estimatedModuleSize] - average) > limit) {
                [_possibleCenters removeObjectAtIndex:i];
                i--;
            }
        }
    }

    if ([_possibleCenters count] > 3) {
        float totalModuleSize = 0.0f;
        for (int i = 0; i < [_possibleCenters count]; i++) {
            totalModuleSize += [_possibleCenters[i] estimatedModuleSize];
        }

        float average = totalModuleSize / (float)[_possibleCenters count];

        [_possibleCenters sortUsingFunction:centerCompare context:(AGX_BRIDGE void *)@(average)];

        NSMutableArray *temp = [[NSMutableArray alloc] initWithArray:
                                [_possibleCenters subarrayWithRange:NSMakeRange(0, 3)]];
        AGX_RELEASE(_possibleCenters);
        _possibleCenters = temp;
    }
    
    return [NSMutableArray arrayWithObjects:_possibleCenters[0], _possibleCenters[1], _possibleCenters[2], nil];
}

AGX_STATIC BOOL foundPatternCross(const int stateCount[]) {
    int totalModuleSize = 0;
    for (int i = 0; i < 5; i++) {
        int count = stateCount[i];
        if (count == 0) return NO;
        totalModuleSize += count;
    }
    if (totalModuleSize < 7) return NO;

    float moduleSize = totalModuleSize / 7.0f;
    float maxVariance = moduleSize / 2.0f;
    // Allow less than 50% variance from 1-1-3-1-1 proportions
    return(ABS(moduleSize - stateCount[0]) < maxVariance &&
           ABS(moduleSize - stateCount[1]) < maxVariance &&
           ABS(3.0f * moduleSize - stateCount[2]) < 3 * maxVariance &&
           ABS(moduleSize - stateCount[3]) < maxVariance &&
           ABS(moduleSize - stateCount[4]) < maxVariance);
}

AGX_STATIC NSInteger furthestFromAverageCompare(id center1, id center2, void *context) {
    float average = [(AGX_BRIDGE NSNumber *)context floatValue];

    float dA = fabsf([((AGXQRCodeFinderPattern *)center2) estimatedModuleSize] - average);
    float dB = fabsf([((AGXQRCodeFinderPattern *)center1) estimatedModuleSize] - average);
    return dA < dB ? -1 : dA == dB ? 0 : 1;
}

AGX_STATIC NSInteger centerCompare(id center1, id center2, void *context) {
    float average = [(AGX_BRIDGE NSNumber *)context floatValue];

    if ([((AGXQRCodeFinderPattern *)center2) count] == [((AGXQRCodeFinderPattern *)center1) count]) {
        float dA = fabsf([((AGXQRCodeFinderPattern *)center2) estimatedModuleSize] - average);
        float dB = fabsf([((AGXQRCodeFinderPattern *)center1) estimatedModuleSize] - average);
        return dA < dB ? 1 : dA == dB ? 0 : -1;
    } else {
        return [((AGXQRCodeFinderPattern *)center2) count] - [((AGXQRCodeFinderPattern *)center1) count];
    }
}

AGX_STATIC void orderBestPatterns(NSMutableArray *patterns) {
    float zeroOneDistance = distance([patterns[0] point], [patterns[1] point]);
    float oneTwoDistance = distance([patterns[1] point], [patterns[2] point]);
    float zeroTwoDistance = distance([patterns[0] point], [patterns[2] point]);
    AGXQRCodeFinderPattern *pointA;
    AGXQRCodeFinderPattern *pointB;
    AGXQRCodeFinderPattern *pointC;
    if (oneTwoDistance >= zeroOneDistance && oneTwoDistance >= zeroTwoDistance) {
        pointB = patterns[0];
        pointA = patterns[1];
        pointC = patterns[2];
    } else if (zeroTwoDistance >= oneTwoDistance && zeroTwoDistance >= zeroOneDistance) {
        pointB = patterns[1];
        pointA = patterns[0];
        pointC = patterns[2];
    } else {
        pointB = patterns[2];
        pointA = patterns[0];
        pointC = patterns[1];
    }

    if (crossProductZ(pointA, pointB, pointC) < 0.0f) {
        AGXQRCodeFinderPattern *temp = pointA;
        pointA = pointC;
        pointC = temp;
    }
    patterns[0] = pointA;
    patterns[1] = pointB;
    patterns[2] = pointC;
}

AGX_STATIC float distance(CGPoint point1, CGPoint point2) {
    float xDiff = point1.x - point2.x;
    float yDiff = point1.y - point2.y;
    return sqrtf(xDiff * xDiff + yDiff * yDiff);
}

AGX_STATIC float crossProductZ(AGXQRCodeFinderPattern *pointA, AGXQRCodeFinderPattern *pointB, AGXQRCodeFinderPattern *pointC) {
    float bX = pointB.point.x;
    float bY = pointB.point.y;
    return ((pointC.point.x - bX) * (pointA.point.y - bY)) - ((pointC.point.y - bY) * (pointA.point.x - bX));
}

@end
