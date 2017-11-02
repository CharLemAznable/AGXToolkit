//
//  AGXBundle.m
//  AGXCore
//
//  Created by Char Aznable on 16/2/4.
//  Copyright © 2016年 AI-CUC-EC. All rights reserved.
//

#import "AGXBundle.h"
#import "AGXArc.h"
#import "NSObject+AGXCore.h"
#import "NSString+AGXCore.h"

@interface AGXBundle ()
@property (nonatomic, AGX_STRONG) NSString *bundleName;
@property (nonatomic, AGX_STRONG) NSString *subpath;
@end

@implementation AGXBundle

- (void)dealloc {
    AGX_RELEASE(_bundleName);
    AGX_RELEASE(_subpath);
    AGX_SUPER_DEALLOC;
}

+ (AGX_INSTANCETYPE)appBundle {
    return self.instance;
}

#define DefaultAppBundle(type, name) \
+ (type)name { return AGXBundle.appBundle.name; }

DefaultAppBundle(AGXBundle *(^)(NSString *), bundleNameAs)
DefaultAppBundle(AGXBundle *(^)(NSString *), subpathAs)
DefaultAppBundle(NSString *(^)(NSString *), filePath)
DefaultAppBundle(NSURL *(^)(NSString *), fileURL)
DefaultAppBundle(id<NSCoding> (^)(NSString *), contentWithFile)
DefaultAppBundle(NSData *(^)(NSString *), dataWithFile)
DefaultAppBundle(NSString *(^)(NSString *, NSStringEncoding), stringWithFile)
DefaultAppBundle(NSArray *(^)(NSString *), arrayWithFile)
DefaultAppBundle(NSDictionary *(^)(NSString *), dictionaryWithFile)
DefaultAppBundle(NSSet *(^)(NSString *), setWithFile)
DefaultAppBundle(UIImage *(^)(NSString *), imageWithFile)

#undef DefaultAppBundle

- (AGXBundle *(^)(NSString *))bundleNameAs {
    return AGX_BLOCK_AUTORELEASE(^AGXBundle *(NSString *bundleName) {
        self.bundleName = bundleName;
        return self;
    });
}

- (AGXBundle *(^)(NSString *))subpathAs {
    return AGX_BLOCK_AUTORELEASE(^AGXBundle *(NSString *subpath) {
        self.subpath = subpath;
        return self;
    });
}

- (NSString *(^)(NSString *))filePath {
    return AGX_BLOCK_AUTORELEASE(^NSString *(NSString *fileName) {
        NSString *filePath = [NSBundle bundleForClass:[AGXBundle class]].resourcePath;
        // if bundleName is nil or empty, search file in mainBundle, subpath defines sub folder reference.
        if ([_bundleName isNotEmpty]) filePath = [[filePath stringByAppendingPathComponent:_bundleName]
                                                  stringByAppendingPathExtension:@"bundle"];
        return [[filePath stringByAppendingPathComponent:_subpath] stringByAppendingPathComponent:fileName];
    });
}

- (NSURL *(^)(NSString *))fileURL {
    return AGX_BLOCK_AUTORELEASE(^NSURL *(NSString *fileName) {
        return [NSURL fileURLWithPath:self.filePath(fileName)];
    });
}

- (id<NSCoding> (^)(NSString *))contentWithFile {
    return AGX_BLOCK_AUTORELEASE(^id<NSCoding> (NSString *fileName) {
        NSData *data = self.dataWithFile(fileName);
        return data ? [NSKeyedUnarchiver unarchiveObjectWithData:data] : nil;
    });
}

- (NSData *(^)(NSString *))dataWithFile {
    return AGX_BLOCK_AUTORELEASE(^NSData *(NSString *fileName) {
        return [NSData dataWithContentsOfFile:self.filePath(fileName)];
    });
}

- (NSString *(^)(NSString *, NSStringEncoding))stringWithFile {
    return AGX_BLOCK_AUTORELEASE(^NSString *(NSString *fileName, NSStringEncoding encoding) {
        return [NSString stringWithContentsOfFile:self.filePath(fileName) encoding:encoding error:nil];
    });
}

- (NSArray *(^)(NSString *))arrayWithFile {
    return AGX_BLOCK_AUTORELEASE(^NSArray *(NSString *fileName) {
        return [NSArray arrayWithContentsOfFile:self.filePath
                ([fileName stringByAppendingPathExtension:@"plist"])];
    });
}

- (NSDictionary *(^)(NSString *))dictionaryWithFile {
    return AGX_BLOCK_AUTORELEASE(^NSDictionary *(NSString *fileName) {
        return [NSDictionary dictionaryWithContentsOfFile:self.filePath
                ([fileName stringByAppendingPathExtension:@"plist"])];
    });
}

- (NSSet *(^)(NSString *))setWithFile {
    return AGX_BLOCK_AUTORELEASE(^NSSet *(NSString *fileName) {
        return [NSSet setWithArray:[NSArray arrayWithContentsOfFile:self.filePath
                                    ([fileName stringByAppendingPathExtension:@"plist"])]];
    });
}

- (UIImage *(^)(NSString *))imageWithFile {
    return AGX_BLOCK_AUTORELEASE(^UIImage *(NSString *fileName) {
        return [UIImage imageWithContentsOfFile:self.filePath
                ([fileName stringByAppendingPathExtension:@"png"])];
    });
}

+ (NSDictionary *)appInfoDictionary {
    return [NSBundle bundleForClass:[AGXBundle class]].infoDictionary;
}

+ (NSString *)appIdentifier {
    return self.appInfoDictionary[@"CFBundleIdentifier"];
}

+ (NSString *)appVersion {
    return self.appInfoDictionary[@"CFBundleShortVersionString"];
}

+ (NSString *)appBuildNumber {
    return self.appInfoDictionary[@"CFBundleVersion"];
}

+ (NSString *)appBundleName {
    return self.appInfoDictionary[@"CFBundleName"]?:@"Unknown";
}

+ (BOOL)viewControllerBasedStatusBarAppearance {
    id setting = [self.appInfoDictionary objectForKey:@"UIViewControllerBasedStatusBarAppearance"];
    return setting ? [setting boolValue] : YES;
}

@end
