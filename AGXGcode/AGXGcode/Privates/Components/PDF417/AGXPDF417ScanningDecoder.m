//
//  AGXPDF417ScanningDecoder.m
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

#import <UIKit/UIGeometry.h>
#import "AGXPDF417ScanningDecoder.h"
#import "AGXGcodeError.h"
#import "AGXPDF417Common.h"
#import "AGXPDF417BoundingBox.h"
#import "AGXPDF417DetectionResultRowIndicatorColumn.h"
#import "AGXPDF417DetectionResult.h"
#import "AGXPDF417CodewordDecoder.h"
#import "AGXPDF417BarcodeValue.h"
#import "AGXPDF417ECErrorCorrection.h"
#import "AGXPDF417DecodedBitStreamParser.h"

const int AGX_PDF417_CODEWORD_SKEW_SIZE = 2;

const int AGX_PDF417_MAX_ERRORS = 3;
const int AGX_PDF417_MAX_EC_CODEWORDS = 512;

@implementation AGXPDF417ScanningDecoder

+ (AGXDecoderResult *)decode:(AGXBitMatrix *)image imageTopLeft:(NSValue *)imageTopLeft imageBottomLeft:(NSValue *)imageBottomLeft imageTopRight:(NSValue *)imageTopRight imageBottomRight:(NSValue *)imageBottomRight minCodewordWidth:(int)minCodewordWidth maxCodewordWidth:(int)maxCodewordWidth error:(NSError **)error {
    AGXPDF417BoundingBox *boundingBox = [AGXPDF417BoundingBox boundingBoxWithImage:image topLeft:imageTopLeft bottomLeft:imageBottomLeft topRight:imageTopRight bottomRight:imageBottomRight];
    AGXPDF417DetectionResultRowIndicatorColumn *leftRowIndicatorColumn = nil;
    AGXPDF417DetectionResultRowIndicatorColumn *rightRowIndicatorColumn = nil;
    AGXPDF417DetectionResult *detectionResult = nil;
    for (int i = 0; i < 2; i++) {
        if (imageTopLeft) {
            leftRowIndicatorColumn = [self rowIndicatorColumn:image boundingBox:boundingBox startPoint:imageTopLeft leftToRight:YES minCodewordWidth:minCodewordWidth maxCodewordWidth:maxCodewordWidth];
        }
        if (imageTopRight) {
            rightRowIndicatorColumn = [self rowIndicatorColumn:image boundingBox:boundingBox startPoint:imageTopRight leftToRight:NO minCodewordWidth:minCodewordWidth maxCodewordWidth:maxCodewordWidth];
        }
        detectionResult = [self merge:leftRowIndicatorColumn rightRowIndicatorColumn:rightRowIndicatorColumn error:error];
        if AGX_EXPECT_F(!detectionResult) return nil;

        if (i == 0 && detectionResult.boundingBox &&
            (detectionResult.boundingBox.minY < boundingBox.minY ||
             detectionResult.boundingBox.maxY > boundingBox.maxY)) {
                boundingBox = detectionResult.boundingBox;
            } else {
                detectionResult.boundingBox = boundingBox;
                break;
            }
    }
    int maxBarcodeColumn = detectionResult.barcodeColumnCount + 1;
    [detectionResult setDetectionResultColumn:0 detectionResultColumn:leftRowIndicatorColumn];
    [detectionResult setDetectionResultColumn:maxBarcodeColumn detectionResultColumn:rightRowIndicatorColumn];

    BOOL leftToRight = leftRowIndicatorColumn != nil;
    for (int barcodeColumnCount = 1; barcodeColumnCount <= maxBarcodeColumn; barcodeColumnCount++) {
        int barcodeColumn = leftToRight ? barcodeColumnCount : maxBarcodeColumn - barcodeColumnCount;
        if ([detectionResult detectionResultColumn:barcodeColumn]) {
            // This will be the case for the opposite row indicator column, which doesn't need to be decoded again.
            continue;
        }
        AGXPDF417DetectionResultColumn *detectionResultColumn;
        if (barcodeColumn == 0 || barcodeColumn == maxBarcodeColumn) {
            detectionResultColumn = [AGXPDF417DetectionResultRowIndicatorColumn columnWithBoundingBox:boundingBox isLeft:barcodeColumn == 0];
        } else {
            detectionResultColumn = [AGXPDF417DetectionResultColumn columnWithBoundingBox:boundingBox];
        }
        [detectionResult setDetectionResultColumn:barcodeColumn detectionResultColumn:detectionResultColumn];
        int startColumn = -1;
        int previousStartColumn = startColumn;
        // TODO start at a row for which we know the start position, then detect upwards and downwards from there.
        for (int imageRow = boundingBox.minY; imageRow <= boundingBox.maxY; imageRow++) {
            startColumn = [self startColumn:detectionResult barcodeColumn:barcodeColumn imageRow:imageRow leftToRight:leftToRight];
            if (startColumn < 0 || startColumn > boundingBox.maxX) {
                if (previousStartColumn == -1) {
                    continue;
                }
                startColumn = previousStartColumn;
            }
            AGXPDF417Codeword *codeword = [self detectCodeword:image minColumn:boundingBox.minX maxColumn:boundingBox.maxX leftToRight:leftToRight startColumn:startColumn imageRow:imageRow minCodewordWidth:minCodewordWidth maxCodewordWidth:maxCodewordWidth];
            if (codeword) {
                [detectionResultColumn setCodeword:imageRow codeword:codeword];
                previousStartColumn = startColumn;
                minCodewordWidth = MIN(minCodewordWidth, codeword.width);
                maxCodewordWidth = MAX(maxCodewordWidth, codeword.width);
            }
        }
    }
    return [self createDecoderResult:detectionResult error:error];
}

