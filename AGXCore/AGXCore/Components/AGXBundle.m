//
//  AGXBundle.m
//  AGXCore
//
//  Created by Char Aznable on 16/2/4.
//  Copyright © 2016年 AI-CUC-EC. All rights reserved.
//

#import "AGXBundle.h"
#import "NSString+AGXCore.h"

@implementation AGXBundle

+ (NSBundle *)appBundle {
    return [NSBundle bundleForClass:[AGXBundle class]];
}

+ (NSString *)appIdentifier {
    return [[AGXBundle appBundle].infoDictionary objectForKey:@"CFBundleIdentifier"];
}

+ (NSString *)appVersion {
    return [[AGXBundle appBundle].infoDictionary objectForKey:@"CFBundleShortVersionString"];
}

+ (UIImage *)imageWithName:(NSString *)imageName {
    return [self imageWithName:imageName bundle:nil];
}

+ (UIImage *)imageForCurrentDeviceWithName:(NSString *)imageName {
    return [self imageForCurrentDeviceWithName:imageName bundle:nil];
}

+ (NSString *)plistPathWithName:(NSString *)fileName {
    return [self plistPathWithName:fileName bundle:nil];
}

+ (NSURL *)audioURLWithName:(NSString *)fileName type:(NSString *)fileType {
    return [self audioURLWithName:fileName type:fileType bundle:nil];
}

+ (UIImage *)imageWithName:(NSString *)imageName bundle:(NSString *)bundleName {
    return [self imageWithName:imageName bundle:bundleName subpath:nil];
}

+ (UIImage *)imageForCurrentDeviceWithName:(NSString *)imageName bundle:(NSString *)bundleName {
    return [self imageForCurrentDeviceWithName:imageName bundle:bundleName subpath:nil];
}

+ (NSString *)plistPathWithName:(NSString *)fileName bundle:(NSString *)bundleName {
    return [self plistPathWithName:fileName bundle:bundleName subpath:nil];
}

+ (NSURL *)audioURLWithName:(NSString *)fileName type:(NSString *)fileType bundle:(NSString *)bundleName {
    return [self audioURLWithName:fileName type:fileType bundle:bundleName subpath:nil];
}

+ (UIImage *)imageWithName:(NSString *)imageName bundle:(NSString *)bundleName subpath:(NSString *)subpath {
    return [UIImage imageWithContentsOfFile:bundleFilePath(imageName, @"png", bundleName, subpath)];
}

+ (UIImage *)imageForCurrentDeviceWithName:(NSString *)imageName bundle:(NSString *)bundleName subpath:(NSString *)subpath {
    return [self imageWithName:[UIImage imageNameForCurrentDeviceNamed:imageName] bundle:bundleName subpath:subpath];
}

+ (NSString *)plistPathWithName:(NSString *)fileName bundle:(NSString *)bundleName subpath:(NSString *)subpath {
    return bundleFilePath(fileName, @"plist", bundleName, subpath);
}

+ (NSURL *)audioURLWithName:(NSString *)fileName type:(NSString *)fileType bundle:(NSString *)bundleName subpath:(NSString *)subpath {
    return [NSURL fileURLWithPath:bundleFilePath(fileName, fileType, bundleName, subpath)];
}

#pragma mark - private functions -

NSString *bundleFilePath(NSString *fileName, NSString *fileType, NSString *bundleName, NSString *subpath) {
    NSBundle *bundle = [AGXBundle appBundle];
    // if bundleName is nil or empty, search file in mainBundle, subpath defines sub folder reference.
    if (!bundleName || [bundleName isEmpty])
        return [bundle pathForResource:fileName ofType:fileType inDirectory:subpath];
    
    return [[[[bundle resourcePath] stringByAppendingPathComponent:
              [NSString stringWithFormat:@"%@.bundle", bundleName]]
             stringByAppendingPathComponent:subpath]
            stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.%@", fileName, fileType]];
}

@end
