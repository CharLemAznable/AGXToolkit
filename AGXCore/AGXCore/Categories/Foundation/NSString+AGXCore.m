//
//  NSString+AGXCore.m
//  AGXCore
//
//  Created by Char Aznable on 16/2/4.
//  Copyright © 2016年 AI-CUC-EC. All rights reserved.
//

#import <CommonCrypto/CommonDigest.h>
#import "NSString+AGXCore.h"
#import "AGXArc.h"
#import "NSObject+AGXCore.h"
#import "NSData+AGXCore.h"

@category_implementation(NSString, AGXCore)

#pragma mark - Extracting numeric values

- (NSUInteger)unsignedIntegerValue {
    NSNumberFormatter *formatter = NSNumberFormatter.instance;
    return [formatter numberFromString:self].unsignedIntegerValue;
}

#pragma mark - Convenience Initialization

+ (AGX_INSTANCETYPE)stringWithFormat:(NSString *)format arguments:(va_list)argList NS_FORMAT_FUNCTION(1,0) {
    return AGX_AUTORELEASE([[self alloc] initWithFormat:format arguments:argList]);
}

+ (AGX_INSTANCETYPE)stringWithData:(NSData *)data encoding:(NSStringEncoding)encoding {
    return AGX_AUTORELEASE([[self alloc] initWithData:data encoding:encoding]);
}

+ (AGX_INSTANCETYPE)stringWithBytes:(const void *)bytes length:(NSUInteger)len encoding:(NSStringEncoding)encoding {
    return AGX_AUTORELEASE([[self alloc] initWithBytes:bytes length:len encoding:encoding]);
}

#pragma mark - Empty Methods

- (BOOL)isEmpty {
    return [self length] == 0;
}

- (BOOL)isNotEmpty {
    return [self length] != 0;
}

#pragma mark - Trim Methods

