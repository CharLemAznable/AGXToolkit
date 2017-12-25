//
//  AGXDataMatrixDetector.m
//  AGXGcode
//
//  Created by Char Aznable on 2016/8/10.
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

#import <UIKit/UIGeometry.h>
#import <AGXCore/AGXCore/AGXArc.h>
#import "AGXDataMatrixDetector.h"
#import "AGXGcodeError.h"
#import "AGXWhiteRectangleDetector.h"
#import "AGXGridSampler.h"

@interface AGXPointTransitions : NSObject
@property (nonatomic, readonly) NSValue *from;
@property (nonatomic, readonly) NSValue *to;
@property (nonatomic, readonly) int transitions;

+ (AGX_INSTANCETYPE)transitionsWithFrom:(NSValue *)from to:(NSValue *)to transitions:(int)transitions;
@end

@implementation AGXDataMatrixDetector {
    AGXBitMatrix *_bits;
    AGXWhiteRectangleDetector *_rectangleDetector;
}

+ (AGX_INSTANCETYPE)detectorWithBits:(AGXBitMatrix *)bits error:(NSError **)error {
    AGXWhiteRectangleDetector *rectangleDetector = [AGXWhiteRectangleDetector detectorWithBits:bits error:error];
    if AGX_EXPECT_F(!rectangleDetector) return nil;
    return AGX_AUTORELEASE([[self alloc] initWithBits:bits rectangleDetector:rectangleDetector]);
}

- (AGX_INSTANCETYPE)initWithBits:(AGXBitMatrix *)bits rectangleDetector:(AGXWhiteRectangleDetector *)rectangleDetector {
    if AGX_EXPECT_T(self = [super init]) {
        _bits = AGX_RETAIN(bits);
        _rectangleDetector = AGX_RETAIN(rectangleDetector);
    }
    return self;
}

- (void)dealloc {
    AGX_RELEASE(_bits);
    AGX_RELEASE(_rectangleDetector);
    AGX_SUPER_DEALLOC;
}

