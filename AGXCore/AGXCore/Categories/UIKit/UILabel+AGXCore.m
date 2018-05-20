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

NSString *const agxParagraphStyleLinesSpacingKey = @"agxParagraphStyleLinesSpacing";
NSString *const agxParagraphStyleParagraphSpacingKey = @"agxParagraphStyleParagraphSpacing";

@category_implementation(UILabel, AGXCore)

- (void)agxInitial {
    [super agxInitial];
    self.backgroundColor = UIColor.clearColor;
}

- (void)agxDecode:(NSCoder *)coder {
    [super agxDecode:coder];
    [self setRetainProperty:[coder decodeObjectForKey:agxParagraphStyleLinesSpacingKey]
            forAssociateKey:agxParagraphStyleLinesSpacingKey];
    [self setRetainProperty:[coder decodeObjectForKey:agxParagraphStyleParagraphSpacingKey]
            forAssociateKey:agxParagraphStyleParagraphSpacingKey];
}

- (void)agxEncode:(NSCoder *)coder {
    [super agxEncode:coder];
    [coder encodeObject:[self retainPropertyForAssociateKey:agxParagraphStyleLinesSpacingKey]
                 forKey:agxParagraphStyleLinesSpacingKey];
    [coder encodeObject:[self retainPropertyForAssociateKey:agxParagraphStyleParagraphSpacingKey]
                 forKey:agxParagraphStyleParagraphSpacingKey];
}

- (void)AGXCore_UILabel_dealloc {
    [self setRetainProperty:NULL forAssociateKey:agxParagraphStyleLinesSpacingKey];
    [self setRetainProperty:NULL forAssociateKey:agxParagraphStyleParagraphSpacingKey];
    [self AGXCore_UILabel_dealloc];
}

- (void)AGXCore_UILabel_setText:(NSString *)text {
    [self AGXCore_UILabel_setText:text];
    [self p_updateAttributedText];
}

- (void)AGXCore_UILabel_setFont:(UIFont *)font {
    [self AGXCore_UILabel_setFont:font];
    [self p_updateAttributedText];
}

- (void)AGXCore_UILabel_setTextColor:(UIColor *)textColor {
    [self AGXCore_UILabel_setTextColor:textColor];
    [self p_updateAttributedText];
}

- (void)AGXCore_UILabel_setShadowColor:(UIColor *)shadowColor {
    [self AGXCore_UILabel_setShadowColor:shadowColor];
    [self p_updateAttributedText];
}

- (void)AGXCore_UILabel_setShadowOffset:(CGSize)shadowOffset {
    [self AGXCore_UILabel_setShadowOffset:shadowOffset];
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

- (CGFloat)paragraphStyleLinesSpacing {
    return [[self retainPropertyForAssociateKey:agxParagraphStyleLinesSpacingKey] cgfloatValue];
}

- (void)setParagraphStyleLinesSpacing:(CGFloat)paragraphStyleLinesSpacing {
    [self setKVORetainProperty:@(paragraphStyleLinesSpacing) forAssociateKey:agxParagraphStyleLinesSpacingKey];
    [self p_updateAttributedText];
}

- (CGFloat)paragraphStyleParagraphSpacing {
    return [[self retainPropertyForAssociateKey:agxParagraphStyleParagraphSpacingKey] cgfloatValue];
}

- (void)setParagraphStyleParagraphSpacing:(CGFloat)paragraphStyleParagraphSpacing {
    [self setKVORetainProperty:@(paragraphStyleParagraphSpacing) forAssociateKey:agxParagraphStyleParagraphSpacingKey];
    [self p_updateAttributedText];
}

+ (void)load {
    agx_once
    ([UILabel swizzleInstanceOriSelector:NSSelectorFromString(@"dealloc")
                         withNewSelector:@selector(AGXCore_UILabel_dealloc)];
     [UILabel swizzleInstanceOriSelector:@selector(setText:)
                         withNewSelector:@selector(AGXCore_UILabel_setText:)];
     [UILabel swizzleInstanceOriSelector:@selector(setFont:)
                         withNewSelector:@selector(AGXCore_UILabel_setFont:)];
     [UILabel swizzleInstanceOriSelector:@selector(setTextColor:)
                         withNewSelector:@selector(AGXCore_UILabel_setTextColor:)];
     [UILabel swizzleInstanceOriSelector:@selector(setShadowColor:)
                         withNewSelector:@selector(AGXCore_UILabel_setShadowColor:)];
     [UILabel swizzleInstanceOriSelector:@selector(setShadowOffset:)
                         withNewSelector:@selector(AGXCore_UILabel_setShadowOffset:)];
     [UILabel swizzleInstanceOriSelector:@selector(setTextAlignment:)
                         withNewSelector:@selector(AGXCore_UILabel_setTextAlignment:)];
     [UILabel swizzleInstanceOriSelector:@selector(setLineBreakMode:)
                         withNewSelector:@selector(AGXCore_UILabel_setLineBreakMode:)];);
}

- (void)p_updateAttributedText {
    NSShadow *shadow = NSShadow.instance;
    shadow.shadowColor = self.shadowColor;
    shadow.shadowOffset = self.shadowOffset;
    NSMutableParagraphStyle *paragraphStyle = NSMutableParagraphStyle.instance;
    paragraphStyle.alignment = self.textAlignment;
    paragraphStyle.lineBreakMode = self.lineBreakMode;
    paragraphStyle.lineSpacing = self.paragraphStyleLinesSpacing;
    paragraphStyle.paragraphSpacing = self.paragraphStyleParagraphSpacing;
    NSMutableAttributedString *attributedText =
    [[NSMutableAttributedString alloc] initWithAttributedString:self.attributedText];
    [attributedText setAttributes:@{NSFontAttributeName: self.font, NSForegroundColorAttributeName: self.textColor,
                                    NSShadowAttributeName: shadow, NSParagraphStyleAttributeName: paragraphStyle}
                            range:NSMakeRange(0, self.text.length)];
    self.attributedText = AGX_AUTORELEASE(attributedText);

    [self setNeedsDisplay];
}

@end
