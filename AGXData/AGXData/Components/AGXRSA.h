//
//  AGXRSA.h
//  AGXData
//
//  Created by Char on 2018/10/22.
//  Copyright © 2018年 AI-CUC-EC. All rights reserved.
//

//
//  Modify from:
//  Flying-Einstein/Encryptions
//  https://github.com/Flying-Einstein/Encryptions
//

#ifndef AGXData_AGXRSA_h
#define AGXData_AGXRSA_h

#import <Foundation/Foundation.h>

@interface AGXRSA : NSObject
// return raw data
+ (NSData *)encryptData:(NSData *)data publicKey:(NSString *)pubKey;
// return base64 encoded string
+ (NSString *)encryptString:(NSString *)str publicKey:(NSString *)pubKey;

//// enc with private key NOT working YET!
//// return raw data
//+ (NSData *)encryptData:(NSData *)data privateKey:(NSString *)prvKey;
//// return base64 encoded string
//+ (NSString *)encryptString:(NSString *)str privateKey:(NSString *)prvKey;
//
//+ (NSData *)decryptData:(NSData *)data publicKey:(NSString *)pubKey;
//// decrypt base64 encoded string, convert result to string(not base64 encoded)
//+ (NSString *)decryptString:(NSString *)str publicKey:(NSString *)pubKey;

+ (NSData *)decryptData:(NSData *)data privateKey:(NSString *)prvKey;
// decrypt base64 encoded string, convert result to string(not base64 encoded)
+ (NSString *)decryptString:(NSString *)str privateKey:(NSString *)prvKey;

// return raw data
+ (NSData *)signSHA1Data:(NSData *)data privateKey:(NSString *)prvKey;
// return base64 encoded string
+ (NSString *)signSHA1String:(NSString *)str privateKey:(NSString *)prvKey;

+ (BOOL)verifySHA1Data:(NSData *)data signData:(NSData *)signData publicKey:(NSString *)pubKey;
// verify plain string
+ (BOOL)verifySHA1String:(NSString *)str signString:(NSString *)signString publicKey:(NSString *)pubKey;
@end

#endif /* AGXData_AGXRSA_h */
