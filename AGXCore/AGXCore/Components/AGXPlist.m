//
//  AGXPlist.m
//  AGXCore
//
//  Created by Char Aznable on 16/4/27.
//  Copyright © 2016年 AI-CUC-EC. All rights reserved.
//

#import "AGXPlist.h"
#import "NSString+AGXCore.h"

@implementation AGXPlist

+ (id)objectFromPlistData:(NSData *)plistData {
    if (!plistData) return nil;
    return [NSPropertyListSerialization
            propertyListWithData:plistData
            options:NSPropertyListImmutable
            format:NULL error:NULL];
}

+ (id)objectFromPlistString:(NSString *)plistString {
    return [self objectFromPlistData:
            [plistString dataUsingEncoding:NSUTF8StringEncoding]];
}

+ (NSData *)plistDataFromObject:(id)object {
    if (!object) return nil;
    return [NSPropertyListSerialization
            dataWithPropertyList:object
            format:NSPropertyListXMLFormat_v1_0
            options:0 error:NULL];
}

+ (NSString *)plistStringFromObject:(id)object {
    NSData *plistData = [self plistDataFromObject:object];
    if (!plistData || [plistData length] == 0) return nil;
    return [NSString stringWithData:plistData encoding:NSUTF8StringEncoding];
}

@end
