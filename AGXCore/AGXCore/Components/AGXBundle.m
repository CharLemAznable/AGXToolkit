//
//  AGXBundle.m
//  AGXCore
//
//  Created by Char Aznable on 16/2/4.
//  Copyright © 2016年 AI-CUC-EC. All rights reserved.
//

#import "AGXBundle.h"
#import "AGXArc.h"
#import "NSString+AGXCore.h"

@implementation AGXBundle {
    NSString *_bundleName;
    NSString *_subpath;
}

- (AGX_INSTANCETYPE)init {
    @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                   reason:@"Please use initializer: +appBundle/+bundleNamed(...)"
                                 userInfo:nil];
    return nil;
}

- (AGX_INSTANCETYPE)initWithName:(NSString *)bundleName {
    if (AGX_EXPECT_T(self = [super init])) _bundleName = [bundleName copy];
    return self;
}

- (void)dealloc {
    AGX_RELEASE(_bundleName);
    AGX_RELEASE(_subpath);
    AGX_SUPER_DEALLOC;
}

+ (AGXBundle *)appBundle {
    return self.bundleNamed(nil);
}

+ (AGXBundle *(^)(NSString *))bundleNamed {
    return AGX_BLOCK_AUTORELEASE(^AGXBundle *(NSString *bundleName) {
        return AGX_AUTORELEASE([[AGXBundle alloc] initWithName:bundleName]);
    });
}

- (AGXBundle *(^)(NSString *))subpath {
    return AGX_BLOCK_AUTORELEASE(^AGXBundle *(NSString *subpath) {
        NSString *temp = [subpath copy];
        AGX_RELEASE(_subpath);
        _subpath = temp;
        return self;
    });
}

- (NSString *(^)(NSString *, NSString *))filePath {
    return AGX_BLOCK_AUTORELEASE(^NSString *(NSString *fileName, NSString *fileExtendName) {
        return bundleFilePath(fileName, fileExtendName, _bundleName, _subpath);
    });
}

- (NSURL *(^)(NSString *, NSString *))fileURL {
    return AGX_BLOCK_AUTORELEASE(^NSURL *(NSString *fileName, NSString *fileExtendName) {
        return [NSURL fileURLWithPath:bundleFilePath(fileName, fileExtendName, _bundleName, _subpath)];
    });
}

- (UIImage *(^)(NSString *))imageNamed {
    return AGX_BLOCK_AUTORELEASE(^UIImage *(NSString *imageName) {
        return [UIImage imageWithContentsOfFile:bundleFilePath(imageName, @"png", _bundleName, _subpath)];
    });
}

#pragma mark - private functions -

NSString *bundleFilePath(NSString *fileName, NSString *fileExtendName, NSString *bundleName, NSString *subpath) {
    NSBundle *bundle = [NSBundle bundleForClass:[AGXBundle class]];
    // if bundleName is nil or empty, search file in mainBundle, subpath defines sub folder reference.
    if (!bundleName || [bundleName isEmpty])
        return [bundle pathForResource:fileName ofType:fileExtendName inDirectory:subpath];

    return [[[[[[bundle resourcePath] stringByAppendingPathComponent:
                bundleName] stringByAppendingPathExtension:@"bundle"]
              stringByAppendingPathComponent:subpath] stringByAppendingPathComponent:
             fileName] stringByAppendingPathExtension:fileExtendName];
}

+ (NSString *)appIdentifier {
    return [[NSBundle bundleForClass:[AGXBundle class]].infoDictionary
            objectForKey:@"CFBundleIdentifier"];
}

+ (NSString *)appVersion {
    return [[NSBundle bundleForClass:[AGXBundle class]].infoDictionary
            objectForKey:@"CFBundleShortVersionString"];
}

+ (BOOL)viewControllerBasedStatusBarAppearance {
    id setting = [[NSBundle bundleForClass:[AGXBundle class]].infoDictionary
                  objectForKey:@"UIViewControllerBasedStatusBarAppearance"];
    return setting ? [setting boolValue] : YES;
}

@end
