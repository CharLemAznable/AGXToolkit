//
//  AGXDataMatrixDataBlock.m
//  AGXGcode
//
//  Created by Char Aznable on 16/8/10.
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
#import "AGXDataMatrixDataBlock.h"

@implementation AGXDataMatrixDataBlock

+ (AGX_INSTANCETYPE)dataBlockWithNumDataCodewords:(int)numDataCodewords codewords:(AGXByteArray *)codewords {
    return AGX_AUTORELEASE([[self alloc] initWithNumDataCodewords:numDataCodewords codewords:codewords]);
}

- (AGX_INSTANCETYPE)initWithNumDataCodewords:(int)numDataCodewords codewords:(AGXByteArray *)codewords {
    if (self = [super init]) {
        _numDataCodewords = numDataCodewords;
        _codewords = AGX_RETAIN(codewords);
    }
    return self;
}

- (void)dealloc {
    AGX_RELEASE(_codewords);
    AGX_SUPER_DEALLOC;
}

+ (NSArray *)dataBlocks:(AGXByteArray *)rawCodewords version:(AGXDataMatrixVersion *)version {
    // Figure out the number and size of data blocks used by this version
    AGXDataMatrixECBlocks *ecBlocks = version.ecBlocks;

    // First count the total number of data blocks
    int totalBlocks = 0;
    NSArray *ecBlockArray = ecBlocks.ecBlocks;
    for (AGXDataMatrixECB *ecBlock in ecBlockArray) {
        totalBlocks += ecBlock.count;
    }

    // Now establish DataBlocks of the appropriate size and number of data codewords
    NSMutableArray *result = [NSMutableArray arrayWithCapacity:totalBlocks];
    for (AGXDataMatrixECB *ecBlock in ecBlockArray) {
        for (int i = 0; i < ecBlock.count; i++) {
            int numDataCodewords = ecBlock.dataCodewords;
            int numBlockCodewords = ecBlocks.ecCodewords + numDataCodewords;
            [result addObject:[AGXDataMatrixDataBlock dataBlockWithNumDataCodewords:numDataCodewords codewords:[AGXByteArray byteArrayWithLength:numBlockCodewords]]];
        }
    }

    // All blocks have the same amount of data, except that the last n
    // (where n may be 0) have 1 less byte. Figure out where these start.
    // TODO(bbrown): There is only one case where there is a difference for Data Matrix for size 144
    int longerBlocksTotalCodewords = [[(AGXDataMatrixDataBlock *)result[0] codewords] length];
    //int shorterBlocksTotalCodewords = longerBlocksTotalCodewords - 1;

    int longerBlocksNumDataCodewords = longerBlocksTotalCodewords - ecBlocks.ecCodewords;
    int shorterBlocksNumDataCodewords = longerBlocksNumDataCodewords - 1;
    // The last elements of result may be 1 element shorter for 144 matrix
    // first fill out as many elements as all of them have minus 1
    int rawCodewordsOffset = 0;
    for (int i = 0; i < shorterBlocksNumDataCodewords; i++) {
        for (AGXDataMatrixDataBlock *block in result) {
            block.codewords.array[i] = rawCodewords.array[rawCodewordsOffset++];
        }
    }

    // Fill out the last data block in the longer ones
    BOOL specialVersion = version.versionNumber == 24;
    int numLongerBlocks = specialVersion ? 8 : (int)[result count];
    for (int j = 0; j < numLongerBlocks; j++) {
        [(AGXDataMatrixDataBlock *)result[j] codewords].array[longerBlocksNumDataCodewords - 1] = rawCodewords.array[rawCodewordsOffset++];
    }

    NSUInteger max = [(AGXDataMatrixDataBlock *)result[0] codewords].length;
    for (int i = longerBlocksNumDataCodewords; i < max; i++) {
        for (int j = 0; j < [result count]; j++) {
            int jOffset = specialVersion ? (j + 8) % [result count] : j;
            int iOffset = specialVersion && jOffset > 7 ? i - 1 : i;
            [(AGXDataMatrixDataBlock *)result[jOffset] codewords].array[iOffset] = rawCodewords.array[rawCodewordsOffset++];
        }
    }
    
    if (rawCodewordsOffset != rawCodewords.length) {
        [NSException raise:NSInvalidArgumentException format:@"Codewords size mismatch"];
    }
    return result;
}

@end
