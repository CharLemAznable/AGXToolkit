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
#import "AGXBundle.h"
#import "AGXDirectory.h"

@category_interface(UIImage, AGXCore)
+ (UIImage *)imagePointWithColor:(UIColor *)color;
+ (UIImage *)imageRectWithColor:(UIColor *)color size:(CGSize)size;
+ (UIImage *)imageGradientRectWithStartColor:(UIColor *)startColor endColor:(UIColor *)endColor direction:(AGXDirection)direction size:(CGSize)size;
+ (UIImage *)imageGradientRectWithColors:(NSArray *)colors locations:(NSArray *)locations direction:(AGXDirection)direction size:(CGSize)size;
+ (UIImage *)imageEllipseWithColor:(UIColor *)color size:(CGSize)size;
+ (UIImage *)imageForCurrentDeviceNamed:(NSString *)name;
+ (NSString *)imageNameForCurrentDeviceNamed:(NSString *)name;
- (UIColor *)dominantColor;

+ (UIImage *)imageWithContentsOfUserFile:(NSString *)fileName;
+ (UIImage *)imageWithContentsOfUserFile:(NSString *)fileName subpath:(NSString *)subpath;
+ (UIImage *)imageWithContentsOfUserFile:(NSString *)fileName inDirectory:(AGXDirectoryType)directory;
+ (UIImage *)imageWithContentsOfUserFile:(NSString *)fileName inDirectory:(AGXDirectoryType)directory subpath:(NSString *)subpath;
+ (UIImage *)imageWithContentsOfUserFile:(NSString *)fileName bundle:(NSString *)bundleName;
+ (UIImage *)imageWithContentsOfUserFile:(NSString *)fileName bundle:(NSString *)bundleName subpath:(NSString *)subpath;

- (BOOL)writeToUserFile:(NSString *)fileName;
- (BOOL)writeToUserFile:(NSString *)fileName inDirectory:(AGXDirectoryType)directory;
- (BOOL)writeToUserFile:(NSString *)fileName inDirectory:(AGXDirectoryType)directory subpath:(NSString *)subpath;
@end

@category_interface(AGXBundle, AGXCoreUIImage)
+ (UIImage *)imageForCurrentDeviceWithName:(NSString *)imageName;
+ (UIImage *)imageForCurrentDeviceWithName:(NSString *)imageName bundle:(NSString *)bundleName;
+ (UIImage *)imageForCurrentDeviceWithName:(NSString *)imageName bundle:(NSString *)bundleName subpath:(NSString *)subpath;
@end

#endif /* AGXCore_UIImage_AGXCore_h */
