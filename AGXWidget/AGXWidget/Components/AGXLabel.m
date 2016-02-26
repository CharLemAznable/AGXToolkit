//
//  AGXLabel.m
//  AGXWidget
//
//  Created by Char Aznable on 16/2/25.
//  Copyright © 2016年 AI-CUC-EC. All rights reserved.
//

#import "AGXLabel.h"
#import <CoreText/CoreText.h>
#import <AGXCore/AGXCore/AGXAdapt.h>
#import <AGXCore/AGXCore/AGXGeometry.h>
#import <AGXCore/AGXCore/NSCoder+AGXCore.h>
#import <AGXCore/AGXCore/UIView+AGXCore.h>
#import <AGXCore/AGXCore/UILabel+AGXCore.h>

@implementation AGXLabel

- (void)agxInitial {
    [super agxInitial];
    self.userInteractionEnabled = YES;
    [self addGestureRecognizer:AGX_AUTORELEASE([[UILongPressGestureRecognizer alloc]
                                                initWithTarget:self action:@selector(longPress:)])];
    self.backgroundColor = [UIColor clearColor];
    _linesSpacing = 0;
}

- (void)dealloc {
    [[UIMenuController sharedMenuController] setMenuVisible:NO animated:NO];
    _dataSource = nil;
    AGX_SUPER_DEALLOC;
}