+ (AGXPDF417DetectionResultRowIndicatorColumn *)rowIndicatorColumn:(AGXBitMatrix *)image boundingBox:(AGXPDF417BoundingBox *)boundingBox startPoint:(NSValue *)startPoint leftToRight:(BOOL)leftToRight minCodewordWidth:(int)minCodewordWidth maxCodewordWidth:(int)maxCodewordWidth {
    AGXPDF417DetectionResultRowIndicatorColumn *rowIndicatorColumn = [AGXPDF417DetectionResultRowIndicatorColumn columnWithBoundingBox:boundingBox isLeft:leftToRight];
    for (int i = 0; i < 2; i++) {
        int increment = i == 0 ? 1 : -1;
        int startColumn = (int) startPoint.CGPointValue.x;
        for (int imageRow = (int) startPoint.CGPointValue.y; imageRow <= boundingBox.maxY &&
             imageRow >= boundingBox.minY; imageRow += increment) {
            AGXPDF417Codeword *codeword = [self detectCodeword:image minColumn:0 maxColumn:image.width leftToRight:leftToRight startColumn:startColumn imageRow:imageRow minCodewordWidth:minCodewordWidth maxCodewordWidth:maxCodewordWidth];
            if (codeword) {
                [rowIndicatorColumn setCodeword:imageRow codeword:codeword];
                if (leftToRight) {
                    startColumn = codeword.startX;
                } else {
                    startColumn = codeword.endX;
                }
            }
        }
    }
    return rowIndicatorColumn;
}

