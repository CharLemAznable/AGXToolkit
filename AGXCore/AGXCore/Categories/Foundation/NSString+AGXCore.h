//
//  NSString+AGXCore.h
//  AGXCore
//
//  Created by Char Aznable on 2016/2/4.
//  Copyright © 2016年 AI-CUC-EC. All rights reserved.
//

#ifndef AGXCore_NSString_AGXCore_h
#define AGXCore_NSString_AGXCore_h

#import <UIKit/UIKit.h>
#import "NSObject+AGXCore.h"

@category_interface(NSString, AGXCore)
@property (readonly) NSUInteger unsignedIntegerValue;

+ (AGX_INSTANCETYPE)stringWithFormat:(NSString *)format arguments:(va_list)argList NS_FORMAT_FUNCTION(1,0);
+ (AGX_INSTANCETYPE)stringWithData:(NSData *)data encoding:(NSStringEncoding)encoding;
+ (AGX_INSTANCETYPE)stringWithBytes:(const void *)bytes length:(NSUInteger)len encoding:(NSStringEncoding)encoding;

- (NSString *)trim;
- (NSString *)trimToNil;

- (NSString *)capitalized;

- (NSComparisonResult)compareToVersionString:(NSString *)version;

- (BOOL)containsCharacterFromSet:(NSCharacterSet *)set;
- (BOOL)containsAnyOfStringInArray:(NSArray *)array;
- (BOOL)containsAllOfStringInArray:(NSArray *)array;

- (NSUInteger)indexOfString:(NSString *)aString;
- (NSUInteger)indexOfCharacterFromSet:(NSCharacterSet *)set;

- (NSUInteger)lastIndexOfString:(NSString *)aString;
- (NSUInteger)lastIndexOfCharacterFromSet:(NSCharacterSet *)set;

- (NSUInteger)indexOfString:(NSString *)aString fromIndex:(NSUInteger)startPos;
- (NSUInteger)indexOfCharacterFromSet:(NSCharacterSet *)set fromIndex:(NSUInteger)startPos;

- (NSUInteger)lastIndexOfString:(NSString *)aString toIndex:(NSUInteger)endPos;
- (NSUInteger)lastIndexOfCharacterFromSet:(NSCharacterSet *)set toIndex:(NSUInteger)endPos;

- (NSString *)substringFromFirstString:(NSString *)aString;
- (NSString *)substringFromFirstCharacterFromSet:(NSCharacterSet *)set;

- (NSString *)substringToFirstString:(NSString *)aString;
- (NSString *)substringToFirstCharacterFromSet:(NSCharacterSet *)set;

- (NSString *)substringFromLastString:(NSString *)aString;
- (NSString *)substringFromLastCharacterFromSet:(NSCharacterSet *)set;

- (NSString *)substringToLastString:(NSString *)aString;
- (NSString *)substringToLastCharacterFromSet:(NSCharacterSet *)set;

- (NSArray *)arraySeparatedByString:(NSString *)separator filterEmpty:(BOOL)filterEmpty;
- (NSArray *)arraySeparatedByCharactersInSet:(NSCharacterSet *)separator filterEmpty:(BOOL)filterEmpty;

- (NSDictionary *)dictionarySeparatedByString:(NSString *)separator keyValueSeparatedByString:(NSString *)kvSeparator filterEmpty:(BOOL)filterEmpty;
- (NSDictionary *)dictionarySeparatedByCharactersInSet:(NSCharacterSet *)separator keyValueSeparatedByCharactersInSet:(NSCharacterSet *)kvSeparator filterEmpty:(BOOL)filterEmpty;

+ (AGX_INSTANCETYPE)stringWithArray:(NSArray *)array joinedByString:(NSString *)joiner usingComparator:(NSComparator)cmptr filterEmpty:(BOOL)filterEmpty;
+ (AGX_INSTANCETYPE)stringWithDictionary:(NSDictionary *)dictionary joinedByString:(NSString *)joiner keyValueJoinedByString:(NSString *)kvJoiner usingKeysComparator:(NSComparator)cmptr filterEmpty:(BOOL)filterEmpty;

- (NSString *)stringByAppendingObjects:(id)firstObj, ... NS_REQUIRES_NIL_TERMINATION;

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
- (CGSize)agxSizeWithFont:(UIFont *)font constrainedToSize:(CGSize)size lineBreakMode:(NSLineBreakMode)lineBreakMode;

- (id)objectFromPlist;
@end

@category_interface(NSString, AGXCoreCaseInsensitive)
- (BOOL)isCaseInsensitiveEqual:(id)object;
- (BOOL)isCaseInsensitiveEqualToString:(NSString *)aString;

- (BOOL)hasCaseInsensitivePrefix:(NSString *)str;
- (BOOL)hasCaseInsensitiveSuffix:(NSString *)str;

- (BOOL)containsCaseInsensitiveString:(NSString *)aString;
- (BOOL)containsAnyOfCaseInsensitiveStringInArray:(NSArray *)array;
- (BOOL)containsAllOfCaseInsensitiveStringInArray:(NSArray *)array;

- (NSUInteger)indexOfCaseInsensitiveString:(NSString *)aString;
- (NSUInteger)lastIndexOfCaseInsensitiveString:(NSString *)aString;
- (NSUInteger)indexOfCaseInsensitiveString:(NSString *)aString fromIndex:(NSUInteger)startPos;
- (NSUInteger)lastIndexOfCaseInsensitiveString:(NSString *)aString fromIndex:(NSUInteger)startPos;

- (NSString *)substringFromFirstCaseInsensitiveString:(NSString *)aString;
- (NSString *)substringToFirstCaseInsensitiveString:(NSString *)aString;
- (NSString *)substringFromLastCaseInsensitiveString:(NSString *)aString;
- (NSString *)substringToLastCaseInsensitiveString:(NSString *)aString;

- (NSArray *)componentsSeparatedByCaseInsensitiveString:(NSString *)separator;
- (NSArray *)arraySeparatedByCaseInsensitiveString:(NSString *)separator filterEmpty:(BOOL)filterEmpty;
- (NSDictionary *)dictionarySeparatedByCaseInsensitiveString:(NSString *)separator keyValueSeparatedByCaseInsensitiveString:(NSString *)kvSeparator filterEmpty:(BOOL)filterEmpty;

- (NSString *)stringByReplacingCaseInsensitiveString:(NSString *)searchString withString:(NSString *)replacement;
@end

#endif /* AGXCore_NSString_AGXCore_h */
