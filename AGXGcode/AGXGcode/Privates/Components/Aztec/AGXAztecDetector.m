//
//  AGXAztecDetector.m
//  AGXGcode
//
//  Created by Char Aznable on 2016/8/9.
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
#import "AGXAztecDetector.h"
#import "AGXGcodeError.h"
#import "AGXWhiteRectangleDetector.h"
#import "AGXReedSolomonDecoder.h"
#import "AGXGridSampler.h"

@implementation AGXAztecDetector {
    AGXReedSolomonDecoder *_rsDecoder;
    BOOL _compact;
    int _nbCenterLayers;
    int _nbDataBlocks;
    int _nbLayers;
    int _shift;
}

+ (AGX_INSTANCETYPE)detectorWithBits:(AGXBitMatrix *)bits {
    return AGX_AUTORELEASE([[self alloc] initWithBits:bits]);
}

- (AGX_INSTANCETYPE)initWithBits:(AGXBitMatrix *)bits {
    if AGX_EXPECT_T(self = [super init]) {
        _rsDecoder = [[AGXReedSolomonDecoder alloc] initWithField:AGXGenericGF.AztecParam];
        _bits = AGX_RETAIN(bits);
    }
    return self;
}

- (void)dealloc {
    AGX_RELEASE(_rsDecoder);
    AGX_RELEASE(_bits);
    AGX_SUPER_DEALLOC;
}

- (AGXAztecDetectorResult *)detectWithMirror:(BOOL)isMirror error:(NSError **)error {
    // 1. Get the center of the aztec matrix
    NSValue *pCenter = self.matrixCenter;
    if AGX_EXPECT_F(!pCenter) {
        if AGX_EXPECT_T(error) *error = AGXNotFoundErrorInstance();
        return nil;
    }

    // 2. Get the center points of the four diagonal points just outside the bull's eye
    //  [topRight, bottomRight, bottomLeft, topLeft]
    NSMutableArray *bullsEyeCorners = [self bullsEyeCorners:pCenter];
    if AGX_EXPECT_F(!bullsEyeCorners) {
        if AGX_EXPECT_T(error) *error = AGXNotFoundErrorInstance();
        return nil;
    }

    if (isMirror) {
        NSValue *temp = bullsEyeCorners[0];
        bullsEyeCorners[0] = bullsEyeCorners[2];
        bullsEyeCorners[2] = temp;
    }

    // 3. Get the size of the matrix and other parameters from the bull's eye
    if AGX_EXPECT_F(![self extractParameters:bullsEyeCorners]) {
        if AGX_EXPECT_T(error) *error = AGXNotFoundErrorInstance();
        return nil;
    }

    // 4. Sample the grid
    AGXBitMatrix *bits = [self sampleGrid:_bits topLeft:bullsEyeCorners[_shift % 4] topRight:bullsEyeCorners[(_shift + 1) % 4] bottomRight:bullsEyeCorners[(_shift + 2) % 4] bottomLeft:bullsEyeCorners[(_shift + 3) % 4]];
    if AGX_EXPECT_F(!bits) {
        if AGX_EXPECT_T(error) *error = AGXNotFoundErrorInstance();
        return nil;
    }

    return [AGXAztecDetectorResult detectorResultWithBits:bits compact:_compact nbDatablocks:_nbDataBlocks nbLayers:_nbLayers];
}

