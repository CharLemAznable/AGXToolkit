//
//  AGXBitMatrix.h
//  AGXGcode
//
//  Created by Char Aznable on 16/7/26.
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

#ifndef AGXGcode_AGXBitMatrix_h
#define AGXGcode_AGXBitMatrix_h

#import "AGXBitArray.h"

@interface AGXBitMatrix : NSObject <NSCopying>
@property (nonatomic, readonly) int width;
@property (nonatomic, readonly) int height;
@property (nonatomic, readonly) int32_t *bits;
@property (nonatomic, readonly) int rowSize;

+ (AGX_INSTANCETYPE)bitMatrixWithDimension:(int)dimension;
+ (AGX_INSTANCETYPE)bitMatrixWithWidth:(int)width height:(int)height;
- (AGX_INSTANCETYPE)initWithDimension:(int)dimension;
- (AGX_INSTANCETYPE)initWithWidth:(int)width height:(int)height;
+ (AGXBitMatrix *)parse:(NSString *)stringRepresentation setString:(NSString *)setString unsetString:(NSString *)unsetString;
- (BOOL)getX:(int)x y:(int)y;
- (void)setX:(int)x y:(int)y;
- (void)unsetX:(int)x y:(int)y;
- (void)flipX:(int)x y:(int)y;
- (void)xor:(AGXBitMatrix *)mask;
- (void)clear;
- (void)setRegionAtLeft:(int)left top:(int)top width:(int)width height:(int)height;
- (AGXBitArray *)rowAtY:(int)y row:(AGXBitArray *)row;
- (void)setRowAtY:(int)y row:(AGXBitArray *)row;
- (void)rotate180;
- (AGXIntArray *)enclosingRectangle;
- (AGXIntArray *)topLeftOnBit;
- (AGXIntArray *)bottomRightOnBit;
- (NSString *)descriptionWithSetString:(NSString *)setString unsetString:(NSString *)unsetString;
@end

#endif /* AGXGcode_AGXBitMatrix_h */
