//
//  AGXDataMatrixVersion.m
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
#import "AGXDataMatrixVersion.h"

static NSArray *VERSIONS = nil;

@implementation AGXDataMatrixVersion

+ (AGX_INSTANCETYPE)versionForDimensions:(int)numRows numColumns:(int)numColumns {
    if AGX_EXPECT_F((numRows & 0x01) != 0 || (numColumns & 0x01) != 0) return nil;

    for (AGXDataMatrixVersion *version in VERSIONS) {
        if (version.symbolSizeRows == numRows && version.symbolSizeColumns == numColumns) {
            return version;
        }
    }
    return nil;
}

+ (AGX_INSTANCETYPE)versionWithVersionNumber:(int)versionNumber symbolSizeRows:(int)symbolSizeRows symbolSizeColumns:(int)symbolSizeColumns dataRegionSizeRows:(int)dataRegionSizeRows dataRegionSizeColumns:(int)dataRegionSizeColumns ecBlocks:(AGXDataMatrixECBlocks *)ecBlocks {
    return AGX_AUTORELEASE([[self alloc] initWithVersionNumber:versionNumber symbolSizeRows:symbolSizeRows symbolSizeColumns:symbolSizeColumns dataRegionSizeRows:dataRegionSizeRows dataRegionSizeColumns:dataRegionSizeColumns ecBlocks:ecBlocks]);
}

- (AGX_INSTANCETYPE)initWithVersionNumber:(int)versionNumber symbolSizeRows:(int)symbolSizeRows symbolSizeColumns:(int)symbolSizeColumns dataRegionSizeRows:(int)dataRegionSizeRows dataRegionSizeColumns:(int)dataRegionSizeColumns ecBlocks:(AGXDataMatrixECBlocks *)ecBlocks {
    if AGX_EXPECT_T(self = [super init]) {
        _versionNumber = versionNumber;
        _symbolSizeRows = symbolSizeRows;
        _symbolSizeColumns = symbolSizeColumns;
        _dataRegionSizeRows = dataRegionSizeRows;
        _dataRegionSizeColumns = dataRegionSizeColumns;
        _ecBlocks = AGX_RETAIN(ecBlocks);

        int total = 0;
        int ecCodewords = ecBlocks.ecCodewords;
        NSArray *ecbArray = ecBlocks.ecBlocks;
        for (AGXDataMatrixECB *ecBlock in ecbArray) {
            total += ecBlock.count * (ecBlock.dataCodewords + ecCodewords);
        }
        _totalCodewords = total;
    }
    return self;
}

- (void)dealloc {
    AGX_RELEASE(_ecBlocks);
    AGX_SUPER_DEALLOC;
}

- (NSString *)description {
    return [@(_versionNumber) stringValue];
}

