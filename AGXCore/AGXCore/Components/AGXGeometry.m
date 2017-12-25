//
//  AGXGeometry.m
//  AGXCore
//
//  Created by Char Aznable on 2016/2/4.
//  Copyright © 2016年 AI-CUC-EC. All rights reserved.
//

#import "AGXGeometry.h"

AGX_INLINE CGRect AGX_CGRectMake(CGPoint origin, CGSize size) {
    return CGRectMake(origin.x, origin.y, size.width, size.height);
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
