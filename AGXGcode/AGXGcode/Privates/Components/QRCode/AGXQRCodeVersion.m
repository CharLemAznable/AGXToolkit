//
//  AGXQRCodeVersion.m
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
#import "AGXQRCodeVersion.h"
#import "AGXQRCodeFormatInformation.h"

/**
 * See ISO 18004:2006 Annex D.
 * Element i represents the raw version bits that specify version i + 7
 */
const int AGX_VERSION_DECODE_INFO[] = {
    0x07C94, 0x085BC, 0x09A99, 0x0A4D3, 0x0BBF6,
    0x0C762, 0x0D847, 0x0E60D, 0x0F928, 0x10B78,
    0x1145D, 0x12A17, 0x13532, 0x149A6, 0x15683,
    0x168C9, 0x177EC, 0x18EC4, 0x191E1, 0x1AFAB,
    0x1B08E, 0x1CC1A, 0x1D33F, 0x1ED75, 0x1F250,
    0x209D5, 0x216F0, 0x228BA, 0x2379F, 0x24B0B,
    0x2542E, 0x26A64, 0x27541, 0x28C69
};

static NSArray *AGX_VERSIONS = nil;

@implementation AGXQRCodeVersion

+ (AGX_INSTANCETYPE)versionWithVersionNumber:(int)versionNumber alignmentPatternCenters:(AGXIntArray *)alignmentPatternCenters ecBlocks1:(AGXQRCodeECBlocks *)ecBlocks1 ecBlocks2:(AGXQRCodeECBlocks *)ecBlocks2 ecBlocks3:(AGXQRCodeECBlocks *)ecBlocks3 ecBlocks4:(AGXQRCodeECBlocks *)ecBlocks4 {
    return AGX_AUTORELEASE([[self alloc] initWithVersionNumber:versionNumber alignmentPatternCenters:alignmentPatternCenters ecBlocks1:ecBlocks1 ecBlocks2:ecBlocks2 ecBlocks3:ecBlocks3 ecBlocks4:ecBlocks4]);
}

- (AGX_INSTANCETYPE)initWithVersionNumber:(int)versionNumber alignmentPatternCenters:(AGXIntArray *)alignmentPatternCenters ecBlocks1:(AGXQRCodeECBlocks *)ecBlocks1 ecBlocks2:(AGXQRCodeECBlocks *)ecBlocks2 ecBlocks3:(AGXQRCodeECBlocks *)ecBlocks3 ecBlocks4:(AGXQRCodeECBlocks *)ecBlocks4 {
    if AGX_EXPECT_T(self = [super init]) {
        _versionNumber = versionNumber;
        _alignmentPatternCenters = AGX_RETAIN(alignmentPatternCenters);
        _ecBlocks = [[NSArray alloc] initWithObjects:ecBlocks1, ecBlocks2, ecBlocks3, ecBlocks4, nil];
        int total = 0;
        int ecCodewords = ecBlocks1.ecCodewordsPerBlock;
        for (AGXQRCodeECB *ecBlock in ecBlocks1.ecBlocks) {
            total += ecBlock.count * (ecBlock.dataCodewords + ecCodewords);
        }
        _totalCodewords = total;
    }
    return self;
}

- (void)dealloc {
    AGX_RELEASE(_alignmentPatternCenters);
    AGX_RELEASE(_ecBlocks);
    AGX_SUPER_DEALLOC;
}

- (int)dimensionForVersion {
    return 17 + 4 * _versionNumber;
}

- (AGXQRCodeECBlocks *)ecBlocksForLevel:(AGXQRCodeErrorCorrectionLevel *)ecLevel {
    return _ecBlocks[ecLevel.ordinal];
}

/**
 * Deduces version information purely from QR Code dimensions.
 *
 * @param dimension dimension in modules
 * @return Version for a QR Code of that dimension or nil if dimension is not 1 mod 4
 */
+ (AGX_INSTANCETYPE)provisionalVersionForDimension:(int)dimension {
    if (dimension % 4 != 1) return nil;
    return [self versionForNumber:(dimension - 17) / 4];
}

+ (AGX_INSTANCETYPE)versionForNumber:(int)versionNumber {
    if (versionNumber < 1 || versionNumber > 40) return nil;
    return AGX_VERSIONS[versionNumber - 1];
}

+ (AGX_INSTANCETYPE)decodeVersionInformation:(int)versionBits {
    int bestDifference = INT_MAX;
    int bestVersion = 0;

    for (int i = 0; i < sizeof(AGX_VERSION_DECODE_INFO) / sizeof(int); i++) {
        int targetVersion = AGX_VERSION_DECODE_INFO[i];
        if (targetVersion == versionBits) {
            return [self versionForNumber:i + 7];
        }
        int bitsDifference = [AGXQRCodeFormatInformation numBitsDiffering:versionBits b:targetVersion];
        if (bitsDifference < bestDifference) {
            bestVersion = i + 7;
            bestDifference = bitsDifference;
        }
    }

    if (bestDifference <= 3) return [self versionForNumber:bestVersion];
    return nil;
}

/**
 * See ISO 18004:2006 Annex E
 */
- (AGXBitMatrix *)buildFunctionPattern {
    int dimension = [self dimensionForVersion];
    AGXBitMatrix *bitMatrix = [AGXBitMatrix bitMatrixWithDimension:dimension];
    [bitMatrix setRegionAtLeft:0 top:0 width:9 height:9];
    [bitMatrix setRegionAtLeft:dimension - 8 top:0 width:8 height:9];
    [bitMatrix setRegionAtLeft:0 top:dimension - 8 width:9 height:8];
    int max = _alignmentPatternCenters.length;

    for (int x = 0; x < max; x++) {
        int i = _alignmentPatternCenters.array[x] - 2;

        for (int y = 0; y < max; y++) {
            if ((x == 0 && (y == 0 || y == max - 1)) || (x == max - 1 && y == 0)) {
                continue;
            }
            [bitMatrix setRegionAtLeft:_alignmentPatternCenters.array[y] - 2 top:i width:5 height:5];
        }
    }

    [bitMatrix setRegionAtLeft:6 top:9 width:1 height:dimension - 17];
    [bitMatrix setRegionAtLeft:9 top:6 width:dimension - 17 height:1];
    if (_versionNumber > 6) {
        [bitMatrix setRegionAtLeft:dimension - 11 top:0 width:3 height:6];
        [bitMatrix setRegionAtLeft:0 top:dimension - 11 width:6 height:3];
    }
    return bitMatrix;
}

- (NSString *)description {
    return [@(_versionNumber) stringValue];
}

/**
 * See ISO 18004:2006 6.5.1 Table 9
 */
