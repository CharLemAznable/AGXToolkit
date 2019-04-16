//
//  AGXRSA.m
//  AGXCore
//
//  Created by Char on 2018/10/22.
//  Copyright © 2018 github.com/CharLemAznable. All rights reserved.
//

#import <CommonCrypto/CommonDigest.h>
#import <Security/Security.h>
#import <AGXCore/AGXCore/NSData+AGXCore.h>
#import <AGXCore/AGXCore/NSString+AGXCore.h>
#import "AGXRSA.h"

@implementation AGXRSA

+ (NSData *)encryptData:(NSData *)data publicKey:(NSString *)pubKey{
    if (!data || !pubKey) return nil;
    SecKeyRef keyRef = [AGXRSA publicKeyFromString:pubKey];
    if (!keyRef) return nil;
    return [AGXRSA encryptData:data withKeyRef:keyRef];
}

+ (NSString *)encryptString:(NSString *)str publicKey:(NSString *)pubKey{
    NSData *data = [AGXRSA encryptData:[str dataUsingEncoding:NSUTF8StringEncoding] publicKey:pubKey];
    return data.base64EncodedString;
}

//+ (NSData *)encryptData:(NSData *)data privateKey:(NSString *)prvKey{
//    if (!data || !prvKey) return nil;
//    SecKeyRef keyRef = [AGXRSA privateKeyFromString:prvKey];
//    if (!keyRef) return nil;
//    return [AGXRSA encryptData:data withKeyRef:keyRef];
//}

//+ (NSString *)encryptString:(NSString *)str privateKey:(NSString *)prvKey{
//    NSData *data = [AGXRSA encryptData:[str dataUsingEncoding:NSUTF8StringEncoding] privateKey:prvKey];
//    return data.base64EncodedString;
//}

//+ (NSData *)decryptData:(NSData *)data publicKey:(NSString *)pubKey{
//    if (!data || !pubKey) return nil;
//    SecKeyRef keyRef = [AGXRSA publicKeyFromString:pubKey];
//    if (!keyRef) return nil;
//    return [AGXRSA decryptData:data withKeyRef:keyRef];
//}

//+ (NSString *)decryptString:(NSString *)str publicKey:(NSString *)pubKey{
//    NSData *data = [NSData dataWithBase64String:str];
//    data = [AGXRSA decryptData:data publicKey:pubKey];
//    return [NSString stringWithData:data encoding:NSUTF8StringEncoding];
//}

+ (NSData *)decryptData:(NSData *)data privateKey:(NSString *)prvKey{
    if (!data || !prvKey) return nil;
    SecKeyRef keyRef = [AGXRSA privateKeyFromString:prvKey];
    if (!keyRef) return nil;
    return [AGXRSA decryptData:data withKeyRef:keyRef];
}

+ (NSString *)decryptString:(NSString *)str privateKey:(NSString *)prvKey{
    NSData *data = [NSData dataWithBase64String:str];
    data = [AGXRSA decryptData:data privateKey:prvKey];
    return [NSString stringWithData:data encoding:NSUTF8StringEncoding];
}

+ (NSData *)signSHA1Data:(NSData *)data privateKey:(NSString *)prvKey {
    if (!data || !prvKey) return nil;
    SecKeyRef keyRef = [AGXRSA privateKeyFromString:prvKey];
    if (!keyRef) return nil;
    return [AGXRSA signSHA1Data:data withKeyRef:keyRef];
}

+ (NSString *)signSHA1String:(NSString *)str privateKey:(NSString *)prvKey {
    NSData *data = [AGXRSA signSHA1Data:[str dataUsingEncoding:NSUTF8StringEncoding] privateKey:prvKey];
    return data.base64EncodedString;
}

+ (BOOL)verifySHA1Data:(NSData *)data signData:(NSData *)signData publicKey:(NSString *)pubKey {
    if (!data || !signData || !pubKey) return NO;
    SecKeyRef keyRef = [AGXRSA publicKeyFromString:pubKey];
    if (!keyRef) return NO;
    return [AGXRSA verifySHA1Data:data signData:signData withKeyRef:keyRef];
}

+ (BOOL)verifySHA1String:(NSString *)str signString:(NSString *)signString publicKey:(NSString *)pubKey {
    NSData *data = [str dataUsingEncoding:NSUTF8StringEncoding];
    NSData *signData = [NSData dataWithBase64String:signString];
    return [AGXRSA verifySHA1Data:data signData:signData publicKey:pubKey];
}

#pragma mark - private methods