+ (AGXPDF417Codeword *)detectCodeword:(AGXBitMatrix *)image minColumn:(int)minColumn maxColumn:(int)maxColumn leftToRight:(BOOL)leftToRight startColumn:(int)startColumn imageRow:(int)imageRow minCodewordWidth:(int)minCodewordWidth maxCodewordWidth:(int)maxCodewordWidth {
    startColumn = [self adjustCodewordStartColumn:image minColumn:minColumn maxColumn:maxColumn leftToRight:leftToRight codewordStartColumn:startColumn imageRow:imageRow];
    // we usually know fairly exact now how long a codeword is. We should provide minimum and maximum expected length
    // and try to adjust the read pixels, e.g. remove single pixel errors or try to cut off exceeding pixels.
    // min and maxCodewordWidth should not be used as they are calculated for the whole barcode an can be inaccurate
    // for the current position
    NSMutableArray *moduleBitCount = [self moduleBitCount:image minColumn:minColumn maxColumn:maxColumn leftToRight:leftToRight startColumn:startColumn imageRow:imageRow];
    if AGX_EXPECT_F(!moduleBitCount) return nil;

    int endColumn;
    int codewordBitCount = [AGXPDF417Common bitCountSum:moduleBitCount];
    if (leftToRight) {
        endColumn = startColumn + codewordBitCount;
    } else {
        for (int i = 0; i < moduleBitCount.count / 2; i++) {
            int tmpCount = [moduleBitCount[i] intValue];
            moduleBitCount[i] = moduleBitCount[moduleBitCount.count - 1 - i];
            moduleBitCount[moduleBitCount.count - 1 - i] = @(tmpCount);
        }
        endColumn = startColumn;
        startColumn = endColumn - codewordBitCount;
    }
    // TODO implement check for width and correction of black and white bars
    // use start (and maybe stop pattern) to determine if blackbars are wider than white bars. If so, adjust.
    // should probably done only for codewords with a lot more than 17 bits.
    // The following fixes 10-1.png, which has wide black bars and small white bars
    //    for (int i = 0; i < moduleBitCount.length; i++) {
    //      if (i % 2 == 0) {
    //        moduleBitCount[i]--;
    //      } else {
    //        moduleBitCount[i]++;
    //      }
    //    }

    // We could also use the width of surrounding codewords for more accurate results, but this seems
    // sufficient for now
    if AGX_EXPECT_F(![self checkCodewordSkew:codewordBitCount minCodewordWidth:minCodewordWidth maxCodewordWidth:maxCodewordWidth]) {
        // We could try to use the startX and endX position of the codeword in the same column in the previous row,
        // create the bit count from it and normalize it to 8. This would help with single pixel errors.
        return nil;
    }

    int decodedValue = [AGXPDF417CodewordDecoder decodedValue:moduleBitCount];
    int codeword = [AGXPDF417Common codeword:decodedValue];
    if AGX_EXPECT_F(codeword == -1) return nil;
    return [AGXPDF417Codeword codewordWithStartX:startColumn endX:endColumn bucket:[self codewordBucketNumber:decodedValue] value:codeword];
}

+ (int)adjustCodewordStartColumn:(AGXBitMatrix *)image minColumn:(int)minColumn maxColumn:(int)maxColumn leftToRight:(BOOL)leftToRight codewordStartColumn:(int)codewordStartColumn imageRow:(int)imageRow {
    int correctedStartColumn = codewordStartColumn;
    int increment = leftToRight ? -1 : 1;
    // there should be no black pixels before the start column. If there are, then we need to start earlier.
    for (int i = 0; i < 2; i++) {
        while (((leftToRight && correctedStartColumn >= minColumn) || (!leftToRight && correctedStartColumn < maxColumn)) &&
               leftToRight == [image getX:correctedStartColumn y:imageRow]) {
            if (abs(codewordStartColumn - correctedStartColumn) > AGX_PDF417_CODEWORD_SKEW_SIZE) {
                return codewordStartColumn;
            }
            correctedStartColumn += increment;
        }
        increment = -increment;
        leftToRight = !leftToRight;
    }
    return correctedStartColumn;
}

