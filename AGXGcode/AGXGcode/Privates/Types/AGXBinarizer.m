//
//  AGXBinarizer.m
//  AGXGcode
//
//  Created by Char Aznable on 16/7/27.
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
#import "AGXBinarizer.h"
#import "AGXGcodeError.h"

const int AGX_LUMINANCE_BITS = 5;
const int AGX_LUMINANCE_SHIFT = 8 - AGX_LUMINANCE_BITS;
const int AGX_LUMINANCE_BUCKETS = 1 << AGX_LUMINANCE_BITS;

const int AGX_BLOCK_SIZE_POWER = 3;
const int AGX_BLOCK_SIZE = 1 << AGX_BLOCK_SIZE_POWER; // ...0100...00
const int AGX_BLOCK_SIZE_MASK = AGX_BLOCK_SIZE - 1;   // ...0011...11
const int AGX_MINIMUM_DIMENSION = AGX_BLOCK_SIZE * 5;
const int AGX_MIN_DYNAMIC_RANGE = 24;

@implementation AGXBinarizer {
    AGXByteArray *_row;
    AGXIntArray *_buckets;
    AGXBitMatrix *_matrix;
}

+ (AGX_INSTANCETYPE)binarizerWithSource:(AGXLuminanceSource *)source {
    return AGX_AUTORELEASE([[self alloc] initWithSource:source]);
}

- (AGX_INSTANCETYPE)initWithSource:(AGXLuminanceSource *)source {
    if (AGX_EXPECT_T(self = [super init])) {
        _luminanceSource = AGX_RETAIN(source);
        _row = [[AGXByteArray alloc] initWithLength:0];
        _buckets = [[AGXIntArray alloc] initWithLength:AGX_LUMINANCE_BUCKETS];
    }
    return self;
}

- (void)dealloc {
    AGX_RELEASE(_luminanceSource);
    AGX_RELEASE(_row);
    AGX_RELEASE(_buckets);
    AGX_RELEASE(_matrix);
    AGX_SUPER_DEALLOC;
}

- (int)width {
    return _luminanceSource.width;
}

- (int)height {
    return _luminanceSource.height;
}

- (AGXBitArray *)blackRow:(int)y row:(AGXBitArray *)row error:(NSError **)error {
    int width = _luminanceSource.width;
    if (row == nil || row.size < width) {
        row = [AGXBitArray bitArrayWithSize:width];
    } else {
        [row clear];
    }

    [self initializeArrays:width];
    AGXByteArray *localRow = [_luminanceSource rowAtY:y row:_row];
    AGXIntArray *localBuckets = _buckets;
    for (int x = 0; x < width; x++) {
        int pixel = localRow.array[x] & 0xff;
        localBuckets.array[pixel >> AGX_LUMINANCE_SHIFT]++;
    }
    int blackPoint = [self estimateBlackPoint:localBuckets];
    if (blackPoint == -1) {
        if (error) *error = AGXNotFoundErrorInstance();
        return nil;
    }

    int left = localRow.array[0] & 0xff;
    int center = localRow.array[1] & 0xff;
    for (int x = 1; x < width - 1; x++) {
        int right = localRow.array[x + 1] & 0xff;
        // A simple -1 4 -1 box filter with a weight of 2.
        int luminance = ((center * 4) - left - right) >> 1;
        if (luminance < blackPoint) {
            [row set:x];
        }
        left = center;
        center = right;
    }

    return row;
}

