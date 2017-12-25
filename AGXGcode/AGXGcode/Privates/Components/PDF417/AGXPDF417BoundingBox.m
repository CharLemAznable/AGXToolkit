//
//  AGXPDF417BoundingBox.m
//  AGXGcode
//
//  Created by Char Aznable on 2016/8/2.
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
#import "AGXPDF417BoundingBox.h"

@interface AGXPDF417BoundingBox ()
@property (nonatomic, readonly) AGXBitMatrix *image;
@end

@implementation AGXPDF417BoundingBox

+ (AGX_INSTANCETYPE)boundingBoxWithImage:(AGXBitMatrix *)image topLeft:(NSValue *)topLeft bottomLeft:(NSValue *)bottomLeft topRight:(NSValue *)topRight bottomRight:(NSValue *)bottomRight {
    if AGX_EXPECT_F((!topLeft && !topRight) || (!bottomLeft && !bottomRight) ||
                    (topLeft && !bottomLeft) || (topRight && !bottomRight)) return nil;

    return AGX_AUTORELEASE([[self alloc] initWithImage:image topLeft:topLeft bottomLeft:bottomLeft topRight:topRight bottomRight:bottomRight]);
}

+ (AGX_INSTANCETYPE)boundingBoxWithBoundingBox:(AGXPDF417BoundingBox *)boundingBox {
    return [self boundingBoxWithImage:boundingBox.image topLeft:boundingBox.topLeft bottomLeft:boundingBox.bottomLeft topRight:boundingBox.topRight bottomRight:boundingBox.bottomRight];
}

- (AGX_INSTANCETYPE)initWithImage:(AGXBitMatrix *)image topLeft:(NSValue *)topLeft bottomLeft:(NSValue *)bottomLeft topRight:(NSValue *)topRight bottomRight:(NSValue *)bottomRight {
    if AGX_EXPECT_T(self = [super init]) {
        _image = AGX_RETAIN(image);
        _topLeft = AGX_RETAIN(topLeft);
        _bottomLeft = AGX_RETAIN(bottomLeft);
        _topRight = AGX_RETAIN(topRight);
        _bottomRight = AGX_RETAIN(bottomRight);
        [self calculateMinMaxValues];
    }
    return self;
}

- (void)dealloc {
    AGX_RELEASE(_image);
    AGX_RELEASE(_topLeft);
    AGX_RELEASE(_bottomLeft);
    AGX_RELEASE(_topRight);
    AGX_RELEASE(_bottomRight);
    AGX_SUPER_DEALLOC;
}

+ (AGXPDF417BoundingBox *)mergeLeftBox:(AGXPDF417BoundingBox *)leftBox rightBox:(AGXPDF417BoundingBox *)rightBox {
    if AGX_EXPECT_F(!leftBox) return rightBox;
    if AGX_EXPECT_F(!rightBox) return leftBox;
    return [self boundingBoxWithImage:leftBox.image topLeft:leftBox.topLeft bottomLeft:leftBox.bottomLeft topRight:rightBox.topRight bottomRight:rightBox.bottomRight];
}

- (AGXPDF417BoundingBox *)addMissingRows:(int)missingStartRows missingEndRows:(int)missingEndRows isLeft:(BOOL)isLeft {
    NSValue *newTopLeft = _topLeft;
    NSValue *newBottomLeft = _bottomLeft;
    NSValue *newTopRight = _topRight;
    NSValue *newBottomRight = _bottomRight;

    if (missingStartRows > 0) {
        NSValue *top = isLeft ? _topLeft : _topRight;
        int newMinY = (int) top.CGPointValue.y - missingStartRows;
        if (newMinY < 0) newMinY = 0;

        // TODO use existing points to better interpolate the new x positions
        NSValue *newTop = [NSValue valueWithCGPoint:CGPointMake(top.CGPointValue.x, newMinY)];
        if (isLeft) {
            newTopLeft = newTop;
        } else {
            newTopRight = newTop;
        }
    }

    if (missingEndRows > 0) {
        NSValue *bottom = isLeft ? _bottomLeft : _bottomRight;
        int newMaxY = (int) bottom.CGPointValue.y + missingEndRows;
        if (newMaxY >= _image.height) newMaxY = _image.height - 1;

        // TODO use existing points to better interpolate the new x positions
        NSValue *newBottom = [NSValue valueWithCGPoint:CGPointMake(bottom.CGPointValue.x, newMaxY)];
        if (isLeft) {
            newBottomLeft = newBottom;
        } else {
            newBottomRight = newBottom;
        }
    }
    [self calculateMinMaxValues];
    return [AGXPDF417BoundingBox boundingBoxWithImage:_image topLeft:newTopLeft bottomLeft:newBottomLeft topRight:newTopRight bottomRight:newBottomRight];
}

- (void)calculateMinMaxValues {
    if (!_topLeft) {
        _topLeft = AGX_RETAIN([NSValue valueWithCGPoint:CGPointMake(0, _topRight.CGPointValue.y)]);
        AGX_RELEASE(_bottomLeft);
        _bottomLeft = AGX_RETAIN([NSValue valueWithCGPoint:CGPointMake(0, _bottomRight.CGPointValue.y)]);
    } else if (!_topRight) {
        _topRight = AGX_RETAIN([NSValue valueWithCGPoint:CGPointMake(_image.width - 1, _topLeft.CGPointValue.y)]);
        AGX_RELEASE(_bottomRight);
        _bottomRight = AGX_RETAIN([NSValue valueWithCGPoint:CGPointMake(_image.width - 1, _bottomLeft.CGPointValue.y)]);
    }

    _minX = (int) MIN(_topLeft.CGPointValue.x, _bottomLeft.CGPointValue.x);
    _maxX = (int) MAX(_topRight.CGPointValue.x, _bottomRight.CGPointValue.x);
    _minY = (int) MIN(_topLeft.CGPointValue.y, _topRight.CGPointValue.y);
    _maxY = (int) MAX(_bottomLeft.CGPointValue.y, _bottomRight.CGPointValue.y);
}

@end
