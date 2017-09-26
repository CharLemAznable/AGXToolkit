//
//  AGXDataMatrixBitMatrixParser.m
//  AGXGcode
//
//  Created by Char Aznable on 16/8/10.
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
#import "AGXDataMatrixBitMatrixParser.h"
#import "AGXGcodeError.h"

@implementation AGXDataMatrixBitMatrixParser {
    AGXBitMatrix *_mappingBitMatrix;
    AGXBitMatrix *_readMappingMatrix;
}

+ (AGX_INSTANCETYPE)parserWithBitMatrix:(AGXBitMatrix *)bitMatrix error:(NSError **)error {
    int dimension = bitMatrix.height;
    if AGX_EXPECT_F(dimension < 8 || dimension > 144 || (dimension & 0x01) != 0) {
        if AGX_EXPECT_T(error) *error = AGXFormatErrorInstance();
        return nil;
    }
    AGXDataMatrixVersion *version = [self readVersion:bitMatrix];
    if AGX_EXPECT_F(!version) {
        if AGX_EXPECT_T(error) *error = AGXFormatErrorInstance();
        return nil;
    }
    return AGX_AUTORELEASE([[self alloc] initWithVersion:version bitMatrix:bitMatrix]);
}

- (AGX_INSTANCETYPE)initWithVersion:(AGXDataMatrixVersion *)version bitMatrix:(AGXBitMatrix *)bitMatrix {
    if AGX_EXPECT_T(self = [super init]) {
        _version = AGX_RETAIN(version);
        _mappingBitMatrix = AGX_RETAIN([self extractDataRegion:bitMatrix]);
        _readMappingMatrix = [[AGXBitMatrix alloc] initWithWidth:_mappingBitMatrix.width height:_mappingBitMatrix.height];
    }
    return self;
}

- (void)dealloc {
    AGX_RELEASE(_version);
    AGX_RELEASE(_mappingBitMatrix);
    AGX_RELEASE(_readMappingMatrix);
    AGX_SUPER_DEALLOC;
}

+ (AGXDataMatrixVersion *)readVersion:(AGXBitMatrix *)bitMatrix {
    return [AGXDataMatrixVersion versionForDimensions:bitMatrix.height numColumns:bitMatrix.width];
}

- (AGXBitMatrix *)extractDataRegion:(AGXBitMatrix *)bitMatrix {
    int symbolSizeRows = _version.symbolSizeRows;
    int symbolSizeColumns = _version.symbolSizeColumns;

    if AGX_EXPECT_F(bitMatrix.height != symbolSizeRows)
        [NSException raise:NSInvalidArgumentException format:@"Dimension of bitMatrix must match the version size"];

    int dataRegionSizeRows = _version.dataRegionSizeRows;
    int dataRegionSizeColumns = _version.dataRegionSizeColumns;

    int numDataRegionsRow = symbolSizeRows / dataRegionSizeRows;
    int numDataRegionsColumn = symbolSizeColumns / dataRegionSizeColumns;

    int sizeDataRegionRow = numDataRegionsRow * dataRegionSizeRows;
    int sizeDataRegionColumn = numDataRegionsColumn * dataRegionSizeColumns;

    AGXBitMatrix *bitMatrixWithoutAlignment = [AGXBitMatrix bitMatrixWithWidth:sizeDataRegionColumn height:sizeDataRegionRow];
    for (int dataRegionRow = 0; dataRegionRow < numDataRegionsRow; ++dataRegionRow) {
        int dataRegionRowOffset = dataRegionRow * dataRegionSizeRows;
        for (int dataRegionColumn = 0; dataRegionColumn < numDataRegionsColumn; ++dataRegionColumn) {
            int dataRegionColumnOffset = dataRegionColumn * dataRegionSizeColumns;
            for (int i = 0; i < dataRegionSizeRows; ++i) {
                int readRowOffset = dataRegionRow * (dataRegionSizeRows + 2) + 1 + i;
                int writeRowOffset = dataRegionRowOffset + i;
                for (int j = 0; j < dataRegionSizeColumns; ++j) {
                    int readColumnOffset = dataRegionColumn * (dataRegionSizeColumns + 2) + 1 + j;
                    if ([bitMatrix getX:readColumnOffset y:readRowOffset]) {
                        int writeColumnOffset = dataRegionColumnOffset + j;
                        [bitMatrixWithoutAlignment setX:writeColumnOffset y:writeRowOffset];
                    }
                }
            }
        }
    }
    return bitMatrixWithoutAlignment;
}

