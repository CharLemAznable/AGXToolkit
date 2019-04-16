//
//  NSData+AGXCore.m
//  AGXCore
//
//  Created by Char Aznable on 2016/2/4.
//  Copyright © 2016 github.com/CharLemAznable. All rights reserved.
//

#import <CommonCrypto/CommonDigest.h>
#import <CommonCrypto/CommonCryptor.h>
#import "NSData+AGXCore.h"
#import "AGXArc.h"
#import "NSString+AGXCore.h"

AGX_STATIC const char _base64EncodingTable[64] = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/";
AGX_STATIC const short _base64DecodingTable[256] = {
    -2, -2, -2, -2, -2, -2, -2, -2, -2, -1, -1, -2, -1, -1, -2, -2,
    -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2,
    -1, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, 62, -2, -2, -2, 63,
    52, 53, 54, 55, 56, 57, 58, 59, 60, 61, -2, -2, -2, -2, -2, -2,
    -2,  0,  1,  2,  3,  4,  5,  6,  7,  8,  9, 10, 11, 12, 13, 14,
    15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, -2, -2, -2, -2, -2,
    -2, 26, 27, 28, 29, 30, 31, 32, 33, 34, 35, 36, 37, 38, 39, 40,
    41, 42, 43, 44, 45, 46, 47, 48, 49, 50, 51, -2, -2, -2, -2, -2,
    -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2,
    -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2,
    -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2,
    -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2,
    -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2,
    -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2,
    -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2,
    -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2
};

@category_implementation(NSData, AGXCore)

// Adapted from http://www.cocoadev.com/index.pl?BaseSixtyFour
- (NSString *)base64EncodedString {
    const uint8_t *input = self.bytes;
    NSInteger length = self.length;

    NSMutableData *data = [NSMutableData dataWithLength:((length + 2) / 3) * 4];
    uint8_t *output = (uint8_t *)data.mutableBytes;

    for (NSInteger i = 0; i < length; i += 3) {
        NSInteger value = 0;
        for (NSInteger j = i; j < (i + 3); j++) {
            value <<= 8;
            if AGX_EXPECT_T(j < length) {
                value |= (0xFF & input[j]);
            }
        }

        NSInteger index = (i / 3) * 4;
        output[index + 0] = _base64EncodingTable[(value >> 18) & 0x3F];
        output[index + 1] = _base64EncodingTable[(value >> 12) & 0x3F];
        output[index + 2] = (i + 1) < length ? _base64EncodingTable[(value >> 6) & 0x3F] : '=';
        output[index + 3] = (i + 2) < length ? _base64EncodingTable[(value >> 0) & 0x3F] : '=';
    }

    return [NSString stringWithData:data encoding:NSASCIIStringEncoding];
}

// Adapted from http://www.cocoadev.com/index.pl?BaseSixtyFour
+ (AGX_INSTANCETYPE)dataWithBase64String:(NSString *)base64String {
    const char *string = [base64String cStringUsingEncoding:NSASCIIStringEncoding];
    NSInteger inputLength = base64String.length;

    if AGX_EXPECT_F(NULL == string/* || inputLength % 4 != 0*/) {
        return nil;
    }

    while (inputLength > 0 && '=' == string[inputLength - 1]) {
        inputLength--;
    }

    NSInteger outputLength = inputLength * 3 / 4;
    NSMutableData *data = [NSMutableData dataWithLength:outputLength];
    uint8_t *output = data.mutableBytes;

    NSInteger inputPoint = 0;
    NSInteger outputPoint = 0;
    while (inputPoint < inputLength) {
        char i0 = string[inputPoint++];
        char i1 = string[inputPoint++];
        char i2 = inputPoint < inputLength ? string[inputPoint++] : 'A'; /* 'A' will decode to \0 */
        char i3 = inputPoint < inputLength ? string[inputPoint++] : 'A';

        output[outputPoint++] = (_base64DecodingTable[i0] << 2) | (_base64DecodingTable[i1] >> 4);
        if (outputPoint < outputLength) {
            output[outputPoint++] = ((_base64DecodingTable[i1] & 0xf) << 4) | (_base64DecodingTable[i2] >> 2);
        }
        if (outputPoint < outputLength) {
            output[outputPoint++] = ((_base64DecodingTable[i2] & 0x3) << 6) | _base64DecodingTable[i3];
        }
    }

    return [self dataWithData:data];
}