+ (NSData *)encryptData:(NSData *)data withKeyRef:(SecKeyRef)keyRef {
    const uint8_t *srcbuf = (const uint8_t *)[data bytes];
    size_t srclen = (size_t)data.length;

    size_t block_size = SecKeyGetBlockSize(keyRef) * sizeof(uint8_t);
    void *outbuf = malloc(block_size);
    size_t src_block_size = block_size - 11;

    NSMutableData *ret = [NSMutableData instance];
    for (int idx = 0; idx < srclen; idx += src_block_size) {
        size_t data_len = srclen - idx;
        if (data_len > src_block_size) {
            data_len = src_block_size;
        }

        size_t outlen = block_size;
        OSStatus status = noErr;
        status = SecKeyEncrypt(keyRef,
                               kSecPaddingPKCS1,
                               srcbuf + idx,
                               data_len,
                               outbuf,
                               &outlen
                               );
        if (status != 0) {
            AGXLog(@"SecKeyEncrypt fail. Error Code: %d", (int)status);
            ret = nil;
            break;
        } else {
            [ret appendBytes:outbuf length:outlen];
        }
    }

    free(outbuf);
    CFRelease(keyRef);
    return ret;
}

+ (NSData *)decryptData:(NSData *)data withKeyRef:(SecKeyRef)keyRef {
    const uint8_t *srcbuf = (const uint8_t *)[data bytes];
    size_t srclen = (size_t)data.length;

    size_t block_size = SecKeyGetBlockSize(keyRef) * sizeof(uint8_t);
    UInt8 *outbuf = malloc(block_size);
    size_t src_block_size = block_size;

    NSMutableData *ret = [NSMutableData instance];
    for (int idx = 0; idx < srclen; idx += src_block_size) {
        //NSLog(@"%d/%d block_size: %d", idx, (int)srclen, (int)block_size);
        size_t data_len = srclen - idx;
        if(data_len > src_block_size){
            data_len = src_block_size;
        }

        size_t outlen = block_size;
        OSStatus status = noErr;
        status = SecKeyDecrypt(keyRef,
                               kSecPaddingNone,
                               srcbuf + idx,
                               data_len,
                               outbuf,
                               &outlen
                               );
        if (status != 0) {
            NSLog(@"SecKeyEncrypt fail. Error Code: %d", (int)status);
            ret = nil;
            break;
        } else {
            //the actual decrypted data is in the middle, locate it!
            int idxFirstZero = -1;
            int idxNextZero = (int)outlen;
            for (int i = 0; i < outlen; i++) {
                if (outbuf[i] == 0) {
                    if (idxFirstZero < 0) {
                        idxFirstZero = i;
                    } else {
                        idxNextZero = i;
                        break;
                    }
                }
            }

            [ret appendBytes:&outbuf[idxFirstZero+1] length:idxNextZero-idxFirstZero-1];
        }
    }

    free(outbuf);
    CFRelease(keyRef);
    return ret;
}

+ (NSData *)signSHA1Data:(NSData *)data withKeyRef:(SecKeyRef)keyRef {
    size_t hashBytesSize = CC_SHA1_DIGEST_LENGTH;
    unsigned char hashBytes[CC_SHA1_DIGEST_LENGTH];
    AGX_CLANG_Diagnostic(-Wunused-variable, {
        unsigned char *res = CC_SHA1(data.bytes, (CC_LONG)data.length, hashBytes);
        NSAssert(res, @"SHA1 Failed");
    })

    size_t keySize = SecKeyGetBlockSize(keyRef) * sizeof(uint8_t);
    unsigned char *signedHashBytes = malloc(keySize);
    memset(signedHashBytes, 0, keySize);
    size_t signedHashBytesSize = keySize;

    AGX_CLANG_Diagnostic(-Wunused-variable, {
        OSStatus status = SecKeyRawSign(keyRef, kSecPaddingPKCS1SHA1, hashBytes, hashBytesSize, signedHashBytes, &signedHashBytesSize);
        NSAssert(status == noErr, @"Sign Failed");
    })

    NSData *resultData = [NSData dataWithBytes:signedHashBytes length:signedHashBytesSize];
    free(signedHashBytes);
    CFRelease(keyRef);
    return resultData;
}

+ (BOOL)verifySHA1Data:(NSData *)data signData:(NSData *)signData withKeyRef:(SecKeyRef)keyRef {
    size_t hashBytesSize = CC_SHA1_DIGEST_LENGTH;
    unsigned char hashBytes[CC_SHA1_DIGEST_LENGTH];
    AGX_CLANG_Diagnostic(-Wunused-variable, {
        unsigned char *res = CC_SHA1(data.bytes, (CC_LONG)data.length, hashBytes);
        NSAssert(res, @"SHA1 Failed");
    })

    OSStatus status = SecKeyRawVerify(keyRef, kSecPaddingPKCS1SHA1, hashBytes, hashBytesSize, signData.bytes, signData.length);
    CFRelease(keyRef);
    return(status == noErr);
}

