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
+ (AGXColorSet *(^)(NSDictionary *))colorsAs;

+ (AGXColorSet *(^)(NSString *))fileNameAs;
+ (AGXColorSet *(^)(NSString *))subpathAs;
+ (AGXColorSet *(^)(AGXDirectory *))directoryAs; // Priority, default AGXDirectory.document
+ (AGXColorSet *(^)(NSString *))bundleNameAs;

- (AGXColorSet *(^)(NSString *))fileNameAs;
- (AGXColorSet *(^)(NSString *))subpathAs;
- (AGXColorSet *(^)(AGXDirectory *))directoryAs;
- (AGXColorSet *(^)(NSString *))bundleNameAs;

- (UIColor *)colorForKey:(NSString *)key;
- (UIColor *)objectForKeyedSubscript:(NSString *)key;
- (UIColor *(^)(NSString *))colorForKey;
@end

AGX_EXTERN NSString *AGXColorSetBundleName;

#define AGXColorSetSynthesize                                       \
+ (AGXColorSet *)agxColorSet {                                      \
    static dispatch_once_t once_t;                                  \
    dispatch_once(&once_t, ^{                                       \
        if AGX_EXPECT_F([self retainPropertyForAssociateKey         \
                         :@"AGXColorSetKey"]) return;               \
        [self setRetainProperty                                     \
         :AGXColorSet.bundleNameAs(AGXColorSetBundleName)           \
         .fileNameAs(self.description)                              \
         forAssociateKey:@"AGXColorSetKey"];                        \
    });                                                             \
    return [self retainPropertyForAssociateKey:@"AGXColorSetKey"];  \
}

#endif /* AGXCore_AGXColorSet_h */
