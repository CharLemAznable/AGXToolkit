//
//  AGXGeometry.m
//  AGXCore
//
//  Created by Char Aznable on 16/2/4.
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

AGX_INLINE CGPoint AGX_StartPointOfDiagonalLine(CGSize rectSize, CGVector diagonalDirection) {
    return CGPointMake(rectSize.width * MAX(0, -diagonalDirection.dx), rectSize.height * MAX(0, -diagonalDirection.dy));
}

AGX_INLINE CGPoint AGX_EndPointOfDiagonalLine(CGSize rectSize, CGVector diagonalDirection) {
    return CGPointMake(rectSize.width * MAX(0, diagonalDirection.dx), rectSize.height * MAX(0, diagonalDirection.dy));
}
