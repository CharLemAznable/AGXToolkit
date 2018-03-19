//
//  AGXLocalization.m
//  AGXCore
//
//  Created by Char Aznable on 2017/12/22.
//  Copyright © 2017年 AI-CUC-EC. All rights reserved.
//

#import "AGXLocalization.h"
#import "AGXArc.h"
#import "AGXResources.h"
#import "NSObject+AGXCore.h"
#import "NSString+AGXCore.h"

@interface AGXLocalization ()
@property (nonatomic, AGX_STRONG) NSString *subpath;
@property (nonatomic, AGX_STRONG) NSString *bundleName;
@property (nonatomic, AGX_STRONG) NSString *tableName;
@property (nonatomic, AGX_STRONG) NSString *language;
@end

@implementation AGXLocalization

AGX_STATIC NSString *AGXLocalizationDefaultLanguage = nil;

+ (NSString *)defaultLanguage {
    return AGXLocalizationDefaultLanguage;
}

+ (void)setDefaultLanguage:(NSString *)defaultLanguage {
    NSString *temp = [defaultLanguage copy];
    AGX_RELEASE(AGXLocalizationDefaultLanguage);
    AGXLocalizationDefaultLanguage = temp;
}

- (void)dealloc {
    AGX_RELEASE(_subpath);
    AGX_RELEASE(_bundleName);
    AGX_RELEASE(_tableName);
    AGX_RELEASE(_language);
    AGX_SUPER_DEALLOC;
}

#define DefaultLocalization(type, name) \
+ (type)name { return AGXLocalization.instance.name; }

DefaultLocalization(AGXLocalization *(^)(NSString *), subpathAs)
DefaultLocalization(AGXLocalization *(^)(NSString *), bundleNameAs)
DefaultLocalization(AGXLocalization *(^)(NSString *), tableNameAs)
DefaultLocalization(AGXLocalization *(^)(NSString *), languageAs)
DefaultLocalization(NSString *(^)(NSString *), localizedString)
DefaultLocalization(NSString *(^)(NSString *, NSString *), localizedStringDefault)
DefaultLocalization(NSArray *, supportedLanguages)

#undef DefaultLocalization

#define LocalizationSettingAs(name)             \
- (AGXLocalization *(^)(NSString *))name##As {  \
    return AGX_BLOCK_AUTORELEASE                \
    (^AGXLocalization *(NSString *name)         \
     { self.name = name; return self; });       \
}

LocalizationSettingAs(subpath)
LocalizationSettingAs(bundleName)
LocalizationSettingAs(tableName)
LocalizationSettingAs(language)

#undef LocalizationSettingAs

- (NSString *(^)(NSString *))localizedString {
    return AGX_BLOCK_AUTORELEASE(^NSString *(NSString *key) {
        return self.localizedStringDefault(key, nil);
    });
}

- (NSString *(^)(NSString *, NSString *))localizedStringDefault {
    return AGX_BLOCK_AUTORELEASE(^NSString *(NSString *key, NSString *value) {
        NSString *language = AGXIsNotEmpty(_language) ? _language
        : (AGXIsNotEmpty(AGXLocalization.defaultLanguage) ? AGXLocalization.defaultLanguage : nil);
        AGXResources *resources = AGXResources.pattern.subpathAppend(_subpath)
        .subpathAppendBundleNamed(_bundleName).subpathAppendLprojNamed(language);
        return([resources.applyWithTemporary.bundle localizedStringForKey:key value:value table:_tableName]?:
               [resources.applyWithCaches.bundle localizedStringForKey:key value:value table:_tableName]?:
               [resources.applyWithDocument.bundle localizedStringForKey:key value:value table:_tableName]?:
               [resources.applyWithApplication.bundle localizedStringForKey:key value:value table:_tableName]?:value?:key);
    });
}

- (NSArray *)supportedLanguages {
    NSMutableSet *languages = NSMutableSet.instance;
    NSArray *resourcesArray = @[AGXResources.temporary, AGXResources.caches,
                                AGXResources.document, AGXResources.application];
    for (AGXResources *resources in resourcesArray) {
        [[resources.subpathAppend(_subpath).subpathAppendBundleNamed(_bundleName).bundle
          pathsForResourcesOfType:@"lproj" inDirectory:@""]
         enumerateObjectsUsingBlock:^(NSString *path, NSUInteger idx, BOOL *stop) {
             [languages addObject:path.stringByDeletingPathExtension.lastPathComponent];
         }];
    }
    return languages.allObjects;
}

@end
