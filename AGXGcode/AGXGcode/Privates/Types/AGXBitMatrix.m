//
//  AGXBitMatrix.m
//  AGXGcode
//
//  Created by Char Aznable on 2016/7/26.
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
#import "AGXBitMatrix.h"
#import "AGXBoolArray.h"

@implementation AGXBitMatrix {
    int _bitsSize;
}

+ (AGX_INSTANCETYPE)bitMatrixWithDimension:(int)dimension {
    return AGX_AUTORELEASE([[self alloc] initWithDimension:dimension]);
}

+ (AGX_INSTANCETYPE)bitMatrixWithWidth:(int)width height:(int)height {
    return AGX_AUTORELEASE([[self alloc] initWithWidth:width height:height]);
}

- (AGX_INSTANCETYPE)initWithDimension:(int)dimension {
    return [self initWithWidth:dimension height:dimension];
}

- (AGX_INSTANCETYPE)initWithWidth:(int)width height:(int)height {
    if AGX_EXPECT_T(self = [super init]) {
        if AGX_EXPECT_F(width < 1 || height < 1)
            @throw [NSException exceptionWithName:NSInvalidArgumentException reason:
                    @"Both dimensions must be greater than 0" userInfo:nil];
        _width = width;
        _height = height;
        _rowSize = (_width + 31) / 32;
        _bitsSize = _rowSize * _height;
        _bits = (int32_t *)malloc(_bitsSize * sizeof(int32_t));
        [self clear];
    }
    return self;
}

- (AGX_INSTANCETYPE)initWithWidth:(int)width height:(int)height rowSize:(int)rowSize bits:(int32_t *)bits {
    if AGX_EXPECT_T(self = [super init]) {
        _width = width;
        _height = height;
        _rowSize = rowSize;
        _bitsSize = _rowSize * _height;
        _bits = (int32_t *)malloc(_bitsSize * sizeof(int32_t));
        memcpy(_bits, bits, _bitsSize * sizeof(int32_t));
    }
    return self;
}

- (void)dealloc {
    if (_bits != NULL) free(_bits);
    AGX_SUPER_DEALLOC;
}

+ (AGXBitMatrix *)parse:(NSString *)stringRepresentation setString:(NSString *)setString unsetString:(NSString *)unsetString {
    if AGX_EXPECT_F(!stringRepresentation)
        @throw [NSException exceptionWithName:@"IllegalArgumentException" reason:
                @"stringRepresentation is required" userInfo:nil];

    AGXBoolArray *bits = [AGXBoolArray boolArrayWithLength:(unsigned int)stringRepresentation.length];
    int bitsPos = 0;
    int rowStartPos = 0;
    int rowLength = -1;
    int nRows = 0;
    int pos = 0;
    while (pos < stringRepresentation.length) {
        if ([stringRepresentation characterAtIndex:pos] == '\n' ||
            [stringRepresentation characterAtIndex:pos] == '\r') {
            if (bitsPos > rowStartPos) {
                if(rowLength == -1) {
                    rowLength = bitsPos - rowStartPos;
                } else if AGX_EXPECT_F(bitsPos - rowStartPos != rowLength) {
                    @throw [NSException exceptionWithName:@"IllegalArgumentException" reason:
                            @"row lengths do not match" userInfo:nil];
                }
                rowStartPos = bitsPos;
                nRows++;
            }
            pos++;
        } else if ([[stringRepresentation substringWithRange:NSMakeRange(pos, setString.length)] isEqualToString:setString]) {
            pos += setString.length;
            bits.array[bitsPos] = YES;
            bitsPos++;
        } else if ([[stringRepresentation substringWithRange:NSMakeRange(pos, unsetString.length)] isEqualToString:unsetString]) {
            pos += unsetString.length;
            bits.array[bitsPos] = NO;
            bitsPos++;
        } else {
            @throw [NSException exceptionWithName:@"IllegalArgumentException"
                                           reason:[NSString stringWithFormat:@"illegal character encountered: %@", [stringRepresentation substringFromIndex:pos]]
                                         userInfo:nil];
        }
    }

    // no EOL at end?
    if (bitsPos > rowStartPos) {
        if (rowLength == -1) {
            rowLength = bitsPos - rowStartPos;
        } else if AGX_EXPECT_F(bitsPos - rowStartPos != rowLength) {
            @throw [NSException exceptionWithName:@"IllegalArgumentException" reason:
                    @"row lengths do not match" userInfo:nil];
        }
        nRows++;
    }

    AGXBitMatrix *matrix = [AGXBitMatrix bitMatrixWithWidth:rowLength height:nRows];
    for (int i = 0; i < bitsPos; i++) {
        if (bits.array[i]) {
            [matrix setX:i % rowLength y:i / rowLength];
        }
    }
    return matrix;
}

