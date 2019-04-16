//
//  NSNull+AGXCore.h
//  AGXCore
//
//  Created by Char Aznable on 2016/2/4.
//  Copyright © 2016 github.com/CharLemAznable. All rights reserved.
//

#ifndef AGXCore_NSNull_AGXCore_h
#define AGXCore_NSNull_AGXCore_h

#import "AGXCategory.h"

@category_interface(NSNull, AGXCore)
+ (BOOL)isNull:(id)obj;
+ (BOOL)isNotNull:(id)obj;
@end

#endif /* AGXCore_NSNull_AGXCore_h */