- (NSString *)trim {
    return [self stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
}

- (NSString *)trimToNil {
    NSString *str = [self trim];
    return [str isEmpty] ? nil : str;
}

#pragma mark - Case Methods

- (NSString *)capitalized {
    if (self.length <= 1) return [self capitalizedString];
    return [NSString stringWithFormat:@"%@%@",
            [[self substringToIndex:1] uppercaseString],
            [self substringFromIndex:1]];
}

#pragma mark - Compare Methods

- (NSComparisonResult)compareToVersionString:(NSString *)version {
    // Break version into fields (separated by '.')
    NSMutableArray *leftFields  = [NSMutableArray arrayWithArray:[self    componentsSeparatedByString:@"."]];
    NSMutableArray *rightFields = [NSMutableArray arrayWithArray:[version componentsSeparatedByString:@"."]];

    // Implict ".0" in case version doesn't have the same number of '.'
    if ([leftFields count] < [rightFields count]) {
        while ([leftFields count] != [rightFields count]) {
            [leftFields addObject:@"0"];
        }
    } else if ([leftFields count] > [rightFields count]) {
        while ([leftFields count] != [rightFields count]) {
            [rightFields addObject:@"0"];
        }
    }

    // Do a numeric comparison on each field
    for (NSUInteger i = 0; i < [leftFields count]; i++) {
        NSComparisonResult result = [[leftFields objectAtIndex:i] compare:[rightFields objectAtIndex:i] options:NSNumericSearch];
        if (result != NSOrderedSame) {
            return result;
        }
    }

    return NSOrderedSame;
}

#pragma mark - Contain Methods

- (BOOL)containsCharacterFromSet:(NSCharacterSet *)set {
    return [self rangeOfCharacterFromSet:set].length > 0;
}

- (BOOL)containsAnyOfStringInArray:(NSArray *)array {
    for (id item in array) if ([self containsString:[item description]]) return YES;
    return NO;
}

- (BOOL)containsAllOfStringInArray:(NSArray *)array {
    for (id item in array) if (![self containsString:[item description]]) return NO;
    return YES;
}

#pragma mark - Index Methods

- (NSUInteger)indexOfString:(NSString *)aString {
    return [self rangeOfString:aString].location;
}

- (NSUInteger)indexOfCharacterFromSet:(NSCharacterSet *)set {
    return [self rangeOfCharacterFromSet:set].location;
}

- (NSUInteger)lastIndexOfString:(NSString *)aString {
    return [self lastRangeOfString:aString].location;
}

- (NSUInteger)lastIndexOfCharacterFromSet:(NSCharacterSet *)set {
    return [self lastRangeOfCharacterFromSet:set].location;
}

#pragma mark - Sub Index Methods

- (NSUInteger)indexOfString:(NSString *)aString fromIndex:(NSUInteger)startPos {
    return [[self substringFromIndex:startPos] rangeOfString:aString].location;
}

- (NSUInteger)indexOfCharacterFromSet:(NSCharacterSet *)set fromIndex:(NSUInteger)startPos {
    return [[self substringFromIndex:startPos] rangeOfCharacterFromSet:set].location;
}

- (NSUInteger)lastIndexOfString:(NSString *)aString toIndex:(NSUInteger)endPos {
    return [[self substringToIndex:endPos] lastRangeOfString:aString].location;
}

- (NSUInteger)lastIndexOfCharacterFromSet:(NSCharacterSet *)set toIndex:(NSUInteger)endPos {
    return [[self substringToIndex:endPos] lastRangeOfCharacterFromSet:set].location;
}

#pragma mark - Sub String Methods

- (NSString *)substringFromFirstString:(NSString *)aString {
    return [self substringAfterRange:[self rangeOfString:aString]];
}

- (NSString *)substringFromFirstCharacterFromSet:(NSCharacterSet *)set {
    return [self substringAfterRange:[self rangeOfCharacterFromSet:set]];
}

- (NSString *)substringToFirstString:(NSString *)aString {
    return [self substringBeforeRange:[self rangeOfString:aString]];
}

- (NSString *)substringToFirstCharacterFromSet:(NSCharacterSet *)set {
    return [self substringBeforeRange:[self rangeOfCharacterFromSet:set]];
}

- (NSString *)substringFromLastString:(NSString *)aString {
    return [self substringAfterRange:[self lastRangeOfString:aString]];
}

- (NSString *)substringFromLastCharacterFromSet:(NSCharacterSet *)set {
    return [self substringAfterRange:[self lastRangeOfCharacterFromSet:set]];
}

- (NSString *)substringToLastString:(NSString *)aString {
    return [self substringBeforeRange:[self lastRangeOfString:aString]];
}

- (NSString *)substringToLastCharacterFromSet:(NSCharacterSet *)set {
    return [self substringBeforeRange:[self lastRangeOfCharacterFromSet:set]];
}

#pragma mark - private util methods

- (NSRange)lastRangeOfString:(NSString *)aString {
    return [self rangeOfString:aString options:NSBackwardsSearch];
}

- (NSRange)lastRangeOfCharacterFromSet:(NSCharacterSet *)set {
    return [self rangeOfCharacterFromSet:set options:NSBackwardsSearch];
}

- (NSString *)substringAfterRange:(NSRange)range {
    return range.length == 0 ? AGX_AUTORELEASE([self copy])
    : [self substringFromIndex:range.location + range.length];
}

- (NSString *)substringBeforeRange:(NSRange)range {
    return range.length == 0 ? AGX_AUTORELEASE([self copy])
    : [self substringToIndex:range.location];
}

#pragma mark - Separate Methods

- (NSArray *)arraySeparatedByString:(NSString *)separator filterEmpty:(BOOL)filterEmpty {
    if AGX_EXPECT_F([self isEmpty]) return filterEmpty ? @[] : @[@""];
    NSArray *components = [self componentsSeparatedByString:separator];
    return filterEmpty ? [components filteredArrayUsingPredicate:
                          [NSPredicate predicateWithFormat:@"SELF.length > 0"]] : components;
}

- (NSArray *)arraySeparatedByCharactersInSet:(NSCharacterSet *)separator filterEmpty:(BOOL)filterEmpty {
    if AGX_EXPECT_F([self isEmpty]) return filterEmpty ? @[] : @[@""];
    NSArray *components = [self componentsSeparatedByCharactersInSet:separator];
    return filterEmpty ? [components filteredArrayUsingPredicate:
                          [NSPredicate predicateWithFormat:@"SELF.length > 0"]] : components;
}

- (NSDictionary *)dictionarySeparatedByString:(NSString *)separator keyValueSeparatedByString:(NSString *)kvSeparator filterEmpty:(BOOL)filterEmpty {
    if AGX_EXPECT_F([self isEmpty]) return @{};
    NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];
    [[self arraySeparatedByString:separator filterEmpty:filterEmpty] enumerateObjectsUsingBlock:
     ^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
         if AGX_EXPECT_F(![obj containsString:kvSeparator]) return;

         NSString *k = [obj substringToFirstString:kvSeparator];
         NSString *v = [obj substringFromFirstString:kvSeparator];
         if (filterEmpty && AGX_EXPECT_F([k isEmpty] || [v isEmpty])) return;

         dictionary[k] = v;
     }];
    return AGX_AUTORELEASE([dictionary copy]);
}

