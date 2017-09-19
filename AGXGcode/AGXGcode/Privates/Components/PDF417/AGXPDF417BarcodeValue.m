//
//  AGXPDF417BarcodeValue.m
//  AGXGcode
//
//  Created by Char Aznable on 16/8/2.
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
#import "AGXPDF417BarcodeValue.h"
#import "AGXPDF417Common.h"

@implementation AGXPDF417BarcodeValue {
    NSMutableDictionary *_values;
}

- (AGX_INSTANCETYPE)init {
    if (AGX_EXPECT_T(self = [super init])) {
        _values = [[NSMutableDictionary alloc] init];
    }
    return self;
}

- (void)dealloc {
    AGX_RELEASE(_values);
    AGX_SUPER_DEALLOC;
}

- (void)setValue:(int)value {
    NSNumber *confidence = _values[@(value)];
    if (!confidence) {
        confidence = @0;
    }
    confidence = @([confidence intValue] + 1);
    _values[@(value)] = confidence;
}

- (AGXIntArray *)value {
    int maxConfidence = -1;
    NSMutableArray *result = [NSMutableArray array];
    for (NSNumber *key in [_values allKeys]) {
        NSNumber *value = _values[key];
        if ([value intValue] > maxConfidence) {
            maxConfidence = [value intValue];
            [result removeAllObjects];
            [result addObject:key];
        } else if ([value intValue] == maxConfidence) {
            [result addObject:key];
        }
    }
    NSArray *array = [[[result sortedArrayUsingSelector:@selector(compare:)] reverseObjectEnumerator] allObjects];
    return [AGXPDF417Common toIntArray:array];
}

- (NSNumber *)confidence:(int)value {
    return _values[@(value)];
}

@end
