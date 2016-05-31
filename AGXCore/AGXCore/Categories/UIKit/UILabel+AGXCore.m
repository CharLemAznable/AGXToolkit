//
//  UILabel+AGXCore.m
//  AGXCore
//
//  Created by Char Aznable on 16/2/17.
//  Copyright © 2016年 AI-CUC-EC. All rights reserved.
//

#import "UILabel+AGXCore.h"
#import <CoreText/CoreText.h>
#import "NSObject+AGXCore.h"
#import "NSNumber+AGXCore.h"
#import "NSCoder+AGXCore.h"
#import "UIView+AGXCore.h"

NSString *const agxLinesSpacingKey = @"agxLinesSpacing";

@category_implementation(UILabel, AGXCore)

- (void)agxInitial {
    [super agxInitial];
    self.backgroundColor = [UIColor clearColor];
}

- (void)agxDecode:(NSCoder *)coder {
    [super agxDecode:coder];
    [self setRetainProperty:[coder decodeObjectForKey:agxLinesSpacingKey] forAssociateKey:agxLinesSpacingKey];
}

- (void)agxEncode:(NSCoder *)coder {
    [super agxEncode:coder];
    [coder encodeObject:[self retainPropertyForAssociateKey:agxLinesSpacingKey] forKey:agxLinesSpacingKey];
}

- (CGFloat)linesSpacing {
    return [[self retainPropertyForAssociateKey:agxLinesSpacingKey] cgfloatValue];
}

- (void)setLinesSpacing:(CGFloat)linesSpacing {
    [self setKVORetainProperty:@(linesSpacing) forAssociateKey:agxLinesSpacingKey];
    [self setNeedsDisplay];
}

- (void)setNeedsDisplay {
    NSMutableParagraphStyle *paragraphStyle = NSMutableParagraphStyle.instance;
    paragraphStyle.alignment = self.textAlignment;
    paragraphStyle.lineBreakMode = self.lineBreakMode;
    paragraphStyle.lineSpacing = self.linesSpacing;
    NSMutableAttributedString *attributedText = [self.attributedText mutableCopy];
    [attributedText setAttributes:@{(NSString *)kCTParagraphStyleAttributeName: paragraphStyle}
                            range:NSMakeRange(0, self.text.length)];
    self.attributedText = AGX_AUTORELEASE(attributedText);
    [super setNeedsDisplay];
}

@end
