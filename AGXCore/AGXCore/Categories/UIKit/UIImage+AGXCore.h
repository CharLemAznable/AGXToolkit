//
//  UIImage+AGXCore.h
//  AGXCore
//
//  Created by Char Aznable on 2016/2/17.
//  Copyright © 2016年 AI-CUC-EC. All rights reserved.
//

#ifndef AGXCore_UIImage_AGXCore_h
#define AGXCore_UIImage_AGXCore_h

#import <UIKit/UIKit.h>
#import "AGXCategory.h"
#import "AGXGeometry.h"
#import "AGXResources.h"

@category_interface(UIImage, AGXCore)
+ (UIImage *)imageWithURLString:(NSString *)URLString;
+ (UIImage *)imageWithURLString:(NSString *)URLString scale:(CGFloat)scale;

+ (UIImage *)imagePointWithColor:(UIColor *)color;
+ (UIImage *)imageRectWithColor:(UIColor *)color size:(CGSize)size;
+ (UIImage *)imageGradientRectWithStartColor:(UIColor *)startColor endColor:(UIColor *)endColor direction:(AGXDirection)direction size:(CGSize)size;
+ (UIImage *)imageGradientRectWithColors:(NSArray *)colors locations:(NSArray *)locations direction:(AGXDirection)direction size:(CGSize)size;
+ (UIImage *)imageEllipseWithColor:(UIColor *)color size:(CGSize)size;
+ (UIImage *)imageCircleWithColor:(UIColor *)color size:(CGSize)size lineWidth:(CGFloat)lineWidth;
+ (UIImage *)imageCrossWithColor:(UIColor *)color edge:(CGFloat)edge lineWidth:(CGFloat)lineWidth;
+ (UIImage *)imageEllipsisWithColor:(UIColor *)color edge:(CGFloat)edge; // "•••"
+ (UIImage *)imageArrowWithColor:(UIColor *)color edge:(CGFloat)edge direction:(AGXDirection)direction;
+ (UIImage *)imageRegularTriangleWithColor:(UIColor *)color edge:(CGFloat)edge direction:(AGXDirection)direction;
+ (UIImage *)captchaImageWithCaptchaCode:(NSString *)captchaCode size:(CGSize)size;

+ (UIImage *)imageBaseOnImage:(UIImage *)baseImage watermarkedWithImage:(UIImage *)watermarkImage;
+ (UIImage *)imageBaseOnImage:(UIImage *)baseImage watermarkedWithImage:(UIImage *)watermarkImage inDirection:(AGXDirection)direction;
+ (UIImage *)imageBaseOnImage:(UIImage *)baseImage watermarkedWithImage:(UIImage *)watermarkImage withOffset:(CGVector)offset;
+ (UIImage *)imageBaseOnImage:(UIImage *)baseImage watermarkedWithImage:(UIImage *)watermarkImage inDirection:(AGXDirection)direction withOffset:(CGVector)offset;

+ (UIImage *)imageBaseOnImage:(UIImage *)baseImage watermarkedWithText:(NSString *)watermarkText;
+ (UIImage *)imageBaseOnImage:(UIImage *)baseImage watermarkedWithText:(NSString *)watermarkText withAttributes:(NSDictionary<NSAttributedStringKey, id> *)attrs;
+ (UIImage *)imageBaseOnImage:(UIImage *)baseImage watermarkedWithText:(NSString *)watermarkText inDirection:(AGXDirection)direction;
+ (UIImage *)imageBaseOnImage:(UIImage *)baseImage watermarkedWithText:(NSString *)watermarkText withOffset:(CGVector)offset;
+ (UIImage *)imageBaseOnImage:(UIImage *)baseImage watermarkedWithText:(NSString *)watermarkText withAttributes:(NSDictionary<NSAttributedStringKey, id> *)attrs inDirection:(AGXDirection)direction;
+ (UIImage *)imageBaseOnImage:(UIImage *)baseImage watermarkedWithText:(NSString *)watermarkText withAttributes:(NSDictionary<NSAttributedStringKey, id> *)attrs withOffset:(CGVector)offset;
+ (UIImage *)imageBaseOnImage:(UIImage *)baseImage watermarkedWithText:(NSString *)watermarkText inDirection:(AGXDirection)direction withOffset:(CGVector)offset;
+ (UIImage *)imageBaseOnImage:(UIImage *)baseImage watermarkedWithText:(NSString *)watermarkText withAttributes:(NSDictionary<NSAttributedStringKey, id> *)attrs inDirection:(AGXDirection)direction withOffset:(CGVector)offset;

+ (UIImage *)imageForCurrentDeviceNamed:(NSString *)name;
+ (NSString *)imageNameForCurrentDeviceNamed:(NSString *)name;
+ (NSString *)imageNameForCurrentPixelRatioNamed:(NSString *)name;
- (UIColor *)dominantColor;

- (UIImage *)imageWithCropInsets:(UIEdgeInsets)cropInsets;

+ (UIImage *)imageFixedOrientation:(UIImage *)aImage;
+ (UIImage *)image:(UIImage *)image scaleToFitSize:(CGSize)size;
+ (UIImage *)image:(UIImage *)image scaleToFillSize:(CGSize)size;

+ (UIImage *)gifImageWithData:(NSData *)data;
+ (UIImage *)gifImageWithData:(NSData *)data fitSize:(CGSize)size;
+ (UIImage *)gifImageWithData:(NSData *)data fillSize:(CGSize)size;

+ (UIImage *)gifImageWithData:(NSData *)data scale:(CGFloat)scale;
+ (UIImage *)gifImageWithData:(NSData *)data scale:(CGFloat)scale fitSize:(CGSize)size;
+ (UIImage *)gifImageWithData:(NSData *)data scale:(CGFloat)scale fillSize:(CGSize)size;
@end

@category_interface(AGXResources, AGXCoreUIImage)
- (UIImage *(^)(NSString *))imageForCurrentDeviceWithImageNamed;
- (BOOL (^)(NSString *, UIImage *))writeImageForCurrentDeviceWithImageNamed;

- (UIImage *(^)(NSString *))gifImageWithFileNamed;
- (UIImage *(^)(NSString *))gifImageWithGifImageNamed;
@end

#endif /* AGXCore_UIImage_AGXCore_h */
