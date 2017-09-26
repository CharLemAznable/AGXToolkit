//
//  AGXAztecDecoder.m
//  AGXGcode
//
//  Created by Char Aznable on 16/8/9.
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
#import "AGXAztecDecoder.h"
#import "AGXGcodeError.h"
#import "AGXBoolArray.h"
#import "AGXReedSolomonDecoder.h"

typedef enum {
    AGXAztecTableUpper = 0,
    AGXAztecTableLower,
    AGXAztecTableMixed,
    AGXAztecTableDigit,
    AGXAztecTablePunct,
    AGXAztecTableBinary
} AGXAztecTable;

static NSString *AGX_AZTEC_UPPER_TABLE[] = {
    @"CTRL_PS", @" ", @"A", @"B", @"C", @"D", @"E", @"F", @"G", @"H", @"I", @"J", @"K", @"L", @"M", @"N", @"O", @"P",
    @"Q", @"R", @"S", @"T", @"U", @"V", @"W", @"X", @"Y", @"Z", @"CTRL_LL", @"CTRL_ML", @"CTRL_DL", @"CTRL_BS"
};

static NSString *AGX_AZTEC_LOWER_TABLE[] = {
    @"CTRL_PS", @" ", @"a", @"b", @"c", @"d", @"e", @"f", @"g", @"h", @"i", @"j", @"k", @"l", @"m", @"n", @"o", @"p",
    @"q", @"r", @"s", @"t", @"u", @"v", @"w", @"x", @"y", @"z", @"CTRL_US", @"CTRL_ML", @"CTRL_DL", @"CTRL_BS"
};

static NSString *AGX_AZTEC_MIXED_TABLE[] = {
    @"CTRL_PS", @" ", @"\1", @"\2", @"\3", @"\4", @"\5", @"\6", @"\7", @"\b", @"\t", @"\n",
    @"\13", @"\f", @"\r", @"\33", @"\34", @"\35", @"\36", @"\37", @"@", @"\\", @"^", @"_",
    @"`", @"|", @"~", @"\177", @"CTRL_LL", @"CTRL_UL", @"CTRL_PL", @"CTRL_BS"
};

static NSString *AGX_AZTEC_PUNCT_TABLE[] = {
    @"", @"\r", @"\r\n", @". ", @", ", @": ", @"!", @"\"", @"#", @"$", @"%", @"&", @"'", @"(", @")",
    @"*", @"+", @",", @"-", @".", @"/", @":", @";", @"<", @"=", @">", @"?", @"[", @"]", @"{", @"}", @"CTRL_UL"
};

static NSString *AGX_AZTEC_DIGIT_TABLE[] = {
    @"CTRL_PS", @" ", @"0", @"1", @"2", @"3", @"4", @"5", @"6", @"7", @"8", @"9", @",", @".", @"CTRL_UL", @"CTRL_US"
};

@implementation AGXAztecDecoder {
    AGXAztecDetectorResult *_detectorResult;
}

- (AGXDecoderResult *)decode:(AGXAztecDetectorResult *)detectorResult error:(NSError **)error {
    _detectorResult = detectorResult;
    AGXBoolArray *rawbits = [self extractBits:detectorResult.bits];
    if AGX_EXPECT_F(!rawbits) {
        if AGX_EXPECT_T(error) *error = AGXFormatErrorInstance();
        return nil;
    }

    AGXBoolArray *correctedBits = [self correctBits:rawbits error:error];
    if AGX_EXPECT_F(!correctedBits) return nil;

    NSString *result = [self encodedData:correctedBits];
    return [AGXDecoderResult resultWithText:result ecLevel:nil];
}