+ (void)load {
    static dispatch_once_t once_t;
    dispatch_once(&once_t, ^{
        AGX_VERSIONS = [[NSArray alloc] initWithObjects:[AGXQRCodeVersion versionWithVersionNumber:1 alignmentPatternCenters:[AGXIntArray intArrayWithLength:0] ecBlocks1:[AGXQRCodeECBlocks ecBlocksWithEcCodewordsPerBlock:7 ecBlocks:[AGXQRCodeECB ecbWithCount:1 dataCodewords:19]] ecBlocks2:[AGXQRCodeECBlocks ecBlocksWithEcCodewordsPerBlock:10 ecBlocks:[AGXQRCodeECB ecbWithCount:1 dataCodewords:16]] ecBlocks3:[AGXQRCodeECBlocks ecBlocksWithEcCodewordsPerBlock:13 ecBlocks:[AGXQRCodeECB ecbWithCount:1 dataCodewords:13]] ecBlocks4:[AGXQRCodeECBlocks ecBlocksWithEcCodewordsPerBlock:17 ecBlocks:[AGXQRCodeECB ecbWithCount:1 dataCodewords:9]]],

                        [AGXQRCodeVersion versionWithVersionNumber:2 alignmentPatternCenters:[AGXIntArray intArrayWithInts:6, 18, -1] ecBlocks1:[AGXQRCodeECBlocks ecBlocksWithEcCodewordsPerBlock:10 ecBlocks:[AGXQRCodeECB ecbWithCount:1 dataCodewords:34]] ecBlocks2:[AGXQRCodeECBlocks ecBlocksWithEcCodewordsPerBlock:16 ecBlocks:[AGXQRCodeECB ecbWithCount:1 dataCodewords:28]] ecBlocks3:[AGXQRCodeECBlocks ecBlocksWithEcCodewordsPerBlock:22 ecBlocks:[AGXQRCodeECB ecbWithCount:1 dataCodewords:22]] ecBlocks4:[AGXQRCodeECBlocks ecBlocksWithEcCodewordsPerBlock:28 ecBlocks:[AGXQRCodeECB ecbWithCount:1 dataCodewords:16]]],

                        [AGXQRCodeVersion versionWithVersionNumber:3 alignmentPatternCenters:[AGXIntArray intArrayWithInts:6, 22, -1] ecBlocks1:[AGXQRCodeECBlocks ecBlocksWithEcCodewordsPerBlock:15 ecBlocks:[AGXQRCodeECB ecbWithCount:1 dataCodewords:55]] ecBlocks2:[AGXQRCodeECBlocks ecBlocksWithEcCodewordsPerBlock:26 ecBlocks:[AGXQRCodeECB ecbWithCount:1 dataCodewords:44]] ecBlocks3:[AGXQRCodeECBlocks ecBlocksWithEcCodewordsPerBlock:18 ecBlocks:[AGXQRCodeECB ecbWithCount:2 dataCodewords:17]] ecBlocks4:[AGXQRCodeECBlocks ecBlocksWithEcCodewordsPerBlock:22 ecBlocks:[AGXQRCodeECB ecbWithCount:2 dataCodewords:13]]],

                        [AGXQRCodeVersion versionWithVersionNumber:4 alignmentPatternCenters:[AGXIntArray intArrayWithInts:6, 26, -1] ecBlocks1:[AGXQRCodeECBlocks ecBlocksWithEcCodewordsPerBlock:20 ecBlocks:[AGXQRCodeECB ecbWithCount:1 dataCodewords:80]] ecBlocks2:[AGXQRCodeECBlocks ecBlocksWithEcCodewordsPerBlock:18 ecBlocks:[AGXQRCodeECB ecbWithCount:2 dataCodewords:32]] ecBlocks3:[AGXQRCodeECBlocks ecBlocksWithEcCodewordsPerBlock:26 ecBlocks:[AGXQRCodeECB ecbWithCount:2 dataCodewords:24]] ecBlocks4:[AGXQRCodeECBlocks ecBlocksWithEcCodewordsPerBlock:16 ecBlocks:[AGXQRCodeECB ecbWithCount:4 dataCodewords:9]]],

                        [AGXQRCodeVersion versionWithVersionNumber:5 alignmentPatternCenters:[AGXIntArray intArrayWithInts:6, 30, -1] ecBlocks1:[AGXQRCodeECBlocks ecBlocksWithEcCodewordsPerBlock:26 ecBlocks:[AGXQRCodeECB ecbWithCount:1 dataCodewords:108]] ecBlocks2:[AGXQRCodeECBlocks ecBlocksWithEcCodewordsPerBlock:24 ecBlocks:[AGXQRCodeECB ecbWithCount:2 dataCodewords:43]] ecBlocks3:[AGXQRCodeECBlocks ecBlocksWithEcCodewordsPerBlock:18 ecBlocks1:[AGXQRCodeECB ecbWithCount:2 dataCodewords:15] ecBlocks2:[AGXQRCodeECB ecbWithCount:2 dataCodewords:16]] ecBlocks4:[AGXQRCodeECBlocks ecBlocksWithEcCodewordsPerBlock:22 ecBlocks1:[AGXQRCodeECB ecbWithCount:2 dataCodewords:11] ecBlocks2:[AGXQRCodeECB ecbWithCount:2 dataCodewords:12]]],

                        [AGXQRCodeVersion versionWithVersionNumber:6 alignmentPatternCenters:[AGXIntArray intArrayWithInts:6, 34, -1] ecBlocks1:[AGXQRCodeECBlocks ecBlocksWithEcCodewordsPerBlock:18 ecBlocks:[AGXQRCodeECB ecbWithCount:2 dataCodewords:68]] ecBlocks2:[AGXQRCodeECBlocks ecBlocksWithEcCodewordsPerBlock:16 ecBlocks:[AGXQRCodeECB ecbWithCount:4 dataCodewords:27]] ecBlocks3:[AGXQRCodeECBlocks ecBlocksWithEcCodewordsPerBlock:24 ecBlocks:[AGXQRCodeECB ecbWithCount:4 dataCodewords:19]] ecBlocks4:[AGXQRCodeECBlocks ecBlocksWithEcCodewordsPerBlock:28 ecBlocks:[AGXQRCodeECB ecbWithCount:4 dataCodewords:15]]],

                        [AGXQRCodeVersion versionWithVersionNumber:7 alignmentPatternCenters:[AGXIntArray intArrayWithInts:6, 22, 38, -1] ecBlocks1:[AGXQRCodeECBlocks ecBlocksWithEcCodewordsPerBlock:20 ecBlocks:[AGXQRCodeECB ecbWithCount:2 dataCodewords:78]] ecBlocks2:[AGXQRCodeECBlocks ecBlocksWithEcCodewordsPerBlock:18 ecBlocks:[AGXQRCodeECB ecbWithCount:4 dataCodewords:31]] ecBlocks3:[AGXQRCodeECBlocks ecBlocksWithEcCodewordsPerBlock:18 ecBlocks1:[AGXQRCodeECB ecbWithCount:2 dataCodewords:14] ecBlocks2:[AGXQRCodeECB ecbWithCount:4 dataCodewords:15]] ecBlocks4:[AGXQRCodeECBlocks ecBlocksWithEcCodewordsPerBlock:26 ecBlocks1:[AGXQRCodeECB ecbWithCount:4 dataCodewords:13] ecBlocks2:[AGXQRCodeECB ecbWithCount:1 dataCodewords:14]]],

                        [AGXQRCodeVersion versionWithVersionNumber:8 alignmentPatternCenters:[AGXIntArray intArrayWithInts:6, 24, 42, -1] ecBlocks1:[AGXQRCodeECBlocks ecBlocksWithEcCodewordsPerBlock:24 ecBlocks:[AGXQRCodeECB ecbWithCount:2 dataCodewords:97]] ecBlocks2:[AGXQRCodeECBlocks ecBlocksWithEcCodewordsPerBlock:22 ecBlocks1:[AGXQRCodeECB ecbWithCount:2 dataCodewords:38] ecBlocks2:[AGXQRCodeECB ecbWithCount:2 dataCodewords:39]] ecBlocks3:[AGXQRCodeECBlocks ecBlocksWithEcCodewordsPerBlock:22 ecBlocks1:[AGXQRCodeECB ecbWithCount:4 dataCodewords:18] ecBlocks2:[AGXQRCodeECB ecbWithCount:2 dataCodewords:19]] ecBlocks4:[AGXQRCodeECBlocks ecBlocksWithEcCodewordsPerBlock:26 ecBlocks1:[AGXQRCodeECB ecbWithCount:4 dataCodewords:14] ecBlocks2:[AGXQRCodeECB ecbWithCount:2 dataCodewords:15]]],

                        [AGXQRCodeVersion versionWithVersionNumber:9 alignmentPatternCenters:[AGXIntArray intArrayWithInts:6, 26, 46, -1] ecBlocks1:[AGXQRCodeECBlocks ecBlocksWithEcCodewordsPerBlock:30 ecBlocks:[AGXQRCodeECB ecbWithCount:2 dataCodewords:116]] ecBlocks2:[AGXQRCodeECBlocks ecBlocksWithEcCodewordsPerBlock:22 ecBlocks1:[AGXQRCodeECB ecbWithCount:3 dataCodewords:36] ecBlocks2:[AGXQRCodeECB ecbWithCount:2 dataCodewords:37]] ecBlocks3:[AGXQRCodeECBlocks ecBlocksWithEcCodewordsPerBlock:20 ecBlocks1:[AGXQRCodeECB ecbWithCount:4 dataCodewords:16] ecBlocks2:[AGXQRCodeECB ecbWithCount:4 dataCodewords:17]] ecBlocks4:[AGXQRCodeECBlocks ecBlocksWithEcCodewordsPerBlock:24 ecBlocks1:[AGXQRCodeECB ecbWithCount:4 dataCodewords:12] ecBlocks2:[AGXQRCodeECB ecbWithCount:4 dataCodewords:13]]],

                        [AGXQRCodeVersion versionWithVersionNumber:10 alignmentPatternCenters:[AGXIntArray intArrayWithInts:6, 28, 50, -1] ecBlocks1:[AGXQRCodeECBlocks ecBlocksWithEcCodewordsPerBlock:18 ecBlocks1:[AGXQRCodeECB ecbWithCount:2 dataCodewords:68] ecBlocks2:[AGXQRCodeECB ecbWithCount:2 dataCodewords:69]] ecBlocks2:[AGXQRCodeECBlocks ecBlocksWithEcCodewordsPerBlock:26 ecBlocks1:[AGXQRCodeECB ecbWithCount:4 dataCodewords:43] ecBlocks2:[AGXQRCodeECB ecbWithCount:1 dataCodewords:44]] ecBlocks3:[AGXQRCodeECBlocks ecBlocksWithEcCodewordsPerBlock:24 ecBlocks1:[AGXQRCodeECB ecbWithCount:6 dataCodewords:19] ecBlocks2:[AGXQRCodeECB ecbWithCount:2 dataCodewords:20]] ecBlocks4:[AGXQRCodeECBlocks ecBlocksWithEcCodewordsPerBlock:28 ecBlocks1:[AGXQRCodeECB ecbWithCount:6 dataCodewords:15] ecBlocks2:[AGXQRCodeECB ecbWithCount:2 dataCodewords:16]]],

                        [AGXQRCodeVersion versionWithVersionNumber:11 alignmentPatternCenters:[AGXIntArray intArrayWithInts:6, 30, 54, -1] ecBlocks1:[AGXQRCodeECBlocks ecBlocksWithEcCodewordsPerBlock:20 ecBlocks:[AGXQRCodeECB ecbWithCount:4 dataCodewords:81]] ecBlocks2:[AGXQRCodeECBlocks ecBlocksWithEcCodewordsPerBlock:30 ecBlocks1:[AGXQRCodeECB ecbWithCount:1 dataCodewords:50] ecBlocks2:[AGXQRCodeECB ecbWithCount:4 dataCodewords:51]] ecBlocks3:[AGXQRCodeECBlocks ecBlocksWithEcCodewordsPerBlock:28 ecBlocks1:[AGXQRCodeECB ecbWithCount:4 dataCodewords:22] ecBlocks2:[AGXQRCodeECB ecbWithCount:4 dataCodewords:23]] ecBlocks4:[AGXQRCodeECBlocks ecBlocksWithEcCodewordsPerBlock:24 ecBlocks1:[AGXQRCodeECB ecbWithCount:3 dataCodewords:12] ecBlocks2:[AGXQRCodeECB ecbWithCount:8 dataCodewords:13]]],

                        [AGXQRCodeVersion versionWithVersionNumber:12 alignmentPatternCenters:[AGXIntArray intArrayWithInts:6, 32, 58, -1] ecBlocks1:[AGXQRCodeECBlocks ecBlocksWithEcCodewordsPerBlock:24 ecBlocks1:[AGXQRCodeECB ecbWithCount:2 dataCodewords:92] ecBlocks2:[AGXQRCodeECB ecbWithCount:2 dataCodewords:93]] ecBlocks2:[AGXQRCodeECBlocks ecBlocksWithEcCodewordsPerBlock:22 ecBlocks1:[AGXQRCodeECB ecbWithCount:6 dataCodewords:36] ecBlocks2:[AGXQRCodeECB ecbWithCount:2 dataCodewords:37]] ecBlocks3:[AGXQRCodeECBlocks ecBlocksWithEcCodewordsPerBlock:26 ecBlocks1:[AGXQRCodeECB ecbWithCount:4 dataCodewords:20] ecBlocks2:[AGXQRCodeECB ecbWithCount:6 dataCodewords:21]] ecBlocks4:[AGXQRCodeECBlocks ecBlocksWithEcCodewordsPerBlock:28 ecBlocks1:[AGXQRCodeECB ecbWithCount:7 dataCodewords:14] ecBlocks2:[AGXQRCodeECB ecbWithCount:4 dataCodewords:15]]],

                        [AGXQRCodeVersion versionWithVersionNumber:13 alignmentPatternCenters:[AGXIntArray intArrayWithInts:6, 34, 62, -1] ecBlocks1:[AGXQRCodeECBlocks ecBlocksWithEcCodewordsPerBlock:26 ecBlocks:[AGXQRCodeECB ecbWithCount:4 dataCodewords:107]] ecBlocks2:[AGXQRCodeECBlocks ecBlocksWithEcCodewordsPerBlock:22 ecBlocks1:[AGXQRCodeECB ecbWithCount:8 dataCodewords:37] ecBlocks2:[AGXQRCodeECB ecbWithCount:1 dataCodewords:38]] ecBlocks3:[AGXQRCodeECBlocks ecBlocksWithEcCodewordsPerBlock:24 ecBlocks1:[AGXQRCodeECB ecbWithCount:8 dataCodewords:20] ecBlocks2:[AGXQRCodeECB ecbWithCount:4 dataCodewords:21]] ecBlocks4:[AGXQRCodeECBlocks ecBlocksWithEcCodewordsPerBlock:22 ecBlocks1:[AGXQRCodeECB ecbWithCount:12 dataCodewords:11] ecBlocks2:[AGXQRCodeECB ecbWithCount:4 dataCodewords:12]]],

                        [AGXQRCodeVersion versionWithVersionNumber:14 alignmentPatternCenters:[AGXIntArray intArrayWithInts:6, 26, 46, 66, -1] ecBlocks1:[AGXQRCodeECBlocks ecBlocksWithEcCodewordsPerBlock:30 ecBlocks1:[AGXQRCodeECB ecbWithCount:3 dataCodewords:115] ecBlocks2:[AGXQRCodeECB ecbWithCount:1 dataCodewords:116]] ecBlocks2:[AGXQRCodeECBlocks ecBlocksWithEcCodewordsPerBlock:24 ecBlocks1:[AGXQRCodeECB ecbWithCount:4 dataCodewords:40] ecBlocks2:[AGXQRCodeECB ecbWithCount:5 dataCodewords:41]] ecBlocks3:[AGXQRCodeECBlocks ecBlocksWithEcCodewordsPerBlock:20 ecBlocks1:[AGXQRCodeECB ecbWithCount:11 dataCodewords:16] ecBlocks2:[AGXQRCodeECB ecbWithCount:5 dataCodewords:17]] ecBlocks4:[AGXQRCodeECBlocks ecBlocksWithEcCodewordsPerBlock:24 ecBlocks1:[AGXQRCodeECB ecbWithCount:11 dataCodewords:12] ecBlocks2:[AGXQRCodeECB ecbWithCount:5 dataCodewords:13]]],

                        [AGXQRCodeVersion versionWithVersionNumber:15 alignmentPatternCenters:[AGXIntArray intArrayWithInts:6, 26, 48, 70, -1] ecBlocks1:[AGXQRCodeECBlocks ecBlocksWithEcCodewordsPerBlock:22 ecBlocks1:[AGXQRCodeECB ecbWithCount:5 dataCodewords:87] ecBlocks2:[AGXQRCodeECB ecbWithCount:1 dataCodewords:88]] ecBlocks2:[AGXQRCodeECBlocks ecBlocksWithEcCodewordsPerBlock:24 ecBlocks1:[AGXQRCodeECB ecbWithCount:5 dataCodewords:41] ecBlocks2:[AGXQRCodeECB ecbWithCount:5 dataCodewords:42]] ecBlocks3:[AGXQRCodeECBlocks ecBlocksWithEcCodewordsPerBlock:30 ecBlocks1:[AGXQRCodeECB ecbWithCount:5 dataCodewords:24] ecBlocks2:[AGXQRCodeECB ecbWithCount:7 dataCodewords:25]] ecBlocks4:[AGXQRCodeECBlocks ecBlocksWithEcCodewordsPerBlock:24 ecBlocks1:[AGXQRCodeECB ecbWithCount:11 dataCodewords:12] ecBlocks2:[AGXQRCodeECB ecbWithCount:7 dataCodewords:13]]],

                        [AGXQRCodeVersion versionWithVersionNumber:16 alignmentPatternCenters:[AGXIntArray intArrayWithInts:6, 26, 50, 74, -1] ecBlocks1:[AGXQRCodeECBlocks ecBlocksWithEcCodewordsPerBlock:24 ecBlocks1:[AGXQRCodeECB ecbWithCount:5 dataCodewords:98] ecBlocks2:[AGXQRCodeECB ecbWithCount:1 dataCodewords:99]] ecBlocks2:[AGXQRCodeECBlocks ecBlocksWithEcCodewordsPerBlock:28 ecBlocks1:[AGXQRCodeECB ecbWithCount:7 dataCodewords:45] ecBlocks2:[AGXQRCodeECB ecbWithCount:3 dataCodewords:46]] ecBlocks3:[AGXQRCodeECBlocks ecBlocksWithEcCodewordsPerBlock:24 ecBlocks1:[AGXQRCodeECB ecbWithCount:15 dataCodewords:19] ecBlocks2:[AGXQRCodeECB ecbWithCount:2 dataCodewords:20]] ecBlocks4:[AGXQRCodeECBlocks ecBlocksWithEcCodewordsPerBlock:30 ecBlocks1:[AGXQRCodeECB ecbWithCount:3 dataCodewords:15] ecBlocks2:[AGXQRCodeECB ecbWithCount:13 dataCodewords:16]]],

                        [AGXQRCodeVersion versionWithVersionNumber:17 alignmentPatternCenters:[AGXIntArray intArrayWithInts:6, 30, 54, 78, -1] ecBlocks1:[AGXQRCodeECBlocks ecBlocksWithEcCodewordsPerBlock:28 ecBlocks1:[AGXQRCodeECB ecbWithCount:1 dataCodewords:107] ecBlocks2:[AGXQRCodeECB ecbWithCount:5 dataCodewords:108]] ecBlocks2:[AGXQRCodeECBlocks ecBlocksWithEcCodewordsPerBlock:28 ecBlocks1:[AGXQRCodeECB ecbWithCount:10 dataCodewords:46] ecBlocks2:[AGXQRCodeECB ecbWithCount:1 dataCodewords:47]] ecBlocks3:[AGXQRCodeECBlocks ecBlocksWithEcCodewordsPerBlock:28 ecBlocks1:[AGXQRCodeECB ecbWithCount:1 dataCodewords:22] ecBlocks2:[AGXQRCodeECB ecbWithCount:15 dataCodewords:23]] ecBlocks4:[AGXQRCodeECBlocks ecBlocksWithEcCodewordsPerBlock:28 ecBlocks1:[AGXQRCodeECB ecbWithCount:2 dataCodewords:14] ecBlocks2:[AGXQRCodeECB ecbWithCount:17 dataCodewords:15]]],

                        [AGXQRCodeVersion versionWithVersionNumber:18 alignmentPatternCenters:[AGXIntArray intArrayWithInts:6, 30, 56, 82, -1] ecBlocks1:[AGXQRCodeECBlocks ecBlocksWithEcCodewordsPerBlock:30 ecBlocks1:[AGXQRCodeECB ecbWithCount:5 dataCodewords:120] ecBlocks2:[AGXQRCodeECB ecbWithCount:1 dataCodewords:121]] ecBlocks2:[AGXQRCodeECBlocks ecBlocksWithEcCodewordsPerBlock:26 ecBlocks1:[AGXQRCodeECB ecbWithCount:9 dataCodewords:43] ecBlocks2:[AGXQRCodeECB ecbWithCount:4 dataCodewords:44]] ecBlocks3:[AGXQRCodeECBlocks ecBlocksWithEcCodewordsPerBlock:28 ecBlocks1:[AGXQRCodeECB ecbWithCount:17 dataCodewords:22] ecBlocks2:[AGXQRCodeECB ecbWithCount:1 dataCodewords:23]] ecBlocks4:[AGXQRCodeECBlocks ecBlocksWithEcCodewordsPerBlock:28 ecBlocks1:[AGXQRCodeECB ecbWithCount:2 dataCodewords:14] ecBlocks2:[AGXQRCodeECB ecbWithCount:19 dataCodewords:15]]],

                        [AGXQRCodeVersion versionWithVersionNumber:19 alignmentPatternCenters:[AGXIntArray intArrayWithInts:6, 30, 58, 86, -1] ecBlocks1:[AGXQRCodeECBlocks ecBlocksWithEcCodewordsPerBlock:28 ecBlocks1:[AGXQRCodeECB ecbWithCount:3 dataCodewords:113] ecBlocks2:[AGXQRCodeECB ecbWithCount:4 dataCodewords:114]] ecBlocks2:[AGXQRCodeECBlocks ecBlocksWithEcCodewordsPerBlock:26 ecBlocks1:[AGXQRCodeECB ecbWithCount:3 dataCodewords:44] ecBlocks2:[AGXQRCodeECB ecbWithCount:11 dataCodewords:45]] ecBlocks3:[AGXQRCodeECBlocks ecBlocksWithEcCodewordsPerBlock:26 ecBlocks1:[AGXQRCodeECB ecbWithCount:17 dataCodewords:21] ecBlocks2:[AGXQRCodeECB ecbWithCount:4 dataCodewords:22]] ecBlocks4:[AGXQRCodeECBlocks ecBlocksWithEcCodewordsPerBlock:26 ecBlocks1:[AGXQRCodeECB ecbWithCount:9 dataCodewords:13] ecBlocks2:[AGXQRCodeECB ecbWithCount:16 dataCodewords:14]]],

                        [AGXQRCodeVersion versionWithVersionNumber:20 alignmentPatternCenters:[AGXIntArray intArrayWithInts:6, 34, 62, 90, -1] ecBlocks1:[AGXQRCodeECBlocks ecBlocksWithEcCodewordsPerBlock:28 ecBlocks1:[AGXQRCodeECB ecbWithCount:3 dataCodewords:107] ecBlocks2:[AGXQRCodeECB ecbWithCount:5 dataCodewords:108]] ecBlocks2:[AGXQRCodeECBlocks ecBlocksWithEcCodewordsPerBlock:26 ecBlocks1:[AGXQRCodeECB ecbWithCount:3 dataCodewords:41] ecBlocks2:[AGXQRCodeECB ecbWithCount:13 dataCodewords:42]] ecBlocks3:[AGXQRCodeECBlocks ecBlocksWithEcCodewordsPerBlock:30 ecBlocks1:[AGXQRCodeECB ecbWithCount:15 dataCodewords:24] ecBlocks2:[AGXQRCodeECB ecbWithCount:5 dataCodewords:25]] ecBlocks4:[AGXQRCodeECBlocks ecBlocksWithEcCodewordsPerBlock:28 ecBlocks1:[AGXQRCodeECB ecbWithCount:15 dataCodewords:15] ecBlocks2:[AGXQRCodeECB ecbWithCount:10 dataCodewords:16]]],

                        [AGXQRCodeVersion versionWithVersionNumber:21 alignmentPatternCenters:[AGXIntArray intArrayWithInts:6, 28, 50, 72, 94, -1] ecBlocks1:[AGXQRCodeECBlocks ecBlocksWithEcCodewordsPerBlock:28 ecBlocks1:[AGXQRCodeECB ecbWithCount:4 dataCodewords:116] ecBlocks2:[AGXQRCodeECB ecbWithCount:4 dataCodewords:117]] ecBlocks2:[AGXQRCodeECBlocks ecBlocksWithEcCodewordsPerBlock:26 ecBlocks:[AGXQRCodeECB ecbWithCount:17 dataCodewords:42]] ecBlocks3:[AGXQRCodeECBlocks ecBlocksWithEcCodewordsPerBlock:28 ecBlocks1:[AGXQRCodeECB ecbWithCount:17 dataCodewords:22] ecBlocks2:[AGXQRCodeECB ecbWithCount:6 dataCodewords:23]] ecBlocks4:[AGXQRCodeECBlocks ecBlocksWithEcCodewordsPerBlock:30 ecBlocks1:[AGXQRCodeECB ecbWithCount:19 dataCodewords:16] ecBlocks2:[AGXQRCodeECB ecbWithCount:6 dataCodewords:17]]],

                        [AGXQRCodeVersion versionWithVersionNumber:22 alignmentPatternCenters:[AGXIntArray intArrayWithInts:6, 26, 50, 72, 98, -1] ecBlocks1:[AGXQRCodeECBlocks ecBlocksWithEcCodewordsPerBlock:28 ecBlocks1:[AGXQRCodeECB ecbWithCount:2 dataCodewords:111] ecBlocks2:[AGXQRCodeECB ecbWithCount:7 dataCodewords:112]] ecBlocks2:[AGXQRCodeECBlocks ecBlocksWithEcCodewordsPerBlock:28 ecBlocks:[AGXQRCodeECB ecbWithCount:17 dataCodewords:46]] ecBlocks3:[AGXQRCodeECBlocks ecBlocksWithEcCodewordsPerBlock:30 ecBlocks1:[AGXQRCodeECB ecbWithCount:7 dataCodewords:24] ecBlocks2:[AGXQRCodeECB ecbWithCount:16 dataCodewords:25]] ecBlocks4:[AGXQRCodeECBlocks ecBlocksWithEcCodewordsPerBlock:24 ecBlocks:[AGXQRCodeECB ecbWithCount:34 dataCodewords:13]]],

                        [AGXQRCodeVersion versionWithVersionNumber:23 alignmentPatternCenters:[AGXIntArray intArrayWithInts:6, 30, 54, 78, 102, -1] ecBlocks1:[AGXQRCodeECBlocks ecBlocksWithEcCodewordsPerBlock:30 ecBlocks1:[AGXQRCodeECB ecbWithCount:4 dataCodewords:121] ecBlocks2:[AGXQRCodeECB ecbWithCount:5 dataCodewords:122]] ecBlocks2:[AGXQRCodeECBlocks ecBlocksWithEcCodewordsPerBlock:28 ecBlocks1:[AGXQRCodeECB ecbWithCount:4 dataCodewords:47] ecBlocks2:[AGXQRCodeECB ecbWithCount:14 dataCodewords:48]] ecBlocks3:[AGXQRCodeECBlocks ecBlocksWithEcCodewordsPerBlock:30 ecBlocks1:[AGXQRCodeECB ecbWithCount:11 dataCodewords:24] ecBlocks2:[AGXQRCodeECB ecbWithCount:14 dataCodewords:25]] ecBlocks4:[AGXQRCodeECBlocks ecBlocksWithEcCodewordsPerBlock:30 ecBlocks1:[AGXQRCodeECB ecbWithCount:16 dataCodewords:15] ecBlocks2:[AGXQRCodeECB ecbWithCount:14 dataCodewords:16]]],

                        [AGXQRCodeVersion versionWithVersionNumber:24 alignmentPatternCenters:[AGXIntArray intArrayWithInts:6, 28, 54, 80, 106, -1] ecBlocks1:[AGXQRCodeECBlocks ecBlocksWithEcCodewordsPerBlock:30 ecBlocks1:[AGXQRCodeECB ecbWithCount:6 dataCodewords:117] ecBlocks2:[AGXQRCodeECB ecbWithCount:4 dataCodewords:118]] ecBlocks2:[AGXQRCodeECBlocks ecBlocksWithEcCodewordsPerBlock:28 ecBlocks1:[AGXQRCodeECB ecbWithCount:6 dataCodewords:45] ecBlocks2:[AGXQRCodeECB ecbWithCount:14 dataCodewords:46]] ecBlocks3:[AGXQRCodeECBlocks ecBlocksWithEcCodewordsPerBlock:30 ecBlocks1:[AGXQRCodeECB ecbWithCount:11 dataCodewords:24] ecBlocks2:[AGXQRCodeECB ecbWithCount:16 dataCodewords:25]] ecBlocks4:[AGXQRCodeECBlocks ecBlocksWithEcCodewordsPerBlock:30 ecBlocks1:[AGXQRCodeECB ecbWithCount:30 dataCodewords:16] ecBlocks2:[AGXQRCodeECB ecbWithCount:2 dataCodewords:17]]],

                        [AGXQRCodeVersion versionWithVersionNumber:25 alignmentPatternCenters:[AGXIntArray intArrayWithInts:6, 32, 58, 84, 110, -1] ecBlocks1:[AGXQRCodeECBlocks ecBlocksWithEcCodewordsPerBlock:26 ecBlocks1:[AGXQRCodeECB ecbWithCount:8 dataCodewords:106] ecBlocks2:[AGXQRCodeECB ecbWithCount:4 dataCodewords:107]] ecBlocks2:[AGXQRCodeECBlocks ecBlocksWithEcCodewordsPerBlock:28 ecBlocks1:[AGXQRCodeECB ecbWithCount:8 dataCodewords:47] ecBlocks2:[AGXQRCodeECB ecbWithCount:13 dataCodewords:48]] ecBlocks3:[AGXQRCodeECBlocks ecBlocksWithEcCodewordsPerBlock:30 ecBlocks1:[AGXQRCodeECB ecbWithCount:7 dataCodewords:24] ecBlocks2:[AGXQRCodeECB ecbWithCount:22 dataCodewords:25]] ecBlocks4:[AGXQRCodeECBlocks ecBlocksWithEcCodewordsPerBlock:30 ecBlocks1:[AGXQRCodeECB ecbWithCount:22 dataCodewords:15] ecBlocks2:[AGXQRCodeECB ecbWithCount:13 dataCodewords:16]]],

                        [AGXQRCodeVersion versionWithVersionNumber:26 alignmentPatternCenters:[AGXIntArray intArrayWithInts:6, 30, 58, 86, 114, -1] ecBlocks1:[AGXQRCodeECBlocks ecBlocksWithEcCodewordsPerBlock:28 ecBlocks1:[AGXQRCodeECB ecbWithCount:10 dataCodewords:114] ecBlocks2:[AGXQRCodeECB ecbWithCount:2 dataCodewords:115]] ecBlocks2:[AGXQRCodeECBlocks ecBlocksWithEcCodewordsPerBlock:28 ecBlocks1:[AGXQRCodeECB ecbWithCount:19 dataCodewords:46] ecBlocks2:[AGXQRCodeECB ecbWithCount:4 dataCodewords:47]] ecBlocks3:[AGXQRCodeECBlocks ecBlocksWithEcCodewordsPerBlock:28 ecBlocks1:[AGXQRCodeECB ecbWithCount:28 dataCodewords:22] ecBlocks2:[AGXQRCodeECB ecbWithCount:6 dataCodewords:23]] ecBlocks4:[AGXQRCodeECBlocks ecBlocksWithEcCodewordsPerBlock:30 ecBlocks1:[AGXQRCodeECB ecbWithCount:33 dataCodewords:16] ecBlocks2:[AGXQRCodeECB ecbWithCount:4 dataCodewords:17]]],

                        [AGXQRCodeVersion versionWithVersionNumber:27 alignmentPatternCenters:[AGXIntArray intArrayWithInts:6, 34, 62, 90, 118, -1] ecBlocks1:[AGXQRCodeECBlocks ecBlocksWithEcCodewordsPerBlock:30 ecBlocks1:[AGXQRCodeECB ecbWithCount:8 dataCodewords:122] ecBlocks2:[AGXQRCodeECB ecbWithCount:4 dataCodewords:123]] ecBlocks2:[AGXQRCodeECBlocks ecBlocksWithEcCodewordsPerBlock:28 ecBlocks1:[AGXQRCodeECB ecbWithCount:22 dataCodewords:45] ecBlocks2:[AGXQRCodeECB ecbWithCount:3 dataCodewords:46]] ecBlocks3:[AGXQRCodeECBlocks ecBlocksWithEcCodewordsPerBlock:30 ecBlocks1:[AGXQRCodeECB ecbWithCount:8 dataCodewords:23] ecBlocks2:[AGXQRCodeECB ecbWithCount:26 dataCodewords:24]] ecBlocks4:[AGXQRCodeECBlocks ecBlocksWithEcCodewordsPerBlock:30 ecBlocks1:[AGXQRCodeECB ecbWithCount:12 dataCodewords:15] ecBlocks2:[AGXQRCodeECB ecbWithCount:28 dataCodewords:16]]],

                        [AGXQRCodeVersion versionWithVersionNumber:28 alignmentPatternCenters:[AGXIntArray intArrayWithInts:6, 26, 50, 74, 98, 122, -1] ecBlocks1:[AGXQRCodeECBlocks ecBlocksWithEcCodewordsPerBlock:30 ecBlocks1:[AGXQRCodeECB ecbWithCount:3 dataCodewords:117] ecBlocks2:[AGXQRCodeECB ecbWithCount:10 dataCodewords:118]] ecBlocks2:[AGXQRCodeECBlocks ecBlocksWithEcCodewordsPerBlock:28 ecBlocks1:[AGXQRCodeECB ecbWithCount:3 dataCodewords:45] ecBlocks2:[AGXQRCodeECB ecbWithCount:23 dataCodewords:46]] ecBlocks3:[AGXQRCodeECBlocks ecBlocksWithEcCodewordsPerBlock:30 ecBlocks1:[AGXQRCodeECB ecbWithCount:4 dataCodewords:24] ecBlocks2:[AGXQRCodeECB ecbWithCount:31 dataCodewords:25]] ecBlocks4:[AGXQRCodeECBlocks ecBlocksWithEcCodewordsPerBlock:30 ecBlocks1:[AGXQRCodeECB ecbWithCount:11 dataCodewords:15] ecBlocks2:[AGXQRCodeECB ecbWithCount:31 dataCodewords:16]]],

                        [AGXQRCodeVersion versionWithVersionNumber:29 alignmentPatternCenters:[AGXIntArray intArrayWithInts:6, 30, 54, 78, 102, 126, -1] ecBlocks1:[AGXQRCodeECBlocks ecBlocksWithEcCodewordsPerBlock:30 ecBlocks1:[AGXQRCodeECB ecbWithCount:7 dataCodewords:116] ecBlocks2:[AGXQRCodeECB ecbWithCount:7 dataCodewords:117]] ecBlocks2:[AGXQRCodeECBlocks ecBlocksWithEcCodewordsPerBlock:28 ecBlocks1:[AGXQRCodeECB ecbWithCount:21 dataCodewords:45] ecBlocks2:[AGXQRCodeECB ecbWithCount:7 dataCodewords:46]] ecBlocks3:[AGXQRCodeECBlocks ecBlocksWithEcCodewordsPerBlock:30 ecBlocks1:[AGXQRCodeECB ecbWithCount:1 dataCodewords:23] ecBlocks2:[AGXQRCodeECB ecbWithCount:37 dataCodewords:24]] ecBlocks4:[AGXQRCodeECBlocks ecBlocksWithEcCodewordsPerBlock:30 ecBlocks1:[AGXQRCodeECB ecbWithCount:19 dataCodewords:15] ecBlocks2:[AGXQRCodeECB ecbWithCount:26 dataCodewords:16]]],

                        [AGXQRCodeVersion versionWithVersionNumber:30 alignmentPatternCenters:[AGXIntArray intArrayWithInts:6, 26, 52, 78, 104, 130, -1] ecBlocks1:[AGXQRCodeECBlocks ecBlocksWithEcCodewordsPerBlock:30 ecBlocks1:[AGXQRCodeECB ecbWithCount:5 dataCodewords:115] ecBlocks2:[AGXQRCodeECB ecbWithCount:10 dataCodewords:116]] ecBlocks2:[AGXQRCodeECBlocks ecBlocksWithEcCodewordsPerBlock:28 ecBlocks1:[AGXQRCodeECB ecbWithCount:19 dataCodewords:47] ecBlocks2:[AGXQRCodeECB ecbWithCount:10 dataCodewords:48]] ecBlocks3:[AGXQRCodeECBlocks ecBlocksWithEcCodewordsPerBlock:30 ecBlocks1:[AGXQRCodeECB ecbWithCount:15 dataCodewords:24] ecBlocks2:[AGXQRCodeECB ecbWithCount:25 dataCodewords:25]] ecBlocks4:[AGXQRCodeECBlocks ecBlocksWithEcCodewordsPerBlock:30 ecBlocks1:[AGXQRCodeECB ecbWithCount:23 dataCodewords:15] ecBlocks2:[AGXQRCodeECB ecbWithCount:25 dataCodewords:16]]],

                        [AGXQRCodeVersion versionWithVersionNumber:31 alignmentPatternCenters:[AGXIntArray intArrayWithInts:6, 30, 56, 82, 108, 134, -1] ecBlocks1:[AGXQRCodeECBlocks ecBlocksWithEcCodewordsPerBlock:30 ecBlocks1:[AGXQRCodeECB ecbWithCount:13 dataCodewords:115] ecBlocks2:[AGXQRCodeECB ecbWithCount:3 dataCodewords:116]] ecBlocks2:[AGXQRCodeECBlocks ecBlocksWithEcCodewordsPerBlock:28 ecBlocks1:[AGXQRCodeECB ecbWithCount:2 dataCodewords:46] ecBlocks2:[AGXQRCodeECB ecbWithCount:29 dataCodewords:47]] ecBlocks3:[AGXQRCodeECBlocks ecBlocksWithEcCodewordsPerBlock:30 ecBlocks1:[AGXQRCodeECB ecbWithCount:42 dataCodewords:24] ecBlocks2:[AGXQRCodeECB ecbWithCount:1 dataCodewords:25]] ecBlocks4:[AGXQRCodeECBlocks ecBlocksWithEcCodewordsPerBlock:30 ecBlocks1:[AGXQRCodeECB ecbWithCount:23 dataCodewords:15] ecBlocks2:[AGXQRCodeECB ecbWithCount:28 dataCodewords:16]]],

                        [AGXQRCodeVersion versionWithVersionNumber:32 alignmentPatternCenters:[AGXIntArray intArrayWithInts:6, 34, 60, 86, 112, 138, -1] ecBlocks1:[AGXQRCodeECBlocks ecBlocksWithEcCodewordsPerBlock:30 ecBlocks:[AGXQRCodeECB ecbWithCount:17 dataCodewords:115]] ecBlocks2:[AGXQRCodeECBlocks ecBlocksWithEcCodewordsPerBlock:28 ecBlocks1:[AGXQRCodeECB ecbWithCount:10 dataCodewords:46] ecBlocks2:[AGXQRCodeECB ecbWithCount:23 dataCodewords:47]] ecBlocks3:[AGXQRCodeECBlocks ecBlocksWithEcCodewordsPerBlock:30 ecBlocks1:[AGXQRCodeECB ecbWithCount:10 dataCodewords:24] ecBlocks2:[AGXQRCodeECB ecbWithCount:35 dataCodewords:25]] ecBlocks4:[AGXQRCodeECBlocks ecBlocksWithEcCodewordsPerBlock:30 ecBlocks1:[AGXQRCodeECB ecbWithCount:19 dataCodewords:15] ecBlocks2:[AGXQRCodeECB ecbWithCount:35 dataCodewords:16]]],

                        [AGXQRCodeVersion versionWithVersionNumber:33 alignmentPatternCenters:[AGXIntArray intArrayWithInts:6, 30, 58, 86, 114, 142, -1] ecBlocks1:[AGXQRCodeECBlocks ecBlocksWithEcCodewordsPerBlock:30 ecBlocks1:[AGXQRCodeECB ecbWithCount:17 dataCodewords:115] ecBlocks2:[AGXQRCodeECB ecbWithCount:1 dataCodewords:116]] ecBlocks2:[AGXQRCodeECBlocks ecBlocksWithEcCodewordsPerBlock:28 ecBlocks1:[AGXQRCodeECB ecbWithCount:14 dataCodewords:46] ecBlocks2:[AGXQRCodeECB ecbWithCount:21 dataCodewords:47]] ecBlocks3:[AGXQRCodeECBlocks ecBlocksWithEcCodewordsPerBlock:30 ecBlocks1:[AGXQRCodeECB ecbWithCount:29 dataCodewords:24] ecBlocks2:[AGXQRCodeECB ecbWithCount:19 dataCodewords:25]] ecBlocks4:[AGXQRCodeECBlocks ecBlocksWithEcCodewordsPerBlock:30 ecBlocks1:[AGXQRCodeECB ecbWithCount:11 dataCodewords:15] ecBlocks2:[AGXQRCodeECB ecbWithCount:46 dataCodewords:16]]],

                        [AGXQRCodeVersion versionWithVersionNumber:34 alignmentPatternCenters:[AGXIntArray intArrayWithInts:6, 34, 62, 90, 118, 146, -1] ecBlocks1:[AGXQRCodeECBlocks ecBlocksWithEcCodewordsPerBlock:30 ecBlocks1:[AGXQRCodeECB ecbWithCount:13 dataCodewords:115] ecBlocks2:[AGXQRCodeECB ecbWithCount:6 dataCodewords:116]] ecBlocks2:[AGXQRCodeECBlocks ecBlocksWithEcCodewordsPerBlock:28 ecBlocks1:[AGXQRCodeECB ecbWithCount:14 dataCodewords:46] ecBlocks2:[AGXQRCodeECB ecbWithCount:23 dataCodewords:47]] ecBlocks3:[AGXQRCodeECBlocks ecBlocksWithEcCodewordsPerBlock:30 ecBlocks1:[AGXQRCodeECB ecbWithCount:44 dataCodewords:24] ecBlocks2:[AGXQRCodeECB ecbWithCount:7 dataCodewords:25]] ecBlocks4:[AGXQRCodeECBlocks ecBlocksWithEcCodewordsPerBlock:30 ecBlocks1:[AGXQRCodeECB ecbWithCount:59 dataCodewords:16] ecBlocks2:[AGXQRCodeECB ecbWithCount:1 dataCodewords:17]]],

                        [AGXQRCodeVersion versionWithVersionNumber:35 alignmentPatternCenters:[AGXIntArray intArrayWithInts:6, 30, 54, 78, 102, 126, 150, -1] ecBlocks1:[AGXQRCodeECBlocks ecBlocksWithEcCodewordsPerBlock:30 ecBlocks1:[AGXQRCodeECB ecbWithCount:12 dataCodewords:121] ecBlocks2:[AGXQRCodeECB ecbWithCount:7 dataCodewords:122]] ecBlocks2:[AGXQRCodeECBlocks ecBlocksWithEcCodewordsPerBlock:28 ecBlocks1:[AGXQRCodeECB ecbWithCount:12 dataCodewords:47] ecBlocks2:[AGXQRCodeECB ecbWithCount:26 dataCodewords:48]] ecBlocks3:[AGXQRCodeECBlocks ecBlocksWithEcCodewordsPerBlock:30 ecBlocks1:[AGXQRCodeECB ecbWithCount:39 dataCodewords:24] ecBlocks2:[AGXQRCodeECB ecbWithCount:14 dataCodewords:25]] ecBlocks4:[AGXQRCodeECBlocks ecBlocksWithEcCodewordsPerBlock:30 ecBlocks1:[AGXQRCodeECB ecbWithCount:22 dataCodewords:15] ecBlocks2:[AGXQRCodeECB ecbWithCount:41 dataCodewords:16]]],

                        [AGXQRCodeVersion versionWithVersionNumber:36 alignmentPatternCenters:[AGXIntArray intArrayWithInts:6, 24, 50, 76, 102, 128, 154, -1] ecBlocks1:[AGXQRCodeECBlocks ecBlocksWithEcCodewordsPerBlock:30 ecBlocks1:[AGXQRCodeECB ecbWithCount:6 dataCodewords:121] ecBlocks2:[AGXQRCodeECB ecbWithCount:14 dataCodewords:122]] ecBlocks2:[AGXQRCodeECBlocks ecBlocksWithEcCodewordsPerBlock:28 ecBlocks1:[AGXQRCodeECB ecbWithCount:6 dataCodewords:47] ecBlocks2:[AGXQRCodeECB ecbWithCount:34 dataCodewords:48]] ecBlocks3:[AGXQRCodeECBlocks ecBlocksWithEcCodewordsPerBlock:30 ecBlocks1:[AGXQRCodeECB ecbWithCount:46 dataCodewords:24] ecBlocks2:[AGXQRCodeECB ecbWithCount:10 dataCodewords:25]] ecBlocks4:[AGXQRCodeECBlocks ecBlocksWithEcCodewordsPerBlock:30 ecBlocks1:[AGXQRCodeECB ecbWithCount:2 dataCodewords:15] ecBlocks2:[AGXQRCodeECB ecbWithCount:64 dataCodewords:16]]],

                        [AGXQRCodeVersion versionWithVersionNumber:37 alignmentPatternCenters:[AGXIntArray intArrayWithInts:6, 28, 54, 80, 106, 132, 158, -1] ecBlocks1:[AGXQRCodeECBlocks ecBlocksWithEcCodewordsPerBlock:30 ecBlocks1:[AGXQRCodeECB ecbWithCount:17 dataCodewords:122] ecBlocks2:[AGXQRCodeECB ecbWithCount:4 dataCodewords:123]] ecBlocks2:[AGXQRCodeECBlocks ecBlocksWithEcCodewordsPerBlock:28 ecBlocks1:[AGXQRCodeECB ecbWithCount:29 dataCodewords:46] ecBlocks2:[AGXQRCodeECB ecbWithCount:14 dataCodewords:47]] ecBlocks3:[AGXQRCodeECBlocks ecBlocksWithEcCodewordsPerBlock:30 ecBlocks1:[AGXQRCodeECB ecbWithCount:49 dataCodewords:24] ecBlocks2:[AGXQRCodeECB ecbWithCount:10 dataCodewords:25]] ecBlocks4:[AGXQRCodeECBlocks ecBlocksWithEcCodewordsPerBlock:30 ecBlocks1:[AGXQRCodeECB ecbWithCount:24 dataCodewords:15] ecBlocks2:[AGXQRCodeECB ecbWithCount:46 dataCodewords:16]]],

                        [AGXQRCodeVersion versionWithVersionNumber:38 alignmentPatternCenters:[AGXIntArray intArrayWithInts:6, 32, 58, 84, 110, 136, 162, -1] ecBlocks1:[AGXQRCodeECBlocks ecBlocksWithEcCodewordsPerBlock:30 ecBlocks1:[AGXQRCodeECB ecbWithCount:4 dataCodewords:122] ecBlocks2:[AGXQRCodeECB ecbWithCount:18 dataCodewords:123]] ecBlocks2:[AGXQRCodeECBlocks ecBlocksWithEcCodewordsPerBlock:28 ecBlocks1:[AGXQRCodeECB ecbWithCount:13 dataCodewords:46] ecBlocks2:[AGXQRCodeECB ecbWithCount:32 dataCodewords:47]] ecBlocks3:[AGXQRCodeECBlocks ecBlocksWithEcCodewordsPerBlock:30 ecBlocks1:[AGXQRCodeECB ecbWithCount:48 dataCodewords:24] ecBlocks2:[AGXQRCodeECB ecbWithCount:14 dataCodewords:25]] ecBlocks4:[AGXQRCodeECBlocks ecBlocksWithEcCodewordsPerBlock:30 ecBlocks1:[AGXQRCodeECB ecbWithCount:42 dataCodewords:15] ecBlocks2:[AGXQRCodeECB ecbWithCount:32 dataCodewords:16]]],

                        [AGXQRCodeVersion versionWithVersionNumber:39 alignmentPatternCenters:[AGXIntArray intArrayWithInts:6, 26, 54, 82, 110, 138, 166, -1] ecBlocks1:[AGXQRCodeECBlocks ecBlocksWithEcCodewordsPerBlock:30 ecBlocks1:[AGXQRCodeECB ecbWithCount:20 dataCodewords:117] ecBlocks2:[AGXQRCodeECB ecbWithCount:4 dataCodewords:118]] ecBlocks2:[AGXQRCodeECBlocks ecBlocksWithEcCodewordsPerBlock:28 ecBlocks1:[AGXQRCodeECB ecbWithCount:40 dataCodewords:47] ecBlocks2:[AGXQRCodeECB ecbWithCount:7 dataCodewords:48]] ecBlocks3:[AGXQRCodeECBlocks ecBlocksWithEcCodewordsPerBlock:30 ecBlocks1:[AGXQRCodeECB ecbWithCount:43 dataCodewords:24] ecBlocks2:[AGXQRCodeECB ecbWithCount:22 dataCodewords:25]] ecBlocks4:[AGXQRCodeECBlocks ecBlocksWithEcCodewordsPerBlock:30 ecBlocks1:[AGXQRCodeECB ecbWithCount:10 dataCodewords:15] ecBlocks2:[AGXQRCodeECB ecbWithCount:67 dataCodewords:16]]],
                        
                        [AGXQRCodeVersion versionWithVersionNumber:40 alignmentPatternCenters:[AGXIntArray intArrayWithInts:6, 30, 58, 86, 114, 142, 170, -1] ecBlocks1:[AGXQRCodeECBlocks ecBlocksWithEcCodewordsPerBlock:30 ecBlocks1:[AGXQRCodeECB ecbWithCount:19 dataCodewords:118] ecBlocks2:[AGXQRCodeECB ecbWithCount:6 dataCodewords:119]] ecBlocks2:[AGXQRCodeECBlocks ecBlocksWithEcCodewordsPerBlock:28 ecBlocks1:[AGXQRCodeECB ecbWithCount:18 dataCodewords:47] ecBlocks2:[AGXQRCodeECB ecbWithCount:31 dataCodewords:48]] ecBlocks3:[AGXQRCodeECBlocks ecBlocksWithEcCodewordsPerBlock:30 ecBlocks1:[AGXQRCodeECB ecbWithCount:34 dataCodewords:24] ecBlocks2:[AGXQRCodeECB ecbWithCount:34 dataCodewords:25]] ecBlocks4:[AGXQRCodeECBlocks ecBlocksWithEcCodewordsPerBlock:30 ecBlocks1:[AGXQRCodeECB ecbWithCount:20 dataCodewords:15] ecBlocks2:[AGXQRCodeECB ecbWithCount:61 dataCodewords:16]]],
                        nil];
    });
}

