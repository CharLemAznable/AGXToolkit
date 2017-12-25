//
//  AGXPDF417DetectionResultRowIndicatorColumn.h
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

#ifndef AGXGcode_AGXPDF417DetectionResultRowIndicatorColumn_h
#define AGXGcode_AGXPDF417DetectionResultRowIndicatorColumn_h

#import "AGXPDF417DetectionResultColumn.h"
#import "AGXPDF417BarcodeMetadata.h"

@interface AGXPDF417DetectionResultRowIndicatorColumn : AGXPDF417DetectionResultColumn
@property (nonatomic, readonly) BOOL isLeft;

+ (AGX_INSTANCETYPE)columnWithBoundingBox:(AGXPDF417BoundingBox *)boundingBox isLeft:(BOOL)isLeft;
- (AGX_INSTANCETYPE)initWithBoundingBox:(AGXPDF417BoundingBox *)boundingBox isLeft:(BOOL)isLeft;
- (BOOL)getRowHeights:(AGXIntArray **)rowHeights;
- (int)adjustCompleteIndicatorColumnRowNumbers:(AGXPDF417BarcodeMetadata *)barcodeMetadata;
- (AGXPDF417BarcodeMetadata *)barcodeMetadata;
@end

#endif /* AGXGcode_AGXPDF417DetectionResultRowIndicatorColumn_h */
