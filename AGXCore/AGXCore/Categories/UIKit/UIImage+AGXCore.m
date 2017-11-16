//
//  UIImage+AGXCore.m
//  AGXCore
//
//  Created by Char Aznable on 16/2/17.
//  Copyright © 2016年 AI-CUC-EC. All rights reserved.
//

#import "UIImage+AGXCore.h"
#import "AGXArc.h"
#import "AGXAdapt.h"
#import "AGXRandom.h"
#import "UIColor+AGXCore.h"

@category_implementation(UIImage, AGXCore)

+ (UIImage *)imageWithURLString:(NSString *)URLString {
    return [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:URLString]]];
}

#pragma mark - image create

+ (UIImage *)imagePointWithColor:(UIColor *)color {
    return [self imageRectWithColor:color size:CGSizeMake(1, 1)];
}

+ (UIImage *)imageRectWithColor:(UIColor *)color size:(CGSize)size {
    CGRect rect = CGRectMake(0, 0, size.width, size.height);
    UIGraphicsBeginImageContextWithOptions(rect.size, NO, UIScreen.mainScreen.scale);
    CGContextRef context = UIGraphicsGetCurrentContext();

    CGContextSetFillColorWithColor(context, [color CGColor]);
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

    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillEllipseInRect(context, rect);

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
        attributes[NSForegroundColorAttributeName] = baseImage.dominantColor.colorShade
        == AGXColorShadeDark ? [UIColor whiteColor] : [UIColor blackColor];
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
