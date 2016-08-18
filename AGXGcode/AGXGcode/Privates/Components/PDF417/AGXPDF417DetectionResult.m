//
//  AGXPDF417DetectionResult.m
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

#import "AGXPDF417DetectionResult.h"
#import "AGXPDF417Common.h"
#import "AGXPDF417DetectionResultRowIndicatorColumn.h"

const int AGX_PDF417_ADJUST_ROW_NUMBER_SKIP = 2;

@implementation AGXPDF417DetectionResult {
    AGXPDF417BarcodeMetadata *_barcodeMetadata;
    int _barcodeColumnCount;
    NSMutableArray *_detectionResultColumnsInternal;
}

- (AGX_INSTANCETYPE)initWithBarcodeMetadata:(AGXPDF417BarcodeMetadata *)barcodeMetadata boundingBox:(AGXPDF417BoundingBox *)boundingBox {
    if (self = [super init]) {
        _barcodeMetadata = AGX_RETAIN(barcodeMetadata);
        _barcodeColumnCount = barcodeMetadata.columnCount;
        _detectionResultColumnsInternal = [[NSMutableArray alloc] initWithCapacity:_barcodeColumnCount + 2];
        for (int i = 0; i < _barcodeColumnCount + 2; i++) {
            [_detectionResultColumnsInternal addObject:[NSNull null]];
        }
        _boundingBox = AGX_RETAIN(boundingBox);
    }
    return self;
}

- (void)dealloc {
    AGX_RELEASE(_barcodeMetadata);
    AGX_RELEASE(_detectionResultColumnsInternal);
    AGX_RELEASE(_boundingBox);
    AGX_SUPER_DEALLOC;
}

- (NSArray *)detectionResultColumns {
    [self adjustIndicatorColumnRowNumbers:_detectionResultColumnsInternal[0]];
    [self adjustIndicatorColumnRowNumbers:_detectionResultColumnsInternal[_barcodeColumnCount + 1]];
    int unadjustedCodewordCount = AGX_PDF417_MAX_CODEWORDS_IN_BARCODE;
    int previousUnadjustedCount;
    do {
        previousUnadjustedCount = unadjustedCodewordCount;
        unadjustedCodewordCount = [self adjustRowNumbers];
    } while (unadjustedCodewordCount > 0 && unadjustedCodewordCount < previousUnadjustedCount);
    return _detectionResultColumnsInternal;
}

- (int)barcodeColumnCount {
    return _barcodeColumnCount;
}

- (int)barcodeRowCount {
    return _barcodeMetadata.rowCount;
}

- (int)barcodeECLevel {
    return _barcodeMetadata.errorCorrectionLevel;
}

- (void)setDetectionResultColumn:(int)barcodeColumn detectionResultColumn:(AGXPDF417DetectionResultColumn *)detectionResultColumn {
    if (!detectionResultColumn) {
        _detectionResultColumnsInternal[barcodeColumn] = [NSNull null];
    } else {
        _detectionResultColumnsInternal[barcodeColumn] = detectionResultColumn;
    }
}

- (AGXPDF417DetectionResultColumn *)detectionResultColumn:(int)barcodeColumn {
    AGXPDF417DetectionResultColumn *result = _detectionResultColumnsInternal[barcodeColumn];
    return (id)result == [NSNull null] ? nil : result;
}

- (NSString *)description {
    AGXPDF417DetectionResultColumn *rowIndicatorColumn = _detectionResultColumnsInternal[0];
    if ((id)rowIndicatorColumn == [NSNull null]) {
        rowIndicatorColumn = _detectionResultColumnsInternal[_barcodeColumnCount + 1];
    }
    NSMutableString *result = [NSMutableString string];
    for (int codewordsRow = 0; codewordsRow < [rowIndicatorColumn.codewords count]; codewordsRow++) {
        [result appendFormat:@"CW %3d:", codewordsRow];
        for (int barcodeColumn = 0; barcodeColumn < _barcodeColumnCount + 2; barcodeColumn++) {
            if (_detectionResultColumnsInternal[barcodeColumn] == [NSNull null]) {
                [result appendString:@"    |   "];
                continue;
            }
            AGXPDF417Codeword *codeword = [(AGXPDF417DetectionResultColumn *)_detectionResultColumnsInternal[barcodeColumn] codewords][codewordsRow];
            if ((id)codeword == [NSNull null]) {
                [result appendString:@"    |   "];
                continue;
            }
            [result appendFormat:@" %3d|%3d", codeword.rowNumber, codeword.value];
        }
        [result appendString:@"\n"];
    }
    return [NSString stringWithString:result];
}

#pragma mark - private methods

