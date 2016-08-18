//
//  AGXQRCodeBitMatrixParser.m
//  AGXGcode
//
//  Created by Char Aznable on 16/8/8.
//  Copyright © 2016年 AI-CUC-EC. All rights reserved.
//

//
//  Modify from:
//  TheLevelUp/ZXingObjC
//

//
//  Copyright 2014 ZXing authors
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//      http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//

#import <AGXCore/AGXCore/AGXArc.h>
#import "AGXQRCodeBitMatrixParser.h"
#import "AGXGcodeError.h"
#import "AGXQRCodeDataMask.h"

@implementation AGXQRCodeBitMatrixParser {
    AGXBitMatrix *_bitMatrix;
    BOOL _shouldMirror;
    AGXQRCodeFormatInformation *_parsedFormatInfo;
    AGXQRCodeVersion *_parsedVersion;
}

+ (AGX_INSTANCETYPE)parserWithBitMatrix:(AGXBitMatrix *)bitMatrix error:(NSError **)error {
    int dimension = bitMatrix.height;
    if (dimension < 21 || (dimension & 0x03) != 1) {
        if (error) *error = AGXFormatErrorInstance();
        return nil;
    }
    return AGX_AUTORELEASE([[self alloc] initWithBitMatrix:bitMatrix]);
}

- (AGX_INSTANCETYPE)initWithBitMatrix:(AGXBitMatrix *)bitMatrix {
    if (self = [super init]) {
        _bitMatrix = AGX_RETAIN(bitMatrix);
        _parsedFormatInfo = nil;
        _parsedVersion = nil;
    }
    return self;
}

- (void)dealloc {
    AGX_RELEASE(_bitMatrix);
    AGX_RELEASE(_parsedFormatInfo);
    AGX_RELEASE(_parsedVersion);
    AGX_SUPER_DEALLOC;
}

- (AGXQRCodeFormatInformation *)readFormatInformationWithError:(NSError **)error {
    if (_parsedFormatInfo != nil) return _parsedFormatInfo;

    int formatInfoBits1 = 0;
    for (int i = 0; i < 6; i++) {
        formatInfoBits1 = [self copyBit:i j:8 versionBits:formatInfoBits1];
    }
    formatInfoBits1 = [self copyBit:7 j:8 versionBits:formatInfoBits1];
    formatInfoBits1 = [self copyBit:8 j:8 versionBits:formatInfoBits1];
    formatInfoBits1 = [self copyBit:8 j:7 versionBits:formatInfoBits1];
    for (int j = 5; j >= 0; j--) {
        formatInfoBits1 = [self copyBit:8 j:j versionBits:formatInfoBits1];
    }

    int dimension = _bitMatrix.height;
    int formatInfoBits2 = 0;
    int jMin = dimension - 7;

    for (int j = dimension - 1; j >= jMin; j--) {
        formatInfoBits2 = [self copyBit:8 j:j versionBits:formatInfoBits2];
    }
    for (int i = dimension - 8; i < dimension; i++) {
        formatInfoBits2 = [self copyBit:i j:8 versionBits:formatInfoBits2];
    }
    _parsedFormatInfo = AGX_RETAIN([AGXQRCodeFormatInformation decodeFormatInformation:formatInfoBits1 maskedFormatInfo2:formatInfoBits2]);
    if (_parsedFormatInfo) return _parsedFormatInfo;

    if (error) *error = AGXFormatErrorInstance();
    return nil;
}

- (AGXQRCodeVersion *)readVersionWithError:(NSError **)error {
    if (_parsedVersion != nil) return _parsedVersion;

    int dimension = _bitMatrix.height;
    int provisionalVersion = (dimension - 17) / 4;
    if (provisionalVersion <= 6) {
        return [AGXQRCodeVersion versionForNumber:provisionalVersion];
    }

    int versionBits = 0;
    int ijMin = dimension - 11;
    for (int j = 5; j >= 0; j--) {
        for (int i = dimension - 9; i >= ijMin; i--) {
            versionBits = [self copyBit:i j:j versionBits:versionBits];
        }
    }
    AGXQRCodeVersion *theParsedVersion = [AGXQRCodeVersion decodeVersionInformation:versionBits];
    if (theParsedVersion != nil && theParsedVersion.dimensionForVersion == dimension) {
        _parsedVersion = AGX_RETAIN(theParsedVersion);
        return _parsedVersion;
    }

    versionBits = 0;
    for (int i = 5; i >= 0; i--) {
        for (int j = dimension - 9; j >= ijMin; j--) {
            versionBits = [self copyBit:i j:j versionBits:versionBits];
        }
    }
    theParsedVersion = [AGXQRCodeVersion decodeVersionInformation:versionBits];
    if (theParsedVersion != nil && theParsedVersion.dimensionForVersion == dimension) {
        _parsedVersion = AGX_RETAIN(theParsedVersion);
        return _parsedVersion;
    }
    if (error) *error = AGXFormatErrorInstance();
    return nil;
}

