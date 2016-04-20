//
//  NSString+AGXCore.m
//  AGXCore
//
//  Created by Char Aznable on 16/2/4.
//  Copyright © 2016年 AI-CUC-EC. All rights reserved.
//

#import "NSString+AGXCore.h"
#import "NSObject+AGXCore.h"
#import "NSData+AGXCore.h"
#import "AGXArc.h"
#include <CommonCrypto/CommonDigest.h>

@category_implementation(NSString, AGXCore)

#pragma mark - Extracting numeric values

- (NSUInteger)unsignedIntegerValue {
    NSNumberFormatter *formatter = AGX_AUTORELEASE([[NSNumberFormatter alloc] init]);
    return [formatter numberFromString:self].unsignedIntegerValue;
}

#pragma mark - Convenience Initialization

+ (NSString *)stringWithData:(NSData *)data encoding:(NSStringEncoding)encoding {
    return AGX_AUTORELEASE([[NSString alloc] initWithData:data encoding:encoding]);
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

- (BOOL)containsString:(NSString *)aString {
    return [self rangeOfString:aString].length > 0;
}

- (BOOL)containsCharactersFromSet:(NSCharacterSet *)set {
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

- (NSUInteger)indexOfCharactersFromSet:(NSCharacterSet *)set {
    return [self rangeOfCharacterFromSet:set].location;
}

- (NSUInteger)lastIndexOfString:(NSString *)aString {
    return [self rangeOfString:aString options:NSBackwardsSearch].location;
}

- (NSUInteger)lastIndexOfCharactersFromSet:(NSCharacterSet *)set {
    return [self rangeOfCharacterFromSet:set options:NSBackwardsSearch].location;
}

#pragma mark - Sub Index Methods

- (NSUInteger)indexOfString:(NSString *)aString fromIndex:(NSUInteger)startPos {
    return [[self substringFromIndex:startPos] rangeOfString:aString].location;
}

- (NSUInteger)indexOfCharactersFromSet:(NSCharacterSet *)set fromIndex:(NSUInteger)startPos {
    return [[self substringFromIndex:startPos] rangeOfCharacterFromSet:set].location;
}

- (NSUInteger)lastIndexOfString:(NSString *)aString fromIndex:(NSUInteger)startPos {
    return [[self substringToIndex:startPos] rangeOfString:aString options:NSBackwardsSearch].location;
}

- (NSUInteger)lastIndexOfCharactersFromSet:(NSCharacterSet *)set fromIndex:(NSUInteger)startPos {
    return [[self substringToIndex:startPos] rangeOfCharacterFromSet:set options:NSBackwardsSearch].location;
}

#pragma mark - Sub String Methods

- (NSString *)substringFromFirstString:(NSString *)aString {
    return [self containsString:aString] ?
    [self substringFromIndex:[self indexOfString:aString]
     + [self rangeOfString:aString].length] :
    AGX_AUTORELEASE([self copy]);
}

- (NSString *)substringFromFirstCharactersFromSet:(NSCharacterSet *)set {
    return [self containsCharactersFromSet:set] ?
    [self substringFromIndex:[self indexOfCharactersFromSet:set]
     + [self rangeOfCharacterFromSet:set].length] :
    AGX_AUTORELEASE([self copy]);
}

- (NSString *)substringToFirstString:(NSString *)aString {
    return [self containsString:aString] ?
    [self substringToIndex:[self indexOfString:aString]] :
    AGX_AUTORELEASE([self copy]);
}

- (NSString *)substringToFirstCharactersFromSet:(NSCharacterSet *)set {
    return [self containsCharactersFromSet:set] ?
    [self substringToIndex:[self indexOfCharactersFromSet:set]] :
    AGX_AUTORELEASE([self copy]);
}

- (NSString *)substringFromLastString:(NSString *)aString {
    return [self containsString:aString] ?
    [self substringFromIndex:[self lastIndexOfString:aString]
     + [self rangeOfString:aString options:NSBackwardsSearch].length] :
    AGX_AUTORELEASE([self copy]);
}

- (NSString *)substringFromLastCharactersFromSet:(NSCharacterSet *)set {
    return [self containsCharactersFromSet:set] ?
    [self substringFromIndex:[self lastIndexOfCharactersFromSet:set]
     + [self rangeOfCharacterFromSet:set options:NSBackwardsSearch].length] :
    AGX_AUTORELEASE([self copy]);
}

- (NSString *)substringToLastString:(NSString *)aString {
    return [self containsString:aString] ?
    [self substringToIndex:[self lastIndexOfString:aString]] :
    AGX_AUTORELEASE([self copy]);
}

- (NSString *)substringToLastCharactersFromSet:(NSCharacterSet *)set {
    return [self containsCharactersFromSet:set] ?
    [self substringToIndex:[self lastIndexOfCharactersFromSet:set]] :
    AGX_AUTORELEASE([self copy]);
}

#pragma mark - Separate Methods

- (NSArray *)arraySeparatedByString:(NSString *)separator filterEmpty:(BOOL)filterEmpty {
    if (AGX_EXPECT_F([self isEmpty])) return filterEmpty ? @[] : @[@""];
    NSArray *components = [self componentsSeparatedByString:separator];
    return filterEmpty ? [components filteredArrayUsingPredicate:
                          [NSPredicate predicateWithFormat:@"SELF.length > 0"]] : components;
}

- (NSArray *)arraySeparatedByCharactersInSet:(NSCharacterSet *)separator filterEmpty:(BOOL)filterEmpty {
    if (AGX_EXPECT_F([self isEmpty])) return filterEmpty ? @[] : @[@""];
    NSArray *components = [self componentsSeparatedByCharactersInSet:separator];
    return filterEmpty ? [components filteredArrayUsingPredicate:
                          [NSPredicate predicateWithFormat:@"SELF.length > 0"]] : components;
}

- (NSDictionary *)dictionarySeparatedByString:(NSString *)separator keyValueSeparatedByString:(NSString *)kvSeparator filterEmpty:(BOOL)filterEmpty {
    if (AGX_EXPECT_F([self isEmpty])) return @{};
    NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];
    [[self arraySeparatedByString:separator filterEmpty:filterEmpty] enumerateObjectsUsingBlock:
     ^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
         if (![obj containsString:kvSeparator]) return;
         
         NSString *k = [obj substringToFirstString:kvSeparator];
         NSString *v = [obj substringFromFirstString:kvSeparator];
         if (filterEmpty && ([k isEmpty] || [v isEmpty])) return;
         
         dictionary[k] = v;
     }];
    return AGX_AUTORELEASE([dictionary copy]);
}