- (NSDictionary *)dictionarySeparatedByCharactersInSet:(NSCharacterSet *)separator keyValueSeparatedByCharactersInSet:(NSCharacterSet *)kvSeparator filterEmpty:(BOOL)filterEmpty {
    if AGX_EXPECT_F([self isEmpty]) return @{};
    NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];
    [[self arraySeparatedByCharactersInSet:separator filterEmpty:filterEmpty] enumerateObjectsUsingBlock:
     ^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
         if AGX_EXPECT_F(![obj containsCharacterFromSet:kvSeparator]) return;

         NSString *k = [obj substringToFirstCharacterFromSet:kvSeparator];
         NSString *v = [obj substringFromFirstCharacterFromSet:kvSeparator];
         if (filterEmpty && AGX_EXPECT_F([k isEmpty] || [v isEmpty])) return;

         dictionary[k] = v;
     }];
    return AGX_AUTORELEASE([dictionary copy]);
}

#pragma mark - Merge Methods

+ (AGX_INSTANCETYPE)stringWithArray:(NSArray *)array joinedByString:(NSString *)joiner usingComparator:(NSComparator)cmptr filterEmpty:(BOOL)filterEmpty {
    if AGX_EXPECT_F(!array) return @"";
    NSArray *arr = cmptr ? [array sortedArrayUsingComparator:cmptr] : array;

    NSMutableString *result = [NSMutableString string];
    for (int i = 0; i < [arr count]; i++) {
        NSString *item = [[arr objectAtIndex:i] description];
        if (filterEmpty && AGX_EXPECT_F([item isEmpty])) continue;
        [result appendString:item];
        if (i + 1 < [arr count]) [result appendString:joiner];
    }
    return [self stringWithString:result];
}

+ (AGX_INSTANCETYPE)stringWithDictionary:(NSDictionary *)dictionary joinedByString:(NSString *)joiner keyValueJoinedByString:(NSString *)kvJoiner usingKeysComparator:(NSComparator)cmptr filterEmpty:(BOOL)filterEmpty {
    if AGX_EXPECT_F(!dictionary) return @"";
    NSArray *keys = cmptr ? [[dictionary allKeys] sortedArrayUsingComparator:cmptr] : [dictionary allKeys];

    NSMutableArray *array = [NSMutableArray array];
    [keys enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSString *k = [obj description];
        NSString *v = [dictionary[obj] description];
        if (filterEmpty && AGX_EXPECT_F([k isEmpty] || [v isEmpty])) return;

        [array addObject:[NSString stringWithFormat:@"%@%@%@", k, kvJoiner, v]];
    }];
    return [self stringWithArray:array joinedByString:joiner usingComparator:NULL filterEmpty:filterEmpty];
}

#pragma mark - Append Methods

