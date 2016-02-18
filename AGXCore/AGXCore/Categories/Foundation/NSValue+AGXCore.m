//
//  NSValue+AGXCore.m
//  AGXCore
//
//  Created by Char Aznable on 16/2/4.
//  Copyright © 2016年 AI-CUC-EC. All rights reserved.
//

#import "NSValue+AGXCore.h"
#import "NSString+AGXCore.h"

@category_implementation(NSValue, AGXCore)

- (id)valueForKey:(NSString *)key {
    const char *objCType = [self objCType];
    if (strcmp(objCType, @encode(CGPoint)) == 0) {
        CGPoint p = [self CGPointValue];
        if ([key isCaseInsensitiveEqualToString:@"x"]) return @(p.x);
        else if ([key isCaseInsensitiveEqualToString:@"y"]) return @(p.y);
        
    } else if (strcmp(objCType, @encode(CGVector)) == 0) {
        CGVector v = [self CGVectorValue];
        if ([key isCaseInsensitiveEqualToString:@"dx"]) return @(v.dx);
        else if ([key isCaseInsensitiveEqualToString:@"dy"]) return @(v.dy);
        
    } else if (strcmp(objCType, @encode(CGSize)) == 0) {
        CGSize s = [self CGSizeValue];
        if ([key isCaseInsensitiveEqualToString:@"width"]) return @(s.width);
        else if ([key isCaseInsensitiveEqualToString:@"height"]) return @(s.height);
        
    } else if (strcmp(objCType, @encode(CGRect)) == 0) {
        CGRect r = [self CGRectValue];
        if ([key isCaseInsensitiveEqualToString:@"origin"]) return [NSValue valueWithCGPoint:r.origin];
        else if ([key isCaseInsensitiveEqualToString:@"size"]) return [NSValue valueWithCGSize:r.size];
        
    } else if (strcmp(objCType, @encode(CGAffineTransform)) == 0) {
        CGAffineTransform t = [self CGAffineTransformValue];
        if ([key isCaseInsensitiveEqualToString:@"a"]) return @(t.a);
        else if ([key isCaseInsensitiveEqualToString:@"b"]) return @(t.b);
        else if ([key isCaseInsensitiveEqualToString:@"c"]) return @(t.c);
        else if ([key isCaseInsensitiveEqualToString:@"d"]) return @(t.d);
        else if ([key isCaseInsensitiveEqualToString:@"tx"]) return @(t.tx);
        else if ([key isCaseInsensitiveEqualToString:@"ty"]) return @(t.ty);
        
    } else if (strcmp(objCType, @encode(UIEdgeInsets)) == 0) {
        UIEdgeInsets e = [self UIEdgeInsetsValue];
        if ([key isCaseInsensitiveEqualToString:@"top"]) return @(e.top);
        else if ([key isCaseInsensitiveEqualToString:@"left"]) return @(e.left);
        else if ([key isCaseInsensitiveEqualToString:@"bottom"]) return @(e.bottom);
        else if ([key isCaseInsensitiveEqualToString:@"right"]) return @(e.right);
        
    } else if (strcmp(objCType, @encode(UIOffset)) == 0) {
        UIOffset o = [self UIOffsetValue];
        if ([key isCaseInsensitiveEqualToString:@"horizontal"]) return @(o.horizontal);
        else if ([key isCaseInsensitiveEqualToString:@"vertical"]) return @(o.vertical);
        
    }
    return [super valueForKey:key];
}

- (id)valueForKeyPath:(NSString *)keyPath {
    if (strcmp([self objCType], @encode(CGRect)) == 0) {
        CGRect r = [self CGRectValue];
        if ([keyPath isCaseInsensitiveEqualToString:@"origin.x"]) return @(r.origin.x);
        else if ([keyPath isCaseInsensitiveEqualToString:@"origin.y"]) return @(r.origin.y);
        else if ([keyPath isCaseInsensitiveEqualToString:@"size.width"]) return @(r.size.width);
        else if ([keyPath isCaseInsensitiveEqualToString:@"size.height"]) return @(r.size.height);
    }
    return [super valueForKeyPath:keyPath];
}

@end