- (BOOL)getX:(int)x y:(int)y {
    NSInteger offset = y * _rowSize + (x / 32);
    return ((_bits[offset] >> (x & 0x1f)) & 1) != 0;
}

- (void)setX:(int)x y:(int)y {
    NSInteger offset = y * _rowSize + (x / 32);
    _bits[offset] |= 1 << (x & 0x1f);
}

- (void)unsetX:(int)x y:(int)y {
    int offset = y * _rowSize + (x / 32);
    _bits[offset] &= ~(1 << (x & 0x1f));
}

- (void)flipX:(int)x y:(int)y {
    NSUInteger offset = y * _rowSize + (x / 32);
    _bits[offset] ^= 1 << (x & 0x1f);
}

- (void)xor:(AGXBitMatrix *)mask {
    if AGX_EXPECT_F(_width != mask.width || _height != mask.height || _rowSize != mask.rowSize)
        @throw [NSException exceptionWithName:NSInvalidArgumentException reason:
                @"input matrix dimensions do not match" userInfo:nil];

    AGXBitArray *rowArray = [AGXBitArray bitArrayWithSize:_width];
    for (int y = 0; y < _height; y++) {
        int offset = y * _rowSize;
        int32_t *row = [mask rowAtY:y row:rowArray].bits;
        for (int x = 0; x < _rowSize; x++) {
            _bits[offset + x] ^= row[x];
        }
    }
}

- (void)clear {
    memset(_bits, 0, _bitsSize * sizeof(int32_t));
}

- (void)setRegionAtLeft:(int)left top:(int)top width:(int)aWidth height:(int)aHeight {
    if AGX_EXPECT_F(aHeight < 1 || aWidth < 1)
        @throw [NSException exceptionWithName:NSInvalidArgumentException reason:
                @"Height and width must be at least 1" userInfo:nil];

    NSUInteger right = left + aWidth;
    NSUInteger bottom = top + aHeight;
    if AGX_EXPECT_F(bottom > _height || right > _width)
        @throw [NSException exceptionWithName:NSInvalidArgumentException reason:
                @"The region must fit inside the matrix" userInfo:nil];

    for (NSUInteger y = top; y < bottom; y++) {
        NSUInteger offset = y * _rowSize;
        for (NSInteger x = left; x < right; x++) {
            _bits[offset + (x / 32)] |= 1 << (x & 0x1f);
        }
    }
}

- (AGXBitArray *)rowAtY:(int)y row:(AGXBitArray *)row {
    if (row == nil || row.size < _width) {
        row = [AGXBitArray bitArrayWithSize:_width];
    } else {
        [row clear];
    }
    int offset = y * _rowSize;
    for (int x = 0; x < _rowSize; x++) {
        [row setBulk:x * 32 newBits:_bits[offset + x]];
    }

    return row;
}

- (void)setRowAtY:(int)y row:(AGXBitArray *)row {
    for (NSUInteger i = 0; i < _rowSize; i++) {
        _bits[(y * _rowSize) + i] = row.bits[i];
    }
}

- (void)rotate180 {
    int width = _width;
    int height = _height;
    AGXBitArray *topRow = [AGXBitArray bitArrayWithSize:width];
    AGXBitArray *bottomRow = [AGXBitArray bitArrayWithSize:width];
    for (int i = 0; i < (height+1) / 2; i++) {
        topRow = [self rowAtY:i row:topRow];
        bottomRow = [self rowAtY:height - 1 - i row:bottomRow];
        [topRow reverse];
        [bottomRow reverse];
        [self setRowAtY:i row:bottomRow];
        [self setRowAtY:height - 1 - i row:topRow];
    }
}