+ (void)load {
    static dispatch_once_t once_t;
    dispatch_once(&once_t, ^{
        VERSIONS = [[NSArray alloc] initWithObjects:
                    [AGXDataMatrixVersion versionWithVersionNumber:1 symbolSizeRows:10 symbolSizeColumns:10 dataRegionSizeRows:8 dataRegionSizeColumns:8 ecBlocks:[AGXDataMatrixECBlocks ecBlocksWithCodewords:5 ecBlocks:[AGXDataMatrixECB ecbWithCount:1 dataCodewords:3]]],

                    [AGXDataMatrixVersion versionWithVersionNumber:2 symbolSizeRows:12 symbolSizeColumns:12 dataRegionSizeRows:10 dataRegionSizeColumns:10 ecBlocks:[AGXDataMatrixECBlocks ecBlocksWithCodewords:7 ecBlocks:[AGXDataMatrixECB ecbWithCount:1 dataCodewords:5]]],

                     [AGXDataMatrixVersion versionWithVersionNumber:3 symbolSizeRows:14 symbolSizeColumns:14 dataRegionSizeRows:12 dataRegionSizeColumns:12 ecBlocks:[AGXDataMatrixECBlocks ecBlocksWithCodewords:10 ecBlocks:[AGXDataMatrixECB ecbWithCount:1 dataCodewords:8]]],

                     [AGXDataMatrixVersion versionWithVersionNumber:4 symbolSizeRows:16 symbolSizeColumns:16 dataRegionSizeRows:14 dataRegionSizeColumns:14 ecBlocks:[AGXDataMatrixECBlocks ecBlocksWithCodewords:12 ecBlocks:[AGXDataMatrixECB ecbWithCount:1 dataCodewords:12]]],

                     [AGXDataMatrixVersion versionWithVersionNumber:5 symbolSizeRows:18 symbolSizeColumns:18 dataRegionSizeRows:16 dataRegionSizeColumns:16 ecBlocks:[AGXDataMatrixECBlocks ecBlocksWithCodewords:14 ecBlocks:[AGXDataMatrixECB ecbWithCount:1 dataCodewords:18]]],

                     [AGXDataMatrixVersion versionWithVersionNumber:6 symbolSizeRows:20 symbolSizeColumns:20 dataRegionSizeRows:18 dataRegionSizeColumns:18 ecBlocks:[AGXDataMatrixECBlocks ecBlocksWithCodewords:18 ecBlocks:[AGXDataMatrixECB ecbWithCount:1 dataCodewords:22]]],

                     [AGXDataMatrixVersion versionWithVersionNumber:7 symbolSizeRows:22 symbolSizeColumns:22 dataRegionSizeRows:20 dataRegionSizeColumns:20 ecBlocks:[AGXDataMatrixECBlocks ecBlocksWithCodewords:20 ecBlocks:[AGXDataMatrixECB ecbWithCount:1 dataCodewords:30]]],

                     [AGXDataMatrixVersion versionWithVersionNumber:8 symbolSizeRows:24 symbolSizeColumns:24 dataRegionSizeRows:22 dataRegionSizeColumns:22 ecBlocks:[AGXDataMatrixECBlocks ecBlocksWithCodewords:24 ecBlocks:[AGXDataMatrixECB ecbWithCount:1 dataCodewords:36]]],

                     [AGXDataMatrixVersion versionWithVersionNumber:9 symbolSizeRows:26 symbolSizeColumns:26 dataRegionSizeRows:24 dataRegionSizeColumns:24 ecBlocks:[AGXDataMatrixECBlocks ecBlocksWithCodewords:28 ecBlocks:[AGXDataMatrixECB ecbWithCount:1 dataCodewords:44]]],

                     [AGXDataMatrixVersion versionWithVersionNumber:10 symbolSizeRows:32 symbolSizeColumns:32 dataRegionSizeRows:14 dataRegionSizeColumns:14 ecBlocks:[AGXDataMatrixECBlocks ecBlocksWithCodewords:36 ecBlocks:[AGXDataMatrixECB ecbWithCount:1 dataCodewords:62]]],

                     [AGXDataMatrixVersion versionWithVersionNumber:11 symbolSizeRows:36 symbolSizeColumns:36 dataRegionSizeRows:16 dataRegionSizeColumns:16 ecBlocks:[AGXDataMatrixECBlocks ecBlocksWithCodewords:42 ecBlocks:[AGXDataMatrixECB ecbWithCount:1 dataCodewords:86]]],

                     [AGXDataMatrixVersion versionWithVersionNumber:12 symbolSizeRows:40 symbolSizeColumns:40 dataRegionSizeRows:18 dataRegionSizeColumns:18 ecBlocks:[AGXDataMatrixECBlocks ecBlocksWithCodewords:48 ecBlocks:[AGXDataMatrixECB ecbWithCount:1 dataCodewords:114]]],

                     [AGXDataMatrixVersion versionWithVersionNumber:13 symbolSizeRows:44 symbolSizeColumns:44 dataRegionSizeRows:20 dataRegionSizeColumns:20 ecBlocks:[AGXDataMatrixECBlocks ecBlocksWithCodewords:56 ecBlocks:[AGXDataMatrixECB ecbWithCount:1 dataCodewords:144]]],

                     [AGXDataMatrixVersion versionWithVersionNumber:14 symbolSizeRows:48 symbolSizeColumns:48 dataRegionSizeRows:22 dataRegionSizeColumns:22 ecBlocks:[AGXDataMatrixECBlocks ecBlocksWithCodewords:68 ecBlocks:[AGXDataMatrixECB ecbWithCount:1 dataCodewords:174]]],

                     [AGXDataMatrixVersion versionWithVersionNumber:15 symbolSizeRows:52 symbolSizeColumns:52 dataRegionSizeRows:24 dataRegionSizeColumns:24 ecBlocks:[AGXDataMatrixECBlocks ecBlocksWithCodewords:42 ecBlocks:[AGXDataMatrixECB ecbWithCount:2 dataCodewords:102]]],

                     [AGXDataMatrixVersion versionWithVersionNumber:16 symbolSizeRows:64 symbolSizeColumns:64 dataRegionSizeRows:14 dataRegionSizeColumns:14 ecBlocks:[AGXDataMatrixECBlocks ecBlocksWithCodewords:56 ecBlocks:[AGXDataMatrixECB ecbWithCount:2 dataCodewords:140]]],

                     [AGXDataMatrixVersion versionWithVersionNumber:17 symbolSizeRows:72 symbolSizeColumns:72 dataRegionSizeRows:16 dataRegionSizeColumns:16 ecBlocks:[AGXDataMatrixECBlocks ecBlocksWithCodewords:36 ecBlocks:[AGXDataMatrixECB ecbWithCount:4 dataCodewords:92]]],

                     [AGXDataMatrixVersion versionWithVersionNumber:18 symbolSizeRows:80 symbolSizeColumns:80 dataRegionSizeRows:18 dataRegionSizeColumns:18 ecBlocks:[AGXDataMatrixECBlocks ecBlocksWithCodewords:48 ecBlocks:[AGXDataMatrixECB ecbWithCount:4 dataCodewords:114]]],

                     [AGXDataMatrixVersion versionWithVersionNumber:19 symbolSizeRows:88 symbolSizeColumns:88 dataRegionSizeRows:20 dataRegionSizeColumns:20 ecBlocks:[AGXDataMatrixECBlocks ecBlocksWithCodewords:56 ecBlocks:[AGXDataMatrixECB ecbWithCount:4 dataCodewords:144]]],

                     [AGXDataMatrixVersion versionWithVersionNumber:20 symbolSizeRows:96 symbolSizeColumns:96 dataRegionSizeRows:22 dataRegionSizeColumns:22 ecBlocks:[AGXDataMatrixECBlocks ecBlocksWithCodewords:68 ecBlocks:[AGXDataMatrixECB ecbWithCount:4 dataCodewords:174]]],

                     [AGXDataMatrixVersion versionWithVersionNumber:21 symbolSizeRows:104 symbolSizeColumns:104 dataRegionSizeRows:24 dataRegionSizeColumns:24 ecBlocks:[AGXDataMatrixECBlocks ecBlocksWithCodewords:56 ecBlocks:[AGXDataMatrixECB ecbWithCount:6 dataCodewords:136]]],

                     [AGXDataMatrixVersion versionWithVersionNumber:22 symbolSizeRows:120 symbolSizeColumns:120 dataRegionSizeRows:18 dataRegionSizeColumns:18 ecBlocks:[AGXDataMatrixECBlocks ecBlocksWithCodewords:68 ecBlocks:[AGXDataMatrixECB ecbWithCount:6 dataCodewords:175]]],

                     [AGXDataMatrixVersion versionWithVersionNumber:23 symbolSizeRows:132 symbolSizeColumns:132 dataRegionSizeRows:20 dataRegionSizeColumns:20 ecBlocks:[AGXDataMatrixECBlocks ecBlocksWithCodewords:62 ecBlocks:[AGXDataMatrixECB ecbWithCount:8 dataCodewords:163]]],

                     [AGXDataMatrixVersion versionWithVersionNumber:24 symbolSizeRows:144 symbolSizeColumns:144 dataRegionSizeRows:22 dataRegionSizeColumns:22 ecBlocks:[AGXDataMatrixECBlocks ecBlocksWithCodewords:62 ecBlocks1:[AGXDataMatrixECB ecbWithCount:8 dataCodewords:156] ecBlocks2:[AGXDataMatrixECB ecbWithCount:2 dataCodewords:155]]],

                     [AGXDataMatrixVersion versionWithVersionNumber:25 symbolSizeRows:8 symbolSizeColumns:18 dataRegionSizeRows:6 dataRegionSizeColumns:16 ecBlocks:[AGXDataMatrixECBlocks ecBlocksWithCodewords:7 ecBlocks:[AGXDataMatrixECB ecbWithCount:1 dataCodewords:5]]],

                     [AGXDataMatrixVersion versionWithVersionNumber:26 symbolSizeRows:8 symbolSizeColumns:32 dataRegionSizeRows:6 dataRegionSizeColumns:14 ecBlocks:[AGXDataMatrixECBlocks ecBlocksWithCodewords:11 ecBlocks:[AGXDataMatrixECB ecbWithCount:1 dataCodewords:10]]],

                     [AGXDataMatrixVersion versionWithVersionNumber:27 symbolSizeRows:12 symbolSizeColumns:26 dataRegionSizeRows:10 dataRegionSizeColumns:24 ecBlocks:[AGXDataMatrixECBlocks ecBlocksWithCodewords:14 ecBlocks:[AGXDataMatrixECB ecbWithCount:1 dataCodewords:16]]],

                     [AGXDataMatrixVersion versionWithVersionNumber:28 symbolSizeRows:12 symbolSizeColumns:36 dataRegionSizeRows:10 dataRegionSizeColumns:16 ecBlocks:[AGXDataMatrixECBlocks ecBlocksWithCodewords:18 ecBlocks:[AGXDataMatrixECB ecbWithCount:1 dataCodewords:22]]],
                     
                     [AGXDataMatrixVersion versionWithVersionNumber:29 symbolSizeRows:16 symbolSizeColumns:36 dataRegionSizeRows:14 dataRegionSizeColumns:16 ecBlocks:[AGXDataMatrixECBlocks ecBlocksWithCodewords:24 ecBlocks:[AGXDataMatrixECB ecbWithCount:1 dataCodewords:32]]],
                     
                     [AGXDataMatrixVersion versionWithVersionNumber:30 symbolSizeRows:16 symbolSizeColumns:48 dataRegionSizeRows:14 dataRegionSizeColumns:22 ecBlocks:[AGXDataMatrixECBlocks ecBlocksWithCodewords:28 ecBlocks:[AGXDataMatrixECB ecbWithCount:1 dataCodewords:49]]],

                    nil];
    });
}

