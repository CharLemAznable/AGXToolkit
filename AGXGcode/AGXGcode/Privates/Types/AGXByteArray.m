//
//  AGXByteArray.m
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

#import <AGXCore/AGXCore/AGXArc.h>
#import "AGXByteArray.h"

@implementation AGXByteArray

+ (AGX_INSTANCETYPE)byteArrayWithLength:(unsigned int)length {
    return AGX_AUTORELEASE([[AGXByteArray alloc] initWithLength:length]);
}

- (AGX_INSTANCETYPE)initWithLength:(unsigned int)length {
    if (length > 0) {
        int8_t *array = (int8_t *)calloc(length, sizeof(int8_t));
        memset(array, 0, length * sizeof(int8_t));
        self = [self initWithLength:length array:array];
        free(array);
    } else self = [self initWithLength:0 array:NULL];
    return self;
}

- (AGX_INSTANCETYPE)initWithLength:(unsigned int)length array:(int8_t *)array {
    if AGX_EXPECT_T(self = [super init]) {
        _length = length;
        if (length > 0) {
            _array = (int8_t *)calloc(length, sizeof(int8_t));
            memcpy(_array, array, length * sizeof(int8_t));
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

- (NSString *)description {
    NSMutableString *s = [NSMutableString stringWithFormat:@"length=%u, array=(", _length];

    for (int i = 0; i < _length; i++) {
        [s appendFormat:@"%d", _array[i]];
        if AGX_EXPECT_T(i < _length - 1) {
            [s appendString:@", "];
        }
    }

    [s appendString:@")"];
    return s;
}

@end