- (NSDictionary *)dictionarySeparatedByCharactersInSet:(NSCharacterSet *)separator keyValueSeparatedByCharactersInSet:(NSCharacterSet *)kvSeparator filterEmpty:(BOOL)filterEmpty {
    if (AGX_EXPECT_F([self isEmpty])) return @{};
    NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];
    [[self arraySeparatedByCharactersInSet:separator filterEmpty:filterEmpty] enumerateObjectsUsingBlock:
     ^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
         if (![obj containsCharactersFromSet:kvSeparator]) return;
         
         NSString *k = [obj substringToFirstCharactersFromSet:kvSeparator];
         NSString *v = [obj substringFromFirstCharactersFromSet:kvSeparator];
         if (filterEmpty && ([k isEmpty] || [v isEmpty])) return;
         
         dictionary[k] = v;
     }];
    return AGX_AUTORELEASE([dictionary copy]);
}

#pragma mark - Merge Methods

+ (NSString *)stringWithArray:(NSArray *)array separator:(NSString *)separator filterEmpty:(BOOL)filterEmpty {
    if (AGX_EXPECT_F(!array)) return @"";
    
    NSMutableString *result = [NSMutableString string];
    for (int i = 0; i < [array count]; i++) {
        NSString *item = [[array objectAtIndex:i] description];
        if (filterEmpty && [item isEmpty]) continue;
        [result appendString:item];
        if (i + 1 < [array count]) [result appendString:separator];
    }
    return AGX_AUTORELEASE([result copy]);
}

+ (NSString *)stringWithDictionary:(NSDictionary *)dictionary separator:(NSString *)separator keyValueSeparator:(NSString *)kvSeparator filterEmpty:(BOOL)filterEmpty {
    if (AGX_EXPECT_F(!dictionary)) return @"";
    
    NSMutableArray *array = [NSMutableArray array];
    [dictionary enumerateKeysAndObjectsUsingBlock:
     ^(id  _Nonnull key, id  _Nonnull value, BOOL * _Nonnull stop) {
         NSString *k = [key description];
         NSString *v = [value description];
         if (filterEmpty && ([k isEmpty] || [v isEmpty])) return;
         
         [array addObject:[NSString stringWithFormat:@"%@%@%@", k, kvSeparator, v]];
     }];
    return [self stringWithArray:array separator:separator filterEmpty:filterEmpty];
}

#pragma mark - Append Methods

