//
//  AGXQRCodeDataBlock.m
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
#import "AGXQRCodeDataBlock.h"

@implementation AGXQRCodeDataBlock

- (AGX_INSTANCETYPE)initWithNumDataCodewords:(int)numDataCodewords codewords:(AGXByteArray *)codewords {
    if (AGX_EXPECT_T(self = [super init])) {
        _numDataCodewords = numDataCodewords;
        _codewords = AGX_RETAIN(codewords);
    }
    return self;
}

- (void)dealloc {
    AGX_RELEASE(_codewords);
    AGX_SUPER_DEALLOC;
}

+ (NSArray *)dataBlocks:(AGXByteArray *)rawCodewords version:(AGXQRCodeVersion *)version ecLevel:(AGXQRCodeErrorCorrectionLevel *)ecLevel {
    if (rawCodewords.length != version.totalCodewords) {
        [NSException raise:NSInvalidArgumentException format:@"Invalid codewords count"];
    }

    // Figure out the number and size of data blocks used by this version and
    // error correction level
    AGXQRCodeECBlocks *ecBlocks = [version ecBlocksForLevel:ecLevel];

    // First count the total number of data blocks
    int totalBlocks = 0;
    NSArray *ecBlockArray = ecBlocks.ecBlocks;
    for (AGXQRCodeECB *ecBlock in ecBlockArray) {
        totalBlocks += ecBlock.count;
    }

    // Now establish DataBlocks of the appropriate size and number of data codewords
    NSMutableArray *result = [NSMutableArray arrayWithCapacity:totalBlocks];
    for (AGXQRCodeECB *ecBlock in ecBlockArray) {
        for (int i = 0; i < ecBlock.count; i++) {
            int numDataCodewords = ecBlock.dataCodewords;
            int numBlockCodewords = ecBlocks.ecCodewordsPerBlock + numDataCodewords;
            [result addObject:AGX_AUTORELEASE([[AGXQRCodeDataBlock alloc] initWithNumDataCodewords:numDataCodewords codewords:[AGXByteArray byteArrayWithLength:numBlockCodewords]])];
        }
    }

    // All blocks have the same amount of data, except that the last n
    // (where n may be 0) have 1 more byte. Figure out where these start.
    int shorterBlocksTotalCodewords = [(AGXQRCodeDataBlock *)result[0] codewords].length;
    int longerBlocksStartAt = (int)[result count] - 1;
    while (longerBlocksStartAt >= 0) {
        int numCodewords = [(AGXQRCodeDataBlock *)result[longerBlocksStartAt] codewords].length;
        if (numCodewords == shorterBlocksTotalCodewords) {
            break;
        }
        longerBlocksStartAt--;
    }
    longerBlocksStartAt++;

    int shorterBlocksNumDataCodewords = shorterBlocksTotalCodewords - ecBlocks.ecCodewordsPerBlock;
    // The last elements of result may be 1 element longer;
    // first fill out as many elements as all of them have
    int rawCodewordsOffset = 0;
    int numResultBlocks = (int)[result count];
    for (int i = 0; i < shorterBlocksNumDataCodewords; i++) {
        for (int j = 0; j < numResultBlocks; j++) {
            [(AGXQRCodeDataBlock *)result[j] codewords].array[i] = rawCodewords.array[rawCodewordsOffset++];
        }
    }
    // Fill out the last data block in the longer ones
    for (int j = longerBlocksStartAt; j < numResultBlocks; j++) {
        [(AGXQRCodeDataBlock *)result[j] codewords].array[shorterBlocksNumDataCodewords] = rawCodewords.array[rawCodewordsOffset++];
    }
    // Now add in error correction blocks
    int max = (int)[(AGXQRCodeDataBlock *)result[0] codewords].length;
    for (int i = shorterBlocksNumDataCodewords; i < max; i++) {
        for (int j = 0; j < numResultBlocks; j++) {
            int iOffset = j < longerBlocksStartAt ? i : i + 1;
            [(AGXQRCodeDataBlock *)result[j] codewords].array[iOffset] = rawCodewords.array[rawCodewordsOffset++];
        }
    }
    
    return result;
}

@end