@end

@implementation AGXDataMatrixECBlocks

+ (AGX_INSTANCETYPE)ecBlocksWithCodewords:(int)ecCodewords ecBlocks:(AGXDataMatrixECB *)ecBlocks {
    return AGX_AUTORELEASE([[self alloc] initWithCodewords:ecCodewords ecBlocks:ecBlocks]);
}

+ (AGX_INSTANCETYPE)ecBlocksWithCodewords:(int)ecCodewords ecBlocks1:(AGXDataMatrixECB *)ecBlocks1 ecBlocks2:(AGXDataMatrixECB *)ecBlocks2 {
    return AGX_AUTORELEASE([[self alloc] initWithCodewords:ecCodewords ecBlocks1:ecBlocks1 ecBlocks2:ecBlocks2]);
}

- (AGX_INSTANCETYPE)initWithCodewords:(int)ecCodewords ecBlocks:(AGXDataMatrixECB *)ecBlocks {
    if AGX_EXPECT_T(self = [super init]) {
        _ecCodewords = ecCodewords;
        _ecBlocks = [[NSArray alloc] initWithObjects:ecBlocks, nil];
    }
    return self;
}

- (AGX_INSTANCETYPE)initWithCodewords:(int)ecCodewords ecBlocks1:(AGXDataMatrixECB *)ecBlocks1 ecBlocks2:(AGXDataMatrixECB *)ecBlocks2 {
    if AGX_EXPECT_T(self = [super init]) {
        _ecCodewords = ecCodewords;
        _ecBlocks = [[NSArray alloc] initWithObjects:ecBlocks1, ecBlocks2, nil];
    }
    return self;
}

- (void)dealloc {
    AGX_RELEASE(_ecBlocks);
    AGX_SUPER_DEALLOC;
}

@end


@implementation AGXDataMatrixECB

+ (AGX_INSTANCETYPE)ecbWithCount:(int)count dataCodewords:(int)dataCodeword {
    return AGX_AUTORELEASE([[self alloc] initWithCount:count dataCodewords:dataCodeword]);
}

- (AGX_INSTANCETYPE)initWithCount:(int)count dataCodewords:(int)dataCodewords {
    if AGX_EXPECT_T(self = [super init]) {
        _count = count;
        _dataCodewords = dataCodewords;
    }
    return self;
}

@end