@end

@implementation AGXQRCodeECBlocks

+ (AGX_INSTANCETYPE)ecBlocksWithEcCodewordsPerBlock:(int)ecCodewordsPerBlock ecBlocks:(AGXQRCodeECB *)ecBlocks {
    return AGX_AUTORELEASE([[AGXQRCodeECBlocks alloc] initWithEcCodewordsPerBlock:ecCodewordsPerBlock ecBlocks:ecBlocks]);
}

+ (AGX_INSTANCETYPE)ecBlocksWithEcCodewordsPerBlock:(int)ecCodewordsPerBlock ecBlocks1:(AGXQRCodeECB *)ecBlocks1 ecBlocks2:(AGXQRCodeECB *)ecBlocks2 {
    return AGX_AUTORELEASE([[AGXQRCodeECBlocks alloc] initWithEcCodewordsPerBlock:ecCodewordsPerBlock ecBlocks1:ecBlocks1 ecBlocks2:ecBlocks2]);
}

- (AGX_INSTANCETYPE)initWithEcCodewordsPerBlock:(int)ecCodewordsPerBlock ecBlocks:(AGXQRCodeECB *)ecBlocks {
    if AGX_EXPECT_T(self = [super init]) {
        _ecCodewordsPerBlock = ecCodewordsPerBlock;
        _ecBlocks = [[NSArray alloc] initWithObjects:ecBlocks, nil];
    }
    return self;
}

