//
//  NSExpression+AGXCore.m
//  AGXCore
//
//  Created by Char Aznable on 16/2/4.
//  Copyright © 2016年 AI-CUC-EC. All rights reserved.
//

#import "NSExpression+AGXCore.h"
#import "NSString+AGXCore.h"

@category_implementation(NSExpression, AGXCore)

+ (NSArray *)keywordsArrayInExpressionFormat {
    return @[@"AND", @"OR", @"IN", @"NOT", @"ALL", @"ANY", @"SOME", @"NONE", @"LIKE", @"CASEINSENSITIVE", @"CI", @"MATCHES", @"CONTAINS", @"BEGINSWITH", @"ENDSWITH", @"BETWEEN", @"NULL", @"NIL", @"SELF", @"TRUE", @"YES", @"FALSE", @"NO", @"FIRST", @"LAST", @"SIZE", @"ANYKEY", @"SUBQUERY", @"CAST", @"TRUEPREDICATE", @"FALSEPREDICATE"];
}

NSString *const agxParametricPrefix   = @"${";
NSString *const agxParametricSuffix   = @"}";
NSString *const agxKeyPathPlaceholder = @"%K";

+ (AGX_INSTANCETYPE)expressionWithParametricFormat:(NSString *)parametricFormat {
    NSMutableString *expressionFormat = [NSMutableString string];
    NSMutableArray *arguments = [NSMutableArray array];
    NSUInteger start = 0, end = [parametricFormat indexOfString:agxParametricPrefix fromIndex:start];
    while (end != NSNotFound) {
        [expressionFormat appendString:[parametricFormat substringWithRange:NSMakeRange(start, end)]];
        start += end + 2;
        end = [parametricFormat indexOfString:agxParametricSuffix fromIndex:start];
        if AGX_EXPECT_F(end == NSNotFound) break;
        [arguments addObject:[parametricFormat substringWithRange:NSMakeRange(start, end)]];
        [expressionFormat appendString:agxKeyPathPlaceholder];
        start += end + 1;
        end = [parametricFormat indexOfString:agxParametricPrefix fromIndex:start];
    }
    if AGX_EXPECT_T(start < [parametricFormat length])
        [expressionFormat appendString:[parametricFormat substringFromIndex:start]];

    return [self expressionWithFormat:expressionFormat argumentArray:arguments];
}

@end
