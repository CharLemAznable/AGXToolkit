//
//  AGXColorSet.m
//  AGXCore
//
//  Created by Char Aznable on 2016/2/18.
//  Copyright © 2016 github.com/CharLemAznable. All rights reserved.
//

#import "AGXColorSet.h"
#import "AGXArc.h"
#import "NSDictionary+AGXCore.h"
#import "UIColor+AGXCore.h"

@interface AGXColorSet ()
@property (nonatomic, AGX_STRONG) NSString *subpath;
@property (nonatomic, AGX_STRONG) NSString *fileName;
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
    AGX_RELEASE(_subpath);
    AGX_RELEASE(_fileName);
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

DefaultInstance(NSString, subpathAs)
DefaultInstance(NSString, fileNameAs)

#undef DefaultInstance

- (AGXColorSet *(^)(NSString *))subpathAs {
    return AGX_BLOCK_AUTORELEASE(^AGXColorSet *(NSString *subpath) {
        self.subpath = subpath;
        [self reload];
        return self;
    });
}

- (AGXColorSet *(^)(NSString *))fileNameAs {
    return AGX_BLOCK_AUTORELEASE(^AGXColorSet *(NSString *fileName) {
        self.fileName = fileName;
        [self reload];
        return self;
    });
}

- (void)reload {
    if (!_fileName) return;
    AGXResources *resources = AGXResources.pattern.subpathAs(_subpath);
    AGX_RELEASE(_colors);
    _colors = AGX_RETAIN(buildColorDictionary
                         (resources.applyWithTemporary.dictionaryWithPlistNamed(_fileName) ?:
                          resources.applyWithCaches.dictionaryWithPlistNamed(_fileName) ?:
                          resources.applyWithDocument.dictionaryWithPlistNamed(_fileName) ?:
                          resources.applyWithApplication.dictionaryWithPlistNamed(_fileName)));
}

- (UIColor *)colorForKey:(NSString *)key {
    return _colors[key];
}

- (UIColor *)objectForKeyedSubscript:(NSString *)key {
    return _colors[key];
}

- (UIColor *(^)(NSString *))colorForKey {
    return AGX_BLOCK_AUTORELEASE(^UIColor *(NSString *key) {
        return _colors[key];
    });
}

#pragma mark - implementation functions -

AGX_STATIC NSDictionary *buildColorDictionary(NSDictionary *srcDictionary) {
    if AGX_EXPECT_F(!srcDictionary) return nil;
    NSMutableDictionary *dstDictionary = NSMutableDictionary.instance;
    [srcDictionary enumerateKeysAndObjectsUsingBlock:
     ^(id key, id obj, BOOL *stop) {
         if ([obj isKindOfClass:UIColor.class]) {
             dstDictionary[key] = obj;
         } else if ([obj isKindOfClass:NSString.class]) {
             dstDictionary[key] = AGXColor(obj);
         }
     }];
    return AGX_AUTORELEASE([dstDictionary copy]);
}

@end
