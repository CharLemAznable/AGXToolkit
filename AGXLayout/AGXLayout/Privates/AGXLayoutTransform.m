//
//  AGXLayoutTransform.m
//  AGXLayout
//
//  Created by Char Aznable on 2016/2/21.
//  Copyright © 2016年 AI-CUC-EC. All rights reserved.
//

#import <AGXCore/AGXCore/NSObject+AGXCore.h>
#import <AGXCore/AGXCore/NSNumber+AGXCore.h>
#import <AGXCore/AGXCore/NSValue+AGXCore.h>
#import <AGXCore/AGXCore/NSExpression+AGXCore.h>
#import "AGXLayoutTransform.h"
#import "AGXLayoutConstraint.h"

@implementation AGXLayoutTransform

- (void)dealloc {
    _view = nil;
    AGX_RELEASE(_left);
    AGX_RELEASE(_right);
    AGX_RELEASE(_top);
    AGX_RELEASE(_bottom);
    AGX_RELEASE(_width);
    AGX_RELEASE(_height);
    AGX_RELEASE(_centerX);
    AGX_RELEASE(_centerY);
    AGX_SUPER_DEALLOC;
}

- (BOOL)isEqual:(id)object {
    if (object == self) return YES;
    if AGX_EXPECT_F(!object || ![object isKindOfClass:[AGXLayoutTransform class]]) return NO;
    return [self isEqualToLayoutTransform:object];
}

- (BOOL)isEqualToLayoutTransform:(AGXLayoutTransform *)transform {
    if (transform == self) return YES;
    return
    ((_view == nil && transform.view == nil) || [_view isEqual:transform.view]) &&
    ((_left == nil && transform.left == nil) || [_left isEqual:transform.left]) &&
    ((_right == nil && transform.right == nil) || [_right isEqual:transform.right]) &&
    ((_top == nil && transform.top == nil) || [_top isEqual:transform.top]) &&
    ((_bottom == nil && transform.bottom == nil) || [_bottom isEqual:transform.bottom]) &&
    ((_width == nil && transform.width == nil) || [_width isEqual:transform.width]) &&
    ((_height == nil && transform.height == nil) || [_height isEqual:transform.height]) &&
    ((_centerX == nil && transform.centerX == nil) || [_centerX isEqual:transform.centerX]) &&
    ((_centerY == nil && transform.centerY == nil) || [_centerY isEqual:transform.centerY]);
}

- (CGRect)transformRect {
    CGRect result = CGRectZero;
    if AGX_EXPECT_F(!_view) return result;
    constraintOriginAndSize(_view, _view.bounds.size.width,
                            _left, _right, _width, _centerX,
                            &result.origin.x, &result.size.width);
    constraintOriginAndSize(_view, _view.bounds.size.height,
                            _top, _bottom, _height, _centerY,
                            &result.origin.y, &result.size.height);
    return result;
}

#pragma mark - transform implementation functions -

AGX_STATIC void constraintOriginAndSize(UIView *view, CGFloat viewSize,
                                        id marginConstraint1, id marginConstraint2,
                                        id sizeConstraint, id centerConstraint,
                                        CGFloat *resultOrigin, CGFloat *resultSize) {
    CGFloat margin1 = constraintValue(view, marginConstraint1);
    CGFloat margin2 = constraintValue(view, marginConstraint2);
    *resultSize = sizeConstraint ? constraintValue(view, sizeConstraint) : viewSize - margin1 - margin2;

    // adjust origin:
    // SS           : superviewSize
    // S            : size
    // m1           : margin1
    // m2           : margin2
    // capacity     = SS - m1 - m2;
    // center       = capacity / 2 + m1
    //              = (SS + m1 - m2) / 2;
    // leftCoord    = center - S / 2
    //              = (SS + m1 - m2 - S) / 2;
    CGFloat center = 0;
    if (!centerConstraint) {
        if (!marginConstraint1 && marginConstraint2) margin1 = viewSize - *resultSize - margin2;
        if (!marginConstraint2 && marginConstraint1) margin2 = viewSize - *resultSize - margin1;
        center = (viewSize + margin1 - margin2) / 2;
    } else center = constraintValue(view, centerConstraint);
    *resultOrigin = center - *resultSize / 2;
}

AGX_STATIC CGFloat constraintValue(UIView *view, id constraint) {
    if ([constraint isKindOfClass:[NSNumber class]]) {
        return [(NSNumber *)constraint cgfloatValue];
    } else if ([constraint isKindOfClass:[AGXLayoutConstraint class]]) {
        AGXLayoutConstraintBlock block = [(AGXLayoutConstraint *)constraint block];
        return (block && view) ? block(view) : 0;
    } else if ([constraint isKindOfClass:[NSExpression class]]) {
        id result = [(NSExpression *)constraint expressionValueWithObject:view context:nil];
        return [result respondsToSelector:@selector(cgfloatValue)] ? [result cgfloatValue] : 0;
    } else if ([constraint isKindOfClass:[NSString class]]) {
        return constraintValue(view, [NSExpression expressionWithParametricFormat:constraint]);
    }
    return 0;
}

@end
