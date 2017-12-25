//
//  AGXQRCodeDetector.m
//  AGXGcode
//
//  Created by Char Aznable on 2016/8/4.
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
#import "AGXQRCodeDetector.h"
#import "AGXGcodeError.h"
#import "AGXQRCodeFinderPatternInfo.h"
#import "AGXQRCodeFinderPatternFinder.h"
#import "AGXQRCodeVersion.h"
#import "AGXQRCodeAlignmentPatternFinder.h"
#import "AGXPerspectiveTransform.h"
#import "AGXGridSampler.h"

@implementation AGXQRCodeDetector

+ (AGX_INSTANCETYPE)detectorWithBits:(AGXBitMatrix *)bits {
    return AGX_AUTORELEASE([[AGXQRCodeDetector alloc] initWithBits:bits]);
}

- (AGX_INSTANCETYPE)initWithBits:(AGXBitMatrix *)bits {
    if AGX_EXPECT_T(self = [super init]) {
        _bits = AGX_RETAIN(bits);
    }
    return self;
}

- (void)dealloc {
    AGX_RELEASE(_bits);
    AGX_SUPER_DEALLOC;
}

- (AGXDetectorResult *)detect:(AGXDecodeHints *)hints error:(NSError **)error {
    AGXQRCodeFinderPatternInfo *info = [[AGXQRCodeFinderPatternFinder finderPatternFinderWithBits:_bits] find:hints error:error];
    if AGX_EXPECT_F(!info) return nil;

    return [self processFinderPatternInfo:info error:error];
}

- (AGXDetectorResult *)processFinderPatternInfo:(AGXQRCodeFinderPatternInfo *)info error:(NSError **)error {
    AGXQRCodeFinderPattern *topLeft = info.topLeft;
    AGXQRCodeFinderPattern *topRight = info.topRight;
    AGXQRCodeFinderPattern *bottomLeft = info.bottomLeft;

    float moduleSize = [self calculateModuleSize:topLeft topRight:topRight bottomLeft:bottomLeft];
    if AGX_EXPECT_F(moduleSize < 1.0f) {
        if AGX_EXPECT_T(error) *error = AGXNotFoundErrorInstance();
        return nil;
    }
    int dimension = computeDimension(topLeft, topRight, bottomLeft, moduleSize, error);
    if AGX_EXPECT_F(dimension == -1) return nil;

    AGXQRCodeVersion *provisionalVersion = [AGXQRCodeVersion provisionalVersionForDimension:dimension];
    if AGX_EXPECT_F(!provisionalVersion) {
        if AGX_EXPECT_T(error) *error = AGXFormatErrorInstance();
        return nil;
    }
    int modulesBetweenFPCenters = [provisionalVersion dimensionForVersion] - 7;

    AGXQRCodeAlignmentPattern *alignmentPattern = nil;
    if (provisionalVersion.alignmentPatternCenters.length > 0) {
        float bottomRightX = topRight.point.x - topLeft.point.x + bottomLeft.point.x;
        float bottomRightY = topRight.point.y - topLeft.point.y + bottomLeft.point.y;

        float correctionToTopLeft = 1.0f - 3.0f / (float)modulesBetweenFPCenters;
        int estAlignmentX = (int)(topLeft.point.x + correctionToTopLeft * (bottomRightX - topLeft.point.x));
        int estAlignmentY = (int)(topLeft.point.y + correctionToTopLeft * (bottomRightY - topLeft.point.y));

        for (int i = 4; i <= 16; i <<= 1) {
            NSError *alignmentError = nil;
            alignmentPattern = [self findAlignmentInRegion:moduleSize estAlignmentX:estAlignmentX estAlignmentY:estAlignmentY allowanceFactor:(float)i error:&alignmentError];
            if (alignmentPattern) {
                break;
            } else if AGX_EXPECT_F(alignmentError.code != AGXNotFoundError) {
                if AGX_EXPECT_T(error) *error = alignmentError;
                return nil;
            }
        }
    }

    AGXPerspectiveTransform *transform = [AGXQRCodeDetector createTransform:topLeft topRight:topRight bottomLeft:bottomLeft alignmentPattern:alignmentPattern dimension:dimension];
    AGXBitMatrix *bits = [self sampleGrid:_bits transform:transform dimension:dimension error:error];
    if AGX_EXPECT_F(!bits) return nil;

    return [AGXDetectorResult detectorResultWithBits:bits];
}

- (float)calculateModuleSize:(AGXQRCodeFinderPattern *)topLeft topRight:(AGXQRCodeFinderPattern *)topRight bottomLeft:(AGXQRCodeFinderPattern *)bottomLeft {
    return ([self calculateModuleSizeOneWay:topLeft otherPattern:topRight] + [self calculateModuleSizeOneWay:topLeft otherPattern:bottomLeft]) / 2.0f;
}

