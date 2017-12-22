//
//  AGXLocalization.h
//  AGXCore
//
//  Created by Char Aznable on 2017/12/22.
//  Copyright © 2017年 AI-CUC-EC. All rights reserved.
//

#ifndef AGXCore_AGXLocalization_h
#define AGXCore_AGXLocalization_h

#import <Foundation/Foundation.h>
#import "AGXC.h"

@interface AGXLocalization : NSObject
+ (NSString *)defaultLanguage;
+ (void)setDefaultLanguage:(NSString *)defaultLanguage;

+ (AGXLocalization *(^)(NSString *))bundleNameAs;
+ (AGXLocalization *(^)(NSString *))tableNameAs;
+ (AGXLocalization *(^)(NSString *))languageAs;
+ (NSArray *)supportedLanguages;

+ (NSString *(^)(NSString *))localizedString;
+ (NSString *(^)(NSString *, NSString *))localizedStringDefault;

- (AGXLocalization *(^)(NSString *))bundleNameAs;
- (AGXLocalization *(^)(NSString *))tableNameAs;
- (AGXLocalization *(^)(NSString *))languageAs;
- (NSArray *)supportedLanguages;

- (NSString *(^)(NSString *))localizedString;
- (NSString *(^)(NSString *, NSString *))localizedStringDefault;
@end

#endif /* AGXCore_AGXLocalization_h */
