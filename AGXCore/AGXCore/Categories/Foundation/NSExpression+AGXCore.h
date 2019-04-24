//
//  NSExpression+AGXCore.h
//  AGXCore
//
//  Created by Char Aznable on 2016/2/4.
//  Copyright © 2016 github.com/CharLemAznable. All rights reserved.
//

#ifndef AGXCore_NSExpression_AGXCore_h
#define AGXCore_NSExpression_AGXCore_h

#import "AGXCategory.h"

@category_interface(NSExpression, AGXCore)
+ (NSArray *)keywordsArrayInExpressionFormat;
+ (AGX_INSTANCETYPE)expressionWithParametricFormat:(NSString *)parametricFormat;
@end

#endif /* AGXCore_NSExpression_AGXCore_h */