- (float)calculateModuleSizeOneWay:(AGXQRCodeFinderPattern *)pattern otherPattern:(AGXQRCodeFinderPattern *)otherPattern {
    float moduleSizeEst1 = [self sizeOfBlackWhiteBlackRunBothWays:(int)pattern.point.x fromY:(int)pattern.point.y toX:(int)otherPattern.point.x toY:(int)otherPattern.point.y];
    float moduleSizeEst2 = [self sizeOfBlackWhiteBlackRunBothWays:(int)otherPattern.point.x fromY:(int)otherPattern.point.y toX:(int)pattern.point.x toY:(int)pattern.point.y];
    if (isnan(moduleSizeEst1)) return moduleSizeEst2 / 7.0f;
    if (isnan(moduleSizeEst2)) return moduleSizeEst1 / 7.0f;
    return (moduleSizeEst1 + moduleSizeEst2) / 14.0f;
}

- (float)sizeOfBlackWhiteBlackRunBothWays:(int)fromX fromY:(int)fromY toX:(int)toX toY:(int)toY {
    float result = [self sizeOfBlackWhiteBlackRun:fromX fromY:fromY toX:toX toY:toY];

    // Now count other way -- don't run off image though of course
    float scale = 1.0f;
    int otherToX = fromX - (toX - fromX);
    if (otherToX < 0) {
        scale = (float)fromX / (float)(fromX - otherToX);
        otherToX = 0;
    } else if (otherToX >= _bits.width) {
        scale = (float)(_bits.width - 1 - fromX) / (float)(otherToX - fromX);
        otherToX = _bits.width - 1;
    }
    int otherToY = (int)(fromY - (toY - fromY) * scale);

    scale = 1.0f;
    if (otherToY < 0) {
        scale = (float)fromY / (float)(fromY - otherToY);
        otherToY = 0;
    } else if (otherToY >= _bits.height) {
        scale = (float)(_bits.height - 1 - fromY) / (float)(otherToY - fromY);
        otherToY = _bits.height - 1;
    }
    otherToX = (int)(fromX + (otherToX - fromX) * scale);

    result += [self sizeOfBlackWhiteBlackRun:fromX fromY:fromY toX:otherToX toY:otherToY];

    // Middle pixel is double-counted this way; subtract 1
    return result - 1.0f;
}

- (float)sizeOfBlackWhiteBlackRun:(int)fromX fromY:(int)fromY toX:(int)toX toY:(int)toY {
    // Mild variant of Bresenham's algorithm;
    // see http://en.wikipedia.org/wiki/Bresenham's_line_algorithm
    BOOL steep = abs(toY - fromY) > abs(toX - fromX);
    if (steep) {
        int temp = fromX;
        fromX = fromY;
        fromY = temp;
        temp = toX;
        toX = toY;
        toY = temp;
    }

    int dx = abs(toX - fromX);
    int dy = abs(toY - fromY);
    int error = -dx / 2;
    int xstep = fromX < toX ? 1 : -1;
    int ystep = fromY < toY ? 1 : -1;

    // In black pixels, looking for white, first or second time.
    int state = 0;
    // Loop up until x == toX, but not beyond
    int xLimit = toX + xstep;
    for (int x = fromX, y = fromY; x != xLimit; x += xstep) {
        int realX = steep ? y : x;
        int realY = steep ? x : y;

        // Does current pixel mean we have moved white to black or vice versa?
        // Scanning black in state 0,2 and white in state 1, so if we find the wrong
        // color, advance to next state or end if we are in state 2 already
        if ((state == 1) == [_bits getX:realX y:realY]) {
            if (state == 2) {
                return distanceInt(x, y, fromX, fromY);
            }
            state++;
        }

        error += dy;
        if (error > 0) {
            if (y == toY) {
                break;
            }
            y += ystep;
            error -= dx;
        }
    }
    // Found black-white-black; give the benefit of the doubt that the next pixel outside the image
    // is "white" so this last point at (toX+xStep,toY) is the right ending. This is really a
    // small approximation; (toX+xStep,toY+yStep) might be really correct. Ignore this.
    if (state == 2) return distanceInt(toX + xstep, toY, fromX, fromY);

    // else we didn't find even black-white-black; no estimate is really possible
    return NAN;
}

