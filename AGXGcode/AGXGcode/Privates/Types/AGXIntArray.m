//
//  AGXIntArray.m
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
#import "AGXIntArray.h"

@implementation AGXIntArray

+ (AGX_INSTANCETYPE)intArrayWithLength:(unsigned int)length {
    return AGX_AUTORELEASE([[AGXIntArray alloc] initWithLength:length]);
}

+ (AGX_INSTANCETYPE)intArrayWithInts:(int32_t)int1, ... {
    va_list args;
    va_start(args, int1);
    unsigned int length = 0;
    for (int32_t i = int1; i != -1; i = va_arg(args, int)) {
        length++;
    }
    va_end(args);

    AGXIntArray *ints = nil;
    if (length > 0) {
        int32_t *array = (int32_t *)calloc(length, sizeof(int32_t));
        va_list args;
        va_start(args, int1);
        int i = 0;
        for (int32_t c = int1; c != -1; c = va_arg(args, int)) {
            array[i++] = c;
        }
        va_end(args);
        ints = [[AGXIntArray alloc] initWithLength:length array:array];
        free(array);
    } else ints = [[AGXIntArray alloc] initWithLength:0 array:NULL];
    return AGX_AUTORELEASE(ints);
}

- (AGX_INSTANCETYPE)initWithLength:(unsigned int)length {
    if (length > 0) {
        int32_t *array = (int32_t *)calloc(length, sizeof(int32_t));
        memset(array, 0, length * sizeof(int32_t));
        self = [self initWithLength:length array:array];
        free(array);
    } else self = [self initWithLength:0 array:NULL];
    return self;
}

- (AGX_INSTANCETYPE)initWithInts:(int32_t)int1, ... {
    va_list args;
    va_start(args, int1);
    unsigned int length = 0;
    for (int32_t i = int1; i != -1; i = va_arg(args, int)) {
        length++;
    }
    va_end(args);

    if (length > 0) {
        int32_t *array = (int32_t *)calloc(length, sizeof(int32_t));
        va_list args;
        va_start(args, int1);
        int i = 0;
        for (int32_t c = int1; c != -1; c = va_arg(args, int)) {
            array[i++] = c;
        }
        va_end(args);
        self = [self initWithLength:length array:array];
        free(array);
    } else self = [self initWithLength:0 array:NULL];
    return self;
}

- (AGX_INSTANCETYPE)initWithLength:(unsigned int)length array:(int32_t *)array {
    if AGX_EXPECT_T(self = [super init]) {
        _length = length;
        if (length > 0) {
            _array = (int32_t *)calloc(length, sizeof(int32_t));
            memcpy(_array, array, length * sizeof(int32_t));
        } else {
            _array = NULL;
        }
    }
    return self;
}

- (void)dealloc {
    if (_array) free(_array);
    AGX_SUPER_DEALLOC;
}

- (void)clear {
    memset(_array, 0, _length * sizeof(int32_t));
}

- (int)sum {
    int sum = 0;
    for (int i = 0; i < _length; i++) {
        sum += _array[i];
    }
    return sum;
}

- (NSString *)description {
    NSMutableString *s = [NSMutableString stringWithFormat:@"length=%u, array=(", _length];

    for (int i = 0; i < _length; i++) {
        [s appendFormat:@"%d", _array[i]];
        if AGX_EXPECT_T(i < _length - 1) [s appendString:@", "];
    }

    [s appendString:@")"];
    return s;
}

- (id)copyWithZone:(NSZone *)zone {
    AGXIntArray *copy = [[AGXIntArray allocWithZone:zone] initWithLength:_length];
    memcpy(copy.array, _array, _length * sizeof(int32_t));
    return copy;
}

@end