+ (SecKeyRef)publicKeyFromString:(NSString *)key {
    NSRange spos = [key rangeOfString:@"-----BEGIN PUBLIC KEY-----"];
    NSRange epos = [key rangeOfString:@"-----END PUBLIC KEY-----"];
    if (spos.location != NSNotFound && epos.location != NSNotFound) {
        NSUInteger s = spos.location + spos.length;
        NSUInteger e = epos.location;
        NSRange range = NSMakeRange(s, e-s);
        key = [key substringWithRange:range];
    }
    key = [key stringByReplacingOccurrencesOfString:@"\r" withString:@""];
    key = [key stringByReplacingOccurrencesOfString:@"\n" withString:@""];
    key = [key stringByReplacingOccurrencesOfString:@"\t" withString:@""];
    key = [key stringByReplacingOccurrencesOfString:@" "  withString:@""];

    // This will be base64 encoded, decode it.
    NSData *data = [NSData dataWithBase64String:key];
    data = [AGXRSA stripPublicKeyHeader:data];
    if (!data) return nil;

    //a tag to read/write keychain storage
    NSString *tag = @"AGXRSA_PubKey";
    NSData *d_tag = [tag dataUsingEncoding:NSUTF8StringEncoding];

    NSMutableDictionary *publicKey = [NSMutableDictionary instance];
    [publicKey setObject:(__bridge id)kSecClassKey forKey:(__bridge id)kSecClass];
    [publicKey setObject:(__bridge id)kSecAttrKeyTypeRSA forKey:(__bridge id)kSecAttrKeyType];
    [publicKey setObject:d_tag forKey:(__bridge id)kSecAttrApplicationTag];

    [publicKey setObject:data forKey:(__bridge id)kSecValueData];
    [publicKey setObject:(__bridge id)kSecAttrKeyClassPublic forKey:(__bridge id)kSecAttrKeyClass];
    [publicKey setObject:[NSNumber numberWithBool:YES] forKey:(__bridge id)kSecReturnPersistentRef];

    // Delete any old lingering key with the same tag
    SecItemDelete((__bridge CFDictionaryRef)publicKey);

    // Add persistent version of the key to system keychain
    CFTypeRef persistKey = nil;
    OSStatus status = SecItemAdd((__bridge CFDictionaryRef)publicKey, &persistKey);
    if (persistKey != nil) {
        CFRelease(persistKey);
    }
    if ((status != noErr) && (status != errSecDuplicateItem)) {
        return nil;
    }

    [publicKey removeObjectForKey:(__bridge id)kSecValueData];
    [publicKey removeObjectForKey:(__bridge id)kSecReturnPersistentRef];
    [publicKey setObject:[NSNumber numberWithBool:YES] forKey:(__bridge id)kSecReturnRef];
    [publicKey setObject:(__bridge id)kSecAttrKeyTypeRSA forKey:(__bridge id)kSecAttrKeyType];

    // Now fetch the SecKeyRef version of the key
    SecKeyRef keyRef = nil;
    status = SecItemCopyMatching((__bridge CFDictionaryRef)publicKey, (CFTypeRef *)&keyRef);
    if (status != noErr) return nil;
    return keyRef;
}