- (AGX_INSTANCETYPE)initWithCoder:(NSCoder *)aDecoder {
    if (AGX_EXPECT_T(self = [super initWithCoder:aDecoder])) {
        _canCopy = [aDecoder decodeBoolForKey:@"canCopy"];
        _linesSpacing = [aDecoder decodeCGFloatForKey:@"linesSpacing"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [super encodeWithCoder:aCoder];
    [aCoder encodeBool:_canCopy forKey:@"canCopy"];
    [aCoder encodeCGFloat:_linesSpacing forKey:@"linesSpacing"];
}

- (void)longPress:(UILongPressGestureRecognizer *)gestureRecognizer  {
    if (gestureRecognizer.state == UIGestureRecognizerStateBegan) {
        [gestureRecognizer.view becomeFirstResponder];
        
        UIMenuController *menuController = [UIMenuController sharedMenuController];
        NSString *copyTitle = [_dataSource respondsToSelector:@selector(menuTitleStringOfCopyInLabel:)]
        ? [_dataSource menuTitleStringOfCopyInLabel:self] : @"复制";
        menuController.menuItems = @[AGX_AUTORELEASE([[UIMenuItem alloc] initWithTitle:copyTitle
                                                                                action:@selector(agxCopy:)])];
        
        if ([_dataSource respondsToSelector:@selector(menuLocationPointInLabel:)]) {
            [menuController setTargetRect:AGX_CGRectMake([_dataSource menuLocationPointInLabel:self], CGSizeZero)
                                   inView:gestureRecognizer.view];
        } else {
            [menuController setTargetRect:AGX_CGRectMake([gestureRecognizer locationInView:gestureRecognizer.view], CGSizeZero)
                                   inView:gestureRecognizer.view];
        }
        [menuController setMenuVisible:YES animated:YES];
    }
}

- (BOOL)canBecomeFirstResponder {
    return YES;
}

- (BOOL)canPerformAction:(SEL)action withSender:(id)sender {
    return _canCopy && action == @selector(agxCopy:);
}

- (void)agxCopy:(id)sender {
    [UIPasteboard generalPasteboard].string = self.text;
}

- (void)drawTextInRect:(CGRect)rect {
    NSMutableAttributedString *attributedStr = [[NSMutableAttributedString alloc]
                                                initWithString:self.text?:@""
                                                attributes:NSAttributedStringAttributesFromAGXLinesSpacingLabel(self)];
    CTFramesetterRef fsRef = CTFramesetterCreateWithAttributedString((CFAttributedStringRef)attributedStr);
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathAddRect(path, NULL, CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.height));
    CTFrameRef frame = CTFramesetterCreateFrame(fsRef, CFRangeMake(0, 0), path, NULL);
    //翻转坐标系统（文本原来是倒的要翻转下）
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetTextMatrix(context, CGAffineTransformIdentity);
    CGContextTranslateCTM(context, 0, self.bounds.size.height);
    CGContextScaleCTM(context, 1.0, -1.0);
    //画出文本
    CTFrameDraw(frame, context);
    UIGraphicsPushContext(context);
    //释放
    CFRelease(frame);
    CFRelease(path);
    CFRelease(fsRef);
    
    AGX_RELEASE(attributedStr);
}

- (void)setLinesSpacing:(CGFloat)linesSpacing {
    _linesSpacing = linesSpacing;
    [self setNeedsDisplay];
}

- (CGSize)sizeThatConstraintToSize:(CGSize)size {
    NSMutableAttributedString *attributedStr = [[NSMutableAttributedString alloc]
                                                initWithString:self.text?:@""
                                                attributes:NSAttributedStringAttributesFromAGXLinesSpacingLabel(self)];
    CTFramesetterRef fsRef = CTFramesetterCreateWithAttributedString((CFAttributedStringRef)attributedStr);
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathAddRect(path, NULL, CGRectMake(0, 0, size.width, size.height));
    CTFrameRef frame = CTFramesetterCreateFrame(fsRef, CFRangeMake(0, 0), path, NULL);
    CFRelease(path);
    CFRelease(fsRef);
    AGX_RELEASE(attributedStr);
    
    NSUInteger lineCount = [(NSArray *)CTFrameGetLines(frame) count];
    CFRelease(frame);
    CGSize originalSize = [super sizeThatConstraintToSize:size];
    originalSize.height += (MAX(1, lineCount) - 1) * _linesSpacing;
    return originalSize;
}

#pragma mark - private methods

AGX_STATIC_INLINE CTTextAlignment CTTextAlignmentFromAGXLinesSpacingLabel(AGXLabel *label) {
    if (label.textAlignment == AGXTextAlignmentLeft) return agxkCTTextAlignmentLeft;
    else if (label.textAlignment == AGXTextAlignmentCenter) return agxkCTTextAlignmentCenter;
    else if (label.textAlignment == AGXTextAlignmentRight) return agxkCTTextAlignmentRight;
    else return agxkCTTextAlignmentNatural;
}

AGX_STATIC NSDictionary *NSAttributedStringAttributesFromAGXLinesSpacingLabel(AGXLabel *label) {
    NSMutableDictionary *mutableAttributes = [NSMutableDictionary dictionary];
    
    if ([NSMutableParagraphStyle class]) {
        mutableAttributes[(NSString *)kCTFontAttributeName] = label.font;
        mutableAttributes[(NSString *)kCTForegroundColorAttributeName] = label.textColor;
        
        NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
        paragraphStyle.alignment = label.textAlignment;
        paragraphStyle.lineSpacing = label.linesSpacing;
        
        mutableAttributes[(NSString *)kCTParagraphStyleAttributeName] = paragraphStyle;
        AGX_RELEASE(paragraphStyle);
    } else {
        CTFontRef font = CTFontCreateWithName((AGX_BRIDGE CFStringRef)label.font.fontName, label.font.pointSize, NULL);
        mutableAttributes[(NSString *)kCTFontAttributeName] = (AGX_BRIDGE id)font;
        CFRelease(font);
        
        mutableAttributes[(NSString *)kCTForegroundColorAttributeName] = (id)label.textColor.CGColor;
        
        CTTextAlignment alignment = CTTextAlignmentFromAGXLinesSpacingLabel(label);
        CGFloat lineSpacing = label.linesSpacing;
        
        CTParagraphStyleSetting paragraphStyles[] = {
            {.spec = kCTParagraphStyleSpecifierAlignment,
                .valueSize = sizeof(CTTextAlignment),
                .value = (const void *)&alignment},
            {.spec = kCTParagraphStyleSpecifierLineSpacing,
                .valueSize = sizeof(CGFloat),
                .value = (const void *)&lineSpacing}
        };
        CTParagraphStyleRef paragraphStyle = CTParagraphStyleCreate(paragraphStyles, 2);
        mutableAttributes[(NSString *)kCTParagraphStyleAttributeName] = (AGX_BRIDGE id)paragraphStyle;
        CFRelease(paragraphStyle);
    }
    return [NSDictionary dictionaryWithDictionary:mutableAttributes];
}

@end
