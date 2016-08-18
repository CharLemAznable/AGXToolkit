//
//  AGXPDF417DetectionResultRowIndicatorColumn.m
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

#import <UIKit/UIGeometry.h>
#import <AGXCore/AGXCore/AGXArc.h>
#import "AGXPDF417DetectionResultRowIndicatorColumn.h"
#import "AGXPDF417Common.h"
#import "AGXPDF417BarcodeValue.h"

@implementation AGXPDF417DetectionResultRowIndicatorColumn

- (AGX_INSTANCETYPE)initWithBoundingBox:(AGXPDF417BoundingBox *)boundingBox isLeft:(BOOL)isLeft {
    if (self = [super initWithBoundingBox:boundingBox]) {
        _isLeft = isLeft;
    }
    return self;
}

- (BOOL)getRowHeights:(AGXIntArray **)rowHeights {
    AGXPDF417BarcodeMetadata *barcodeMetadata = [self barcodeMetadata];
    if (!barcodeMetadata) {
        *rowHeights = nil;
        return YES;
    }
    [self adjustIncompleteIndicatorColumnRowNumbers:barcodeMetadata];
    AGXIntArray *result = [AGXIntArray intArrayWithLength:barcodeMetadata.rowCount];
    for (AGXPDF417Codeword *codeword in self.codewords) {
        if ((id)codeword != [NSNull null]) {
            int rowNumber = codeword.rowNumber;
            if (rowNumber >= result.length) {
                *rowHeights = nil;
                return NO;
            }
            result.array[rowNumber]++;
        } // else throw exception?
    }
    *rowHeights = result;
    return YES;
}

- (int)adjustIncompleteIndicatorColumnRowNumbers:(AGXPDF417BarcodeMetadata *)barcodeMetadata {
    NSValue *top = _isLeft ? self.boundingBox.topLeft : self.boundingBox.topRight;
    NSValue *bottom = _isLeft ? self.boundingBox.bottomLeft : self.boundingBox.bottomRight;
    int firstRow = [self imageRowToCodewordIndex:(int)top.CGPointValue.y];
    int lastRow = [self imageRowToCodewordIndex:(int)bottom.CGPointValue.y];
    float averageRowHeight = (lastRow - firstRow) / (float) barcodeMetadata.rowCount;
    int barcodeRow = -1;
    int maxRowHeight = 1;
    int currentRowHeight = 0;
    for (int codewordsRow = firstRow; codewordsRow < lastRow; codewordsRow++) {
        if (self.codewords[codewordsRow] == [NSNull null]) continue;

        AGXPDF417Codeword *codeword = self.codewords[codewordsRow];
        [codeword setRowNumberAsRowIndicatorColumn];

        int rowDifference = codeword.rowNumber - barcodeRow;
        // TODO improve handling with case where first row indicator doesn't start with 0
        if (rowDifference == 0) {
            currentRowHeight++;
        } else if (rowDifference == 1) {
            maxRowHeight = MAX(maxRowHeight, currentRowHeight);
            currentRowHeight = 1;
            barcodeRow = codeword.rowNumber;
        } else if (codeword.rowNumber >= barcodeMetadata.rowCount) {
            self.codewords[codewordsRow] = [NSNull null];
        } else {
            barcodeRow = codeword.rowNumber;
            currentRowHeight = 1;
        }
    }
    return (int) (averageRowHeight + 0.5);
}

- (int)adjustCompleteIndicatorColumnRowNumbers:(AGXPDF417BarcodeMetadata *)barcodeMetadata {
    for (AGXPDF417Codeword *codeword in self.codewords) {
        if ((id)codeword != [NSNull null]) {
            [codeword setRowNumberAsRowIndicatorColumn];
        }
    }
    [self removeIncorrectCodewords:barcodeMetadata];
    NSValue *top = _isLeft ? self.boundingBox.topLeft : self.boundingBox.topRight;
    NSValue *bottom = _isLeft ? self.boundingBox.bottomLeft : self.boundingBox.bottomRight;
    int firstRow = [self imageRowToCodewordIndex:(int)top.CGPointValue.y];
    int lastRow = [self imageRowToCodewordIndex:(int)bottom.CGPointValue.y];
    // We need to be careful using the average row height. Barcode could be skewed so that we have smaller and
    // taller rows
    float averageRowHeight = (lastRow - firstRow) / (float) barcodeMetadata.rowCount;
    int barcodeRow = -1;
    int maxRowHeight = 1;
    int currentRowHeight = 0;
    for (int codewordsRow = firstRow; codewordsRow < lastRow; codewordsRow++) {
        if (self.codewords[codewordsRow] == [NSNull null]) {
            continue;
        }
        AGXPDF417Codeword *codeword = self.codewords[codewordsRow];

        //      float expectedRowNumber = (codewordsRow - firstRow) / averageRowHeight;
        //      if (Math.abs(codeword.getRowNumber() - expectedRowNumber) > 2) {
        //        SimpleLog.log(LEVEL.WARNING,
        //            "Removing codeword, rowNumberSkew too high, codeword[" + codewordsRow + "]: Expected Row: " +
        //                expectedRowNumber + ", RealRow: " + codeword.getRowNumber() + ", value: " + codeword.getValue());
        //        codewords[codewordsRow] = null;
        //      }

        int rowDifference = codeword.rowNumber - barcodeRow;
        // TODO improve handling with case where first row indicator doesn't start with 0
        if (rowDifference == 0) {
            currentRowHeight++;
        } else if (rowDifference == 1) {
            maxRowHeight = MAX(maxRowHeight, currentRowHeight);
            currentRowHeight = 1;
            barcodeRow = codeword.rowNumber;
        } else if (rowDifference < 0 ||
                   codeword.rowNumber >= barcodeMetadata.rowCount ||
                   rowDifference > codewordsRow) {
            self.codewords[codewordsRow] = [NSNull null];
        } else {
            int checkedRows;
            if (maxRowHeight > 2) {
                checkedRows = (maxRowHeight - 2) * rowDifference;
            } else {
                checkedRows = rowDifference;
            }
            BOOL closePreviousCodewordFound = checkedRows >= codewordsRow;
            for (int i = 1; i <= checkedRows && !closePreviousCodewordFound; i++) {
                // there must be (height * rowDifference) number of codewords missing. For now we assume height = 1.
                // This should hopefully get rid of most problems already.
                closePreviousCodewordFound = self.codewords[codewordsRow - i] != [NSNull null];
            }
            if (closePreviousCodewordFound) {
                self.codewords[codewordsRow] = [NSNull null];
            } else {
                barcodeRow = codeword.rowNumber;
                currentRowHeight = 1;
            }
        }
    }
    return (int)(averageRowHeight + 0.5);
}

