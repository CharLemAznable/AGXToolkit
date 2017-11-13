//
//  AGXPDF417DetectionResultColumn.h
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

#ifndef AGXGcode_AGXPDF417DetectionResultColumn_h
#define AGXGcode_AGXPDF417DetectionResultColumn_h

#import "AGXPDF417BoundingBox.h"
#import "AGXPDF417Codeword.h"

@interface AGXPDF417DetectionResultColumn : NSObject
@property (nonatomic, readonly) AGXPDF417BoundingBox *boundingBox;
@property (nonatomic, readonly) NSMutableArray *codewords;

+ (AGX_INSTANCETYPE)columnWithBoundingBox:(AGXPDF417BoundingBox *)boundingBox;
- (AGX_INSTANCETYPE)initWithBoundingBox:(AGXPDF417BoundingBox *)boundingBox;
- (int)imageRowToCodewordIndex:(int)imageRow;
- (void)setCodeword:(int)imageRow codeword:(AGXPDF417Codeword *)codeword;
- (AGXPDF417Codeword *)codeword:(int)imageRow;
- (AGXPDF417Codeword *)codewordNearby:(int)imageRow;
@end

#endif /* AGXGcode_AGXPDF417DetectionResultColumn_h */