- (AGXDetectorResult *)detectWithError:(NSError **)error {
    NSArray *cornerPoints = [_rectangleDetector detectWithError:error];
    if AGX_EXPECT_F(!cornerPoints) return nil;

    NSValue *pointA = cornerPoints[0];
    NSValue *pointB = cornerPoints[1];
    NSValue *pointC = cornerPoints[2];
    NSValue *pointD = cornerPoints[3];

    NSMutableArray *transitions = [NSMutableArray arrayWithCapacity:4];
    [transitions addObject:[self transitionsBetween:pointA to:pointB]];
    [transitions addObject:[self transitionsBetween:pointA to:pointC]];
    [transitions addObject:[self transitionsBetween:pointB to:pointD]];
    [transitions addObject:[self transitionsBetween:pointC to:pointD]];
    [transitions sortUsingSelector:@selector(compare:)];

    AGXPointTransitions *lSideOne = (AGXPointTransitions *)transitions[0];
    AGXPointTransitions *lSideTwo = (AGXPointTransitions *)transitions[1];

    NSMutableDictionary *pointCount = [NSMutableDictionary dictionary];
    [self increment:pointCount key:[lSideOne from]];
    [self increment:pointCount key:[lSideOne to]];
    [self increment:pointCount key:[lSideTwo from]];
    [self increment:pointCount key:[lSideTwo to]];

    NSValue *maybeTopLeft = nil;
    NSValue *bottomLeft = nil;
    NSValue *maybeBottomRight = nil;
    for (NSValue *point in [pointCount allKeys]) {
        NSNumber *value = pointCount[point];
        if ([value intValue] == 2) {
            bottomLeft = point;
        } else {
            if (maybeTopLeft == nil) {
                maybeTopLeft = point;
            } else {
                maybeBottomRight = point;
            }
        }
    }

    if AGX_EXPECT_F(maybeTopLeft == nil || bottomLeft == nil || maybeBottomRight == nil) {
        if AGX_EXPECT_T(error) *error = AGXNotFoundErrorInstance();
        return nil;
    }

    NSMutableArray *corners = [NSMutableArray arrayWithObjects:maybeTopLeft, bottomLeft, maybeBottomRight, nil];
    orderBestPatterns(corners);

    NSValue *bottomRight = corners[0];
    bottomLeft = corners[1];
    NSValue *topLeft = corners[2];

    NSValue *topRight;
    if (!pointCount[pointA]) {
        topRight = pointA;
    } else if (!pointCount[pointB]) {
        topRight = pointB;
    } else if (!pointCount[pointC]) {
        topRight = pointC;
    } else {
        topRight = pointD;
    }

    int dimensionTop = [[self transitionsBetween:topLeft to:topRight] transitions];
    int dimensionRight = [[self transitionsBetween:bottomRight to:topRight] transitions];

    if ((dimensionTop & 0x01) == 1) dimensionTop++;
    dimensionTop += 2;

    if ((dimensionRight & 0x01) == 1) dimensionRight++;
    dimensionRight += 2;

    AGXBitMatrix *bits = nil;
    NSValue *correctedTopRight = nil;

    if (4 * dimensionTop >= 7 * dimensionRight || 4 * dimensionRight >= 7 * dimensionTop) {
        correctedTopRight = [self correctTopRightRectangular:bottomLeft bottomRight:bottomRight topLeft:topLeft topRight:topRight dimensionTop:dimensionTop dimensionRight:dimensionRight];
        if (correctedTopRight == nil) correctedTopRight = topRight;

        dimensionTop = [[self transitionsBetween:topLeft to:correctedTopRight] transitions];
        dimensionRight = [[self transitionsBetween:bottomRight to:correctedTopRight] transitions];

        if ((dimensionTop & 0x01) == 1) dimensionTop++;
        if ((dimensionRight & 0x01) == 1) dimensionRight++;

        bits = [self sampleGrid:_bits topLeft:topLeft bottomLeft:bottomLeft bottomRight:bottomRight topRight:correctedTopRight dimensionX:dimensionTop dimensionY:dimensionRight error:error];
        if AGX_EXPECT_F(!bits) return nil;

    } else {
        int dimension = MIN(dimensionRight, dimensionTop);
        correctedTopRight = [self correctTopRight:bottomLeft bottomRight:bottomRight topLeft:topLeft topRight:topRight dimension:dimension];
        if (correctedTopRight == nil) correctedTopRight = topRight;

        int dimensionCorrected = MAX([[self transitionsBetween:topLeft to:correctedTopRight] transitions], [[self transitionsBetween:bottomRight to:correctedTopRight] transitions]);
        dimensionCorrected++;
        if ((dimensionCorrected & 0x01) == 1) dimensionCorrected++;
        
        bits = [self sampleGrid:_bits topLeft:topLeft bottomLeft:bottomLeft bottomRight:bottomRight topRight:correctedTopRight dimensionX:dimensionCorrected dimensionY:dimensionCorrected error:error];
        if AGX_EXPECT_F(!bits) return nil;
    }
    return [AGXDetectorResult detectorResultWithBits:bits];
}

/**
 * Counts the number of black/white transitions between two points, using something like Bresenham's algorithm.
 */
