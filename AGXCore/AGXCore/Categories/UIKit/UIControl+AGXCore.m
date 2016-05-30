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

#pragma mark - borderWidth

- (CGFloat)borderWidth {
    return [self borderWidthForState:UIControlStateNormal];
}

- (void)setBorderWidth:(CGFloat)borderWidth {
    [self setBorderWidth:borderWidth forState:UIControlStateNormal];
}

- (CGFloat)borderWidthForState:(UIControlState)state {
    return [[[self agxBorderWidths] objectForKey:[self keyForState:state]
                                    defaultValue:[[self agxBorderWidths] valueForKey:
                                                  [self keyForState:UIControlStateNormal]]]
            cgfloatValue];
}

- (void)setBorderWidth:(CGFloat)width forState:(UIControlState)state {
    if (state == UIControlStateNormal) self.layer.borderWidth = width;
    [self agxBorderWidths][[self keyForState:state]] = [NSNumber numberWithCGFloat:width];
}

+ (CGFloat)borderWidthForState:(UIControlState)state {
    return [APPEARANCE borderWidthForState:state];
}

+ (void)setBorderWidth:(CGFloat)width forState:(UIControlState)state {
    [APPEARANCE setBorderWidth:width forState:state];
}

#pragma mark - borderColor

- (UIColor *)borderColor {
    return [self borderColorForState:UIControlStateNormal];
}

- (void)setBorderColor:(UIColor *)borderColor {
    [self setBorderColor:borderColor forState:UIControlStateNormal];
}

- (UIColor *)borderColorForState:(UIControlState)state {
    return [[self agxBorderColors] objectForKey:[self keyForState:state]
                                   defaultValue:[[self agxBorderColors] valueForKey:
                                                 [self keyForState:UIControlStateNormal]]];
}

- (void)setBorderColor:(UIColor *)color forState:(UIControlState)state {
    if (state == UIControlStateNormal) self.layer.borderColor = color.CGColor;
    [self agxBorderColors][[self keyForState:state]] = color;
}

+ (UIColor *)borderColorForState:(UIControlState)state {
    return [APPEARANCE borderColorForState:state];
}

+ (void)setBorderColor:(UIColor *)color forState:(UIControlState)state {
    [APPEARANCE setBorderColor:color forState:state];
}

#pragma mark - shadowColor

- (UIColor *)shadowColor {
    return [self shadowColorForState:UIControlStateNormal];
}

- (void)setShadowColor:(UIColor *)shadowColor {
    [self setShadowColor:shadowColor forState:UIControlStateNormal];
}

- (UIColor *)shadowColorForState:(UIControlState)state {
    return [[self agxShadowColors] objectForKey:[self keyForState:state]
                                   defaultValue:[[self agxShadowColors] valueForKey:
                                                 [self keyForState:UIControlStateNormal]]];
}

- (void)setShadowColor:(UIColor *)color forState:(UIControlState)state {
    if (state == UIControlStateNormal) self.layer.shadowColor = color.CGColor;
    [self agxShadowColors][[self keyForState:state]] = color;
}

+ (UIColor *)shadowColorForState:(UIControlState)state {
    return [APPEARANCE shadowColorForState:state];
}

+ (void)setShadowColor:(UIColor *)color forState:(UIControlState)state {
    [APPEARANCE setShadowColor:color forState:state];
}

#pragma mark - shadowOpacity

- (float)shadowOpacity {
    return [self shadowOpacityForState:UIControlStateNormal];
}

- (void)setShadowOpacity:(float)shadowOpacity {
    [self setShadowOpacity:shadowOpacity forState:UIControlStateNormal];
}

- (float)shadowOpacityForState:(UIControlState)state {
    return [[[self agxShadowOpacities] objectForKey:[self keyForState:state]
                                       defaultValue:[[self agxShadowOpacities] valueForKey:
                                                     [self keyForState:UIControlStateNormal]]]
            floatValue];
}