- (void)adjustIndicatorColumnRowNumbers:(AGXPDF417DetectionResultColumn *)detectionResultColumn {
    if (detectionResultColumn && (id)detectionResultColumn != [NSNull null]) {
        [(AGXPDF417DetectionResultRowIndicatorColumn *)detectionResultColumn adjustCompleteIndicatorColumnRowNumbers:_barcodeMetadata];
    }
}

- (int)adjustRowNumbers {
    int unadjustedCount = [self adjustRowNumbersByRow];
    if (unadjustedCount == 0) {
        return 0;
    }
    for (int barcodeColumn = 1; barcodeColumn < _barcodeColumnCount + 1; barcodeColumn++) {
        NSArray *codewords = [_detectionResultColumnsInternal[barcodeColumn] codewords];
        for (int codewordsRow = 0; codewordsRow < [codewords count]; codewordsRow++) {
            if ((id)codewords[codewordsRow] == [NSNull null]) {
                continue;
            }
            if (![codewords[codewordsRow] hasValidRowNumber]) {
                [self adjustRowNumbers:barcodeColumn codewordsRow:codewordsRow codewords:codewords];
            }
        }
    }
    return unadjustedCount;
}

- (int)adjustRowNumbersByRow {
    [self adjustRowNumbersFromBothRI];
    // TODO we should only do full row adjustments if row numbers of left and right row indicator column match.
    // Maybe it's even better to calculated the height (in codeword rows) and divide it by the number of barcode
    // rows. This, together with the LRI and RRI row numbers should allow us to get a good estimate where a row
    // number starts and ends.
    int unadjustedCount = [self adjustRowNumbersFromLRI];
    return unadjustedCount + [self adjustRowNumbersFromRRI];
}

- (void)adjustRowNumbersFromBothRI {
    if (_detectionResultColumnsInternal[0] == [NSNull null] || _detectionResultColumnsInternal[_barcodeColumnCount + 1] == [NSNull null]) {
        return;
    }
    NSArray *LRIcodewords = [(AGXPDF417DetectionResultColumn *)_detectionResultColumnsInternal[0] codewords];
    NSArray *RRIcodewords = [(AGXPDF417DetectionResultColumn *)_detectionResultColumnsInternal[_barcodeColumnCount + 1] codewords];
    for (int codewordsRow = 0; codewordsRow < [LRIcodewords count]; codewordsRow++) {
        if (LRIcodewords[codewordsRow] != [NSNull null] &&
            RRIcodewords[codewordsRow] != [NSNull null] &&
            [(AGXPDF417Codeword *)LRIcodewords[codewordsRow] rowNumber] == [(AGXPDF417Codeword *)RRIcodewords[codewordsRow] rowNumber]) {
            for (int barcodeColumn = 1; barcodeColumn <= _barcodeColumnCount; barcodeColumn++) {
                AGXPDF417Codeword *codeword = [(AGXPDF417DetectionResultColumn *)_detectionResultColumnsInternal[barcodeColumn] codewords][codewordsRow];
                if ((id)codeword == [NSNull null]) {
                    continue;
                }
                codeword.rowNumber = [(AGXPDF417Codeword *)LRIcodewords[codewordsRow] rowNumber];
                if (![codeword hasValidRowNumber]) {
                    [(AGXPDF417DetectionResultColumn *)_detectionResultColumnsInternal[barcodeColumn] codewords][codewordsRow] = [NSNull null];
                }
            }
        }
    }
}

- (int)adjustRowNumbersFromLRI {
    if (_detectionResultColumnsInternal[0] == [NSNull null]) return 0;

    int unadjustedCount = 0;
    NSArray *codewords = [_detectionResultColumnsInternal[0] codewords];
    for (int codewordsRow = 0; codewordsRow < [codewords count]; codewordsRow++) {
        if ((id)codewords[codewordsRow] == [NSNull null]) {
            continue;
        }
        int rowIndicatorRowNumber = [codewords[codewordsRow] rowNumber];
        int invalidRowCounts = 0;
        for (int barcodeColumn = 1; barcodeColumn < _barcodeColumnCount + 1 && invalidRowCounts < AGX_PDF417_ADJUST_ROW_NUMBER_SKIP; barcodeColumn++) {
            if (_detectionResultColumnsInternal[barcodeColumn] != [NSNull null]) {
                AGXPDF417Codeword *codeword = [_detectionResultColumnsInternal[barcodeColumn] codewords][codewordsRow];
                if ((id)codeword != [NSNull null]) {
                    invalidRowCounts = [self adjustRowNumberIfValid:rowIndicatorRowNumber invalidRowCounts:invalidRowCounts codeword:codeword];
                    if (![codeword hasValidRowNumber]) {
                        unadjustedCount++;
                    }
                }
            }
        }
    }
    return unadjustedCount;
}

