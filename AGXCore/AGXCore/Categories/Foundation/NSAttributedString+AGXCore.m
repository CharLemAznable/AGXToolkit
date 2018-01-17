//
//  NSAttributedString+AGXCore.m
//  AGXCore
//
//  Created by Char Aznable on 2018/1/18.
//  Copyright © 2018年 AI-CUC-EC. All rights reserved.
//

#import "NSAttributedString+AGXCore.h"
#import "AGXArc.h"

@category_implementation(NSAttributedString, AGXCore)

+ (AGX_INSTANCETYPE)attrStringWithString:(NSString *)string {
    return AGX_AUTORELEASE([[self alloc] initWithString:string]);
}

+ (AGX_INSTANCETYPE)attrStringWithString:(NSString *)string attributes:(NSDictionary<NSAttributedStringKey, id> *)attrs {
    return AGX_AUTORELEASE([[self alloc] initWithString:string attributes:attrs]);
}

+ (AGX_INSTANCETYPE)attrStringWithAttributedString:(NSAttributedString *)attrString {
    return AGX_AUTORELEASE([[self alloc] initWithAttributedString:attrString]);
}

@end