- (NSString *)appendWithObjects:(id)firstObj, ... NS_REQUIRES_NIL_TERMINATION {
    NSArray *objects = agx_va_list(firstObj);
    NSMutableArray *temp = [NSMutableArray arrayWithArray:objects];
    [temp insertObject:self atIndex:0];
    return [NSString stringWithArray:temp joinedByString:@"" usingComparator:NULL filterEmpty:NO];
}

#pragma mark - Replace Methods

- (NSString *)stringByReplacingString:(NSString *)searchString withString:(NSString *)replacement {
    return [self stringByReplacingOccurrencesOfString:searchString withString:replacement
                                              options:0 range:NSMakeRange(0, self.length)];
}

- (NSString *)stringByReplacingCharactersInSet:(NSCharacterSet *)set withString:(NSString *)replacement mergeContinuous:(BOOL)mergeContinuous {
    return [NSString stringWithArray:[self arraySeparatedByCharactersInSet:set filterEmpty:mergeContinuous]
                     joinedByString:replacement usingComparator:NULL filterEmpty:NO];
}

#pragma mark - Escape/Unescape Methods

- (NSString *)stringByEscapingForURLQuery {
    return [self stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet characterSetWithCharactersInString:@"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"]];
}


- (NSString *)stringByUnescapingFromURLQuery {
    return [self stringByRemovingPercentEncoding];
}

#pragma mark - Encode/Decode Methods

- (NSString *)MD5Sum {
    const char *cstr = [self cStringUsingEncoding:NSUTF8StringEncoding];
    unsigned char digest[CC_MD5_DIGEST_LENGTH], i;
    CC_MD5(cstr, (unsigned int)strlen(cstr), digest);
    NSMutableString *ms = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH * 2];
    for (i = 0; i < CC_MD5_DIGEST_LENGTH; i++) {
        [ms appendFormat:@"%02x", digest[i]];
    }
    return AGX_AUTORELEASE([ms copy]);
}

- (NSString *)SHA1Sum {
    const char *cstr = [self cStringUsingEncoding:NSUTF8StringEncoding];
    unsigned char digest[CC_SHA1_DIGEST_LENGTH], i;
    CC_SHA1(cstr, (unsigned int)strlen(cstr), digest);
    NSMutableString *ms = [NSMutableString stringWithCapacity:CC_SHA1_DIGEST_LENGTH * 2];
    for (i = 0; i < CC_SHA1_DIGEST_LENGTH; i++) {
        [ms appendFormat:@"%02x", digest[i]];
    }
    return AGX_AUTORELEASE([ms copy]);
}

- (NSString *)AES256EncryptedStringUsingKey:(NSString *)key {
    return [[[self dataUsingEncoding:NSUTF8StringEncoding] AES256EncryptedDataUsingKey:key] base64EncodedString];
}

- (NSString *)AES256DecryptedStringUsingKey:(NSString *)key {
    NSData *result = [[NSData dataWithBase64String:self] AES256DecryptedDataUsingKey:key];
    if AGX_EXPECT_T(result && result.length > 0) {
        return [NSString stringWithData:result encoding:NSUTF8StringEncoding];
    }
    return nil;
}

- (NSString *)base64EncodedString  {
    if AGX_EXPECT_F([self length] == 0) return nil;
    return [[self dataUsingEncoding:NSUTF8StringEncoding] base64EncodedString];
}

+ (AGX_INSTANCETYPE)stringWithBase64String:(NSString *)base64String {
    return [self stringWithData:[NSData dataWithBase64String:base64String] encoding:NSUTF8StringEncoding];
}

+ (NSString *)replaceUnicodeToUTF8:(NSString *)aUnicodeString {
    NSString *tempStr1 = [aUnicodeString stringByReplacingOccurrencesOfString:@"\\u" withString:@"\\U"];
    NSString *tempStr2 = [tempStr1 stringByReplacingOccurrencesOfString:@"\"" withString:@"\\\""];
    NSString *tempStr3 = [[@"\"" stringByAppendingString:tempStr2] stringByAppendingString:@"\""];
    NSData *tempData = [tempStr3 dataUsingEncoding:NSUTF8StringEncoding];
    NSString *returnStr = [NSPropertyListSerialization propertyListWithData:tempData
                                                                    options:NSPropertyListImmutable
                                                                     format:NULL error:NULL];

    return [returnStr stringByReplacingOccurrencesOfString:@"\\r\\n" withString:@"\n"];
}

