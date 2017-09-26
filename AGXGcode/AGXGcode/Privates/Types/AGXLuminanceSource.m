//
//  AGXLuminanceSource.m
//  AGXGcode
//
//  Created by Char Aznable on 16/7/27.
//  Copyright © 2016年 AI-CUC-EC. All rights reserved.
//

//
//  Modify from:
//  TheLevelUp/ZXingObjC
//

//
//  Copyright 2014 ZXing authors
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//      http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//

#import <AGXCore/AGXCore/AGXArc.h>
#import "AGXLuminanceSource.h"

@interface AGXInvertedLuminanceSource : AGXLuminanceSource
@property (nonatomic, AGX_WEAK, readonly) AGXLuminanceSource *original;

- (AGX_INSTANCETYPE)initWithOriginal:(AGXLuminanceSource *)original;
@end

@implementation AGXLuminanceSource {
    int8_t *_data;
    size_t _left;
    size_t _top;
}

+ (AGX_INSTANCETYPE)luminanceSourceWithCGImage:(CGImageRef)image {
    return AGX_AUTORELEASE([[self alloc] initWithCGImage:image]);
}

+ (AGX_INSTANCETYPE)luminanceSourceWithCGImage:(CGImageRef)image left:(size_t)left top:(size_t)top width:(size_t)width height:(size_t)height {
    return AGX_AUTORELEASE([[self alloc] initWithCGImage:image left:left top:top width:width height:height]);
}

- (AGX_INSTANCETYPE)initWithCGImage:(CGImageRef)image {
    return [self initWithCGImage:image left:0 top:0 width:CGImageGetWidth(image) height:CGImageGetHeight(image)];
}

- (AGX_INSTANCETYPE)initWithCGImage:(CGImageRef)image left:(size_t)left top:(size_t)top width:(size_t)width height:(size_t)height {
    if AGX_EXPECT_T(self = [super init]) {
        _image = CGImageRetain(image);
        _width = (int)width;
        _height = (int)height;
        _data = 0;
        _left = left;
        _top = top;

        size_t sourceWidth = CGImageGetWidth(image);
        size_t sourceHeight = CGImageGetHeight(image);
        size_t selfWidth = width;
        size_t selfHeight= height;

        if AGX_EXPECT_F(left + selfWidth > sourceWidth || top + selfHeight > sourceHeight)
            [NSException raise:NSInvalidArgumentException format:@"Crop rectangle does not fit within image data."];

        CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
        CGContextRef context = CGBitmapContextCreate(NULL, selfWidth, selfHeight, 8, selfWidth * 4, colorSpace, kCGBitmapByteOrder32Little|kCGImageAlphaPremultipliedLast);
        CGColorSpaceRelease(colorSpace);

        CGContextSetAllowsAntialiasing(context, FALSE);
        CGContextSetInterpolationQuality(context, kCGInterpolationNone);

        if (top || left) CGContextClipToRect(context, CGRectMake(0, 0, selfWidth, selfHeight));

        CGContextDrawImage(context, CGRectMake(-left, -top, selfWidth, selfHeight), _image);

        uint32_t *pixelData = CGBitmapContextGetData(context);

        _data = (int8_t *)malloc(selfWidth * selfHeight * sizeof(int8_t));

        dispatch_apply(selfHeight, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^(size_t idx) {
            size_t stripe_start = idx * selfWidth;
            size_t stripe_stop = stripe_start + selfWidth;

            for (size_t i = stripe_start; i < stripe_stop; i++) {
                uint32_t rgbPixelIn = pixelData[i];
                uint32_t rgbPixelOut = 0;

                uint32_t red = (rgbPixelIn >> 24) & 0xFF;
                uint32_t green = (rgbPixelIn >> 16) & 0xFF;
                uint32_t blue = (rgbPixelIn >> 8) & 0xFF;
                uint32_t alpha = (rgbPixelIn & 0xFF);

                // ImageIO premultiplies all PNGs, so we have to "un-premultiply them":
                // http://code.google.com/p/cocos2d-iphone/issues/detail?id=697#c26
                if (alpha != 0xFF) {
                    red   =   red > 0 ? ((red   << 20) / (alpha << 2)) >> 10 : 0;
                    green = green > 0 ? ((green << 20) / (alpha << 2)) >> 10 : 0;
                    blue  =  blue > 0 ? ((blue  << 20) / (alpha << 2)) >> 10 : 0;
                }

                if (red == green && green == blue) {
                    rgbPixelOut = red;
                } else {
                    // 0x200 = 1<<9, half an lsb of the result to force rounding
                    rgbPixelOut = (306 * red + 601 * green + 117 * blue + (0x200)) >> 10;
                }

                if (rgbPixelOut > 255) {
                    rgbPixelOut = 255;
                }

                _data[i] = rgbPixelOut;
            }
        });

        CGContextRelease(context);

        _left = left;
        _top = top;
    }
    return self;
}

- (void)dealloc {
    if (_image) CGImageRelease(_image);
    if (_data) free(_data);
    AGX_SUPER_DEALLOC;
}

- (AGXByteArray *)rowAtY:(int)y row:(AGXByteArray *)row {
    if AGX_EXPECT_F(y < 0 || y >= _height)
        [NSException raise:NSInvalidArgumentException format:
         @"Requested row is outside the image: %d", y];

    if (!row || row.length < _width) {
        row = [AGXByteArray byteArrayWithLength:_width];
    }
    int offset = y * _width;
    memcpy(row.array, _data + offset, _width * sizeof(int8_t));
    return row;
}