+ (NSMutableArray *)moduleBitCount:(AGXBitMatrix *)image minColumn:(int)minColumn maxColumn:(int)maxColumn leftToRight:(BOOL)leftToRight startColumn:(int)startColumn imageRow:(int)imageRow {
    int imageColumn = startColumn;
    NSMutableArray *moduleBitCount = [NSMutableArray arrayWithCapacity:8];
    for (int i = 0; i < 8; i++) {
        [moduleBitCount addObject:@0];
    }
    int moduleNumber = 0;
    int increment = leftToRight ? 1 : -1;
    BOOL previousPixelValue = leftToRight;
    while (((leftToRight && imageColumn < maxColumn) || (!leftToRight && imageColumn >= minColumn)) &&
           moduleNumber < moduleBitCount.count) {
        if ([image getX:imageColumn y:imageRow] == previousPixelValue) {
            moduleBitCount[moduleNumber] = @([moduleBitCount[moduleNumber] intValue] + 1);
            imageColumn += increment;
        } else {
            moduleNumber++;
            previousPixelValue = !previousPixelValue;
        }
    }
    if (moduleNumber == moduleBitCount.count ||
        (((leftToRight && imageColumn == maxColumn) || (!leftToRight && imageColumn == minColumn)) && moduleNumber == moduleBitCount.count - 1)) {
        return moduleBitCount;
    }
    return nil;
}

+ (BOOL)checkCodewordSkew:(int)codewordSize minCodewordWidth:(int)minCodewordWidth maxCodewordWidth:(int)maxCodewordWidth {
    return minCodewordWidth - AGX_PDF417_CODEWORD_SKEW_SIZE <= codewordSize && codewordSize <= maxCodewordWidth + AGX_PDF417_CODEWORD_SKEW_SIZE;
}

+ (int)codewordBucketNumber:(int)codeword {
    return [self codewordBucketNumberWithModuleBitCount:[self bitCountForCodeword:codeword]];
}

+ (int)codewordBucketNumberWithModuleBitCount:(NSArray *)moduleBitCount {
    return ([moduleBitCount[0] intValue] - [moduleBitCount[2] intValue] + [moduleBitCount[4] intValue] - [moduleBitCount[6] intValue] + 9) % 9;
}

+ (NSArray *)bitCountForCodeword:(int)codeword {
    NSMutableArray *result = [NSMutableArray array];
    for (int i = 0; i < 8; i++) {
        [result addObject:@0];
    }

    int previousValue = 0;
    int i = (int)result.count - 1;
    while (YES) {
        if ((codeword & 0x1) != previousValue) {
            previousValue = codeword & 0x1;
            i--;
            if (i < 0) break;
        }
        result[i] = @([result[i] intValue] + 1);
        codeword >>= 1;
    }
    return result;
}

+ (AGXPDF417DetectionResult *)merge:(AGXPDF417DetectionResultRowIndicatorColumn *)leftRowIndicatorColumn rightRowIndicatorColumn:(AGXPDF417DetectionResultRowIndicatorColumn *)rightRowIndicatorColumn error:(NSError **)error {
    if AGX_EXPECT_F(!leftRowIndicatorColumn && !rightRowIndicatorColumn) return nil;

    AGXPDF417BarcodeMetadata *barcodeMetadata = [self barcodeMetadata:leftRowIndicatorColumn rightRowIndicatorColumn:rightRowIndicatorColumn];
    if AGX_EXPECT_F(!barcodeMetadata) return nil;

    AGXPDF417BoundingBox *leftBoundingBox, *rightBoundingBox;
    if AGX_EXPECT_F(![self adjustBoundingBox:&leftBoundingBox rowIndicatorColumn:
                       leftRowIndicatorColumn error:error]) return nil;
    if AGX_EXPECT_F(![self adjustBoundingBox:&rightBoundingBox rowIndicatorColumn:
                       rightRowIndicatorColumn error:error]) return nil;

    AGXPDF417BoundingBox *boundingBox = [AGXPDF417BoundingBox mergeLeftBox:leftBoundingBox rightBox:rightBoundingBox];
    if AGX_EXPECT_F(!boundingBox) {
        if AGX_EXPECT_T(error) *error = AGXNotFoundErrorInstance();
        return nil;
    }
    return [AGXPDF417DetectionResult detectionResultWithBarcodeMetadata:barcodeMetadata boundingBox:boundingBox];
}