- (AGX_INSTANCETYPE)initWithEcCodewordsPerBlock:(int)ecCodewordsPerBlock ecBlocks1:(AGXQRCodeECB *)ecBlocks1 ecBlocks2:(AGXQRCodeECB *)ecBlocks2 {
    if AGX_EXPECT_T(self = [super init]) {
        _ecCodewordsPerBlock = ecCodewordsPerBlock;
        _ecBlocks = [[NSArray alloc] initWithObjects:ecBlocks1, ecBlocks2, nil];
    }
    return self;
}

- (void)dealloc {
    AGX_RELEASE(_ecBlocks);
    AGX_SUPER_DEALLOC;
}

- (int)numBlocks {
    int total = 0;
    for (AGXQRCodeECB *ecb in _ecBlocks) {
        total += [ecb count];
    }
    return total;
}

- (int)totalECCodewords {
    return _ecCodewordsPerBlock * self.numBlocks;
}

@end

@implementation AGXQRCodeECB

+ (AGX_INSTANCETYPE)ecbWithCount:(int)count dataCodewords:(int)dataCodewords {
    return AGX_AUTORELEASE([[AGXQRCodeECB alloc] initWithCount:count dataCodewords:dataCodewords]);
}

- (AGX_INSTANCETYPE)initWithCount:(int)count dataCodewords:(int)dataCodewords {
    if AGX_EXPECT_T(self = [super init]) {
        _count = count;
        _dataCodewords = dataCodewords;
    }
    return self;
}

@end