- (AGXPDF417BarcodeMetadata *)barcodeMetadata {
    AGXPDF417BarcodeValue *barcodeColumnCount = AGX_AUTORELEASE([[AGXPDF417BarcodeValue alloc] init]);
    AGXPDF417BarcodeValue *barcodeRowCountUpperPart = AGX_AUTORELEASE([[AGXPDF417BarcodeValue alloc] init]);
    AGXPDF417BarcodeValue *barcodeRowCountLowerPart = AGX_AUTORELEASE([[AGXPDF417BarcodeValue alloc] init]);
    AGXPDF417BarcodeValue *barcodeECLevel = AGX_AUTORELEASE([[AGXPDF417BarcodeValue alloc] init]);
    for (AGXPDF417Codeword *codeword in self.codewords) {
        if ((id)codeword == [NSNull null]) {
            continue;
        }
        [codeword setRowNumberAsRowIndicatorColumn];
        int rowIndicatorValue = codeword.value % 30;
        int codewordRowNumber = codeword.rowNumber;
        if (!self.isLeft) {
            codewordRowNumber += 2;
        }
        switch (codewordRowNumber % 3) {
            case 0:
                [barcodeRowCountUpperPart setValue:rowIndicatorValue * 3 + 1];
                break;
            case 1:
                [barcodeECLevel setValue:rowIndicatorValue / 3];
                [barcodeRowCountLowerPart setValue:rowIndicatorValue % 3];
                break;
            case 2:
                [barcodeColumnCount setValue:rowIndicatorValue + 1];
                break;
        }
    }
    // Maybe we should check if we have ambiguous values?
    int32_t rows = [barcodeRowCountUpperPart value].array[0] + [barcodeRowCountLowerPart value].array[0];
    if (([barcodeColumnCount value].length == 0) || ([barcodeRowCountUpperPart value].length == 0) ||
        ([barcodeRowCountLowerPart value].length == 0) || ([barcodeECLevel value].length == 0) ||
        [barcodeColumnCount value].array[0] < 1 || rows < AGX_PDF417_MIN_ROWS_IN_BARCODE || rows > AGX_PDF417_MAX_ROWS_IN_BARCODE) {
        return nil;
    }
    AGXPDF417BarcodeMetadata *barcodeMetadata = [[AGXPDF417BarcodeMetadata alloc] initWithColumnCount:[barcodeColumnCount value].array[0] rowCountUpperPart:[barcodeRowCountUpperPart value].array[0] rowCountLowerPart:[barcodeRowCountLowerPart value].array[0] errorCorrectionLevel:[barcodeECLevel value].array[0]];
    [self removeIncorrectCodewords:barcodeMetadata];
    return AGX_AUTORELEASE(barcodeMetadata);
}

- (void)removeIncorrectCodewords:(AGXPDF417BarcodeMetadata *)barcodeMetadata {
    // Remove codewords which do not match the metadata
    // TODO Maybe we should keep the incorrect codewords for the start and end positions?
    for (int codewordRow = 0; codewordRow < [self.codewords count]; codewordRow++) {
        AGXPDF417Codeword *codeword = self.codewords[codewordRow];
        if (self.codewords[codewordRow] == [NSNull null]) {
            continue;
        }
        int rowIndicatorValue = codeword.value % 30;
        int codewordRowNumber = codeword.rowNumber;
        if (codewordRowNumber > barcodeMetadata.rowCount) {
            self.codewords[codewordRow] = [NSNull null];
            continue;
        }
        if (!self.isLeft) {
            codewordRowNumber += 2;
        }
        switch (codewordRowNumber % 3) {
            case 0:
                if (rowIndicatorValue * 3 + 1 != barcodeMetadata.rowCountUpperPart) {
                    self.codewords[codewordRow] = [NSNull null];
                }
                break;
            case 1:
                if (rowIndicatorValue / 3 != barcodeMetadata.errorCorrectionLevel ||
                    rowIndicatorValue % 3 != barcodeMetadata.rowCountLowerPart) {
                    self.codewords[codewordRow] = [NSNull null];
                }
                break;
            case 2:
                if (rowIndicatorValue + 1 != barcodeMetadata.columnCount) {
                    self.codewords[codewordRow] = [NSNull null];
                }
                break;
        }
    }
}

- (NSString *)description {
    return [NSString stringWithFormat:@"IsLeft: %@\n%@", @(self.isLeft), [super description]];
}

@end
