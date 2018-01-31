//
//  UILabel+AGXCore.m
//  AGXCore
//
//  Created by Char Aznable on 2016/2/17.
//  Copyright © 2016年 AI-CUC-EC. All rights reserved.
//

#import <CoreText/CoreText.h>
#import "UILabel+AGXCore.h"
#import "NSObject+AGXCore.h"
#import "NSNumber+AGXCore.h"
#import "NSCoder+AGXCore.h"
#import "UIView+AGXCore.h"

NSString *const agxLinesSpacingKey = @"agxLinesSpacing";
NSString *const agxParagraphSpacingKey = @"agxParagraphSpacing";

@category_implementation(UILabel, AGXCore)

- (void)agxInitial {
    [super agxInitial];
    self.backgroundColor = UIColor.clearColor;
}

- (void)agxDecode:(NSCoder *)coder {
    [super agxDecode:coder];
    [self setRetainProperty:[coder decodeObjectForKey:agxLinesSpacingKey] forAssociateKey:agxLinesSpacingKey];
    [self setRetainProperty:[coder decodeObjectForKey:agxParagraphSpacingKey] forAssociateKey:agxParagraphSpacingKey];
}

- (void)agxEncode:(NSCoder *)coder {
    [super agxEncode:coder];
    [coder encodeObject:[self retainPropertyForAssociateKey:agxLinesSpacingKey] forKey:agxLinesSpacingKey];
    [coder encodeObject:[self retainPropertyForAssociateKey:agxParagraphSpacingKey] forKey:agxParagraphSpacingKey];
}

- (void)AGXCore_UILabel_dealloc {
    [self setRetainProperty:NULL forAssociateKey:agxLinesSpacingKey];
    [self setRetainProperty:NULL forAssociateKey:agxParagraphSpacingKey];
    [self AGXCore_UILabel_dealloc];
}

- (void)AGXCore_UILabel_setText:(NSString *)text {
    [self AGXCore_UILabel_setText:text];
    [self p_updateAttributedText];
}

- (void)AGXCore_UILabel_setTextAlignment:(NSTextAlignment)textAlignment {
    [self AGXCore_UILabel_setTextAlignment:textAlignment];
    [self p_updateAttributedText];
}

- (void)AGXCore_UILabel_setLineBreakMode:(NSLineBreakMode)lineBreakMode {
    [self AGXCore_UILabel_setLineBreakMode:lineBreakMode];
    [self p_updateAttributedText];
}

- (CGFloat)linesSpacing {
    return [[self retainPropertyForAssociateKey:agxLinesSpacingKey] cgfloatValue];
}

- (void)setLinesSpacing:(CGFloat)linesSpacing {
    [self setKVORetainProperty:@(linesSpacing) forAssociateKey:agxLinesSpacingKey];
    [self p_updateAttributedText];
}

- (CGFloat)paragraphSpacing {
    return [[self retainPropertyForAssociateKey:agxParagraphSpacingKey] cgfloatValue];
}

- (void)setParagraphSpacing:(CGFloat)paragraphSpacing {
    [self setKVORetainProperty:@(paragraphSpacing) forAssociateKey:agxParagraphSpacingKey];
    [self p_updateAttributedText];
}

+ (void)load {
    agx_once
    ([UILabel swizzleInstanceOriSelector:NSSelectorFromString(@"dealloc")
                         withNewSelector:@selector(AGXCore_UILabel_dealloc)];
     [UILabel swizzleInstanceOriSelector:@selector(setText:)
                         withNewSelector:@selector(AGXCore_UILabel_setText:)];
     [UILabel swizzleInstanceOriSelector:@selector(setTextAlignment:)
                         withNewSelector:@selector(AGXCore_UILabel_setTextAlignment:)];
     [UILabel swizzleInstanceOriSelector:@selector(setLineBreakMode:)
                         withNewSelector:@selector(AGXCore_UILabel_setLineBreakMode:)];)
}

- (void)p_updateAttributedText {
    NSMutableParagraphStyle *paragraphStyle = NSMutableParagraphStyle.instance;
    paragraphStyle.alignment = self.textAlignment;
    paragraphStyle.lineBreakMode = self.lineBreakMode;
    paragraphStyle.lineSpacing = self.linesSpacing;
    paragraphStyle.paragraphSpacing = self.paragraphSpacing;
    NSMutableAttributedString *attributedText =
    [[NSMutableAttributedString alloc] initWithAttributedString:self.attributedText];
    [attributedText setAttributes:@{NSParagraphStyleAttributeName: paragraphStyle}
                            range:NSMakeRange(0, self.text.length)];
    self.attributedText = AGX_AUTORELEASE(attributedText);

    [self setNeedsDisplay];
}

@end