- (int)adjustRowNumbersFromRRI {
    if (_detectionResultColumnsInternal[_barcodeColumnCount + 1] == [NSNull null]) return 0;

    int unadjustedCount = 0;
    NSArray *codewords = [_detectionResultColumnsInternal[_barcodeColumnCount + 1] codewords];
    for (int codewordsRow = 0; codewordsRow < [codewords count]; codewordsRow++) {
        if ((id)codewords[codewordsRow] == [NSNull null]) {
            continue;
        }
        int rowIndicatorRowNumber = [codewords[codewordsRow] rowNumber];
        int invalidRowCounts = 0;
        for (int barcodeColumn = _barcodeColumnCount + 1; barcodeColumn > 0 && invalidRowCounts < AGX_PDF417_ADJUST_ROW_NUMBER_SKIP; barcodeColumn--) {
            if (_detectionResultColumnsInternal[barcodeColumn] != [NSNull null]) {
                AGXPDF417Codeword *codeword = [_detectionResultColumnsInternal[barcodeColumn] codewords][codewordsRow];
                if ((id)codeword != [NSNull null]) {
                    invalidRowCounts = [self adjustRowNumberIfValid:rowIndicatorRowNumber invalidRowCounts:invalidRowCounts codeword:codeword];
                    if (![codeword hasValidRowNumber]) {
                        unadjustedCount++;
                    }
                }
            }
        }
    }
    return unadjustedCount;
}

- (int)adjustRowNumberIfValid:(int)rowIndicatorRowNumber invalidRowCounts:(int)invalidRowCounts codeword:(AGXPDF417Codeword *)codeword {
    if (!codeword) return invalidRowCounts;

    if (![codeword hasValidRowNumber]) {
        if ([codeword isValidRowNumber:rowIndicatorRowNumber]) {
            [codeword setRowNumber:rowIndicatorRowNumber];
            invalidRowCounts = 0;
        } else {
            ++invalidRowCounts;
        }
    }
    return invalidRowCounts;
}

- (void)adjustRowNumbers:(int)barcodeColumn codewordsRow:(int)codewordsRow codewords:(NSArray *)codewords {
    AGXPDF417Codeword *codeword = codewords[codewordsRow];
    NSArray *previousColumnCodewords = [_detectionResultColumnsInternal[barcodeColumn - 1] codewords];
    NSArray *nextColumnCodewords = previousColumnCodewords;
    if (_detectionResultColumnsInternal[barcodeColumn + 1] != [NSNull null]) {
        nextColumnCodewords = [_detectionResultColumnsInternal[barcodeColumn + 1] codewords];
    }

    NSMutableArray *otherCodewords = [NSMutableArray arrayWithCapacity:14];
    for (int i = 0; i < 14; i++) {
        [otherCodewords addObject:[NSNull null]];
    }

    otherCodewords[2] = previousColumnCodewords[codewordsRow];
    otherCodewords[3] = nextColumnCodewords[codewordsRow];

    if (codewordsRow > 0) {
        otherCodewords[0] = codewords[codewordsRow - 1];
        otherCodewords[4] = previousColumnCodewords[codewordsRow - 1];
        otherCodewords[5] = nextColumnCodewords[codewordsRow - 1];
    }
    if (codewordsRow > 1) {
        otherCodewords[8] = codewords[codewordsRow - 2];
        otherCodewords[10] = previousColumnCodewords[codewordsRow - 2];
        otherCodewords[11] = nextColumnCodewords[codewordsRow - 2];
    }
    if (codewordsRow < [codewords count] - 1) {
        otherCodewords[1] = codewords[codewordsRow + 1];
        otherCodewords[6] = previousColumnCodewords[codewordsRow + 1];
        otherCodewords[7] = nextColumnCodewords[codewordsRow + 1];
    }
    if (codewordsRow < [codewords count] - 2) {
        otherCodewords[9] = codewords[codewordsRow + 2];
        otherCodewords[12] = previousColumnCodewords[codewordsRow + 2];
        otherCodewords[13] = nextColumnCodewords[codewordsRow + 2];
    }
    for (AGXPDF417Codeword *otherCodeword in otherCodewords) {
        if ([self adjustRowNumber:codeword otherCodeword:otherCodeword]) {
            return;
        }
    }
}
- (BOOL)adjustRowNumber:(AGXPDF417Codeword *)codeword otherCodeword:(AGXPDF417Codeword *)otherCodeword {
    if ((id)otherCodeword == [NSNull null]) {
        return NO;
    }
    if ([otherCodeword hasValidRowNumber] && otherCodeword.bucket == codeword.bucket) {
        [codeword setRowNumber:otherCodeword.rowNumber];
        return YES;
    }
    return NO;
}

@end
