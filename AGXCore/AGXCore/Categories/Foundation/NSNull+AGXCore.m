//
//  NSNull+AGXCore.m
//  AGXCore
//
//  Created by Char Aznable on 2016/2/4.
//  Copyright © 2016 github.com/CharLemAznable. All rights reserved.
//

#import "NSNull+AGXCore.h"

@category_implementation(NSNull, AGXCore)

+ (BOOL)isNull:(id)obj {
    return nil == obj || [obj isEqual:self.null];
}

+ (BOOL)isNotNull:(id)obj {
    return nil != obj && ![obj isEqual:self.null];
}

@end
