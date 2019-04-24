//
//  AGXUPCEANAbstractReader.h
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

#ifndef AGXGcode_AGXUPCEANAbstractReader_h
#define AGXGcode_AGXUPCEANAbstractReader_h

#import "AGXOneDAbstractReader.h"
#import "AGXGcodeFormat.h"

typedef enum {
    AGX_UPC_EAN_PATTERNS_L_PATTERNS = 0,
    AGX_UPC_EAN_PATTERNS_L_AND_G_PATTERNS
} AGX_UPC_EAN_PATTERNS;

extern const int AGX_UPC_EAN_START_END_PATTERN_LEN;
extern const int AGX_UPC_EAN_START_END_PATTERN[];
extern const int AGX_UPC_EAN_MIDDLE_PATTERN_LEN;
extern const int AGX_UPC_EAN_MIDDLE_PATTERN[];
extern const int AGX_UPC_EAN_L_PATTERNS_LEN;
extern const int AGX_UPC_EAN_L_PATTERNS_SUB_LEN;
extern const int AGX_UPC_EAN_L_PATTERNS[][4];
extern const int AGX_UPC_EAN_L_AND_G_PATTERNS_LEN;
extern const int AGX_UPC_EAN_L_AND_G_PATTERNS_SUB_LEN;
extern const int AGX_UPC_EAN_L_AND_G_PATTERNS[][4];

NSRange findStartGuardPattern(AGXBitArray *row, NSError **error);
NSRange findGuardPattern(AGXBitArray *row, int rowOffset, BOOL whiteFirst, const int pattern[], int patternLen, AGXIntArray *counters, NSError **error);
BOOL checkStandardUPCEANChecksum(NSString *sumString);
int decodeDigit(AGXBitArray *row, AGXIntArray *counters, int rowOffset, AGX_UPC_EAN_PATTERNS patternType, NSError **error);

@interface AGXUPCEANAbstractReader : AGXOneDAbstractReader
- (AGXGcodeResult *)decodeRow:(int)rowNumber row:(AGXBitArray *)row startGuardRange:(NSRange)startGuardRange hints:(AGXDecodeHints *)hints error:(NSError **)error;
- (NSRange)decodeEnd:(AGXBitArray *)row endStart:(int)endStart error:(NSError **)error;
- (BOOL)checkChecksum:(NSString *)sumString error:(NSError **)error;
- (AGXGcodeFormat)gcodeFormat;
- (int)decodeMiddle:(AGXBitArray *)row startRange:(NSRange)startRange result:(NSMutableString *)result error:(NSError **)error;
@end

#endif /* AGXGcode_AGXUPCEANAbstractReader_h */