- (AGXByteArray *)matrix {
    int area = _width * _height;

    AGXByteArray *matrix = [AGXByteArray byteArrayWithLength:area];
    memcpy(matrix.array, _data, area * sizeof(int8_t));
    return matrix;
}

- (AGXLuminanceSource *)invert {
    return AGX_AUTORELEASE([[AGXInvertedLuminanceSource alloc] initWithOriginal:self]);
}

- (AGXLuminanceSource *)crop:(int)left top:(int)top width:(int)width height:(int)height {
    CGImageRef croppedImageRef = CGImageCreateWithImageInRect(_image, CGRectMake(left, top, width, height));
    AGXLuminanceSource *result = [[AGXLuminanceSource alloc] initWithCGImage:croppedImageRef];
    CGImageRelease(croppedImageRef);
    return AGX_AUTORELEASE(result);
}

- (AGXLuminanceSource *)rotateCounterClockwise {
    double radians = 270.0f * M_PI / 180;

#if TARGET_OS_EMBEDDED || TARGET_IPHONE_SIMULATOR
    radians = -1 * radians;
#endif

    int sourceWidth = _width;
    int sourceHeight = _height;

    CGRect imgRect = CGRectMake(0, 0, sourceWidth, sourceHeight);
    CGAffineTransform transform = CGAffineTransformMakeRotation(radians);
    CGRect rotatedRect = CGRectApplyAffineTransform(imgRect, transform);

    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef context = CGBitmapContextCreate(NULL, rotatedRect.size.width, rotatedRect.size.height, 8, 0, colorSpace, kCGBitmapAlphaInfoMask & kCGImageAlphaPremultipliedFirst);
    CGContextSetAllowsAntialiasing(context, FALSE);
    CGContextSetInterpolationQuality(context, kCGInterpolationNone);
    CGColorSpaceRelease(colorSpace);

    CGContextTranslateCTM(context, +(rotatedRect.size.width/2), +(rotatedRect.size.height/2));
    CGContextRotateCTM(context, radians);

    CGContextDrawImage(context, CGRectMake(-imgRect.size.width/2, -imgRect.size.height/2, imgRect.size.width, imgRect.size.height), _image);

    CGImageRef rotatedImage = CGBitmapContextCreateImage(context);
    CFRelease(context);

    AGXLuminanceSource *result = [[AGXLuminanceSource alloc] initWithCGImage:rotatedImage left:_top top:sourceWidth - (_left + _width) width:_height height:_width];
    CGImageRelease(rotatedImage);

    return AGX_AUTORELEASE(result);
}

- (NSString *)description {
    AGXByteArray *row = [AGXByteArray byteArrayWithLength:self.width];
    NSMutableString *result = [NSMutableString stringWithCapacity:self.height * (self.width + 1)];
    for (int y = 0; y < self.height; y++) {
        row = [self rowAtY:y row:row];
        for (int x = 0; x < self.width; x++) {
            int luminance = row.array[x] & 0xFF;
            unichar c;
            if (luminance < 0x40) {
                c = '#';
            } else if (luminance < 0x80) {
                c = '+';
            } else if (luminance < 0xC0) {
                c = '.';
            } else {
                c = ' ';
            }
            [result appendFormat:@"%C", c];
        }
        [result appendString:@"\n"];
    }
    return result;
}

@end

@implementation AGXInvertedLuminanceSource

- (AGX_INSTANCETYPE)initWithOriginal:(AGXLuminanceSource *)original {
    if AGX_EXPECT_T(self = [super initWithCGImage:original.image]) {
        _original = original;
    }
    return self;
}

- (void)dealloc {
    _original = nil;
    AGX_SUPER_DEALLOC;
}

- (AGXByteArray *)rowAtY:(int)y row:(AGXByteArray *)row {
    row = [self.original rowAtY:y row:row];
    int width = self.width;
    int8_t *rowArray = row.array;
    for (int i = 0; i < width; i++) {
        rowArray[i] = (int8_t) (255 - (rowArray[i] & 0xFF));
    }
    return row;
}

- (AGXByteArray *)matrix {
    AGXByteArray *matrix = [self.original matrix];
    int length = self.width * self.height;
    AGXByteArray *invertedMatrix = [AGXByteArray byteArrayWithLength:length];
    int8_t *invertedMatrixArray = invertedMatrix.array;
    int8_t *matrixArray = matrix.array;
    for (int i = 0; i < length; i++) {
        invertedMatrixArray[i] = (int8_t) (255 - (matrixArray[i] & 0xFF));
    }
    return invertedMatrix;
}

- (AGXLuminanceSource *)invert {
    return self.original;
}

- (AGXLuminanceSource *)crop:(int)left top:(int)top width:(int)aWidth height:(int)aHeight {
    return AGX_AUTORELEASE([[AGXInvertedLuminanceSource alloc] initWithOriginal:
                            [self.original crop:left top:top width:aWidth height:aHeight]]);
}

- (AGXLuminanceSource *)rotateCounterClockwise {
    return AGX_AUTORELEASE([[AGXInvertedLuminanceSource alloc] initWithOriginal:
                            [self.original rotateCounterClockwise]]);
}

@end
