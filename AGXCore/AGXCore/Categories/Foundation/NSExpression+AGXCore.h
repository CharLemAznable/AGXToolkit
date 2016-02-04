//
//  NSExpression+AGXCore.h
//  AGXCore
//
//  Created by Char Aznable on 16/2/4.
//  Copyright © 2016年 AI-CUC-EC. All rights reserved.
//

#ifndef AGXCore_NSExpression_AGXCore_h
#define AGXCore_NSExpression_AGXCore_h

#import <Foundation/Foundation.h>
#import "AGXCategory.h"

@category_interface(NSExpression, AGXCore)
+ (NSArray *)keywordsArrayInExpressionFormat;
+ (NSExpression *)expressionWithParametricFormat:(NSString *)parametricFormat;
@end

#endif /* AGXCore_NSExpression_AGXCore_h */
