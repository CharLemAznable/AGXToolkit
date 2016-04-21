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

NSString *const zParametricPrefix   = @"${";
NSString *const zParametricSuffix   = @"}";
NSString *const zKeyPathPlaceholder = @"%K";

+ (NSExpression *)expressionWithParametricFormat:(NSString *)parametricFormat {
    NSMutableString *expressionFormat = [NSMutableString string];
    NSMutableArray *arguments = [NSMutableArray array];
    NSUInteger start = 0, end = [parametricFormat indexOfString:zParametricPrefix fromIndex:start];
    while (end != NSNotFound) {
        [expressionFormat appendString:[parametricFormat substringWithRange:NSMakeRange(start, end)]];
        start += end + 2;
        end = [parametricFormat indexOfString:zParametricSuffix fromIndex:start];
        if (end == NSNotFound) break;
        [arguments addObject:[parametricFormat substringWithRange:NSMakeRange(start, end)]];
        [expressionFormat appendString:zKeyPathPlaceholder];
        start += end + 1;
        end = [parametricFormat indexOfString:zParametricPrefix fromIndex:start];
    }
    if (start < [parametricFormat length])
        [expressionFormat appendString:[parametricFormat substringFromIndex:start]];

    return [self expressionWithFormat:expressionFormat argumentArray:arguments];
}

@end
