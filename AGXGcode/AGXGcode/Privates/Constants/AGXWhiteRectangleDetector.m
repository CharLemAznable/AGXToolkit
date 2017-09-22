//
//  AGXWhiteRectangleDetector.m
//  AGXGcode
//
//  Created by Char Aznable on 16/8/9.
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
#import "AGXWhiteRectangleDetector.h"
#import "AGXGcodeError.h"

const int AGX_INIT_SIZE = 10;
const int AGX_CORR = 1;

@implementation AGXWhiteRectangleDetector {
    AGXBitMatrix *_bits;
    int _height;
    int _width;
    int _leftInit;
    int _rightInit;
    int _downInit;
    int _upInit;
}

+ (AGX_INSTANCETYPE)detectorWithBits:(AGXBitMatrix *)bits error:(NSError **)error {
    return [self detectorWithBits:bits initSize:AGX_INIT_SIZE x:bits.width/2 y:bits.height/2 error:error];
}

+ (AGX_INSTANCETYPE)detectorWithBits:(AGXBitMatrix *)bits initSize:(int)initSize x:(int)x y:(int)y error:(NSError **)error {
    int halfsize = initSize / 2;
    int leftInit = x - halfsize;
    int rightInit = x + halfsize;
    int upInit = y - halfsize;
    int downInit = y + halfsize;
    if (AGX_EXPECT_F(upInit < 0 || leftInit < 0 || downInit >= bits.height || rightInit >= bits.width)) {
        if (AGX_EXPECT_T(error)) *error = AGXNotFoundErrorInstance();
        return nil;
    }
    return AGX_AUTORELEASE([[self alloc] initWithBits:bits left:leftInit right:rightInit up:upInit down:downInit]);
}

- (AGX_INSTANCETYPE)initWithBits:(AGXBitMatrix *)bits left:(int)left right:(int)right up:(int)up down:(int)down {
    if (AGX_EXPECT_T(self = [super init])) {
        _bits = AGX_RETAIN(bits);
        _height = _bits.height;
        _width = _bits.width;
        _leftInit = left;
        _rightInit = right;
        _upInit = up;
        _downInit = down;
    }
    return self;
}

- (void)dealloc {
    AGX_RELEASE(_bits);
    AGX_SUPER_DEALLOC;
}

- (NSArray *)detectWithError:(NSError **)error {
    int left = _leftInit;
    int right = _rightInit;
    int up = _upInit;
    int down = _downInit;
    BOOL sizeExceeded = NO;
    BOOL aBlackPointFoundOnBorder = YES;
    BOOL atLeastOneBlackPointFoundOnBorder = NO;

    BOOL atLeastOneBlackPointFoundOnRight = NO;
    BOOL atLeastOneBlackPointFoundOnBottom = NO;
    BOOL atLeastOneBlackPointFoundOnLeft = NO;
    BOOL atLeastOneBlackPointFoundOnTop = NO;

    while (aBlackPointFoundOnBorder) {
        aBlackPointFoundOnBorder = NO;

        // .....
        // .   |
        // .....
        BOOL rightBorderNotWhite = YES;
        while ((rightBorderNotWhite || !atLeastOneBlackPointFoundOnRight) && right < _width) {
            rightBorderNotWhite = [self containsBlackPoint:up b:down fixed:right horizontal:NO];
            if (rightBorderNotWhite) {
                right++;
                aBlackPointFoundOnBorder = YES;
                atLeastOneBlackPointFoundOnRight = YES;
            } else if (!atLeastOneBlackPointFoundOnRight) {
                right++;
            }
        }

        if (right >= _width) {
            sizeExceeded = YES;
            break;
        }

        // .....
        // .   .
        // .___.
        BOOL bottomBorderNotWhite = YES;
        while ((bottomBorderNotWhite || !atLeastOneBlackPointFoundOnBottom) && down < _height) {
            bottomBorderNotWhite = [self containsBlackPoint:left b:right fixed:down horizontal:YES];
            if (bottomBorderNotWhite) {
                down++;
                aBlackPointFoundOnBorder = YES;
                atLeastOneBlackPointFoundOnBottom = YES;
            } else if (!atLeastOneBlackPointFoundOnBottom) {
                down++;
            }
        }

        if (down >= _height) {
            sizeExceeded = YES;
            break;
        }

        // .....
        // |   .
        // .....
        BOOL leftBorderNotWhite = YES;
        while ((leftBorderNotWhite || !atLeastOneBlackPointFoundOnLeft) && left >= 0) {
            leftBorderNotWhite = [self containsBlackPoint:up b:down fixed:left horizontal:NO];
            if (leftBorderNotWhite) {
                left--;
                aBlackPointFoundOnBorder = YES;
                atLeastOneBlackPointFoundOnLeft = YES;
            } else if (!atLeastOneBlackPointFoundOnLeft) {
                left--;
            }
        }

        if (left < 0) {
            sizeExceeded = YES;
            break;
        }

        // .___.
        // .   .
        // .....
        BOOL topBorderNotWhite = YES;
        while ((topBorderNotWhite  || !atLeastOneBlackPointFoundOnTop) && up >= 0) {
            topBorderNotWhite = [self containsBlackPoint:left b:right fixed:up horizontal:YES];
            if (topBorderNotWhite) {
                up--;
                aBlackPointFoundOnBorder = YES;
                atLeastOneBlackPointFoundOnTop = YES;
            } else if (!atLeastOneBlackPointFoundOnTop) {
                up--;
            }
        }

        if (up < 0) {
            sizeExceeded = YES;
            break;
        }

        if (aBlackPointFoundOnBorder) {
            atLeastOneBlackPointFoundOnBorder = YES;
        }
    }

    if (!sizeExceeded && atLeastOneBlackPointFoundOnBorder) {
        int maxSize = right - left;

        NSValue *z = nil;
        for (int i = 1; i < maxSize; i++) {
            z = [self blackPointOnSegment:left aY:down - i bX:left + i bY:down];
            if (z != nil) break;
        }

        if (AGX_EXPECT_F(z == nil)) {
            if (AGX_EXPECT_T(error)) *error = AGXNotFoundErrorInstance();
            return nil;
        }

        NSValue *t = nil;
        for (int i = 1; i < maxSize; i++) {
            t = [self blackPointOnSegment:left aY:up + i bX:left + i bY:up];
            if (t != nil) break;
        }

        if (AGX_EXPECT_F(t == nil)) {
            if (AGX_EXPECT_T(error)) *error = AGXNotFoundErrorInstance();
            return nil;
        }

        NSValue *x = nil;
        for (int i = 1; i < maxSize; i++) {
            x = [self blackPointOnSegment:right aY:up + i bX:right - i bY:up];
            if (x != nil) break;
        }
        
        if (AGX_EXPECT_F(x == nil)) {
            if (AGX_EXPECT_T(error)) *error = AGXNotFoundErrorInstance();
            return nil;
        }
        
        NSValue *y = nil;
        for (int i = 1; i < maxSize; i++) {
            y = [self blackPointOnSegment:right aY:down - i bX:right - i bY:down];
            if (y != nil) break;
        }
        
        if (AGX_EXPECT_F(y == nil)) {
            if (AGX_EXPECT_T(error)) *error = AGXNotFoundErrorInstance();
            return nil;
        }
        return [self centerEdges:y z:z x:x t:t];
    } else {
        if (AGX_EXPECT_T(error)) *error = AGXNotFoundErrorInstance();
        return nil;
    }
}

