//
//  AGXQRCodeVersion.h
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

#ifndef AGXGcode_AGXQRCodeVersion_h
#define AGXGcode_AGXQRCodeVersion_h

#import "AGXBitMatrix.h"
#import "AGXQRCodeErrorCorrectionLevel.h"

@class AGXQRCodeECB, AGXQRCodeECBlocks;

/**
 * See ISO 18004:2006 Annex D
 */
@interface AGXQRCodeVersion : NSObject
@property (nonatomic, readonly) int versionNumber;
@property (nonatomic, readonly) AGXIntArray *alignmentPatternCenters;
@property (nonatomic, readonly) NSArray *ecBlocks;
@property (nonatomic, readonly) int totalCodewords;
@property (nonatomic, readonly) int dimensionForVersion;

- (AGXQRCodeECBlocks *)ecBlocksForLevel:(AGXQRCodeErrorCorrectionLevel *)ecLevel;
+ (AGX_INSTANCETYPE)provisionalVersionForDimension:(int)dimension;
+ (AGX_INSTANCETYPE)versionForNumber:(int)versionNumber;
+ (AGX_INSTANCETYPE)decodeVersionInformation:(int)versionBits;
- (AGXBitMatrix *)buildFunctionPattern;
@end

/**
 * Encapsulates a set of error-correction blocks in one symbol version. Most versions will
 * use blocks of differing sizes within one version, so, this encapsulates the parameters for
 * each set of blocks. It also holds the number of error-correction codewords per block since it
 * will be the same across all blocks within one version.
 */
@interface AGXQRCodeECBlocks : NSObject
@property (nonatomic, readonly) int ecCodewordsPerBlock;
@property (nonatomic, readonly) int numBlocks;
@property (nonatomic, readonly) int totalECCodewords;
@property (nonatomic, readonly) NSArray *ecBlocks;

+ (AGX_INSTANCETYPE)ecBlocksWithEcCodewordsPerBlock:(int)ecCodewordsPerBlock ecBlocks:(AGXQRCodeECB *)ecBlocks;
+ (AGX_INSTANCETYPE)ecBlocksWithEcCodewordsPerBlock:(int)ecCodewordsPerBlock ecBlocks1:(AGXQRCodeECB *)ecBlocks1 ecBlocks2:(AGXQRCodeECB *)ecBlocks2;
- (AGX_INSTANCETYPE)initWithEcCodewordsPerBlock:(int)ecCodewordsPerBlock ecBlocks:(AGXQRCodeECB *)ecBlocks;
- (AGX_INSTANCETYPE)initWithEcCodewordsPerBlock:(int)ecCodewordsPerBlock ecBlocks1:(AGXQRCodeECB *)ecBlocks1 ecBlocks2:(AGXQRCodeECB *)ecBlocks2;
@end

/**
 * Encapsualtes the parameters for one error-correction block in one symbol version.
 * This includes the number of data codewords, and the number of times a block with these
 * parameters is used consecutively in the QR code version's format.
 */
@interface AGXQRCodeECB : NSObject
@property (nonatomic, readonly) int count;
@property (nonatomic, readonly) int dataCodewords;

+ (AGX_INSTANCETYPE)ecbWithCount:(int)count dataCodewords:(int)dataCodewords;
- (AGX_INSTANCETYPE)initWithCount:(int)count dataCodewords:(int)dataCodewords;
@end

#endif /* AGXGcode_AGXQRCodeVersion_h */
