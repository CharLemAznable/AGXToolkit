//
//  NSAttributedString+AGXCore.h
//  AGXCore
//
//  Created by Char Aznable on 2018/1/18.
//  Copyright © 2018年 AI-CUC-EC. All rights reserved.
//

#ifndef AGXCore_NSAttributedString_AGXCore_h
#define AGXCore_NSAttributedString_AGXCore_h

#import "AGXCategory.h"

@category_interface(NSAttributedString, AGXCore)
+ (AGX_INSTANCETYPE)attrStringWithString:(NSString *)string;
+ (AGX_INSTANCETYPE)attrStringWithString:(NSString *)string attributes:(NSDictionary<NSAttributedStringKey, id> *)attrs;
+ (AGX_INSTANCETYPE)attrStringWithAttributedString:(NSAttributedString *)attrString;
@end

#endif /* AGXCore_NSAttributedString_AGXCore_h */
