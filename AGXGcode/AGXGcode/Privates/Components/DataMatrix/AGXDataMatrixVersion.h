//
//  AGXDataMatrixVersion.h
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

#ifndef AGXGcode_AGXDataMatrixVersion_h
#define AGXGcode_AGXDataMatrixVersion_h

#import <AGXCore/AGXCore/AGXObjC.h>

@class AGXDataMatrixECBlocks, AGXDataMatrixECB;

@interface AGXDataMatrixVersion : NSObject
@property (nonatomic, readonly) AGXDataMatrixECBlocks *ecBlocks;
@property (nonatomic, readonly) int dataRegionSizeColumns;
@property (nonatomic, readonly) int dataRegionSizeRows;
@property (nonatomic, readonly) int symbolSizeColumns;
@property (nonatomic, readonly) int symbolSizeRows;
@property (nonatomic, readonly) int totalCodewords;
@property (nonatomic, readonly) int versionNumber;

+ (AGX_INSTANCETYPE)versionForDimensions:(int)numRows numColumns:(int)numColumns;
@end

@interface AGXDataMatrixECBlocks : NSObject
@property (nonatomic, readonly) NSArray *ecBlocks;
@property (nonatomic, readonly) int ecCodewords;

+ (AGX_INSTANCETYPE)ecBlocksWithCodewords:(int)ecCodewords ecBlocks:(AGXDataMatrixECB *)ecBlocks;
+ (AGX_INSTANCETYPE)ecBlocksWithCodewords:(int)ecCodewords ecBlocks1:(AGXDataMatrixECB *)ecBlocks1 ecBlocks2:(AGXDataMatrixECB *)ecBlocks2;
@end

@interface AGXDataMatrixECB : NSObject
@property (nonatomic, readonly) int count;
@property (nonatomic, readonly) int dataCodewords;

+ (AGX_INSTANCETYPE)ecbWithCount:(int)count dataCodewords:(int)dataCodeword;
@end

#endif /* AGXGcode_AGXDataMatrixVersion_h */
