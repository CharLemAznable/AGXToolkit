//
//  UIControl+AGXCore.m
//  AGXCore
//
//  Created by Char Aznable on 16/2/17.
//  Copyright © 2016年 AI-CUC-EC. All rights reserved.
//

#import "UIControl+AGXCore.h"
#import "NSObject+AGXCore.h"
#import "NSNumber+AGXCore.h"
#import "NSDictionary+AGXCore.h"
#import "UIView+AGXCore.h"
#import "AGXAppearance.h"

@category_implementation(UIControl, AGXCore)

- (CGFloat)borderWidthForState:(UIControlState)state {
    return [[[self agxBorderWidths] objectForKey:[self keyForState:state]
                                    defaultValue:[[self agxBorderWidths] valueForKey:
                                                  [self keyForState:UIControlStateNormal]]]
            cgfloatValue];
}

- (void)setBorderWidth:(CGFloat)width forState:(UIControlState)state {
    if(state == UIControlStateNormal) self.borderWidth = width;
    [self agxBorderWidths][[self keyForState:state]] = [NSNumber numberWithCGFloat:width];
}

+ (CGFloat)borderWidthForState:(UIControlState)state {
    return [APPEARANCE borderWidthForState:state];
}

+ (void)setBorderWidth:(CGFloat)width forState:(UIControlState)state {
    [APPEARANCE setBorderWidth:width forState:state];
}

- (UIColor *)borderColorForState:(UIControlState)state {
    return [[self agxBorderColors] objectForKey:[self keyForState:state]
                                   defaultValue:[[self agxBorderColors] valueForKey:
                                                 [self keyForState:UIControlStateNormal]]];
}

- (void)setBorderColor:(UIColor *)color forState:(UIControlState)state {
    if(state == UIControlStateNormal) self.borderColor = color;
    [self agxBorderColors][[self keyForState:state]] = color;
}

+ (UIColor *)borderColorForState:(UIControlState)state {
    return [APPEARANCE borderColorForState:state];
}

+ (void)setBorderColor:(UIColor *)color forState:(UIControlState)state {
    [APPEARANCE setBorderColor:color forState:state];
}

- (UIColor *)shadowColorForState:(UIControlState)state {
    return [[self agxShadowColors] objectForKey:[self keyForState:state]
                                   defaultValue:[[self agxShadowColors] valueForKey:
                                                 [self keyForState:UIControlStateNormal]]];
}

- (void)setShadowColor:(UIColor *)color forState:(UIControlState)state {
    if(state == UIControlStateNormal) self.shadowColor = color;
    [self agxShadowColors][[self keyForState:state]] = color;
}

+ (UIColor *)shadowColorForState:(UIControlState)state {
    return [APPEARANCE shadowColorForState:state];
}

+ (void)setShadowColor:(UIColor *)color forState:(UIControlState)state {
    [APPEARANCE setShadowColor:color forState:state];
}

- (float)shadowOpacityForState:(UIControlState)state {
    return [[[self agxShadowOpacities] objectForKey:[self keyForState:state]
                                       defaultValue:[[self agxShadowOpacities] valueForKey:
                                                     [self keyForState:UIControlStateNormal]]]
            floatValue];
}

- (void)setShadowOpacity:(float)opacity forState:(UIControlState)state {
    if(state == UIControlStateNormal) self.shadowOpacity = opacity;
    [self agxShadowOpacities][[self keyForState:state]] = [NSNumber numberWithFloat:opacity];
}

+ (float)shadowOpacityForState:(UIControlState)state {
    return [APPEARANCE shadowOpacityForState:state];
}

+ (void)setShadowOpacity:(float)opacity forState:(UIControlState)state {
    [APPEARANCE setShadowOpacity:opacity forState:state];
}

- (CGSize)shadowOffsetForState:(UIControlState)state {
    return [[[self agxShadowOffsets] objectForKey:[self keyForState:state]
                                     defaultValue:[[self agxShadowOffsets] valueForKey:
                                                   [self keyForState:UIControlStateNormal]]]
            CGSizeValue];
}

- (void)setShadowOffset:(CGSize)offset forState:(UIControlState)state {
    if(state == UIControlStateNormal) self.shadowOffset = offset;
    [self agxShadowOffsets][[self keyForState:state]] = [NSValue valueWithCGSize:offset];
}

+ (CGSize)shadowOffsetForState:(UIControlState)state {
    return [APPEARANCE shadowOffsetForState:state];
}

+ (void)setShadowOffset:(CGSize)offset forState:(UIControlState)state {
    [APPEARANCE setShadowOffset:offset forState:state];
}

- (CGFloat)shadowSizeForState:(UIControlState)state {
    return [[[self agxShadowSizes] objectForKey:[self keyForState:state]
                                   defaultValue:[[self agxShadowSizes] valueForKey:
                                                 [self keyForState:UIControlStateNormal]]]
            cgfloatValue];
}

- (void)setShadowSize:(CGFloat)size forState:(UIControlState)state {
    if(state == UIControlStateNormal) self.shadowSize = size;
    [self agxShadowSizes][[self keyForState:state]] = [NSNumber numberWithCGFloat:size];
}

+ (CGFloat)shadowSizeForState:(UIControlState)state {
    return [APPEARANCE shadowSizeForState:state];
}

+ (void)setShadowSize:(CGFloat)size forState:(UIControlState)state {
    [APPEARANCE setShadowSize:size forState:state];
}

