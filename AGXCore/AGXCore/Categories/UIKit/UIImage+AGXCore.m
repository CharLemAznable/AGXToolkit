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

@category_implementation(UIImage, AGXCore)

+ (UIImage *)imageWithURLString:(NSString *)urlString {
    return [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:urlString]]];
}

+ (UIImage *)imagePointWithColor:(UIColor *)color {
    return [self imageRectWithColor:color size:CGSizeMake(1, 1)];
}

+ (UIImage *)imageRectWithColor:(UIColor *)color size:(CGSize)size {
    CGRect rect = CGRectMake(0, 0, size.width, size.height);
    UIGraphicsBeginImageContext(rect.size);
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
+ (UIImage *)imageGradientRectWithStartColor:(UIColor *)startColor endColor:(UIColor *)endColor
                                   direction:(AGXDirection)direction size:(CGSize)size {
    return [self imageGradientRectWithColors:@[startColor, endColor] locations:nil
                                   direction:direction size:size];
}

/**
 * (NSArray *)locations is an optional array of `NSNumber` objects defining the location of each gradient stop.
 * The gradient stops are specified as values between `0` and `1`. The values must be monotonically increasing.
 * If `nil`, the stops are spread uniformly across the range.
 */
+ (UIImage *)imageGradientRectWithColors:(NSArray *)colors locations:(NSArray *)locations
                               direction:(AGXDirection)direction size:(CGSize)size {
    if (AGX_EXPECT_F([colors count] < 2)) return nil;

    CGRect rect = CGRectMake(0, 0, size.width, size.height);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();

    CGGradientRef gradient = CreateGradientWithColorsAndLocations(colors, locations);
    if (AGX_EXPECT_T(gradient)) {
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
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();

    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillEllipseInRect(context, rect);

    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

+ (UIImage *)imageForCurrentDeviceNamed:(NSString *)name {
    return [self imageNamed:[self imageNameForCurrentDeviceNamed:name]];
}

+ (NSString *)imageNameForCurrentDeviceNamed:(NSString *)name {
    return [NSString stringWithFormat:@"%@%@", name, AGX_IS_IPHONE6P ? @"-800-Portrait-736h":(AGX_IS_IPHONE6 ? @"-800-667h":(AGX_IS_IPHONE5 ? @"-700-568h":@""))];
}

+ (NSString *)imageNameForCurrentPixelRatioNamed:(NSString *)name {
    if ([UIScreen mainScreen].scale <= 1) return name;
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
    if (AGX_EXPECT_F(!data)) { CGContextRelease(context); return nil; }

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