- (AGXQRCodeAlignmentPattern *)findAlignmentInRegion:(float)overallEstModuleSize estAlignmentX:(int)estAlignmentX estAlignmentY:(int)estAlignmentY allowanceFactor:(float)allowanceFactor error:(NSError **)error {
    int allowance = (int)(allowanceFactor * overallEstModuleSize);
    int alignmentAreaLeftX = MAX(0, estAlignmentX - allowance);
    int alignmentAreaRightX = MIN(_bits.width - 1, estAlignmentX + allowance);
    if AGX_EXPECT_F(alignmentAreaRightX - alignmentAreaLeftX < overallEstModuleSize * 3) {
        if AGX_EXPECT_T(error) *error = AGXNotFoundErrorInstance();
        return nil;
    }

    int alignmentAreaTopY = MAX(0, estAlignmentY - allowance);
    int alignmentAreaBottomY = MIN(_bits.height - 1, estAlignmentY + allowance);
    if AGX_EXPECT_F(alignmentAreaBottomY - alignmentAreaTopY < overallEstModuleSize * 3) {
        if AGX_EXPECT_T(error) *error = AGXNotFoundErrorInstance();
        return nil;
    }

    AGXQRCodeAlignmentPatternFinder *alignmentFinder = [AGXQRCodeAlignmentPatternFinder alignmentPatternFinderWithBits:_bits startX:alignmentAreaLeftX startY:alignmentAreaTopY width:alignmentAreaRightX - alignmentAreaLeftX height:alignmentAreaBottomY - alignmentAreaTopY moduleSize:overallEstModuleSize];
    return [alignmentFinder findWithError:error];
}

+ (AGXPerspectiveTransform *)createTransform:(AGXQRCodeFinderPattern *)topLeft topRight:(AGXQRCodeFinderPattern *)topRight bottomLeft:(AGXQRCodeFinderPattern *)bottomLeft alignmentPattern:(AGXQRCodeAlignmentPattern *)alignmentPattern dimension:(int)dimension {
    float dimMinusThree = (float)dimension - 3.5f;
    float bottomRightX;
    float bottomRightY;
    float sourceBottomRightX;
    float sourceBottomRightY;
    if (alignmentPattern != nil) {
        bottomRightX = alignmentPattern.point.x;
        bottomRightY = alignmentPattern.point.y;
        sourceBottomRightX = dimMinusThree - 3.0f;
        sourceBottomRightY = sourceBottomRightX;
    } else {
        bottomRightX = (topRight.point.x - topLeft.point.x) + bottomLeft.point.x;
        bottomRightY = (topRight.point.y - topLeft.point.y) + bottomLeft.point.y;
        sourceBottomRightX = dimMinusThree;
        sourceBottomRightY = dimMinusThree;
    }

    return [AGXPerspectiveTransform quadrilateralToQuadrilateral:3.5f y0:3.5f x1:dimMinusThree y1:3.5f x2:sourceBottomRightX y2:sourceBottomRightY x3:3.5f y3:dimMinusThree x0p:topLeft.point.x y0p:topLeft.point.y x1p:topRight.point.x y1p:topRight.point.y x2p:bottomRightX y2p:bottomRightY x3p:bottomLeft.point.x y3p:bottomLeft.point.y];
}

- (AGXBitMatrix *)sampleGrid:(AGXBitMatrix *)bits transform:(AGXPerspectiveTransform *)transform dimension:(int)dimension error:(NSError **)error {
    return [AGXGridSampler.shareInstance sampleGrid:bits dimensionX:dimension dimensionY:dimension
                                          transform:transform error:error];
}

AGX_STATIC int p_round(float d) {
    return (int) (d + (d < 0.0f ? -0.5f : 0.5f));
}

AGX_STATIC float distance(float aX, float aY, float bX, float bY) {
    float xDiff = aX - bX;
    float yDiff = aY - bY;
    return sqrtf(xDiff * xDiff + yDiff * yDiff);
}

AGX_STATIC float distanceInt(int aX, int aY, int bX, int bY) {
    int xDiff = aX - bX;
    int yDiff = aY - bY;
    return sqrtf(xDiff * xDiff + yDiff * yDiff);
}

AGX_STATIC int computeDimension(AGXQRCodeFinderPattern *topLeft, AGXQRCodeFinderPattern *topRight, AGXQRCodeFinderPattern *bottomLeft, float moduleSize, NSError **error) {
    int tltrCentersDimension = p_round(distance(topLeft.point.x, topLeft.point.y, topRight.point.x, topRight.point.y) / moduleSize);
    int tlblCentersDimension = p_round(distance(topLeft.point.x, topLeft.point.y, bottomLeft.point.x, bottomLeft.point.y) / moduleSize);
    int dimension = ((tltrCentersDimension + tlblCentersDimension) / 2) + 7;

    switch (dimension & 0x03) {
        case 0:
            dimension++;
            break;
        case 2:
            dimension--;
            break;
        case 3:
            if AGX_EXPECT_T(error) *error = AGXNotFoundErrorInstance();
            return -1;
    }
    return dimension;
}

@end