- (AGXIntArray *)enclosingRectangle {
    int left = _width;
    int top = _height;
    int right = -1;
    int bottom = -1;

    for (int y = 0; y < _height; y++) {
        for (int x32 = 0; x32 < _rowSize; x32++) {
            int32_t theBits = _bits[y * _rowSize + x32];
            if (theBits != 0) {
                if (y < top) top = y;
                if (y > bottom) bottom = y;
                if (x32 * 32 < left) {
                    int32_t bit = 0;
                    while ((theBits << (31 - bit)) == 0) {
                        bit++;
                    }
                    if ((x32 * 32 + bit) < left) {
                        left = x32 * 32 + bit;
                    }
                }
                if (x32 * 32 + 31 > right) {
                    int bit = 31;
                    while ((theBits >> bit) == 0) {
                        bit--;
                    }
                    if ((x32 * 32 + bit) > right) {
                        right = x32 * 32 + bit;
                    }
                }
            }
        }
    }

    NSInteger width = right - left;
    NSInteger height = bottom - top;

    if AGX_EXPECT_F(width < 0 || height < 0) return nil;
    return [AGXIntArray intArrayWithInts:left, top, width, height, -1];
}

- (AGXIntArray *)topLeftOnBit {
    int bitsOffset = 0;
    while (bitsOffset < _bitsSize && _bits[bitsOffset] == 0) {
        bitsOffset++;
    }
    if AGX_EXPECT_F(bitsOffset == _bitsSize) return nil;

    int y = bitsOffset / _rowSize;
    int x = (bitsOffset % _rowSize) * 32;

    int32_t theBits = _bits[bitsOffset];
    int32_t bit = 0;
    while ((theBits << (31 - bit)) == 0) {
        bit++;
    }
    x += bit;
    return [AGXIntArray intArrayWithInts:x, y, -1];
}

- (AGXIntArray *)bottomRightOnBit {
    int bitsOffset = _bitsSize - 1;
    while (bitsOffset >= 0 && _bits[bitsOffset] == 0) {
        bitsOffset--;
    }
    if AGX_EXPECT_F(bitsOffset < 0) return nil;

    int y = bitsOffset / _rowSize;
    int x = (bitsOffset % _rowSize) * 32;

    int32_t theBits = _bits[bitsOffset];
    int32_t bit = 31;
    while ((theBits >> bit) == 0) {
        bit--;
    }
    x += bit;

    return [AGXIntArray intArrayWithInts:x, y, -1];
}

- (BOOL)isEqual:(NSObject *)o {
    if AGX_EXPECT_F(!([o isKindOfClass:AGXBitMatrix.class])) return NO;

    AGXBitMatrix *other = (AGXBitMatrix *)o;
    for (int i = 0; i < _bitsSize; i++) {
        if (_bits[i] != other.bits[i]) return NO;
    }
    return _width == other.width && _height == other.height &&
    _rowSize == other.rowSize && _bitsSize == [[other valueForKey:@"bitsSize"] intValue];
}

- (NSUInteger)hash {
    NSInteger hash = _width;
    hash = 31 * hash + _width;
    hash = 31 * hash + _height;
    hash = 31 * hash + _rowSize;
    for (NSUInteger i = 0; i < _bitsSize; i++) {
        hash = 31 * hash + _bits[i];
    }
    return hash;
}

- (NSString *)description {
    return [self descriptionWithSetString:@"X " unsetString:@"  "];
}

- (NSString *)descriptionWithSetString:(NSString *)setString unsetString:(NSString *)unsetString {
    NSMutableString *result = [NSMutableString stringWithCapacity:_height * (_width + 1)];
    for (int y = 0; y < _height; y++) {
        for (int x = 0; x < _width; x++) {
            [result appendString:[self getX:x y:y] ? setString : unsetString];
        }
        [result appendString:@"\n"];
    }
    return result;
}

- (id)copyWithZone:(NSZone *)zone {
    return [[AGXBitMatrix allocWithZone:zone] initWithWidth:_width height:_height rowSize:_rowSize bits:_bits];
}

@end