#pragma mark - swizzle

- (void)agxInitial {
    [super agxInitial];
    
    [self assignProperty:[NSMutableDictionary dictionary] forAssociateKey:agxBorderWidthsKey];
    [self assignProperty:[NSMutableDictionary dictionary] forAssociateKey:agxBorderColorsKey];
    
    [self assignProperty:[NSMutableDictionary dictionary] forAssociateKey:agxShadowColorsKey];
    [self assignProperty:[NSMutableDictionary dictionary] forAssociateKey:agxShadowOpacitiesKey];
    [self assignProperty:[NSMutableDictionary dictionary] forAssociateKey:agxShadowOffsetsKey];
    [self assignProperty:[NSMutableDictionary dictionary] forAssociateKey:agxShadowSizesKey];
    
    [self addTarget:self action:@selector(agxTouchUpInsideEvent:) forControlEvents:UIControlEventTouchUpInside];
}

float AGXMinOperationInterval = 0.2;

- (void)agxTouchUpInsideEvent:(id)sender {
    self.enabled = NO;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(AGXMinOperationInterval * NSEC_PER_SEC)),
                   dispatch_get_main_queue(), ^{ self.enabled = YES; });
}

- (void)agx_dealloc_uicontrol_agxcore {
    [self assignProperty:nil forAssociateKey:agxBorderWidthsKey];
    [self assignProperty:nil forAssociateKey:agxBorderColorsKey];
    
    [self assignProperty:nil forAssociateKey:agxShadowColorsKey];
    [self assignProperty:nil forAssociateKey:agxShadowOpacitiesKey];
    [self assignProperty:nil forAssociateKey:agxShadowOffsetsKey];
    [self assignProperty:nil forAssociateKey:agxShadowSizesKey];
    
    [self agx_dealloc_uicontrol_agxcore];
}

- (void)agx_setHighlighted:(BOOL)highlighted {
    [self agx_setHighlighted:highlighted];
    UIControlState state = highlighted ? UIControlStateHighlighted : [self isSelected] ? UIControlStateSelected : UIControlStateNormal;
    
    self.borderWidth    = [self borderWidthForState:state];
    self.borderColor    = [self borderColorForState:state];
    
    self.shadowColor    = [self shadowColorForState:state];
    self.shadowOpacity  = [self shadowOpacityForState:state];
    self.shadowOffset   = [self shadowOffsetForState:state];
    self.shadowSize     = [self shadowSizeForState:state];
}

- (void)agx_setSelected:(BOOL)selected {
    [self agx_setSelected:selected];
    UIControlState state = selected ? UIControlStateSelected : UIControlStateNormal;
    
    self.borderWidth    = [self borderWidthForState:state];
    self.borderColor    = [self borderColorForState:state];
    
    self.shadowColor    = [self shadowColorForState:state];
    self.shadowOpacity  = [self shadowOpacityForState:state];
    self.shadowOffset   = [self shadowOffsetForState:state];
    self.shadowSize     = [self shadowSizeForState:state];
}

- (void)agx_setEnabled:(BOOL)enabled {
    [self agx_setEnabled:enabled];
    UIControlState state = enabled ? UIControlStateNormal : UIControlStateDisabled;
    
    self.borderWidth    = [self borderWidthForState:state];
    self.borderColor    = [self borderColorForState:state];
    
    self.shadowColor    = [self shadowColorForState:state];
    self.shadowOpacity  = [self shadowOpacityForState:state];
    self.shadowOffset   = [self shadowOffsetForState:state];
    self.shadowSize     = [self shadowSizeForState:state];
}

+ (void)load {
    static dispatch_once_t once_t;
    dispatch_once(&once_t, ^{
        [self swizzleInstanceOriSelector:NSSelectorFromString(@"dealloc")
                         withNewSelector:@selector(agx_dealloc_uicontrol_agxcore)];
        [self swizzleInstanceOriSelector:@selector(setHighlighted:)
                         withNewSelector:@selector(agx_setHighlighted:)];
        [self swizzleInstanceOriSelector:@selector(setSelected:)
                         withNewSelector:@selector(agx_setSelected:)];
        [self swizzleInstanceOriSelector:@selector(setEnabled:)
                         withNewSelector:@selector(agx_setEnabled:)];
    });
}

#pragma mark - Associated Value Methods -

NSString *const agxBorderWidthsKey      = @"agxBorderWidths";
NSString *const agxBorderColorsKey      = @"agxBorderColors";

NSString *const agxShadowColorsKey      = @"agxShadowColors";
NSString *const agxShadowOpacitiesKey   = @"agxShadowOpacities";
NSString *const agxShadowOffsetsKey     = @"agxShadowOffsets";
NSString *const agxShadowSizesKey       = @"agxShadowSizes";

#define AGXAttribute_implement(attribute)                   \
- (NSMutableDictionary *)attribute {                        \
    return [self propertyForAssociateKey:attribute##Key];   \
}

AGXAttribute_implement(agxBorderWidths)
AGXAttribute_implement(agxBorderColors)
AGXAttribute_implement(agxShadowColors)
AGXAttribute_implement(agxShadowOpacities)
AGXAttribute_implement(agxShadowOffsets)
AGXAttribute_implement(agxShadowSizes)

#pragma mark - Private Methods -

- (NSString *)keyForState:(UIControlState)state {
    return [NSString stringWithFormat:@"%d", (unsigned int)state];
}

@end