- (AGXBoolArray *)extractBits:(AGXBitMatrix *)matrix {
    BOOL compact = _detectorResult.isCompact;
    int layers = _detectorResult.nbLayers;
    int baseMatrixSize = compact ? 11 + layers * 4 : 14 + layers * 4; // not including alignment lines
    AGXIntArray *alignmentMap = [AGXIntArray intArrayWithLength:baseMatrixSize];
    AGXBoolArray *rawbits = [AGXBoolArray boolArrayWithLength:[self totalBitsInLayer:layers compact:compact]];

    if (compact) {
        for (int i = 0; i < alignmentMap.length; i++) {
            alignmentMap.array[i] = i;
        }
    } else {
        int matrixSize = baseMatrixSize + 1 + 2 * ((baseMatrixSize / 2 - 1) / 15);
        int origCenter = baseMatrixSize / 2;
        int center = matrixSize / 2;
        for (int i = 0; i < origCenter; i++) {
            int newOffset = i + i / 15;
            alignmentMap.array[origCenter - i - 1] = (int32_t)(center - newOffset - 1);
            alignmentMap.array[origCenter + i] = (int32_t)(center + newOffset + 1);
        }
    }
    for (int i = 0, rowOffset = 0; i < layers; i++) {
        int rowSize = compact ? (layers - i) * 4 + 9 : (layers - i) * 4 + 12;
        // The top-left most point of this layer is <low, low> (not including alignment lines)
        int low = i * 2;
        // The bottom-right most point of this layer is <high, high> (not including alignment lines)
        int high = baseMatrixSize - 1 - low;
        // We pull bits from the two 2 x rowSize columns and two rowSize x 2 rows
        for (int j = 0; j < rowSize; j++) {
            int columnOffset = j * 2;
            for (int k = 0; k < 2; k++) {
                // left column
                rawbits.array[rowOffset + columnOffset + k] =
                [matrix getX:alignmentMap.array[low + k] y:alignmentMap.array[low + j]];
                // bottom row
                rawbits.array[rowOffset + 2 * rowSize + columnOffset + k] =
                [matrix getX:alignmentMap.array[low + j] y:alignmentMap.array[high - k]];
                // right column
                rawbits.array[rowOffset + 4 * rowSize + columnOffset + k] =
                [matrix getX:alignmentMap.array[high - k] y:alignmentMap.array[high - j]];
                // top row
                rawbits.array[rowOffset + 6 * rowSize + columnOffset + k] =
                [matrix getX:alignmentMap.array[high - j] y:alignmentMap.array[low + k]];
            }
        }
        rowOffset += rowSize * 8;
    }
    return rawbits;
}

- (int)totalBitsInLayer:(int)layers compact:(BOOL)compact {
    return ((compact ? 88 : 112) + 16 * layers) * layers;
}

- (AGXBoolArray *)correctBits:(AGXBoolArray *)rawbits error:(NSError **)error {
    AGXGenericGF *gf;
    int codewordSize;

    int nbLayers = _detectorResult.nbLayers;
    if (nbLayers <= 2) {
        codewordSize = 6;
        gf = [AGXGenericGF AztecData6];
    } else if (nbLayers <= 8) {
        codewordSize = 8;
        gf = [AGXGenericGF AztecData8];
    } else if (nbLayers <= 22) {
        codewordSize = 10;
        gf = [AGXGenericGF AztecData10];
    } else {
        codewordSize = 12;
        gf = [AGXGenericGF AztecData12];
    }

    int numDataCodewords = _detectorResult.nbDatablocks;
    int numCodewords = rawbits.length / codewordSize;
    if AGX_EXPECT_F(numCodewords < numDataCodewords) {
        if AGX_EXPECT_T(error) *error = AGXFormatErrorInstance();
        return 0;
    }
    int offset = rawbits.length % codewordSize;
    int numECCodewords = numCodewords - numDataCodewords;

    AGXIntArray *dataWords = [AGXIntArray intArrayWithLength:numCodewords];
    for (int i = 0; i < numCodewords; i++, offset += codewordSize) {
        dataWords.array[i] = [self readCode:rawbits startIndex:offset length:codewordSize];
    }

    AGXReedSolomonDecoder *rsDecoder = AGX_AUTORELEASE([[AGXReedSolomonDecoder alloc] initWithField:gf]);
    NSError *decodeError = nil;
    if AGX_EXPECT_F(![rsDecoder decode:dataWords twoS:numECCodewords error:&decodeError]) {
        if AGX_EXPECT_T(error) *error = (decodeError.code == AGXReedSolomonError ?
                                         AGXFormatErrorInstance() : decodeError);
        return 0;
    }

    // Now perform the unstuffing operation.
    // First, count how many bits are going to be thrown out as stuffing
    int mask = (1 << codewordSize) - 1;
    int stuffedBits = 0;
    for (int i = 0; i < numDataCodewords; i++) {
        int32_t dataWord = dataWords.array[i];
        if (dataWord == 0 || dataWord == mask) {
            if AGX_EXPECT_T(error) *error = AGXFormatErrorInstance();
            return 0;
        } else if (dataWord == 1 || dataWord == mask - 1) {
            stuffedBits++;
        }
    }

    // Now, actually unpack the bits and remove the stuffing
    AGXBoolArray *correctedBits = [AGXBoolArray boolArrayWithLength:numDataCodewords * codewordSize - stuffedBits];
    int index = 0;
    for (int i = 0; i < numDataCodewords; i++) {
        int dataWord = dataWords.array[i];
        if (dataWord == 1 || dataWord == mask - 1) {
            // next codewordSize-1 bits are all zeros or all ones
            memset(correctedBits.array + index * sizeof(BOOL), dataWord > 1, codewordSize - 1);
            index += codewordSize - 1;
        } else {
            for (int bit = codewordSize - 1; bit >= 0; --bit) {
                correctedBits.array[index++] = (dataWord & (1 << bit)) != 0;
            }
        }
    }
    return correctedBits;
}