+ (AGXPDF417BarcodeMetadata *)barcodeMetadata:(AGXPDF417DetectionResultRowIndicatorColumn *)leftRowIndicatorColumn rightRowIndicatorColumn:(AGXPDF417DetectionResultRowIndicatorColumn *)rightRowIndicatorColumn {
    AGXPDF417BarcodeMetadata *leftBarcodeMetadata;
    if (!leftRowIndicatorColumn || !(leftBarcodeMetadata = leftRowIndicatorColumn.barcodeMetadata)) {
        return rightRowIndicatorColumn ? rightRowIndicatorColumn.barcodeMetadata : nil;
    }
    AGXPDF417BarcodeMetadata *rightBarcodeMetadata;
    if (!rightRowIndicatorColumn || !(rightBarcodeMetadata = rightRowIndicatorColumn.barcodeMetadata)) {
        return leftRowIndicatorColumn.barcodeMetadata;
    }

    if AGX_EXPECT_F(leftBarcodeMetadata.columnCount != rightBarcodeMetadata.columnCount &&
                    leftBarcodeMetadata.errorCorrectionLevel != rightBarcodeMetadata.errorCorrectionLevel &&
                    leftBarcodeMetadata.rowCount != rightBarcodeMetadata.rowCount) return nil;
    return leftBarcodeMetadata;
}

+ (BOOL)adjustBoundingBox:(AGXPDF417BoundingBox **)boundingBox
       rowIndicatorColumn:(AGXPDF417DetectionResultRowIndicatorColumn *)rowIndicatorColumn
                    error:(NSError **)error {
    if (!rowIndicatorColumn) {
        *boundingBox = nil;
        return YES;
    }
    AGXIntArray *rowHeights;
    if AGX_EXPECT_F(![rowIndicatorColumn getRowHeights:&rowHeights]) {
        if AGX_EXPECT_T(error) *error = AGXFormatErrorInstance();
        *boundingBox = nil;
        return NO;
    }
    if AGX_EXPECT_F(!rowHeights) {
        *boundingBox = nil;
        return YES;
    }
    int maxRowHeight = [self max:rowHeights];
    int missingStartRows = 0;
    for (int i = 0; i < rowHeights.length; i++) {
        int rowHeight = rowHeights.array[i];
        missingStartRows += maxRowHeight - rowHeight;
        if (rowHeight > 0) break;
    }
    NSArray *codewords = rowIndicatorColumn.codewords;
    for (int row = 0; missingStartRows > 0 && codewords[row] == NSNull.null; row++) {
        missingStartRows--;
    }
    int missingEndRows = 0;
    for (int row = rowHeights.length - 1; row >= 0; row--) {
        missingEndRows += maxRowHeight - rowHeights.array[row];
        if (rowHeights.array[row] > 0) break;
    }
    for (int row = (int)codewords.count - 1; missingEndRows > 0 && codewords[row] == NSNull.null; row--) {
        missingEndRows--;
    }
    *boundingBox = [rowIndicatorColumn.boundingBox addMissingRows:missingStartRows
                                                   missingEndRows:missingEndRows
                                                           isLeft:rowIndicatorColumn.isLeft];
    return *boundingBox != nil;
}

+ (int)max:(AGXIntArray *)values {
    int maxValue = -1;
    for (int i = 0; i < values.length; i++) {
        int value = values.array[i];
        maxValue = MAX(maxValue, value);
    }
    return maxValue;
}