+ (NSString *)replaceUTF8ToUnicode:(NSString *)aUTF8String {
    NSUInteger length = [aUTF8String length];
    NSMutableString *s = [NSMutableString stringWithCapacity:0];
    for (int i = 0; i < length; i++) {
        unichar _char = [aUTF8String characterAtIndex:i];

        //判断是否为英文和数字
        if (_char <= '9' && _char >= '0') {
            [s appendFormat:@"%@",[aUTF8String substringWithRange:NSMakeRange(i, 1)]];
        } else if (_char >= 'a' && _char <= 'z') {
            [s appendFormat:@"%@",[aUTF8String substringWithRange:NSMakeRange(i, 1)]];
        } else if (_char >= 'A' && _char <= 'Z') {
            [s appendFormat:@"%@",[aUTF8String substringWithRange:NSMakeRange(i, 1)]];
        } else {
            [s appendFormat:@"\\u%x",[aUTF8String characterAtIndex:i]];
        }
    }
    return s;
}

#pragma mark - UUID

+ (NSString *)uuidString {
    CFUUIDRef uuidObj = CFUUIDCreate(nil);
    NSString *uuidString = (AGX_BRIDGE_TRANSFER NSString *)CFUUIDCreateString(nil, uuidObj);
    CFRelease(uuidObj);
    return AGX_AUTORELEASE(uuidString);
}

#pragma mark - Parametric builder

- (NSString *)parametricStringWithObject:(id)object {
    NSMutableString *result = [NSMutableString string];
    NSUInteger start = 0, end = [self indexOfString:@"${" fromIndex:start];
    while (end != NSNotFound) {
        [result appendString:[self substringWithRange:NSMakeRange(start, end)]];
        start += end + 2;
        end = [self indexOfString:@"}" fromIndex:start];
        if AGX_EXPECT_F(end == NSNotFound) break;
        NSString *value = [object valueForKeyPath:[self substringWithRange:NSMakeRange(start, end)]];
        [result appendString:value?:@""];
        start += end + 1;
        end = [self indexOfString:@"${" fromIndex:start];
    }
    if AGX_EXPECT_T(start < [self length]) [result appendString:[self substringFromIndex:start]];
    return AGX_AUTORELEASE([result copy]);
}

#pragma mark - Size caculator

- (CGSize)agxSizeWithFont:(UIFont *)font constrainedToSize:(CGSize)size {
    return [self agxSizeWithFont:font constrainedToSize:size lineBreakMode:NSLineBreakByWordWrapping];
}

- (CGSize)agxSizeWithFont:(UIFont *)font constrainedToSize:(CGSize)size lineBreakMode:(NSLineBreakMode)lineBreakMode {
    NSMutableParagraphStyle *paragraphStyle = NSMutableParagraphStyle.instance;
    paragraphStyle.lineBreakMode = lineBreakMode;
    return [self boundingRectWithSize:size options:NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading
                           attributes:@{ NSFontAttributeName:font, NSParagraphStyleAttributeName:paragraphStyle }
                              context:NULL].size;

}

#pragma mark - Plist

- (id)objectFromPlist {
    return [[NSData dataWithBase64String:self] objectFromPlist];
}

@end

@category_implementation(NSString, AGXCoreCaseInsensitive)

#pragma mark - Compare Methods

- (BOOL)isCaseInsensitiveEqual:(id)object {
    if (object == self) return YES;
    if AGX_EXPECT_F(!object || ![object isKindOfClass:[NSString class]]) return NO;
    return [self isCaseInsensitiveEqualToString:object];
}

