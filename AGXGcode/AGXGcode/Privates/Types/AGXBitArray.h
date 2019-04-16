//
//  AGXBitArray.h
//  AGXGcode
//
//  Created by Char Aznable on 2016/7/26.
//  Copyright © 2016 github.com/CharLemAznable. All rights reserved.
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

#ifndef AGXGcode_AGXBitArray_h
#define AGXGcode_AGXBitArray_h

#import "AGXByteArray.h"
#import "AGXIntArray.h"

@interface AGXBitArray : NSObject <NSCopying>
@property (nonatomic, readonly) int32_t *bits;
@property (nonatomic, readonly) int size;

+ (AGX_INSTANCETYPE)bitArrayWithSize:(int)size;
- (AGX_INSTANCETYPE)initWithSize:(int)size;
- (int)sizeInBytes;
- (BOOL)get:(int)i;
- (void)set:(int)i;
- (void)flip:(int)i;
- (int)nextSet:(int)from;
- (int)nextUnset:(int)from;
- (void)setBulk:(int)i newBits:(int32_t)newBits;
- (void)setRange:(int)start end:(int)end;
- (void)clear;
- (BOOL)isRange:(int)start end:(int)end value:(BOOL)value;
- (void)appendBit:(BOOL)bit;
- (void)appendBits:(int32_t)value numBits:(int)numBits;
- (void)appendBitArray:(AGXBitArray *)other;
- (void)xor:(AGXBitArray *)other;
- (void)toBytes:(int)bitOffset array:(AGXByteArray *)array offset:(int)offset numBytes:(int)numBytes;
- (AGXIntArray *)bitArray;
- (void)reverse;
@end

#endif /* AGXGcode_AGXBitArray_h */
