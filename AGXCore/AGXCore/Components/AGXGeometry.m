//
//  AGXGeometry.m
//  AGXCore
//
//  Created by Char Aznable on 2016/2/4.
//  Copyright © 2016年 AI-CUC-EC. All rights reserved.
//

#import "AGXGeometry.h"

AGX_INLINE AGX_OVERLOAD CGRect AGX_CGRectMake(CGPoint origin, CGSize size) {
    return CGRectMake(origin.x, origin.y, size.width, size.height);
}

AGX_INLINE AGX_OVERLOAD CGRect AGX_CGRectMake(CGSize size) {
    return CGRectMake(0, 0, size.width, size.height);
}

AGX_INLINE AGX_OVERLOAD CGRect AGX_CGRectMake(CGFloat width, CGFloat height) {
    return CGRectMake(0, 0, width, height);
}

AGX_INLINE CGPoint AGX_CGRectGetTopLeft(CGRect rect) {
    return CGPointMake(CGRectGetMinX(rect), CGRectGetMinY(rect));
}

AGX_INLINE CGPoint AGX_CGRectGetTopRight(CGRect rect) {
    return CGPointMake(CGRectGetMaxX(rect), CGRectGetMinY(rect));
}

AGX_INLINE CGPoint AGX_CGRectGetBottomLeft(CGRect rect) {
    return CGPointMake(CGRectGetMinX(rect), CGRectGetMaxY(rect));
}

AGX_INLINE CGPoint AGX_CGRectGetBottomRight(CGRect rect) {
    return CGPointMake(CGRectGetMaxX(rect), CGRectGetMaxY(rect));
}

AGX_INLINE CGSize AGX_CGSizeFromUIOffset(UIOffset offset) {
    return CGSizeMake(offset.horizontal, offset.vertical);
}

AGX_INLINE UIOffset AGX_UIOffsetFromCGSize(CGSize size) {
    return UIOffsetMake(size.width, size.height);
}

AGX_INLINE CGVector AGX_CGVectorFromDirection(AGXDirection direction) {
    switch(direction) {
        case AGXDirectionNorth:return CGVectorMake(0, 1);
        case AGXDirectionNorthEast:return CGVectorMake(1, 1);
        case AGXDirectionEast:return CGVectorMake(1, 0);
        case AGXDirectionSouthEast:return CGVectorMake(1, -1);
        case AGXDirectionSouth:return CGVectorMake(0, -1);
        case AGXDirectionSouthWest:return CGVectorMake(-1, -1);
        case AGXDirectionWest:return CGVectorMake(-1, 0);
        case AGXDirectionNorthWest:return CGVectorMake(-1, 1);
    }
}

AGX_INLINE UIEdgeInsets AGX_UIEdgeInsetsAddUIEdgeInsets(UIEdgeInsets insets1, UIEdgeInsets insets2) {
    return UIEdgeInsetsMake(insets1.top+insets2.top, insets1.left+insets2.left,
                            insets1.bottom+insets2.bottom, insets1.right+insets2.right);
}

AGX_INLINE UIEdgeInsets AGX_UIEdgeInsetsSubtractUIEdgeInsets(UIEdgeInsets insets1, UIEdgeInsets insets2) {
    return UIEdgeInsetsMake(insets1.top-insets2.top, insets1.left-insets2.left,
                            insets1.bottom-insets2.bottom, insets1.right-insets2.right);
}
