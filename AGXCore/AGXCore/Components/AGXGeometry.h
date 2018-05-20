//
//  AGXGeometry.h
//  AGXCore
//
//  Created by Char Aznable on 2016/2/4.
//  Copyright © 2016年 AI-CUC-EC. All rights reserved.
//

#ifndef AGXCore_AGXGeometry_h
#define AGXCore_AGXGeometry_h

#import <CoreGraphics/CGGeometry.h>
#import <UIKit/UIGeometry.h>
#import "AGXObjC.h"

typedef NS_ENUM(NSUInteger, AGXDirection) {
    AGXDirectionNorth,
    AGXDirectionNorthEast,
    AGXDirectionEast,
    AGXDirectionSouthEast,
    AGXDirectionSouth,
    AGXDirectionSouthWest,
    AGXDirectionWest,
    AGXDirectionNorthWest
};

AGX_EXTERN AGX_OVERLOAD CGRect AGX_CGRectMake(CGPoint origin, CGSize size);
AGX_EXTERN AGX_OVERLOAD CGRect AGX_CGRectMake(CGSize size); // default origin: 0, 0
AGX_EXTERN AGX_OVERLOAD CGRect AGX_CGRectMake(CGFloat width, CGFloat height); // default origin: 0, 0
AGX_EXTERN CGPoint AGX_CGRectGetTopLeft(CGRect rect);
AGX_EXTERN CGPoint AGX_CGRectGetTopRight(CGRect rect);
AGX_EXTERN CGPoint AGX_CGRectGetBottomLeft(CGRect rect);
AGX_EXTERN CGPoint AGX_CGRectGetBottomRight(CGRect rect);
AGX_EXTERN CGSize AGX_CGSizeFromUIOffset(UIOffset offset);
AGX_EXTERN UIOffset AGX_UIOffsetFromCGSize(CGSize size);
AGX_EXTERN CGVector AGX_CGVectorFromDirection(AGXDirection direction);
AGX_EXTERN UIEdgeInsets AGX_UIEdgeInsetsAddUIEdgeInsets(UIEdgeInsets insets1, UIEdgeInsets insets2);
AGX_EXTERN UIEdgeInsets AGX_UIEdgeInsetsSubtractUIEdgeInsets(UIEdgeInsets insets1, UIEdgeInsets insets2);

#endif /* AGXCore_AGXGeometry_h */
