//
//  AGXColorSet.h
//  AGXCore
//
//  Created by Char Aznable on 16/2/18.
//  Copyright © 2016年 AI-CUC-EC. All rights reserved.
//

#ifndef AGXCore_AGXColorSet_h
#define AGXCore_AGXColorSet_h

#import <UIKit/UIKit.h>
#import "AGXDirectory.h"
#import "NSObject+AGXCore.h"

@interface AGXColorSet : NSObject

+ (AGXColorSet *)colorSetWithDictionary:(NSDictionary *)dictionary;
+ (AGXColorSet *)colorSetWithContentsOfUserFile:(NSString *)fileName;
+ (AGXColorSet *)colorSetWithContentsOfUserFile:(NSString *)fileName subpath:(NSString *)subpath;
+ (AGXColorSet *)colorSetWithContentsOfUserFile:(NSString *)fileName inDirectory:(AGXDirectoryType)directory;
+ (AGXColorSet *)colorSetWithContentsOfUserFile:(NSString *)fileName inDirectory:(AGXDirectoryType)directory subpath:(NSString *)subpath;
+ (AGXColorSet *)colorSetWithContentsOfUserFile:(NSString *)fileName bundle:(NSString *)bundleName;
+ (AGXColorSet *)colorSetWithContentsOfUserFile:(NSString *)fileName bundle:(NSString *)bundleName subpath:(NSString *)subpath;

- (AGX_INSTANCETYPE)initWithDictionary:(NSDictionary *)dictionary;
- (AGX_INSTANCETYPE)initWithContentsOfUserFile:(NSString *)fileName;
- (AGX_INSTANCETYPE)initWithContentsOfUserFile:(NSString *)fileName subpath:(NSString *)subpath;
- (AGX_INSTANCETYPE)initWithContentsOfUserFile:(NSString *)fileName inDirectory:(AGXDirectoryType)directory;
- (AGX_INSTANCETYPE)initWithContentsOfUserFile:(NSString *)fileName inDirectory:(AGXDirectoryType)directory subpath:(NSString *)subpath;
- (AGX_INSTANCETYPE)initWithContentsOfUserFile:(NSString *)fileName bundle:(NSString *)bundleName;
- (AGX_INSTANCETYPE)initWithContentsOfUserFile:(NSString *)fileName bundle:(NSString *)bundleName subpath:(NSString *)subpath;

- (void)reloadWithDictionary:(NSDictionary *)dictionary;
- (void)reloadWithContentsOfUserFile:(NSString *)fileName;
- (void)reloadWithContentsOfUserFile:(NSString *)fileName subpath:(NSString *)subpath;
- (void)reloadWithContentsOfUserFile:(NSString *)fileName inDirectory:(AGXDirectoryType)directory;
- (void)reloadWithContentsOfUserFile:(NSString *)fileName inDirectory:(AGXDirectoryType)directory subpath:(NSString *)subpath;
- (void)reloadWithContentsOfUserFile:(NSString *)fileName bundle:(NSString *)bundleName;
- (void)reloadWithContentsOfUserFile:(NSString *)fileName bundle:(NSString *)bundleName subpath:(NSString *)subpath;

- (UIColor *)colorForKey:(NSString *)key;
- (UIColor *)objectForKeyedSubscript:(NSString *)key;

@end

AGX_EXTERN NSString *AGXColorSetBundleName;

#define AGXColorSetSynthesize                                                       \
+ (AGXColorSet *)agxColorSet {                                                      \
    static dispatch_once_t once_t;                                                  \
    dispatch_once(&once_t, ^{                                                       \
        if (AGX_EXPECT_F([self propertyForAssociateKey:@"AGXColorSetKey"])) return; \
        [self setProperty:[AGXColorSet colorSetWithContentsOfUserFile:              \
                           [self description] bundle:AGXColorSetBundleName]         \
          forAssociateKey:@"AGXColorSetKey"];                                       \
    });                                                                             \
    return [self propertyForAssociateKey:@"AGXColorSetKey"];                        \
}

#endif /* AGXCore_AGXColorSet_h */