- (NSValue *)matrixCenter {
    NSValue *pointA, *pointB, *pointC, *pointD;

    AGXWhiteRectangleDetector *detector = [AGXWhiteRectangleDetector detectorWithBits:_bits error:nil];
    NSArray *cornerPoints = [detector detectWithError:nil];
    if (cornerPoints) {
        pointA = cornerPoints[0];
        pointB = cornerPoints[1];
        pointC = cornerPoints[2];
        pointD = cornerPoints[3];
    } else {
        // This exception can be in case the initial rectangle is white
        // In that case, surely in the bull's eye, we try to expand the rectangle.
        int cx = _bits.width / 2;
        int cy = _bits.height / 2;
        pointA = [self firstDifferent:[NSValue valueWithCGPoint:CGPointMake(cx + 7, cy - 7)] color:NO dx:1 dy:-1];
        pointB = [self firstDifferent:[NSValue valueWithCGPoint:CGPointMake(cx + 7, cy + 7)] color:NO dx:1 dy:1];
        pointC = [self firstDifferent:[NSValue valueWithCGPoint:CGPointMake(cx - 7, cy + 7)] color:NO dx:-1 dy:1];
        pointD = [self firstDifferent:[NSValue valueWithCGPoint:CGPointMake(cx - 7, cy - 7)] color:NO dx:-1 dy:-1];
    }

    //Compute the center of the rectangle
    int cx = p_round((pointA.CGPointValue.x+pointD.CGPointValue.x+pointB.CGPointValue.x+pointC.CGPointValue.x)/4.0f);
    int cy = p_round((pointA.CGPointValue.y+pointD.CGPointValue.y+pointB.CGPointValue.y+pointC.CGPointValue.y)/4.0f);

    // Redetermine the white rectangle starting from previously computed center.
    // This will ensure that we end up with a white rectangle in center bull's eye
    // in order to compute a more accurate center.
    detector = [AGXWhiteRectangleDetector detectorWithBits:_bits initSize:15 x:cx y:cy error:nil];
    cornerPoints = [detector detectWithError:nil];

    if (cornerPoints) {
        pointA = cornerPoints[0];
        pointB = cornerPoints[1];
        pointC = cornerPoints[2];
        pointD = cornerPoints[3];
    } else {
        // This exception can be in case the initial rectangle is white
        // In that case we try to expand the rectangle.
        pointA = [self firstDifferent:[NSValue valueWithCGPoint:CGPointMake(cx + 7, cy - 7)] color:NO dx:1 dy:-1];
        pointB = [self firstDifferent:[NSValue valueWithCGPoint:CGPointMake(cx + 7, cy + 7)] color:NO dx:1 dy:1];
        pointC = [self firstDifferent:[NSValue valueWithCGPoint:CGPointMake(cx - 7, cy + 7)] color:NO dx:-1 dy:1];
        pointD = [self firstDifferent:[NSValue valueWithCGPoint:CGPointMake(cx - 7, cy - 7)] color:NO dx:-1 dy:-1];
    }

    cx = p_round((pointA.CGPointValue.x+pointD.CGPointValue.x+pointB.CGPointValue.x+pointC.CGPointValue.x)/4.0f);
    cy = p_round((pointA.CGPointValue.y+pointD.CGPointValue.y+pointB.CGPointValue.y+pointC.CGPointValue.y)/4.0f);
    
    // Recompute the center of the rectangle
    return [NSValue valueWithCGPoint:CGPointMake(cx, cy)];
}

- (NSMutableArray *)bullsEyeCorners:(NSValue *)pCenter {
    NSValue *pina = pCenter, *pinb = pCenter, *pinc = pCenter, *pind = pCenter;

    BOOL color = YES;
    for (_nbCenterLayers = 1; _nbCenterLayers < 9; _nbCenterLayers++) {
        NSValue *pouta = [self firstDifferent:pina color:color dx:1 dy:-1];
        NSValue *poutb = [self firstDifferent:pinb color:color dx:1 dy:1];
        NSValue *poutc = [self firstDifferent:pinc color:color dx:-1 dy:1];
        NSValue *poutd = [self firstDifferent:pind color:color dx:-1 dy:-1];

        //d      a
        //
        //c      b
        if (_nbCenterLayers > 2) {
            float q = distancePoint(poutd.CGPointValue, pouta.CGPointValue) * _nbCenterLayers / (distancePoint(pind.CGPointValue, pina.CGPointValue) * (_nbCenterLayers + 2));
            if (q < 0.75 || q > 1.25 || ![self isWhiteOrBlackRectangle:pouta p2:poutb p3:poutc p4:poutd]) break;
        }

        pina = pouta;
        pinb = poutb;
        pinc = poutc;
        pind = poutd;

        color = !color;
    }

    if AGX_EXPECT_F(_nbCenterLayers != 5 && _nbCenterLayers != 7) return nil;

    _compact = _nbCenterLayers == 5;

    // Expand the square by .5 pixel in each direction so that we're on the border
    // between the white square and the black square
    NSValue *pinax = [NSValue valueWithCGPoint:CGPointMake(pina.CGPointValue.x + 0.5f, pina.CGPointValue.y - 0.5f)];
    NSValue *pinbx = [NSValue valueWithCGPoint:CGPointMake(pinb.CGPointValue.x + 0.5f, pinb.CGPointValue.y + 0.5f)];
    NSValue *pincx = [NSValue valueWithCGPoint:CGPointMake(pinc.CGPointValue.x - 0.5f, pinc.CGPointValue.y + 0.5f)];
    NSValue *pindx = [NSValue valueWithCGPoint:CGPointMake(pind.CGPointValue.x - 0.5f, pind.CGPointValue.y - 0.5f)];

    // Expand the square so that its corners are the centers of the points
    // just outside the bull's eye.
    return [NSMutableArray arrayWithArray:[self expandSquare:@[pinax, pinbx, pincx, pindx] oldSide:2 * _nbCenterLayers - 3 newSide:2 * _nbCenterLayers]];
}

