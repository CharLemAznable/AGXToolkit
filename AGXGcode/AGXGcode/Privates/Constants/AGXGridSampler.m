//
//  AGXGridSampler.m
//  AGXGcode
//
//  Created by Char Aznable on 16/8/5.
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

#import "AGXGridSampler.h"
#import "AGXGcodeError.h"

@singleton_implementation(AGXGridSampler)

- (AGXBitMatrix *)sampleGrid:(AGXBitMatrix *)image dimensionX:(int)dimensionX dimensionY:(int)dimensionY p1ToX:(float)p1ToX p1ToY:(float)p1ToY p2ToX:(float)p2ToX p2ToY:(float)p2ToY p3ToX:(float)p3ToX p3ToY:(float)p3ToY p4ToX:(float)p4ToX p4ToY:(float)p4ToY p1FromX:(float)p1FromX p1FromY:(float)p1FromY p2FromX:(float)p2FromX p2FromY:(float)p2FromY p3FromX:(float)p3FromX p3FromY:(float)p3FromY p4FromX:(float)p4FromX p4FromY:(float)p4FromY error:(NSError **)error {
    AGXPerspectiveTransform *transform = [AGXPerspectiveTransform quadrilateralToQuadrilateral:p1ToX y0:p1ToY x1:p2ToX y1:p2ToY x2:p3ToX y2:p3ToY x3:p4ToX y3:p4ToY x0p:p1FromX y0p:p1FromY x1p:p2FromX y1p:p2FromY x2p:p3FromX y2p:p3FromY x3p:p4FromX y3p:p4FromY];
    return [self sampleGrid:image dimensionX:dimensionX dimensionY:dimensionY transform:transform error:error];
}

- (AGXBitMatrix *)sampleGrid:(AGXBitMatrix *)image dimensionX:(int)dimensionX dimensionY:(int)dimensionY transform:(AGXPerspectiveTransform *)transform error:(NSError **)error {
    if AGX_EXPECT_F(dimensionX <= 0 || dimensionY <= 0) {
        if AGX_EXPECT_T(error) *error = AGXNotFoundErrorInstance();
        return nil;
    }
    AGXBitMatrix *bits = [AGXBitMatrix bitMatrixWithWidth:dimensionX height:dimensionY];
    int pointsLen = 2 * dimensionX;
    float pointsf[pointsLen];
    memset(pointsf, 0, pointsLen * sizeof(float));

    for (int y = 0; y < dimensionY; y++) {
        int max = dimensionX << 1;
        float iValue = (float)y + 0.5f;
        for (int x = 0; x < max; x += 2) {
            pointsf[x] = (float) (x / 2) + 0.5f;
            pointsf[x + 1] = iValue;
        }
        [transform transformPoints:pointsf pointsLen:pointsLen];

        if AGX_EXPECT_F(![AGXGridSampler checkAndNudgePoints:image points:
                          pointsf pointsLen:pointsLen error:error]) return nil;

        for (int x = 0; x < max; x += 2) {
            int xx = (int)pointsf[x];
            int yy = (int)pointsf[x + 1];
            if AGX_EXPECT_F(xx < 0 || yy < 0 || xx >= image.width || yy >= image.height) {
                if AGX_EXPECT_T(error) *error = AGXNotFoundErrorInstance();
                return nil;
            }

            if ([image getX:xx y:yy]) {
                [bits setX:x / 2 y:y];
            }
        }
    }
    return bits;
}

+ (BOOL)checkAndNudgePoints:(AGXBitMatrix *)bits points:(float *)points pointsLen:(int)pointsLen error:(NSError **)error {
    int width = bits.width;
    int height = bits.height;
    // Check and nudge points from start until we see some that are OK:
    BOOL nudged = YES;
    for (int offset = 0; offset < pointsLen && nudged; offset += 2) {
        int x = (int) points[offset];
        int y = (int) points[offset + 1];
        if AGX_EXPECT_F(x < -1 || x > width || y < -1 || y > height) {
            if AGX_EXPECT_T(error) *error = AGXNotFoundErrorInstance();
            return NO;
        }
        nudged = NO;
        if (x == -1) {
            points[offset] = 0.0f;
            nudged = YES;
        } else if (x == width) {
            points[offset] = width - 1;
            nudged = YES;
        }
        if (y == -1) {
            points[offset + 1] = 0.0f;
            nudged = YES;
        } else if (y == height) {
            points[offset + 1] = height - 1;
            nudged = YES;
        }
    }
    // Check and nudge points from end:
    nudged = YES;
    for (int offset = pointsLen - 2; offset >= 0 && nudged; offset -= 2) {
        int x = (int) points[offset];
        int y = (int) points[offset + 1];
        if AGX_EXPECT_F(x < -1 || x > width || y < -1 || y > height) {
            if AGX_EXPECT_T(error) *error = AGXNotFoundErrorInstance();
            return NO;
        }
        nudged = NO;
        if (x == -1) {
            points[offset] = 0.0f;
            nudged = YES;
        } else if (x == width) {
            points[offset] = width - 1;
            nudged = YES;
        }
        if (y == -1) {
            points[offset + 1] = 0.0f;
            nudged = YES;
        } else if (y == height) {
            points[offset + 1] = height - 1;
            nudged = YES;
        }
    }
    return YES;
}

@end
