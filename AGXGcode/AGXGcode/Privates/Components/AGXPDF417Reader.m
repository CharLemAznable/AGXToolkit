//
//  AGXPDF417Reader.m
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

#import <AGXCore/AGXCore/AGXMath.h>
#import "AGXPDF417Reader.h"
#import "UIImage+AGXGcode.h"
#import "AGXPDF417Common.h"
#import "AGXPDF417Detector.h"
#import "AGXPDF417ScanningDecoder.h"

@implementation AGXPDF417Reader

- (AGXGcodeResult *)decode:(UIImage *)image hints:(AGXDecodeHints *)hints error:(NSError **)error {
    AGXPDF417DetectorResult *detectorResult = [AGXPDF417Detector detect:image.AGXBinaryBitmap hints:hints error:error];
    if (!detectorResult) return nil;

    for (NSArray *points in detectorResult.points) {
        NSValue *imageTopLeft = points[4] == [NSNull null] ? nil : points[4];
        NSValue *imageBottomLeft = points[5] == [NSNull null] ? nil : points[5];
        NSValue *imageTopRight = points[6] == [NSNull null] ? nil : points[6];
        NSValue *imageBottomRight = points[7] == [NSNull null] ? nil : points[7];

        AGXDecoderResult *decoderResult = [AGXPDF417ScanningDecoder decode:detectorResult.bits imageTopLeft:imageTopLeft imageBottomLeft:imageBottomLeft imageTopRight:imageTopRight imageBottomRight:imageBottomRight minCodewordWidth:[self minCodewordWidth:points] maxCodewordWidth:[self maxCodewordWidth:points] error:error];
        if (!decoderResult) return nil;
        return [AGXGcodeResult resultWithText:decoderResult.text format:kGcodeFormatPDF417];
    }
    return nil;
}

- (void)reset {}

- (int)minCodewordWidth:(NSArray *)p {
    return MIN(MIN([self minWidth:p[0] p2:p[4]], [self minWidth:p[6] p2:p[2]] * AGX_PDF417_MODULES_IN_CODEWORD /
                   AGX_PDF417_MODULES_IN_STOP_PATTERN),
               MIN([self minWidth:p[1] p2:p[5]], [self minWidth:p[7] p2:p[3]] * AGX_PDF417_MODULES_IN_CODEWORD /
                   AGX_PDF417_MODULES_IN_STOP_PATTERN));
}

- (int)minWidth:(NSValue *)p1 p2:(NSValue *)p2 {
    if (!p1 || !p2 || (id)p1 == [NSNull null] || p2 == (id)[NSNull null]) {
        return INT_MAX;
    }
    return cgfabs(p1.CGPointValue.x - p2.CGPointValue.x);
}

- (int)maxCodewordWidth:(NSArray *)p {
    return MAX(MAX([self maxWidth:p[0] p2:p[4]], [self maxWidth:p[6] p2:p[2]] * AGX_PDF417_MODULES_IN_CODEWORD /
                   AGX_PDF417_MODULES_IN_STOP_PATTERN),
               MAX([self maxWidth:p[1] p2:p[5]], [self maxWidth:p[7] p2:p[3]] * AGX_PDF417_MODULES_IN_CODEWORD /
                   AGX_PDF417_MODULES_IN_STOP_PATTERN));
}

- (int)maxWidth:(NSValue *)p1 p2:(NSValue *)p2 {
    if (!p1 || !p2 || (id)p1 == [NSNull null] || p2 == (id)[NSNull null]) {
        return 0;
    }
    return cgfabs(p1.CGPointValue.x - p2.CGPointValue.x);
}

@end
