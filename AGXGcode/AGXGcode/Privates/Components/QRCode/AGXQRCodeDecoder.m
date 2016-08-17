//
//  AGXQRCodeDecoder.m
//  AGXGcode
//
//  Created by Char Aznable on 16/8/5.
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
#import "AGXQRCodeDecoder.h"
#import "AGXGcodeError.h"
#import "AGXReedSolomonDecoder.h"
#import "AGXQRCodeBitMatrixParser.h"
#import "AGXQRCodeDataBlock.h"
#import "AGXQRCodeDecodedBitStreamParser.h"

@implementation AGXQRCodeDecoder {
    AGXReedSolomonDecoder *_rsDecoder;
}

- (AGX_INSTANCETYPE)init {
    if (self = [super init]) {
        _rsDecoder = [[AGXReedSolomonDecoder alloc] initWithField:[AGXGenericGF QrCodeField256]];
    }
    return self;
}

- (void)dealloc {
    AGX_RELEASE(_rsDecoder);
    AGX_SUPER_DEALLOC;
}

- (AGXDecoderResult *)decodeMatrix:(AGXBitMatrix *)bits hints:(AGXDecodeHints *)hints error:(NSError **)error {
    AGXQRCodeBitMatrixParser *parser = [AGXQRCodeBitMatrixParser parserWithBitMatrix:bits error:error];
    if (!parser) return nil;

    AGXDecoderResult *result = [self decodeParser:parser hints:hints error:error];
    if (result) return result;

    return nil;
}

- (AGXDecoderResult *)decodeParser:(AGXQRCodeBitMatrixParser *)parser hints:(AGXDecodeHints *)hints error:(NSError **)error {
    AGXQRCodeVersion *version = [parser readVersionWithError:error];
    if (!version) return nil;

    AGXQRCodeFormatInformation *formatInfo = [parser readFormatInformationWithError:error];
    if (!formatInfo) return nil;

    AGXQRCodeErrorCorrectionLevel *ecLevel = formatInfo.errorCorrectionLevel;

    AGXByteArray *codewords = [parser readCodewordsWithError:error];
    if (!codewords) return nil;

    NSArray *dataBlocks = [AGXQRCodeDataBlock dataBlocks:codewords version:version ecLevel:ecLevel];

    int totalBytes = 0;
    for (AGXQRCodeDataBlock *dataBlock in dataBlocks) {
        totalBytes += dataBlock.numDataCodewords;
    }
    if (totalBytes == 0) return nil;

    AGXByteArray *resultBytes = [AGXByteArray byteArrayWithLength:totalBytes];
    int resultOffset = 0;

    for (AGXQRCodeDataBlock *dataBlock in dataBlocks) {
        AGXByteArray *codewordBytes = dataBlock.codewords;
        int numDataCodewords = [dataBlock numDataCodewords];
        if (![self correctErrors:codewordBytes numDataCodewords:numDataCodewords error:error]) {
            return nil;
        }
        for (int i = 0; i < numDataCodewords; i++) {
            resultBytes.array[resultOffset++] = codewordBytes.array[i];
        }
    }

    return [AGXQRCodeDecodedBitStreamParser decode:resultBytes version:version ecLevel:ecLevel hints:hints error:error];
}

- (BOOL)correctErrors:(AGXByteArray *)codewordBytes numDataCodewords:(int)numDataCodewords error:(NSError **)error {
    int numCodewords = (int)codewordBytes.length;
    // First read into an array of ints
    AGXIntArray *codewordsInts = [AGXIntArray intArrayWithLength:numCodewords];
    for (int i = 0; i < numCodewords; i++) {
        codewordsInts.array[i] = codewordBytes.array[i] & 0xFF;
    }
    int numECCodewords = (int)codewordBytes.length - numDataCodewords;
    NSError *decodeError = nil;
    if (![_rsDecoder decode:codewordsInts twoS:numECCodewords error:&decodeError]) {
        if (decodeError.code == AGXReedSolomonError) {
            if (error) *error = AGXChecksumErrorInstance();
            return NO;
        } else {
            if (error) *error = decodeError;
            return NO;
        }
    }
    // Copy back into array of bytes -- only need to worry about the bytes that were data
    // We don't care about errors in the error-correction codewords
    for (int i = 0; i < numDataCodewords; i++) {
        codewordBytes.array[i] = (int8_t) codewordsInts.array[i];
    }
    return YES;
}

@end
