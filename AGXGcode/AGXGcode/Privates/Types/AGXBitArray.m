//
//  AGXBitArray.m
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

#import <AGXCore/AGXCore/AGXArc.h>
#import "AGXBitArray.h"

@implementation AGXBitArray {
    int _bitsLength;
}

+ (AGX_INSTANCETYPE)bitArrayWithSize:(int)size {
    return AGX_AUTORELEASE([[self alloc] initWithSize:size]);
}

- (AGX_INSTANCETYPE)init {
    if (AGX_EXPECT_T(self = [super init])) {
        _size = 0;
        _bitsLength = 1;
        _bits = (int32_t *)calloc(1, sizeof(int32_t));
    }
    return self;
}

- (AGX_INSTANCETYPE)initWithSize:(int)size {
    if (AGX_EXPECT_T(self = [super init])) {
        _size = size;
        _bitsLength = (size + 31) / 32;
        _bits = (int32_t *)calloc(_bitsLength, sizeof(int32_t));
    }
    return self;
}

- (void)dealloc {
    if (_bits != NULL) free(_bits);
    AGX_SUPER_DEALLOC;
}

- (int)sizeInBytes {
    return (_size + 7) / 8;
}

- (void)ensureCapacity:(int)size {
    if (size > _bitsLength * 32) {
        int newBitsLength = (size + 31) / 32;
        _bits = realloc(_bits, newBitsLength * sizeof(int32_t));
        memset(_bits + _bitsLength, 0, (newBitsLength - _bitsLength) * sizeof(int32_t));
        _bitsLength = newBitsLength;
    }
}

- (BOOL)get:(int)i {
    return (_bits[i / 32] & (1 << (i & 0x1F))) != 0;
}

- (void)set:(int)i {
    _bits[i / 32] |= 1 << (i & 0x1F);
}

- (void)flip:(int)i {
    _bits[i / 32] ^= 1 << (i & 0x1F);
}

- (int)nextSet:(int)from {
    if (from >= _size) return _size;

    int bitsOffset = from / 32;
    int32_t currentBits = _bits[bitsOffset];
    // mask off lesser bits first
    currentBits &= ~((1 << (from & 0x1F)) - 1);
    while (currentBits == 0) {
        if (++bitsOffset == _bitsLength) {
            return _size;
        }
        currentBits = _bits[bitsOffset];
    }
    int result = (bitsOffset * 32) + [self numberOfTrailingZeros:currentBits];
    return result > _size ? _size : result;
}

- (int)nextUnset:(int)from {
    if (from >= _size) return _size;

    int bitsOffset = from / 32;
    int32_t currentBits = ~_bits[bitsOffset];
    // mask off lesser bits first
    currentBits &= ~((1 << (from & 0x1F)) - 1);
    while (currentBits == 0) {
        if (++bitsOffset == _bitsLength) {
            return _size;
        }
        currentBits = ~_bits[bitsOffset];
    }
    int result = (bitsOffset * 32) + [self numberOfTrailingZeros:currentBits];
    return result > _size ? _size : result;
}

- (void)setBulk:(int)i newBits:(int32_t)newBits {
    _bits[i / 32] = newBits;
}

- (void)setRange:(int)start end:(int)end {
    if (end < start) {
        @throw [NSException exceptionWithName:NSInvalidArgumentException reason:@"Start greater than end" userInfo:nil];
    }
    if (end == start) return;

    end--; // will be easier to treat this as the last actually set bit -- inclusive
    int firstInt = start / 32;
    int lastInt = end / 32;
    for (int i = firstInt; i <= lastInt; i++) {
        int firstBit = i > firstInt ? 0 : start & 0x1F;
        int lastBit = i < lastInt ? 31 : end & 0x1F;
        int32_t mask;
        if (lastBit > 31) {
            @throw [NSException exceptionWithName:NSInvalidArgumentException reason:@"Bit-shift operand does not support more than 31 bits" userInfo:nil];
        }
        if (firstBit == 0 && lastBit == 31) {
            mask = -1;
        } else {
            mask = 0;
            for (int j = firstBit; j <= lastBit; j++) {
                mask |= 1 << j;
            }
        }
        _bits[i] |= mask;
    }
}

- (void)clear {
    memset(_bits, 0, _bitsLength * sizeof(int32_t));
}

- (BOOL)isRange:(int)start end:(int)end value:(BOOL)value {
    if (end < start) {
        @throw [NSException exceptionWithName:NSInvalidArgumentException reason:@"Start greater than end" userInfo:nil];
    }
    if (end == start) return YES; // empty range matches

    end--; // will be easier to treat this as the last actually set bit -- inclusive
    int firstInt = start / 32;
    int lastInt = end / 32;
    for (int i = firstInt; i <= lastInt; i++) {
        int firstBit = i > firstInt ? 0 : start & 0x1F;
        int lastBit = i < lastInt ? 31 : end & 0x1F;
        int32_t mask;
        if (lastBit > 31) {
            @throw [NSException exceptionWithName:NSInvalidArgumentException reason:@"Bit-shift operand does not support more than 31 bits" userInfo:nil];
        }
        if (firstBit == 0 && lastBit == 31) {
            mask = -1;
        } else {
            mask = 0;
            for (int j = firstBit; j <= lastBit; j++) {
                mask |= 1 << j;
            }
        }

        // Return false if we're looking for 1s and the masked bits[i] isn't all 1s (that is,
        // equals the mask, or we're looking for 0s and the masked portion is not all 0s
        if ((_bits[i] & mask) != (value ? mask : 0)) {
            return NO;
        }
    }

    return YES;
}