- (NSString *)appendWithObjects:(id)firstObj, ... NS_REQUIRES_NIL_TERMINATION {
    NSMutableArray *temp = [NSMutableArray arrayWithObjects:self, nil];
    
    if (firstObj) {
        id arg = firstObj;
        
        agx_va_start(firstObj);
        do {
            [temp addObject:arg];
        } while ((arg = va_arg(_argvs_, id)));
        agx_va_end;
    }
    
    return [NSString stringWithArray:temp separator:@"" filterEmpty:NO];
}

#pragma mark - Replace Methods

- (NSString *)stringByReplacingString:(NSString *)searchString withString:(NSString *)replacement {
    return [self stringByReplacingOccurrencesOfString:searchString withString:replacement
                                              options:0 range:NSMakeRange(0, self.length)];
}

- (NSString *)stringByReplacingCharactersInSet:(NSCharacterSet *)set withString:(NSString *)replacement mergeContinuous:(BOOL)mergeContinuous {
    return [NSString stringWithArray:[self arraySeparatedByCharactersInSet:set filterEmpty:mergeContinuous]
                           separator:replacement filterEmpty:NO];
}

#pragma mark - Escape/Unescape Methods

- (NSString *)stringByEscapingForURLQuery {
    return [self stringByAddingPercentEncodingWithAllowedCharacters:
            [NSCharacterSet characterSetWithCharactersInString:@":/=,!$&'()*+;[]@#?% "]];
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

- (NSString *)base64EncodedString  {
    if (AGX_EXPECT_F([self length] == 0)) return nil;
    return [[self dataUsingEncoding:NSUTF8StringEncoding] base64EncodedString];
}

+ (NSString *)stringWithBase64String:(NSString *)base64String {
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
        if (end == NSNotFound) break;
        NSString *value = [object valueForKey:[self substringWithRange:NSMakeRange(start, end)]];
        [result appendString:value?:@""];
        start += end + 1;
        end = [self indexOfString:@"${" fromIndex:start];
    }
    if (start < [self length])
        [result appendString:[self substringFromIndex:start]];
    return AGX_AUTORELEASE([result copy]);
}

#pragma mark - Size caculator

- (CGSize)agxSizeWithFont:(UIFont *)font constrainedToSize:(CGSize)size {
    return [self boundingRectWithSize:size options:NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading
                           attributes:@{ NSFontAttributeName:font } context:NULL].size;
}

@end

@category_implementation(NSString, AGXCoreCaseInsensitive)

#pragma mark - Compare Methods

- (BOOL)isCaseInsensitiveEqual:(id)object {
    if (object == self) return YES;
    if (!object || ![object isKindOfClass:[NSString class]]) return NO;
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
    return [self rangeOfString:aString options:NSCaseInsensitiveSearch].length > 0;
}

- (BOOL)containsCaseInsensitiveCharactersFromSet:(NSCharacterSet *)set {
    return [self rangeOfCharacterFromSet:set options:NSCaseInsensitiveSearch].length > 0;
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
    return [self rangeOfString:aString options:NSCaseInsensitiveSearch].location;
}

- (NSUInteger)indexOfCaseInsensitiveCharactersFromSet:(NSCharacterSet *)set {
    return [self rangeOfCharacterFromSet:set options:NSCaseInsensitiveSearch].location;
}

- (NSUInteger)lastIndexOfCaseInsensitiveString:(NSString *)aString {
    return [self rangeOfString:aString options:NSCaseInsensitiveSearch|NSBackwardsSearch].location;
}

- (NSUInteger)lastIndexOfCaseInsensitiveCharactersFromSet:(NSCharacterSet *)set {
    return [self rangeOfCharacterFromSet:set options:NSCaseInsensitiveSearch|NSBackwardsSearch].location;
}

#pragma mark - Sub Index Methods

- (NSUInteger)indexOfCaseInsensitiveString:(NSString *)aString fromIndex:(NSUInteger)startPos {
    return [[self substringFromIndex:startPos] rangeOfString:aString options:NSCaseInsensitiveSearch].location;
}

- (NSUInteger)indexOfCaseInsensitiveCharactersFromSet:(NSCharacterSet *)set fromIndex:(NSUInteger)startPos {
    return [[self substringFromIndex:startPos] rangeOfCharacterFromSet:set options:NSCaseInsensitiveSearch].location;
}

- (NSUInteger)lastIndexOfCaseInsensitiveString:(NSString *)aString fromIndex:(NSUInteger)startPos {
    return [[self substringToIndex:startPos] rangeOfString:aString options:NSCaseInsensitiveSearch|NSBackwardsSearch].location;
}

- (NSUInteger)lastIndexOfCaseInsensitiveCharactersFromSet:(NSCharacterSet *)set fromIndex:(NSUInteger)startPos {
    return [[self substringToIndex:startPos] rangeOfCharacterFromSet:set options:NSCaseInsensitiveSearch|NSBackwardsSearch].location;
}

