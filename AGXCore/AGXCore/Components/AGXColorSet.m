//
//  AGXColorSet.m
//  AGXCore
//
//  Created by Char Aznable on 16/2/18.
//  Copyright © 2016年 AI-CUC-EC. All rights reserved.
//

#import "AGXColorSet.h"
#import "NSDictionary+AGXCore.h"
#import "UIColor+AGXCore.h"
#import "AGXArc.h"

@interface AGXColorSet () {
    NSDictionary *_colors;
}
@end

@implementation AGXColorSet

- (AGX_INSTANCETYPE)init {
    return [self initWithDictionary:nil];
}

- (void)dealloc {
    AGX_RELEASE(_colors);
    AGX_SUPER_DEALLOC;
}

#pragma mark - Conveniences -

+ (AGXColorSet *)colorSetWithDictionary:(NSDictionary *)dictionary {
    return AGX_AUTORELEASE([[self alloc] initWithDictionary:dictionary]);
}

+ (AGXColorSet *)colorSetWithContentsOfUserFile:(NSString *)fileName {
    return [self colorSetWithContentsOfUserFile:fileName subpath:nil];
}

+ (AGXColorSet *)colorSetWithContentsOfUserFile:(NSString *)fileName subpath:(NSString *)subpath {
    if ([AGXDirectory fileExists:fileName inDirectory:AGXDocument subpath:subpath])
        return [self colorSetWithContentsOfUserFile:fileName inDirectory:AGXDocument subpath:subpath];
    return [self colorSetWithContentsOfUserFile:fileName bundle:nil subpath:subpath];
}

+ (AGXColorSet *)colorSetWithContentsOfUserFile:(NSString *)fileName inDirectory:(AGXDirectoryType)directory {
    return [self colorSetWithContentsOfUserFile:fileName inDirectory:directory subpath:nil];
}

+ (AGXColorSet *)colorSetWithContentsOfUserFile:(NSString *)fileName inDirectory:(AGXDirectoryType)directory subpath:(NSString *)subpath {
    return [self colorSetWithDictionary:
            [NSDictionary dictionaryWithContentsOfUserFile:fileName inDirectory:directory subpath:subpath]];
}

+ (AGXColorSet *)colorSetWithContentsOfUserFile:(NSString *)fileName bundle:(NSString *)bundleName {
    return [self colorSetWithContentsOfUserFile:fileName bundle:bundleName subpath:nil];
}

+ (AGXColorSet *)colorSetWithContentsOfUserFile:(NSString *)fileName bundle:(NSString *)bundleName subpath:(NSString *)subpath {
    return [self colorSetWithDictionary:
            [NSDictionary dictionaryWithContentsOfUserFile:fileName bundle:bundleName subpath:subpath]];
}

#pragma mark - initializations -

- (AGX_INSTANCETYPE)initWithDictionary:(NSDictionary *)dictionary {
    if (AGX_EXPECT_T(self = [super init])) {
        _colors = AGX_RETAIN(buildColorDictionary(dictionary));
    }
    return self;
}

- (AGX_INSTANCETYPE)initWithContentsOfUserFile:(NSString *)fileName {
    return [self initWithContentsOfUserFile:fileName subpath:nil];
}

- (AGX_INSTANCETYPE)initWithContentsOfUserFile:(NSString *)fileName subpath:(NSString *)subpath {
    if ([AGXDirectory fileExists:fileName inDirectory:AGXDocument subpath:subpath])
        return [self initWithContentsOfUserFile:fileName inDirectory:AGXDocument subpath:subpath];
    return [self initWithContentsOfUserFile:fileName bundle:nil subpath:subpath];
}

- (AGX_INSTANCETYPE)initWithContentsOfUserFile:(NSString *)fileName inDirectory:(AGXDirectoryType)directory {
    return [self initWithContentsOfUserFile:fileName inDirectory:directory subpath:nil];
}

- (AGX_INSTANCETYPE)initWithContentsOfUserFile:(NSString *)fileName inDirectory:(AGXDirectoryType)directory subpath:(NSString *)subpath {
    return [self initWithDictionary:
            [NSDictionary dictionaryWithContentsOfUserFile:fileName inDirectory:directory subpath:subpath]];
}

- (AGX_INSTANCETYPE)initWithContentsOfUserFile:(NSString *)fileName bundle:(NSString *)bundleName {
    return [self initWithContentsOfUserFile:fileName bundle:bundleName subpath:nil];
}

- (AGX_INSTANCETYPE)initWithContentsOfUserFile:(NSString *)fileName bundle:(NSString *)bundleName subpath:(NSString *)subpath {
    return [self initWithDictionary:
            [NSDictionary dictionaryWithContentsOfUserFile:fileName bundle:bundleName subpath:subpath]];
}

#pragma mark - reloaders -

- (void)reloadWithDictionary:(NSDictionary *)dictionary {
    AGX_RELEASE(_colors);
    _colors = AGX_RETAIN(buildColorDictionary(dictionary));
}

- (void)reloadWithContentsOfUserFile:(NSString *)fileName {
    [self reloadWithContentsOfUserFile:fileName subpath:nil];
}

- (void)reloadWithContentsOfUserFile:(NSString *)fileName subpath:(NSString *)subpath {
    if ([AGXDirectory fileExists:fileName inDirectory:AGXDocument subpath:subpath])
        [self reloadWithContentsOfUserFile:fileName inDirectory:AGXDocument subpath:subpath];
    [self reloadWithContentsOfUserFile:fileName bundle:nil subpath:subpath];
}

- (void)reloadWithContentsOfUserFile:(NSString *)fileName inDirectory:(AGXDirectoryType)directory {
    [self reloadWithContentsOfUserFile:fileName inDirectory:directory subpath:nil];
}

- (void)reloadWithContentsOfUserFile:(NSString *)fileName inDirectory:(AGXDirectoryType)directory subpath:(NSString *)subpath {
    [self reloadWithDictionary:
     [NSDictionary dictionaryWithContentsOfUserFile:fileName inDirectory:directory subpath:subpath]];
}

- (void)reloadWithContentsOfUserFile:(NSString *)fileName bundle:(NSString *)bundleName {
    [self reloadWithContentsOfUserFile:fileName bundle:bundleName subpath:nil];
}

- (void)reloadWithContentsOfUserFile:(NSString *)fileName bundle:(NSString *)bundleName subpath:(NSString *)subpath {
    [self reloadWithDictionary:
     [NSDictionary dictionaryWithContentsOfUserFile:fileName bundle:bundleName subpath:subpath]];
}

#pragma mark -

- (UIColor *)colorForKey:(NSString *)key {
    return [_colors objectForKey:key];
}

- (UIColor *)objectForKeyedSubscript:(NSString *)key {
    return [_colors objectForKey:key];
}

#pragma mark - implementation functions -

AGX_STATIC NSDictionary *buildColorDictionary(NSDictionary *srcDictionary) {
    if (AGX_EXPECT_F(!srcDictionary)) return nil;
    NSMutableDictionary *dstDictionary = AGX_AUTORELEASE([[NSMutableDictionary alloc] init]);
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