- (AGXBitMatrix *)blackMatrixWithError:(NSError **)error {
    if (_matrix != nil) return _matrix;

    int width = _luminanceSource.width;
    int height = _luminanceSource.height;
    if (width >= AGX_MINIMUM_DIMENSION && height >= AGX_MINIMUM_DIMENSION) {
        AGXByteArray *luminances = _luminanceSource.matrix;
        int subWidth = width >> AGX_BLOCK_SIZE_POWER;
        if ((width & AGX_BLOCK_SIZE_MASK) != 0) {
            subWidth++;
        }
        int subHeight = height >> AGX_BLOCK_SIZE_POWER;
        if ((height & AGX_BLOCK_SIZE_MASK) != 0) {
            subHeight++;
        }
        int **blackPoints = [self calculateBlackPoints:luminances.array subWidth:subWidth subHeight:subHeight width:width height:height];

        AGXBitMatrix *newMatrix = [AGXBitMatrix bitMatrixWithWidth:width height:height];
        [self calculateThresholdForBlock:luminances.array subWidth:subWidth subHeight:subHeight width:width height:height blackPoints:blackPoints matrix:newMatrix];
        _matrix = AGX_RETAIN(newMatrix);

        for (int i = 0; i < subHeight; i++) {
            free(blackPoints[i]);
        }
        free(blackPoints);
    } else { // If the image is too small
        AGXBitMatrix *newMatrix = [AGXBitMatrix bitMatrixWithWidth:width height:height];

        // Quickly calculates the histogram by sampling four rows from the image. This proved to be
        // more robust on the blackbox tests than sampling a diagonal as we used to do.
        [self initializeArrays:width];

        // We delay reading the entire image luminance until the black point estimation succeeds.
        // Although we end up reading four rows twice, it is consistent with our motto of
        // "fail quickly" which is necessary for continuous scanning.
        AGXIntArray *localBuckets = _buckets;
        for (int y = 1; y < 5; y++) {
            int row = height * y / 5;
            AGXByteArray *localRow = [_luminanceSource rowAtY:row row:_row];
            int right = (width * 4) / 5;
            for (int x = width / 5; x < right; x++) {
                int pixel = localRow.array[x] & 0xff;
                localBuckets.array[pixel >> AGX_LUMINANCE_SHIFT]++;
            }
        }
        int blackPoint = [self estimateBlackPoint:localBuckets];
        if (blackPoint == -1) {
            if (error) *error = AGXNotFoundErrorInstance();
            return nil;
        }

        AGXByteArray *localLuminances = _luminanceSource.matrix;
        for (int y = 0; y < height; y++) {
            int offset = y * width;
            for (int x = 0; x < width; x++) {
                int pixel = localLuminances.array[offset + x] & 0xff;
                if (pixel < blackPoint) {
                    [newMatrix setX:x y:y];
                }
            }
        }
        _matrix = AGX_RETAIN(newMatrix);
    }
    return _matrix;
}

- (void)initializeArrays:(int)luminanceSize {
    if (_row.length < luminanceSize) {
        AGX_RELEASE(_row);
        _row = [[AGXByteArray alloc] initWithLength:luminanceSize];
    }

    for (int x = 0; x < AGX_LUMINANCE_BUCKETS; x++) {
        _buckets.array[x] = 0;
    }
}

- (int)estimateBlackPoint:(AGXIntArray *)buckets {
    // Find the tallest peak in the histogram.
    int numBuckets = buckets.length;
    int maxBucketCount = 0;
    int firstPeak = 0;
    int firstPeakSize = 0;
    for (int x = 0; x < numBuckets; x++) {
        if (buckets.array[x] > firstPeakSize) {
            firstPeak = x;
            firstPeakSize = buckets.array[x];
        }
        if (buckets.array[x] > maxBucketCount) {
            maxBucketCount = buckets.array[x];
        }
    }

    // Find the second-tallest peak which is somewhat far from the tallest peak.
    int secondPeak = 0;
    int secondPeakScore = 0;
    for (int x = 0; x < numBuckets; x++) {
        int distanceToBiggest = x - firstPeak;
        // Encourage more distant second peaks by multiplying by square of distance.
        int score = buckets.array[x] * distanceToBiggest * distanceToBiggest;
        if (score > secondPeakScore) {
            secondPeak = x;
            secondPeakScore = score;
        }
    }

    // Make sure firstPeak corresponds to the black peak.
    if (firstPeak > secondPeak) {
        int temp = firstPeak;
        firstPeak = secondPeak;
        secondPeak = temp;
    }

    // If there is too little contrast in the image to pick a meaningful black point, throw rather
    // than waste time trying to decode the image, and risk false positives.
    if (secondPeak - firstPeak <= numBuckets / 16) {
        return -1;
    }

    // Find a valley between them that is low and closer to the white peak.
    int bestValley = secondPeak - 1;
    int bestValleyScore = -1;
    for (int x = secondPeak - 1; x > firstPeak; x--) {
        int fromFirst = x - firstPeak;
        int score = fromFirst * fromFirst * (secondPeak - x) * (maxBucketCount - buckets.array[x]);
        if (score > bestValleyScore) {
            bestValley = x;
            bestValleyScore = score;
        }
    }

    return bestValley << AGX_LUMINANCE_SHIFT;
}

/**
 * Calculates a single black point for each block of pixels and saves it away.
 * See the following thread for a discussion of this algorithm:
 *  http://groups.google.com/group/zxing/browse_thread/thread/d06efa2c35a7ddc0
 */
