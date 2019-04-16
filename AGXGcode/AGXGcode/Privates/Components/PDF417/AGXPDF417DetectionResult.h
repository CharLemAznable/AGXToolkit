//
//  AGXPDF417DetectionResult.h
//  AGXGcode
//
//  Created by Char Aznable on 2016/8/2.
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

#ifndef AGXGcode_AGXPDF417DetectionResult_h
#define AGXGcode_AGXPDF417DetectionResult_h

#import <AGXCore/AGXCore/AGXArc.h>
#import "AGXPDF417BarcodeMetadata.h"
#import "AGXPDF417DetectionResultColumn.h"

@interface AGXPDF417DetectionResult : NSObject
@property (nonatomic, AGX_STRONG) AGXPDF417BoundingBox *boundingBox;

+ (AGX_INSTANCETYPE)detectionResultWithBarcodeMetadata:(AGXPDF417BarcodeMetadata *)barcodeMetadata boundingBox:(AGXPDF417BoundingBox *)boundingBox;
- (AGX_INSTANCETYPE)initWithBarcodeMetadata:(AGXPDF417BarcodeMetadata *)barcodeMetadata boundingBox:(AGXPDF417BoundingBox *)boundingBox;
- (NSArray *)detectionResultColumns;
- (int)barcodeColumnCount;
- (int)barcodeRowCount;
- (int)barcodeECLevel;
- (void)setDetectionResultColumn:(int)barcodeColumn detectionResultColumn:(AGXPDF417DetectionResultColumn *)detectionResultColumn;
- (AGXPDF417DetectionResultColumn *)detectionResultColumn:(int)barcodeColumn;
@end

#endif /* AGXGcode_AGXPDF417DetectionResult_h */