- (AGXByteArray *)readCodewords {
    AGXByteArray *result = [AGXByteArray byteArrayWithLength:_version.totalCodewords];
    int resultOffset = 0;

    int row = 4;
    int column = 0;

    int numRows = _mappingBitMatrix.height;
    int numColumns = _mappingBitMatrix.width;

    BOOL corner1Read = NO;
    BOOL corner2Read = NO;
    BOOL corner3Read = NO;
    BOOL corner4Read = NO;

    do {
        if ((row == numRows) && (column == 0) && !corner1Read) {
            result.array[resultOffset++] = (int8_t) [self readCorner1:numRows numColumns:numColumns];
            row -= 2;
            column += 2;
            corner1Read = YES;
        } else if ((row == numRows - 2) && (column == 0) && ((numColumns & 0x03) != 0) && !corner2Read) {
            result.array[resultOffset++] = (int8_t) [self readCorner2:numRows numColumns:numColumns];
            row -= 2;
            column += 2;
            corner2Read = YES;
        } else if ((row == numRows + 4) && (column == 2) && ((numColumns & 0x07) == 0) && !corner3Read) {
            result.array[resultOffset++] = (int8_t) [self readCorner3:numRows numColumns:numColumns];
            row -= 2;
            column += 2;
            corner3Read = YES;
        } else if ((row == numRows - 2) && (column == 0) && ((numColumns & 0x07) == 4) && !corner4Read) {
            result.array[resultOffset++] = (int8_t) [self readCorner4:numRows numColumns:numColumns];
            row -= 2;
            column += 2;
            corner4Read = YES;
        } else {
            do {
                if ((row < numRows) && (column >= 0) && ![_readMappingMatrix getX:column y:row]) {
                    result.array[resultOffset++] = (int8_t) [self readUtah:row column:column numRows:numRows numColumns:numColumns];
                }
                row -= 2;
                column += 2;
            } while ((row >= 0) && (column < numColumns));
            row += 1;
            column += 3;

            do {
                if ((row >= 0) && (column < numColumns) && ![_readMappingMatrix getX:column y:row]) {
                    result.array[resultOffset++] = (int8_t) [self readUtah:row column:column numRows:numRows numColumns:numColumns];
                }
                row += 2;
                column -= 2;
            } while ((row < numRows) && (column >= 0));
            row += 3;
            column += 1;
        }
    } while ((row < numRows) || (column < numColumns));
    
    if AGX_EXPECT_F(resultOffset != _version.totalCodewords) return nil;
    return result;
}

- (int)readCorner1:(int)numRows numColumns:(int)numColumns {
    int currentByte = 0;
    if ([self readModule:numRows - 1 column:0 numRows:numRows numColumns:numColumns]) {
        currentByte |= 1;
    }
    currentByte <<= 1;
    if ([self readModule:numRows - 1 column:1 numRows:numRows numColumns:numColumns]) {
        currentByte |= 1;
    }
    currentByte <<= 1;
    if ([self readModule:numRows - 1 column:2 numRows:numRows numColumns:numColumns]) {
        currentByte |= 1;
    }
    currentByte <<= 1;
    if ([self readModule:0 column:numColumns - 2 numRows:numRows numColumns:numColumns]) {
        currentByte |= 1;
    }
    currentByte <<= 1;
    if ([self readModule:0 column:numColumns - 1 numRows:numRows numColumns:numColumns]) {
        currentByte |= 1;
    }
    currentByte <<= 1;
    if ([self readModule:1 column:numColumns - 1 numRows:numRows numColumns:numColumns]) {
        currentByte |= 1;
    }
    currentByte <<= 1;
    if ([self readModule:2 column:numColumns - 1 numRows:numRows numColumns:numColumns]) {
        currentByte |= 1;
    }
    currentByte <<= 1;
    if ([self readModule:3 column:numColumns - 1 numRows:numRows numColumns:numColumns]) {
        currentByte |= 1;
    }
    return currentByte;
}

- (int)readCorner2:(int)numRows numColumns:(int)numColumns {
    int currentByte = 0;
    if ([self readModule:numRows - 3 column:0 numRows:numRows numColumns:numColumns]) {
        currentByte |= 1;
    }
    currentByte <<= 1;
    if ([self readModule:numRows - 2 column:0 numRows:numRows numColumns:numColumns]) {
        currentByte |= 1;
    }
    currentByte <<= 1;
    if ([self readModule:numRows - 1 column:0 numRows:numRows numColumns:numColumns]) {
        currentByte |= 1;
    }
    currentByte <<= 1;
    if ([self readModule:0 column:numColumns - 4 numRows:numRows numColumns:numColumns]) {
        currentByte |= 1;
    }
    currentByte <<= 1;
    if ([self readModule:0 column:numColumns - 3 numRows:numRows numColumns:numColumns]) {
        currentByte |= 1;
    }
    currentByte <<= 1;
    if ([self readModule:0 column:numColumns - 2 numRows:numRows numColumns:numColumns]) {
        currentByte |= 1;
    }
    currentByte <<= 1;
    if ([self readModule:0 column:numColumns - 1 numRows:numRows numColumns:numColumns]) {
        currentByte |= 1;
    }
    currentByte <<= 1;
    if ([self readModule:1 column:numColumns - 1 numRows:numRows numColumns:numColumns]) {
        currentByte |= 1;
    }
    return currentByte;
}