- (int **)calculateBlackPoints:(int8_t *)luminances subWidth:(int)subWidth subHeight:(int)subHeight width:(int)width height:(int)height {
    int **blackPoints = (int **)malloc(subHeight * sizeof(int *));
    for (int y = 0; y < subHeight; y++) {
        blackPoints[y] = (int *)malloc(subWidth * sizeof(int));

        int yoffset = y << AGX_BLOCK_SIZE_POWER;
        int maxYOffset = height - AGX_BLOCK_SIZE;
        if (yoffset > maxYOffset) {
            yoffset = maxYOffset;
        }
        for (int x = 0; x < subWidth; x++) {
            int xoffset = x << AGX_BLOCK_SIZE_POWER;
            int maxXOffset = width - AGX_BLOCK_SIZE;
            if (xoffset > maxXOffset) {
                xoffset = maxXOffset;
            }
            int sum = 0;
            int min = 0xFF;
            int max = 0;
            for (int yy = 0, offset = yoffset * width + xoffset; yy < AGX_BLOCK_SIZE; yy++, offset += width) {
                for (int xx = 0; xx < AGX_BLOCK_SIZE; xx++) {
                    int pixel = luminances[offset + xx] & 0xFF;
                    sum += pixel;
                    // still looking for good contrast
                    if (pixel < min) {
                        min = pixel;
                    }
                    if (pixel > max) {
                        max = pixel;
                    }
                }
                // short-circuit min/max tests once dynamic range is met
                if (max - min > AGX_MIN_DYNAMIC_RANGE) {
                    // finish the rest of the rows quickly
                    for (yy++, offset += width; yy < AGX_BLOCK_SIZE; yy++, offset += width) {
                        for (int xx = 0; xx < AGX_BLOCK_SIZE; xx++) {
                            sum += luminances[offset + xx] & 0xFF;
                        }
                    }
                }
            }

            // The default estimate is the average of the values in the block.
            int average = sum >> (AGX_BLOCK_SIZE_POWER * 2);
            if (max - min <= AGX_MIN_DYNAMIC_RANGE) {
                // If variation within the block is low, assume this is a block with only light or only
                // dark pixels. In that case we do not want to use the average, as it would divide this
                // low contrast area into black and white pixels, essentially creating data out of noise.
                //
                // The default assumption is that the block is light/background. Since no estimate for
                // the level of dark pixels exists locally, use half the min for the block.
                average = min / 2;

                if (y > 0 && x > 0) {
                    // Correct the "white background" assumption for blocks that have neighbors by comparing
                    // the pixels in this block to the previously calculated black points. This is based on
                    // the fact that dark barcode symbology is always surrounded by some amount of light
                    // background for which reasonable black point estimates were made. The bp estimated at
                    // the boundaries is used for the interior.

                    // The (min < bp) is arbitrary but works better than other heuristics that were tried.
                    int averageNeighborBlackPoint =
                    (blackPoints[y - 1][x] + (2 * blackPoints[y][x - 1]) + blackPoints[y - 1][x - 1]) / 4;
                    if (min < averageNeighborBlackPoint) {
                        average = averageNeighborBlackPoint;
                    }
                }
            }
            blackPoints[y][x] = average;
        }
    }
    return blackPoints;
}

/**
 * For each block in the image, calculate the average black point using a 5x5 grid
 * of the blocks around it. Also handles the corner cases (fractional blocks are computed based
 * on the last pixels in the row/column which are also used in the previous block).
 */
- (void)calculateThresholdForBlock:(int8_t *)luminances subWidth:(int)subWidth subHeight:(int)subHeight width:(int)width height:(int)height blackPoints:(int **)blackPoints matrix:(AGXBitMatrix *)matrix {
    for (int y = 0; y < subHeight; y++) {
        int yoffset = y << AGX_BLOCK_SIZE_POWER;
        int maxYOffset = height - AGX_BLOCK_SIZE;
        if (yoffset > maxYOffset) {
            yoffset = maxYOffset;
        }
        for (int x = 0; x < subWidth; x++) {
            int xoffset = x << AGX_BLOCK_SIZE_POWER;
            int maxXOffset = width - AGX_BLOCK_SIZE;
            if (xoffset > maxXOffset) {
                xoffset = maxXOffset;
            }
            int left = [self cap:x min:2 max:subWidth - 3];
            int top = [self cap:y min:2 max:subHeight - 3];
            int sum = 0;
            for (int z = -2; z <= 2; z++) {
                int *blackRow = blackPoints[top + z];
                sum += blackRow[left - 2] + blackRow[left - 1] + blackRow[left] + blackRow[left + 1] + blackRow[left + 2];
            }
            int average = sum / 25;
            [self thresholdBlock:luminances xoffset:xoffset yoffset:yoffset threshold:average stride:width matrix:matrix];
        }
    }
}

- (int)cap:(int)value min:(int)min max:(int)max {
    return value < min ? min : value > max ? max : value;
}

/**
 * Applies a single threshold to a block of pixels.
 */
- (void)thresholdBlock:(int8_t *)luminances xoffset:(int)xoffset yoffset:(int)yoffset threshold:(int)threshold stride:(int)stride matrix:(AGXBitMatrix *)matrix {
    for (int y = 0, offset = yoffset * stride + xoffset; y < AGX_BLOCK_SIZE; y++, offset += stride) {
        for (int x = 0; x < AGX_BLOCK_SIZE; x++) {
            // Comparison needs to be <= so that black == 0 pixels are black even if the threshold is 0
            if ((luminances[offset + x] & 0xFF) <= threshold) {
                [matrix setX:xoffset + x y:yoffset + y];
            }
        }
    }
}

@end