- (void)setShadowOpacity:(float)opacity forState:(UIControlState)state {
    if (state == UIControlStateNormal) self.layer.shadowOpacity = opacity;
    [self agxShadowOpacities][[self keyForState:state]] = [NSNumber numberWithFloat:opacity];
}

+ (float)shadowOpacityForState:(UIControlState)state {
    return [APPEARANCE shadowOpacityForState:state];
}

+ (void)setShadowOpacity:(float)opacity forState:(UIControlState)state {
    [APPEARANCE setShadowOpacity:opacity forState:state];
}

#pragma mark - shadowOffset

- (CGSize)shadowOffset {
    return [self shadowOffsetForState:UIControlStateNormal];
}

- (void)setShadowOffset:(CGSize)shadowOffset {
    [self setShadowOffset:shadowOffset forState:UIControlStateNormal];
}

- (CGSize)shadowOffsetForState:(UIControlState)state {
    return [[[self agxShadowOffsets] objectForKey:[self keyForState:state]
                                     defaultValue:[[self agxShadowOffsets] valueForKey:
                                                   [self keyForState:UIControlStateNormal]]]
            CGSizeValue];
}

- (void)setShadowOffset:(CGSize)offset forState:(UIControlState)state {
    if (state == UIControlStateNormal) self.layer.shadowOffset = offset;
    [self agxShadowOffsets][[self keyForState:state]] = [NSValue valueWithCGSize:offset];
}

+ (CGSize)shadowOffsetForState:(UIControlState)state {
    return [APPEARANCE shadowOffsetForState:state];
}

+ (void)setShadowOffset:(CGSize)offset forState:(UIControlState)state {
    [APPEARANCE setShadowOffset:offset forState:state];
}

#pragma mark - shadowSize

- (CGFloat)shadowSize {
    return [self shadowSizeForState:UIControlStateNormal];
}

- (void)setShadowSize:(CGFloat)shadowSize {
    [self setShadowSize:shadowSize forState:UIControlStateNormal];
}

- (CGFloat)shadowSizeForState:(UIControlState)state {
    return [[[self agxShadowSizes] objectForKey:[self keyForState:state]
                                   defaultValue:[[self agxShadowSizes] valueForKey:
                                                 [self keyForState:UIControlStateNormal]]]
            cgfloatValue];
}

- (void)setShadowSize:(CGFloat)size forState:(UIControlState)state {
    if (state == UIControlStateNormal) self.layer.shadowRadius = size;
    [self agxShadowSizes][[self keyForState:state]] = [NSNumber numberWithCGFloat:size];
}

+ (CGFloat)shadowSizeForState:(UIControlState)state {
    return [APPEARANCE shadowSizeForState:state];
}

+ (void)setShadowSize:(CGFloat)size forState:(UIControlState)state {
    [APPEARANCE setShadowSize:size forState:state];
}

#pragma mark - acceptEventInterval

- (NSTimeInterval)acceptEventInterval {
    return [[self retainPropertyForAssociateKey:agxAcceptEventIntervalKey] doubleValue];
}

- (void)setAcceptEventInterval:(NSTimeInterval)acceptEventInterval {
    [self setKVORetainProperty:@(acceptEventInterval) forAssociateKey:agxAcceptEventIntervalKey];
}

#pragma mark - override

- (void)agxInitial {
    [super agxInitial];

    [self setRetainProperty:[NSMutableDictionary dictionary] forAssociateKey:agxBorderWidthsKey];
    [self setRetainProperty:[NSMutableDictionary dictionary] forAssociateKey:agxBorderColorsKey];

    [self setRetainProperty:[NSMutableDictionary dictionary] forAssociateKey:agxShadowColorsKey];
    [self setRetainProperty:[NSMutableDictionary dictionary] forAssociateKey:agxShadowOpacitiesKey];
    [self setRetainProperty:[NSMutableDictionary dictionary] forAssociateKey:agxShadowOffsetsKey];
    [self setRetainProperty:[NSMutableDictionary dictionary] forAssociateKey:agxShadowSizesKey];

    [self setRetainProperty:@(0.2) forAssociateKey:agxAcceptEventIntervalKey];
    [self setRetainProperty:[NSMutableDictionary dictionary] forAssociateKey:agxIgnoreControlEventKey];
}

