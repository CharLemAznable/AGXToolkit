//
//  AGXDataMatrixReader.m
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
#import "AGXDataMatrixReader.h"
#import "UIImage+AGXGcode.h"
#import "AGXDataMatrixDetector.h"
#import "AGXDecoderResult.h"
#import "AGXDataMatrixDecoder.h"

@implementation AGXDataMatrixReader {
    AGXDataMatrixDecoder *_decoder;
}

- (AGX_INSTANCETYPE)init {
    if AGX_EXPECT_T(self = [super init]) {
        _decoder = [[AGXDataMatrixDecoder alloc] init];
    }
    return self;
}

- (void)dealloc {
    AGX_RELEASE(_decoder);
    AGX_SUPER_DEALLOC;
}

- (AGXGcodeResult *)decode:(UIImage *)image hints:(AGXDecodeHints *)hints error:(NSError **)error {
    AGXBitMatrix *matrix = [image.AGXBinaryBitmap blackMatrixWithError:error];
    if AGX_EXPECT_F(!matrix) return nil;

    AGXDataMatrixDetector *detector = [AGXDataMatrixDetector detectorWithBits:matrix error:error];
    if AGX_EXPECT_F(!detector) return nil;

    AGXDetectorResult *detectorResult = [detector detectWithError:error];
    if AGX_EXPECT_F(!detectorResult) return nil;

    AGXDecoderResult *decoderResult = [_decoder decodeMatrix:detectorResult.bits error:error];
    if AGX_EXPECT_F(!decoderResult) return nil;

    return [AGXGcodeResult gcodeResultWithText:decoderResult.text format:kGcodeFormatDataMatrix];
}

- (void)reset {}

@end
