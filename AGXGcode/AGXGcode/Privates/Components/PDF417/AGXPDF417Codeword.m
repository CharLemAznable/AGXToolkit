//
//  AGXPDF417Codeword.m
//  AGXGcode
//
//  Created by Char Aznable on 2016/8/2.
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
#import "AGXPDF417Codeword.h"

const int AGX_PDF417_BARCODE_ROW_UNKNOWN = -1;

@implementation AGXPDF417Codeword

+ (AGX_INSTANCETYPE)codewordWithStartX:(int)startX endX:(int)endX bucket:(int)bucket value:(int)value {
    return AGX_AUTORELEASE([[self alloc] initWithStartX:startX endX:endX bucket:bucket value:value]);
}

- (AGX_INSTANCETYPE)initWithStartX:(int)startX endX:(int)endX bucket:(int)bucket value:(int)value {
    if AGX_EXPECT_T(self = [super init]) {
        _startX = startX;
        _endX = endX;
        _bucket = bucket;
        _value = value;
        _rowNumber = AGX_PDF417_BARCODE_ROW_UNKNOWN;
    }
    return self;
}

- (BOOL)hasValidRowNumber {
    return [self isValidRowNumber:_rowNumber];
}

- (BOOL)isValidRowNumber:(int)rowNumber {
    return rowNumber != AGX_PDF417_BARCODE_ROW_UNKNOWN && _bucket == (rowNumber % 3) * 3;
}

- (void)setRowNumberAsRowIndicatorColumn {
    _rowNumber = (_value / 30) * 3 + _bucket / 3;
}

- (int)width {
    return _endX - _startX;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"%d|%d", _rowNumber, _value];
}

@end