+ (int)startColumn:(AGXPDF417DetectionResult *)detectionResult
     barcodeColumn:(int)barcodeColumn
          imageRow:(int)imageRow
       leftToRight:(BOOL)leftToRight {
    int offset = leftToRight ? 1 : -1;
    AGXPDF417Codeword *codeword = nil;
    if ([self isValidBarcodeColumn:detectionResult barcodeColumn:barcodeColumn - offset]) {
        codeword = [[detectionResult detectionResultColumn:barcodeColumn - offset] codeword:imageRow];
    }
    if (codeword) {
        return leftToRight ? codeword.endX : codeword.startX;
    }
    codeword = [[detectionResult detectionResultColumn:barcodeColumn] codewordNearby:imageRow];
    if (codeword) {
        return leftToRight ? codeword.startX : codeword.endX;
    }
    if ([self isValidBarcodeColumn:detectionResult barcodeColumn:barcodeColumn - offset]) {
        codeword = [[detectionResult detectionResultColumn:barcodeColumn - offset] codewordNearby:imageRow];
    }
    if (codeword) {
        return leftToRight ? codeword.endX : codeword.startX;
    }
    int skippedColumns = 0;

    while ([self isValidBarcodeColumn:detectionResult barcodeColumn:barcodeColumn - offset]) {
        barcodeColumn -= offset;
        for (AGXPDF417Codeword *previousRowCodeword in [detectionResult detectionResultColumn:barcodeColumn].codewords) {
            if ((id)previousRowCodeword != NSNull.null) {
                return((leftToRight ? previousRowCodeword.endX : previousRowCodeword.startX) +
                       offset *
                       skippedColumns *
                       (previousRowCodeword.endX - previousRowCodeword.startX));
            }
        }
        skippedColumns++;
    }
    return leftToRight ? detectionResult.boundingBox.minX : detectionResult.boundingBox.maxX;
}

+ (BOOL)isValidBarcodeColumn:(AGXPDF417DetectionResult *)detectionResult barcodeColumn:(int)barcodeColumn {
    return barcodeColumn >= 0 && barcodeColumn <= detectionResult.barcodeColumnCount + 1;
}

+ (AGXDecoderResult *)createDecoderResult:(AGXPDF417DetectionResult *)detectionResult error:(NSError **)error {
    NSArray *barcodeMatrix = [self createBarcodeMatrix:detectionResult];
    if AGX_EXPECT_F(!barcodeMatrix) {
        if AGX_EXPECT_T(error) *error = AGXFormatErrorInstance();
        return nil;
    }
    if AGX_EXPECT_F(![self adjustCodewordCount:detectionResult barcodeMatrix:barcodeMatrix]) {
        if AGX_EXPECT_T(error) *error = AGXNotFoundErrorInstance();
        return nil;
    }
    NSMutableArray *erasures = [NSMutableArray array];
    AGXIntArray *codewords = [AGXIntArray intArrayWithLength:detectionResult.barcodeRowCount * detectionResult.barcodeColumnCount];
    NSMutableArray *ambiguousIndexValuesList = [NSMutableArray array];
    NSMutableArray *ambiguousIndexesList = [NSMutableArray array];
    for (int row = 0; row < detectionResult.barcodeRowCount; row++) {
        for (int column = 0; column < detectionResult.barcodeColumnCount; column++) {
            AGXIntArray *values = [(AGXPDF417BarcodeValue *)barcodeMatrix[row][column + 1] value];
            int codewordIndex = row * detectionResult.barcodeColumnCount + column;
            if (values.length == 0) {
                [erasures addObject:@(codewordIndex)];
            } else if (values.length == 1) {
                codewords.array[codewordIndex] = values.array[0];
            } else {
                [ambiguousIndexesList addObject:@(codewordIndex)];
                [ambiguousIndexValuesList addObject:values];
            }
        }
    }
    return [self createDecoderResultFromAmbiguousValues:detectionResult.barcodeECLevel codewords:codewords erasureArray:[AGXPDF417Common toIntArray:erasures] ambiguousIndexes:[AGXPDF417Common toIntArray:ambiguousIndexesList] ambiguousIndexValues:ambiguousIndexValuesList error:error];
}