- (BOOL)isCaseInsensitiveEqualToString:(NSString *)aString {
    if (aString == self) return YES;
    return NSOrderedSame == [self compare:aString options:NSCaseInsensitiveSearch];
}

- (BOOL)hasCaseInsensitivePrefix:(NSString *)str {
    return [self.lowercaseString hasPrefix:str.lowercaseString];
}

- (BOOL)hasCaseInsensitiveSuffix:(NSString *)str {
    return [self.lowercaseString hasSuffix:str.lowercaseString];
}

#pragma mark - Contain Methods

- (BOOL)containsCaseInsensitiveString:(NSString *)aString {
    return [self rangeOfCaseInsensitiveString:aString].length > 0;
}

- (BOOL)containsAnyOfCaseInsensitiveStringInArray:(NSArray *)array {
    for (id item in array) if ([self containsCaseInsensitiveString:[item description]]) return YES;
    return NO;
}

- (BOOL)containsAllOfCaseInsensitiveStringInArray:(NSArray *)array {
    for (id item in array) if (![self containsCaseInsensitiveString:[item description]]) return NO;
    return YES;
}

#pragma mark - Index Methods

- (NSUInteger)indexOfCaseInsensitiveString:(NSString *)aString {
    return [self rangeOfCaseInsensitiveString:aString].location;
}

- (NSUInteger)lastIndexOfCaseInsensitiveString:(NSString *)aString {
    return [self lastRangeOfCaseInsensitiveString:aString].location;
}

#pragma mark - Sub Index Methods

- (NSUInteger)indexOfCaseInsensitiveString:(NSString *)aString fromIndex:(NSUInteger)startPos {
    return [[self substringFromIndex:startPos] rangeOfCaseInsensitiveString:aString].location;
}

- (NSUInteger)lastIndexOfCaseInsensitiveString:(NSString *)aString fromIndex:(NSUInteger)startPos {
    return [[self substringToIndex:startPos] lastRangeOfCaseInsensitiveString:aString].location;
}

#pragma mark - Sub String Methods

- (NSString *)substringFromFirstCaseInsensitiveString:(NSString *)aString {
    return [self substringAfterRange:[self rangeOfCaseInsensitiveString:aString]];
}

- (NSString *)substringToFirstCaseInsensitiveString:(NSString *)aString {
    return [self substringBeforeRange:[self rangeOfCaseInsensitiveString:aString]];
}

- (NSString *)substringFromLastCaseInsensitiveString:(NSString *)aString {
    return [self substringAfterRange:[self lastRangeOfCaseInsensitiveString:aString]];
}

- (NSString *)substringToLastCaseInsensitiveString:(NSString *)aString {
    return [self substringBeforeRange:[self lastRangeOfCaseInsensitiveString:aString]];
}

#pragma mark - private util methods

- (NSRange)rangeOfCaseInsensitiveString:(NSString *)aString {
    return [self rangeOfString:aString options:NSCaseInsensitiveSearch];
}

- (NSRange)lastRangeOfCaseInsensitiveString:(NSString *)aString {
    return [self rangeOfString:aString options:NSCaseInsensitiveSearch|NSBackwardsSearch];
}

#pragma mark - Separate Methods

- (NSArray<NSString *> *)componentsSeparatedByCaseInsensitiveString:(NSString *)separator {
    NSMutableArray *result = [NSMutableArray array];
    NSRange range = [[self substringFromIndex:0] rangeOfCaseInsensitiveString:separator];
    NSUInteger start = 0, end = range.location;
    while (end != NSNotFound) {
        if (start + end > 0) [result addObject:[self substringWithRange:NSMakeRange(start, end)]];
        start += end + range.length;
        range = [[self substringFromIndex:start] rangeOfCaseInsensitiveString:separator];
        end = range.location;
    }
    if AGX_EXPECT_T(start < [self length]) [result addObject:[self substringFromIndex:start]];
    return AGX_AUTORELEASE([result copy]);
}