- (AGXPointTransitions *)transitionsBetween:(NSValue *)from to:(NSValue *)to {
    int fromX = (int)from.CGPointValue.x;
    int fromY = (int)from.CGPointValue.y;
    int toX = (int)to.CGPointValue.x;
    int toY = (int)to.CGPointValue.y;
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
    int ystep = fromY < toY ? 1 : -1;
    int xstep = fromX < toX ? 1 : -1;
    int transitions = 0;
    BOOL inBlack = [_bits getX:steep ? fromY : fromX y:steep ? fromX : fromY];
    for (int x = fromX, y = fromY; x != toX; x += xstep) {
        BOOL isBlack = [_bits getX:steep ? y : x y:steep ? x : y];
        if (isBlack != inBlack) {
            transitions++;
            inBlack = isBlack;
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
    return [AGXPointTransitions transitionsWithFrom:from to:to transitions:transitions];
}

/**
 * Increments the Integer associated with a key by one.
 */
- (void)increment:(NSMutableDictionary *)table key:(NSValue *)key {
    NSNumber *value = table[key];
    table[key] = value == nil ? @1 : @([value intValue] + 1);
}

- (NSValue *)correctTopRightRectangular:(NSValue *)bottomLeft bottomRight:(NSValue *)bottomRight topLeft:(NSValue *)topLeft topRight:(NSValue *)topRight dimensionTop:(int)dimensionTop dimensionRight:(int)dimensionRight {
    float corr = p_round(distance(bottomLeft.CGPointValue, bottomRight.CGPointValue)) / (float)dimensionTop;
    int norm = p_round(distance(topLeft.CGPointValue, topRight.CGPointValue));
    float cos = (topRight.CGPointValue.x - topLeft.CGPointValue.x) / norm;
    float sin = (topRight.CGPointValue.y - topLeft.CGPointValue.y) / norm;

    NSValue *c1 = [NSValue valueWithCGPoint:CGPointMake
                   (topRight.CGPointValue.x + corr * cos, topRight.CGPointValue.y + corr * sin)];

    corr = p_round(distance(bottomLeft.CGPointValue, topLeft.CGPointValue)) / (float)dimensionRight;
    norm = p_round(distance(bottomRight.CGPointValue, topRight.CGPointValue));
    cos = (topRight.CGPointValue.x - bottomRight.CGPointValue.x) / norm;
    sin = (topRight.CGPointValue.y - bottomRight.CGPointValue.y) / norm;

    NSValue *c2 = [NSValue valueWithCGPoint:CGPointMake
                   (topRight.CGPointValue.x + corr * cos, topRight.CGPointValue.y + corr * sin)];

    if (![self isValid:c1]) {
        if ([self isValid:c2]) {
            return c2;
        }
        return nil;
    } else if (![self isValid:c2]) {
        return c1;
    }

    int l1 = abs(dimensionTop - [[self transitionsBetween:topLeft to:c1] transitions]) + abs(dimensionRight - [[self transitionsBetween:bottomRight to:c1] transitions]);
    int l2 = abs(dimensionTop - [[self transitionsBetween:topLeft to:c2] transitions]) + abs(dimensionRight - [[self transitionsBetween:bottomRight to:c2] transitions]);

    return(l1 <= l2 ? c1 : c2);
}

- (NSValue *)correctTopRight:(NSValue *)bottomLeft bottomRight:(NSValue *)bottomRight topLeft:(NSValue *)topLeft topRight:(NSValue *)topRight dimension:(int)dimension {
    float corr = p_round(distance(bottomLeft.CGPointValue, bottomRight.CGPointValue)) / (float)dimension;
    int norm = p_round(distance(topLeft.CGPointValue, topRight.CGPointValue));
    float cos = (topRight.CGPointValue.x - topLeft.CGPointValue.x) / norm;
    float sin = (topRight.CGPointValue.y - topLeft.CGPointValue.y) / norm;

    NSValue *c1 = [NSValue valueWithCGPoint:CGPointMake
                   (topRight.CGPointValue.x + corr * cos, topRight.CGPointValue.y + corr * sin)];;

    corr = p_round(distance(bottomLeft.CGPointValue, topLeft.CGPointValue)) / (float)dimension;
    norm = p_round(distance(bottomRight.CGPointValue, topRight.CGPointValue));
    cos = (topRight.CGPointValue.x - bottomRight.CGPointValue.x) / norm;
    sin = (topRight.CGPointValue.y - bottomRight.CGPointValue.y) / norm;

    NSValue *c2 = [NSValue valueWithCGPoint:CGPointMake
                   (topRight.CGPointValue.x + corr * cos, topRight.CGPointValue.y + corr * sin)];

    if (![self isValid:c1]) {
        if ([self isValid:c2]) {
            return c2;
        }
        return nil;
    } else if (![self isValid:c2]) {
        return c1;
    }

    int l1 = abs([[self transitionsBetween:topLeft to:c1] transitions] - [[self transitionsBetween:bottomRight to:c1] transitions]);
    int l2 = abs([[self transitionsBetween:topLeft to:c2] transitions] - [[self transitionsBetween:bottomRight to:c2] transitions]);
    
    return l1 <= l2 ? c1 : c2;
}

- (BOOL)isValid:(NSValue *)p {
    return(p.CGPointValue.x >= 0 && p.CGPointValue.x < _bits.width &&
           p.CGPointValue.y > 0 && p.CGPointValue.y < _bits.height);
}

- (AGXBitMatrix *)sampleGrid:(AGXBitMatrix *)image topLeft:(NSValue *)topLeft bottomLeft:(NSValue *)bottomLeft bottomRight:(NSValue *)bottomRight topRight:(NSValue *)topRight dimensionX:(int)dimensionX dimensionY:(int)dimensionY error:(NSError **)error {
    return [AGXGridSampler.shareInstance sampleGrid:image dimensionX:dimensionX dimensionY:dimensionY p1ToX:0.5f p1ToY:0.5f p2ToX:dimensionX - 0.5f p2ToY:0.5f p3ToX:dimensionX - 0.5f p3ToY:dimensionY - 0.5f p4ToX:0.5f p4ToY:dimensionY - 0.5f p1FromX:topLeft.CGPointValue.x p1FromY:topLeft.CGPointValue.y p2FromX:topRight.CGPointValue.x p2FromY:topRight.CGPointValue.y p3FromX:bottomRight.CGPointValue.x p3FromY:bottomRight.CGPointValue.y p4FromX:bottomLeft.CGPointValue.x p4FromY:bottomLeft.CGPointValue.y error:error];
}

AGX_STATIC void orderBestPatterns(NSMutableArray *patterns) {
    float zeroOneDistance = distance([patterns[0] CGPointValue], [patterns[1] CGPointValue]);
    float oneTwoDistance = distance([patterns[1] CGPointValue], [patterns[2] CGPointValue]);
    float zeroTwoDistance = distance([patterns[0] CGPointValue], [patterns[2] CGPointValue]);
    NSValue *pointA;
    NSValue *pointB;
    NSValue *pointC;
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
        NSValue *temp = pointA;
        pointA = pointC;
        pointC = temp;
    }
    patterns[0] = pointA;
    patterns[1] = pointB;
    patterns[2] = pointC;
}

AGX_STATIC int p_round(float d) {
    return (int) (d + (d < 0.0f ? -0.5f : 0.5f));
}

AGX_STATIC float distance(CGPoint pattern1, CGPoint pattern2) {
    float xDiff = pattern1.x - pattern2.x;
    float yDiff = pattern1.y - pattern2.y;
    return sqrtf(xDiff * xDiff + yDiff * yDiff);
}

AGX_STATIC float crossProductZ(NSValue *pointA, NSValue *pointB, NSValue *pointC) {
    float bX = pointB.CGPointValue.x;
    float bY = pointB.CGPointValue.y;
    return(((pointC.CGPointValue.x - bX) * (pointA.CGPointValue.y - bY)) -
           ((pointC.CGPointValue.y - bY) * (pointA.CGPointValue.x - bX)));
}

@end

@implementation AGXPointTransitions

+ (AGX_INSTANCETYPE)transitionsWithFrom:(NSValue *)from to:(NSValue *)to transitions:(int)transitions {
    return AGX_AUTORELEASE([[self alloc] initWithFrom:from to:to transitions:transitions]);
}

- (AGX_INSTANCETYPE)initWithFrom:(NSValue *)from to:(NSValue *)to transitions:(int)transitions {
    if AGX_EXPECT_T(self = [super init]) {
        _from = AGX_RETAIN(from);
        _to = AGX_RETAIN(to);
        _transitions = transitions;
    }
    return self;
}

- (void)dealloc {
    AGX_RELEASE(_from);
    AGX_RELEASE(_to);
    AGX_SUPER_DEALLOC;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"%@/%@/%d", _from, _to, _transitions];
}

- (NSComparisonResult)compare:(AGXPointTransitions *)otherObject {
    return [@(_transitions) compare:@(otherObject.transitions)];
}

@end
