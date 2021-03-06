//
//  AGXLocalization.h
//  AGXCore
//
//  Created by Char Aznable on 2017/12/22.
//  Copyright © 2017 github.com/CharLemAznable. All rights reserved.
//

#ifndef AGXCore_AGXLocalization_h
#define AGXCore_AGXLocalization_h

#import <Foundation/Foundation.h>

#define AGXLocalizedStringDefault(key, tbl, val)        \
AGXLocalization.bundleNameAs(@"AGXLocalization")        \
.tableNameAs((tbl)).localizedStringDefault((key), (val))

#define AGXLocalizedString(key, tbl)                    \
AGXLocalizedStringDefault((key), (tbl), nil)

@interface AGXLocalization : NSObject
+ (NSString *)defaultLanguage;
+ (void)setDefaultLanguage:(NSString *)defaultLanguage;

+ (AGXLocalization *(^)(NSString *))subpathAs;
+ (AGXLocalization *(^)(NSString *))bundleNameAs;
+ (AGXLocalization *(^)(NSString *))tableNameAs;
+ (AGXLocalization *(^)(NSString *))languageAs;
+ (NSArray *)supportedLanguages;

+ (NSString *(^)(NSString *))localizedString;
+ (NSString *(^)(NSString *, NSString *))localizedStringDefault;

- (AGXLocalization *(^)(NSString *))subpathAs;
- (AGXLocalization *(^)(NSString *))bundleNameAs;
- (AGXLocalization *(^)(NSString *))tableNameAs;
- (AGXLocalization *(^)(NSString *))languageAs;
- (NSArray *)supportedLanguages;

- (NSString *(^)(NSString *))localizedString;
- (NSString *(^)(NSString *, NSString *))localizedStringDefault;
@end

#endif /* AGXCore_AGXLocalization_h */
