//
//  AGXOneDAbstractReader.h
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

#ifndef AGXGcode_AGXOneDAbstractReader_h
#define AGXGcode_AGXOneDAbstractReader_h

#import "AGXGcodeReader.h"
#import "AGXBitArray.h"
#import "AGXDecodeHints.h"
#import "AGXGcodeResult.h"

BOOL recordPattern(AGXBitArray *row, int start, AGXIntArray *counters);
BOOL recordPatternInReverse(AGXBitArray *row, int start, AGXIntArray *counters);
float patternMatchVariance(AGXIntArray *counters, const int pattern[], float maxIndividualVariance);

@interface AGXOneDAbstractReader : NSObject <AGXGcodeReader>
- (AGXGcodeResult *)decodeRow:(int)rowNumber row:(AGXBitArray *)row hints:(AGXDecodeHints *)hints error:(NSError **)error;
@end

#endif /* AGXGcode_AGXOneDAbstractReader_h */
