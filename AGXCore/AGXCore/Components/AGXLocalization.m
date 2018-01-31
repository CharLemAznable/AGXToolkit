//
//  AGXLocalization.m
//  AGXCore
//
//  Created by Char Aznable on 2017/12/22.
//  Copyright © 2017年 AI-CUC-EC. All rights reserved.
//

#import "AGXLocalization.h"
#import "AGXArc.h"
#import "AGXBundle.h"
#import "NSObject+AGXCore.h"
#import "NSString+AGXCore.h"

@interface AGXLocalization ()
@property (nonatomic, AGX_STRONG) NSString *bundleName;
@property (nonatomic, AGX_STRONG) NSString *tableName;
@property (nonatomic, AGX_STRONG) NSString *language;
@end

@implementation AGXLocalization {
    NSArray *_supportedLanguages;
}

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
    AGX_RELEASE(_bundleName);
    AGX_RELEASE(_tableName);
    AGX_RELEASE(_language);
    AGX_RELEASE(_supportedLanguages);
    AGX_SUPER_DEALLOC;
}

#define DefaultLocalization(type, name) \
+ (type)name { return AGXLocalization.instance.name; }

DefaultLocalization(AGXLocalization *(^)(NSString *), bundleNameAs)
DefaultLocalization(AGXLocalization *(^)(NSString *), tableNameAs)
DefaultLocalization(AGXLocalization *(^)(NSString *), languageAs)
DefaultLocalization(NSString *(^)(NSString *), localizedString)
DefaultLocalization(NSString *(^)(NSString *, NSString *), localizedStringDefault)
DefaultLocalization(NSArray *, supportedLanguages)

#undef DefaultLocalization

- (AGXLocalization *(^)(NSString *))bundleNameAs {
    return AGX_BLOCK_AUTORELEASE(^AGXLocalization *(NSString *bundleName) {
        self.bundleName = bundleName;
        return self;
    });
}

- (AGXLocalization *(^)(NSString *))tableNameAs {
    return AGX_BLOCK_AUTORELEASE(^AGXLocalization *(NSString *tableName) {
        self.tableName = tableName;
        return self;
    });
}

- (AGXLocalization *(^)(NSString *))languageAs {
    return AGX_BLOCK_AUTORELEASE(^AGXLocalization *(NSString *language) {
        self.language = language;
        return self;
    });
}

- (NSString *(^)(NSString *))localizedString {
    return AGX_BLOCK_AUTORELEASE(^NSString *(NSString *key) {
        return self.localizedStringDefault(key, nil);
    });
}

- (NSString *(^)(NSString *, NSString *))localizedStringDefault {
    return AGX_BLOCK_AUTORELEASE(^NSString *(NSString *key, NSString *value) {
        NSString *language = AGXIsNotEmpty(_language) ? _language
        : (AGXIsNotEmpty(AGXLocalization.defaultLanguage) ? AGXLocalization.defaultLanguage : nil);
        return [AGXBundle.bundleNameAs(_bundleName).subpathAs
                ([language stringByAppendingPathExtension:@"lproj"]).bundle
                localizedStringForKey:key value:value table:_tableName]?:value?:key;
    });
}

- (NSArray *)supportedLanguages {
    if (!_supportedLanguages) {
        @synchronized (self) {
            if (!_supportedLanguages) {
                NSMutableArray *languages = NSMutableArray.instance;
                [[AGXBundle.bundleNameAs(_bundleName).bundle
                  pathsForResourcesOfType:@"lproj" inDirectory:@""]
                 enumerateObjectsUsingBlock:^(NSString *path, NSUInteger idx, BOOL *stop) {
                     [languages addObject:path.stringByDeletingPathExtension.lastPathComponent];
                 }];
                _supportedLanguages = [languages copy];
            }
        }
    }
    return _supportedLanguages;
}

@end