- (int)copyBit:(int)i j:(int)j versionBits:(int)versionBits {
    BOOL bit = _shouldMirror ? [_bitMatrix getX:j y:i] : [_bitMatrix getX:i y:j];
    return bit ? (versionBits << 1) | 0x1 : versionBits << 1;
}

- (AGXByteArray *)readCodewordsWithError:(NSError **)error {
    AGXQRCodeFormatInformation *formatInfo = [self readFormatInformationWithError:error];
    if (!formatInfo) return nil;

    AGXQRCodeVersion *version = [self readVersionWithError:error];
    if (!version) return nil;

    // Get the data mask for the format used in this QR Code. This will exclude
    // some bits from reading as we wind through the bit matrix.
    AGXQRCodeDataMask *dataMask = [AGXQRCodeDataMask forReference:[formatInfo dataMask]];
    int dimension = _bitMatrix.height;
    [dataMask unmaskBitMatrix:_bitMatrix dimension:dimension];

    AGXBitMatrix *functionPattern = [version buildFunctionPattern];

    BOOL readingUp = YES;
    AGXByteArray *result = [AGXByteArray byteArrayWithLength:version.totalCodewords];
    int resultOffset = 0;
    int currentByte = 0;
    int bitsRead = 0;
    // Read columns in pairs, from right to left
    for (int j = dimension - 1; j > 0; j -= 2) {
        if (j == 6) {
            // Skip whole column with vertical alignment pattern;
            // saves time and makes the other code proceed more cleanly
            j--;
        }
        // Read alternatingly from bottom to top then top to bottom
        for (int count = 0; count < dimension; count++) {
            int i = readingUp ? dimension - 1 - count : count;
            for (int col = 0; col < 2; col++) {
                // Ignore bits covered by the function pattern
                if (![functionPattern getX:j - col y:i]) {
                    // Read a bit
                    bitsRead++;
                    currentByte <<= 1;
                    if ([_bitMatrix getX:j - col y:i]) {
                        currentByte |= 1;
                    }
                    // If we've made a whole byte, save it off
                    if (bitsRead == 8) {
                        result.array[resultOffset++] = (int8_t) currentByte;
                        bitsRead = 0;
                        currentByte = 0;
                    }
                }
            }
        }
        readingUp ^= YES; // readingUp = !readingUp; // switch directions
    }
    if (resultOffset != [version totalCodewords]) {
        if (error) *error = AGXFormatErrorInstance();
        return nil;
    }
    return result;
}

- (void)remask {
    if (!_parsedFormatInfo) return; // We have no format information, and have no data mask

    AGXQRCodeDataMask *dataMask = [AGXQRCodeDataMask forReference:_parsedFormatInfo.dataMask];
    [dataMask unmaskBitMatrix:_bitMatrix dimension:_bitMatrix.height];
}

- (void)setMirror:(BOOL)mirror {
    AGX_RELEASE(_parsedFormatInfo);
    _parsedFormatInfo = nil;
    AGX_RELEASE(_parsedVersion);
    _parsedVersion = nil;
    _shouldMirror = mirror;
}

- (void)mirror {
    for (int x = 0; x < _bitMatrix.width; x++) {
        for (int y = x + 1; y < _bitMatrix.height; y++) {
            if ([_bitMatrix getX:x y:y] != [_bitMatrix getX:y y:x]) {
                [_bitMatrix flipX:y y:x];
                [_bitMatrix flipX:x y:y];
            }
        }
    }
}

@end
