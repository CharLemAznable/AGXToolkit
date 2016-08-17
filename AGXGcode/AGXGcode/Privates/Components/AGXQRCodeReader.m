//
//  AGXQRCodeReader.m
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
#import "AGXQRCodeReader.h"
#import "UIImage+AGXGcode.h"
#import "AGXQRCodeDetector.h"
#import "AGXDecoderResult.h"
#import "AGXQRCodeDecoder.h"

@implementation AGXQRCodeReader {
    AGXQRCodeDecoder *_decoder;
}

- (AGX_INSTANCETYPE)init {
    if (self = [super init]) {
        _decoder = [[AGXQRCodeDecoder alloc] init];
    }
    return self;
}

- (void)dealloc {
    AGX_RELEASE(_decoder);
    AGX_SUPER_DEALLOC;
}

- (AGXGcodeResult *)decode:(UIImage *)image hints:(AGXDecodeHints *)hints error:(NSError **)error {
    AGXBitMatrix *matrix = [image.AGXBinaryBitmap blackMatrixWithError:error];
    if (!matrix) return nil;

    AGXDetectorResult *detectorResult = [[AGXQRCodeDetector detectorWithBits:matrix] detect:hints error:error];
    if (!detectorResult) return nil;

    AGXDecoderResult *decoderResult = [_decoder decodeMatrix:detectorResult.bits hints:hints error:error];
    if (!decoderResult) return nil;

    return [AGXGcodeResult resultWithText:decoderResult.text format:kGcodeFormatQRCode];
}

- (void)reset {}

@end
