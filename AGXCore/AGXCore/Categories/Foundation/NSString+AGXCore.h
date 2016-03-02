//
//  NSString+AGXCore.h
//  AGXCore
//
//  Created by Char Aznable on 16/2/4.
//  Copyright © 2016年 AI-CUC-EC. All rights reserved.
//

#ifndef AGXCore_NSString_AGXCore_h
#define AGXCore_NSString_AGXCore_h

#import <UIKit/UIKit.h>
#import "AGXCategory.h"

@category_interface(NSString, AGXCore)
- (BOOL)isEmpty;
- (BOOL)isNotEmpty;

- (NSString *)trim;
- (NSString *)trimToNil;

- (NSString *)capitalized;

- (BOOL)isCaseInsensitiveEqual:(id)object;
- (BOOL)isCaseInsensitiveEqualToString:(NSString *)aString;

- (NSComparisonResult)compareToVersionString:(NSString *)version;

- (NSUInteger)indexOfString:(NSString *)aString;
- (NSUInteger)indexCaseInsensitiveOfString:(NSString *)aString;
- (NSUInteger)indexOfString:(NSString *)aString fromIndex:(NSUInteger)startPos;
- (NSUInteger)indexCaseInsensitiveOfString:(NSString *)aString fromIndex:(NSUInteger)startPos;

- (BOOL)containsString:(NSString *)aString;
- (BOOL)containsCaseInsensitiveString:(NSString *)aString;

- (BOOL)containsAnyOfStringInArray:(NSArray *)array;
- (BOOL)containsAnyOfCaseInsensitiveStringInArray:(NSArray *)array;

- (BOOL)containsAllOfStringInArray:(NSArray *)array;
- (BOOL)containsAllOfCaseInsensitiveStringInArray:(NSArray *)array;

- (NSArray *)arraySplitedByString:(NSString *)separator;
- (NSArray *)arraySplitedByCharactersInSet:(NSCharacterSet *)separator;

- (NSArray *)arraySplitedByString:(NSString *)separator filterEmptyItem:(BOOL)filterEmptyItem;
- (NSArray *)arraySplitedByCharactersInSet:(NSCharacterSet *)separator filterEmptyItem:(BOOL)filterEmptyItem;

+ (AGX_INSTANCETYPE)stringWithArray:(NSArray *)array;
+ (AGX_INSTANCETYPE)stringWithArray:(NSArray *)array separator:(NSString *)separatorString;
- (NSString *)appendWithObjects:(id)firstObj, ... NS_REQUIRES_NIL_TERMINATION;

- (NSString *)stringByReplacingString:(NSString *)searchString withString:(NSString *)replacement;
- (NSString *)stringByCaseInsensitiveReplacingString:(NSString *)searchString withString:(NSString *)replacement;

- (NSString *)stringByReplacingCharactersInSet:(NSCharacterSet *)set withString:(NSString *)replacement;
- (NSString *)stringByReplacingCharactersInSet:(NSCharacterSet *)set withString:(NSString *)replacement mergeContinuous:(BOOL)mergeContinuous;

- (NSString *)stringByEscapingForURLQuery;
- (NSString *)stringByUnescapingFromURLQuery;

- (NSString *)MD5Sum;
- (NSString *)SHA1Sum;

- (NSString *)base64EncodedString;
+ (NSString *)stringWithBase64String:(NSString *)base64String;

+ (NSString *)replaceUnicodeToUTF8:(NSString *)aUnicodeString;
+ (NSString *)replaceUTF8ToUnicode:(NSString *)aUTF8String;

+ (NSString *)uuidString;
- (NSString *)parametricStringWithObject:(id)object;

- (CGSize)agxSizeWithFont:(UIFont *)font constrainedToSize:(CGSize)size;
@end

#endif /* AGXCore_NSString_AGXCore_h */
