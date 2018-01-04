//
//  AGXKeychain.m
//  AGXData
//
//  Created by Char Aznable on 2016/2/22.
//  Copyright © 2016年 AI-CUC-EC. All rights reserved.
//

//
//  Modify from:
//  SFHFKeychainUtils
//

//  Created by Buzz Andersen on 10/20/08.
//  Based partly on code by Jonathan Wight, Jon Crosby, and Mike Malone.
//  Copyright 2008 Sci-Fi Hi-Fi. All rights reserved.
//
//  Permission is hereby granted, free of charge, to any person
//  obtaining a copy of this software and associated documentation
//  files (the "Software"), to deal in the Software without
//  restriction, including without limitation the rights to use,
//  copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the
//  Software is furnished to do so, subject to the following
//  conditions:
//
//  The above copyright notice and this permission notice shall be
//  included in all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
//  EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
//  OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
//  NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
//  HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
//  WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
//  FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
//  OTHER DEALINGS IN THE SOFTWARE.

#import <Security/Security.h>
#import <AGXCore/AGXCore/AGXArc.h>
#import <AGXCore/AGXCore/NSString+AGXCore.h>
#import "AGXKeychain.h"

#define AGXKeychainErrorExpect(condition, errorCondition, error, errorCode, errorReturn)                \
if AGX_EXPECT_F(condition) {                                                                            \
    if AGX_EXPECT_T(errorCondition)                                                                     \
        *(error) = [NSError errorWithDomain:@"AGXKeychainErrorDomain" code:(errorCode) userInfo:nil];   \
    return(errorReturn);                                                                                \
}

#define AGXKeychainErrorExpectDefault(condition, error, errorCode, errorReturn)                         \
AGXKeychainErrorExpect(condition, (error) != nil, error, errorCode, errorReturn)

@implementation AGXKeychain

+ (NSString *)passwordForUsername:(NSString *)username andService:(NSString *)service error:(NSError **)error {
    AGXKeychainErrorExpectDefault(!username || !service, error, -2000, nil)

    if AGX_EXPECT_T(error) *error = nil;
    NSDictionary *query = @{(NSString *)kSecClass : (NSString *)kSecClassGenericPassword,
                            (NSString *)kSecAttrAccount : username,
                            (NSString *)kSecAttrService : service};
    NSMutableDictionary *attributeQuery = [query mutableCopy];
    [attributeQuery setObject:(id)kCFBooleanTrue forKey:(id)kSecReturnAttributes];
    CFTypeRef attributeResultRef = NULL;
    OSStatus status = SecItemCopyMatching((CFDictionaryRef)attributeQuery, &attributeResultRef);
    AGX_RELEASE((AGX_BRIDGE_TRANSFER id)attributeResultRef);
    AGX_RELEASE(attributeQuery);
    AGXKeychainErrorExpect(status != noErr, (error) != nil && status != errSecItemNotFound, error, status, nil)

    NSMutableDictionary *passwordQuery = [query mutableCopy];
    [passwordQuery setObject:(id)kCFBooleanTrue forKey:(id)kSecReturnData];
    CFTypeRef resultDataRef = NULL;
    status = SecItemCopyMatching((CFDictionaryRef)passwordQuery, &resultDataRef);
    NSData *resultData = AGX_AUTORELEASE((AGX_BRIDGE_TRANSFER NSData *)resultDataRef);
    AGX_RELEASE(passwordQuery);
    AGXKeychainErrorExpectDefault(status != noErr, error, errSecItemNotFound == status ? -1999 : status, nil)
    AGXKeychainErrorExpectDefault(!resultData, error, -1999, nil)

    return [NSString stringWithData:resultData encoding:NSUTF8StringEncoding];
}

+ (BOOL)storePassword:(NSString *)password forUsername:(NSString *)username andService:(NSString *)service updateExisting:(BOOL)updateExisting error:(NSError **)error {
    AGXKeychainErrorExpectDefault(!password || !username || !service, error, -2000, NO)

    NSError *existingError = nil;
    NSString *existingPassword = [self passwordForUsername:username andService:service error:&existingError];
    if (-1999 == existingError.code) {
        existingError = nil;
        [self deletePasswordForUsername:username andService:service error:&existingError];
        if AGX_EXPECT_F(existingError.code != noErr) {
            if AGX_EXPECT_T(error) *error = existingError;
            return NO;
        }
    } else if ([existingError code] != noErr) {
        if AGX_EXPECT_T(error) *error = existingError;
        return NO;
    }

    if AGX_EXPECT_T(error) *error = nil;
    OSStatus status = noErr;
    if (existingPassword) {
        if (![existingPassword isEqualToString:password] && updateExisting) {
            NSDictionary *query = @{(NSString *)kSecClass : (NSString *)kSecClassGenericPassword,
                                    (NSString *)kSecAttrService : service,
                                    (NSString *)kSecAttrLabel : service,
                                    (NSString *)kSecAttrAccount : username};
            NSDictionary *sec = @{(NSString *)kSecValueData : [password dataUsingEncoding:NSUTF8StringEncoding]};
            status = SecItemUpdate((CFDictionaryRef)query, (CFDictionaryRef)sec);
        }
    } else {
        NSDictionary *query = @{(NSString *)kSecClass : (NSString *)kSecClassGenericPassword,
                                (NSString *)kSecAttrService : service,
                                (NSString *)kSecAttrLabel : service,
                                (NSString *)kSecAttrAccount : username,
                                (NSString *)kSecValueData : [password dataUsingEncoding:NSUTF8StringEncoding]};
        status = SecItemAdd((CFDictionaryRef)query, NULL);
    }

    AGXKeychainErrorExpectDefault(status != noErr, error, status, NO)
    return YES;
}

+ (BOOL)deletePasswordForUsername:(NSString *)username andService:(NSString *)service error:(NSError **)error {
    AGXKeychainErrorExpectDefault(!username || !service, error, -2000, NO)

    if AGX_EXPECT_T(error) *error = nil;
    NSDictionary *query = @{(NSString *)kSecClass : (NSString *)kSecClassGenericPassword,
                            (NSString *)kSecAttrAccount : username,
                            (NSString *)kSecAttrService : service,
                            (NSString *)kSecReturnAttributes : (id)kCFBooleanTrue};
    OSStatus status = SecItemDelete((CFDictionaryRef)query);
    AGXKeychainErrorExpectDefault(status != noErr, error, status, NO)
    return YES;
}

@end

#undef AGXKeychainErrorExpectDefault
#undef AGXKeychainErrorExpect
