//
//  AGXColorSet.h
//  AGXCore
//
//  Created by Char Aznable on 2016/2/18.
//  Copyright © 2016年 AI-CUC-EC. All rights reserved.
//

#ifndef AGXCore_AGXColorSet_h
#define AGXCore_AGXColorSet_h

#import <UIKit/UIKit.h>
#import "AGXResources.h"
#import "NSObject+AGXCore.h"

@interface AGXColorSet : NSObject
+ (AGXColorSet *(^)(NSDictionary *))colorsAs;

 // Resources Priority: temporary > caches > document > appBundle
+ (AGXColorSet *(^)(NSString *))subpathAs;
+ (AGXColorSet *(^)(NSString *))fileNameAs;

- (AGXColorSet *(^)(NSString *))subpathAs;
- (AGXColorSet *(^)(NSString *))fileNameAs;

- (void)reload;

- (UIColor *)colorForKey:(NSString *)key;
- (UIColor *)objectForKeyedSubscript:(NSString *)key;
- (UIColor *(^)(NSString *))colorForKey;
@end

#define AGXColorSetSynthesize(SUBPATH)                              \
+ (AGXColorSet *)agxColorSet {                                      \
    agx_once                                                        \
    (if AGX_EXPECT_F([self retainPropertyForAssociateKey:           \
                      @"AGXColorSetKey"]) return;                   \
     [self setRetainProperty:                                       \
      AGXColorSet.subpathAs(SUBPATH).fileNameAs(self.description)   \
             forAssociateKey:@"AGXColorSetKey"];)                   \
    return [self retainPropertyForAssociateKey:@"AGXColorSetKey"];  \
}

#endif /* AGXCore_AGXColorSet_h */