- (void)agxDecode:(NSCoder *)coder {
    [super agxDecode:coder];

    [self setRetainProperty:[coder decodeObjectForKey:agxBorderWidthsKey] forAssociateKey:agxBorderWidthsKey];
    [self setRetainProperty:[coder decodeObjectForKey:agxBorderColorsKey] forAssociateKey:agxBorderColorsKey];

    [self setRetainProperty:[coder decodeObjectForKey:agxShadowColorsKey] forAssociateKey:agxShadowColorsKey];
    [self setRetainProperty:[coder decodeObjectForKey:agxShadowOpacitiesKey] forAssociateKey:agxShadowOpacitiesKey];
    [self setRetainProperty:[coder decodeObjectForKey:agxShadowOffsetsKey] forAssociateKey:agxShadowOffsetsKey];
    [self setRetainProperty:[coder decodeObjectForKey:agxShadowSizesKey] forAssociateKey:agxShadowSizesKey];

    [self setRetainProperty:[coder decodeObjectForKey:agxAcceptEventIntervalKey] forAssociateKey:agxAcceptEventIntervalKey];
    [self setRetainProperty:[coder decodeObjectForKey:agxIgnoreControlEventKey] forAssociateKey:agxIgnoreControlEventKey];
}

- (void)agxEncode:(NSCoder *)coder {
    [super agxEncode:coder];

    [coder encodeObject:[self retainPropertyForAssociateKey:agxBorderWidthsKey] forKey:agxBorderWidthsKey];
    [coder encodeObject:[self retainPropertyForAssociateKey:agxBorderColorsKey] forKey:agxBorderColorsKey];

    [coder encodeObject:[self retainPropertyForAssociateKey:agxShadowColorsKey] forKey:agxShadowColorsKey];
    [coder encodeObject:[self retainPropertyForAssociateKey:agxShadowOpacitiesKey] forKey:agxShadowOpacitiesKey];
    [coder encodeObject:[self retainPropertyForAssociateKey:agxShadowOffsetsKey] forKey:agxShadowOffsetsKey];
    [coder encodeObject:[self retainPropertyForAssociateKey:agxShadowSizesKey] forKey:agxShadowSizesKey];

    [coder encodeObject:[self retainPropertyForAssociateKey:agxAcceptEventIntervalKey] forKey:agxAcceptEventIntervalKey];
    [coder encodeObject:[self retainPropertyForAssociateKey:agxIgnoreControlEventKey] forKey:agxIgnoreControlEventKey];
}

#pragma mark - swizzle

- (void)AGXCore_UIControl_dealloc {
    [self setRetainProperty:NULL forAssociateKey:agxBorderWidthsKey];
    [self setRetainProperty:NULL forAssociateKey:agxBorderColorsKey];

    [self setRetainProperty:NULL forAssociateKey:agxShadowColorsKey];
    [self setRetainProperty:NULL forAssociateKey:agxShadowOpacitiesKey];
    [self setRetainProperty:NULL forAssociateKey:agxShadowOffsetsKey];
    [self setRetainProperty:NULL forAssociateKey:agxShadowSizesKey];

    [self setRetainProperty:NULL forAssociateKey:agxAcceptEventIntervalKey];
    [self setRetainProperty:NULL forAssociateKey:agxIgnoreControlEventKey];

    [self AGXCore_UIControl_dealloc];
}

- (void)AGXCore_UIControl_setHighlighted:(BOOL)highlighted {
    [self AGXCore_UIControl_setHighlighted:highlighted];
    UIControlState state = highlighted ? UIControlStateHighlighted : [self isSelected] ? UIControlStateSelected : UIControlStateNormal;
    [self p_settingForState:state];
}

