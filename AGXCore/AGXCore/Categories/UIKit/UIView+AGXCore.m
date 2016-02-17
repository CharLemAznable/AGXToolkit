//
//  UIView+AGXCore.m
//  AGXCore
//
//  Created by Char Aznable on 16/2/17.
//  Copyright © 2016年 AI-CUC-EC. All rights reserved.
//

#import "UIView+AGXCore.h"
#import "NSObject+AGXCore.h"
#import "AGXAppearance.h"

@category_implementation(UIView, AGXCore)

- (void)agxInitial {
    self.backgroundColor = [UIColor clearColor];
}

NSString *const agxBackgroundImageKVOKey = @"agxBackgroundImage";

- (UIImage *)backgroundImage {
    return [self propertyForAssociateKey:agxBackgroundImageKVOKey];
}

- (void)setBackgroundImage:(UIImage *)backgroundImage {
    [self setProperty:backgroundImage forAssociateKey:agxBackgroundImageKVOKey];
    [self setNeedsDisplay];
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
    UIGraphicsBeginImageContext(self.bounds.size);
    [self.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

#pragma mark - swizzle

- (AGX_INSTANCETYPE)agx_init {
    if (AGX_EXPECT_T([self agx_init])) [self agxInitial];
    return self;
}

- (AGX_INSTANCETYPE)agx_initWithFrame:(CGRect)frame {
    if (AGX_EXPECT_T([self agx_initWithFrame:frame])) [self agxInitial];
    return self;
}

- (AGX_INSTANCETYPE)agx_initWithCoder:(NSCoder *)aDecoder {
    if (AGX_EXPECT_T([self agx_initWithCoder:aDecoder]))
        [self assignProperty:[aDecoder decodeObjectOfClass:[UIImage class] forKey:@"backgroundImage"]
             forAssociateKey:agxBackgroundImageKVOKey];
    return self;
}

- (void)agx_encodeWithCoder:(NSCoder *)aCoder {
    [self agx_encodeWithCoder:aCoder];
    [aCoder encodeObject:[self propertyForAssociateKey:agxBackgroundImageKVOKey] forKey:@"backgroundImage"];
}

- (void)agx_dealloc_uiview_agxcore {
    [self assignProperty:nil forAssociateKey:agxBackgroundImageKVOKey];
    [self agx_dealloc_uiview_agxcore];
}

- (void)agx_drawRect:(CGRect)rect {
    [self agx_drawRect:rect];
    [[self propertyForAssociateKey:agxBackgroundImageKVOKey] drawInRect:rect];
}

+ (void)load {
    static dispatch_once_t once_t;
    dispatch_once(&once_t, ^{
        [self swizzleInstanceOriSelector:@selector(init)
                         withNewSelector:@selector(agx_init)];
        [self swizzleInstanceOriSelector:@selector(initWithFrame:)
                         withNewSelector:@selector(agx_initWithFrame:)];
        [self swizzleInstanceOriSelector:@selector(initWithCoder:)
                         withNewSelector:@selector(agx_initWithCoder:)];
        [self swizzleInstanceOriSelector:@selector(encodeWithCoder:)
                         withNewSelector:@selector(agx_encodeWithCoder:)];
#if !IS_ARC
        [self swizzleInstanceOriSelector:@selector(dealloc)
                         withNewSelector:@selector(agx_dealloc_uiview_agxcore)];
#endif
        [self swizzleInstanceOriSelector:@selector(drawRect:)
                         withNewSelector:@selector(agx_drawRect:)];
    });
}

@end