- (NSArray *)arraySeparatedByCaseInsensitiveString:(NSString *)separator filterEmpty:(BOOL)filterEmpty {
    if AGX_EXPECT_F([self isEmpty]) return filterEmpty ? @[] : @[@""];
    NSArray *components = [self componentsSeparatedByCaseInsensitiveString:separator];
    return filterEmpty ? [components filteredArrayUsingPredicate:
                          [NSPredicate predicateWithFormat:@"SELF.length > 0"]] : components;
}

- (NSDictionary *)dictionarySeparatedByCaseInsensitiveString:(NSString *)separator keyValueSeparatedByCaseInsensitiveString:(NSString *)kvSeparator filterEmpty:(BOOL)filterEmpty {
    if AGX_EXPECT_F([self isEmpty]) return @{};
    NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];
    [[self arraySeparatedByCaseInsensitiveString:separator filterEmpty:filterEmpty]
     enumerateObjectsUsingBlock:
     ^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
         if AGX_EXPECT_F(![obj containsCaseInsensitiveString:kvSeparator]) return;

         NSString *k = [obj substringToFirstCaseInsensitiveString:kvSeparator];
         NSString *v = [obj substringFromFirstCaseInsensitiveString:kvSeparator];
         if (filterEmpty && AGX_EXPECT_F([k isEmpty] || [v isEmpty])) return;

         dictionary[k] = v;
     }];
    return AGX_AUTORELEASE([dictionary copy]);
}

#pragma mark - Replace Methods

- (NSString *)stringByReplacingCaseInsensitiveString:(NSString *)searchString withString:(NSString *)replacement {
    return [self stringByReplacingOccurrencesOfString:searchString withString:replacement
                                              options:NSCaseInsensitiveSearch range:NSMakeRange(0, self.length)];
}

@end

@category_interface(NSString, AGXCoreSafe)
@end
@category_implementation(NSString, AGXCoreSafe)

+ (AGX_INSTANCETYPE)AGXCoreSafe_NSString_stringWithUTF8String:(const char *)nullTerminatedCString {
    if AGX_EXPECT_F(!nullTerminatedCString) return nil;
    return [self AGXCoreSafe_NSString_stringWithUTF8String:nullTerminatedCString];
}

- (AGX_INSTANCETYPE)AGXCoreSafe_NSString_initWithUTF8String:(const char *)nullTerminatedCString {
    if AGX_EXPECT_F(!nullTerminatedCString) return nil;
    return [self AGXCoreSafe_NSString_initWithUTF8String:nullTerminatedCString];
}

+ (AGX_INSTANCETYPE)AGXCoreSafe_NSString_stringWithCString:(const char *)cString encoding:(NSStringEncoding)enc {
    if AGX_EXPECT_F(!cString) return nil;
    return [self AGXCoreSafe_NSString_stringWithCString:cString encoding:enc];
}

- (AGX_INSTANCETYPE)AGXCoreSafe_NSString_initWithCString:(const char *)nullTerminatedCString encoding:(NSStringEncoding)encoding {
    if AGX_EXPECT_F(!nullTerminatedCString) return nil;
    return [self AGXCoreSafe_NSString_initWithCString:nullTerminatedCString encoding:encoding];
}

+ (void)load {
    static dispatch_once_t once_t;
    dispatch_once(&once_t, ^{
        [NSString swizzleClassOriSelector:@selector(stringWithUTF8String:)
                          withNewSelector:@selector(AGXCoreSafe_NSString_stringWithUTF8String:)];
        [NSString swizzleInstanceOriSelector:@selector(initWithUTF8String:)
                             withNewSelector:@selector(AGXCoreSafe_NSString_initWithUTF8String:)];
        [NSString swizzleClassOriSelector:@selector(stringWithCString:encoding:)
                          withNewSelector:@selector(AGXCoreSafe_NSString_stringWithCString:encoding:)];
        [NSString swizzleInstanceOriSelector:@selector(initWithCString:encoding:)
                             withNewSelector:@selector(AGXCoreSafe_NSString_initWithCString:encoding:)];
    });
}

@end