+ (SecKeyRef)privateKeyFromString:(NSString *)key {
    NSRange spos = [key rangeOfString:@"-----BEGIN RSA PRIVATE KEY-----"];
    NSRange epos = [key rangeOfString:@"-----END RSA PRIVATE KEY-----"];
    if (spos.location != NSNotFound && epos.location != NSNotFound) {
        NSUInteger s = spos.location + spos.length;
        NSUInteger e = epos.location;
        NSRange range = NSMakeRange(s, e-s);
        key = [key substringWithRange:range];
    }
    key = [key stringByReplacingOccurrencesOfString:@"\r" withString:@""];
    key = [key stringByReplacingOccurrencesOfString:@"\n" withString:@""];
    key = [key stringByReplacingOccurrencesOfString:@"\t" withString:@""];
    key = [key stringByReplacingOccurrencesOfString:@" "  withString:@""];

    // This will be base64 encoded, decode it.
    NSData *data = [NSData dataWithBase64String:key];
    data = [AGXRSA stripPrivateKeyHeader:data];
    if (!data) return nil;

    //a tag to read/write keychain storage
    NSString *tag = @"AGXRSA_PrvKey";
    NSData *d_tag = [NSData dataWithBytes:[tag UTF8String] length:[tag length]];

    // Delete any old lingering key with the same tag
    NSMutableDictionary *privateKey = [NSMutableDictionary instance];
    [privateKey setObject:(__bridge id)kSecClassKey forKey:(__bridge id)kSecClass];
    [privateKey setObject:(__bridge id)kSecAttrKeyTypeRSA forKey:(__bridge id)kSecAttrKeyType];
    [privateKey setObject:d_tag forKey:(__bridge id)kSecAttrApplicationTag];
    SecItemDelete((__bridge CFDictionaryRef)privateKey);

    // Add persistent version of the key to system keychain
    [privateKey setObject:data forKey:(__bridge id)kSecValueData];
    [privateKey setObject:(__bridge id)kSecAttrKeyClassPrivate forKey:(__bridge id)kSecAttrKeyClass];
    [privateKey setObject:[NSNumber numberWithBool:YES] forKey:(__bridge id)kSecReturnPersistentRef];

    CFTypeRef persistKey = nil;
    OSStatus status = SecItemAdd((__bridge CFDictionaryRef)privateKey, &persistKey);
    if (persistKey != nil) {
        CFRelease(persistKey);
    }
    if ((status != noErr) && (status != errSecDuplicateItem)) {
        return nil;
    }

    [privateKey removeObjectForKey:(__bridge id)kSecValueData];
    [privateKey removeObjectForKey:(__bridge id)kSecReturnPersistentRef];
    [privateKey setObject:[NSNumber numberWithBool:YES] forKey:(__bridge id)kSecReturnRef];
    [privateKey setObject:(__bridge id)kSecAttrKeyTypeRSA forKey:(__bridge id)kSecAttrKeyType];

    // Now fetch the SecKeyRef version of the key
    SecKeyRef keyRef = nil;
    status = SecItemCopyMatching((__bridge CFDictionaryRef)privateKey, (CFTypeRef *)&keyRef);
    if (status != noErr) return nil;
    return keyRef;
}

+ (NSData *)stripPublicKeyHeader:(NSData *)d_key {
    // Skip ASN.1 public key header
    if (d_key == nil) return(nil);

    unsigned long len = [d_key length];
    if (!len) return(nil);

    unsigned char *c_key = (unsigned char *)[d_key bytes];
    unsigned int  idx    = 0;

    if (c_key[idx++] != 0x30) return(nil);

    if (c_key[idx] > 0x80) idx += c_key[idx] - 0x80 + 1;
    else idx++;

    // PKCS #1 rsaEncryption szOID_RSA_RSA
    static unsigned char seqiod[] =
    { 0x30, 0x0d, 0x06, 0x09, 0x2a, 0x86, 0x48, 0x86, 0xf7, 0x0d, 0x01, 0x01, 0x01, 0x05, 0x00 };
    if (memcmp(&c_key[idx], seqiod, 15)) return(nil);

    idx += 15;

    if (c_key[idx++] != 0x03) return(nil);

    if (c_key[idx] > 0x80) idx += c_key[idx] - 0x80 + 1;
    else idx++;

    if (c_key[idx++] != '\0') return(nil);

    // Now make a new NSData from this buffer
    return([NSData dataWithBytes:&c_key[idx] length:len - idx]);
}

//credit: http://hg.mozilla.org/services/fx-home/file/tip/Sources/NetworkAndStorage/CryptoUtils.m#l1036
+ (NSData *)stripPrivateKeyHeader:(NSData *)d_key {
    // Skip ASN.1 private key header
    if (d_key == nil) return(nil);

    unsigned long len = [d_key length];
    if (!len) return(nil);

    unsigned char *c_key = (unsigned char *)[d_key bytes];
    unsigned int  idx    = 22; //magic byte at offset 22

    if (0x04 != c_key[idx++]) return(nil);

    //calculate length of the key
    unsigned int c_len = c_key[idx++];
    int det = c_len & 0x80;
    if (!det) {
        c_len = c_len & 0x7f;
    } else {
        int byteCount = c_len & 0x7f;
        if (byteCount + idx > len) {
            //rsa length field longer than buffer
            return(nil);
        }
        unsigned int accum = 0;
        unsigned char *ptr = &c_key[idx];
        idx += byteCount;
        while (byteCount) {
            accum = (accum << 8) + *ptr;
            ptr++;
            byteCount--;
        }
        c_len = accum;
    }

    // Now make a new NSData from this buffer
    return([d_key subdataWithRange:NSMakeRange(idx, c_len)]);
}

@end
