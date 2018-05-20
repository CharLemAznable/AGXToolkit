//
//  AGXLine.m
//  AGXWidget
//
//  Created by Char Aznable on 2016/4/1.
//  Copyright © 2016年 AI-CUC-EC. All rights reserved.
//

//
//  Modify from:
//  SSLineView(SSToolkit)
//

//  Copyright (c) 2008-2014 Sam Soffes
//
//  Permission is hereby granted, free of charge, to any person obtaining
//  a copy of this software and associated documentation files (the
//  "Software"), to deal in the Software without restriction, including
//  without limitation the rights to use, copy, modify, merge, publish,
//  distribute, sublicense, and/or sell copies of the Software, and to
//  permit persons to whom the Software is furnished to do so, subject to
//  the following conditions:
//
//  The above copyright notice and this permission notice shall be
//  included in all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
//  EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
//  MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
//  NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
//  LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
//  OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
//  WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

#import <AGXCore/AGXCore/AGXAdapt.h>
#import <AGXCore/AGXCore/AGXMath.h>
#import <AGXCore/AGXCore/UIView+AGXCore.h>
#import <AGXCore/AGXCore/UIColor+AGXCore.h>
#import "AGXLine.h"

#define IntegerPixelRatio       ((int)[UIScreen mainScreen].scale)
#define VectorAntiEffect(v)     (1-cgfabs(vector.v))

@implementation AGXLine

- (void)agxInitial {
    self.backgroundColor = UIColor.clearColor;
    self.opaque = NO;
    self.contentMode = UIViewContentModeRedraw;

    _lineColor = AGX_RETAIN(UIColor.grayColor);
    _lineDirection = AGXDirectionEast;
    _lineWidth = 1;
    _ceilAdjust = NO;
}

- (void)dealloc {
    AGX_RELEASE(_lineColor);
    AGX_RELEASE(_dashLengths);
    AGX_SUPER_DEALLOC;
}

- (void)drawRect:(CGRect)rect {
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextClipToRect(context, rect);
    CGContextSetStrokeColorWithColor(context, _lineColor.CGColor); // lineColor
    CGVector vector = AGX_CGVectorFromDirection(_lineDirection); // lineDirection
    CGFloat lineWidth = _lineWidth * AGX_SinglePixel;
    CGContextSetLineWidth(context, lineWidth); // lineWidth
    CGFloat pixelAdjustOffset = 0;
    if (_lineWidth % IntegerPixelRatio != 0) { // aliquant need adjust
        pixelAdjustOffset = AGX_SinglePixel / 2;
        if (_ceilAdjust) pixelAdjustOffset *= -1;
    }

    if (_dashLengths) {
        NSUInteger dashLengthsCount = _dashLengths.count;
        CGFloat *lengths = (CGFloat *)malloc(sizeof(CGFloat) * dashLengthsCount);

        for (NSUInteger i = 0; i < dashLengthsCount; i++) {
            lengths[i] = [_dashLengths[i] floatValue];
        }
        CGContextSetLineDash(context, _dashPhase, lengths, dashLengthsCount);

        free(lengths);
    }

    CGFloat width = rect.size.width, height = rect.size.height;
    CGFloat startX = roundScaleAdjust((MAX(0, -vector.dx) + VectorAntiEffect(dx) / 2) * width);
    CGFloat startY = roundScaleAdjust((MAX(0, vector.dy) + VectorAntiEffect(dy) / 2) * height);
    CGFloat endX = roundScaleAdjust((MAX(0, vector.dx) + VectorAntiEffect(dx) / 2) * width);
    CGFloat endY = roundScaleAdjust((MAX(0, -vector.dy) + VectorAntiEffect(dy) / 2) * height);
    if (needAdjustment(startX, lineWidth)) startX -= pixelAdjustOffset * VectorAntiEffect(dx);
    if (needAdjustment(startY, lineWidth)) startY -= pixelAdjustOffset * VectorAntiEffect(dy);
    if (needAdjustment(endX, lineWidth)) endX -= pixelAdjustOffset * VectorAntiEffect(dx);
    if (needAdjustment(endY, lineWidth)) endY -= pixelAdjustOffset * VectorAntiEffect(dy);
    CGContextMoveToPoint(context, startX, startY);
    CGContextAddLineToPoint(context, endX, endY);
    CGContextStrokePath(context);
}

- (void)setLineColor:(UIColor *)lineColor {
    if AGX_EXPECT_F([_lineColor isEqualToColor:lineColor]) return;
    UIColor *temp = AGX_RETAIN(lineColor);
    AGX_RELEASE(_lineColor);
    _lineColor = temp;
    [self setNeedsDisplay];
}

- (void)setLineDirection:(AGXDirection)lineDirection {
    if AGX_EXPECT_F(_lineDirection == lineDirection) return;
    _lineDirection = lineDirection;
    [self setNeedsDisplay];
}

- (void)setLineWidth:(NSUInteger)lineWidth {
    if AGX_EXPECT_F(_lineWidth == lineWidth) return;
    _lineWidth = lineWidth;
    [self setNeedsDisplay];
}

- (void)setCeilAdjust:(BOOL)ceilAdjust {
    if AGX_EXPECT_F(_ceilAdjust == ceilAdjust) return;
    _ceilAdjust = ceilAdjust;
    [self setNeedsDisplay];
}

- (void)setDashPhase:(CGFloat)dashPhase {
    if AGX_EXPECT_F(_dashPhase == dashPhase) return;
    _dashPhase = dashPhase;
    [self setNeedsDisplay];
}

- (void)setDashLengths:(NSArray *)dashLengths {
    if AGX_EXPECT_F([_dashLengths isEqualToArray:dashLengths]) return;
    NSArray *temp = [dashLengths copy];
    AGX_RELEASE(_dashLengths);
    _dashLengths = temp;
    [self setNeedsDisplay];
}

#pragma mark - private methods

AGX_STATIC_INLINE CGFloat roundScaleAdjust(CGFloat v) {
    return cground(v * UIScreen.mainScreen.scale * 2) / UIScreen.mainScreen.scale / 2;
}

AGX_STATIC_INLINE BOOL needAdjustment(CGFloat v, CGFloat lineWidth) {
    return cglround((v - lineWidth / 2) * UIScreen.mainScreen.scale * 2) % 2 != 0;
}

@end

#undef IntegerPixelRatio
#undef VectorAntiEffect
