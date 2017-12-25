//
//  AGXDataMatrixDecoder.m
//  AGXGcode
//
//  Created by Char Aznable on 2016/8/10.
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
#import "AGXDataMatrixDecoder.h"
#import "AGXGcodeError.h"
#import "AGXReedSolomonDecoder.h"
#import "AGXDataMatrixBitMatrixParser.h"
#import "AGXDataMatrixDataBlock.h"
#import "AGXDataMatrixDecodedBitStreamParser.h"

@implementation AGXDataMatrixDecoder {
    AGXReedSolomonDecoder *_rsDecoder;
}

- (AGX_INSTANCETYPE)init {
    if AGX_EXPECT_T(self = [super init]) {
        _rsDecoder = [[AGXReedSolomonDecoder alloc] initWithField:[AGXGenericGF DataMatrixField256]];
    }
    return self;
}

- (void)dealloc {
    AGX_RELEASE(_rsDecoder);
    AGX_SUPER_DEALLOC;
}

- (AGXDecoderResult *)decodeMatrix:(AGXBitMatrix *)bits error:(NSError **)error {
    AGXDataMatrixBitMatrixParser *parser = [AGXDataMatrixBitMatrixParser parserWithBitMatrix:bits error:error];
    if AGX_EXPECT_F(!parser) return nil;

    AGXDataMatrixVersion *version = [parser version];

    AGXByteArray *codewords = [parser readCodewords];
    NSArray *dataBlocks = [AGXDataMatrixDataBlock dataBlocks:codewords version:version];

    NSUInteger dataBlocksCount = [dataBlocks count];

    int totalBytes = 0;
    for (int i = 0; i < dataBlocksCount; i++) {
        totalBytes += [dataBlocks[i] numDataCodewords];
    }

    if AGX_EXPECT_F(totalBytes == 0) return nil;

    AGXByteArray *resultBytes = [AGXByteArray byteArrayWithLength:totalBytes];
    for (int j = 0; j < dataBlocksCount; j++) {
        AGXDataMatrixDataBlock *dataBlock = dataBlocks[j];
        AGXByteArray *codewordBytes = dataBlock.codewords;
        int numDataCodewords = [dataBlock numDataCodewords];
        if AGX_EXPECT_F(![self correctErrors:codewordBytes numDataCodewords:numDataCodewords error:error]) {
            return nil;
        }
        for (int i = 0; i < numDataCodewords; i++) {
            // De-interlace data blocks.
            resultBytes.array[i * dataBlocksCount + j] = codewordBytes.array[i];
        }
    }
    return [AGXDataMatrixDecodedBitStreamParser decode:resultBytes error:error];
}

- (BOOL)correctErrors:(AGXByteArray *)codewordBytes numDataCodewords:(int)numDataCodewords error:(NSError **)error {
    int numCodewords = codewordBytes.length;
    // First read into an array of ints
    AGXIntArray *codewordsInts = [AGXIntArray intArrayWithLength:numCodewords];
    for (int i = 0; i < numCodewords; i++) {
        codewordsInts.array[i] = codewordBytes.array[i] & 0xFF;
    }
    int numECCodewords = codewordBytes.length - numDataCodewords;

    NSError *decodeError = nil;
    if AGX_EXPECT_F(![_rsDecoder decode:codewordsInts twoS:numECCodewords error:&decodeError]) {
        if AGX_EXPECT_T(error) *error = (decodeError.code == AGXReedSolomonError ?
                                           AGXChecksumErrorInstance() : decodeError);
        return NO;
    }
    
    for (int i = 0; i < numDataCodewords; i++) {
        codewordBytes.array[i] = (int8_t) codewordsInts.array[i];
    }
    return YES;
}

@end
