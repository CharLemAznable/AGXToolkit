//
//  AGXColorSet.m
//  AGXCore
//
//  Created by Char Aznable on 16/2/18.
//  Copyright © 2016年 AI-CUC-EC. All rights reserved.
//

#import "AGXColorSet.h"
#import "AGXArc.h"
#import "AGXBundle.h"
#import "NSDictionary+AGXCore.h"
#import "UIColor+AGXCore.h"

@interface AGXColorSet ()
@property (nonatomic, AGX_STRONG) NSString *fileName;
@property (nonatomic, AGX_STRONG) NSString *subpath;
@property (nonatomic, AGX_STRONG) AGXDirectory *directory;
@property (nonatomic, AGX_STRONG) NSString *bundleName;
@end

@implementation AGXColorSet {
    NSDictionary *_colors;
}

- (AGX_INSTANCETYPE)initWithDictionary:(NSDictionary *)colors {
    if AGX_EXPECT_T(self = [super init]) {
        _colors = AGX_RETAIN(buildColorDictionary(colors));
    }
    return self;
}

- (void)dealloc {
    AGX_RELEASE(_fileName);
    AGX_RELEASE(_subpath);
    AGX_RELEASE(_directory);
    AGX_RELEASE(_bundleName);
    AGX_RELEASE(_colors);
    AGX_SUPER_DEALLOC;
}

+ (AGXColorSet *(^)(NSDictionary *))colorsAs {
    return AGX_BLOCK_AUTORELEASE(^AGXColorSet *(NSDictionary *colors) {
        return AGX_AUTORELEASE([[AGXColorSet alloc] initWithDictionary:colors]);
    });
}

#define DefaultInstance(type, name) \
+ (AGXColorSet *(^)(type *))name { return AGXColorSet.instance.name; }

DefaultInstance(NSString, fileNameAs)
DefaultInstance(NSString, subpathAs)
DefaultInstance(AGXDirectory, directoryAs)
DefaultInstance(NSString, bundleNameAs)

#undef DefaultInstance

- (AGXColorSet *(^)(NSString *))fileNameAs {
    return AGX_BLOCK_AUTORELEASE(^AGXColorSet *(NSString *fileName) {
        self.fileName = fileName;
        return self.reload;
    });
}

- (AGXColorSet *(^)(NSString *))subpathAs {
    return AGX_BLOCK_AUTORELEASE(^AGXColorSet *(NSString *subpath) {
        self.subpath = subpath;
        return self.reload;
    });
}

- (AGXColorSet *(^)(AGXDirectory *))directoryAs {
    return AGX_BLOCK_AUTORELEASE(^AGXColorSet *(AGXDirectory *directory) {
        self.directory = directory;
        return self.reload;
    });
}

- (AGXColorSet *(^)(NSString *))bundleNameAs {
    return AGX_BLOCK_AUTORELEASE(^AGXColorSet *(NSString *bundleName) {
        self.bundleName = bundleName;
        return self.reload;
    });
}

- (AGXColorSet *)reload {
    if (!_fileName) return self;
    AGX_RELEASE(_colors);
    AGXDirectory *directory = _directory ?: AGXDirectory.document;
    _colors = AGX_RETAIN(buildColorDictionary
                         (directory.subpathAs(_subpath).dictionaryWithFile(_fileName)
                          ?: AGXBundle.bundleNameAs(_bundleName).subpathAs(_subpath).dictionaryWithFile(_fileName)));
    return self;
}

- (UIColor *)colorForKey:(NSString *)key {
    return [_colors objectForKey:key];
}

- (UIColor *)objectForKeyedSubscript:(NSString *)key {
    return [_colors objectForKey:key];
}

- (UIColor *(^)(NSString *))colorForKey {
    return AGX_BLOCK_AUTORELEASE(^UIColor *(NSString *key) {
        return [_colors objectForKey:key];
    });
}

#pragma mark - implementation functions -

AGX_STATIC NSDictionary *buildColorDictionary(NSDictionary *srcDictionary) {
    if AGX_EXPECT_F(!srcDictionary) return nil;
    NSMutableDictionary *dstDictionary = NSMutableDictionary.instance;
    [srcDictionary enumerateKeysAndObjectsUsingBlock:
     ^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
         if ([obj isKindOfClass:[UIColor class]]) {
             [dstDictionary setObject:obj forKey:key];
         } else if ([obj isKindOfClass:[NSString class]]) {
             [dstDictionary setObject:[UIColor colorWithRGBAHexString:obj] forKey:key];
         }
     }];
    return AGX_AUTORELEASE([dstDictionary copy]);
}

@end

NSString *AGXColorSetBundleName = nil;