- (int)readCorner3:(int)numRows numColumns:(int)numColumns {
    int currentByte = 0;
    if ([self readModule:numRows - 1 column:0 numRows:numRows numColumns:numColumns]) {
        currentByte |= 1;
    }
    currentByte <<= 1;
    if ([self readModule:numRows - 1 column:numColumns - 1 numRows:numRows numColumns:numColumns]) {
        currentByte |= 1;
    }
    currentByte <<= 1;
    if ([self readModule:0 column:numColumns - 3 numRows:numRows numColumns:numColumns]) {
        currentByte |= 1;
    }
    currentByte <<= 1;
    if ([self readModule:0 column:numColumns - 2 numRows:numRows numColumns:numColumns]) {
        currentByte |= 1;
    }
    currentByte <<= 1;
    if ([self readModule:0 column:numColumns - 1 numRows:numRows numColumns:numColumns]) {
        currentByte |= 1;
    }
    currentByte <<= 1;
    if ([self readModule:1 column:numColumns - 3 numRows:numRows numColumns:numColumns]) {
        currentByte |= 1;
    }
    currentByte <<= 1;
    if ([self readModule:1 column:numColumns - 2 numRows:numRows numColumns:numColumns]) {
        currentByte |= 1;
    }
    currentByte <<= 1;
    if ([self readModule:1 column:numColumns - 1 numRows:numRows numColumns:numColumns]) {
        currentByte |= 1;
    }
    return currentByte;
}

- (int)readCorner4:(int)numRows numColumns:(int)numColumns {
    int currentByte = 0;
    if ([self readModule:numRows - 3 column:0 numRows:numRows numColumns:numColumns]) {
        currentByte |= 1;
    }
    currentByte <<= 1;
    if ([self readModule:numRows - 2 column:0 numRows:numRows numColumns:numColumns]) {
        currentByte |= 1;
    }
    currentByte <<= 1;
    if ([self readModule:numRows - 1 column:0 numRows:numRows numColumns:numColumns]) {
        currentByte |= 1;
    }
    currentByte <<= 1;
    if ([self readModule:0 column:numColumns - 2 numRows:numRows numColumns:numColumns]) {
        currentByte |= 1;
    }
    currentByte <<= 1;
    if ([self readModule:0 column:numColumns - 1 numRows:numRows numColumns:numColumns]) {
        currentByte |= 1;
    }
    currentByte <<= 1;
    if ([self readModule:1 column:numColumns - 1 numRows:numRows numColumns:numColumns]) {
        currentByte |= 1;
    }
    currentByte <<= 1;
    if ([self readModule:2 column:numColumns - 1 numRows:numRows numColumns:numColumns]) {
        currentByte |= 1;
    }
    currentByte <<= 1;
    if ([self readModule:3 column:numColumns - 1 numRows:numRows numColumns:numColumns]) {
        currentByte |= 1;
    }
    return currentByte;
}

- (int)readUtah:(int)row column:(int)column numRows:(int)numRows numColumns:(int)numColumns {
    int currentByte = 0;
    if ([self readModule:row - 2 column:column - 2 numRows:numRows numColumns:numColumns]) {
        currentByte |= 1;
    }
    currentByte <<= 1;
    if ([self readModule:row - 2 column:column - 1 numRows:numRows numColumns:numColumns]) {
        currentByte |= 1;
    }
    currentByte <<= 1;
    if ([self readModule:row - 1 column:column - 2 numRows:numRows numColumns:numColumns]) {
        currentByte |= 1;
    }
    currentByte <<= 1;
    if ([self readModule:row - 1 column:column - 1 numRows:numRows numColumns:numColumns]) {
        currentByte |= 1;
    }
    currentByte <<= 1;
    if ([self readModule:row - 1 column:column numRows:numRows numColumns:numColumns]) {
        currentByte |= 1;
    }
    currentByte <<= 1;
    if ([self readModule:row column:column - 2 numRows:numRows numColumns:numColumns]) {
        currentByte |= 1;
    }
    currentByte <<= 1;
    if ([self readModule:row column:column - 1 numRows:numRows numColumns:numColumns]) {
        currentByte |= 1;
    }
    currentByte <<= 1;
    if ([self readModule:row column:column numRows:numRows numColumns:numColumns]) {
        currentByte |= 1;
    }
    return currentByte;
}

- (BOOL)readModule:(int)row column:(int)column numRows:(int)numRows numColumns:(int)numColumns {
    if (row < 0) {
        row += numRows;
        column += 4 - ((numRows + 4) & 0x07);
    }
    if (column < 0) {
        column += numColumns;
        row += 4 - ((numColumns + 4) & 0x07);
    }
    [_readMappingMatrix setX:column y:row];
    return [_mappingBitMatrix getX:column y:row];
}

@end
