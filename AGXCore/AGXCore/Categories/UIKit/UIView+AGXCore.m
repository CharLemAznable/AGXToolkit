//
//  UIView+AGXCore.m
//  AGXCore
//
//  Created by Char Aznable on 16/2/17.
//  Copyright © 2016年 AI-CUC-EC. All rights reserved.
//

#import "UIView+AGXCore.h"
#import "AGXAppearance.h"

@category_implementation(UIView, AGXCore)

- (void)agxInitial {}
- (void)agxDecode:(NSCoder *)coder {}
- (void)agxEncode:(NSCoder *)coder {}

NSString *const agxBackgroundImageViewKVOKey = @"agxBackgroundImageView";

- (UIImage *)backgroundImage {
    return ((UIImageView *)[self retainPropertyForAssociateKey:agxBackgroundImageViewKVOKey]).image;
}

- (void)setBackgroundImage:(UIImage *)backgroundImage {
    UIImageView *backgroundImageView = [self retainPropertyForAssociateKey:agxBackgroundImageViewKVOKey];
    if (!backgroundImageView) {
        backgroundImageView = UIImageView.instance;
        [self setKVORetainProperty:backgroundImageView forAssociateKey:agxBackgroundImageViewKVOKey];
    }
    backgroundImageView.image = backgroundImage;
    [self setNeedsLayout];
}

- (BOOL)masksToBounds {
    return self.layer.masksToBounds;
}

- (void)setMasksToBounds:(BOOL)masksToBounds {
    self.layer.masksToBounds = masksToBounds;
}

- (CGFloat)cornerRadius {
    return self.layer.cornerRadius;
}

- (void)setCornerRadius:(CGFloat)cornerRadius {
    self.layer.cornerRadius = cornerRadius;
}

- (CGFloat)borderWidth {
    return self.layer.borderWidth;
}

- (void)setBorderWidth:(CGFloat)borderWidth {
    self.layer.borderWidth = borderWidth;
}

+ (CGFloat)borderWidth {
    return [(UIView *)APPEARANCE borderWidth];
}

+ (void)setBorderWidth:(CGFloat)borderWidth {
    [(UIView *)APPEARANCE setBorderWidth:borderWidth];
}

- (UIColor *)borderColor {
    return [UIColor colorWithCGColor:self.layer.borderColor];
}

- (void)setBorderColor:(UIColor *)borderColor {
    self.layer.borderColor = borderColor.CGColor;
}

+ (UIColor *)borderColor {
    return [(UIView *)APPEARANCE borderColor];
}

+ (void)setBorderColor:(UIColor *)borderColor {
    [(UIView *)APPEARANCE setBorderColor:borderColor];
}

- (UIColor *)shadowColor {
    return [UIColor colorWithCGColor:self.layer.shadowColor];
}

- (void)setShadowColor:(UIColor *)shadowColor {
    self.layer.shadowColor = shadowColor.CGColor;
}

+ (UIColor *)shadowColor {
    return [(UIView *)APPEARANCE shadowColor];
}

+ (void)setShadowColor:(UIColor *)shadowColor {
    [(UIView *)APPEARANCE setShadowColor:shadowColor];
}

- (float)shadowOpacity {
    return self.layer.shadowOpacity;
}

- (void)setShadowOpacity:(float)shadowOpacity {
    self.layer.shadowOpacity = shadowOpacity;
}

+ (float)shadowOpacity {
    return [(UIView *)APPEARANCE shadowOpacity];
}

+ (void)setShadowOpacity:(float)shadowOpacity {
    [(UIView *)APPEARANCE setShadowOpacity:shadowOpacity];
}

- (CGSize)shadowOffset {
    return self.layer.shadowOffset;
}

- (void)setShadowOffset:(CGSize)shadowOffset {
    self.layer.shadowOffset = shadowOffset;
}

+ (CGSize)shadowOffset {
    return [(UIView *)APPEARANCE shadowOffset];
}

+ (void)setShadowOffset:(CGSize)shadowOffset {
    [(UIView *)APPEARANCE setShadowOffset:shadowOffset];
}

- (CGFloat)shadowSize {
    return self.layer.shadowRadius;
}

- (void)setShadowSize:(CGFloat)shadowSize {
    self.layer.shadowRadius = shadowSize;
}

+ (CGFloat)shadowSize {
    return [(UIView *)APPEARANCE shadowSize];
}

+ (void)setShadowSize:(CGFloat)shadowSize {
    [(UIView *)APPEARANCE setShadowSize:shadowSize];
}

- (UIImage *)imageRepresentation {
    UIGraphicsBeginImageContextWithOptions(self.bounds.size, YES, [UIScreen mainScreen].scale);
    [self.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

- (void)resizeFrame:(CGRect (^)(CGRect rect))resizer {
    if AGX_EXPECT_T(resizer) self.frame = resizer(self.frame);
}

#pragma mark - swizzle

- (AGX_INSTANCETYPE)AGXCore_UIView_initWithFrame:(CGRect)frame {
    if AGX_EXPECT_T([self AGXCore_UIView_initWithFrame:frame]) [self agxInitial];
    return self;
}

- (AGX_INSTANCETYPE)AGXCore_UIView_initWithCoder:(NSCoder *)aDecoder {
    if AGX_EXPECT_T([self AGXCore_UIView_initWithCoder:aDecoder]) {
        [self setRetainProperty:[aDecoder decodeObjectForKey:agxBackgroundImageViewKVOKey]
                forAssociateKey:agxBackgroundImageViewKVOKey];
        [self agxDecode:aDecoder];
    }
    return self;
}

- (void)AGXCore_UIView_encodeWithCoder:(NSCoder *)aCoder {
    [self AGXCore_UIView_encodeWithCoder:aCoder];
    [aCoder encodeObject:[self retainPropertyForAssociateKey:agxBackgroundImageViewKVOKey]
                  forKey:agxBackgroundImageViewKVOKey];
    [self agxEncode:aCoder];
}

- (void)AGXCore_UIView_dealloc {
    [self setRetainProperty:NULL forAssociateKey:agxBackgroundImageViewKVOKey];
    [self AGXCore_UIView_dealloc];
}

- (void)AGXCore_UIView_layoutSubviews {
    [self AGXCore_UIView_layoutSubviews];
    UIImageView *backgroundImageView = [self retainPropertyForAssociateKey:agxBackgroundImageViewKVOKey];
    if (!backgroundImageView) return;
    [backgroundImageView removeFromSuperview];
    if (!backgroundImageView.image) return;
    [backgroundImageView setFrame:self.bounds];
    [self insertSubview:backgroundImageView atIndex:0];
}

+ (void)load {
    agx_once
    ([UIView swizzleInstanceOriSelector:@selector(initWithFrame:)
                        withNewSelector:@selector(AGXCore_UIView_initWithFrame:)];
     [UIView swizzleInstanceOriSelector:@selector(initWithCoder:)
                        withNewSelector:@selector(AGXCore_UIView_initWithCoder:)];
     [UIView swizzleInstanceOriSelector:@selector(encodeWithCoder:)
                        withNewSelector:@selector(AGXCore_UIView_encodeWithCoder:)];
     [UIView swizzleInstanceOriSelector:NSSelectorFromString(@"dealloc")
                        withNewSelector:@selector(AGXCore_UIView_dealloc)];
     [UIView swizzleInstanceOriSelector:@selector(layoutSubviews)
                        withNewSelector:@selector(AGXCore_UIView_layoutSubviews)];)
}

@end
