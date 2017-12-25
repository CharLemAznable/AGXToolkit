//
//  AGXPDF417Common.h
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

#ifndef AGXGcode_AGXPDF417Common_h
#define AGXGcode_AGXPDF417Common_h

#import "AGXIntArray.h"

#define AGX_PDF417_SYMBOL_TABLE_LEN 2787
#define AGX_PDF417_BARS_IN_MODULE 8

extern const int AGX_PDF417_SYMBOL_TABLE[];
extern const int AGX_PDF417_NUMBER_OF_CODEWORDS;
extern const int AGX_PDF417_MIN_ROWS_IN_BARCODE;
extern const int AGX_PDF417_MAX_ROWS_IN_BARCODE;
extern const int AGX_PDF417_MAX_CODEWORDS_IN_BARCODE;
extern const int AGX_PDF417_MODULES_IN_CODEWORD;
extern const int AGX_PDF417_MODULES_IN_STOP_PATTERN;

@interface AGXPDF417Common : NSObject
+ (int)bitCountSum:(NSArray *)moduleBitCount;
+ (AGXIntArray *)toIntArray:(NSArray *)list;
+ (int)codeword:(int)symbol;
@end

#endif /* AGXGcode_AGXPDF417Common_h */