- (void)appendBit:(BOOL)bit {
    [self ensureCapacity:_size + 1];
    if (bit) {
        _bits[_size / 32] |= 1 << (_size & 0x1F);
    }
    _size++;
}

- (void)appendBits:(int32_t)value numBits:(int)numBits {
    if (numBits < 0 || numBits > 32) {
        @throw [NSException exceptionWithName:NSInvalidArgumentException
                                       reason:@"Num bits must be between 0 and 32"
                                     userInfo:nil];
    }
    [self ensureCapacity:_size + numBits];
    for (int numBitsLeft = numBits; numBitsLeft > 0; numBitsLeft--) {
        [self appendBit:((value >> (numBitsLeft - 1)) & 0x01) == 1];
    }
}

- (void)appendBitArray:(AGXBitArray *)other {
    int otherSize = [other size];
    [self ensureCapacity:_size + otherSize];

    for (int i = 0; i < otherSize; i++) {
        [self appendBit:[other get:i]];
    }
}

- (void)xor:(AGXBitArray *)other {
    if (_bitsLength != [[other valueForKey:@"bitsLength"] intValue]) {
        @throw [NSException exceptionWithName:NSInvalidArgumentException
                                       reason:@"Sizes don't match"
                                     userInfo:nil];
    }

    for (int i = 0; i < _bitsLength; i++) {
        // The last byte could be incomplete (i.e. not have 8 bits in
        // it) but there is no problem since 0 XOR 0 == 0.
        _bits[i] ^= other.bits[i];
    }
}

- (void)toBytes:(int)bitOffset array:(AGXByteArray *)array offset:(int)offset numBytes:(int)numBytes {
    for (int i = 0; i < numBytes; i++) {
        int32_t theByte = 0;
        for (int j = 0; j < 8; j++) {
            if ([self get:bitOffset]) {
                theByte |= 1 << (7 - j);
            }
            bitOffset++;
        }
        array.array[offset + i] = (int8_t) theByte;
    }
}

- (AGXIntArray *)bitArray {
    AGXIntArray *array = [AGXIntArray intArrayWithLength:_bitsLength];
    memcpy(array.array, _bits, array.length * sizeof(int32_t));
    return array;
}

- (BOOL)isEqual:(id)o {
    if (![o isKindOfClass:[AGXBitArray class]]) return NO;

    AGXBitArray *other = (AGXBitArray *)o;
    return _size == other.size && memcmp(_bits, other.bits, _bitsLength) != 0;
}

- (NSUInteger)hash {
    return 31 * _size;
}

- (void)reverse {
    int32_t *newBits = (int32_t *)calloc(_bitsLength, sizeof(int32_t));
    int size = _size;

    // reverse all int's first
    int len = ((size-1) / 32);
    int oldBitsLen = len + 1;
    for (int i = 0; i < oldBitsLen; i++) {
        long x = (long) _bits[i];
        x = ((x >>  1) & 0x55555555L) | ((x & 0x55555555L) <<  1);
        x = ((x >>  2) & 0x33333333L) | ((x & 0x33333333L) <<  2);
        x = ((x >>  4) & 0x0f0f0f0fL) | ((x & 0x0f0f0f0fL) <<  4);
        x = ((x >>  8) & 0x00ff00ffL) | ((x & 0x00ff00ffL) <<  8);
        x = ((x >> 16) & 0x0000ffffL) | ((x & 0x0000ffffL) << 16);
        newBits[len - i] = (int32_t) x;
    }
    // now correct the int's if the bit size isn't a multiple of 32
    if (size != oldBitsLen * 32) {
        int leftOffset = oldBitsLen * 32 - size;
        int mask = 1;
        for (int i = 0; i < 31 - leftOffset; i++) {
            mask = (mask << 1) | 1;
        }
        int32_t currentInt = (newBits[0] >> leftOffset) & mask;
        for (int i = 1; i < oldBitsLen; i++) {
            int32_t nextInt = newBits[i];
            currentInt |= nextInt << (32 - leftOffset);
            newBits[i - 1] = currentInt;
            currentInt = (nextInt >> leftOffset) & mask;
        }
        newBits[oldBitsLen - 1] = currentInt;
    }
    if (_bits != NULL) {
        free(_bits);
    }
    _bits = newBits;
}

- (NSString *)description {
    NSMutableString *result = [NSMutableString string];

    for (int i = 0; i < _size; i++) {
        if ((i & 0x07) == 0) {
            [result appendString:@" "];
        }
        [result appendString:[self get:i] ? @"X" : @"."];
    }

    return result;
}

// Ported from OpenJDK Integer.numberOfTrailingZeros implementation
- (int32_t)numberOfTrailingZeros:(int32_t)i {
    int32_t y;
    if (i == 0) return 32;
    int32_t n = 31;
    y = i <<16; if (y != 0) { n = n -16; i = y; }
    y = i << 8; if (y != 0) { n = n - 8; i = y; }
    y = i << 4; if (y != 0) { n = n - 4; i = y; }
    y = i << 2; if (y != 0) { n = n - 2; i = y; }
    return n - (int32_t)((uint32_t)(i << 1) >> 31);
}

- (id)copyWithZone:(NSZone *)zone {
    AGXBitArray *copy = [[AGXBitArray allocWithZone:zone] initWithSize:_size];
    memcpy(copy.bits, _bits, _size * sizeof(int32_t));
    return copy;
}

@end