- (int)readCode:(AGXBoolArray *)rawbits startIndex:(int)startIndex length:(int)length {
    int res = 0;
    for (int i = startIndex; i < startIndex + length; i++) {
        res <<= 1;
        if (rawbits.array[i]) {
            res |= 0x01;
        }
    }
    return res;
}

- (NSString *)encodedData:(AGXBoolArray *)correctedBits {
    int endIndex = (int)correctedBits.length;
    AGXAztecTable latchTable = AGXAztecTableUpper; // table most recently latched to
    AGXAztecTable shiftTable = AGXAztecTableUpper; // table to use for the next read
    NSMutableString *result = [NSMutableString stringWithCapacity:20];
    int index = 0;
    while (index < endIndex) {
        if (shiftTable == AGXAztecTableBinary) {
            if (endIndex - index < 5) break;
            int length = [self readCode:correctedBits startIndex:index length:5];
            index += 5;
            if (length == 0) {
                if (endIndex - index < 11) break;
                length = [self readCode:correctedBits startIndex:index length:11] + 31;
                index += 11;
            }
            for (int charCount = 0; charCount < length; charCount++) {
                if (endIndex - index < 8) {
                    index = endIndex;  // Force outer loop to exit
                    break;
                }

                int code = [self readCode:correctedBits startIndex:index length:8];
                [result appendFormat:@"%C", (unichar)code];
                index += 8;
            }
            // Go back to whatever mode we had been in
            shiftTable = latchTable;
        } else {
            int size = shiftTable == AGXAztecTableDigit ? 4 : 5;
            if (endIndex - index < size) break;
            int code = [self readCode:correctedBits startIndex:index length:size];
            index += size;
            NSString *str = [self character:shiftTable code:code];
            if ([str hasPrefix:@"CTRL_"]) {
                // Table changes
                shiftTable = [self table:[str characterAtIndex:5]];
                if ([str characterAtIndex:6] == 'L') {
                    latchTable = shiftTable;
                }
            } else {
                [result appendString:str];
                // Go back to whatever mode we had been in
                shiftTable = latchTable;
            }
        }
    }
    return [NSString stringWithString:result];
}

- (NSString *)character:(AGXAztecTable)table code:(int)code {
    switch (table) {
        case AGXAztecTableUpper: return AGX_AZTEC_UPPER_TABLE[code];
        case AGXAztecTableLower: return AGX_AZTEC_LOWER_TABLE[code];
        case AGXAztecTableMixed: return AGX_AZTEC_MIXED_TABLE[code];
        case AGXAztecTablePunct: return AGX_AZTEC_PUNCT_TABLE[code];
        case AGXAztecTableDigit: return AGX_AZTEC_DIGIT_TABLE[code];
        // Should not reach here.
        default: @throw [NSException exceptionWithName:@"IllegalStateException" reason:@"Bad table" userInfo:nil];
    }
}

- (AGXAztecTable)table:(unichar)t {
    switch (t) {
        case 'L': return AGXAztecTableLower;
        case 'P': return AGXAztecTablePunct;
        case 'M': return AGXAztecTableMixed;
        case 'D': return AGXAztecTableDigit;
        case 'B': return AGXAztecTableBinary;
        case 'U':
        default : return AGXAztecTableUpper;
    }
}

@end