- (NSString *)MD5Sum {
    unsigned char digest[CC_MD5_DIGEST_LENGTH], i;
    CC_MD5(self.bytes, (unsigned int)self.length, digest);
    NSMutableString *ms = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH * 2];
    for (i = 0; i < CC_MD5_DIGEST_LENGTH; i++) {
        [ms appendFormat:@"%02x", digest[i]];
    }
    return AGX_AUTORELEASE([ms copy]);
}

- (NSString *)SHA1Sum {
    unsigned char digest[CC_SHA1_DIGEST_LENGTH], i;
    CC_SHA1(self.bytes, (unsigned int)self.length, digest);
    NSMutableString *ms = [NSMutableString stringWithCapacity:CC_SHA1_DIGEST_LENGTH * 2];
    for (i = 0; i < CC_SHA1_DIGEST_LENGTH; i++) {
        [ms appendFormat:@"%02x", digest[i]];
    }
    return AGX_AUTORELEASE([ms copy]);
}

- (NSData *)AES256EncryptedDataUsingKey:(NSString *)key {
    char keyPtr[kCCKeySizeAES256 + 1];
    memset(keyPtr, 0, sizeof(keyPtr));
    [key getCString:keyPtr maxLength:sizeof(keyPtr) encoding:NSUTF8StringEncoding];

    NSUInteger dataLength = self.length;
    size_t bufferSize = dataLength + kCCBlockSizeAES128;
    void *buffer = malloc(bufferSize);

    size_t numBytesEncrypted = 0;
    CCCryptorStatus cryptStatus = CCCrypt(kCCEncrypt,
                                          kCCAlgorithmAES128,
                                          kCCOptionPKCS7Padding|kCCOptionECBMode,
                                          keyPtr,
                                          kCCBlockSizeAES128,
                                          NULL,
                                          self.bytes,
                                          dataLength,
                                          buffer,
                                          bufferSize,
                                          &numBytesEncrypted);

    if AGX_EXPECT_T(kCCSuccess == cryptStatus) {
        return [NSData dataWithBytesNoCopy:buffer length:numBytesEncrypted];
    }
    free(buffer);
    return nil;
}

- (NSData *)AES256DecryptedDataUsingKey:(NSString *)key {
    char keyPtr[kCCKeySizeAES256 + 1];
    memset(keyPtr, 0, sizeof(keyPtr));
    [key getCString:keyPtr maxLength:sizeof(keyPtr) encoding:NSUTF8StringEncoding];

    NSUInteger dataLength = self.length;
    size_t bufferSize = dataLength + kCCBlockSizeAES128;
    void *buffer = malloc(bufferSize);

    size_t numBytesDecrypted = 0;
    CCCryptorStatus cryptStatus = CCCrypt(kCCDecrypt,
                                          kCCAlgorithmAES128,
                                          kCCOptionPKCS7Padding|kCCOptionECBMode,
                                          keyPtr,
                                          kCCBlockSizeAES128,
                                          NULL,
                                          self.bytes,
                                          dataLength,
                                          buffer,
                                          bufferSize,
                                          &numBytesDecrypted);

    if AGX_EXPECT_T(kCCSuccess == cryptStatus) {
        return [NSData dataWithBytesNoCopy:buffer length:numBytesDecrypted];
    }
    free(buffer);
    return nil;
}

- (id)objectFromPlist {
    return [NSPropertyListSerialization propertyListWithData:self options:NSPropertyListImmutable format:NULL error:NULL];
}

@end
