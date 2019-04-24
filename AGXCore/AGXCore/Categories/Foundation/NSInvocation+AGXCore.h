//
//  NSInvocation+AGXCore.h
//  AGXCore
//
//  Created by Char Aznable on 2019/4/18.
//  Copyright © 2019 github.com/CharLemAznable. All rights reserved.
//

#ifndef AGXCore_NSInvocation_AGXCore_h
#define AGXCore_NSInvocation_AGXCore_h

#import "AGXCategory.h"

@category_interface(NSInvocation, AGXCore)
+ (NSInvocation *)invocationWithTarget:(id)target action:(SEL)action;
@end

#endif /* AGXCore_NSInvocation_AGXCore_h */
