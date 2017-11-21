//
//  UIView+AGXCore.h
//  AGXCore
//
//  Created by Char Aznable on 16/2/17.
//  Copyright © 2016年 AI-CUC-EC. All rights reserved.
//

#ifndef AGXCore_UIView_AGXCore_h
#define AGXCore_UIView_AGXCore_h

#import <UIKit/UIKit.h>
#import "AGXArc.h"
#import "AGXCategory.h"

@category_interface(UIView, AGXCore)
- (void)agxInitial;
- (void)agxDecode:(NSCoder *)coder;
- (void)agxEncode:(NSCoder *)coder;

@property (nonatomic, AGX_STRONG) UIImage *backgroundImage;

@property BOOL masksToBounds;
@property CGFloat cornerRadius;

@property CGFloat borderWidth UI_APPEARANCE_SELECTOR;
+ (CGFloat)borderWidth;
+ (void)setBorderWidth:(CGFloat)borderWidth;

@property UIColor *borderColor UI_APPEARANCE_SELECTOR;
+ (UIColor *)borderColor;
+ (void)setBorderColor:(UIColor *)borderColor;

@property UIColor *shadowColor UI_APPEARANCE_SELECTOR;
+ (UIColor *)shadowColor;
+ (void)setShadowColor:(UIColor *)shadowColor;

@property float shadowOpacity UI_APPEARANCE_SELECTOR;
+ (float)shadowOpacity;
+ (void)setShadowOpacity:(float)shadowOpacity;

@property CGSize shadowOffset UI_APPEARANCE_SELECTOR;
+ (CGSize)shadowOffset;
+ (void)setShadowOffset:(CGSize)shadowOffset;

@property CGFloat shadowSize UI_APPEARANCE_SELECTOR;
+ (CGFloat)shadowSize;
+ (void)setShadowSize:(CGFloat)shadowSize;

- (UIImage *)imageRepresentation;
- (void)resizeFrame:(CGRect (^)(CGRect rect))resizer;
@end

#endif /* AGXCore_UIView_AGXCore_h */