- (BOOL)extractParameters:(NSArray *)bullsEyeCorners {
    NSValue *p0 = bullsEyeCorners[0], *p1 = bullsEyeCorners[1], *p2 = bullsEyeCorners[2], *p3 = bullsEyeCorners[3];

    if AGX_EXPECT_F(![self isValid:p0] || ![self isValid:p1] ||
                    ![self isValid:p2] || ![self isValid:p3]) return NO;

    int length = 2 * _nbCenterLayers;
    // Get the bits around the bull's eye
    int sides[] = {
        [self sampleLine:p0 p2:p1 size:length], // Right side
        [self sampleLine:p1 p2:p2 size:length], // Bottom
        [self sampleLine:p2 p2:p3 size:length], // Left side
        [self sampleLine:p3 p2:p0 size:length] // Top
    };

    // bullsEyeCorners[shift] is the corner of the bulls'eye that has three
    // orientation marks.
    // sides[shift] is the row/column that goes from the corner with three
    // orientation marks to the corner with two.
    int shift = [self rotationForSides:sides length:length];
    if AGX_EXPECT_F(shift == -1) return NO;
    _shift = shift;

    // Flatten the parameter bits into a single 28- or 40-bit long
    long parameterData = 0;
    for (int i = 0; i < 4; i++) {
        int side = sides[(_shift + i) % 4];
        if (_compact) {
            // Each side of the form ..XXXXXXX. where Xs are parameter data
            parameterData <<= 7;
            parameterData += (side >> 1) & 0x7F;
        } else {
            // Each side of the form ..XXXXX.XXXXX. where Xs are parameter data
            parameterData <<= 10;
            parameterData += ((side >> 2) & (0x1f << 5)) + ((side >> 1) & 0x1F);
        }
    }

    // Corrects parameter data using RS.  Returns just the data portion
    // without the error correction.
    int correctedData = [self correctedParameterData:parameterData compact:_compact];
    if AGX_EXPECT_F(correctedData == -1) return NO;

    if (_compact) {
        // 8 bits:  2 bits layers and 6 bits data blocks
        _nbLayers = (correctedData >> 6) + 1;
        _nbDataBlocks = (correctedData & 0x3F) + 1;
    } else {
        // 16 bits:  5 bits layers and 11 bits data blocks
        _nbLayers = (correctedData >> 11) + 1;
        _nbDataBlocks = (correctedData & 0x7FF) + 1;
    }
    return YES;
}

AGX_STATIC int p_round(float d) {
    return (int) (d + (d < 0.0f ? -0.5f : 0.5f));
}

AGX_STATIC float distancePoint(CGPoint a, CGPoint b) {
    return distance(a.x, a.y, b.x, b.y);
}

AGX_STATIC float distance(float aX, float aY, float bX, float bY) {
    float xDiff = aX - bX;
    float yDiff = aY - bY;
    return sqrtf(xDiff * xDiff + yDiff * yDiff);
}

AGX_STATIC int expectedCornerBits[] = {
    0xee0,  // 07340  XXX .XX X.. ...
    0x1dc,  // 00734  ... XXX .XX X..
    0x83b,  // 04073  X.. ... XXX .XX
    0x707,  // 03407 .XX X.. ... XXX
};

AGX_STATIC int bitCount(uint32_t i) {
    i = i - ((i >> 1) & 0x55555555);
    i = (i & 0x33333333) + ((i >> 2) & 0x33333333);
    return (((i + (i >> 4)) & 0x0F0F0F0F) * 0x01010101) >> 24;
}

- (BOOL)isValidX:(int)x y:(int)y {
    return x >= 0 && x < _bits.width && y > 0 && y < _bits.height;
}

- (BOOL)isValid:(NSValue *)point {
    int x = p_round(point.CGPointValue.x);
    int y = p_round(point.CGPointValue.y);
    return [self isValidX:x y:y];
}

