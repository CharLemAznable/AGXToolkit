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

- (UIColor *)dominantColor {
    int bitmapInfo = kCGBitmapByteOrderDefault | kCGImageAlphaPremultipliedLast;
    CGSize thumbSize=CGSizeMake(MAX(self.size.width / 4, 1), MAX(self.size.height / 4, 1));
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef context = CGBitmapContextCreate(NULL, thumbSize.width, thumbSize.height,
                                                 8, thumbSize.width*4, colorSpace, bitmapInfo);
    CGRect drawRect = CGRectMake(0, 0, thumbSize.width, thumbSize.height);
    CGContextDrawImage(context, drawRect, self.CGImage);
    CGColorSpaceRelease(colorSpace);

    unsigned char *data = CGBitmapContextGetData(context);
    if (AGX_EXPECT_F(!data)) { CGContextRelease(context); return nil; }

    NSCountedSet *colorSet = [NSCountedSet setWithCapacity:thumbSize.width * thumbSize.height];
    for (int x = 0; x < thumbSize.width; x++) {
        for (int y = 0; y < thumbSize.height; y++) {
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
    return [UIColor colorWithRed:([maxColor[0] intValue]/255.f)
                           green:([maxColor[1] intValue]/255.f)
                            blue:([maxColor[2] intValue]/255.f)
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

+ (UIImage *)imageWithContentsOfUserFile:(NSString *)fileName {
    return [self imageWithContentsOfUserFile:fileName subpath:nil];
}

+ (UIImage *)imageWithContentsOfUserFile:(NSString *)fileName subpath:(NSString *)subpath {
    if (AGXDirectory.document.subpath(subpath).fileExists(fileName))
        return [self imageWithContentsOfUserFile:fileName inDirectory:AGXDocument subpath:subpath];
    return [self imageWithContentsOfUserFile:fileName bundle:nil subpath:subpath];
}

+ (UIImage *)imageWithContentsOfUserFile:(NSString *)fileName inDirectory:(AGXDirectoryType)directory {
    return [self imageWithContentsOfUserFile:fileName inDirectory:directory subpath:nil];
}

+ (UIImage *)imageWithContentsOfUserFile:(NSString *)fileName inDirectory:(AGXDirectoryType)directory subpath:(NSString *)subpath {
    NSString *fname = [NSString stringWithFormat:@"%@.png", fileName];
    AGXDirectory *dir = AGXDirectory.document.subpath(subpath);
    if (AGX_EXPECT_F(!dir.fileExists(fname))) return nil;
    return [self imageWithContentsOfFile:dir.filePath(fname)];
}

+ (UIImage *)imageWithContentsOfUserFile:(NSString *)fileName bundle:(NSString *)bundleName {
    return [self imageWithContentsOfUserFile:fileName bundle:bundleName subpath:nil];
}

+ (UIImage *)imageWithContentsOfUserFile:(NSString *)fileName bundle:(NSString *)bundleName subpath:(NSString *)subpath {
    return AGXBundle.bundleNamed(bundleName).subpath(subpath).imageNamed(fileName);
}

- (BOOL)writeToUserFile:(NSString *)fileName {
    return [self writeToUserFile:fileName inDirectory:AGXDocument];
}

- (BOOL)writeToUserFile:(NSString *)fileName inDirectory:(AGXDirectoryType)directory {
    return [self writeToUserFile:fileName inDirectory:directory subpath:nil];
}

- (BOOL)writeToUserFile:(NSString *)fileName inDirectory:(AGXDirectoryType)directory subpath:(NSString *)subpath {
    AGXDirectory *dir = AGXDirectory.document.subpath(subpath);
    return(dir.createPathOfFile(fileName) &&
           [UIImagePNGRepresentation(self) writeToFile:dir.filePath(fileName) atomically:YES]);
}

@end

@category_implementation(AGXBundle, AGXCoreUIImage)

+ (UIImage *)imageForCurrentDeviceWithName:(NSString *)imageName {
    return [self imageForCurrentDeviceWithName:imageName bundle:nil];
}

+ (UIImage *)imageForCurrentDeviceWithName:(NSString *)imageName bundle:(NSString *)bundleName {
    return [self imageForCurrentDeviceWithName:imageName bundle:bundleName subpath:nil];
}

+ (UIImage *)imageForCurrentDeviceWithName:(NSString *)imageName bundle:(NSString *)bundleName subpath:(NSString *)subpath {
    return AGXBundle.bundleNamed(bundleName).subpath(subpath).imageNamed([UIImage imageNameForCurrentDeviceNamed:imageName]);
}

@end