+ (NSArray *)createBarcodeMatrix:(AGXPDF417DetectionResult *)detectionResult {
    NSMutableArray *barcodeMatrix = [NSMutableArray array];
    for (int row = 0; row < detectionResult.barcodeRowCount; row++) {
        [barcodeMatrix addObject:[NSMutableArray array]];
        for (int column = 0; column < detectionResult.barcodeColumnCount + 2; column++) {
            barcodeMatrix[row][column] = AGX_AUTORELEASE([[AGXPDF417BarcodeValue alloc] init]);
        }
    }

    int column = 0;
    for (AGXPDF417DetectionResultColumn *detectionResultColumn in detectionResult.detectionResultColumns) {
        if ((id)detectionResultColumn != NSNull.null) {
            for (AGXPDF417Codeword *codeword in detectionResultColumn.codewords) {
                if ((id)codeword != NSNull.null) {
                    int rowNumber = codeword.rowNumber;
                    if (rowNumber >= 0) {
                        if AGX_EXPECT_F(rowNumber >= barcodeMatrix.count) return nil;
                        [(AGXPDF417BarcodeValue *)barcodeMatrix[rowNumber][column] setValue:codeword.value];
                    }
                }
            }
        }
        column++;
    }
    return barcodeMatrix;
}

+ (BOOL)adjustCodewordCount:(AGXPDF417DetectionResult *)detectionResult barcodeMatrix:(NSArray *)barcodeMatrix {
    AGXIntArray *numberOfCodewords = [(AGXPDF417BarcodeValue *)barcodeMatrix[0][1] value];
    int calculatedNumberOfCodewords = detectionResult.barcodeColumnCount * detectionResult.barcodeRowCount;
    [self numberOfECCodeWords:detectionResult.barcodeECLevel];
    if (numberOfCodewords.length == 0) {
        if (calculatedNumberOfCodewords < 1 || calculatedNumberOfCodewords > AGX_PDF417_MAX_CODEWORDS_IN_BARCODE) {
            return NO;
        }
        [(AGXPDF417BarcodeValue *)barcodeMatrix[0][1] setValue:calculatedNumberOfCodewords];
    } else if (numberOfCodewords.array[0] != calculatedNumberOfCodewords) {
        // The calculated one is more reliable as it is derived from the row indicator columns
        [(AGXPDF417BarcodeValue *)barcodeMatrix[0][1] setValue:calculatedNumberOfCodewords];
    }
    return YES;
}

+ (int)numberOfECCodeWords:(int)barcodeECLevel {
    return 2 << barcodeECLevel;
}

+ (AGXDecoderResult *)createDecoderResultFromAmbiguousValues:(int)ecLevel codewords:(AGXIntArray *)codewords erasureArray:(AGXIntArray *)erasureArray ambiguousIndexes:(AGXIntArray *)ambiguousIndexes ambiguousIndexValues:(NSArray *)ambiguousIndexValues error:(NSError **)error {
    AGXIntArray *ambiguousIndexCount = [AGXIntArray intArrayWithLength:ambiguousIndexes.length];

    int tries = 100;
    while (tries-- > 0) {
        for (int i = 0; i < ambiguousIndexCount.length; i++) {
            AGXIntArray *a = ambiguousIndexValues[i];
            codewords.array[ambiguousIndexes.array[i]] = a.array[(ambiguousIndexCount.array[i] + 1) % [(AGXIntArray *)ambiguousIndexValues[i] length]];
        }
        NSError *e;
        AGXDecoderResult *result = [self decodeCodewords:codewords ecLevel:ecLevel erasures:erasureArray error:&e];
        if (result) {
            return result;
        } else if AGX_EXPECT_F(e.code != AGXChecksumError) {
            if AGX_EXPECT_T(error) *error = e;
            return nil;
        }
        if AGX_EXPECT_F(ambiguousIndexCount.length == 0) {
            if AGX_EXPECT_T(error) *error = AGXChecksumErrorInstance();
            return nil;
        }
        for (int i = 0; i < ambiguousIndexCount.length; i++) {
            if (ambiguousIndexCount.array[i] < [(AGXIntArray *)ambiguousIndexValues[i] length] - 1) {
                ambiguousIndexCount.array[i]++;
                break;
            } else {
                ambiguousIndexCount.array[i] = 0;
                if AGX_EXPECT_F(i == ambiguousIndexes.length - 1) {
                    if AGX_EXPECT_T(error) *error = AGXChecksumErrorInstance();
                    return nil;
                }
            }
        }
    }
    if AGX_EXPECT_T(error) *error = AGXChecksumErrorInstance();
    return nil;
}