- (void)AGXCore_UIControl_setSelected:(BOOL)selected {
    [self AGXCore_UIControl_setSelected:selected];
    UIControlState state = selected ? UIControlStateSelected : UIControlStateNormal;
    [self p_settingForState:state];
}

- (void)AGXCore_UIControl_setEnabled:(BOOL)enabled {
    [self AGXCore_UIControl_setEnabled:enabled];
    UIControlState state = enabled ? UIControlStateNormal : UIControlStateDisabled;
    [self p_settingForState:state];
}

- (void)AGXCore_UIControl_sendActionsForControlEvents:(UIControlEvents)controlEvents {
    if ([self p_ignoreControlEvent:controlEvents]) return;
    if ([self acceptEventInterval] > 0) {
        [self p_setIgnore:YES forControlEvent:controlEvents];
        agx_delay_main([self acceptEventInterval], [self p_setIgnore:NO forControlEvent:controlEvents];)
    }
    [self AGXCore_UIControl_sendActionsForControlEvents:controlEvents];
}

+ (void)load {
    static dispatch_once_t once_t;
    dispatch_once(&once_t, ^{
        [self swizzleInstanceOriSelector:NSSelectorFromString(@"dealloc")
                         withNewSelector:@selector(AGXCore_UIControl_dealloc)];
        [self swizzleInstanceOriSelector:@selector(setHighlighted:)
                         withNewSelector:@selector(AGXCore_UIControl_setHighlighted:)];
        [self swizzleInstanceOriSelector:@selector(setSelected:)
                         withNewSelector:@selector(AGXCore_UIControl_setSelected:)];
        [self swizzleInstanceOriSelector:@selector(setEnabled:)
                         withNewSelector:@selector(AGXCore_UIControl_setEnabled:)];
        [self swizzleInstanceOriSelector:@selector(sendActionsForControlEvents:)
                         withNewSelector:@selector(AGXCore_UIControl_sendActionsForControlEvents:)];
    });
}

#pragma mark - Associated Value Methods -

NSString *const agxBorderWidthsKey          = @"agxBorderWidths";
NSString *const agxBorderColorsKey          = @"agxBorderColors";

NSString *const agxShadowColorsKey          = @"agxShadowColors";
NSString *const agxShadowOpacitiesKey       = @"agxShadowOpacities";
NSString *const agxShadowOffsetsKey         = @"agxShadowOffsets";
NSString *const agxShadowSizesKey           = @"agxShadowSizes";

NSString *const agxAcceptEventIntervalKey   = @"agxAcceptEventInterval";
NSString *const agxIgnoreControlEventKey    = @"agxIgnoreControlEvent";

#define AGXAttribute_implement(attribute)                       \
- (NSMutableDictionary *)attribute {                            \
    return [self retainPropertyForAssociateKey:attribute##Key]; \
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

- (void)p_settingForState:(UIControlState)state {
    self.layer.borderWidth      = [self borderWidthForState:state];
    self.layer.borderColor      = [self borderColorForState:state].CGColor;

    self.layer.shadowColor      = [self shadowColorForState:state].CGColor;
    self.layer.shadowOpacity    = [self shadowOpacityForState:state];
    self.layer.shadowOffset     = [self shadowOffsetForState:state];
    self.layer.shadowRadius     = [self shadowSizeForState:state];
}

- (BOOL)p_ignoreControlEvent:(UIControlEvents)controlEvents {
    return [[[self retainPropertyForAssociateKey:agxIgnoreControlEventKey] objectForKey:@(controlEvents)] boolValue];
}

- (void)p_setIgnore:(BOOL)ignore forControlEvent:(UIControlEvents)controlEvents {
    [[self retainPropertyForAssociateKey:agxIgnoreControlEventKey] setObject:@(ignore) forKey:@(controlEvents)];
}

@end
