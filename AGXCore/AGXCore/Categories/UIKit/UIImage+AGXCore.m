//
//  UIImage+AGXCore.m
//  AGXCore
//
//  Created by Char Aznable on 2016/2/17.
//  Copyright © 2016年 AI-CUC-EC. All rights reserved.
//

#import "UIImage+AGXCore.h"
#import "AGXArc.h"
#import "AGXAdapt.h"
#import "AGXMath.h"
#import "AGXRandom.h"
#import "UIColor+AGXCore.h"

@category_implementation(UIImage, AGXCore)

+ (UIImage *)imageWithURLString:(NSString *)URLString {
    return [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:URLString]]];
}

+ (UIImage *)imageWithURLString:(NSString *)URLString scale:(CGFloat)scale {
    return [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:URLString]] scale:scale];
}

#pragma mark - image create

+ (UIImage *)imagePointWithColor:(UIColor *)color {
    return [self imageRectWithColor:color size:CGSizeMake(1, 1)];
}

+ (UIImage *)imageRectWithColor:(UIColor *)color size:(CGSize)size {
    CGRect rect = CGRectMake(0, 0, size.width, size.height);
    UIGraphicsBeginImageContextWithOptions(rect.size, NO, UIScreen.mainScreen.scale);
    CGContextRef context = UIGraphicsGetCurrentContext();

    CGContextSetFillColorWithColor(context, color.CGColor);
    CGContextFillRect(context, rect);

    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

/*
 * (AGXDirection)direction specify gradient direction.
 */
+ (UIImage *)imageGradientRectWithStartColor:(UIColor *)startColor endColor:(UIColor *)endColor direction:(AGXDirection)direction size:(CGSize)size {
    return [self imageGradientRectWithColors:@[startColor, endColor] locations:nil
                                   direction:direction size:size];
}

/**
 * (NSArray *)locations is an optional array of `NSNumber` objects defining the location of each gradient stop.
 * The gradient stops are specified as values between `0` and `1`. The values must be monotonically increasing.
 * If `nil`, the stops are spread uniformly across the range.
 */
+ (UIImage *)imageGradientRectWithColors:(NSArray *)colors locations:(NSArray *)locations direction:(AGXDirection)direction size:(CGSize)size {
    if AGX_EXPECT_F([colors count] < 2) return nil;

    CGRect rect = CGRectMake(0, 0, size.width, size.height);
    UIGraphicsBeginImageContextWithOptions(rect.size, NO, UIScreen.mainScreen.scale);
    CGContextRef context = UIGraphicsGetCurrentContext();

    CGGradientRef gradient = CreateGradientWithColorsAndLocations(colors, locations);
    if AGX_EXPECT_T(gradient) {
        CGVector vector = AGX_CGVectorFromDirection(direction);
        CGContextDrawLinearGradient(context, gradient,
                                    CGPointMake(size.width * MAX(0, -vector.dx), size.height * MAX(0, vector.dy)),
                                    CGPointMake(size.width * MAX(0, vector.dx), size.height * MAX(0, -vector.dy)),
                                    kCGGradientDrawsBeforeStartLocation | kCGGradientDrawsAfterEndLocation);
    }

    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    CGGradientRelease(gradient);
    UIGraphicsEndImageContext();
    return image;
}

+ (UIImage *)imageEllipseWithColor:(UIColor *)color size:(CGSize)size {
    CGRect rect = CGRectMake(0, 0, size.width, size.height);
    UIGraphicsBeginImageContextWithOptions(rect.size, NO, UIScreen.mainScreen.scale);
    CGContextRef context = UIGraphicsGetCurrentContext();

    CGContextSetFillColorWithColor(context, color.CGColor);
    CGContextFillEllipseInRect(context, rect);

    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

+ (UIImage *)imageCircleWithColor:(UIColor *)color size:(CGSize)size lineWidth:(CGFloat)lineWidth {
    UIGraphicsBeginImageContextWithOptions(size, NO, UIScreen.mainScreen.scale);
    CGContextRef context = UIGraphicsGetCurrentContext();

    CGContextSetStrokeColorWithColor(context, color.CGColor);
    CGContextSetLineWidth(context, lineWidth);
    CGContextStrokeEllipseInRect(context, CGRectMake
                                 (lineWidth, lineWidth,
                                  size.width-lineWidth*2, size.height-lineWidth*2));

    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

+ (UIImage *)imageCrossWithColor:(UIColor *)color edge:(CGFloat)edge lineWidth:(CGFloat)lineWidth {
    CGRect rect = CGRectMake(0, 0, edge, edge);
    UIGraphicsBeginImageContextWithOptions(rect.size, NO, UIScreen.mainScreen.scale);
    CGContextRef context = UIGraphicsGetCurrentContext();

    CGFloat radius = edge/2, radiusSqrt2 = radius/cgsqrt(2);
    CGContextTranslateCTM(context, radius, radius);
    CGContextSetStrokeColorWithColor(context, color.CGColor);
    CGContextSetLineWidth(context, lineWidth);
    CGContextSetLineCap(context, kCGLineCapRound);
    CGContextMoveToPoint(context, -radiusSqrt2, -radiusSqrt2);
    CGContextAddLineToPoint(context, radiusSqrt2, radiusSqrt2);
    CGContextStrokePath(context);
    CGContextMoveToPoint(context, radiusSqrt2, -radiusSqrt2);
    CGContextAddLineToPoint(context, -radiusSqrt2, radiusSqrt2);
    CGContextStrokePath(context);

    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

+ (UIImage *)imageEllipsisWithColor:(UIColor *)color edge:(CGFloat)edge {
    CGRect rect = CGRectMake(0, 0, edge, edge);
    UIGraphicsBeginImageContextWithOptions(rect.size, NO, UIScreen.mainScreen.scale);
    CGContextRef context = UIGraphicsGetCurrentContext();

    CGFloat radius = edge/9;
    CGSize pointSize = CGSizeMake(radius*2, radius*2);
    CGContextSetFillColorWithColor(context, color.CGColor);
    for (int i = 0; i < 3; i++) {
        CGPoint position = CGPointMake(edge/3*i+radius/2, edge/2-radius);
        CGContextFillEllipseInRect(context, AGX_CGRectMake(position, pointSize));
    }

    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

+ (UIImage *)imageArrowWithColor:(UIColor *)color edge:(CGFloat)edge direction:(AGXDirection)direction {
    CGRect rect = CGRectMake(0, 0, edge, edge);
    UIGraphicsBeginImageContextWithOptions(rect.size, NO, UIScreen.mainScreen.scale);
    CGContextRef context = UIGraphicsGetCurrentContext();

    CGFloat radius = edge/2, radiusSqrt2 = radius/cgsqrt(2);
    CGContextSetFillColorWithColor(context, color.CGColor);
    CGContextTranslateCTM(context, radius, radius);
    CGContextRotateCTM(context, direction*M_PI_4);
    CGContextMoveToPoint(context, -radiusSqrt2, radiusSqrt2);
    CGContextAddLineToPoint(context, 0, -radius);
    CGContextAddLineToPoint(context, radiusSqrt2, radiusSqrt2);
    CGContextAddLineToPoint(context, 0, radiusSqrt2/2);
    CGContextFillPath(context);

    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

+ (UIImage *)captchaImageWithCaptchaCode:(NSString *)captchaCode size:(CGSize)size {
    CGRect rect = CGRectMake(0, 0, size.width, size.height);
    UIGraphicsBeginImageContextWithOptions(rect.size, NO, UIScreen.mainScreen.scale);
    CGContextRef context = UIGraphicsGetCurrentContext();

    UIColor *backgroundColor = AGXRandom.UICOLOR_RGB_ALL_LIMITIN(.7, 1); // light
    CGContextSetFillColorWithColor(context, backgroundColor.CGColor);
    CGContextFillRect(context, rect);

    NSString *captchaText = [NSString stringWithFormat:@"%@", captchaCode];
    NSUInteger captchaTextCount = captchaText.length;
    CGFloat width = size.width / captchaText.length, height = size.height;

    for (int i = 0; i < captchaTextCount; i++) {
        NSString *code = [NSString stringWithFormat:@"%C", [captchaText characterAtIndex:i]];
        UIColor *color = AGXRandom.UICOLOR_RGB_ALL_LIMITIN(0, .4); // dark
        UIFont *font = AGXRandom.UIFONT_LIMITIN(height * .6, height * .8);
        CGSize codeSize = [code sizeWithAttributes:@{NSFontAttributeName: font}];
        CGPoint point = AGXRandom.CGPOINT_IN(CGRectMake(width * i, 0, width - codeSize.width,
                                                        height - codeSize.height));
        [code drawAtPoint:point withAttributes:@{NSForegroundColorAttributeName: color,
                                                 NSFontAttributeName: font}];
    }

    for (int i = 0; i < captchaTextCount; i++) {
        UIColor *color = AGXRandom.UICOLOR_RGB_ALL_LIMITIN(.3, .7); // middle
        CGContextSetStrokeColorWithColor(context, color.CGColor);
        CGContextSetLineWidth(context, AGXRandom.CGFLOAT_BETWEEN(AGX_SinglePixel, AGX_SinglePixel*5));
        CGPoint point = AGXRandom.CGPOINT_IN(rect);
        CGContextMoveToPoint(context, point.x, point.y);
        point = AGXRandom.CGPOINT_IN(rect);
        CGContextAddLineToPoint(context, point.x, point.y);
        CGContextStrokePath(context);
    }

    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

#pragma mark - watermark with image

+ (UIImage *)imageBaseOnImage:(UIImage *)baseImage watermarkedWithImage:(UIImage *)watermarkImage {
    return [self imageBaseOnImage:baseImage watermarkedWithImage:watermarkImage withOffset:CGVectorMake(0, 0)];
}

+ (UIImage *)imageBaseOnImage:(UIImage *)baseImage watermarkedWithImage:(UIImage *)watermarkImage inDirection:(AGXDirection)direction {
    return [self imageBaseOnImage:baseImage watermarkedWithImage:watermarkImage
                      inDirection:direction withOffset:CGVectorMake(0, 0)];
}

+ (UIImage *)imageBaseOnImage:(UIImage *)baseImage watermarkedWithImage:(UIImage *)watermarkImage withOffset:(CGVector)offset {
    return [self imageBaseOnImage:baseImage watermarkedWithImage:watermarkImage
                      inDirection:AGXDirectionSouthEast withOffset:offset];
}

+ (UIImage *)imageBaseOnImage:(UIImage *)baseImage watermarkedWithImage:(UIImage *)watermarkImage inDirection:(AGXDirection)direction withOffset:(CGVector)offset {
    CGSize baseImageSize = baseImage.size;
    UIGraphicsBeginImageContextWithOptions(baseImageSize, NO, baseImage.scale);
    [baseImage drawInRect:AGX_CGRectMake(CGPointMake(0, 0), baseImageSize)];

    CGFloat baseWidth = baseImageSize.width, baseHeight = baseImageSize.height;
    CGSize watermarkSize = watermarkImage.size;
    CGFloat fullX = baseWidth - watermarkSize.width;
    CGFloat fullY = baseHeight - watermarkSize.height;

    CGVector vector = AGX_CGVectorFromDirection(direction);
    CGPoint watermarkOrigin = CGPointMake(fullX/2*(1+vector.dx)-offset.dx*vector.dx,
                                          fullY/2*(1-vector.dy)+offset.dy*vector.dy);
    [watermarkImage drawInRect:AGX_CGRectMake(watermarkOrigin, watermarkSize)];

    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

#pragma mark - watermark with text

+ (UIImage *)imageBaseOnImage:(UIImage *)baseImage watermarkedWithText:(NSString *)watermarkText {
    return [self imageBaseOnImage:baseImage watermarkedWithText:watermarkText withAttributes:@{}];
}

+ (UIImage *)imageBaseOnImage:(UIImage *)baseImage watermarkedWithText:(NSString *)watermarkText withAttributes:(NSDictionary<NSAttributedStringKey, id> *)attrs {
    return [self imageBaseOnImage:baseImage watermarkedWithText:watermarkText
                   withAttributes:attrs withOffset:CGVectorMake(0, 0)];
}

+ (UIImage *)imageBaseOnImage:(UIImage *)baseImage watermarkedWithText:(NSString *)watermarkText inDirection:(AGXDirection)direction {
    return [self imageBaseOnImage:baseImage watermarkedWithText:watermarkText
                   withAttributes:@{} inDirection:direction];
}

+ (UIImage *)imageBaseOnImage:(UIImage *)baseImage watermarkedWithText:(NSString *)watermarkText withOffset:(CGVector)offset {
    return [self imageBaseOnImage:baseImage watermarkedWithText:watermarkText
                   withAttributes:@{} withOffset:offset];
}

+ (UIImage *)imageBaseOnImage:(UIImage *)baseImage watermarkedWithText:(NSString *)watermarkText withAttributes:(NSDictionary<NSAttributedStringKey, id> *)attrs inDirection:(AGXDirection)direction {
    return [self imageBaseOnImage:baseImage watermarkedWithText:watermarkText
                   withAttributes:attrs inDirection:direction withOffset:CGVectorMake(0, 0)];
}

+ (UIImage *)imageBaseOnImage:(UIImage *)baseImage watermarkedWithText:(NSString *)watermarkText withAttributes:(NSDictionary<NSAttributedStringKey, id> *)attrs withOffset:(CGVector)offset {
    return [self imageBaseOnImage:baseImage watermarkedWithText:watermarkText
                   withAttributes:attrs inDirection:AGXDirectionSouthEast withOffset:offset];
}

+ (UIImage *)imageBaseOnImage:(UIImage *)baseImage watermarkedWithText:(NSString *)watermarkText inDirection:(AGXDirection)direction withOffset:(CGVector)offset {
    return [self imageBaseOnImage:baseImage watermarkedWithText:watermarkText
                   withAttributes:@{} inDirection:direction withOffset:offset];
}

+ (UIImage *)imageBaseOnImage:(UIImage *)baseImage watermarkedWithText:(NSString *)watermarkText withAttributes:(NSDictionary<NSAttributedStringKey, id> *)attrs inDirection:(AGXDirection)direction withOffset:(CGVector)offset {
    NSMutableDictionary *attributes = [NSMutableDictionary dictionaryWithDictionary:attrs];
    if (!attributes[NSForegroundColorAttributeName]) {
        attributes[NSForegroundColorAttributeName] = AGX_UIColor(1, 1, 1, .7);
    }

    CGSize baseImageSize = baseImage.size;
    UIGraphicsBeginImageContextWithOptions(baseImageSize, NO, baseImage.scale);
    [baseImage drawInRect:AGX_CGRectMake(CGPointMake(0, 0), baseImageSize)];

    CGFloat baseWidth = baseImageSize.width, baseHeight = baseImageSize.height;
    CGSize watermarkSize = [watermarkText sizeWithAttributes:attributes];
    CGFloat fullX = baseWidth - watermarkSize.width;
    CGFloat fullY = baseHeight - watermarkSize.height;

    CGVector vector = AGX_CGVectorFromDirection(direction);
    CGPoint watermarkOrigin = CGPointMake(fullX/2*(1+vector.dx)-offset.dx*vector.dx,
                                          fullY/2*(1-vector.dy)+offset.dy*vector.dy);
    [watermarkText drawInRect:AGX_CGRectMake(watermarkOrigin, watermarkSize)
               withAttributes:attributes];

    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

#pragma mark - image for device

+ (UIImage *)imageForCurrentDeviceNamed:(NSString *)name {
    return [self imageNamed:[self imageNameForCurrentDeviceNamed:name]];
}

+ (NSString *)imageNameForCurrentDeviceNamed:(NSString *)name {
    return [NSString stringWithFormat:@"%@%@", name, AGX_IS_IPHONEX?@"-1100-2436h":(AGX_IS_IPHONE6P?@"-800-Portrait-736h":(AGX_IS_IPHONE6||AGX_IS_IPHONE6P_BIGMODE?@"-800-667h":(AGX_IS_IPHONE5?@"-700-568h":@"")))];
}

+ (NSString *)imageNameForCurrentPixelRatioNamed:(NSString *)name {
    if AGX_EXPECT_F([UIScreen mainScreen].scale <= 1) return name;
    return [NSString stringWithFormat:@"%@@%dx", name, (int)[UIScreen mainScreen].scale];
}

- (UIColor *)dominantColor {
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef context = CGBitmapContextCreate(NULL, self.size.width, self.size.height,
                                                 8, self.size.width * 4, colorSpace,
                                                 kCGImageAlphaPremultipliedLast);
    CGRect drawRect = CGRectMake(0, 0, self.size.width, self.size.height);
    CGContextDrawImage(context, drawRect, self.CGImage);
    CGColorSpaceRelease(colorSpace);

    unsigned char *data = CGBitmapContextGetData(context);
    if AGX_EXPECT_F(!data) { CGContextRelease(context); return nil; }

    NSCountedSet *colorSet = [NSCountedSet setWithCapacity:self.size.width * self.size.height];
    for (int x = 0; x < self.size.width; x++) {
        for (int y = 0; y < self.size.height; y++) {
            int offset = 4 * (x * y);
            [colorSet addObject:@[@(data[offset]),
                                  @(data[offset+1]),
                                  @(data[offset+2]),
                                  @(data[offset+3])]];
        }
    }
    CGContextRelease(context);

    NSEnumerator *enumerator = [colorSet objectEnumerator];
    NSArray *curColor = nil;
    NSArray *maxColor = nil;
    NSUInteger maxCount = 0;

    while ((curColor = [enumerator nextObject]) != nil) {
        NSUInteger tmpCount = [colorSet countForObject:curColor];
        if (tmpCount < maxCount) continue;
        maxCount = tmpCount;
        maxColor = curColor;
    }
    return [UIColor colorWithRed:([maxColor[0] intValue]/255.f)/([maxColor[3] intValue]/255.f)
                           green:([maxColor[1] intValue]/255.f)/([maxColor[3] intValue]/255.f)
                            blue:([maxColor[2] intValue]/255.f)/([maxColor[3] intValue]/255.f)
                           alpha:([maxColor[3] intValue]/255.f)];
}

#pragma mark - image process

//
//  Modify from:
//  banchichen/TZImagePickerController
//

//  The MIT License (MIT)
//
//  Copyright (c) 2016 Zhen Tan
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.

+ (UIImage *)imageFixedOrientation:(UIImage *)aImage {
    // No-op if the orientation is already correct
    if (aImage.imageOrientation == UIImageOrientationUp) return aImage;

    // We need to calculate the proper transformation to make the image upright.
    // We do it in 2 steps: Rotate if Left/Right/Down, and then flip if Mirrored.
    CGAffineTransform transform = CGAffineTransformIdentity;
    switch (aImage.imageOrientation) {
        case UIImageOrientationDown:
        case UIImageOrientationDownMirrored:
            transform = CGAffineTransformTranslate(transform, aImage.size.width, aImage.size.height);
            transform = CGAffineTransformRotate(transform, M_PI);
            break;

        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
            transform = CGAffineTransformTranslate(transform, aImage.size.width, 0);
            transform = CGAffineTransformRotate(transform, M_PI_2);
            break;

        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
            transform = CGAffineTransformTranslate(transform, 0, aImage.size.height);
            transform = CGAffineTransformRotate(transform, -M_PI_2);
            break;

        default:
            break;
    }
    switch (aImage.imageOrientation) {
        case UIImageOrientationUpMirrored:
        case UIImageOrientationDownMirrored:
            transform = CGAffineTransformTranslate(transform, aImage.size.width, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;

        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRightMirrored:
            transform = CGAffineTransformTranslate(transform, aImage.size.height, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;

        default:
            break;
    }

    // Now we draw the underlying CGImage into a new context, applying the transform
    // calculated above.
    CGContextRef context = CGBitmapContextCreate(NULL, aImage.size.width, aImage.size.height,
                                                 CGImageGetBitsPerComponent(aImage.CGImage), 0,
                                                 CGImageGetColorSpace(aImage.CGImage),
                                                 CGImageGetBitmapInfo(aImage.CGImage));
    CGContextConcatCTM(context, transform);
    switch (aImage.imageOrientation) {
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
            // Grr...
            CGContextDrawImage(context, CGRectMake(0, 0, aImage.size.height,
                                                   aImage.size.width), aImage.CGImage);
            break;

        default:
            CGContextDrawImage(context, CGRectMake(0, 0, aImage.size.width,
                                                   aImage.size.height), aImage.CGImage);
            break;
    }

    // And now we just create a new UIImage from the drawing context
    CGImageRef cgImage = CGBitmapContextCreateImage(context);
    UIImage *image = [UIImage imageWithCGImage:cgImage];
    CGContextRelease(context);
    CGImageRelease(cgImage);
    return image;
}

+ (UIImage *)image:(UIImage *)image scaleToSize:(CGSize)size {
    if (image.size.width <= size.width &&
        image.size.height <= size.height) return image;

    UIGraphicsBeginImageContext(size);
    [image drawInRect:CGRectMake(0, 0, size.width, size.height)];
    UIImage *scaledImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return scaledImage;
}

#pragma mark - inline function -

AGX_STATIC CGGradientRef CreateGradientWithColorsAndLocations(NSArray *colors, NSArray *locations) {
    NSUInteger colorsCount = [colors count];
    NSUInteger locationsCount = [locations count];

    CGColorSpaceRef colorSpace = CGColorGetColorSpace([[colors objectAtIndex:0] CGColor]);

    CGFloat *gradientLocations = NULL;
    if (locationsCount == colorsCount) {
        gradientLocations = (CGFloat *)malloc(sizeof(CGFloat) * locationsCount);
        for (NSUInteger i = 0; i < locationsCount; i++) {
            gradientLocations[i] = [[locations objectAtIndex:i] floatValue];
        }
    }

    NSMutableArray *gradientColors = [[NSMutableArray alloc] initWithCapacity:colorsCount];
    [colors enumerateObjectsUsingBlock:^(id object, NSUInteger index, BOOL *stop) {
        [gradientColors addObject:(id)[(UIColor *)object CGColor]];
    }];

    CGGradientRef gradient = CGGradientCreateWithColors(colorSpace, (AGX_BRIDGE CFArrayRef)gradientColors, gradientLocations);

    AGX_RELEASE(gradientColors);
    if (gradientLocations) free(gradientLocations);

    return gradient;
}

@end

@category_implementation(AGXDirectory, AGXCoreUIImage)

+ (UIImage *(^)(NSString *))imageForCurrentDeviceWithFile {
    return AGXDirectory.document.imageForCurrentDeviceWithFile;
}

+ (BOOL (^)(NSString *, UIImage *))writeToFileWithImageForCurrentDevice {
    return AGXDirectory.document.writeToFileWithImageForCurrentDevice;
}

- (UIImage *(^)(NSString *))imageForCurrentDeviceWithFile {
    return AGX_BLOCK_AUTORELEASE(^UIImage *(NSString *fileName) {
        return self.imageWithFile([UIImage imageNameForCurrentDeviceNamed:fileName]);
    });
}

- (BOOL (^)(NSString *, UIImage *))writeToFileWithImageForCurrentDevice {
    return AGX_BLOCK_AUTORELEASE(^BOOL (NSString *fileName, UIImage *image) {
        return self.writeToFileWithImage([UIImage imageNameForCurrentDeviceNamed:fileName], image);
    });
}

@end

@category_implementation(AGXBundle, AGXCoreUIImage)

+ (UIImage *(^)(NSString *))imageForCurrentDeviceWithFile {
    return AGXBundle.appBundle.imageForCurrentDeviceWithFile;
}

- (UIImage *(^)(NSString *))imageForCurrentDeviceWithFile {
    return AGX_BLOCK_AUTORELEASE(^UIImage *(NSString *fileName) {
        return self.imageWithFile([UIImage imageNameForCurrentDeviceNamed:fileName]);
    });
}

@end