#pragma mark - Sub String Methods

- (NSString *)substringFromFirstCaseInsensitiveString:(NSString *)aString {
    return [self containsCaseInsensitiveString:aString] ?
    [self substringFromIndex:[self indexOfCaseInsensitiveString:aString]] :
    AGX_AUTORELEASE([self copy]);
}

- (NSString *)substringFromFirstCaseInsensitiveCharactersFromSet:(NSCharacterSet *)set {
    return [self containsCaseInsensitiveCharactersFromSet:set] ?
    [self substringFromIndex:[self indexOfCaseInsensitiveCharactersFromSet:set]] :
    AGX_AUTORELEASE([self copy]);
}

- (NSString *)substringToFirstCaseInsensitiveString:(NSString *)aString {
    return [self containsCaseInsensitiveString:aString] ?
    [self substringToIndex:[self indexOfCaseInsensitiveString:aString]] :
    AGX_AUTORELEASE([self copy]);
}

- (NSString *)substringToFirstCaseInsensitiveCharactersFromSet:(NSCharacterSet *)set {
    return [self containsCaseInsensitiveCharactersFromSet:set] ?
    [self substringToIndex:[self indexOfCaseInsensitiveCharactersFromSet:set]] :
    AGX_AUTORELEASE([self copy]);
}

- (NSString *)substringFromLastCaseInsensitiveString:(NSString *)aString {
    return [self containsCaseInsensitiveString:aString] ?
    [self substringFromIndex:[self lastIndexOfCaseInsensitiveString:aString]] :
    AGX_AUTORELEASE([self copy]);
}

- (NSString *)substringFromLastCaseInsensitiveCharactersFromSet:(NSCharacterSet *)set {
    return [self containsCaseInsensitiveCharactersFromSet:set] ?
    [self substringFromIndex:[self lastIndexOfCaseInsensitiveCharactersFromSet:set]] :
    AGX_AUTORELEASE([self copy]);
}

- (NSString *)substringToLastCaseInsensitiveString:(NSString *)aString {
    return [self containsCaseInsensitiveString:aString] ?
    [self substringToIndex:[self lastIndexOfCaseInsensitiveString:aString]] :
    AGX_AUTORELEASE([self copy]);
}

- (NSString *)substringToLastCaseInsensitiveCharactersFromSet:(NSCharacterSet *)set {
    return [self containsCaseInsensitiveCharactersFromSet:set] ?
    [self substringToIndex:[self lastIndexOfCaseInsensitiveCharactersFromSet:set]] :
    AGX_AUTORELEASE([self copy]);
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

+ (AGX_INSTANCETYPE)AGXCoreSafe_stringWithUTF8String:(const char *)nullTerminatedCString {
    if (AGX_EXPECT_F(!nullTerminatedCString)) return nil;
    return [self AGXCoreSafe_stringWithUTF8String:nullTerminatedCString];
}

- (AGX_INSTANCETYPE)AGXCoreSafe_initWithUTF8String:(const char *)nullTerminatedCString {
    if (AGX_EXPECT_F(!nullTerminatedCString)) return nil;
    return [self AGXCoreSafe_initWithUTF8String:nullTerminatedCString];
}

+ (AGX_INSTANCETYPE)AGXCoreSafe_stringWithCString:(const char *)cString encoding:(NSStringEncoding)enc {
    if (AGX_EXPECT_F(!cString)) return nil;
    return [self AGXCoreSafe_stringWithCString:cString encoding:enc];
}

- (AGX_INSTANCETYPE)AGXCoreSafe_initWithCString:(const char *)nullTerminatedCString encoding:(NSStringEncoding)encoding {
    if (AGX_EXPECT_F(!nullTerminatedCString)) return nil;
    return [self AGXCoreSafe_initWithCString:nullTerminatedCString encoding:encoding];
}

+ (void)load {
    static dispatch_once_t once_t;
    dispatch_once(&once_t, ^{
        [self swizzleClassOriSelector:@selector(stringWithUTF8String:)
                      withNewSelector:@selector(AGXCoreSafe_stringWithUTF8String:)];
        [self swizzleInstanceOriSelector:@selector(initWithUTF8String:)
                         withNewSelector:@selector(AGXCoreSafe_initWithUTF8String:)];
        [self swizzleClassOriSelector:@selector(stringWithCString:encoding:)
                      withNewSelector:@selector(AGXCoreSafe_stringWithCString:encoding:)];
        [self swizzleInstanceOriSelector:@selector(initWithCString:encoding:)
                         withNewSelector:@selector(AGXCoreSafe_initWithCString:encoding:)];
    });
}

@end