+ (AGXDecoderResult *)decodeCodewords:(AGXIntArray *)codewords ecLevel:(int)ecLevel erasures:(AGXIntArray *)erasures error:(NSError **)error {
    if AGX_EXPECT_F(codewords.length == 0) {
        if AGX_EXPECT_T(error) *error = AGXFormatErrorInstance();
        return nil;
    }

    int numECCodewords = 1 << (ecLevel + 1);
    int correctedErrorsCount = [self correctErrors:codewords erasures:erasures numECCodewords:numECCodewords];
    if AGX_EXPECT_F(correctedErrorsCount == -1) {
        if AGX_EXPECT_T(error) *error = AGXChecksumErrorInstance();
        return nil;
    }
    if AGX_EXPECT_F(![self verifyCodewordCount:codewords numECCodewords:numECCodewords]) {
        if AGX_EXPECT_T(error) *error = AGXFormatErrorInstance();
        return nil;
    }

    // Decode the codewords
    AGXDecoderResult *decoderResult = [AGXPDF417DecodedBitStreamParser decode:codewords ecLevel:@(ecLevel).stringValue error:error];
    if AGX_EXPECT_F(!decoderResult) return nil;
    decoderResult.errorsCorrected = @(correctedErrorsCount);
    decoderResult.erasures = @(erasures.length);
    return decoderResult;
}

+ (int)correctErrors:(AGXIntArray *)codewords erasures:(AGXIntArray *)erasures numECCodewords:(int)numECCodewords {
    if AGX_EXPECT_F(erasures && (erasures.length > numECCodewords / 2 + AGX_PDF417_MAX_ERRORS ||
                                 numECCodewords < 0 || numECCodewords > AGX_PDF417_MAX_EC_CODEWORDS)) {
        // Too many errors or EC Codewords is corrupted
        return -1;
    }
    return [AGXPDF417ECErrorCorrection.shareInstance decode:codewords numECCodewords:numECCodewords erasures:erasures];
}

+ (BOOL)verifyCodewordCount:(AGXIntArray *)codewords numECCodewords:(int)numECCodewords {
    if AGX_EXPECT_F(codewords.length < 4) {
        // Codeword array size should be at least 4 allowing for
        // Count CW, At least one Data CW, Error Correction CW, Error Correction CW
        return NO;
    }
    // The first codeword, the Symbol Length Descriptor, shall always encode the total number of data
    // codewords in the symbol, including the Symbol Length Descriptor itself, data codewords and pad
    // codewords, but excluding the number of error correction codewords.
    int numberOfCodewords = codewords.array[0];
    if AGX_EXPECT_F(numberOfCodewords > codewords.length) return NO;
    if (numberOfCodewords == 0) {
        // Reset to the length of the array - 8 (Allow for at least level 3 Error Correction (8 Error Codewords)
        if AGX_EXPECT_T(numECCodewords < codewords.length) {
            codewords.array[0] = codewords.length - numECCodewords;
        } else {
            return NO;
        }
    }
    return YES;
}

@end