- (NSValue *)firstDifferent:(NSValue *)init color:(BOOL)color dx:(int)dx dy:(int)dy {
    int x = init.CGPointValue.x + dx;
    int y = init.CGPointValue.y + dy;

    while ([self isValidX:x y:y] && [_bits getX:x y:y] == color) {
        x += dx;
        y += dy;
    }

    x -= dx;
    y -= dy;

    while ([self isValidX:x y:y] && [_bits getX:x y:y] == color) {
        x += dx;
    }
    x -= dx;

    while ([self isValidX:x y:y] && [_bits getX:x y:y] == color) {
        y += dy;
    }
    y -= dy;
    
    return [NSValue valueWithCGPoint:CGPointMake(x, y)];
}

- (BOOL)isWhiteOrBlackRectangle:(NSValue *)p1 p2:(NSValue *)p2 p3:(NSValue *)p3 p4:(NSValue *)p4 {
    int corr = 3;

    p1 = [NSValue valueWithCGPoint:CGPointMake(p1.CGPointValue.x - corr, p1.CGPointValue.y + corr)];
    p2 = [NSValue valueWithCGPoint:CGPointMake(p2.CGPointValue.x - corr, p2.CGPointValue.y - corr)];
    p3 = [NSValue valueWithCGPoint:CGPointMake(p3.CGPointValue.x + corr, p3.CGPointValue.y - corr)];
    p4 = [NSValue valueWithCGPoint:CGPointMake(p4.CGPointValue.x + corr, p4.CGPointValue.y + corr)];

    int cInit = [self color:p4 p2:p1];
    if (cInit == 0) return NO;

    int c = [self color:p1 p2:p2];
    if (c != cInit) return NO;

    c = [self color:p2 p2:p3];
    if (c != cInit) return NO;

    c = [self color:p3 p2:p4];
    return c == cInit;
}

- (int)color:(NSValue *)p1 p2:(NSValue *)p2 {
    float d = distancePoint(p1.CGPointValue, p2.CGPointValue);
    float dx = (p2.CGPointValue.x - p1.CGPointValue.x) / d;
    float dy = (p2.CGPointValue.y - p1.CGPointValue.y) / d;
    int error = 0;

    float px = p1.CGPointValue.x;
    float py = p1.CGPointValue.y;

    BOOL colorModel = [_bits getX:p1.CGPointValue.x y:p1.CGPointValue.y];

    for (int i = 0; i < d; i++) {
        px += dx;
        py += dy;
        if ([_bits getX:p_round(px) y:p_round(py)] != colorModel) {
            error++;
        }
    }

    float errRatio = (float)error / d;

    if (errRatio > 0.1f && errRatio < 0.9f) return 0;
    return((errRatio <= 0.1f) == colorModel ? 1 : -1);
}

- (NSArray *)expandSquare:(NSArray *)cornerPoints oldSide:(float)oldSide newSide:(float)newSide {
    NSValue *cornerPoints0 = (NSValue *)cornerPoints[0];
    NSValue *cornerPoints1 = (NSValue *)cornerPoints[1];
    NSValue *cornerPoints2 = (NSValue *)cornerPoints[2];
    NSValue *cornerPoints3 = (NSValue *)cornerPoints[3];

    float ratio = newSide / (2 * oldSide);
    float dx =  cornerPoints0.CGPointValue.x - cornerPoints2.CGPointValue.x;
    float dy = cornerPoints0.CGPointValue.y - cornerPoints2.CGPointValue.y;
    float centerx = (cornerPoints0.CGPointValue.x + cornerPoints2.CGPointValue.x) / 2.0f;
    float centery = (cornerPoints0.CGPointValue.y + cornerPoints2.CGPointValue.y) / 2.0f;

    NSValue *result0 = [NSValue valueWithCGPoint:CGPointMake(centerx + ratio * dx, centery + ratio * dy)];
    NSValue *result2 = [NSValue valueWithCGPoint:CGPointMake(centerx - ratio * dx, centery - ratio * dy)];

    dx = cornerPoints1.CGPointValue.x - cornerPoints3.CGPointValue.x;
    dy = cornerPoints1.CGPointValue.y - cornerPoints3.CGPointValue.y;
    centerx = (cornerPoints1.CGPointValue.x + cornerPoints3.CGPointValue.x) / 2.0f;
    centery = (cornerPoints1.CGPointValue.y + cornerPoints3.CGPointValue.y) / 2.0f;
    NSValue *result1 = [NSValue valueWithCGPoint:CGPointMake(centerx + ratio * dx, centery + ratio * dy)];
    NSValue *result3 = [NSValue valueWithCGPoint:CGPointMake(centerx - ratio * dx, centery - ratio * dy)];

    return @[result0, result1, result2, result3];
}

