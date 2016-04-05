//
//  AGXKeychain.m
//  AGXData
//
//  Created by Char Aznable on 16/2/22.
//  Copyright © 2016年 AI-CUC-EC. All rights reserved.
//

#import "AGXKeychain.h"
#import <Security/Security.h>
#import <AGXCore/AGXCore/AGXObjC.h>
#import <AGXCore/AGXCore/AGXArc.h>

#define AGXKeychainErrorExpect(condition, errorCondition, error, errorCode, errorReturn)                \
if (AGX_EXPECT_F(condition)) {                                                                          \
    if (errorCondition)                                                                                 \
        *(error) = [NSError errorWithDomain:@"AGXKeychainErrorDomain" code:(errorCode) userInfo:nil];   \
    return (errorReturn);                                                                               \
}

#define AGXKeychainErrorExpectDefault(condition, error, errorCode, errorReturn)                         \
AGXKeychainErrorExpect(condition, (error) != nil, error, errorCode, errorReturn)

@implementation AGXKeychain

+ (NSString *)passwordForUsername:(NSString *)username andService:(NSString *)service error:(NSError **)error {
    AGXKeychainErrorExpectDefault(!username || !service, error, -2000, nil)
    
    if (error != nil) *error = nil;
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
    AGXKeychainErrorExpectDefault(status != noErr, error, status == errSecItemNotFound ? -1999 : status, nil)
    AGXKeychainErrorExpectDefault(!resultData, error, -1999, nil)
    
    return AGX_AUTORELEASE([[NSString alloc] initWithData:resultData encoding:NSUTF8StringEncoding]);
}

+ (BOOL)storePassword:(NSString *)password forUsername:(NSString *)username andService:(NSString *)service updateExisting:(BOOL)updateExisting error:(NSError **)error {
    AGXKeychainErrorExpectDefault(!password || !username || !service, error, -2000, NO)
    
    NSError *existingError = nil;
    NSString *existingPassword = [self passwordForUsername:username andService:service error:&existingError];
    if (existingError.code == -1999) {
        existingError = nil;
        [self deletePasswordForUsername:username andService:service error:&existingError];
        if (existingError.code != noErr) {
            if (error != nil) *error = existingError;
            return NO;
        }
    } else if ([existingError code] != noErr) {
        if (error != nil) *error = existingError;
        return NO;
    }
    
    if (error != nil) *error = nil;
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
    
    if (error != nil) *error = nil;
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
