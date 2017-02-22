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
@property (readonly) NSUInteger unsignedIntegerValue;

+ (AGX_INSTANCETYPE)stringWithData:(NSData *)data encoding:(NSStringEncoding)encoding;
+ (AGX_INSTANCETYPE)stringWithBytes:(const void *)bytes length:(NSUInteger)len encoding:(NSStringEncoding)encoding;

- (BOOL)isEmpty;
- (BOOL)isNotEmpty;

- (NSString *)trim;
- (NSString *)trimToNil;

- (NSString *)capitalized;

- (NSComparisonResult)compareToVersionString:(NSString *)version;

- (BOOL)containsString:(NSString *)aString;
- (BOOL)containsCharactersFromSet:(NSCharacterSet *)set;

- (BOOL)containsAnyOfStringInArray:(NSArray *)array;
- (BOOL)containsAllOfStringInArray:(NSArray *)array;

- (NSUInteger)indexOfString:(NSString *)aString;
- (NSUInteger)indexOfCharactersFromSet:(NSCharacterSet *)set;

- (NSUInteger)lastIndexOfString:(NSString *)aString;
- (NSUInteger)lastIndexOfCharactersFromSet:(NSCharacterSet *)set;

- (NSUInteger)indexOfString:(NSString *)aString fromIndex:(NSUInteger)startPos;
- (NSUInteger)indexOfCharactersFromSet:(NSCharacterSet *)set fromIndex:(NSUInteger)startPos;

- (NSUInteger)lastIndexOfString:(NSString *)aString toIndex:(NSUInteger)endPos;
- (NSUInteger)lastIndexOfCharactersFromSet:(NSCharacterSet *)set toIndex:(NSUInteger)endPos;

- (NSString *)substringFromFirstString:(NSString *)aString;
- (NSString *)substringFromFirstCharactersFromSet:(NSCharacterSet *)set;

- (NSString *)substringToFirstString:(NSString *)aString;
- (NSString *)substringToFirstCharactersFromSet:(NSCharacterSet *)set;

- (NSString *)substringFromLastString:(NSString *)aString;
- (NSString *)substringFromLastCharactersFromSet:(NSCharacterSet *)set;

- (NSString *)substringToLastString:(NSString *)aString;
- (NSString *)substringToLastCharactersFromSet:(NSCharacterSet *)set;

- (NSArray *)arraySeparatedByString:(NSString *)separator filterEmpty:(BOOL)filterEmpty;
- (NSArray *)arraySeparatedByCharactersInSet:(NSCharacterSet *)separator filterEmpty:(BOOL)filterEmpty;

- (NSDictionary *)dictionarySeparatedByString:(NSString *)separator keyValueSeparatedByString:(NSString *)kvSeparator filterEmpty:(BOOL)filterEmpty;
- (NSDictionary *)dictionarySeparatedByCharactersInSet:(NSCharacterSet *)separator keyValueSeparatedByCharactersInSet:(NSCharacterSet *)kvSeparator filterEmpty:(BOOL)filterEmpty;

+ (NSString *)stringWithArray:(NSArray *)array usingComparator:(NSComparator)cmptr separator:(NSString *)separator filterEmpty:(BOOL)filterEmpty;
+ (NSString *)stringWithDictionary:(NSDictionary *)dictionary usingKeysComparator:(NSComparator)cmptr separator:(NSString *)separator keyValueSeparator:(NSString *)kvSeparator filterEmpty:(BOOL)filterEmpty;

- (NSString *)appendWithObjects:(id)firstObj, ... NS_REQUIRES_NIL_TERMINATION;

- (NSString *)stringByReplacingString:(NSString *)searchString withString:(NSString *)replacement;
- (NSString *)stringByReplacingCharactersInSet:(NSCharacterSet *)set withString:(NSString *)replacement mergeContinuous:(BOOL)mergeContinuous;

- (NSString *)stringByEscapingForURLQuery;
- (NSString *)stringByUnescapingFromURLQuery;

- (NSString *)MD5Sum;
- (NSString *)SHA1Sum;
- (NSString *)AES256EncryptedStringUsingKey:(NSString *)key;
- (NSString *)AES256DecryptedStringUsingKey:(NSString *)key;

- (NSString *)base64EncodedString;
+ (AGX_INSTANCETYPE)stringWithBase64String:(NSString *)base64String;

+ (NSString *)replaceUnicodeToUTF8:(NSString *)aUnicodeString;
+ (NSString *)replaceUTF8ToUnicode:(NSString *)aUTF8String;

+ (NSString *)uuidString;
- (NSString *)parametricStringWithObject:(id)object;

- (CGSize)agxSizeWithFont:(UIFont *)font constrainedToSize:(CGSize)size;

- (id)objectFromPlist;
@end

@category_interface(NSString, AGXCoreCaseInsensitive)
- (BOOL)isCaseInsensitiveEqual:(id)object;
- (BOOL)isCaseInsensitiveEqualToString:(NSString *)aString;

- (BOOL)hasCaseInsensitivePrefix:(NSString *)str;
- (BOOL)hasCaseInsensitiveSuffix:(NSString *)str;

- (BOOL)containsCaseInsensitiveString:(NSString *)aString;
- (BOOL)containsCaseInsensitiveCharactersFromSet:(NSCharacterSet *)set;

- (BOOL)containsAnyOfCaseInsensitiveStringInArray:(NSArray *)array;
- (BOOL)containsAllOfCaseInsensitiveStringInArray:(NSArray *)array;

- (NSUInteger)indexOfCaseInsensitiveString:(NSString *)aString;
- (NSUInteger)indexOfCaseInsensitiveCharactersFromSet:(NSCharacterSet *)set;

- (NSUInteger)lastIndexOfCaseInsensitiveString:(NSString *)aString;
- (NSUInteger)lastIndexOfCaseInsensitiveCharactersFromSet:(NSCharacterSet *)set;

- (NSUInteger)indexOfCaseInsensitiveString:(NSString *)aString fromIndex:(NSUInteger)startPos;
- (NSUInteger)indexOfCaseInsensitiveCharactersFromSet:(NSCharacterSet *)set fromIndex:(NSUInteger)startPos;

- (NSUInteger)lastIndexOfCaseInsensitiveString:(NSString *)aString fromIndex:(NSUInteger)startPos;
- (NSUInteger)lastIndexOfCaseInsensitiveCharactersFromSet:(NSCharacterSet *)set fromIndex:(NSUInteger)startPos;

- (NSString *)substringFromFirstCaseInsensitiveString:(NSString *)aString;
- (NSString *)substringFromFirstCaseInsensitiveCharactersFromSet:(NSCharacterSet *)set;

- (NSString *)substringToFirstCaseInsensitiveString:(NSString *)aString;
- (NSString *)substringToFirstCaseInsensitiveCharactersFromSet:(NSCharacterSet *)set;

- (NSString *)substringFromLastCaseInsensitiveString:(NSString *)aString;
- (NSString *)substringFromLastCaseInsensitiveCharactersFromSet:(NSCharacterSet *)set;

- (NSString *)substringToLastCaseInsensitiveString:(NSString *)aString;
- (NSString *)substringToLastCaseInsensitiveCharactersFromSet:(NSCharacterSet *)set;

- (NSString *)stringByReplacingCaseInsensitiveString:(NSString *)searchString withString:(NSString *)replacement;
@end

#endif /* AGXCore_NSString_AGXCore_h */
