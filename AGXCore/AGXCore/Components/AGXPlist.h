//
//  AGXPlist.h
//  AGXCore
//
//  Created by Char Aznable on 16/4/27.
//  Copyright © 2016年 AI-CUC-EC. All rights reserved.
//

#ifndef AGXCore_AGXPlist_h
#define AGXCore_AGXPlist_h

#import <Foundation/Foundation.h>

@interface AGXPlist : NSObject
+ (id)objectFromPlistData:(NSData *)plistData;
+ (id)objectFromPlistString:(NSString *)plistString;
+ (NSData *)plistDataFromObject:(id)object;
+ (NSString *)plistStringFromObject:(id)object;
@end

#endif /* AGXCore_AGXPlist_h */
