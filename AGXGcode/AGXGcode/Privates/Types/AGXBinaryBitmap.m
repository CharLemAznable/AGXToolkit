//
//  AGXBinaryBitmap.m
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
#import "AGXBinaryBitmap.h"

@implementation AGXBinaryBitmap {
    AGXBinarizer *_binarizer;
    AGXBitMatrix *_matrix;
}

+ (AGX_INSTANCETYPE)binaryBitmapWithBinarizer:(AGXBinarizer *)binarizer {
    return AGX_AUTORELEASE([[self alloc] initWithBinarizer:binarizer]);
}

- (AGX_INSTANCETYPE)initWithBinarizer:(AGXBinarizer *)binarizer {
    if AGX_EXPECT_T(self = [super init]) {
        if AGX_EXPECT_F(binarizer == nil)
            [NSException raise:NSInvalidArgumentException format:@"Binarizer must be non-null."];
        _binarizer = AGX_RETAIN(binarizer);
    }
    return self;
}

- (void)dealloc {
    AGX_RELEASE(_binarizer);
    AGX_RELEASE(_matrix);
    AGX_SUPER_DEALLOC;
}

- (int)width {
    return _binarizer.width;
}

- (int)height {
    return _binarizer.height;
}

- (AGXBitArray *)blackRow:(int)y row:(AGXBitArray *)row error:(NSError **)error {
    return [_binarizer blackRow:y row:row error:error];
}

- (AGXBitMatrix *)blackMatrixWithError:(NSError **)error {
    if AGX_EXPECT_F(_matrix == nil) _matrix = AGX_RETAIN([_binarizer blackMatrixWithError:error]);
    return _matrix;
}

- (AGXBinaryBitmap *)crop:(int)left top:(int)top width:(int)aWidth height:(int)aHeight {
    return [AGXBinaryBitmap binaryBitmapWithBinarizer:
            [AGXBinarizer binarizerWithSource:
             [_binarizer.luminanceSource crop:left top:top width:aWidth height:aHeight]]];
}

- (AGXBinaryBitmap *)rotateCounterClockwise {
    return [AGXBinaryBitmap binaryBitmapWithBinarizer:
            [AGXBinarizer binarizerWithSource:
             [_binarizer.luminanceSource rotateCounterClockwise]]];
}

- (NSString *)description {
    AGXBitMatrix *matrix = [self blackMatrixWithError:nil];
    return matrix ? [matrix description] : @"";
}

@end
