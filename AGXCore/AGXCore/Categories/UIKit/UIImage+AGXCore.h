//
//  UIImage+AGXCore.h
//  AGXCore
//
//  Created by Char Aznable on 16/2/17.
//  Copyright © 2016年 AI-CUC-EC. All rights reserved.
//

#ifndef AGXCore_UIImage_AGXCore_h
#define AGXCore_UIImage_AGXCore_h

#import <UIKit/UIKit.h>
#import "AGXCategory.h"
#import "AGXGeometry.h"
#import "AGXDirectory.h"
#import "AGXBundle.h"

@category_interface(UIImage, AGXCore)
+ (UIImage *)imageWithURLString:(NSString *)URLString;
+ (UIImage *)imageWithURLString:(NSString *)URLString scale:(CGFloat)scale;

+ (UIImage *)imagePointWithColor:(UIColor *)color;
+ (UIImage *)imageRectWithColor:(UIColor *)color size:(CGSize)size;
+ (UIImage *)imageGradientRectWithStartColor:(UIColor *)startColor endColor:(UIColor *)endColor direction:(AGXDirection)direction size:(CGSize)size;
+ (UIImage *)imageGradientRectWithColors:(NSArray *)colors locations:(NSArray *)locations direction:(AGXDirection)direction size:(CGSize)size;
+ (UIImage *)imageEllipseWithColor:(UIColor *)color size:(CGSize)size;
+ (UIImage *)imageCrossWithColor:(UIColor *)color edge:(CGFloat)edge lineWidth:(CGFloat)lineWidth;
+ (UIImage *)imageEllipsisWithColor:(UIColor *)color edge:(CGFloat)edge; // "•••"
+ (UIImage *)imageArrowWithColor:(UIColor *)color edge:(CGFloat)edge direction:(AGXDirection)direction;
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
@end

@category_interface(AGXDirectory, AGXCoreUIImage)
+ (UIImage *(^)(NSString *))imageForCurrentDeviceWithFile;
+ (BOOL (^)(NSString *, UIImage *))writeToFileWithImageForCurrentDevice;

- (UIImage *(^)(NSString *))imageForCurrentDeviceWithFile;
- (BOOL (^)(NSString *, UIImage *))writeToFileWithImageForCurrentDevice;
@end

@category_interface(AGXBundle, AGXCoreUIImage)
+ (UIImage *(^)(NSString *))imageForCurrentDeviceWithFile;

- (UIImage *(^)(NSString *))imageForCurrentDeviceWithFile;
@end

#endif /* AGXCore_UIImage_AGXCore_h */
