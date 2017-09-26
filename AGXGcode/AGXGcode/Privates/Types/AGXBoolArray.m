//
//  AGXBoolArray.m
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
#import "AGXBoolArray.h"

@implementation AGXBoolArray

+ (AGX_INSTANCETYPE)boolArrayWithLength:(unsigned int)length {
    return AGX_AUTORELEASE([[AGXBoolArray alloc] initWithLength:length]);
}

- (AGX_INSTANCETYPE)initWithLength:(unsigned int)length {
    if AGX_EXPECT_T(self = [super init]) {
        _array = (BOOL *)calloc(length, sizeof(BOOL));
        _length = length;
    }

    return self;
}

- (void)dealloc {
    if (_array) free(_array);
    AGX_SUPER_DEALLOC;
}

@end