/**
 * Determines whether a segment contains a black point
 *
 * @param a          min value of the scanned coordinate
 * @param b          max value of the scanned coordinate
 * @param fixed      value of fixed coordinate
 * @param horizontal set to true if scan must be horizontal, false if vertical
 * @return true if a black point has been found, else false.
 */
- (BOOL)containsBlackPoint:(int)a b:(int)b fixed:(int)fixed horizontal:(BOOL)horizontal {
    if (horizontal) {
        for (int x = a; x <= b; x++) {
            if ([_bits getX:x y:fixed]) {
                return YES;
            }
        }
    } else {
        for (int y = a; y <= b; y++) {
            if ([_bits getX:fixed y:y]) {
                return YES;
            }
        }
    }
    return NO;
}

- (NSValue *)blackPointOnSegment:(float)aX aY:(float)aY bX:(float)bX bY:(float)bY {
    int dist = p_round(distance(aX, aY, bX, bY));
    float xStep = (bX - aX) / dist;
    float yStep = (bY - aY) / dist;

    for (int i = 0; i < dist; i++) {
        int x = p_round(aX + i * xStep);
        int y = p_round(aY + i * yStep);
        if ([_bits getX:x y:y]) {
            return [NSValue valueWithCGPoint:CGPointMake(x, y)];
        }
    }
    return nil;
}

AGX_STATIC int p_round(float d) {
    return (int) (d + (d < 0.0f ? -0.5f : 0.5f));
}

AGX_STATIC float distance(float aX, float aY, float bX, float bY) {
    float xDiff = aX - bX;
    float yDiff = aY - bY;
    return sqrtf(xDiff * xDiff + yDiff * yDiff);
}

/**
 * recenters the points of a constant distance towards the center
 *
 * @param y bottom most point
 * @param z left most point
 * @param x right most point
 * @param t top most point
 * @return AGXResultPoint array describing the corners of the rectangular
 *         region. The first and last points are opposed on the diagonal, as
 *         are the second and third. The first point will be the topmost
 *         point and the last, the bottommost. The second point will be
 *         leftmost and the third, the rightmost
 */
- (NSArray *)centerEdges:(NSValue *)y z:(NSValue *)z x:(NSValue *)x t:(NSValue *)t {
    //
    //       t            t
    //  z                      x
    //        x    OR    z
    //   y                    y
    //

    float yi = y.CGPointValue.x;
    float yj = y.CGPointValue.y;
    float zi = z.CGPointValue.x;
    float zj = z.CGPointValue.y;
    float xi = x.CGPointValue.x;
    float xj = x.CGPointValue.y;
    float ti = t.CGPointValue.x;
    float tj = t.CGPointValue.y;

    if (yi < _width / 2.0f) {
        return @[[NSValue valueWithCGPoint:CGPointMake(ti - AGX_CORR, tj + AGX_CORR)],
                 [NSValue valueWithCGPoint:CGPointMake(zi + AGX_CORR, zj + AGX_CORR)],
                 [NSValue valueWithCGPoint:CGPointMake(xi - AGX_CORR, xj - AGX_CORR)],
                 [NSValue valueWithCGPoint:CGPointMake(yi + AGX_CORR, yj - AGX_CORR)]];
    } else {
        return @[[NSValue valueWithCGPoint:CGPointMake(ti + AGX_CORR, tj + AGX_CORR)],
                 [NSValue valueWithCGPoint:CGPointMake(zi + AGX_CORR, zj - AGX_CORR)],
                 [NSValue valueWithCGPoint:CGPointMake(xi - AGX_CORR, xj + AGX_CORR)],
                 [NSValue valueWithCGPoint:CGPointMake(yi - AGX_CORR, yj - AGX_CORR)]];
    }
}

@end