- (int)sampleLine:(NSValue *)p1 p2:(NSValue *)p2 size:(int)size {
    int result = 0;

    float d = distancePoint(p1.CGPointValue, p2.CGPointValue);
    float moduleSize = d / size;
    float px = p1.CGPointValue.x;
    float py = p1.CGPointValue.y;
    float dx = moduleSize * (p2.CGPointValue.x - p1.CGPointValue.x) / d;
    float dy = moduleSize * (p2.CGPointValue.y - p1.CGPointValue.y) / d;
    for (int i = 0; i < size; i++) {
        if ([_bits getX:p_round(px + i * dx) y:p_round(py + i * dy)]) {
            result |= 1 << (size - i - 1);
        }
    }
    return result;
}

- (int)rotationForSides:(const int[])sides length:(int)length {
    // In a normal pattern, we expect to See
    //   **    .*             D       A
    //   *      *
    //
    //   .      *
    //   ..    ..             C       B
    //
    // Grab the 3 bits from each of the sides the form the locator pattern and concatenate
    // into a 12-bit integer.  Start with the bit at A
    int cornerBits = 0;
    for (int i = 0; i < 4; i++) {
        int side = sides[i];
        // XX......X where X's are orientation marks
        int t = ((side >> (length - 2)) << 1) + (side & 1);
        cornerBits = (cornerBits << 3) + t;
    }
    // Mov the bottom bit to the top, so that the three bits of the locator pattern at A are
    // together.  cornerBits is now:
    //  3 orientation bits at A || 3 orientation bits at B || ... || 3 orientation bits at D
    cornerBits = ((cornerBits & 1) << 11) + (cornerBits >> 1);
    // The result shift indicates which element of BullsEyeCorners[] goes into the top-left
    // corner. Since the four rotation values have a Hamming distance of 8, we
    // can easily tolerate two errors.
    for (int shift = 0; shift < 4; shift++) {
        if (bitCount(cornerBits ^ expectedCornerBits[shift]) <= 2) {
            return shift;
        }
    }
    return -1;
}

- (int)correctedParameterData:(long)parameterData compact:(BOOL)compact {
    int numCodewords;
    int numDataCodewords;

    if (compact) {
        numCodewords = 7;
        numDataCodewords = 2;
    } else {
        numCodewords = 10;
        numDataCodewords = 4;
    }

    int numECCodewords = numCodewords - numDataCodewords;
    AGXIntArray *parameterWords = [AGXIntArray intArrayWithLength:numCodewords];
    for (int i = numCodewords - 1; i >= 0; --i) {
        parameterWords.array[i] = (int32_t) parameterData & 0xF;
        parameterData >>= 4;
    }

    if AGX_EXPECT_F(![_rsDecoder decode:parameterWords twoS:numECCodewords error:nil]) return NO;
    // Toss the error correction.  Just return the data as an integer
    int result = 0;
    for (int i = 0; i < numDataCodewords; i++) {
        result = (result << 4) + parameterWords.array[i];
    }
    return result;
}

- (AGXBitMatrix *)sampleGrid:(AGXBitMatrix *)bits topLeft:(NSValue *)topLeft topRight:(NSValue *)topRight bottomRight:(NSValue *)bottomRight bottomLeft:(NSValue *)bottomLeft {
    int dimension = self.dimension;

    float low = dimension / 2.0f - _nbCenterLayers;
    float high = dimension / 2.0f + _nbCenterLayers;

    return [AGXGridSampler.shareInstance sampleGrid:bits dimensionX:dimension dimensionY:dimension p1ToX:low p1ToY:low p2ToX:high p2ToY:low p3ToX:high p3ToY:high p4ToX:low p4ToY:high p1FromX:topLeft.CGPointValue.x p1FromY:topLeft.CGPointValue.y p2FromX:topRight.CGPointValue.x p2FromY:topRight.CGPointValue.y p3FromX:bottomRight.CGPointValue.x p3FromY:bottomRight.CGPointValue.y p4FromX:bottomLeft.CGPointValue.x p4FromY:bottomLeft.CGPointValue.y error:nil];
}

- (int)dimension {
    if (_compact) return 4 * _nbLayers + 11;
    if (_nbLayers <= 4) return 4 * _nbLayers + 15;
    return 4 * _nbLayers + 2 * ((_nbLayers-4)/8 + 1) + 15;
}

@end
