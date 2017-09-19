//
//  AGXPDF417DetectionResultColumn.m
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
#import "AGXPDF417DetectionResultColumn.h"

const int AGX_PDF417_MAX_NEARBY_DISTANCE = 5;

@implementation AGXPDF417DetectionResultColumn

- (AGX_INSTANCETYPE)initWithBoundingBox:(AGXPDF417BoundingBox *)boundingBox {
    if (AGX_EXPECT_T(self = [super init])) {
        _boundingBox = AGX_RETAIN([AGXPDF417BoundingBox boundingBoxWithBoundingBox:boundingBox]);
        _codewords = [[NSMutableArray alloc] init];
        for (int i = 0; i < boundingBox.maxY - boundingBox.minY + 1; i++) {
            [_codewords addObject:[NSNull null]];
        }
    }
    return self;
}

- (void)dealloc {
    AGX_RELEASE(_boundingBox);
    AGX_RELEASE(_codewords);
    AGX_SUPER_DEALLOC;
}

- (int)imageRowToCodewordIndex:(int)imageRow {
    return imageRow - _boundingBox.minY;
}

- (void)setCodeword:(int)imageRow codeword:(AGXPDF417Codeword *)codeword {
    _codewords[[self imageRowToCodewordIndex:imageRow]] = codeword;
}

- (AGXPDF417Codeword *)codeword:(int)imageRow {
    NSUInteger index = [self imageRowToCodewordIndex:imageRow];
    if (_codewords[index] == [NSNull null]) {
        return nil;
    }
    return _codewords[index];
}

- (AGXPDF417Codeword *)codewordNearby:(int)imageRow {
    AGXPDF417Codeword *codeword = [self codeword:imageRow];
    if (codeword) return codeword;

    for (int i = 1; i < AGX_PDF417_MAX_NEARBY_DISTANCE; i++) {
        int nearImageRow = [self imageRowToCodewordIndex:imageRow] - i;
        if (nearImageRow >= 0) {
            codeword = _codewords[nearImageRow];
            if ((id)codeword != [NSNull null]) {
                return codeword;
            }
        }
        nearImageRow = [self imageRowToCodewordIndex:imageRow] + i;
        if (nearImageRow < [_codewords count]) {
            codeword = _codewords[nearImageRow];
            if ((id)codeword != [NSNull null]) {
                return codeword;
            }
        }
    }
    return nil;
}

- (NSString *)description {
    NSMutableString *result = [NSMutableString string];
    int row = 0;
    for (AGXPDF417Codeword *codeword in _codewords) {
        if ((id)codeword == [NSNull null]) {
            [result appendFormat:@"%3d:    |   \n", row++];
            continue;
        }
        [result appendFormat:@"%3d: %3d|%3d\n", row++, codeword.rowNumber, codeword.value];
    }
    return [NSString stringWithString:result];
}

@end
